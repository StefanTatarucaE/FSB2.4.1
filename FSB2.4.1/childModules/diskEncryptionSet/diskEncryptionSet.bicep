/*
SUMMARY: Disk Encryption Set module
DESCRIPTION: Module for deployment of Azure Disk Encryption Set
             Deploys disk encryption set and access policy for associated key vault to use encryption key
AUTHOR/S: gert.zanting@eviden.com
VERSION: 0.0.1
*/

// PARAMETERS
@description('Specifies the name of the Disk Encryption Set.')
param diskEncryptionSetName string

@description('Name of the deployment region. Disk encryption set and key vault must be located in same region.')
param location string

@description('A mapping of tags to assign to the resource.')
param tags object

@description('Name for existing key vault, must be unique across Azure.')
param keyVaultName string

@description('Name for key in existing key vault, key itself must be existing as well.')
param keyName string

@description('Enable auto-updating to the latest key version.')
param keyRotationEnabled bool

// RESOURCE DEPLOYMENTS 
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

resource keyVaultKey 'Microsoft.KeyVault/vaults/keys@2021-10-01' existing = {
  name: keyName
  parent: keyVault
}

resource diskEncryptionSet 'Microsoft.Compute/diskEncryptionSets@2022-03-02' = {
  name: diskEncryptionSetName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    activeKey: {
      sourceVault: {
        id: keyVault.id
      }
      keyUrl: keyVaultKey.properties.keyUriWithVersion
    }
    rotationToLatestKeyVersionEnabled: keyRotationEnabled
  }
}

// OUTPUTS
output diskEncryptionSetId string = diskEncryptionSet.id
output diskEncryptionSetName string = diskEncryptionSet.name
output diskEncryptionSetPrincipalId string = diskEncryptionSet.identity.principalId
