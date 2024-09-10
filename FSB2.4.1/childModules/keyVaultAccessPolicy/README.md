# childModules/keyVaultAccessPolicy/keyVaultAccessPolicy.bicep
Bicep module to create an Azure KeyVault access policy.

## Module Features
Key vault module builds the key vaults, but it has a limitation as far as access policy is concerned. The keyvault module requires access policy to be passed when creating the keyvault. This causes an issue if we need to assign the access policy to a resource which needs to be created after the key vault. This module will solve this issue.

The module can be used for the below
1. Add access policy to a key vault
1. Remove the access polciy in the key vault
1. Update an access policy in the key vault


**P.S. : This bicep module cannot be used to remove the user or account running this module to remove itself.**

## Parent Module Example Use
```bicep
module keyVault '../../childModules/keyVaultAccessPolicy/keyVaultAccessPolicy.bicep' = {
  scope: resourceGroup(deployresourceGroup)
  name: 'keyVaultAccessPolicy-deployment'
  params: {
    keyVaultName: keyVaultName
    accessPoliciesAdd: accessPoliciesAdd
    accessPoliciesRemove: accessPoliciesRemove
    accessPoliciesUpdate: accessPoliciesUpdate
  }
}
```

## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `keyVaultName` | `string` | true | Specifies the name of the key vault for which the access policy needs to be added, modifed or removed. |
| `accessPoliciesAdd` | `array` | false | Array of AccessPolicies to be created for the KeyVault. Additional Details [here](#array---accesspoliciesadd-accesspoliciesupdate).|
| `accessPoliciesRemove`  | `array` | false | Array of objectid to be deleted needs to be passed.  Additional Details [here](#array---accesspoliciesremove).|
| `accessPoliciesUpdate` | `array` | false | Array of AccessPolicies to be update for the KeyVault.  Additional Details [here](#array---accesspoliciesadd-accesspoliciesupdate).|

### Array - accessPoliciesAdd, accessPoliciesUpdate
| Name | Type  | Description |
| --- | --- | --- | 
| `objectId` | `GUID`|The object id (principal id) of the application or user in the Azure Tenant|
|  `permissions` | `object`|The permissions needed for the object id on the Key vault. Additional Details [here](#object---accesspoliciesadd-accesspoliciesupdate--permissions). |

### Array - accessPoliciesRemove
 Name | Type  | Description |
| --- | --- | --- | 
| `objectId` | `GUID`|The object id (principal id) of the application or user in the Azure Tenant|

#### Object - accessPoliciesAdd, accessPoliciesUpdate-> permissions
 Name | Type  | Description |
| --- | --- | --- | 
| `keys` | `array`|The type of permissions needed on the key settings. The accepted values are <ul><li>Get</li><li>List</li><li>Update</li><li>Create</li><li>Import</li><li>Delete</li><li>Recover</li><li>Backup</li><li>Restore</li><li>GetRotationPolicy</li><li>SetRotationPolicy</li><li>Rotate</li><li>GetRotationPolicy</li><li>SetRotationPolicy</li></ul>|
| `secrets` | `array`| The type of permissions needed on the secrets settings. The accepted values are <ul><li>Get</li><li>List</li><li>Set</li><li>Delete</li><li>Recover</li><li>Backup</li><li>Restore</li><li>Purge</li></ul>|
| `certificates` | `array`|The type of permissions needed on the certificates settings. The accepted values are  <ul><li>Get</li><li>List</li><li>Update</li><li>Create</li><li>Import</li><li>Delete</li><li>Recover</li><li>Backup</li><li>Restore</li><li>ManageContacts</li><li>ManageIssuers</li><li>GetIssuers</li><li>ListIssuers</li><li>SetIssuers</li><li>DeleteIssuers</li><li>Purge" </li></ul>|

## Module outputs
NA

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "keyVaultName": {
            "value": "cu1-sub1-d-kvt-001"
        },
        "accessPoliciesAdd": {
            "value": [
                {
                    "objectId": "746672be-5081-4ad5-a7a2-405ce95b8e09",
                    "permissions": {
                        "keys": [
                            "Get",
                            "List"
                        ],
                        "secrets": [
                            "Get"
                        ],
                        "certificates": [
                            "Get"
                        ]
                    }
                }
            ]
        },
        "accessPoliciesRemove": {
            "value": [
                {
                    "objectId": "cb8ac6ae-e266-48c8-9758-f2dae9e49d9c"
                }
            ]
        },
        "accessPoliciesUpdate": {
            "value": [
                {
                    "objectId": "8fad8337-b903-4946-872b-a5d1538c941d",
                    "permissions": {
                        "keys": [
                            "Get",
                            "List"
                        ],
                        "secrets": [
                            "Get",
                            "List",
                            "Set",
                            "Delete",
                            "Recover",
                            "Backup",
                            "Restore",
                            "Purge"
                        ],
                        "certificates": []
                    }
                }
            ]
        }
    }
}
```