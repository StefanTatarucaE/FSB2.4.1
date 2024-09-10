##
## Eviden Landing Zones for Azure - Check Tags for Automation Accounts in Azure MGMT Subscription
##
 
Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
        $totalRules = 265
        $dateTime = (Get-Date).ToString()
    }

    Context 'Azure Monitor Alert Rules Check' {

        It 'Step39-01. Verify if the Alert rules are present under Monitor ' {

            $becauseText1 = 'The total number of Alert Rules should be '+ $totalRules + ' Checked at: ' + $($dateTime)

            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $alertRulesMgmt = Get-AzScheduledQueryRule
            $alertRulesMgmtCount = ($alertRulesMgmt | Where-Object { $_.Enabled }).Count

            $alertRulesMgmtCount | Should -BeExactly $totalRules -Because $becauseText1

        }
    }
}