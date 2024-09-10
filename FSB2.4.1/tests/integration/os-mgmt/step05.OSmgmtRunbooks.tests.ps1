##
## Eviden Landing Zones for Azure - Feature test runbook status for OSMGMT
##
 
Describe 'OS-MGMT - Check OS-MGMT runbooks' {

    BeforeAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        $runbookAutomationAccount = get-runbookAutomationAccount -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        $automationAccount = $runbookAutomationAccount.Name
        $resourceGroup = $runbookAutomationAccount.ResourceGroupName

        # Detect runbooks for OSMGMT 
        $runbooks = get-AzAutomationRunbook -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccount | Where-Object { $_.Name -like 'OSMGMT*' }
        # Number of runbooks for OSMGMT that should be available and should be completed
        $runbookCount = "11"
        $runbooksCompletedCount = "9"
    }

    Context ' Check last job status' {
            
        It ' Check if all runbooks installed' {
            $becauseText = 'There should be at least ' + $($runbookCount) + ' runbooks created' + ' Checked at: ' + $($DateTime)
            $runbooks.Count | Should -BeGreaterOrEqual $runbookCount -Because $becauseText
        }   
                
        It ' Check last job for status completed' {
            Foreach ($runbook in $runbooks.Name) {
                $completed = (Get-AzAutomationJob -AutomationAccountName $automationAccount -RunbookName $runbook -ResourceGroupName $resourceGroup -erroraction 'silentlycontinue').Status -contains "completed" 
                If ($completed -eq $True) {
                    $completedCount = $completedCount + 1
                }
            }
            $becauseText = 'There should be at least ' + $($runbooksCompletedCount) + ' runbooks with status completed' + ' Checked at: ' + $($DateTime)
            $completedCount | Should -BeGreaterOrEqual $runbooksCompletedCount -Because $becauseText
        }   
    }
}