/*
SUMMARY: Deployment of firewall rule collection groups.
DESCRIPTION: Deploy firewall rule collection groups for the virtual wan hub firewall policy.
AUTHOR/S: alexandru-daniel.stan@atos.net
VERSION: 0.0.1
*/

// PARAMETERS

@description('Name of the firewall Policy.')
param azFirewallPolicyName string

@description('This array represents the firewall rules within the Firewall Policy.')
param firewallRuleCollectionGroups array

// RESOURCES

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-01-01' existing = {
  name: azFirewallPolicyName
}

@batchSize(1)
resource firewallPolicyRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = [ for ruleGroups in firewallRuleCollectionGroups: {
  parent: firewallPolicy
  name: ruleGroups.name
  properties: ruleGroups.properties
}]

// Outputs

@description('The resource name of the deployed Firewall Policy.')
output firewallPolicyName string = firewallPolicy.name

@description('The resource id of the deployed Firewall Policy.')
output firewallPolicyResourceId string = firewallPolicy.id
