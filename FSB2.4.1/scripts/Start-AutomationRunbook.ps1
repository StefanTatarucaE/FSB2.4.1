function Start-AutomationRunbook {
    <#
    .SYNOPSIS
        This script starts an automation account runbook job

    .DESCRIPTION
        This script will trigger a runbook job from automation account that is located in MGMT subscription: 

    .PARAMETER $runbookName
        Specifies the runbook name to be executed. 

    .PARAMETER $runbookParameters
        Specifies set of parameters for the runbook job

    .INPUTS
        None.

    .OUTPUTS
        None. 

    .NOTES
        Version:        0.1
        Author:         gert.zanting@eviden.com
        Creation Date:  20230109

    .EXAMPLE
        $parameters = @{
            "runbookName" = "Update-EventGridAutomationWebhook"
            "runbookParameters" = @{}
        }

        Start-AzAutomationRunbook @parameters
	#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]$runbookName,
        [Parameter(Mandatory = $False)]
        [System.Collections.IDictionary]$runbookParameters = @{}
    )

    Write-Verbose "Checking deployed runbooks."
    $runbooks = Search-AzGraph -Query "resources| where (type =~ 'microsoft.automation/automationaccounts/runbooks' and name contains ""$runbookName"")"

    if ($runbooks) {
        foreach ($runbook in $runbooks) {
            try {
                $automationAccountName = ($runbook.id -Split '/')[8]
                $subscriptionContext = Get-AzContext -ListAvailable | Where-Object { $_.Subscription.Id -eq $runbook.subscriptionId }
    
                $params = @{
                    Name                  = $runbook.name
                    Parameters            = $runbookParameters
                    ResourceGroupName     = $runbook.resourceGroup
                    AutomationAccountName = $automationAccountName
                    DefaultProfile        = $subscriptionContext
                }
                Write-Verbose ("Starting runbook '" + $params.Name + "', AutomationAccount '" + $params.AutomationAccountName + "'")

                $startedRunbook = Start-AzAutomationRunbook @params
                Write-Verbose ("Job started for Runbook '" + $startedRunbook.RunbookName + "' - AutomationAccount '" + $startedRunbook.AutomationAccountName +"'")
            }
            catch {
                Write-Error ("ERROR: Starting runbook " + $runbook.name + " . $($_.Exception.Message)") -ErrorAction Stop
            }
        }
    } else {
        Write-Verbose "No deployed runbooks found that match name $runbookName ."
    }
}
