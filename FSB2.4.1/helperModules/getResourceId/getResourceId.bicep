/*
SUMMARY: helper child module to get resourceid of an existing resource.
DESCRIPTION: This module doesnt deploy anything, but it allow to get the ID of an existing resource in a different subscription.
AUTHOR/S: frederic.trapet@eviden.com
VERSION: 0.1
*/

// SCOPE
targetScope = 'subscription'

//PARAMETERS
@description('Specify the name of the Resource group in the scoped subscription that contains the resource')
param resourceGroupName string

@description('Specify the name of the resource in the specified resource group')
param resourceName string

@description('Specify the type of the resource between allowed types in this modules')
@allowed([
  'actionGroup'
  'monitoringWorkspace'
  'functionApp'
  'dataCollectionRules'
  'managedIdentity'
])
param resourceType string

var outputResourceId = (resourceType == 'actionGroup') ? existingActionGroup.id : (resourceType == 'monitoringWorkspace') ? existingWorkspace.id : (resourceType == 'functionApp') ? existingFunctionApp.id : (resourceType == 'dataCollectionRules') ? existingDataCollectionRules.id : (resourceType == 'managedIdentity') ? existingUserManagedIdentity.properties.principalId : 'unknown'

//RESOURCE Deployment

// Get existing action group if needed
resource existingActionGroup 'Microsoft.Insights/actionGroups@2022-06-01' existing = if (resourceType == 'actionGroup') {
  scope: resourceGroup(resourceGroupName)
  name: resourceName
}

// Get existing workspace if needed
resource existingWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (resourceType == 'monitoringWorkspace') {
  scope: resourceGroup(resourceGroupName)
  name: resourceName
}

// Get existing functionapp if needed
resource existingFunctionApp 'Microsoft.Web/sites@2021-03-01' existing = if (resourceType == 'functionApp') {
  scope: resourceGroup(resourceGroupName)
  name: resourceName
}

// Get existing Data Collection Rules
resource existingDataCollectionRules 'Microsoft.Insights/dataCollectionRules@2022-06-01' existing = if (resourceType == 'dataCollectionRules') {
  scope : resourceGroup(resourceGroupName)
  name: resourceName
}

// Get existing User Managed Identity
resource existingUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if (resourceType == 'managedIdentity') {
  scope : resourceGroup(resourceGroupName)
  name: resourceName
}


//OUTPUTS
// return the id of the resource (first value not null in the list)
output resourceID string = outputResourceId

