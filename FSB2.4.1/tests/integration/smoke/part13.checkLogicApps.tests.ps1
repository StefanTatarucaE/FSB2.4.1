##
## Eviden Landing Zones for Azure - Check Tags for Automation Accounts in Azure MGMT Subscription
##
 
Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
        $tagName1 = $tagPrefix + "Managed"
        $tagName2 = $tagPrefix + "Purpose"

        $tagValue1 = $tagValuePrefix + "Billing"
        $tagValue2 = $tagValuePrefix + "ITSM"
        $tagValue3 = "True"
        $tagValue4 = $tagValuePrefix+ "DiskEncryption"
        $tagValue5 = $tagValuePrefix + "ItsmAlerts"
        $tagValue6 = $tagValuePrefix + "ItsmCmdb"
        $dateTime = (Get-Date).ToString()
    }

    Context 'Azure LogicApps Tag Check' {

        It 'Step18-01. Check if the correct Tags/Values have been assigned to the ITSM_Alerts LogicApp' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The ITSM_Alerts LogicApp should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The ITSM_Alerts LogicApp should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'ItsmAlerts TAG assigned' + ' Checked at: ' + $($dateTime)

            $keyVaultTags = (Get-AzResource -ResourceType Microsoft.Logic/workflows -Name *itsm-alerts).Tags

            $resourcetags = convert-hashToString($keyVaultTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue3`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue5`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step18-02. Check if the correct Tags/Values have been assigned to the ITSM_CMDB LogicApp' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The ITSM_CMDB LogicApp should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The ITSM_CMDB LogicApp should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'ItsmAlerts TAG assigned' + ' Checked at: ' + $($dateTime)

            $keyVaultTags = (Get-AzResource -ResourceType Microsoft.Logic/workflows -Name *itsm-cmdb).Tags

            $resourcetags = convert-hashToString($keyVaultTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue3`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue6`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }
    }
}