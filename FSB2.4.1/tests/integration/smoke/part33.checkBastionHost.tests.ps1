##
## Eviden Landing Zones for Azure - Check Bastion Host Properties
##
 
Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
        $tagName1 = $tagPrefix + "Managed"
        $tagName2 = $tagPrefix + "Purpose"

        $tagValue1 = $tagValuePrefix + "NetworkingHub"
        $tagValue2 = "True"

        $dateTime = (Get-Date).ToString()
    }

    Context 'Check Bastion Host Properties' {

        It 'Step41. Check if the correct Tags/Values have been assigned to the Bastion Host RSG' {
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingHub TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-hub-bastionhost
            $resourcetags = convert-hashToString($resourceGroup.tags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue2`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step42. Check if the correct Tags/Values have been assigned to the Bastion Host Resource' {
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Bastion Host Resource should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Bastion Host Resource should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingHub TAG assigned' + ' Checked at: ' + $($dateTime)

            $bastionHostTags = (Get-AzResource -ResourceType 'Microsoft.Network/bastionHosts' -Name *-bas-hub).Tags 
            $resourcetags = convert-hashToString($bastionHostTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue2`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step43-01. Check if the correct Tags/Values have been assigned to the Bastion Host Public IP' {
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Bastion Host Public IP should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Bastion Host Public IP should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingHub TAG assigned' + ' Checked at: ' + $($dateTime)

            $publicIpTags = (Get-AzResource -ResourceType Microsoft.Network/publicIPAddresses -Name *-bas-hub).Tags
            $resourcetags = convert-hashToString($publicIpTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue2`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step43-02. Check if the Public IP is associated to the Bastion Host' {
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The "*-bas-hub" Public IP should be associated to the Bastion Host' + ' Checked at: ' + $($dateTime)

            $publicIpId = (Get-AzResource -ResourceType Microsoft.Network/publicIPAddresses -Name *-bas-hub).ResourceId

            $bastionHost = Get-AzBastion
            $bastionHostPublicIpId = ($bastionHost.IpConfigurationsText | ConvertFrom-Json).PublicIpAddress.Id

            $publicIpId | Should -BeExactly $bastionHostPublicIpId -Because $becauseText1

        }

        It 'Step44. Verify if the Subnet for Bastion is present in the Hub Virtual Network' {
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
      
            $becauseText1 = 'The Virtual Network "vnet-hub" should have the "AzureBastionSubnet" subnet assigned' + ' Checked at: ' + $($dateTime)
            
            $vNetHub = Get-AzVirtualNetwork -Name *vnet-hub*
    
            $vNetHub.Subnets.Name -match "AzureBastionSubnet" | Should -Not -BeNullOrEmpty -Because $becauseText1
           
            
        }

        It 'Step45. Check if the Network Security Group is present for Azure Bastion with required tags in Connectivity subscription' {
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The NSG Group in CNTY for Bastion should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The NSG Group in CNTY for Bastion should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingHub TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-hub-bastionhost
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue2`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }


    }
}