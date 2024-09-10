<#
    .SYNOPSIS
        Remove the legacy log analytics monitoring agent from VM and VM Scale sets

    .DESCRIPTION
        This runbook is supposed to be scheduled for example one time per day.
        It will identify all VMs and VM Scale Sets that have the legacy Log Analytics agent installed and remove it automatically.

        For the removal of the old agent to happen, the following conditions must be met:
        - The VM must have the managed tag set
        - The VM must be running
        - The VM must have both agent extensions installed : Microsoft Monitoring Agent (MMA) and Azure Monitoring Agent (AMA)
        - The VM must be associated with a Data collection Rule

    .OUTPUTS
        N/A

    .NOTES
        Author:     Frederic TRAPET
        Company:    Eviden
        Email:      frederic.trapet@eviden.com
        Created:    2024-03-07
        Updated:    2024-03-07
        Version:    1.0
#>

# Defines the maximum time allowed for this runbook to run in minutes, the goal is to process as much VMs as possible in this interval.
# (the removal of the old extension can take 2 minutes for a VM, and the maximum run time allowed by Azure is 3 hours)
[int] $maxRunbookRunTimeMinutes = 120

# Get connected
try {

  #Disable the Context inheritance from a previous session
  Disable-AzContextAutosave -Scope Process

  Write-Output "Logging into Azure with System-assigned Identity"
  $azConnect = Connect-AzAccount -Identity

  if (-not $azConnect) {
      Write-Error "Login error: Logging into azure Failed..." -ErrorAction 'Stop'
  }
  else {
      Write-Output "Successfully logged into the Azure Platform."
  }
}
catch {
  throw $_.Exception
}
$subscriptions = Get-AzSubscription

# Tags & Tag Values used in the runbook.
$tagPrefix      = Get-AutomationVariable -Name 'tagPrefix'
$managedTagName = "$($tagPrefix)Managed"
$windowsDCRName = "$($tagPrefix)-DCR-Windows"
$linuxDCRName   = "$($tagPrefix)-DCR-Linux"
$startTime      = $(get-date)

# -- VMs --
# Execute a resourcegraph query to get all managed VMs that are currently running, and have both extensions installed.
# The query will also return the Data Collection Rules associated with the VMs if any.

$resourceGraphQuery = @"
Resources
| where type =~ 'microsoft.compute/virtualmachines'
| extend PowerState = tostring(properties.extended.instanceView.powerState.code)
| where tolower(tostring(tags)) contains '"$($managedTagName.tolower())":"true"'
| where PowerState =~ 'PowerState/running'
| extend JoinID = toupper(id), OSType = tostring(properties.storageProfile.osDisk.osType), VMName = name
| join kind=leftouter(
    insightsresources
    | where type == 'microsoft.insights/datacollectionruleassociations'
    | where id contains 'microsoft.compute/virtualmachines/'
    | project id=tolower(id), properties
    | extend idComponents = split(id, '/providers/microsoft.insights/datacollectionruleassociations/')
    | extend VMId = toupper(tostring(idComponents[0]))
    | extend dcrId = properties['dataCollectionRuleId']
    | where isnotnull(dcrId)
    | extend dcrIdComponents = split(dcrId, '/')
    | extend dcrName = tostring(dcrIdComponents[8])
    | project VMId, dcrName
    | summarize DataCollectionRules = make_list(dcrName) by VMId
) on `$left.JoinID == `$right.VMId
| join kind=leftouter(
	Resources
	| where type == 'microsoft.compute/virtualmachines/extensions'
	| extend
		VMId = toupper(substring(id, 0, indexof(id, '/extensions'))),
		ExtensionName = name
) on `$left.JoinID == `$right.VMId
| summarize Extensions = make_list(ExtensionName) by id, VMName, OSType, tostring(DataCollectionRules)
| where
 ((Extensions contains 'AzureMonitorWindowsAgent') and (Extensions contains 'MicrosoftMonitoringAgent')) 
 or
 ((Extensions contains 'AzureMonitorLinuxAgent') and (Extensions contains 'OMSAgentForLinux'))
| project id, VMName, OSType, tostring(Extensions), DataCollectionRules
| limit 500
"@
$vmsWithLegacyAgentInstalled = Search-AzGraph -Subscription $subscriptions -Query $resourceGraphQuery

