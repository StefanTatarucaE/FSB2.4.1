# policy/auditTagAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy definition, 1 policy assignment & 1 role assignment.

This policy will audit the existence of a tag on a resource. Does not apply to resource groups.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/tagAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    tagName: 'exampleTag'
    policyEffect: 'Audit'
    tagAuditDenyDefName: 'tag.auditdeny.policy.def'
    tagAuditDenyDefDisplayName: 'Tag auditdeny policy definition'
    tagAuditDenyDefAssignmentName: 'tag.auditdeny.policy.def.assignment'
    tagAuditDenyDefAssignmentDisplayName: 'Tag auditdeny policy definition'
    policyMetadata : 'EvidenELZ'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `tagName` | `string` | true | Set the tag name to be audited (checked if set) on resources. |
| `policyEffect` | `string` | true | Set the policy effect when the policy rule evaluates to true. Possible values Audit, Deny or Disable. |
| `tagAuditDenyDefName` | `string` | true | Specify policy definition name for Tag Audit Deny. |
| `tagAuditDenyDefDisplayName` | `string` | true | Specify policy displayname for Tag Audit Deny. |
| `tagAuditDenyDefAssignmentName` | `string` | true | Specify policy assignment name for Tag Audit Deny. |
| `tagAuditDenyDefAssignmentDisplayName` | `string` | true | Specify policy assignment displayname for Tag Audit Deny. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |


## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "tagName": {
            "value": "EvidenManaged"
        },
        "policyEffect": {
            "value": "Audit"
        },
        "tagAuditDenyDefName": {
            "value": "tag.auditdeny.policy.def"
        },
        "tagAuditDenyDefDisplayName": {
            "value": "Tag auditdeny policy definition"
        },
        "tagAuditDenyDefAssignmentName": {
            "value": "tag.auditdeny.policy.def.assignment"
        },
        "tagAuditDenyDefAssignmentDisplayName": {
            "value": "Tag auditdeny policy definition"
        },
        "policyMetadata": {
           "value": "EvidenELZ"
        }
    }
}
```
