# policy/iso27001AuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy assignment.

It deploys the ISO 27001 policy definition set.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyAssignments@2021-06-01` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/iso27001AuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    iso27001AuditDenySetAssignmentName : 'iso27001.auditdeny.policy.set'
    iso27001AuditDenySetAssignmentDisplayName 'ISO 27001 auditdeny policy set'
    isoPolicyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/89c6cddc-1c73-4ac1-b19c-54d1a15a42f2'
    policyMetadata : 'EvidenELZ'
    iso27000Settings: iso27001Settings
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
|`iso27001AuditDenySetAssignmentName` | `string` | true | Specify policy set Assignment name for iso 27001 Audit Deny |
|`iso27001AuditDenySetAssignmentDisplayName` | `string` | true | Specify policy set Assignment display name for iso 27001 Audit Deny |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |
| `isoPolicyDefinitionId` | `string` | true | Specify the policy definition id of the built-in ISO Initiative. |

### Object - isoSettings
| Name | Type | Description |
| --- | --- | --- |
| `includeArcMachines` | `String` | Include Arc connected servers for Guest Configuration policies or not. Allowed Values: true; false. |
| `listOfResourceTypesWithDiagnosticLogsEnabled` | `string[]` | List of resource types that should have resource logs enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `includeMetricsDiagnosticLogging` | `Boolean` | Include metrics when auditing diagnostic logging settings. Allowed Values: true, false. |
| `includeLogsDiagnosticLogging` | `Boolean` | Include metrics when auditing diagnostic logging settings. Allowed Values: true, false. |

## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "iso27001AuditDenySettings": {
            "value": {
                "includeArcMachines": "false",
                "resourceTypesWithDiagnosticLogs": [
                    "Microsoft.AnalysisServices/servers",
                    "Microsoft.ApiManagement/service",
                    "Microsoft.Network/applicationGateways",
                    "Microsoft.Automation/automationAccounts",
                    "Microsoft.ContainerInstance/containerGroups",
                    "Microsoft.ContainerRegistry/registries",
                    "Microsoft.ContainerService/managedClusters",
                    "Microsoft.Batch/batchAccounts",
                    "Microsoft.Cdn/profiles/endpoints",
                    "Microsoft.CognitiveServices/accounts",
                    "Microsoft.DocumentDB/databaseAccounts",
                    "Microsoft.DataFactory/factories",
                    "Microsoft.DataLakeAnalytics/accounts",
                    "Microsoft.DataLakeStore/accounts",
                    "Microsoft.EventGrid/topics",
                    "Microsoft.EventHub/namespaces",
                    "Microsoft.Network/expressRouteCircuits",
                    "Microsoft.Network/azureFirewalls",
                    "Microsoft.HDInsight/clusters",
                    "Microsoft.Devices/IotHubs",
                    "Microsoft.KeyVault/vaults",
                    "Microsoft.Network/loadBalancers",
                    "Microsoft.Logic/integrationAccounts",
                    "Microsoft.Logic/workflows",
                    "Microsoft.DBforMySQL/servers",
                    "Microsoft.Network/networkInterfaces",
                    "Microsoft.Network/networkSecurityGroups",
                    "Microsoft.DBforPostgreSQL/servers",
                    "Microsoft.PowerBIDedicated/capacities",
                    "Microsoft.Network/publicIPAddresses",
                    "Microsoft.RecoveryServices/vaults",
                    "Microsoft.Cache/redis",
                    "Microsoft.Relay/namespaces",
                    "Microsoft.Search/searchServices",
                    "Microsoft.ServiceBus/namespaces",
                    "Microsoft.SignalRService/SignalR",
                    "Microsoft.Sql/servers/databases",
                    "Microsoft.Sql/servers/elasticPools",
                    "Microsoft.StreamAnalytics/streamingjobs",
                    "Microsoft.TimeSeriesInsights/environments",
                    "Microsoft.Network/trafficManagerProfiles",
                    "Microsoft.Compute/virtualMachines",
                    "Microsoft.Compute/virtualMachineScaleSets",
                    "Microsoft.Network/virtualNetworks",
                    "Microsoft.Network/virtualNetworkGateways"
                ]
            }
        },
        "iso27001AuditDenySetAssignmentName": {
            "value": "iso27001.auditdeny.policy.set"
        },
        "iso27001AuditDenySetAssignmentDisplayName": {
            "value": "ISO 27001 auditdeny policy set"
        },
        "isoPolicyDefinitionId": {
            "value": "/providers/Microsoft.Authorization/policySetDefinitions/89c6cddc-1c73-4ac1-b19c-54d1a15a42f2"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```