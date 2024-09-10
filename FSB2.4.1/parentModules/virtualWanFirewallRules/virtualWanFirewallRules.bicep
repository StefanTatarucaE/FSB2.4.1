/*
SUMMARY: Virtual Wan Firewall rule collection groups.
DESCRIPTION: Parent module to deploy Firewall rule collection groups as part of vwan solution.             
AUTHOR/S: alexandru-daniel.stan@atos.net
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

// PARAMETERS
@description('Parameter to determine the subscription using abbreviation. To be provided by the pipeline.')
@allowed([
  'mgmt'
  'cnty'
  'lndz'
  'tool'
])
param subscriptionType string

@description('This array represents the firewall rules within the Firewall Policy.')
param firewallRuleCollectionGroups array

@description('Specifies the tier of the Firewall Policy. Allowed values are: "Basic", "Standard", "Premium". Make sure to set the value of this parameter identical to the one in the "virtualWanHubs" array from the "<env>.cnty.virtualWan.params.json parameter file".  ')
param azFirewallPolicySku string

// VARIABLES

// Variables to load the naming convention files for resource naming.
var namingJsonData = {
  mgmt: {
    definition: json(loadTextContent('../../mgmtNaming.json'))
  }
  cnty: {
    definition: json(loadTextContent('../../cntyNaming.json'))
  }
  lndz: {
    definition: json(loadTextContent('../../lndzNaming.json'))
  }
  tool: {
    definition: json(loadTextContent('../../toolNaming.json'))
  }
}
var namingData = namingJsonData[subscriptionType].definition

// Variables to set the desired resourcegroup names

var virtualWanResourceGroupName = namingData.connectivityVirtualWanResourceGroup.name

// Variable which contains a unique value based on subscriptionId & deployment location
// used to deploy the child modules on subscription level.
#disable-next-line no-loc-expr-outside-params
var uniqueDeployPrefix = take(uniqueString(subscription().subscriptionId, deployment().location), 6)

// Variables for the firewall policy to which the firewall rules will be deployed.
var firewallPolicyName = namingData.connectivityHubFirewallPolicy.name
var firewallPolicyNamePremium = namingData.connectivityHubFirewallPolicyPremium.name

// RESOURCE DEPLOYMENTS

// Existing resource group which holds the Vwan resources.
resource virtualWanResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: virtualWanResourceGroupName
}

// Create Firewall Rules (rule collection group).

module virtualWanFirewallRules '../../childModules/virtualWanFirewallRules/virtualWanFirewallRules.bicep' = if (subscriptionType == 'cnty') {
  scope: virtualWanResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-virtualWan-firewall-rules'
  params: {
    azFirewallPolicyName: (azFirewallPolicySku == 'Premium') ? firewallPolicyNamePremium : firewallPolicyName
    firewallRuleCollectionGroups: firewallRuleCollectionGroups
  }
}
