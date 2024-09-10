# policy/postgreSqlAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy set definition grouping 13 built-in policy definations & 1 policy assignment.

This policy configures governance and security policies for the Azure PostgreSQL. Azure policy set has below built-in policies : 

- Connection throttling should be enabled for PostgreSQL database servers.
- Disconnections should be logged for PostgreSQL database servers.
- Enforce SSL connection should be enabled for PostgreSQL database servers.
- Geo-redundant backup should be enabled for Azure Database for PostgreSQL.
- Infrastructure encryption should be enabled for Azure Database for PostgreSQL servers.
- Log checkpoints should be enabled for PostgreSQL database servers.
- Log connections should be enabled for PostgreSQL database servers.
- Log duration should be enabled for PostgreSQL database servers.
- PostgreSQL server should use a virtual network service endpoint.
- PostgreSQL servers should use customer-managed keys to encrypt data at rest.
- Private endpoint should be enabled for PostgreSQL servers.
- Public network access should be disabled for PostgreSQL flexible servers.
- Public network access should be disabled for PostgreSQL servers.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/postgreSqlAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params : {
    postgreSqlSettings: 
    {
        enableConnectionThrottlingEffect: 'AuditIfNotExists',
        disconnectionLoggedEffect: 'AuditIfNotExists',
        enforceSslConnectionEffect: 'Audit',
        geoRedundantBackupEffect: 'Audit',
        enableInfrastructureEncryptionEffect: 'Audit',
        enableLogCheckpointsEffect: 'Audit',
        enableLogConnectionEffect: 'AuditIfNotExists',
        enableLogDurationEffect: 'AuditIfNotExists',
        useVirtualNetworkServiceEndpointEffect: 'AuditIfNotExists',
        usePostgreCustomerManagedkeyEffect: 'AuditIfNotExists',
        enablePrivateEndpointEffect: 'AuditIfNotExists',
        disablePublicAccessFlexiEffect: 'Audit',
        disablePostgresPublicAccessEffect: 'Audit'
    }
    postgreSqlAuditDenySetName : 'postgresql.auditdeny.policy.set'
    postgreSqlAuditDenySetDisplayName : 'Postgresql auditdeny policy set'
    postgreSqlAuditDenySetAssignmentName : 'postgresql.auditdeny.policy.set.assignment'
    postgreSqlAuditDenySetAssignmentDisplayName : 'Postgresql auditdeny policy set assignment'
    policyMetadata : 'EvidenELZ'
    }
}
```

## Module Parameters


| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `postgreSqlSettings` | `object` | true | Object which sets the values of the policy set definition parameters. The specific parameters & what they are for, are described in the `policySetDefinition` resource block. Additional Details [here](#object---postgresqlsettings).|
| `postgreSqlAuditDenySetName` | `string` | true |  Policy set name for postgreSql auditdeny. |
| `postgreSqlAuditDenySetDisplayName` | `string` | true | Policy set display name for postgreSql auditdeny. |
| `postgreSqlAuditDenySetAssignmentName` | `string` | true | Policy set assignment name for postgreSql auditdeny. |
| `postgreSqlAuditDenySetAssignmentDisplayName` | `string` | true | Policy set assignment display name for postgreSql auditdeny. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

### Object - postgreSqlSettings
| Name | Type | Description |
| --- | --- | --- |
| `enableConnectionThrottlingEffect` | `string` | Azure PostgreSql connection throttling effect should be enabled.. Allowed Values: AuditIfNotExists, Disabled. |
| `disconnectionLoggedEffect` | `string` | Enable log disconnection effort for Azure PostgreSql. Allowed Values: AuditIfNotExists, Disabled. |
| `enforceSslConnectionEffect` | `string` | Enable SSL connection. Allowed Values: Audit, Disabled. |
| `geoRedundantBackupEffect` | `string` | Enable geo-redundant backup. Allowed Values: Audit, Disabled. |
| `enableInfrastructureEncryptionEffect` | `string` | Enable infrastructure encryption. Allowed Values: Audit, Deny, Disabled. |
| `enableLogCheckpointsEffect` | `string` | Enable log checkpoints. Allowed Values: AuditIfNotExists, Disabled. |
| `enableLogConnectionEffect` | `string` | Enable log connections. Allowed Values: AuditIfNotExists, Disabled. |
| `enableLogDurationEffect` | `string` | Enabled log duration. Allowed Values: AuditIfNotExists, Disabled. |
| `useVirtualNetworkServiceEndpointEffect` | `string` | Use a virtual network service endpoint. Allowed Values: AuditIfNotExists, Disabled. |
| `usePostgreCustomerManagedkeyEffect` | `string` | Use customer-managed keys to encrypt data at rest. Allowed Values: AuditIfNotExists, Disabled. |
| `enablePrivateEndpointEffect` | `string` | Private endpoint connections enforce secure communication by enabling private connectivity to Azure Database for PostgreSQL. Configure a private endpoint connection to enable access to traffic coming only from known networks and prevent access from all other IP addresses, including within Azure. Allowed Values: AuditIfNotExists, Disabled. |
| `disablePublicAccessFlexiEffect` | `string` | Disabled public network access for flexible servers. Allowed Values: Audit, Deny, Disabled. |
| `disablePostgresPublicAccessEffect` | `string` | Disabled public network access for servers. Allowed Values: Audit, Deny, Disabled. |


## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "postgreSqlSettings": {
            "value": {
                "enableConnectionThrottlingEffect": "AuditIfNotExists",
                "disconnectionLoggedEffect": "AuditIfNotExists",
                "enforceSslConnectionEffect": "Audit",
                "geoRedundantBackupEffect": "Audit",
                "enableInfrastructureEncryptionEffect": "Audit",
                "enableLogCheckpointsEffect": "AuditIfNotExists",
                "enableLogConnectionEffect": "AuditIfNotExists",
                "enableLogDurationEffect": "AuditIfNotExists",
                "useVirtualNetworkServiceEndpointEffect": "AuditIfNotExists",
                "usePostgreCustomerManagedkeyEffect": "AuditIfNotExists",
                "enablePrivateEndpointEffect": "AuditIfNotExists",
                "disablePublicAccessFlexiEffect": "Audit",
                "disablePostgresPublicAccessEffect": "Audit"
            }
        },
        "postgreSqlAuditDenySetName" :{
            "value": "postgresql.auditdeny.policy.set"
        },
        "postgreSqlAuditDenySetDisplayName" :{
            "value": "Postgresql auditdeny policy set"
        },
        "postgreSqlAuditDenySetAssignmentName" :{
            "value": "postgresql.auditdeny.policy.set.assignment"
        },
        "postgreSqlAuditDenySetAssignmentDisplayName" :{
            "value": "Postgresql auditdeny policy set assignment"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```