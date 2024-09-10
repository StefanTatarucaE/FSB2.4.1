##
## Eviden Landing Zones for Azure - Feature test Validate the nsg rule sets in accordance with DSC services and VM OS Management
##

Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

  BeforeAll {
    $dateTime = (Get-Date).ToString()

    $tagName1 = $tagPrefix + "Managed"
    $tagName2 = $tagPrefix + "Purpose"

    $tagValue1 = $tagValuePrefix + "NetworkingHub"
    $tagValue2 = $tagValuePrefix + "NetworkingSpoke"
    $tagValue3 = "True"

  }

  Context 'Verify NSG Tags' {
    It 'Check for NSG Tags in CNTY subscription' {
      Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

      $becauseText1 = 'The NSG should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
      $becauseText2 = 'The NSG should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingHub TAG assigned' + ' Checked at: ' + $($dateTime)

      $nsgTags = (Get-AzResource -ResourceType Microsoft.Network/networkSecurityGroups -Name *hub-network*).Tags

      $resourcetags = convert-hashToString($nsgTags)

      $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue3`"")
      $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

      $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
      $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2
    }

    It 'Check for NSG Tags in LNDZ subscription' {
      Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

      $becauseText1 = 'The  NSG should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
      $becauseText2 = 'The NSG should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingSpoke TAG assigned' + ' Checked at: ' + $($dateTime)

      $nsg1Tags = (Get-AzResource -ResourceType Microsoft.Network/networkSecurityGroups -Name *back*).Tags
      $nsg2Tags = (Get-AzResource -ResourceType Microsoft.Network/networkSecurityGroups -Name *front*).Tags
      $nsg3Tags = (Get-AzResource -ResourceType Microsoft.Network/networkSecurityGroups -Name *middle*).Tags

      $resourcetags1 = convert-hashToString($nsg1Tags)
      $resourcetags2 = convert-hashToString($nsg2Tags)
      $resourcetags3 = convert-hashToString($nsg3Tags)

      $resource1MatchesTag1 = ($resourcetags1 -match "$tagName1=`"$tagValue3`"")
      $resource1MatchesTag2 = ($resourcetags1 -match "$tagName2=`"$tagValue2`"")

      $resource2MatchesTag1 = ($resourcetags2 -match "$tagName1=`"$tagValue3`"")
      $resource2MatchesTag2 = ($resourcetags2 -match "$tagName2=`"$tagValue2`"")

      $resource3MatchesTag1 = ($resourcetags3 -match "$tagName1=`"$tagValue3`"")
      $resource3MatchesTag2 = ($resourcetags3 -match "$tagName2=`"$tagValue2`"")

      $resource1MatchesTag1 | Should -BeTrue -Because $becauseText1
      $resource1MatchesTag2 | Should -BeTrue -Because $becauseText2

      $resource2MatchesTag1 | Should -BeTrue -Because $becauseText1
      $resource2MatchesTag2 | Should -BeTrue -Because $becauseText2

      $resource3MatchesTag1 | Should -BeTrue -Because $becauseText1
      $resource3MatchesTag2 | Should -BeTrue -Because $becauseText2
    }
  }
}

Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

  BeforeAll {
    $dateTime = (Get-Date).ToString()
  }

  Context 'Verify associated subnets for NSGs' {
    It 'Check for NSG associated subnet in CNTY' {
      Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
      $becauseText = 'The NSG in CNTY should be associated with the *snet-hub-network* subnet' + 'Checked at:' + $($dateTime)

      $nsgID = (Get-AzNetworkSecurityGroup -Name *hub-network*).Id
      $nsgSubnetId = (Get-AzNetworkSecurityGroup -Name *hub-network*).Subnets.Id
      $subnetNsgId = (Get-AzVirtualNetworkSubnetConfig -ResourceId $nsgsubnetId).NetworkSecurityGroup.Id

      $nsgID | Should -BeExactly $subnetNsgId -Because $becauseText

    }

    It 'Check for NSG associated subnet in LNDZ' {
      Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
      $becauseText1 = 'The "spoke-front" NSG in LNDZ should be associated with the *snet-spoke-front* subnet' + 'Checked at:' + $($dateTime)
      $becauseText2 = 'The "spoke-back" NSG in LNDZ should be associated with the *snet-spoke-back* subnet' + 'Checked at:' + $($dateTime)
      $becauseText3 = 'The "spoke-middle" NSG in LNDZ should be associated with the *snet-spoke-middle* subnet' + 'Checked at:' + $($dateTime)

      $nsgID1 = (Get-AzNetworkSecurityGroup -Name *spoke-front*).Id
      $nsgSubnetId1 = (Get-AzNetworkSecurityGroup -Name *spoke-front*).Subnets.Id
      $subnetNsgId1 = (Get-AzVirtualNetworkSubnetConfig -ResourceId $nsgSubnetId1).NetworkSecurityGroup.Id

      $nsgID1 | Should -BeExactly $subnetNsgId1 -Because $becauseText1

      $nsgID2 = (Get-AzNetworkSecurityGroup -Name *spoke-back*).Id
      $nsgSubnetId2 = (Get-AzNetworkSecurityGroup -Name *spoke-back*).Subnets.Id
      $subnetNsgId2 = (Get-AzVirtualNetworkSubnetConfig -ResourceId $nsgSubnetId2).NetworkSecurityGroup.Id

      $nsgID2 | Should -BeExactly $subnetNsgId2 -Because $becauseText2

      $nsgID3 = (Get-AzNetworkSecurityGroup -Name *spoke-middle*).Id
      $nsgSubnetId3 = (Get-AzNetworkSecurityGroup -Name *spoke-middle*).Subnets.Id
      $subnetNsgId3 = (Get-AzVirtualNetworkSubnetConfig -ResourceId $nsgsubnetId3).NetworkSecurityGroup.Id

      $nsgID3 | Should -BeExactly $subnetNsgId3 -Because $becauseText3

    }
  }
}

Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
      $dateTime = (Get-Date).ToString()
      Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
      $nsg = Get-AzResource -ResourceType "Microsoft.Network/networkSecurityGroups" -Tag @{"${tagPrefix}Purpose" = "${tagValuePrefix}NetworkingHub" } -Name "*hub-network"
      $nsgCnty = Get-AzNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $nsg.ResourceGroupName
        
    }
  
    Context 'Verify nsg rule sets on CNTY' {
      It 'Check for Default Security Rules' {
        $becauseText = 'There are 6 Default Security rules by default for Inbound/Outbound' + 'Checked at:' + $($dateTime)
        $nsgCnty.DefaultSecurityRules.Count | Should -BeExactly 6 -Because $becauseText      
    }
        
      
      It 'Check for Security Rules' {
        $becauseText = 'There are 2 new security rules added: BLOCK_ALL_UDP AND BLOCK_ALL_TCP' + 'Checked at:' + $($dateTime)
        $nsgCnty.SecurityRules.Count | Should -BeExactly 2 -Because $becauseText
      }
    }
  }



Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
      $dateTime = (Get-Date).ToString()
      Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
      $rgName = Get-AzResourceGroup  -Name "*spoke-network*"
 
    }
  
    Context 'Verify nsg Default Security Rules for spoke-back, spoke-front and spoke-middle' {
        
      It 'Check for Default Security rules' {

          $becauseText = 'There are 6 Default Security rules by default for Inbound/Outbound' + 'Checked at:' + $($dateTime)
          #Default security rules should be equal with 6 rules.
          $nsgBack = Get-AzNetworkSecurityGroup -Name "*spoke-back*" -ResourceGroupName $rgName.ResourceGroupName
          $nsgBack.DefaultSecurityRules.Count | Should -BeLikeExactly 6 -Because $becauseText
            
          $nsgFront = Get-AzNetworkSecurityGroup -Name "*spoke-front*" -ResourceGroupName $rgName.ResourceGroupName
          $nsgFront.DefaultSecurityRules.Count | Should -BeLikeExactly 6 -Because $becauseText
            
          $nsgMiddle = Get-AzNetworkSecurityGroup -Name "*spoke-middle*" -ResourceGroupName $rgName.ResourceGroupName
          $nsgMiddle.DefaultSecurityRules.Count | Should -BeLikeExactly 6 -Because $becauseText
      }
    
    } 

    Context 'Verify nsg Security rules sets on LNDZ for spoke-back, spoke-front and spoke-middle' {

      It 'Check for Security rules of spoke-back nsg' {
        
        $becauseText = 'Checked at:' + $($dateTime)
        #Check for rule: DCSA-Allow-Own-Subnet-Inbound #1#
        $nsgBackSubIn = Get-AzNetworkSecurityGroup -Name "*spoke-back*" | Get-AzNetworkSecurityRuleConfig -Name "DCSA-Allow-Own-Subnet-Inbound"
        $nsgBackSubIn.Access | Should -BeLikeExactly 'Allow' -Because $becauseText
        $nsgBackSubIn.DestinationPortRange | Should -BeLike '*' -Because $becauseText

        #Check for rule: DCSA-Allow-Own-Subnet-Outbound #2# 
        $nsgBackOwnSub = Get-AzNetworkSecurityGroup -Name "*spoke-back*" | Get-AzNetworkSecurityRuleConfig -Name "DCSA-Allow-Own-Subnet-Outbound"
        $nsgBackOwnSub.Access | Should -BeLikeExactly 'Allow' -Because $becauseText
        $nsgBackOwnSub.DestinationPortRange | Should -BeLike '*' -Because $becauseText
        
      }
        
      It 'Check for Security rules of spoke-front nsg' {

        $becauseTest = 'Checked at:' +$($dateTime)
        #Check for rule: DCSA-Allow-Own-Subnet-Inbound #1#
        $nsgfrontSubIn = Get-AzNetworkSecurityGroup -Name "*spoke-front*"  | Get-AzNetworkSecurityRuleConfig -Name "DCSA-Allow-Own-Subnet-Inbound"
        $nsgfrontSubIn.Access | Should -BeLikeExactly 'Allow' -Because $becauseText
        $nsgfrontSubIn.DestinationPortRange | Should -BeLike '*' -Because $becauseText

        #Check for rule: DCSA-Allow-Own-Subnet-Outbound #2# 
        $nsgfrontOwnSub = Get-AzNetworkSecurityGroup -Name "*spoke-front*"  | Get-AzNetworkSecurityRuleConfig -Name "DCSA-Allow-Own-Subnet-Outbound"
        $nsgfrontOwnSub.Access | Should -BeLikeExactly 'Allow' -Because $becauseText
        $nsgfrontOwnSub.DestinationPortRange | Should -BeLike '*' -Because $becauseText
      
      }

      It 'Check for Security rules of spoke-middle nsg' {
        
        $becauseText = 'Checked at:' + $($dateTime)
        #Check for rule: DCSA-Allow-Own-Subnet-Inbound #1#
        $nsgmidSubIn = Get-AzNetworkSecurityGroup -Name "*spoke-middle*" | Get-AzNetworkSecurityRuleConfig -Name "DCSA-Allow-Own-Subnet-Inbound"
        $nsgmidSubIn.Access | Should -BeLikeExactly 'Allow' -Because $becauseText
        $nsgmidSubIn.DestinationPortRange | Should -BeLike '*' -Because $becauseText

        #Check for rule: DCSA-Allow-Own-Subnet-Outbound #2# 
        $nsgmidOwnSub = Get-AzNetworkSecurityGroup -Name "*spoke-middle*" | Get-AzNetworkSecurityRuleConfig -Name "DCSA-Allow-Own-Subnet-Outbound"
        $nsgmidOwnSub.Access | Should -BeLikeExactly 'Allow' -Because $becauseText
        $nsgmidOwnSub.DestinationPortRange | Should -BeLike '*' -Because $becauseText
      
      }

    } 
}
  
 