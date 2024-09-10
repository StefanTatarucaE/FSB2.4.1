# policy/blockLogAnalyticsAgentAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy definition and 1 policy assignment.

This policy will audit/deny the existence of the legacy log analytics monitoring agent on Windows and Linux Virtual Machines and Scale Sets.
It will be used as part of the migration process from the old Microsoft monitoring agent (MMA) to the new Azure monitoring agent (AMA).

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/blockLogAnalyticsAgentAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    blockLogAnalyticsAgentDefEffect: 'Deny'
    blockLogAnalyticsAgentDefName: 'blockloganalyticsagent.auditdeny.policy.def'
    blockLogAnalyticsAgentDefDisplayName: 'Prevent Log Analytics monitoring agent extension on all Virtual Machines auditdeny policy definition'
    blockLogAnalyticsAgentDefAssignmentName: 'blockloganalyticsagent.auditdeny.policy.def.assignment'
    blockLogAnalyticsAgentDefAssignmentDisplayName: 'Prevent Log Analytics monitoring agent extension on all Virtual Machines auditdeny policy definitionassignment'
    policyMetadata : 'EvidenELZ'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `blockLogAnalyticsAgentDefEffect` | `string` | true | Set the policy effect when the policy rule evaluates to true. Possible values Audit, Deny or Disable. |
| `blockLogAnalyticsAgentDefName` | `string` | true | Specify policy definition name for block Loganalytics Agent Audit Deny. |
| `blockLogAnalyticsAgentDefDisplayName` | `string` | true | Specify policy displayname for block Loganalytics Agent Audit Deny. |
| `blockLogAnalyticsAgentDefAssignmentName` | `string` | true | Specify policy assignment name for block Loganalytics Agent Audit Deny. |
| `blockLogAnalyticsAgentDefAssignmentDisplayName` | `string` | true | Specify policy assignment displayname for block Loganalytics Agent Audit Deny. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "blockLogAnalyticsAgentDefEffect": {
            "value": "Audit"
        },
        "blockLogAnalyticsAgentDefName": {
            "value": "blockloganalyticsagent.auditdeny.policy.def"
        },
        "blockLogAnalyticsAgentDefDisplayName": {
            "value": "Prevent Log Analytics monitoring agent extension on all Virtual Machines auditdeny policy definition"
        },
        "blockLogAnalyticsAgentDefAssignmentName": {
            "value": "blockloganalyticsagent.auditdeny.policy.def.assignment"
        },
        "blockLogAnalyticsAgentDefAssignmentDisplayName": {
            "value": "Prevent Log Analytics monitoring agent extension on all Virtual Machines auditdeny policy definitionassignment"
        },
        "policyMetadata": {
           "value": "EvidenELZ"
        }
    }
}
```
