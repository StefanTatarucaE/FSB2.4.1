# policy/azRedisAuditDeny/policy.bicep
Bicep module to create Azure policy resources for redis.

## Module Features
This module deploys 3 Azure policy definition, 1 policy set & 1 policy assignment.

This policy assignemnet for Redis is with below definition set.

- Azure Cache for Redis should disable public network access
- Azure Cache for Redis should use private link
- Only secure connections to your Azure Cache for Redis should be enabled

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policydefinitions` | [2020-09-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions?tabs=bicep) |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |



## Module Example Use
```bicep
module examplePolicy '../childModules/policy/azRedisAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
        azRedisAuditSettings: {
            disablePublicAccess: 'Audit'
            useRedisPrivateLink: 'AuditIfNotExists'
            enableSecureConnection: 'Audit'
        }
        azRedisAuditDenySetName: 'azRedis.auditdeny.policy.set'
        azRedisAuditDenySetDisplayName: 'Redis auditdeny policy set'
        azRedisAuditDenySetAssignmentName: 'azRedis.auditdeny.policy.set.assignment'
        azRedisAuditDenySetAssignmentDisplayName: 'Redis auditdeny policy set assignment'
        policyMetadata : 'EvidenELZ'
        }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `azRedisAuditSettings` | `object` | true | Object which sets the values of the policy set definition parameters. The specific parameters & what they are for, are described in the `policySetDefinition` resource block. Additional Details [here](#object---azredisauditsettings).|
| `azRedisAuditDenySetName` | `string` | true | Specify set name for Redis audit deny initiative |
| `azRedisAuditDenySetDisplayName` | `string` | true | Specify displayname for Redis audit deny initiative |
| `azRedisAuditDenySetAssignmentName` | `string` | true | Specify set assignment name for Redis audit deny initiative |
| `azRedisAuditDenySetAssignmentDisplayName` | `string` | true | Specify set assignment displayname for Redis audit deny initiative |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |


### Object - azRedisAuditSettings
| Name | Type | Description |
| --- | --- | --- |
| `disablePublicAccess` | `string` | Redis should disable public network access. The Allowed Values: Audit, Deny, Disabled. |
| `useRedisPrivateLink` | `string` | Redis should use private link. The Allowed Values: AuditIfNotExists, Disabled. |
| `enableSecureConnection` | `string` | Redis should be enabled only on secure connections. The Allowed Values: Audit, Deny, Disabled. |


## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "azRedisAuditSettings": {
            "value": {
                "disablePublicAccess": "Audit",
                "useRedisPrivateLink": "AuditIfNotExists",
                "enableSecureConnection": "Audit"
            }
        },
        "azRedisAuditDenySetName": {
            "value": "azredis.auditdeny.policy.set"
        },
        "azRedisAuditDenySetDisplayName": {
            "value": "Redis auditdeny policy set"
        },
        "azRedisAuditDenySetAssignmentName": {
            "value": "azredis.auditdeny.policy.set.assignment"
        },
        "azRedisAuditDenySetAssignmentDisplayName": {
		    "value": "Redis auditdeny policy set assignment"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```