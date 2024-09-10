/*
SUMMARY: Role Assignment used in combination with the Managed Identity child module.
DESCRIPTION: Deployment of Role assignments at resource group level for existing managed identities for the Eviden Landingzones for Azure solution.
AUTHOR/S: alkesh.naik@eviden.com
VERSION: 0.0.1
*/
// SCOPE
targetScope = 'resourceGroup'

//PARAMETERS
@description('Required. The resource ID of the resource to apply the role assignment to')
param managedIdentityId string

@description('Required. The name of the role to assign. If it cannot be found you can specify the role definition ID instead')
param roleDefinitionIdOrNames array = []


//VARIABLES
var builtInRoleNames = {
  'Owner': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  }
  'Contributor': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  } 
  'Reader': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  }
  'Log Analytics Contributor': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '92aaf0da-9dab-42b6-94a3-d43ce8d16293')
  }
  'Log Analytics Reader': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '73c42c96-874c-492b-b04d-ab87d138a893')
  } 
  'Managed Identity Contributor': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e40ec5ca-96e0-45a2-b4ff-59039f2c2b59')
  }
  'Managed Identity Operator': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f1a07417-d97a-45cb-824c-7a7467783830')
  }
  'Monitoring Contributor': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '749f88d5-cbae-40b8-bcfc-e573ddc772fa')
  }
  'Monitoring Metrics Publisher': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')
  }
  'Monitoring Reader': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '43d0d8ad-25c7-4714-9337-8ba259a9fe05')
  }
  'Resource Policy Contributor': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '36243c78-bf99-498c-9df9-86d9f8d28608')
  }
  'Security Admin': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'fb1c8493-542b-48eb-b624-b4c8fea62acd')
  }
  'User Access Administrator': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9')
  }
  'VM Contributor': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '9980e02c-c2be-4d73-94e8-173b1dc7cf3c')
  }
  'Website Contributor': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'de139f84-1756-47ae-9be6-808fbbe84772')
  }
  'Network Contributor': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
  }
  'DocumentDB Contributor': {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5bd9cd88-fe45-4216-938b-f97437e15450')
  }
  'Azure Kubernetes Service Contributor Role':{
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8') 
  }
  'Automation Operator':{
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'd3881f73-407a-4167-8283-e981cbba0404') 
  }
}

var principalType = 'ServicePrincipal' //Setting hardcoded to ServicePrincipal to make sure deployment does not find when assigning role. See https://aka.ms/docs-principaltype

//RESOURCE Deployment
// Create Role Assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for roleDefinitionIdorName in roleDefinitionIdOrNames: {
  name: guid(principalType, managedIdentityId, roleDefinitionIdorName)
  properties: {
    roleDefinitionId: contains(builtInRoleNames, roleDefinitionIdorName) ? builtInRoleNames[roleDefinitionIdorName].id : roleDefinitionIdorName
    principalId: managedIdentityId
    principalType: !empty(principalType) ? principalType : null
  }
}]

//OUTPUTS
