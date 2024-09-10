# policy/azSqlDbAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy set definition & 1 policy assignment.

This policy configures governance and security policies for the Azure Sql Databases

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/azSqlDbAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
  sqlsettings: {
        sqlDbAdvancedDataSecurity : 'AuditIfNotExists'
        sqlDbAdOnlyEnabled : 'Audit'
        sqlDbEnsureServerTdeIsEncryptedWithYourOwnKey : 'Audit',
        enableSqlTlsPolicy : 'Audit'
        azureSqlDbAvoidGrsBackup : 'Disabled'
        vulnerabilitySqlDatabase : 'AuditIfNotExists'

  }
  azSqlDbAuditDenySetName: 'azsqldb.auditdeny.policy.set'
  azSqlDbAuditDenySetDisplayName: 'Sql auditdeny policy set'
  azSqlDbAuditDenySetAssignmentName: 'azsqldb.auditdeny.policy.set.assignment'
  azSqlDbAuditDenySetAssignmentDisplayName: 'Sql auditdeny policy set assignment'
  policyMetadata : 'EvidenELZ'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `sqlSettings` | `object` | true | Object which sets the values of the policy set definition parameters. The specific parameters & what they are for, are described in the `policySetDefinition` resource block. Additional Details [here](#object---sqlsettings).|
| `azSqlDbAuditDenySetName` | `string` | true | Specify set name for Sql Db audit deny initiative |
| `azSqlDbAuditDenySetDisplayName` | `string` | true | Specify displayname for Sql Db audit deny initiative |
| `azSqlDbAuditDenySetAssignmentName` | `string` | true | Specify set assignment name for Sql Db audit deny initiative |
| `azSqlDbAuditDenySetAssignmentDisplayName` | `string` | true | Specify set assignment displayname for Sql Db audit deny initiative |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |


### Object - sqlSettings
| Name | Type | Description |
| --- | --- | --- |
| `sqlDbAdvancedDataSecurity` | `string` | Azure Defender for SQL should be enabled for unprotected Azure SQL servers. Allowed values are AuditIfNotExists and Disabled |
| `sqlDbAdOnlyEnabled` | `string` | Azure SQL Database should have Azure Active Directory Only Authentication enabled. Allowed values are Audit, Deny and Disabled. |
| `sqlDbEnsureServerTdeIsEncryptedWithYourOwnKey` | `string` | Azure SQL servers should use customer-managed keys to encrypt data at rest. |
| `enableSqlTlsPolicy` | `string` | Azure Sql Database should be running TLS version 1.2 or newer. Allowed Values: Audit, Disabled.|
| `azureSqlDbAvoidGrsBackup` | `string` | Databases should avoid using the default geo-redundant storage for backups, if data residency rules require data to stay within a specific region. Allowed Values: Deny, Disabled.|
| `vulnerabilitySqlDatabase` | `string` | Audit each Sql Database which doesnt have recurring vulnerability assessment scans enabled. Allowed Values: AuditIfNotExists, Disabled.|

## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "sqlSettings": {
            "value": {
                "enableSqlTlsPolicy": "Audit",
                "azureSqlDbAvoidGrsBackup": "Disabled",
                "vulnerabilitySqlDatabase":"AuditIfNotExists",
                "sqlDbAdvancedDataSecurity":"AuditIfNotExists",
                "sqlDbEnsureServerTdeIsEncryptedWithYourOwnKey":"Audit",
                "sqlDbAdOnlyEnabled":"Audit"
            }
        },
        "azSqlDbAuditDenySetName": {
            "value": "azsqldb.auditdeny.policy.set"
        },
        "azSqlDbAuditDenySetDisplayName": {
            "value": "Sql Db auditdeny policy set"
        },
        "azSqlDbAuditDenySetAssignmentName": {
            "value": "azsqldb.auditdeny.policy.set.assignment"
        },
        "azSqlDbAuditDenySetAssignmentDisplayName": {
		    "value": "Sql Db auditdeny policy set assignment"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```