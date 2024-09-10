##
## Eviden Landing Zones for Azure - Feature test Managed Identity
##
 
Describe 'Core -  Check Managed Identity Usage' {

    BeforeAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
    }

    Context 'Check if Automation Accounts have the Identity Type set to SystemAssigned' {
                                 
        It 'Check Automation Accounts' {

            $listAutomationAccounts = Get-AzAutomationAccount
            $automationAccounts = $listAutomationAccounts.AutomationAccountName
            $automationAccountsCount = $automationAccounts.Count
            
            Foreach ($automationAccount in $automationAccounts) {
                $identityType = (Get-AzAutomationAccount | Where-Object { ($_.AutomationAccountName-eq $automationAccount)}).Identity.Type
                If ($identityType -eq 'SystemAssigned') {
                    $correctTypeCount = $correctTypeCount + 1
                }                
            }

            #Checks if all runbooks have the the Identity Type set to SystemAssigned
            $becauseText = 'All runbooks should have Identity Type set to "SystemAssigned"' + 'Checked at:' + $($dateTime)
            $correctTypeCount | Should -BeExactly $automationAccountsCount -Because $becauseText
        }
    }
}
