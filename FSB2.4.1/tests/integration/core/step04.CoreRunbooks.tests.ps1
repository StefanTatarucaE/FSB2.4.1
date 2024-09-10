##
## Eviden Landing Zones for Azure - Feature test runbook status for Core
##
 
Describe 'Core - Check Core Runbooks' {

    BeforeAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        $runbookAutomationAccount = get-runbookAutomationAccount -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        $automationAccount = $runbookAutomationAccount.Name
        $resourceGroup = $runbookAutomationAccount.ResourceGroupName

        # Detect runbooks for Core (=not starting with PAAS or OSMGMT in the name)
        $runbooks = Get-AzAutomationRunbook -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccount | Where-Object { $_.Name -Notlike 'PAAS*' } | Where-Object { $_.Name -Notlike 'OSMGMT*' }
        # Number of runbooks for Core that should be available and should be completed
        $runbookCount = "9"
        $runbooksCompletedCount = "5"
    }

    Context ' Check last job status' {
            
        It ' Check if all runbooks installed' {
            $becauseText = 'There should be at least ' + $($runbookCount) + ' runbooks created.' + 'Checked at:' + $($dateTime)
            $runbooks.Count | Should -BeGreaterOrEqual $runbookCount -Because $becauseText
        }   
                
        It ' Check jobs for status completed' {
            Foreach ($runbook in $runbooks.Name) {
                $completed = (Get-AzAutomationJob -AutomationAccountName $automationAccount -RunbookName $runbook -ResourceGroupName $resourceGroup -erroraction 'silentlycontinue').Status -contains "Completed" 
                If ($completed -eq $True) {
                    $completedCount = $completedCount + 1
                }
            }
            $becauseText = 'There should be at least ' + $($runbooksCompletedCount) + ' runbooks with status Completed.' + 'Checked at:' + $($dateTime)
            $completedCount | Should -BeGreaterOrEqual $runbooksCompletedCount -Because $becauseText
        }   
    }
}