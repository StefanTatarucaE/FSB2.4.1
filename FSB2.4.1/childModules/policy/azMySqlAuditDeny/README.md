# policy/azMySqlAuditden/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy set definition & 1 policy assignment.

This policy configures governance and security policies for Azure MySql Database.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/azMySqlAuditdeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
  mySqlsettings: {
        enableSslConnection: 'Audit'
        enableGeoRedundantBackup: 'Audit'
        enableInfraEncryption: 'Audit'
        useVirtualNetworkServiceEndpoint: 'AuditIfNotExists'
        useCustomerManagedKeyMySql: 'AuditIfNotExists'
        enablePrivateEndpointMySql: 'AuditIfNotExists'
        disablePublicAccessFlexibleMySql: 'Audit'
        disablePublicAccessMySql: 'Audit'
  }
  mySqlAuditDenySetName: 'mysql.auditdeny.policy.set'
  mySqlAuditDenySetDisplayName: 'Mysql auditdeny policy set'
  mySqlAuditDenySetAssignmentName: 'mysql.auditdeny.policy.set.assignment'
  mySqlAuditDenySetAssignmentDisplayName: 'Mysql auditdeny policy set assignment'
  policyMetadata : 'EvidenELZ'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `mySqlSettings` | `object` | true | Object which sets the values of the policy set definition parameters. The specific parameters & what they are for, are described in the `policySetDefinition` resource block. Additional Details [here](#array---mysqlsettings).|
| `mySqlAuditDenySetName` | `string` | true | Specify set name for mysql audit deny initiative |
| `mySqlAuditDenySetDisplayName` | `string` | true | Specify displayname for mysql audit deny initiative |
| `mySqlAuditDenySetAssignmentName` | `string` | true | Specify set assignment name for mysql audit deny initiative |
| `mySqlAuditDenySetAssignmentDisplayName` | `string` | true | Specify set assignment displayname for mysql audit deny initiative |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |


### Object - mySqlSettings
| Name | Type | Description |
| --- | --- | --- |
| `enableSslConnection` | `string` | Enforce SSL connection should be enabled. |
| `enableGeoRedundantBackup` | `string` | Geo-redundant backup should be enabled. |
| `enableInfraEncryption` | `string` | Infrastructure encryption should be enabled. |
| `useVirtualNetworkServiceEndpoint` | `string` | Use a virtual network service endpoint.|
| `useCustomerManagedKeyMySql` | `string` | Use customer-managed keys to encrypt data at rest. |
| `enablePrivateEndpointMySql` | `string` | Private endpoint should be enabled.|
| `disablePublicAccessFlexibleMySql` | `string` | Public network access should be disabled for flexible servers.|
| `disablePublicAccessMySql` | `string` | Public network access should be disabled. |


## Module Outputs
None.


## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "mySqlSettings": {
            "value": {
                "enableSslConnection": "Audit",
                "enableGeoRedundantBackup": "Audit",
                "enableInfraEncryption": "Audit",
                "useVirtualNetworkServiceEndpoint": "AuditIfNotExists",
                "useCustomerManagedKeyMySql": "AuditIfNotExists",
                "enablePrivateEndpointMySql": "AuditIfNotExists",
                "disablePublicAccessFlexibleMySql": "Audit",
                "disablePublicAccessMySql": "Audit"
            }
        },
        "mySqlAuditDenySetName": {
            "value": "mysql.auditdeny.policy.set"
        },
        "mySqlAuditDenySetDisplayName": {
            "value": "Mysql auditdeny policy set"
        },
        "mySqlAuditDenySetAssignmentName": {
            "value": "mysql.auditdeny.policy.set.assignment"
        },
        "mySqlAuditDenySetAssignmentDisplayName": {
            "value": "Mysql auditdeny policy set assignment"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```