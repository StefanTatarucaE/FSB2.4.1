# childModules/keyVaultKey/keyVaultKey.bicep
Child module for the Key creation inside existing Keyvaults .

## Description
This module will create key for the existing KeyVaults.
It's only possible to create new keys. It isn't possible to update existing keys, nor create new versions of existing keys.


## Parent Module Example Use
```bicep
module keyVaultKey '../../childModules/keyVaultKey/keyVaultKey.bicep' = {
  scope: resourceGroup(deployresourceGroup)
  name: 'keyVaultKey-deployment'
  params: {
    keyVaultName: keyVaultName
    keyVaultKeyEnabled: keyVaultKeyEnabled
    keyVaultKeyName: keyVaultKeyName
    keyVaultKeySize: keyVaultKeySize
    keyVaultKeyType: keyVaultKeyType
    keyVaultKeyRotationPolicy: keyVaultKeyRotationPolicy
  }
}
```

## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `keyVaultName` | `string` | true | Specifies the name of the key vault for which the key needs to be created. |
| `keyVaultKeyEnabled` | `bool` | true | Determines whether or not the key is enabled. |
| `keyVaultKeyName` | `string` | true | Specifies the name of the key needs to be created. |
| `keyVaultKeySize` | `int` | true | Specifies the key size in bits. For example: 2048, 3072, or 4096 for RSA. |
| `keyVaultKeyType` | `string` | true | Specifies the type of the key. For Example: 'EC''EC-HSM''RSA''RSA-HSM' |
| `keyVaultKeyRotationPolicy` | `object` | true | Specifies the properties of the key rotation policy |

## 'keyVaultKeyRotationPolicy' Parameter Properties 

| Name | Type | Description |
| --- | --- | --- |
| `lifetimeActions` | `array` | An array of trigger/action pair objects describing the behaviour of the key during its life cycle. |
| `trigger` | `object` | Object holding the trigger definition for a particular lifetimeAction. |
| `timeAfterCreate` | `string` | Specifies at what time after creation of a key the action from this particular lifetimeAction will take place. Defined in ISO 8601 format. Eg: 'P90D', 'P1Y'.|
| `timeBeforeExpiry` | `string` | Specifies at what time before expiration of a key the action from this particular lifetimeAction will take place. Defined in ISO 8601 format. |
| `action` | `string` | Specifies the action to be taken at trigger time. Valid options are `rotate` and `notify`. The rotate option creates a new version of the key, the notify option generates an EventGrid event. |
| `attributes` | `object` | Placeholder object for `expiryTime` property |
| `expiryTime` | `string` | Specifies the expiration time for the new key version. It should be in ISO8601 format. Eg: 'P90D', 'P1Y'. |

## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `keyVaultKeyId` | Output the Id of the key created. | `keyVaultKey.id` |

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "keyVaultName": {
            "value": "cu8-lnd1-d-euwe-kvt-des"
        },
        "keyVaultKeyEnabled": {
            "value": true
        },
        "keyVaultKeyName": {
            "value": "testkey"
        },
        "keyVaultKeySize": {
            "value": 2048
        },
        "keyVaultKeyType": {
            "value": "RSA"
        },
        "keyVaultKeyRotationPolicy": {
            "lifetimeActions": [
                {
                    "trigger": {
                        "timeAfterCreate": "P80D"
                    },
                    "action": {
                        "type": "rotate"
                    }
                },
                {
                    "trigger": {
                        "timeBeforeExpiry": "P10D"
                    },
                    "action": {
                        "type": "notify"
                    }
                }
            ],
            "attributes": {
                "expiryTime": "P3M"
            }
        }
    }
}
```