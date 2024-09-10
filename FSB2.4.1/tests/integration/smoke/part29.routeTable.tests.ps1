##
## Eviden Landing Zones for Azure - Feature test
##

Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {
    BeforeAll {
      $tagName1 = $tagPrefix + "Managed"
      $tagName2 = $tagPrefix + "Purpose"

      $tagValue1 = $tagValuePrefix + "NetworkingSpoke"
      $tagValue2 = "True"
  
      $dateTime = (Get-Date).ToString()
  
    }
  
    Context 'Verify Route Table' {
      It 'Step36-01. Check if the correct Tags/Values have been assigned to the Route Table in LNDZ' {
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'The Route Table should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
        $becauseText2 = 'The Eoute Table should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingSpoke TAG assigned' + ' Checked at: ' + $($dateTime)
  
        $routeTableTags = (Get-AzResource -ResourceType Microsoft.Network/routeTables).Tags
    
        $resourcetags = convert-hashToString($routeTableTags)
    
        $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue2`"")
        $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")
  
        $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
        $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2
        
      }

      It 'Step36-02. Check the route is present with Next hop type as Internet' {
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'The route should have the Next hop type as Internet' + ' Checked at: ' + $($dateTime)

        $routeTable = Get-AzRouteTable

        $routeTable.Routes.NextHopType -match "VirtualAppliance"| Should -BeTrue -Because $becauseText1
        
      }

      It 'Step36-03. Verify whether the subnets are associated with the Route Table' {
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'The Route Table should be associated with the "front" subnet' + ' Checked at: ' + $($dateTime)
        $becauseText2 = 'The Route Table should be associated with the "back" subnet' + ' Checked at: ' + $($dateTime)
        $becauseText3 = 'The Route Table should be associated with the "middle" subnet' + ' Checked at: ' + $($dateTime)
  
        $routeTable = Get-AzRouteTable

        $routeTable.Subnets.Id -match "-snet-spoke-front" | Should -Not -BeNullOrEmpty -Because $becauseText1
        $routeTable.Subnets.Id -match "-snet-spoke-back" | Should -Not -BeNullOrEmpty -Because $becauseText2
        $routeTable.Subnets.Id -match "-snet-spoke-middle" | Should -Not -BeNullOrEmpty -Because $becauseText3
        
      }
    }
} 
  


