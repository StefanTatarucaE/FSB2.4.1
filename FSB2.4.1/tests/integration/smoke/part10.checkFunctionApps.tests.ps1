##
## Eviden Landing Zones for Azure - Check Tags for Automation Accounts in Azure MGMT Subscription
##
 
Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
        $tagName1 = $tagPrefix + "Managed"
        $tagName2 = $tagPrefix + "Purpose"

        $tagValue1 = $tagValuePrefix + "Billing"
        $tagValue2 = $tagValuePrefix + "ItsmListener"
        $tagValue3 = $tagValuePrefix + "ITSM"
        $tagValue4 = "True"
        $tagValue5 = $tagValuePrefix + "OSTagging"
        $tagValue6 = "FuncOsTagging"

        $dateTime = (Get-Date).ToString()
    }

    Context 'Azure Function App Tag Check' {

        It 'Step15-01. Check if the correct Tags/Values have been assigned to the Billing Azure Function App' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Billing Azure FunctionApp should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Billing Azure FunctionApp should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Billing TAG assigned' + ' Checked at: ' + $($dateTime)

            $functionAppTags = (Get-AzResource -ResourceType 'Microsoft.Web/sites' -Name *billing*).Tags

            $resourcetags = convert-hashToString($functionAppTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue4`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step15-02. Check if the correct Tags/Values have been assigned to the ITSM Azure Function App' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The ITSM Azure FunctionApp should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The ITSM Azure FunctionApp should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'ItsmListener TAG assigned' + ' Checked at: ' + $($dateTime)

            $functionAppTags = (Get-AzResource -ResourceType 'Microsoft.Web/sites' -Name *itsm-pwsh).Tags 

            $resourcetags = convert-hashToString($functionAppTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue4`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue2`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step15-03. Check if the correct Tags/Values have been assigned to the OSTagging Azure Function App' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The OSTagging Azure FunctionApp should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The OSTagging Azure FunctionApp should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'FuncOsTagging TAG assigned' + ' Checked at: ' + $($dateTime)

            $functionAppTags = (Get-AzResource -ResourceType 'Microsoft.Web/sites' -Name *ostagging).Tags 

            $resourcetags = convert-hashToString($functionAppTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue4`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue6`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }
    }
}