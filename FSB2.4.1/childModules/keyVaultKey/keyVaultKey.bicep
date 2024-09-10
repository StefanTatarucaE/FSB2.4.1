/*
SUMMARY: Child module for the Key creation inside existing Keyvaults
DESCRIPTION: Module to create keys for an existing KeyVault.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.1
*/

//PARAMETERS
@description('Specifies the name of the key vault.')
param keyVaultName string

@description('Specifies the name of the key needs to be created.')
param keyVaultKeyName string

@description('Specifies if key should be enabled.')
param keyVaultKeyEnabled bool

@description('Specifies the size of the key.')
param keyVaultKeySize int

@description('Specifies the type of the key.')
param keyVaultKeyType string

@description('Specifies the Key Rotation Policy.')
param keyVaultKeyRotationPolicy object

//RESOURCES
resource existingKeyvault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

resource keyVaultKey 'Microsoft.KeyVault/vaults/keys@2021-06-01-preview' = {
  parent: existingKeyvault
  name: keyVaultKeyName
  properties: {
    attributes: {
      enabled: keyVaultKeyEnabled
    }
    keySize: keyVaultKeySize
    kty: keyVaultKeyType
    rotationPolicy: !empty(keyVaultKeyRotationPolicy) ? keyVaultKeyRotationPolicy : null
  }
}

//OUTPUTS
output keyVaultKeyName string = keyVaultKey.name
output keyVaultKeyId string = keyVaultKey.id
