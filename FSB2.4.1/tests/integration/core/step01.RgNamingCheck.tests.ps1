##
## Eviden Landing Zones for Azure - Feature test
##
 
Describe 'Core -  Check ResourceGroup Naming Policy' {

    BeforeAll {
        $rgNamingPolicy = "atos.azurepolicy.name.convention.policy.assignment"
        $dateTime = (Get-Date).ToString()
    }

    Context 'Check number of Incompliant ResourceGroups in MGT' {

        It 'MGMT' {

            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            #Retrieve the number of Incompliancies
            $incompliantResources = get-incompliantDcsResources -policyAssignmentName $rgNamingPolicy -tagPrefix $tagPrefix
            $becauseText = 'For the MGMT Subscription there should be zero incompliant ResourceGroups' + 'Checked at:' + $($dateTime)
            $incompliantResources | Should -Be "0" -Because $becauseText
        }
    }
    Context 'Check number of Incompliant ResourceGroups in CNTY' {

        It 'CNTY' {

            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            #Retrieve the number of Incompliancies
            $becauseText = 'For the CNTY Subscription there should be zero incompliant ResourceGroups' + 'Checked at:' + $($dateTime)
            $incompliantResources = get-incompliantDcsResources -policyAssignmentName $rgNamingPolicy -tagPrefix $tagPrefix
            $incompliantResources | Should -Be "0" -Because $becauseText
            #$incompliantResources | Should -Be "1" -Because $becauseText #make the test fail to check outputs
        }
    }
}