if ($vmsWithLegacyAgentInstalled.count -eq 0) {
  Write-Output "No VMs found with the legacy Log Analytics agent installed."
} else {
  foreach ($vm in $vmsWithLegacyAgentInstalled) {

    $elapsedTime = $(get-date) - $StartTime
    if ($elapsedTime.TotalMinutes -ge $maxRunbookRunTimeMinutes) {
      Write-Output "Processing time exceeded $($maxRunbookRunTimeMinutes) minutes. Stopping the runbook."
      break
    }

    $vmId = $vm.id
    $vmName = $vm.VMName
    $osType = $vm.OSType
    $dataCollectionRules = $vm.DataCollectionRules

    If (
      (($osType -eq "Windows") -and ($dataCollectionRules -like '*"' + $windowsDCRName + '"*')) -or 
      (($osType -eq "Linux") -and ($dataCollectionRules -like '*"' + $linuxDCRName + '"*'))
    )
    {
      $subscription = $vm.id.split("/")[2]
      $subcontext = Get-AzContext -ListAvailable | Where-Object {$_.Subscription -like $subscription}
      $extensionName = If ($osType -eq "Windows") {"MicrosoftMonitoringAgent"} else {"OmsAgentForLinux"}

      Write-Output "VM [$($vmName)] in subscription [$($subscription)] has both Legacy and New Monitoring agent installed."
      Write-Output "Removing the legacy Log Analytics agent extension [$($extensionName)] ..."

      $params = @{
        DefaultProfile    = $subcontext
        VMName            = $vmName
        ResourceGroupName = $vm.id.split("/")[4]
        Name              = $extensionName
        Force             = $true
      }
      try {
        $actionResult = Remove-AzVMExtension @params -ErrorAction stop
        If ($actionResult.IsSuccessStatusCode) {
          Write-Output "Extension successfully removed."
        } else {
          Write-Warning "Error while trying to remove the extension [$($extensionName)] on VM [$($vmName)]"
        }
      }
      catch {
        $errmsg = $Error[0].ToString()
        Write-Warning "Error while trying to remove the extension [$($extensionName)] on VM [$($vmName)] : $($errmsg)"
      }
    } else {
      Write-warning "VM [$($vmName)] with ID [$($vmId)] has both agents installed but no Data collection rule associated. Skipping VM."
    }
  }
}

# -- VM ScaleSets --
# Execute a resourcegraph query to get all managed VM ScaleSets, that have both extensions installed.

$resourceGraphQuery = @"
Resources
| where type =~ 'microsoft.compute/virtualMachineScaleSets'
| where tolower(tostring(tags)) contains '"$($managedTagName.tolower())":"true"'
| extend OSType = tostring(properties.virtualMachineProfile.storageProfile.osDisk.osType)
| extend ExtensionsData = parse_json(properties.virtualMachineProfile.extensionProfile.extensions)
| mv-expand ExtensionsData
| summarize Extensions = make_list(ExtensionsData.name) by id, name, OSType
| project id, VMSSName = name, OSType, tostring(Extensions)
| where
((Extensions contains 'AzureMonitorWindowsAgent') and (Extensions contains 'MicrosoftMonitoringAgent'))
or
((Extensions contains 'AzureMonitorLinuxAgent') and (Extensions contains 'OMSAgentForLinux'))
| limit 500
"@

if (-Not($elapsedTime.TotalMinutes -ge $maxRunbookRunTimeMinutes)) {
  $vmScaleSetsWithLegacyAgentInstalled = Search-AzGraph -Subscription $subscriptions -Query $resourceGraphQuery

  if ($vmScaleSetsWithLegacyAgentInstalled.count -eq 0) {
    Write-Output "No VM ScaleSets found with the legacy Log Analytics agent installed."
  } else {
    foreach ($vmSs in $vmScaleSetsWithLegacyAgentInstalled) {
      $elapsedTime = $(get-date) - $StartTime
      if ($elapsedTime.TotalMinutes -ge $maxRunbookRunTimeMinutes) {
        Write-Output "Processing time exceeded $($maxRunbookRunTimeMinutes) minutes. Stopping the runbook."
        break
      }

      $vmSsName = $vmSs.VMSSName
      $osType = $vmSs.OSType

      $subscription = $vmSs.id.split("/")[2]
      $subcontext = Get-AzContext -ListAvailable | Where-Object {$_.Subscription -like $subscription}
      $extensionName = If ($osType -eq "Windows") {"MicrosoftMonitoringAgent"} else {"OMSAgentForLinux"}

      Write-Output "VM ScaleSet [$($vmSsName)] in subscription [$($subscription)] has both Legacy and New Monitoring agent installed."
      Write-Output "Removing the legacy Log Analytics agent extension [$($extensionName)] ..."

      try {
        $vmSsObject = Get-AzVmss -DefaultProfile $subcontext -ResourceId $vmSs.id -ErrorAction stop
        $vmSsObject = Remove-AzVmssExtension -DefaultProfile $subcontext -VirtualMachineScaleSet $vmSsObject -Name $extensionName -ErrorAction stop
        $params = @{
          DefaultProfile          = $subcontext
          ResourceGroupName       = $vmSsObject.ResourceGroupName
          Name                    = $vmSsObject.Name
          VirtualMachineScaleSet  = $vmSsObject
        }
        Update-AzVmss @params -ErrorAction stop | Out-Null
        Write-Output "Extension successfully removed."
      }
      catch {
        $errmsg = $Error[0].ToString()
        Write-Warning "Error while trying to remove the extension [$($extensionName)] on VM ScaleSet [$($vmSsName)] : $($errmsg)"
      }
    }
  }
}