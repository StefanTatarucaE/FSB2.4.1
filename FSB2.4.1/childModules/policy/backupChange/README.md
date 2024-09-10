# policy/backupChange/backupChange.bicep

Bicep module to create Azure policy resource.
## Module Features

This module deploys policy definition, policy assignment and role assignments for each backup schedule (from Recovery Services Vault) defined in the parameter file.

This policy will enable Backup if the VM has the required tags.
In order to enable backup in a reovery services vault in the same location as the VM, the following tags needs to be present on the VM:

| Tag Name | Tag Value |
| --- | --- |
| EvidenManaged | true |
| EvidenBackup | <name of the Backup Schedule from the Recovery Services Vault (customizable from parameter file)> |

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/roleAssignments` (via roleAssignment module) | [2020-10-01-preview](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2020-10-01-preview/roleassignments) |

## Module Example Use

```bicep
module backupPolicy '../../childModules/policy/backupChange/backupChange.bicep' =  {
  name: 'policy-deployment'
  params: {
    backupTagName: 'EvidenBackup'
    managedTagName: 'EvidenManaged'
    policyMetadata:policyMeteringTag
    backupPolicyConfigurations: {
        list: [
                    {
                        backupTagNamePrefix: 'Bronze'
                    },
                    {
                        backupTagNamePrefix: 'Silver'
                    },
                    {
                        backupTagNamePrefix: 'Gold'
                    }
                ]
    }
    vaultLocation: recoveryServicesVault.outputs.vaultLocation
    vaultId: recoveryServicesVault.outputs.vaultID
    backupDefAssignmentName: 'sub1-d-policyAssignment'
    backupDefName: 'sub1-d-policyDefinition'
  }
}
```
## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `backupTagName` | `string` | true | Name of the backup tag for which the DINE policy will kick in and enable backup for the tagged VM. Example: EvidenBackup |
| `managedTagName` | `string` | true | Name of the Eviden Managed tag for which the DINE policy will kick in and enable backup for the tagged VM. Example: EvidenManaged |
| `backupPolicyConfigurations` | `object` | true | A JSON structure used to specify the backup policy configuration. When used in a parent module, this will be the same parameter used by the RecoveryServicesVault Module.  Additional Details [here](#object---backuppolicyconfigurations). |
| `vaultLocation` | `string` | true | Specify the location of the VMs that you want to protect. VMs will be backed up to a vault in the same location. |
| `vaultId` | `string` | true | Provide the Recovery Services Vault ID |
| `backupDefAssignmentName` | `string` | true | Name of the policy assignment that will be generated from the Naming module |
| `backupDefName` | `string` | true | Name of the policy definition that will be generated from the Naming module |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

### Object - backupPolicyConfigurations

| Name | Type | Description |
| --- | --- | --- |
| `list` | `array` | Array of Backup Policies. Each element needs to contain 'backupTagNamePrefix' and the value as a string. The string value must match the name of the each Backup Policy of the Recovery Services vault.  Additional Details [here](#array---list).|

#### Array - list

`"key"`:`"value"`

**Example:**
```json
"list": [
          {
              "backupTagNamePrefix": "Bronze"
          },
          {
              "backupTagNamePrefix": "Silver"
          },
          {
              "backupTagNamePrefix": "Gold"
          }
        ]
```

## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "backupDefName": {
            "value": "sub1-d-policyDefinition"
        },
        "backupDefAssignmentName": {
            "value": "sub1-d-policyAssignment"
        },
        "backupTagName": {
            "value": "EvidenBackup"
        },
        "managedTagName": {
            "value": "EvidenManaged"
        },
         "policyMetadata": {
            "value": "EvidenELZ"
        },
        "backupPolicyConfigurations": {
            "value": {
                "list": [
                    {
                        "backupTagNamePrefix": "Bronze"
                    },
                    {
                        "backupTagNamePrefix": "Silver"
                    },
                    {
                        "backupTagNamePrefix": "Gold"
                    }
                ]
            }
        },
        "vaultLocation": {
            "value": "westeruope"
        },
        "vaultId": {
            "value": ""
        }
    }
}
```
