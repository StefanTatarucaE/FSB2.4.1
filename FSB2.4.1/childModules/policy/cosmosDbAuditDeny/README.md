# policy/cosmosDbAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy set definitions and 1 policy assignment.

This policy will audit the CosmosDb resource. Does not apply to resource groups.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/cosmosDbAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    cosmosDbSettings:{
        firewallRuleEnabledEffect: 'Audit'
        useCustomerManagedKeyEffect: 'Audit'
        allowedLocationEffect: 'Audit'
        disablePublicNetworkAccessEffect: 'Audit'
        throughputMaxEffect: 'Audit'
        "throughputMax": 1000000,
        "listOfAllowedLocationsmosDb": [
          "uksouth",
          "ukwest"
        ],
        localAuthenticationDisableEffect: 'Audit'
        virtualNetworkServiceEndpointEffect: 'Audit'
        usePrivateLinkEffect: 'Audit'
    }
    cosmosDbAuditDenySetName : 'cosmosdb.auditdeny.policy.set'
    cosmosdbAuditDenySetDisplayName : 'Cosmosdb auditdeny policy set'
    cosmosdbAuditDenySetAssignmentName : 'cosmosdb.auditdeny.policy.set.assignment'
    cosmosdbAuditDenySetAssignmentDisplayName : 'Cosmosdb auditdeny policy set assignment'
    policyMetadata : 'EvidenELZ'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `cosmosDbSettings` | `object` | true | Object which sets the values of the policy set definition parameters. The specific parameters & what they are for, are described in the `policySetDefinition` resource block.  Additional Details [here](#object---cosmosdbsettings).|
| `cosmosDbAuditDenySetName` | `string` | true | set name for cosmosdb audit deny initiative. |
| `cosmosdbAuditDenySetDisplayName` | `string` | true | set displayname for cosmosdb audit deny initiative. |
| `cosmosdbAuditDenySetAssignmentName` | `string` | true | set assignment name for cosmosdb audit deny initiative. |
| `cosmosdbAuditDenySetAssignmentDisplayName` | `string` | true | set assignment displayname for cosmosdb audit deny initiative. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |


### Object - cosmosDbSettings
| Name | Type | Description |
| --- | --- | --- |
| `firewallRuleEnabledEffect` | `string` | Firewall rules should be defined on your Azure Cosmos DB accounts to prevent traffic from unauthorized sources. Accounts that have at least one IP rule defined with the virtual network filter enabled are deemed compliant. Accounts disabling public access are also deemed compliant. Allowed Values: Audit, Deny, Disabled. |
| `useCustomerManagedKeyEffect` | `string` | Customer-managed keys to encrypt data at rest effect. Allowed Values: Audit, Deny, Disabled. |
| `allowedLocationEffect` | `string` | Allowed locations effect. Allowed Values: Audit, Deny, Disabled'. |
| `disablePublicNetworkAccessEffect` | `string` | Disable public network access effect. Allowed Values: Audit, Deny, Disabled. |
| `throughputMaxEffect` | `string` | Maximum throughput effect. Allowed Values: Audit, Deny, Disabled. |
| `listOfAllowedLocations` | `string[]` | The list of locations that can be specified when deploying Azure Cosmos DB resources needed for 'Allowed locations effect' policy. | 
| `throughputMax` | `int` | The maximum throughput (RU/s) that can be assigned to a container via the Resource Provider during create or update. Parameter is needed for 'Maximum thorughput effect' policy. |
| `localAuthenticationDisableEffect` | `string` | Local authentication methods disable. Allowed Values: Audit, Deny, Disabled. |
| `virtualNetworkServiceEndpointEffect` | `string` | Check if CosmosDB is using a virtual network service endpoint. Allowed Values: Audit, Disabled. |
| `usePrivateLinkEffect` | `string` | Check if CosmosDB is using a private link. Allowed Values: Audit, Disabled. |

## Module Outputs
None.


## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "cosmosDbSettings": {
      "value": {
        "firewallRuleEnabledEffect": "Audit",
        "useCustomerManagedKeyEffect": "Audit",
        "allowedLocationEffect": "Audit",
        "disablePublicNetworkAccessEffect": "Audit",
        "throughputMaxEffect": "Audit",
        "throughputMax": 1000000,
        "listOfAllowedLocations": [
          "uksouth",
          "ukwest"
        ],
        "localAuthenticationDisableEffect": "Audit",
        "virtualNetworkServiceEndpointEffect": "Audit",
        "usePrivateLinkEffect": "Audit"
      }
    },
    "cosmosDbAuditDenySetName": {
      "value": "cosmosdb.auditdeny.policy.set"
    },
    "cosmosdbAuditDenySetDisplayName": {
      "value": "Cosmosdb auditdeny policy set"
    },
    "cosmosdbAuditDenySetAssignmentName": {
      "value": "cosmosdb.auditdeny.policy.set.assignment"
    },
    "cosmosdbAuditDenySetAssignmentDisplayName": {
      "value": "Cosmosdb auditdeny policy set assignment"
    },
    "policyMetadata": {
        "value": "EvidenELZ"
    }
  }
}
```

