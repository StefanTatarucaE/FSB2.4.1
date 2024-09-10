##
## Eviden Landing Zones for Azure - Check Tags for Automation Accounts in Azure MGMT Subscription
##
 
Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {

        $tagName1 = $tagPrefix + "Managed"
        $tagName2 = $tagPrefix + "Purpose"

        $tagValue1 = $tagValuePrefix + "DiskEncryption"
        $tagValue2 = "True"

        $dateTime = (Get-Date).ToString()
    }

    Context 'Azure Disk Encryption Sets' {

        It 'Step34-01. Check if the correct Tags/Values have been assigned to the Disk Encryption Sets in LNDZ1' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Disk Encryption Sets should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Disk Encryption Sets should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'DiskEncryption TAG assigned' + ' Checked at: ' + $($dateTime)

            $diskEncryptionSetTags1 = (Get-AzResource -ResourceType Microsoft.Compute/diskEncryptionSets -Name *des*)[0].Tags
            $diskEncryptionSetTags2 = (Get-AzResource -ResourceType Microsoft.Compute/diskEncryptionSets -Name *des*)[1].Tags

            $resourcetags1 = convert-hashToString($diskEncryptionSetTags1)
            $resourcetags2 = convert-hashToString($diskEncryptionSetTags2)

            $resourceMatchesTag1 = ($resourcetags1 -match "$tagName1=`"$tagValue2`"")
            $resourceMatchesTag2 = ($resourcetags1 -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag3 = ($resourcetags2 -match "$tagName1=`"$tagValue2`"")
            $resourceMatchesTag4 = ($resourcetags2 -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

            $resourceMatchesTag3 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag4 | Should -BeTrue -Because $becauseText2

        }

        It 'Step34-02. Check if the correct Tags/Values have been assigned to the Disk Encryption Sets in LNDZ2' {
            Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Disk Encryption Sets should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Runbooks Automation Account should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'DiskEncryption TAG assigned' + ' Checked at: ' + $($dateTime)

            $diskEncryptionSetTags1 = (Get-AzResource -ResourceType Microsoft.Compute/diskEncryptionSets -Name *des*)[0].Tags
            $diskEncryptionSetTags2 = (Get-AzResource -ResourceType Microsoft.Compute/diskEncryptionSets -Name *des*)[1].Tags

            $resourcetags1 = convert-hashToString($diskEncryptionSetTags1)
            $resourcetags2 = convert-hashToString($diskEncryptionSetTags2)

            $resourceMatchesTag1 = ($resourcetags1 -match "$tagName1=`"$tagValue2`"")
            $resourceMatchesTag2 = ($resourcetags1 -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag3 = ($resourcetags2 -match "$tagName1=`"$tagValue2`"")
            $resourceMatchesTag4 = ($resourcetags2 -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

            $resourceMatchesTag3 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag4 | Should -BeTrue -Because $becauseText2

        }
    }
}