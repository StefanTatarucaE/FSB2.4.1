##
## Eviden Landing Zones for Azure - Feature test Validate the nsg rule sets in accordance with DSC services and VM OS Management
##


Describe 'Core -  Validate the nsg rule sets in CNTY' {

    BeforeAll {
      $dateTime = (Get-Date).ToString()
      Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
      $nsg = Get-AzResource -ResourceType "Microsoft.Network/networkSecurityGroups" -Tag @{"${tagPrefix}Purpose" = "${tagValuePrefix}NetworkingHub"} -Name "*hub-network"
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



Describe 'Core -  Validate the nsg rule sets in LNDZ' {

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
  
 