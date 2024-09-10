Describe 'Core -  Firewall policy' {

  BeforeAll {
    Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
    $dateTime = (Get-Date).ToString()

    $firewall = get-azfirewall 
    $fwpolicy = Get-AzFirewallPolicy -ResourceId $firewall.FirewallPolicy.Id

    $ruleCollName = "DefaultNetworkRuleCollectionGroup"
    $ruleCollName2 = "DefaultApplicationRuleCollectionGroup"
    $appRules = "Eviden-Application-Allow-RC"

    $openPorts =  get-firewallPolicies -fwPolicyName $fwPolicy.Name -resourceGroupName $fwPolicy.ResourceGroupName -ruleCollName $ruleCollName

    $getRules = Get-AzFirewallPolicyRuleCollectionGroup -Name $ruleCollName2 -ResourceGroupName $fwPolicy.ResourceGroupName -AzureFirewallPolicyName $fwPolicy.Name
    $filterRules = $getRules.Properties.RuleCollection | where {$_.Name -eq $appRules}
    $rulesList = $filterRules.Rules[0..6].Name
  }

  Context 'Verify Azure Firewall Policy Rules' {
    It 'Check if HTTP/HTTPS ports are opened in the firewall' {
      $becauseText1 = 'HTTP port 80 should be opened in the firewall' + 'Checked at:' + $($dateTime)
      $becauseText2 = 'HTTPS port 443 should be opened in the firewall' + 'Checked at:' + $($dateTime)
      "80" | should -BeIn $openPorts -Because $becauseText1
      "443" | should -BeIn $openPorts -Because $becauseText2
    }
    
    It 'Check if KMS port is open in the firewall' {
      $becauseText = 'KMS port 1688 should be opened in the firewall' + 'Check at:' + $($dateTime)
      "1688" | should -BeIn $openPorts -Because $becauseText
    }

    It 'Check if "ExampleEvidenAllowMicrosoft" rule is present in the App Rule Collection' {
      $becauseText = '"ExampleEvidenAllowMicrosoft" rule should be present in the App Rule Collection' + 'Check at:' + $($dateTime)
      "ExampleEvidenAllowMicrosoft" | should -BeIn $rulesList -Because $becauseText
    }    

    It 'Check if "EvidenAllowBackup" rule is present in the App Rule Collection' {
      $becauseText = '"EvidenAllowBackup" rule should be present in the App Rule Collection' + 'Check at:' + $($dateTime)
      "EvidenAllowBackup" | should -BeIn $rulesList -Because $becauseText
    }

    It 'Check if "EvidenAllowUpdateManagement" rule is present in the App Rule Collection' {
      $becauseText = '"EvidenAllowUpdateManagement" rule should be present in the App Rule Collection' + 'Check at:' + $($dateTime)
      "EvidenAllowUpdateManagement" | should -BeIn $rulesList -Because $becauseText
    }

    It 'Check if "EvidenAllowOMS" rule is present in the App Rule Collection' {
      $becauseText = '"EvidenAllowOMS" rule should be present in the App Rule Collection' + 'Check at:' + $($dateTime)
      "EvidenAllowOMS" | should -BeIn $rulesList -Because $becauseText
    }

    It 'Check if "EvidenAllowQualys" rule is present in the App Rule Collection' {
      $becauseText = '"EvidenAllowQualys" rule should be present in the App Rule Collection' + 'Check at:' + $($dateTime)
      "EvidenAllowQualys" | should -BeIn $rulesList -Because $becauseText
    }

    It 'Check if "EvidenAllowWindowsLinux" rule is present in the App Rule Collection' {
      $becauseText = '"EvidenAllowWindowsLinux" rule should be present in the App Rule Collection' + 'Check at:' + $($dateTime)
      "EvidenAllowWindowsLinux" | should -BeIn $rulesList -Because $becauseText
    }

    It 'Check if "EvidenAllowWindowsNet" rule is present in the App Rule Collection' {
      $becauseText = '"EvidenAllowWindowsNet" rule should be present in the App Rule Collection' + 'Check at:' + $($dateTime)
      "EvidenAllowWindowsNet" | should -BeIn $rulesList -Because $becauseText
    }
  }
}
