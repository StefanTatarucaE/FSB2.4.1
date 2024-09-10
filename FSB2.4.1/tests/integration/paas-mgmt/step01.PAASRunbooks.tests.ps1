##
## Eviden Landing Zones for Azure - Feature test runbook status for PAAS MGMT
##
 
Describe 'PAAS-MGMT - Check PAAS-MGMT runbooks' {

    BeforeAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        $runbookAutomationAccount = get-runbookAutomationAccount -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        $automationAccount = $runbookAutomationAccount.Name
        $resourceGroup = $runbookAutomationAccount.ResourceGroupName

        # Detect runbooks for PAAS 
        $runbooks = get-AzAutomationRunbook -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccount | Where-Object { $_.Name -like 'PAAS*' }
        # Number of runbooks for  PAAS MGMT that should be available and should be completed
        $runbookCount = "6"
        $runbooksCompletedCount = "5"
    }

    Context ' Check last job status' {
            
        It ' Check if all runbooks installed' {
            $becauseText = 'There should be at least ' + $($runbookCount) + ' runbooks created' + ' Checked at: ' + $($dateTime)
            $runbooks.Count | Should -BeGreaterOrEqual $runbookCount -Because $becauseText
        }   
                
        It ' Check last job for status completed' {
            foreach ($Runbook in $runbooks.Name) {
                $completed = (Get-AzAutomationJob -AutomationAccountName $automationAccount -RunbookName $Runbook -ResourceGroupName $resourceGroup -erroraction 'silentlycontinue').Status -contains "completed" 
                if ($completed -eq $True) {
                    $completedCount = $completedCount + 1
                }
            }
            $becauseText = 'There should be at least ' + $($runbooksCompletedCount) + ' runbooks with status completed' + ' Checked at: ' + $($dateTime)
            $completedCount | Should -BeGreaterOrEqual $runbooksCompletedCount -Because $becauseText
        }   
    }
}