# childModules/keyVault/keyvault.bicep
Bicep module to create an Azure KeyVault.

## Module Features
Deploys an Azure Key Vault resource and associated access policies if required.

Allows deployment with the following features enabled or disabled:
- enabledForDeployment
- enabledForDiskEncryption
- enabledForTemplateDeployment
- enablePurgeProtection
- enableRbacAuthorization
- enableSoftDelete

## Parent Module Example Use
```bicep
module keyVault '../../childModules/keyVault/keyVault.bicep' = {
  scope: resourceGroup(deployresourceGroup)
  name: 'keyVault-deployment'
  params: {
    keyVaultName: keyVaultName
    location: location
    skuName: skuName
    tags: tags
    keyVaultFeatures: keyVaultFeatures
    networkRuleAction: networkRuleAction
    publicNetworkAccess: publicNetworkAccess
    networkRuleBypassOptions: networkRuleBypassOptions
    softDeleteRetentionInDays: softDeleteRetentionInDays
  }
}
```

## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `keyVaultName` | `string` | true | Specifies the name of the Key Vault. |
| `location` | `string` | true | Specifies the location to deploy the Key Vault. |
| `skuName` | `string` | true | Specifies the SKU details of the Key Vault. premium/standard. |
| `tags`| `object` | true | Specifies the tags to be assigned to the Key Vault resource.  Additional Details [here](#object---tags).|
| `keyVaultFeatures` | `object` | true | Features to be enabled or disabled for the keyvault.  Additional Details [here](#object---keyvaultfeatures).|
| `publicNetworkAccess` | `string` | true | Specifies whether the Key Vault will accept traffic from public internet. If set to disabled it overrides all firewall rules, allowing only private endpoint and trusted services traffic. |
| `softDeleteRetentionInDays` | `int` | true | Number of retention days for soft delete, if the Soft Delete feature is enabled. Ignored if Soft Delete is not enabled. |
| `networkRuleBypassOptions` | `string` | true | Specifies what traffic can bypass the network rules. This can be AzureServices (default if not specified) or None. |
| `networkRuleAction` | `string` | true | The default action when no rule from ipRules and from virtualNetworkRules match. Evaluated after the networkRuleBypassOptions is evaluated. |

### Object - tags
Below is an example of the tags object

`"key"`:`"value"`

**Example:**
```json
{
    "EvidenManaged": "true",
    "Project": "Monitoring Parent Module",
    "ManagedBy": "AzureBicep"
}
```

### Object - keyVaultFeatures
 Name | Type  | Description |
| --- | --- | --- |
| `enabledForDeployment` | `bool`|Property to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.|
| `enabledForDiskEncryption` | `bool`|Property to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.|
| `enabledForTemplateDeployment` | `bool`|Property to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault.|
| `enablePurgeProtection` | `bool`|Property specifying whether protection against purge is enabled for this vault. Setting this property to true activates protection against purge for this vault and its content - only the Key Vault service may initiate a hard, irrecoverable deletion. The setting is effective only if soft delete is also enabled. Enabling this functionality is irreversible - that is, the property does not accept false as its value.|
| `enableRbacAuthorization` | `bool`|Property that controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, and the access policies specified in vault properties will be ignored. When false, the key vault will use the access policies specified in vault properties, and any policy stored on Azure Resource Manager will be ignored. If null or not specified, the vault is created with the default value of false. Note that management actions are always authorized with RBAC.|
| `enableSoftDelete` | `bool`|Property to specify whether the 'soft delete' functionality is enabled for this key vault. If it's not set to any value(true or false) when creating new key vault, it will be set to true by default. Once set to true, it cannot be reverted to false.|

## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `keyVaultResourceId` | The resource ID of the created Key Vault. | `keyVault.id` |
| `keyVaultName` | The name of the created keyVault. | `keyVault.name` |

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "keyVaultName": {
            "value": "cu6-cnty-q-keyvault"
        },
        "location": {
            "value": "westeurope"
        },
        "skuName": {
            "value": "standard"
        },
        "tags": {
            "value": {
                "EvidenManaged": "true"
            }
        },
        "keyVaultFeatures": {
            "value": {
                "enabledForDeployment": false,
                "enabledForDiskEncryption": false,
                "enabledForTemplateDeployment": false,
                "enablePurgeProtection": true,
                "enableRbacAuthorization": false,
                "enableSoftDelete": false
            }
        },
        "softDeleteRetentionInDays": {
            "value": 7
        },
        "publicNetworkAccess": {
            "value": "enabled"
        },
        "networkRuleBypassOptions": {
            "value": "AzureServices"
        },
        "networkRuleAction": {
            "value": "Allow"
        }
    }
}
```