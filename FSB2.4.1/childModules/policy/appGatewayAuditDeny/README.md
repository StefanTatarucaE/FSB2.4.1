# policy/appGatewayAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy set definition & 1 policy assignment.

This policy configures governance and security policies for the Azure Application Gateway.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/appGatewayAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    policyMetadata:'EvidenELZ'
    wafEnableEffect: 'Audit'
    wafModeEffect: 'Audit'
    modeRequirement: 'Detection'
    appGatewayAuditDenySetName: 'appgateway.auditdeny.policy.set'
    appGatewayAuditDenySetDisplayName: 'Application gateway auditdeny policy set'
    appGatewayAuditDenySetAssignmentName: 'appgateway.auditdeny.policy.set.assignment'
    appGatewayAuditDenySetAssignmentDisplayName: 'Application gateway auditdeny policy set assignment'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `wafEnableEffect` | `string` | true | Set the policy effect for when the policy rule evaluates to true.
Policy rule: Web Application Firewall (WAF) should be enabled for Application Gateway.|
| `wafModeEffect` | `string` | true | Set the policy effect when the policy rule evaluates to true. Policy rule: Web Application Firewall (WAF) should use the specified mode for Application Gateway.  |
| `modeRequirement` | `string` | true | Mode required for all WAF policies. |
| `appGatewayAuditDenySetName` | `string` | true | Specify set name for Application Gateway audit deny initiative. |
| `appGatewayAuditDenySetDisplayName` | `string` | true | Specify set displayname for Application Gateway audit deny initiative. |
| `appGatewayAuditDenySetAssignmentName` | `string` | true | Specify set assignment name for Application Gateway audit deny initiative. |
| `appGatewayAuditDenySetAssignmentDisplayName` | `string` | true | Specify set assignment displayname for Application Gateway audit deny initiative. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |


## Module Outputs

None.

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "wafEnableEffect": {
      "value": "Audit"
    },
    "wafModeEffect": {
      "value": "Audit"
    },
    "appGatewayAuditDenySetName": {
      "value": "appgateway.auditdeny.policy.set"
    },
    "appGatewayAuditDenySetDisplayName": {
      "value": "Application gateway auditdeny policy set"
    },
    "appGatewayAuditDenySetAssignmentName": {
      "value": "appgateway.auditdeny.policy.set.assignment"
    },
    "appGatewayAuditDenySetAssignmentDisplayName": {
      "value": "Application gateway auditdeny policy set assignment"
    },
    "modeRequirement": {
      "value": "Detection"
    },
    "policyMetadata": {
      "value": "EvidenELZ"
    }
  }
}
```