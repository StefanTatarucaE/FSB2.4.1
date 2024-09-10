# childModules/diskEncryptionSet/diskEncryptionSet.bicep <!-- omit in toc -->

This Bicep module deploys Disk Encryption Sets.

Disk Encryption Sets are used for server-side encryption of Azure Disk Storage. 
The Disk Encryption Set contains a reference to an Azure Key Vault and RSA key (stored in the key vault).
The RSA key is used for encryption and decryption of Azure managed disks.

## Navigation <!-- omit in toc -->

- [Resource types](#resource-types)
- [Parameters](#parameters)
  - [Required parameters](#required-parameters)
  - [Parameter usage: `tags`](#parameter-usage-tags)
- [Outputs](#outputs)
- [Deployment example](#deployment-example)
- [Notes](#notes)
  
## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Compute/diskEncryptionSets` | [2022-03-02](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Compute/2022-03-02/diskEncryptionSets) |

## Parameters

### Required parameters

|  Name | Type | Description |
| :-- | :-- | :-- |
| `diskEncryptionSetName` | `string` | Specifies the name of the Disk Encryption Set. |
| `location` | `string` | The Azure region of the Disk Encryption Set. Must be in the same region as where the key vault is deployed. |
| `keyVaultName` | `string` | Specifies name for existing key vault, must be unique across Azure. |
| `keyName` | `string` | Name of key in existing key vault, key itself must be existing as well. |
| `keyRotationEnabled` | `bool` | Enable automatic key rotation for the disk encryption set customer-managed key. |
| `tags` | `object` | A mapping of tags to assign to the resource. |

### Parameter usage: `tags`

Tag names and tag values can be provided as needed. A tag can be left without a value.

<details>

<summary>Parameter JSON format</summary>

```json
"tags": {
    "value": {
        "Environment": "Test",
        "Contact": "sample.user@custcompany.net",
        "CostCenter": "8844",
        "ServiceName": "BackendServiceXYZ",
        "Role": "BackendXYZ"
    }
}
```

</details>

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `diskEncryptionSetId` | string | Resource ID of created disk encryption set. |
| `diskEncryptionSetName` | string | Name of created disk encryption set. |
| `diskEncryptionSetPrincipalId` | string | Principal ID (or Object ID) of created disk encryption set. Needed in key vault access policy.|

## Deployment example

<p>
<details>

<summary>via Bicep module</summary>

```bicep
module diskEncryptionSet '../../childModules/diskEncryptionSet/diskEncryptionSet.bicep' = {
  scope: exampleResourceGroup
  name: 'diskEncryptionSet-deployment'
  location: 'westeurope'
  params: {
    diskEncryptionSetName: 'aaa-lnd1-d-des-euwe'
    location: 'westeurope'
    keyVaultName: 'aaa-lnd1-d-kvt-euwe-des'
    keyName: 'dcs-sse-cmk-euwe'
    keyRotationEnabled: false
    tags: {
      Environment: 'Test'
      Contact: 'sample.user@custcompany.net'
      CostCenter: '8844'
      ServiceName: 'BackendServiceXYZ'
      Role: 'BackendXYZ'
    }
  }
}
```

</details>
</p>

## Notes

This childModules/diskEncryptionSet/diskEncryptionSet.bicep needs a few modifications to unify it to the rest of the codebase.

- Identity type is hardcoded to SystemAssigned in the resource block without a comment.
- Outputs are missing descriptions.
