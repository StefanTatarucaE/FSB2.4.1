##
## Eviden Landing Zones for Azure - Check Tags for Automation Accounts in Azure MGMT Subscription
##
 
Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
        $totalPolicyAssignmentsCount = 178
        $dateTime = (Get-Date).ToString()
    }

    Context 'Azure Policy Assignments Check' {

        It 'Step38-01. Verify if the Policy assignments are present' {

            $becauseText1 = 'The total number of Policy Assignments should be '+ $totalPolicyAssignmentsCount + ' Checked at: ' + $($dateTime)

            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $policyAssignmentsCountMgmt = (Get-AzPolicyAssignment).Count

            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $policyAssignmentsCountCnty = (Get-AzPolicyAssignment).Count
            
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $policyAssignmentsCountLndz = (Get-AzPolicyAssignment).Count

            Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            
            $policyAssignmentsCountLndz2 = (Get-AzPolicyAssignment).Count

            $totalPolicyAssignments = $policyAssignmentsCountMgmt + $policyAssignmentsCountCnty + $policyAssignmentsCountLndz + $policyAssignmentsCountLndz2

            $totalPolicyAssignments | Should -BeExactly $totalPolicyAssignmentsCount -Because $becauseText1
        }
    }
}
