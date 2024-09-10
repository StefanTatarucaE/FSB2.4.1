##
## Eviden Landing Zones for Azure - Check Tags for Automation Accounts in Azure MGMT Subscription
##
 
Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
        $tagName1 = $tagPrefix + "Managed"
        $tagName2 = $tagPrefix + "Purpose"

        $tagValue1 = $tagValuePrefix + "SharedImageGallery"
        $tagValue2 = "True"

        $dateTime = (Get-Date).ToString()
    }

    Context 'Azure Compute Gallery Tag Check' {

        It 'Step14-01. Check if the correct Tags/Values have been assigned to the Azure Compute Gallery' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Azure Compute Gallery should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Azure Compute Gallery should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'SharedImageGallery TAG assigned' + ' Checked at: ' + $($dateTime)

            $gallery = Get-AzGallery

            $tags = Get-AzTag -ResourceId $gallery.Id -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Properties

            $resourcetags = convert-hashToString($tags.TagsProperty)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue2`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }
    }
}