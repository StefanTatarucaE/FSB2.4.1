# policy/pci/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy assignment.

It deploys the PCI policy definition set.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyAssignments@2021-06-01` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/pciAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    pciAuditDenySetAssignmentName: 'pci.auditdeny.policy.set.assignment'
    pciAuditDenySetAssignmentDisplayName: 'PCI 4 auditdeny policy set assignment'
    pciPolicyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/496eeda9-8f2f-4d5e-8dfd-204f0a92ed41'
    policyMetadata : 'EvidenELZ'
    pciSettings: pciSettings
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `pciAuditDenySetAssignmentName` | `string` | true | The name to be used to create the policy assignment. |
| `pciAuditDenySetAssignmentDisplayName` | `string` | true | The display name for the assignment. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |
| `pciPolicyDefinitionId` | `string` | true | Specify the policy definition id of the built-in PCI Initiative. |

### Object - pciSettings
| Name | Type | Description |
| --- | --- | --- |
| `includeArcMachines` | `String` | Include Arc connected servers for Guest Configuration policies or not. Allowed Values: true; false. |
| `listOfResourceTypesWithDiagnosticLogsEnabled` | `string[]` | List of resource types that should have resource logs enabled. Allowed Values: AuditIfNotExists; Disabled. |

## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "pciAuditDenySettings": {
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
        "pciAuditDenySetAssignmentName": {
            "value": "pci.auditdeny.policy.set.assignment"
        },
        "pciAuditDenySetAssignmentDisplayName": {
            "value": "PCI auditdeny policy set assignment"
        },
        "pciPolicyDefinitionId": {
            "value": "/providers/Microsoft.Authorization/policySetDefinitions/496eeda9-8f2f-4d5e-8dfd-204f0a92ed41"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```