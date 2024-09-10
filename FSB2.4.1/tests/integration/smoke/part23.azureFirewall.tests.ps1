##
## Eviden Landing Zones for Azure - Check Firewall Check.
##

Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

  BeforeAll {
    $tagName1 = $tagPrefix + "Managed"
    $tagName2 = $tagPrefix + "Purpose"

    $tagValue1 = $tagValuePrefix + "NetworkingHub"
    $tagValue2 = "True"

    $dateTime = (Get-Date).ToString()

  }

  Context 'Verify Azure Firewall' {
    It 'Step25-01. Check if the correct Tags/Values have been assigned to the Firewall in CNTY' {
      Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 

      $becauseText1 = 'The Firewall should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
      $becauseText2 = 'The Firewall should have the  ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingHub TAG assigned' + ' Checked at: ' + $($dateTime)

      $firewallPolicyTags = (Get-AzResource -ResourceType Microsoft.Network/azureFirewalls -Name *fw-hub).Tags

      $resourcetags = convert-hashToString($firewallPolicyTags)

      $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue2`"")
      $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

      $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
      $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

    }
    
    It 'Step25-2. Check if the Firewall Policy is asigned to the Firewall' {
      Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

      $firewall = get-azfirewall 
      $fwpolicy = Get-AzFirewallPolicy -ResourceId $firewall.FirewallPolicy.Id
  
      $getFwPolicyId = (Get-AzFirewall -Name *fw-hub).FirewallPolicy.Id

      $becauseText1 = 'The Firewall Policy should be connected to the Firewall' + 'Checked at:' + $($dateTime)

      $fwpolicy.id.ToLower() | should -BeExactly $getFwPolicyId.ToLower() -Because $becauseText1
    
    }
    
  }
}
