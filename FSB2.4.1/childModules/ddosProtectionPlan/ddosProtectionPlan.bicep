/*
SUMMARY: Deployment of a DDoS Protection Plan.
DESCRIPTION: Deploy a DDoS Protection Plan.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.6
*/

// PARAMETERS
@description('Specifies the DDoS Plan name')
param name string

@description('Specifies the location where the Azure Resource will be created')
param location string

@description('A mapping of tags to assign to the resource.')
param tags object = {}

// RESOURCE DEPLOYMENTS
resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2021-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {} // This object doesn't contain any properties to set during deployment. All properties are ReadOnly.
}

// OUTPUTS
@description('Resource ID of the DDoS Protection Plan')
output ddosProtectionPlanResourceId string = ddosProtectionPlan.id
