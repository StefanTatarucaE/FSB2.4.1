/*
SUMMARY: Deployment of a logic app.
DESCRIPTION: Deploy a logic app to the desired Azure region.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.1
Notes: Requires bicep minimum version 0.7.4
*/

// PARAMETERS
@description('Specify unique logic app name')
param logicAppName string

@description('Specify the location where logic app is to be created')
param location string

@description('Speciy mapping of tags attached to logic app')
param tags object

@description('Provide the definition for workflow')
param definition object

@description('Specify parameter object required for definition workflow')
param definitionParameters object

@description('Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool

@description('The ID(s) to assign to the resource.')
param userAssignedIdentities object

@description('The workflow state.')
@allowed([
  'Completed'
  'Deleted'
  'Disabled'
  'Enabled'
  'NotSpecified'
  'Suspended'
])
param logicAppState string

// VARIABLES

var identityType = systemAssignedIdentity ? 'SystemAssigned' : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

var logicAppCallbackUrl = listCallbackURL('${logicApp.id}/triggers/manual','2019-05-01').value

// RESOURCE DEPLOYMENTS
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  tags: tags
  identity: identity

  properties: {
    definition: definition
    parameters: definitionParameters
    state: logicAppState
  }
}

//OUTPUTS
output logicAppID string = logicApp.id
output logicAppPrincipalId string = identityType == 'SystemAssigned' ? logicApp.identity.principalId : 'None'
output logicAppCallbackUrl string = logicAppCallbackUrl
