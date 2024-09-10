##
## Eviden Landing Zones for Azure - Feature test
##
 
Describe 'Core -  Check Number of exemptions' {

    BeforeAll {

        $dateTime = (Get-Date).ToString()

        # Set the expected values for number of exemptions in the subscriptions
        $global:mgmtExemptions = "86"
        $global:cntyExemptions = "22"
        $global:lndzExemptions = "0"

    }
    Context 'Check number of exemptions in the MGMT Subscription' {

        It 'MGMT Subscription exemptions' {

            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            #Retrieve the number of exemptions
            $becauseText = 'For the MGMT Subscription there should be ' + $($mgmtExemptions) + ' exemptions created' + ' Checked at: ' + $($dateTime)
            $exemptions_mgmt = get-numberOfExemptions
            $exemptions_mgmt | Should -Be $mgmtExemptions -Because $becauseText
        }
    }

    Context 'Check number of exemptions in the CNTY Subscription' {

        It 'CNTY Subscription exemptions' {

            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null         
            #Retrieve the number of exemptions
            $becauseText = 'For the CNTY Subscription there should be ' + $($cntyExemptions) + ' exemptions created' + ' Checked at: ' + $($dateTime)
            $exemptions_cnty = get-numberOfExemptions
            $exemptions_cnty | Should -Be $cntyExemptions -Because $becauseText
        }
    }

    Context 'Check number of exemptions in the LNDZ Subscription' {

        It 'LNDZ Subscription exemptions' {

            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            #Retrieve the number of exemptions
            $becauseText = 'For the LNDZ Subscription there should be ' + $($lndzExemptions) + ' exemptions created' + ' Checked at: ' + $($dateTime)
            $exemptions_lndz = get-numberOfExemptions
            $exemptions_lndz | Should -Be $lndzExemptions -Because $becauseText
        }
    }
    
    
}