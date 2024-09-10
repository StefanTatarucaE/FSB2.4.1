##
## Eviden Landing Zones for Azure - Feature test
##

Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {
    BeforeAll {
      $tagName1 = $tagPrefix + "Managed"
      $tagName2 = $tagPrefix + "Purpose"

      $tagValue1 = $tagValuePrefix + "NetworkingHub"
      $tagValue2 = "True"
  
      $dateTime = (Get-Date).ToString()
  
    }
  
    Context 'Verify Public IPs' {
      It 'Step29-01. Check if the correct Tags/Values have been assigned to the Private DNS Zone in CNTY' {
        Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
  
        $becauseText1 = 'The "pip-fw-hub1" Public IP should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
        $becauseText2 = 'The "pip-fw-hub1" Public IP should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingHub TAG assigned' + ' Checked at: ' + $($dateTime)
  
        $publicIpTags = (Get-AzResource -ResourceType Microsoft.Network/publicIPAddresses -Name *pip-fw-hub1).Tags
    
        $resourcetags = convert-hashToString($publicIpTags)
    
        $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue2`"")
        $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")
  
        $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
        $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2
        
      }
     }
} 
  