/*
SUMMARY: Child module for the access policy
DESCRIPTION: Module to create, update or delete the access policies for an existing KeyVault.
AUTHOR/S: alkesh.naik@eviden.com
VERSION: 0.2
*/



//PARAMETERS
@description('Specifies the name of the key vault for which the access policy needs to be added, modifed or removed.')
param keyVaultName string

@description('Array of AccessPolicies to be created for the KeyVault')
param accessPoliciesAdd array = []

@description('Array of objectid to be deleted needs to be passed.')
param accessPoliciesRemove array = []

@description('Array of AccessPolicies to be update for the KeyVault')
param accessPoliciesUpdate array = []

//VARIABLES
var tenantId = subscription().tenantId

//RESOURCES
resource keyVaultAccessPolicyAdd 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${keyVaultName}/add' //here we have to specify the keyvaultname for it to assign the access to the correct keyvault. The accepted values after keyvaultname is 'add' | 'remove' | 'replace'".
  properties: {
    accessPolicies: [for policy in accessPoliciesAdd: {
      objectId: policy.objectId
      tenantId: tenantId
      permissions: policy.permissions
    }]
  }
}

resource keyVaultAccessPolicyRemove 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${keyVaultName}/remove' //here we have to specify the keyvaultname for it to assign the access to the correct keyvault. The accepted values after keyvaultname is 'add' | 'remove' | 'replace'".
  properties: {
    accessPolicies: [for policy in accessPoliciesRemove: {
      objectId: policy.objectId
      tenantId: tenantId
    }]
  }
  dependsOn: [
    keyVaultAccessPolicyAdd
  ]
}

resource keyVaultAccessPolicyUpdate 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${keyVaultName}/replace' //here we have to specify the keyvaultname for it to assign the access to the correct keyvault. The accepted values after keyvaultname is 'add' | 'remove' | 'replace'".
  properties: {
    accessPolicies: [for policy in accessPoliciesUpdate: {
      objectId: policy.objectId
      tenantId: tenantId
      permissions: policy.permissions
    }]
  }
  dependsOn: [
    keyVaultAccessPolicyAdd
    keyVaultAccessPolicyRemove
  ]
}


// OUTPUTS
