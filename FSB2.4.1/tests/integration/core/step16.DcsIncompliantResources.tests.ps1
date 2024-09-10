##
## Eviden Landing Zones for Azure - Feature test
##
 
Describe 'Core -  Check Incompliant DCS Resources for MCSB/CIS/ISO (Excluding Subscription Incompliancies' {

    BeforeAll {
        $dateTime = (Get-Date).ToString()
        $cisPolicyAssignmentName = "cis140.auditdeny.policy.set.assignment"
        $mcsbPolicyAssignmentName = "securitybenchmark.auditdeny.policy.def.assignment"
        $isoPolicyAssignmentName = "iso27001.auditdeny.policy.set"
    }

    Context 'Check number of Incompliant resources in the MGMT Subscription' {

        It 'MCSB Initiative' {

            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            #Retrieve the number of Incompliancies
            $becauseText = 'For the MGMT Subscription there should be zero incompliant resources' + ' Checked at: ' + $($dateTime)
            $incompliantResources = get-incompliantDcsResources -policyAssignmentName $mcsbPolicyAssignmentName -tagPrefix $tagPrefix
            $incompliantResources | Should -Be "0" -Because $becauseText
        }

        It 'CIS Initiative' {

            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            #Retrieve the number of Incompliancies
            $becauseText = 'For the MGMT Subscription there should be zero incompliant resources' + ' Checked at: ' + $($dateTime)
            $incompliantResources = get-incompliantDcsResources -policyAssignmentName $cisPolicyAssignmentName -tagPrefix $tagPrefix
            $incompliantResources | Should -Be "0" -Because $becauseText
        }

        It 'ISO Initiative' {

            #Retrieve the number of Incompliancies
            $becauseText = 'For the MGMT Subscription there should be zero incompliant resources' + ' Checked at: ' + $($dateTime)
            $incompliantResources = get-incompliantDcsResources -policyAssignmentName $isoPolicyAssignmentName -tagPrefix $tagPrefix
            $incompliantResources | Should -Be "0" -Because $becauseText
        }
    }
    Context 'Check number of Incompliant resources in the CNTY Subscription' {

        It 'CIS Initiative' {

            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            #Retrieve the number of Incompliancies
            $becauseText = 'For the CNTY Subscription there should be zero incompliant resources' + ' Checked at: ' + $($dateTime)
            $incompliantResources = get-incompliantDcsResources -policyAssignmentName $cisPolicyAssignmentName -tagPrefix $tagPrefix
            $incompliantResources | Should -Be "0" -Because $becauseText
        }

        It 'ISO Initiative' {

            #Retrieve the number of Incompliancies
            $becauseText = 'For the CNTY Subscription there should be zero incompliant resources' + ' Checked at: ' + $($dateTime)
            $incompliantResources = get-incompliantDcsResources -policyAssignmentName $isoPolicyAssignmentName -tagPrefix $tagPrefix
            #$incompliantResources | Should -Be "2" -Because $becauseText
            $incompliantResources | Should -Be "0" -Because $becauseText #modified 10042022
        }
    }

}