<#
    .SYNOPSIS
        Peform custom monitoring operation and send alerts in Log Analytics custom table

    .DESCRIPTION
        This runbook perform various checks to monitor the following items in customer subscriptions :
        - Availablity sets
        If an issue is found, a custom alert is sent to a custom table in the Log Analytics workspace.
        Some predefined alert rules will pick those alerts and send them to ITSM.

    .OUTPUTS
        N/A

    .NOTES
        Author:     Frederic TRAPET
        Company:    Eviden
        Email:      frederic.Trapet@eviden.com
        Created:    2021-06-15
        Updated:    2023-08-07
        Version:    0.5
#>


##
## CONFIGURATION
##

[int]    $AVSET_MinimumCreationTimeHours = 12

##
## SCRIPT START
##

# Define branding variables needed for the Get-ServiceAndSendToLogAnalytics runbook from the automation account variables

$tagPrefix = Get-AutomationVariable -Name 'tagPrefix'
$tagValuePrefix = Get-AutomationVariable -Name 'tagValuePrefix'


# Tags & Tag Values used in the Get-ServiceAndSendToLogAnalytics runbook

$tagName = "$($tagPrefix)Purpose"
$managedTagName = "$($tagPrefix)Managed"
$laWorkspaceTag = "$($tagValuePrefix)Monitoring"

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

try {

    # Search each customer subscription for the primary Log Analytics workspace (based on the special tag)
    $workspaceSearch = Search-customerManagementLogAnalyticsWorkspace -tagname $tagName -tagValue $laWorkspaceTag
    Write-output "Using log Analytics workspace [$($workspaceSearch.LogAnalyticsWorkspace.Name)] ($($workspaceSearch.LogAnalyticsWorkspace.CustomerId))"

    ##
    ## Loop though each customer subscription and perform checks
    ##
    

    $subscriptions = Get-AzSubscription    
    foreach ($subscription in $subscriptions) {
        $Subcontext = Get-AzContext -ListAvailable | Where-Object {$_.Subscription -like $subscription.Id}
        Write-Output ("Selected Subscription is " + $subscription.Name)

        ##
        ## Check Availability-Sets - Ensure there is at least one running VM in two different fault-domains
        ##
        
        $avSets = Get-AzAvailabilitySet -DefaultProfile $Subcontext -ErrorAction SilentlyContinue
        foreach ($avSet in $avSets) {
            $ResourceTags = $avset.Tags
            If ($ResourceTags[$managedTagName] -ne "true") {continue}
            $FaultDomainsVM = new-object int[] $avSet.PlatformFaultDomainCount
            foreach ($resourceID in $avSet.VirtualMachinesReferences) {
                $VMData = Invoke-AzureRestAPIDataRequest -APIurl ($resourceID.id+'/instanceView?api-version=2017-03-30')
                If ($VMData) {
                    If ($VMData.statuses[1].code -eq 'PowerState/running') {
                        $FaultDomainsVM[$VMData.platformFaultDomain] += 1
                    }
                }
            }
            $ValidsFaultDomains = 0
            foreach ($NbVMsFaultDomain in $FaultDomainsVM) {
                If ($NbVMsFaultDomain -gt 0) {
                    $ValidsFaultDomains += 1
                }
            }
            If ($ValidsFaultDomains -lt 2) {
                $AVSetData = Invoke-AzureRestAPIDataRequest -APIurl ('/subscriptions/'+$subscription.Id+'/resources?$filter=name eq '''+$avSet.Name+''' and resourceType eq ''Microsoft.Compute/availabilitySets''&$expand=createdTime&top=1&api-version=2021-04-01')
                If ($AVSetData) {    
                    $DateDifference = (Get-Date) - [DateTime]$AVSetData.value[0].createdTime
                    If ($DateDifference.TotalHours -gt $AVSET_MinimumCreationTimeHours) {
                        Write-Output ("Invalid configuration detected for availability-set ["+$avSet.Name+"]")
                        $params = @{
                            AlertName = "Availability set has not enough VMs running for high-availability"
                            AlertDescription = "The availability set ["+$avSet.Name+"] has only "+$ValidsFaultDomains+" active fault domains with a running virtual machine, high availability will not be available in case of failure."
                            AlertCategory = "Availability Sets"
                            AlertSeverity = "warning"
                            AlertResourceId = $avSet.Id
                            ForceUseGenericCI = $true
                            LogAnalyticsWorkspace  = $workspaceSearch.LogAnalyticsWorkspace
                            WorkspaceSharedKeys    = $workspaceSearch.WorkspaceSharedKeys
                        }
                        Send-CustomAlertToLogAnalytics @params
                    } else {
                        Write-Output ("Ignoring invalid availability-set ["+$avSet.Name+"] because it was created less than "+$AVSET_MinimumCreationTimeHours+" hours ago")
                    }
                }
            }
        }        

        ##
        ## Other monitoring parts goes here ...
        ##
        
    }  
    Write-Output ("Process completed")       
} catch {
    Write-Error "Fatal error: $($_.ToString()) [$($_.InvocationInfo.ScriptLineNumber), $($_.InvocationInfo.OffsetInLine)]"
}
