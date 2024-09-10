# policy/rsgNameConventionAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy definition & 1 policy assignment.

This policy will audit if Resource Groups are named using the naming convention or not.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/rsgNameConventionAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    policyEffect: 'Audit'
    rsgNameConventionsAuditDenyDefName : 'nameconvention.auditdeny.policy.def'
    rsgNameConventionsAuditDenyDefDisplayName : 'Audit Resource Group naming convention'
    rsgNameConventionsAuditDenyDefAssignmentName : 'nameconvention.auditdeny.policy.def.assignment'
    rsgNameConventionsAuditDenyDefAssignmentDisplayName : 'Name convention auditdeny policy definition assignment'
    policyMetadata : 'EvidenELZ'
    }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `policyEffect` | `string` | true | Set the policy effect when the policy rule evaluates to true Possible values Audit, Deny or Disable. |
| `rsgNameConventionsAuditDenyDefName` | `string` | true | Policy name for RsgName convention Audit Deny |
| `rsgNameConventionsAuditDenyDefDisplayName` | `string` | true | Policy display name for RsgName convention Audit Deny |
| `rsgNameConventionsAuditDenyDefAssignmentName` | `string` | true | Policy assignment name for RsgName convention Audit Deny |
| `rsgNameConventionsAuditDenyDefAssignmentDisplayName` | `string` | true | Policy assignment display name for RsgName convention Audit Deny |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |


## Module Outputs
None.

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "policyEffect": {
      "value": "Audit"
    },
    "rsgNameConventionsAuditDenyDefName" : {
      "value": "nameconvention.auditdeny.policy.def"
    },
    "rsgNameConventionsAuditDenyDefDisplayName" : {
      "value": "Audit Resource Group naming convention"
    },
    "rsgNameConventionsAuditDenyDefAssignmentName" : {
      "value": "nameconvention.auditdeny.policy.def.assignment"
    },
    "rsgNameConventionsAuditDenyDefAssignmentDisplayName" : {
      "value": "Name convention auditdeny policy definition assignment"
    },
    "policyMetadata": {
      "value": "EvidenELZ"
    }
  }
}
```