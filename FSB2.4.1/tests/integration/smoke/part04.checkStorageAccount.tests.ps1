##
## Eviden Landingzones for Azure - Check Tags for Automation Accounts in Azure MGMT Subscription
##
 
Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
        $tagName1 = $tagPrefix + "Managed"
        $tagName2 = $tagPrefix + "Purpose"

        $tagValue1 = $tagValuePrefix + "Billing"
        $tagValue2 = $tagValuePrefix + "ITSM"
        $tagValue3 = $tagValuePrefix + "OSTagging"
        $tagValue4 = $tagValuePrefix + "Reporting"
        $tagValue5 = $tagValuePrefix +  "Bootstrap"
        $tagValue6 = $tagValuePrefix + "SharedImageGallery"
        $tagValue7 = "True"

        $dateTime = (Get-Date).ToString()
    }

    Context 'Storage Account Tag Check' {

        It 'Step09-01. Check if the correct Tags/Values have been assigned to the Billing Storage Account' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Billing Storage Account should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Billing Storage Account should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Billing TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-metering
            $storageAccount = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -ResourceGroupName $resourceGroup[0].ResourceGroupName

            $tags = Get-AzTag -ResourceId $storageaccount[0].ResourceId -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Properties

            $resourcetags = convert-hashToString($tags.TagsProperty)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue7`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step09-02. Check if the correct Tags/Values have been assigned to the ITSM Storage Account' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The ITSM Storage Account should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The ITSM Storage Account should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'ITSM TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-itsm
            $storageAccount = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -ResourceGroupName $resourceGroup.ResourceGroupName -Name *itsmpwsh*

            $tags = Get-AzTag -ResourceId $storageaccount.ResourceId -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Properties

            $resourcetags = convert-hashToString($tags.TagsProperty)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue7`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue2`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step09-03. Check if the correct Tags/Values have been assigned to the OsTagging Storage Account' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The OsTagging Storage Account should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The OsTagging Storage Account should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'OSTagging TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-ostagging
            $storageAccount = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -ResourceGroupName $resourceGroup.ResourceGroupName -Name *ostag*

            $tags = Get-AzTag -ResourceId $storageaccount.ResourceId -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Properties

            $resourcetags = convert-hashToString($tags.TagsProperty)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue7`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue3`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step09-04. Check if the correct Tags/Values have been assigned to the Reporting Storage Account' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Reporting Storage Account should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Reporting Storage Account should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Reporting TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-reporting
            $storageAccount = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -ResourceGroupName $resourceGroup.ResourceGroupName -Name *reporting*

            $tags = Get-AzTag -ResourceId $storageaccount.ResourceId -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Properties

            $resourcetags = convert-hashToString($tags.TagsProperty)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue7`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue4`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step09-05. Check if the correct Tags/Values have been assigned to the Bootstrap Storage Account' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Bootstrap Storage Account should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Bootstrap Storage Account should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Bootstrap TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-bootstrap
            $storageAccount = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -ResourceGroupName $resourceGroup.ResourceGroupName -Name *aart*

            $tags = Get-AzTag -ResourceId $storageaccount.ResourceId -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Properties

            $resourcetags = convert-hashToString($tags.TagsProperty)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue7`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue5`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step09-06. Check if the correct Tags/Values have been assigned to the SharedImageGallery Storage Account' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The SharedImageGallery Storage Account should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The SharedImageGallery Storage Account should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'SharedImageGallery TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-computegallery
            $storageAccount = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -ResourceGroupName $resourceGroup.ResourceGroupName -Name *sacg*

            $tags = Get-AzTag -ResourceId $storageaccount[0].ResourceId -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Properties

            $resourcetags = convert-hashToString($tags.TagsProperty)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue7`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue6`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }
    }
}