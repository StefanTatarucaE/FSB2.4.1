function Start-AutoRemediationForDinePolicies {
    <#
    .SYNOPSIS
		This script will be used to start the auto-remediation for DINE policies in CNTY, TOOL and LNDZ workflows.

    .DESCRIPTION
        This script will trigger the below runbooks from Automation account that is located in MGMT subscription: 
        - MONITORING-Create-RemediationTaskSecurityCenterExport0
        - Create-RemediationTaskSecurityCenterTier
        - MONITORING-Create-RemediationTaskDiagnosticSettings-Core
        - MONITORING-Create-RemediationTaskDiagnosticSettings-Network
        - MONITORING-Create-RemediationTaskDiagnosticSettings-OsMgmt
        - MONITORING-Create-RemediationTaskDiagnosticSettings-PaaS

    .PARAMETER $targetSubscriptionId
	    Specifies the environment subscription id of the workflow that you use to run this script. 

    .PARAMETER $mgmtSubscriptionId
        Specifies the environment target subscription id where you want to trigger the auto-remediation runbooks. 
        Note: It needs to be filled with the mgmt subscription because the runbooks are located on the automation account that has been deployed in MGMT subscription. 

    .PARAMETER $tagPrefix
        Specifies the prefix for the company name that will be used in the tag name part

    .PARAMETER $tagValuePrefix
        Specifies the prefix for the company name that will be used in the tag value part

    .INPUTS
        Parameters value coming from the pipeline.

    .OUTPUTS
        None.

    .NOTES
        Version:        0.2
        Author:         frederic.trapet@eviden.com
        Creation Date:  20220916
        Purpose/Change: Modified to avoid using the get-azresource cmdlet that is not always reliable and can have delay

    .EXAMPLE
        $parameters = @{
            "targetSubscriptionId" = "xxxxa3c-xx7a-4cxe-80f4-1xcb2xxx7exbx"
            "mgmtSubscriptionId" = "2914575d-bxxc-488b-bx20-f1xxxxxx"
            "tagPrefix"          = "myCompany"
            "tagValuePrefix"     = "myCompany"
        }

        Start-AutoRemediationForDinePolicies @parameters
	#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]$targetSubscriptionId,
        [Parameter(Mandatory = $True)]
        [string]$mgmtSubscriptionId,
        [Parameter(Mandatory = $True)]
        [string]$tagPrefix,
        [Parameter(Mandatory = $True)]
        [string]$tagValuePrefix
    )

    #Tags used in this script:
    $tagName = $tagPrefix + 'Purpose'
    $tagValue = $tagValuePrefix + 'Automation'

    if (-not ([string]::IsNullOrEmpty($mgmtSubscriptionId))) {
        if (($mgmtSubscriptionId -ne $targetSubscriptionId)) { 
            Set-AzContext -SubscriptionId $mgmtSubscriptionId
        }
        Write-Host "Checking for the existence of the runbooks in MGMT subscription."
        $automationAccount = Get-AzAutomationAccount | Where-Object { $_.Tags[$tagName] -eq $tagValue }
        $existingRunbooks = Get-AzAutomationRunbook -AutomationAccountName $automationAccount.AutomationAccountName -ResourceGroupName $automationAccount.ResourceGroupName

        #Checking for the presence of runbooks in the automation account and triggering automatic remediation for DINE policies.
        if (-not ([string]::IsNullOrEmpty($existingRunbooks))) {
            Write-Host "Auto-Remediation has started, runbooks will be triggered."
            $runbookNames = @(
                "MONITORING-Create-RemediationTaskSecurityCenterExport"
                "Create-RemediationTaskSecurityCenterTier"
                "MONITORING-Create-RemediationTaskDiagnosticSettings"
            )
            $remediatedRunbooks = foreach ($runbook in $runbookNames) {
                $params = @{
                    Name                  = $runbook
                    AutomationAccountName = $automationAccount.AutomationAccountName
                    ResourceGroupName     = $automationAccount.ResourceGroupName
                }
                $startedRunbook = Start-AzAutomationRunbook @params

                [pscustomobject]@{
                    RunbookName           = $startedRunbook.RunbookName
                    AutomationAccountName = $startedRunbook.AutomationAccountName
                }
            }
            Write-Output $remediatedRunbooks
        }
        else {
            Write-Host "The MGMT subscription has no runbooks on the automation account and automated remediation is not possible!"
        }
        # Switching back to the target subscription. 
        if ($mgmtSubscriptionId -ne $targetSubscriptionId) {
            Set-AzContext -SubscriptionId $targetSubscriptionId
        }
    }
    else {
        Write-Host "No MGMT subscriptions have been established as existing to apply automatic remediation for DINE policies."
    }
}

