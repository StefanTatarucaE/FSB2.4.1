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
        $tagValue4 = $tagValuePrefix + "DiskEncryption"


        $dateTime = (Get-Date).ToString()
    }

    Context 'Azure KeyVaults Tag Check' {

        It 'Step17-01. Check if the correct Tags/Values have been assigned to the Billing KeyVault' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Billing KeyVault should should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Billing Keyvault should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Billing TAG assigned' + ' Checked at: ' + $($dateTime)

            $keyVaultTags = (Get-AzResource -ResourceType Microsoft.KeyVault/vaults -Name *billing).Tags

            $resourcetags = convert-hashToString($keyVaultTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue3`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step17-02. Check if the correct Tags/Values have been assigned to the ITSM KeyVault' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The ITSM KeyVault should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The ITSM KeyVault should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'ITSM TAG assigned' + ' Checked at: ' + $($dateTime)

            $keyVaultTags = (Get-AzResource -ResourceType Microsoft.KeyVault/vaults -Name *itsm).Tags

            $resourcetags = convert-hashToString($keyVaultTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue3`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue2`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step17-03. Check if the correct Tags/Values have been assigned to the DiskEncryption KeyVault for LNDZ1' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Disk Encryption Keyvault should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Disk Encryption Keyvault should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'DiskEncryption TAG assigned' + ' Checked at: ' + $($dateTime)

            $keyVaultTags1 = (Get-AzResource -ResourceType Microsoft.KeyVault/vaults -Name *-des)[0].Tags
            $keyVaultTags2 = (Get-AzResource -ResourceType Microsoft.KeyVault/vaults -Name *-des)[1].Tags

            $resourcetags1 = convert-hashToString($keyVaultTags1)
            $resourcetags2 = convert-hashToString($keyVaultTags2)

            $resourceMatchesTag1 = ($resourcetags1 -match "$tagName1=`"$tagValue3`"")
            $resourceMatchesTag2 = ($resourcetags1 -match "$tagName2=`"$tagValue4`"")

            $resourceMatchesTag3 = ($resourcetags2 -match "$tagName1=`"$tagValue3`"")
            $resourceMatchesTag4 = ($resourcetags2 -match "$tagName2=`"$tagValue4`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

            $resourceMatchesTag3 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag4 | Should -BeTrue -Because $becauseText2

        }

        It 'Step17-04. Check if the correct Tags/Values have been assigned to the DiskEncryption KeyVault for LNDZ2' {
            Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Disk Encryption Keyvault should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Disk Encryption Keyvault should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'DiskEncryption TAG assigned' + ' Checked at: ' + $($dateTime)

            $keyVaultTags1 = (Get-AzResource -ResourceType Microsoft.KeyVault/vaults -Name *-des)[0].Tags
            $keyVaultTags2 = (Get-AzResource -ResourceType Microsoft.KeyVault/vaults -Name *-des)[1].Tags

            $resourcetags1 = convert-hashToString($keyVaultTags1)
            $resourcetags2 = convert-hashToString($keyVaultTags2)

            $resourceMatchesTag1 = ($resourcetags1 -match "$tagName1=`"$tagValue3`"")
            $resourceMatchesTag2 = ($resourcetags1 -match "$tagName2=`"$tagValue4`"")

            $resourceMatchesTag3 = ($resourcetags2 -match "$tagName1=`"$tagValue3`"")
            $resourceMatchesTag4 = ($resourcetags2 -match "$tagName2=`"$tagValue4`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

            $resourceMatchesTag3 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag4 | Should -BeTrue -Because $becauseText2

        }
    }
}