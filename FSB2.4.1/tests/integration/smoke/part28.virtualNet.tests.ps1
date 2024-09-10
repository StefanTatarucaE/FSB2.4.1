##
## Eviden Landing Zones for Azure - Feature test
##

Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {
    BeforeAll {
      $tagName1 = $tagPrefix + "Managed"
      $tagName2 = $tagPrefix + "Purpose"

      $tagValue1 = $tagValuePrefix + "NetworkingHub"
      $tagValue2 = $tagValuePrefix + "NetworkingSpoke"
      $tagValue3 = "True"
  
      $dateTime = (Get-Date).ToString()
  
    }
  
    Context 'Verify Virtual Network' {
      It 'Step30-01. Check if the correct Tags/Values have been assigned to the Virtual Network "vnet-hub" in CNTY' {
        Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'The Virtual Network "vnet-hub" should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
        $becauseText2 = 'The Virtual Network "vnet-hub" should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingHub TAG assigned' + ' Checked at: ' + $($dateTime)
  
        $vNetTags = (Get-AzResource -ResourceType Microsoft.Network/virtualNetworks -Name *vnet-hub).Tags
    
        $resourcetags = convert-hashToString($vNetTags)
    
        $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue3`"")
        $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")
  
        $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
        $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2
        
      }

      It 'Step30-02. Check if the correct subnets are present in Virtual Network "vnet-hub" in CNTY' {
        Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'The Virtual Network "vnet-hub" should have the "snet-hub-network" subnet assigned' + ' Checked at: ' + $($dateTime)
        $becauseText2 = 'The Virtual Network "vnet-hub" should have the "AzureFirewallSubnet" subnet assigned' + ' Checked at: ' + $($dateTime)
        $becauseText3 = 'The Virtual Network "vnet-hub" should have the "GatewaySubnet" subnet assigned' + ' Checked at: ' + $($dateTime)
  
        $vNet = Get-AzVirtualNetwork -Name *vnet-hub*

        $vnet.Subnets.Name -match "snet-hub-network" | Should -Not -BeNullOrEmpty -Because $becauseText1
        $vnet.Subnets.Name -match "AzureFirewallSubnet" | Should -Not -BeNullOrEmpty -Because $becauseText2
        $vnet.Subnets.Name -match "GatewaySubnet" | Should -Not -BeNullOrEmpty -Because $becauseText3
        
      }

      It 'Step30-03. Check whether the Peering to Spoke network from Hub Virtual Network is configured' {
        Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'The Virtual Network "vnet-hub" should be peered with the spoke Virtual Network(s)' + ' Checked at: ' + $($dateTime)
       
        $vNet = Get-AzVirtualNetwork -Name *vnet-hub*

        $vNet.VirtualNetworkPeerings.Name -match "spoke" | Should -Not -BeNullOrEmpty -Because $becauseText1
        
      }

      It 'Step31-01. Check if the correct Tags/Values have been assigned to the Virtual Network "spoke" in LNDZ' {
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'The Virtual Network "vnet-spoke" should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
        $becauseText2 = 'The Virtual Network "vnet-spoke" should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingSpoke TAG assigned' + ' Checked at: ' + $($dateTime)
  
        $vNetTags = (Get-AzResource -ResourceType Microsoft.Network/virtualNetworks -Name *vnet-spoke).Tags
    
        $resourcetags = convert-hashToString($vNetTags)
    
        $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue3`"")
        $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue2`"")
  
        $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
        $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2
        
      }

      It 'Step31-02. Check if the correct subnets are present in Virtual Network "spoke" in LNDZ' {
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'The Virtual Network "spoke" should have the "front" subnet assigned' + ' Checked at: ' + $($dateTime)
        $becauseText2 = 'The Virtual Network "spoke" should have the "back" subnet assigned' + ' Checked at: ' + $($dateTime)
        $becauseText3 = 'The Virtual Network "spoke" should have the "middle" subnet assigned' + ' Checked at: ' + $($dateTime)
  
        $vNet = Get-AzVirtualNetwork -Name *-spoke*

        $vnet.Subnets.Name -match "front" | Should -Not -BeNullOrEmpty -Because $becauseText1
        $vnet.Subnets.Name -match "back" | Should -Not -BeNullOrEmpty -Because $becauseText2
        $vnet.Subnets.Name -match "middle" | Should -Not -BeNullOrEmpty -Because $becauseText3
        
      }

      It 'Step31-03. Check whether the Peering to Hub network from Spoke Network is configured' {
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'The Virtual Network "spoke" should be peered with the Hub Virtual Network(s)' + ' Checked at: ' + $($dateTime)
       
        $vNet = Get-AzVirtualNetwork -Name *-spoke*

        $vNet.VirtualNetworkPeerings.Name -match "hub" | Should -BeTrue -Because $becauseText1
        
      }

      It 'Step33-01. Verify if the Network Watcher is enabled for the subscription for the specific location where the Virtual Network is available' {
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'Network Watcher should be enabled in the location where the spoke network is deployed' + ' Checked at: ' + $($dateTime)
       
        $vNet = Get-AzVirtualNetwork -Name *-spoke*
        $netWatcher = Get-AzNetworkWatcher

        $netWatcher.Location -match $vnet.Location | Should -Not -BeNullOrEmpty -Because $becauseText1
        
      }
     }
} 
  


