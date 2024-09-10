# Deployment of firewall rule collection groups.

This bicep module deploys firewall rule collection groups (firewall rules) for the virtual wan hub firewall policy.

## Navigation <!-- omit in toc -->

- [Parameters](#parameters)

  - [Required parameters](#required-parameters)

- [Outputs](#outputs)
- [Deployment example](#deployment-example)

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Network/firewallPolicies` | [2022-01-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/firewallpolicies?pivots=deployment-language-bicep) |
| `Microsoft.Network/firewallPolicies/ruleCollectionGroups` | [2022-01-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/firewallpolicies/rulecollectiongroups?pivots=deployment-language-bicep) |

## Parameters

### Required parameters

|  Name | Type | Description |
| :-- | :-- | :-- |
| `azFirewallPolicyName` | string | Name of the firewall Policy. The value of this will be provided in the virtualWanFirewallRules parent module using the helper (naming) module. |
| `firewallRuleCollectionGroups` | array | This array represents the firewall rules (rule collection groups) within the Firewall Policy. |

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `firewallPolicyName` | string | The resource name of the deployed Firewall Policy. |
| `firewallPolicyResourceId` | string | The resource id of the deployed Firewall Policy. |

## Deployment example

<p>
<details>
<summary>via Bicep module</summary>

```bicep
module virtualWanFirewallPolicies '../../childModules/virtualWanFirewallRules/virtualWanFirewallRules.bicep' = {
  scope: exampleRG
  name: 'virtualWan-firewall-rules'
  params: {
    azFirewallPolicyName: 'firewall-policy' 
    applicationFirewallRuleCollectionGroups: applicationFirewallRuleCollectionGroups
    networkFirewallRuleCollectionGroups: networkFirewallRuleCollectionGroups
  }
}

```

</details>
</p>