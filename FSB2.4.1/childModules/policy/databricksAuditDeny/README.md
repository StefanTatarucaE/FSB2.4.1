# policy/databricksAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy set definition and 1 policy assignment.

This policy set will audit or deny the creation of Azure Databricks resources. Does not apply to resource groups.

The following built-in policies are included:

- Azure Databricks Workspaces should disable public network access
- Clusters that are part of Azure Databricks Workspaces should disable public IP
- Resource logs in Azure Databricks Workspace should be enabled

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/databricksAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    databricksSettings:{
        disablePublicNetworkAccessEffect: 'Audit'
        disablePublicIpEffect: 'Audit'
        enableWorkspaceResourceLogsEffect: 'AuditIfNotExists'
  }
    databricksAuditDenySetName : 'databricks.auditdeny.policy.set'
    databricksAuditDenySetDisplayName : 'Databricks auditdeny policy set'
    databricksAuditDenySetAssignmentName : 'databricks.auditdeny.policy.set.assignment'
    databricksAuditDenySetAssignmentDisplayName : 'Databricks auditdeny policy set assignment'
    policyMetadata : 'EvidenELZ'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `databricksSettings` | `object` | true | Object which sets the values of the policy set definition parameters. The specific parameters & what they are for, are described in the `policySetDefinition` resource block.  Additional Details [here](#object---databricksSettings).|
| `databricksAuditDenySetName` | `string` | true | Specifies the policy set name for Databricks audit deny initiative. |
| `databricksAuditDenySetDisplayName` | `string` | true | Specifies the policy set display name for Databricks audit deny initiative. |
| `databricksAuditDenySetAssignmentName` | `string` | true | Specifies the policy set assignment name for Databricks audit deny initiative. |
| `databricksAuditDenySetAssignmentDisplayName` | `string` | true | Specifies the policy set assignment displayname for Databricks audit deny initiative. |
| `policyMetadata` | `string` | true | Specifies metadata source value required for billing and monitoring. |


### Object - databricksSettings
| Name | Type | Description |
| --- | --- | --- |
| `disablePublicNetworkAccessEffect` | `string` | Azure Databricks Workspaces should have public network access disabled. More at: https://docs.microsoft.com/azure/databricks/administration-guide/cloud-configurations/azure/vnet-inject. Allowed values: Audit, Deny, Disabled |
| `disablePublicIpEffect` | `string` | Clusters part of Azure Databricks Workspaces should have public IP disabled. More at: https://learn.microsoft.com/azure/databricks/security/secure-cluster-connectivity. Allowed values: Audit, Deny, Disabled |
| `enableWorkspaceResourceLogsEffect` | `string` | Check if resource logs are enabled for Databricks. Allowed values: AuditIfNotExists, Disabled |

## Module Outputs
None.


## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "databricksSettings": {
      "value": {
        "disablePublicNetworkAccessEffect": "Audit",
        "disablePublicIpEffect": "Audit",
        "enableWorkspaceResourceLogsEffect": "AuditIfNotExists"
      }
    },
    "databricksAuditDenySetName": {
      "value": "databricks.auditdeny.policy.set"
    },
    "databricksAuditDenySetDisplayName": {
      "value": "Databricks auditdeny policy set"
    },
    "databricksAuditDenySetAssignmentName": {
      "value": "databricks.auditdeny.policy.set.assignment"
    },
    "databricksAuditDenySetAssignmentDisplayName": {
      "value": "Databricks auditdeny policy set assignment"
    },
    "policyMetadata": {
        "value": "EvidenELZ"
    }
  }
}
```

