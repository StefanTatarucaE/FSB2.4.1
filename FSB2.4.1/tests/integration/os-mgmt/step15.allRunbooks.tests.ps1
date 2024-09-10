##
## Eviden Landing Zones for Azure - Feature test runbook status 
##
 
Describe 'Check All runbooks' {

    BeforeAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $runbookAutomationAccount = get-runbookAutomationAccount -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        $automationAccount = $runbookAutomationAccount.Name
        $resourceGroup = $runbookAutomationAccount.ResourceGroupName
        $dateTime = (Get-Date).ToString()

        # Detect all runbooks from the selected subscription 
        $runbooks = get-AzAutomationRunbook -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccount 
        # Number of runbooks that should be available and should be completed
        $runbookCount = "26"
        $runbooksCompletedCount = "22"
    }

    Context ' Check last job status' {
            
        It ' Check if all runbooks installed' {
            $becauseText = 'There should be at least ' + $($runbookCount) + ' runbooks created at: ' + $($dateTime) #message appears if the test is failing
            $runbooks.Count | Should -BeGreaterOrEqual $runbookCount -Because $becauseText
            Write-Host ("Check if all runbooks are installed test completed successfullly at: " + $dateTime) # message appears when the test is successfull
        }   
                
        It ' Check last job for status completed' {
            Foreach ($runbook in $runbooks.Name) {
                $completed = (Get-AzAutomationJob -AutomationAccountName $automationAccount -RunbookName $runbook -ResourceGroupName $resourceGroup -erroraction 'silentlycontinue').Status -contains "completed" 
                If ($completed -eq $True) {
                    $completedCount = $completedCount + 1
                }
            }
            $becauseText = 'There should be at least ' + $($runbooksCompletedCount) + ' runbooks with status completed at: ' + $($dateTime) #message appears if the test is failing
            $completedCount | Should -BeGreaterOrEqual $runbooksCompletedCount -Because $becauseText
            Write-Host ("Check last job for status completed test completed successfullly at: " + $dateTime) # message appears when the test is successfull
        }   
    }
}