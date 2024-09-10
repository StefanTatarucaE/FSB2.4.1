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
        $tagValue5 = $tagValuePrefix + "OsTagging"
        $tagValue6 = "FuncOsTagging"

        $dateTime = (Get-Date).ToString()
    }

    Context 'Azure App Service Plans Tag Check' {

        It 'Step16-01. Check if the correct Tags/Values have been assigned to the Billing App Service Plan' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Billing App Service Plan should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Billing App Service Plan should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Billing TAG assigned' + ' Checked at: ' + $($dateTime)

            $appServicePlanTags = (Get-AzResource -ResourceType Microsoft.Web/serverfarms -Name *billing).Tags

            $resourcetags = convert-hashToString($appServicePlanTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue4`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step16-02. Check if the correct Tags/Values have been assigned to the ITSM App Service Plan' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The ITSM App Service Plan should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The ITSM App Service Plan should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'ItsmListener TAG assigned' + ' Checked at: ' + $($dateTime)

            $appServicePlanTags = (Get-AzResource -ResourceType Microsoft.Web/serverfarms -Name *itsm-pwsh).Tags 

            $resourcetags = convert-hashToString($appServicePlanTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue4`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue2`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step16-03. Check if the correct Tags/Values have been assigned to the OSTagging App Service Plan' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The OSTagging App Service Plan should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The OSTagging App Service Plan should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'OsTagging TAG assigned' + ' Checked at: ' + $($dateTime)

            $appServicePlanTags = (Get-AzResource -ResourceType Microsoft.Web/serverfarms -Name *ostagging).Tags

            $resourcetags = convert-hashToString($appServicePlanTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue4`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue5`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step16-04. Verify if the billing App Service Plan is connected with billing Function App' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Billing App Service Plan should be connected with the Billing Function App' + ' Checked at: ' + $($dateTime)

            $functionApp = (Get-AzResource -ResourceType 'Microsoft.Web/sites' -Name *billing*).Name

            $appServicePlanId = (Get-AzResource -ResourceType Microsoft.Web/serverfarms -Name *billing*).ResourceId

            $serverFarmId = (Get-AzWebApp -Name $functionApp).ServerFarmId
            
            $appServicePlanId | Should -BeLike $serverFarmId -Because $becauseText1

        }

        It 'Step16-05. Verify if the ITSM App Service Plan is connected with ITSM Function App' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The ITSM App Service Plan should be connected with the ITSM Function App' + ' Checked at: ' + $($dateTime)

            $functionApp = (Get-AzResource -ResourceType 'Microsoft.Web/sites' -Name *itsm-pwsh).Name

            $appServicePlanId = (Get-AzResource -ResourceType Microsoft.Web/serverfarms -Name *itsm-pwsh).ResourceId

            $serverFarmId = (Get-AzWebApp -Name $functionApp).ServerFarmId
            
            $appServicePlanId | Should -BeLike $serverFarmId -Because $becauseText1

        }

        It 'Step16-06. Verify if the OSTagging App Service Plan is connected with OSTagging Function App' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The OSTagging App Service Plan should be connected with the OSTagging Function App' + ' Checked at: ' + $($dateTime)

            $functionApp = (Get-AzResource -ResourceType 'Microsoft.Web/sites' -Name *ostagging).Name

            $appServicePlanId = (Get-AzResource -ResourceType Microsoft.Web/serverfarms -Name *ostagging).ResourceId

            $serverFarmId = (Get-AzWebApp -Name $functionApp).ServerFarmId
            
            $appServicePlanId | Should -BeLike $serverFarmId -Because $becauseText1

        }
    }
}