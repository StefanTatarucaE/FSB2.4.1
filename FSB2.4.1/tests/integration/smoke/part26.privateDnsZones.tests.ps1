##
## Eviden Landing Zones for Azure - Check Private DNS Zone
##

Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
      $tagName1 = $tagPrefix + "Managed"
      $tagName2 = $tagPrefix + "Purpose"
  
      $tagValue1 = $tagValuePrefix + "NetworkingHub"
      $tagValue2 = "True"
  
      $dateTime = (Get-Date).ToString()
  
    }
  
    Context 'Verify Private DNS Zone' {
      It 'Step28-01. Check if the correct Tags/Values have been assigned to the Private DNS Zone in CNTY' {
        Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'The Private DNS Zone should have the' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
        $becauseText2 = 'The Private DNS Zone should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingHub TAG assigned' + ' Checked at: ' + $($dateTime)
  
        $privateDnsTags = (Get-AzResource -ResourceType Microsoft.Network/privateDnsZones).Tags
    
        $resourcetags = convert-hashToString($privateDnsTags)

        $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue2`"")
        $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

        $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
        $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

    }

    It 'Step28-02. Check if the Virtual Network Links are present in the Private DNS Zone Configuration' {
        Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'The "-vnet-hub-vnetlink" should be configured for the Private DNS Zone' + ' Checked at: ' + $($dateTime)
        $becauseText2 = 'The "-vnet-spoke-vnetlink" should be configured for the Private DNS Zone' + ' Checked at: ' + $($dateTime)
  
        $privateDnsZone = Get-AzPrivateDnsZone

        $hubVnetLink = (Get-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $privateDnsZone.ResourceGroupName -ZoneName $privateDnsZone.Name).Name -like "*vnet-hub*"
        $spokeVnetLink = (Get-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $privateDnsZone.ResourceGroupName -ZoneName $privateDnsZone.Name).Name -like "*vnet-spoke*"

        $hubVnetLink | Should -Not -BeNullOrEmpty -Because $becauseText1
        $spokeVnetLink | Should -Not -BeNullOrEmpty -Because $becauseText2
        
    }
  }
}
  