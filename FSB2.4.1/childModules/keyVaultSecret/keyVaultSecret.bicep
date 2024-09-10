/*
SUMMARY: Child module for the Secret creation inside an existing Keyvaults
DESCRIPTION: Module to create Secret for an existing KeyVault. Note that secrets should not be store in repository in parameter files.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.1
*/

//PARAMETERS
@description('Specifies the name of the key vault.')
param keyVaultName string

@description('Specifies the name of the secret needs to be created.')
param keyVaultSecretName string

@description('Specifies if secret should be enabled.')
param keyVaultSecretEnabled bool

@description('Specifies the type of the secret.')
param keyVaultSecretType string

@secure()
param keyVaultSecretValue string

//RESOURCES
resource existingKeyvault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' =  {
  parent: existingKeyvault
  name: keyVaultSecretName
  properties: {
    attributes: {
      enabled: keyVaultSecretEnabled
    }
    contentType: keyVaultSecretType
    value: keyVaultSecretValue
  }
}

//OUTPUTS
output keyVaultSecretId string = keyVaultSecret.id
