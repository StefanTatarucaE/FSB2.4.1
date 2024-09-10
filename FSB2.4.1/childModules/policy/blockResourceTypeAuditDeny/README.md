# policy/blockResourceTypeAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy assignment.

It disallows Resource Types in the environment, which can be provided via a parameter.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyAssignments@2021-06-01` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/blockResourceTypeAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    resourceTypesNotAllowed: [
      'Microsoft.Compute/snapshots'
      'Microsoft.DesktopVirtualization/hostpools'
    ]
    blockResourceTypeAuditDenyDefAssignmentName : 'blockresourcetype.auditdeny.policy.def.assignment'
    blockResourceTypeAuditDenyDefAssignmentDisplayName : 'Block resource type audit deny policy definition'
    policyMetadata : 'EvidenELZ'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `resourceTypesNotAllowed` | `string[]` | true | The list of Resource Types that are not allowed in the environment. |
| `blockResourceTypeAuditDenyDefAssignmentName` | `String` | true | Policy assignment name for Block Resource Type Change |
| `blockResourceTypeAuditDenyDefAssignmentDisplayName` | `String` | true | Policy assignment display name for Block Resource Type Change |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "resourceTypesNotAllowed": {
            "value": [
                "Microsoft.Compute/snapshots",
                "Microsoft.DesktopVirtualization/hostpools"
            ]
        },
        "blockResourceTypeAuditDenyDefAssignmentName" : {
            "value": "blockresourcetype.auditdeny.policy.def.assignment"
        },
        "blockResourceTypeAuditDenyDefAssignmentDisplayName" : {
            "value": "Block resource type audit deny policy definition"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```
