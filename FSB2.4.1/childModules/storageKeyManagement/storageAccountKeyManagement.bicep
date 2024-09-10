/*
SUMMARY: Storage Accounts Key management resources deployments (Legacy)
DESCRIPTION: Module to deploy the key rotation managing Key Vault resource for storage accounts and the policy that grants the "Storage Account Key Operator Service Role" to the storage accounts in scope (with specific tag)
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription'

// PARAMETERS
@description('Required. Specifies the location of the Monitoring solution resources.')
param location string

@description('Parameter to determine the subscription using abbreviation. To be provided by the pipeline')
@allowed([ 'lndz' ])
param subscriptionType string

@description('The Object ID of the Key Vault Azure Active Directory application')
param keyVaultAppObjectId string

@description('A mapping of tags to assign to the resource.')
param keyManagementTags object = {}

@description('The Managed Identity of the automation account from Management subscription.')
param automationAccountIdentity string

// VARIABLES

// Variables to load in the naming convention files for resource naming.
var namingJsonData = {
  lndz: {
    definition: json(loadTextContent('../../lndzNaming.json'))
  }
}

var namingData = namingJsonData[subscriptionType].definition

var parentModuleConfig = loadJsonContent('parentModuleConfig.json', 'landingzone')

//Variables to load from the naming convention files for branding, tagging and resource naming.

var tagPrefix = namingData.tagPrefix.name
var tagValuePrefix = namingData.tagValuePrefix.name
var policyMeteringTag = '${namingData.company.name}${namingData.productCode.name}'
var managedPolicyRuleTag = '${namingData.tagPrefix.name}Managed'
var keyRotationPolicyRuleTag = '${namingData.tagValuePrefix.name}StorageAccountKeyRotation'
var tags  = union(keyManagementTags,{ '${tagPrefix}Purpose': '${tagValuePrefix}StorageAccountKeyManagement' }, {'${tagPrefix}Managed': 'true'})

#disable-next-line no-loc-expr-outside-params
var uniqueDeployPrefix = take(uniqueString(subscription().subscriptionId, deployment().location), 6)

var accessPoliciesAdd = [
  {
      objectId: automationAccountIdentity
      permissions: parentModuleConfig.automationAccountIdentityPermissions.permissions
  }
]

// RESOURCE DEPLOYMENTS

resource saKeyManagementResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: namingData.storageKeyManagementKeyvaultResourceGroup.name
  location: location
  tags: tags
}

module managingKeyVault '../keyVault/keyVault.bicep' = {
  name: '${uniqueDeployPrefix}-KeyManagementKeyVault-deployment'
  scope: saKeyManagementResourceGroup
  params: {
    keyVaultName: namingData.storageKeyManagementKeyVault.name
    location: location
    tags: tags
    skuName: parentModuleConfig.keyManagementKeyVaultConfig.skuName
    softDeleteRetentionInDays: parentModuleConfig.keyManagementKeyVaultConfig.softDeleteRetentionInDays
    publicNetworkAccess: parentModuleConfig.keyManagementKeyVaultConfig.publicNetworkAccess
    networkRuleBypassOptions: parentModuleConfig.keyManagementKeyVaultConfig.networkRuleBypassOptions
    networkRuleAction: parentModuleConfig.keyManagementKeyVaultConfig.networkRuleAction
    keyVaultFeatures: parentModuleConfig.keyManagementKeyVaultFeatures
  }
}

module accessPolicy '../keyVaultAccessPolicy/keyVaultAccessPolicy.bicep' = {
  name: '${uniqueDeployPrefix}-keyVaultAccessPolicy-deployment'
  scope: saKeyManagementResourceGroup
  params: {
    keyVaultName: managingKeyVault.outputs.keyVaultName
    accessPoliciesAdd: accessPoliciesAdd
  }
}

module roleAssignmentPolicy '../policy/storageAccountRoleAssignmentChange/policy.bicep' = {
  name: '${uniqueDeployPrefix}-storageRoleAssignment-policy-deployment'
  params: {
    deployLocation: location
    policyRuleTag:[
      managedPolicyRuleTag
      keyRotationPolicyRuleTag
    ]
    policyMetadata: policyMeteringTag
    keyVaultAppObjectId: keyVaultAppObjectId
    storageAccountRoleAssignmentChangePolicyName: namingData.storageAccountRoleAssignmentChange.storageAccountRoleAssignmentChangeName
    storageAccountRoleAssignmentChangePolicyDisplayName: namingData.storageAccountRoleAssignmentChange.storageAccountRoleAssignmentChangeDisplayName
    storageAccountRoleAssignmentChangePolicyAssignmentName: namingData.storageAccountRoleAssignmentChange.storageAccountRoleAssignmentChangeAssignmentName
    storageAccountRoleAssignmentChangePolicyAssignmentDisplayName: namingData.storageAccountRoleAssignmentChange.storageAccountRoleAssignmentChangeAssignmentDisplayName
  }
}
