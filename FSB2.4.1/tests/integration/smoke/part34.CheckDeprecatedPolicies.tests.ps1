##
## Eviden Landing Zones for Azure- Test if there are deprecated policies deployed as part of the product.
##

Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
    }

    Context 'Check for deprecated policies' {

        It 'Step 46-01. Check deprecated policies in MGMT Subscription' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $deprecatedPolicies = get-deprecatedPolicies

            $becauseText = 'There should be no deprecated policies deployed ' + $($deprecatedPolicies) + 'Checked at:' + $($dateTime)
            $deprecatedPolicies.count |  Should -Be 0 -Because $becauseText
        }
        It 'Step 46-02. Check deprecated policies in CNTY Subscription' {
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $deprecatedPolicies = get-deprecatedPolicies

            $becauseText = 'There should be no deprecated policies deployed ' + $($deprecatedPolicies) + 'Checked at:' + $($dateTime)
            $deprecatedPolicies.count |  Should -Be 0 -Because $becauseText
        }
        It 'Step 46-03. Check deprecated policies in LNDZ Subscription' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $deprecatedPolicies = get-deprecatedPolicies

            $becauseText = 'There should be no deprecated policies deployed ' + $($deprecatedPolicies) + 'Checked at:' + $($dateTime)
            $deprecatedPolicies.count |  Should -Be 0 -Because $becauseText
        }
    }
}
