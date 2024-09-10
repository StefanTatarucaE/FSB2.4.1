# policy/storageAccountRoleAssignmentChange/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy definition & 1 policy assignment.

This policy will assign the Storage Account Key Operator Service Role (81a9662b-bebf-436f-a333-f67b29880f12) to the Microsoft Key Vault Enterprise Application for storage accounts tagged with `EvidenManaged = True` and `EvidenStorageAccountKeyRotation = True`.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/storageAccountRoleAssignmentChange/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    keyVaultAppObjectId: '9c448bb3-fcfb-44be-8a74-f8c71939ff6e'
    storageAccountRoleAssignmentChangePolicyName: 'sstorage-roleassg-change-policy-def'
    storageAccountRoleAssignmentChangePolicyDisplayName: 'Storage account role assignment change policy definition'
    storageAccountRoleAssignmentChangePolicyAssignmentName: 'storage-roleassg-change-policy-def-assignment'
    storageAccountRoleAssignmentChangePolicyAssignmentDisplayName: 'Storage account role assignment change policy definition assignment'
    policyMetadata:'EvidenELZ'
    policyRuleTag:[
      EvidenManaged
      EvidenStorageAccountKeyRotation
    ]
  }

```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `keyVaultAppObjectId` | `string` | true | Specify the Object id assigned to the tenant's Microsoft Key Vault Enterprise Application. |
| `storageAccountRoleAssignmentChangePolicyName` | `string` | true | Specify the name for storage account role assignment change policy. |
| `storageAccountRoleAssignmentChangePolicyDisplayName` | `string` | true | Specify the display name for storage account role assignment change policy. |
| `storageAccountRoleAssignmentChangePolicyAssignmentName` | `string` | true | Specify the name for the assignment of storage account role assignment change policy. |
| `storageAccountRoleAssignmentChangePolicyAssignmentDisplayName` | `string` | true | Specify the display name for the assignment of storage account role assignment change policy. |
| `policyMetadata` | `string` | true | Specify the metadata source value required for billing and monitoring. |
| `policyRuleTag` | `array` | true | Tag used for the policy rule. |


## Module Outputs
None.

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "policyMetaData": {
      "value": "EvidenELZ"
    },
    "keyVaultAppObjectId": {
      "value": "9c448bb3-fcfb-44be-8a74-f8c71939ff6e"
    },
    "storageAccountRoleAssignmentChangePolicyName": {
      "value": "storage-roleassg-change-policy-def"
    },
    "storageAccountRoleAssignmentChangePolicyDisplayName": {
      "value": "Storage account role assignment change policy definition"
    },
    "storageAccountRoleAssignmentChangePolicyAssignmentName": {
      "value": "storage-roleassg-change-policy-def-assignment"
    },
    "storageAccountRoleAssignmentChangePolicyAssignmentDisplayName": {
      "value": "Storage account role assignment change policy definition assignment"
    },
    "policyRuleTag": {
      "value": [
        "EvidenManaged",
        "EvidenStorageAccountKeyRotation"
      ]
    }
  }
}
```