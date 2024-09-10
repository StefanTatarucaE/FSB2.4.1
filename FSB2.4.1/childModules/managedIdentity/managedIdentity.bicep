/*
SUMMARY: Managed Identity child module.
DESCRIPTION: Deployment of Managed Identity for the Eviden Landingzones for Azure solution.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

//PARAMETERS
@description('Specifies the name of the Managed Identity.')
param userManagedIdentityName string

@description('Specifies the location of the Managed Identity.')
param location string = resourceGroup().location

@description('A mapping of tags to assign to the resource.')
param tags object

//RESOURCE Deployment

// Create keyVault and policies
resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userManagedIdentityName
  location: location
  tags: tags
}

//OUTPUTS
@description('The name of the user assigned identity')
output userManagedIdentityName string = userManagedIdentity.name

@description('The resource ID of the user assigned identity')
output userManagedIdentityResourceID string = userManagedIdentity.id

@description('The principal ID of the user assigned identity')
output userManagedIdentityPrincipalId string = userManagedIdentity.properties.principalId

@description('The resource group the user assigned identity was deployed into')
output resourceGroupName string = resourceGroup().name
