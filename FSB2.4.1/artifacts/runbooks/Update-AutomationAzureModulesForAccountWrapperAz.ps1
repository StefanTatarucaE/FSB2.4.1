<#
.SYNOPSIS
    This runbook will retrieve the two parameter values needed to start the Modules Update script.
    If it was able to retrieve those values it will start the Modules Update script runbook.

.DESCRIPTION
    This runbook will retrieve the two parameter values needed to start the Modules Update script.
    If it was able to retrieve those values it will start the Modules Update script runbook.

.PARAMETER ResourceGroupName
    Optional. The name of the Azure Resource Group containing the Automation account to update all modules for.
    If a resource group is not specified, then it will use the current one for the automation account
    if it is run from the automation service

.PARAMETER AutomationAccountName
    Optional. The name of the Automation account to update all modules for.
    If an automation account is not specified, then it will use the current one for the automation account
    if it is run from the automation service

.EXAMPLE
    N/A

.NOTES
    AUTHOR: Peter Lemmen / Frederic Trapet
    LASTEDIT: 28-07-2020
#>

param(
  [Parameter(Mandatory = $false)]
  [String] $ResourceGroupName,

  [Parameter(Mandatory = $false)]
  [String] $AutomationAccountName
)


# Get connected
try {

  #Disable the Context inheritance from a previous session
  Disable-AzContextAutosave -Scope Process

	Write-Output "Connecting to azure via  Connect-AzAccount -Identity" 
	Connect-AzAccount -Identity 
	Write-Output "Successfully connected with Automation account's Managed Identity" 

	$azContext = Get-AzContext
  Write-Output ("Selecting subscription [" + $azContext.Subscription.id + "]")
  
  $Subcontext = Get-AzContext -ListAvailable | Where-Object {$_.Subscription -like $azContext.Subscription.id } | Write-Verbose

  # Find the automation account or resource group if not specified
  if (([string]::IsNullOrEmpty($ResourceGroupName)) -or ([string]::IsNullOrEmpty($AutomationAccountName))) {
    Write-Output ("Finding the ResourceGroup and AutomationAccount this job is running in ...")
    if ([string]::IsNullOrEmpty($PSPrivateMetadata.JobId.Guid)) {
      throw "This is not running from the automation service. Please specify ResourceGroupName and AutomationAccountName as parameters"
    }
    Write-Output "Get all AutomationAccounts..."
    $AutomationResource = Get-AzResource -ResourceType Microsoft.Automation/AutomationAccounts -DefaultProfile $Subcontext

    foreach ($Automation in $AutomationResource) {
      $Job = Get-AzAutomationJob -ResourceGroupName $Automation.ResourceGroupName -AutomationAccountName $Automation.Name -Id $PSPrivateMetadata.JobId.Guid -DefaultProfile $Subcontext -ErrorAction SilentlyContinue
      if (!([string]::IsNullOrEmpty($Job))) {
        $ResourceGroupName = $Job.ResourceGroupName
        $AutomationAccountName = $Job.AutomationAccountName
        Write-Output "Discovered resource group name: ${ResourceGroupName}"
        Write-Output "Discovered automation account name: ${AutomationAccountName}"
        break;
      }
    }
  }

  # Check automation account and resource group once again
  if (([string]::IsNullOrEmpty($ResourceGroupName)) -or ([string]::IsNullOrEmpty($AutomationAccountName))) {
    throw "Failed to discover ResourceGroupName '$ResourceGroupName' or AutomationAccountName '$AutomationAccountName'"
  }
  else {
    $runbookParameters = @{
      "ResourceGroupName" = $ResourceGroupName
      "AutomationAccountName" = $AutomationAccountName
      "AzureModuleClass" = 'Az'
    }
    Write-Output "Starting runbook: Update-AutomationAzureModulesForAccount in automationaccount: ${AutomationAccountName} in resourcegroup: ${ResourceGroupName} "
    Start-AzAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name "Update-AutomationAzureModulesForAccount" -Parameters $runbookParameters
  }
  Write-Output "Done!"
} catch {
	throw $_.Exception
}
