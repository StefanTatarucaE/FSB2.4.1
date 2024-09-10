/*
SUMMARY: KeyVault child module.
DESCRIPTION: Deployment of KeyVault resource for the ELZ solution.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.6
*/

//PARAMETERS
@description('Specifies the name of the key vault.')
param keyVaultName string

@description('Specifies the location of the key vault.')
param location string

@description('Specifies the SKU name for the key vault.')
@allowed(['standard','premium'])
param skuName string

@description('A mapping of tags to assign to the resource.')
param tags object

@description('Object to specify the features of the key vault.')
param keyVaultFeatures object

@description('Specifies whether the key vault will accept traffic from public internet. If set to disabled it overrides all firewall rules, allowing only private endpoint and trusted services traffic.')
@allowed(['enabled', 'disabled'])
param publicNetworkAccess string

@description('Soft Delete data retention days.')
@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int

@description('Specifies what traffic can bypass the network rules. This can be AzureServices (default if not specified) or None')
@allowed(['None', 'AzureServices'])
param networkRuleBypassOptions string

@description('The default action when no rule from ipRules and from virtualNetworkRules match. This is only used after the bypass (networkRuleBypassOptions) property has been evaluated.')
@allowed(['Allow', 'Deny'])
param networkRuleAction string

//VARIABLES
var tenantId = subscription().tenantId

//RESOURCES
resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      name: skuName
      family: 'A' //hardcoded, only option available
    }
    accessPolicies: []
    enabledForDeployment: keyVaultFeatures.enabledForDeployment
    enabledForDiskEncryption: keyVaultFeatures.enabledForDiskEncryption
    enabledForTemplateDeployment: keyVaultFeatures.enabledForTemplateDeployment
    enablePurgeProtection: keyVaultFeatures.enablePurgeProtection ? keyVaultFeatures.enablePurgeProtection: json('null') //deployment fails if enablePurgeProtection is set to false
    enableRbacAuthorization: keyVaultFeatures.enableRbacAuthorization
    enableSoftDelete: keyVaultFeatures.enableSoftDelete
    softDeleteRetentionInDays: keyVaultFeatures.enableSoftDelete ? softDeleteRetentionInDays : json('null')
    publicNetworkAccess: publicNetworkAccess
    tenantId: tenantId
    networkAcls: {
      bypass: networkRuleBypassOptions
      defaultAction: networkRuleAction
    }
  }
}

//OUTPUTS
output keyVaultName string = keyVault.name
output keyVaultResourceId string = keyVault.id
