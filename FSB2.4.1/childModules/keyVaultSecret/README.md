# childModules/keyVaultSecret/keyVaultSecret.bicep
Child module for the Secret creation inside existing Keyvaults .

## Description
This module will create secret for the existing KeyVaults.


## Parent Module Example Use
```bicep
module keyVaultSecret '../../childModules/keyVaultSecret/keyVaultSecret.bicep' = {
  scope: resourceGroup(deployresourceGroup)
  name: 'keyVaultSecret-deployment'
  params: {
    keyVaultName: keyVaultName
    keyVaultSecretEnabled: keyVaultSecretEnabled
    keyVaultSecretName: keyVaultSecretName
    keyVaultSecretType: keyVaultSecretType
    keyVaultSecretValue: keyVaultSecretValue
  }
}
```

## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `keyVaultName` | `string` | true | Specifies the name of the key vault for which the secret needs to be created. |
| `keyVaultSecretEnabled` | `bool` | true | Determines whether or not the secret is enabled. |
| `keyVaultSecretName` | `string` | true | Specifies the name of the secret needs to be created. |
| `keyVaultSecretType` | `int` | true | Specifies the content type of the secret.	 |
| `keyVaultSecretValue` | `string` | true | Specifies the value of the secret. Note: Do not store passwords in parameter files.' |


## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `keyVaultSecretId` | Output the Id of the secret created. | `keyVaultSecret.id` |

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "keyVaultName": {
            "value": "cu8-lnd1-d-euwe-kvt-des"
        },
        "keyVaultSecretEnabled": {
            "value": true
        },
        "keyVaultSecretName": {
            "value": "testsecretnew"
        },
        "keyVaultSecretValue": {
            "value": "Secret Value"
        },
        "keyVaultSecretType": {
            "value": "Secret"
        }
    }
}
```