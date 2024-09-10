# policy/azSqlManagedInstanceAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 custom policy definition, references 6 built-in policies in 1 policy set definition & 1 policy assignment.

This policy is for the Azure SQL Managed Instance with below definition.

- Azure Defender for SQL should be enabled for unprotected SQL Managed Instances
- SQL managed instances should use customer-managed keys to encrypt data at rest
- SQL Managed Instance should have the minimal TLS version of 1.2
- Azure SQL Managed Instance should have Azure Active Directory Only Authentication enabled
- SQL Managed Instance auditdeny policy set
- Vulnerability assessment should be enabled on SQL Managed Instance

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |



## Module Example Use
```bicep
module examplePolicy '../childModules/policy/azSqlManagedInstanceAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
        azSqlManagedInstanceSettings : {
            sqlManagedInstanceAdvancedDataSecurity: 'AuditIfNotExists'
            sqlManagedInstanceAdOnlyEnabled: 'Audit'
            sqlManagedInstanceBlockGrsBackupRedundancy: 'Deny'
            sqlManagedInstanceEnsureServerTdeIsEncryptedWithYourOwnKey: 'Audit'
            sqlManagedInstanceMiniumTlsVersionAudit: 'Audit'
            sqlManagedInstanceVulnerabilityAssesment: 'AuditIfNotExists'
        }
        azSqlManagedInstanceAuditDenySetName: 'azsqlmanagedinstance.auditdeny.policy.set'
        azSqlManagedInstanceAuditDenySetDisplayName: 'Sql managed instance auditdeny policy set'
        azSqlManagedInstanceAuditDenySetAssignmentName: 'azsqlmanagedinstance.auditdeny.policy.set.assignment'
        azSqlManagedInstanceAuditDenySetAssignmentDisplayName: 'Sql managed instance auditdeny policy set assignment'
        policyMetadata : 'EvidenELZ'
    }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `azSqlManagedInstanceSettings` | `object` | true | Object which sets the values of the policy set definition parameters. The specific parameters & what they are for, are described in the `policySetDefinition` resource block.  Additional Details [here](#object---azsqlmanagedinstancesettings).|
| `azSqlManagedInstanceAuditDenySetName` | `string` | true | Specify set name for Sql managed instance audit deny initiative |
| `azSqlManagedInstanceAuditDenySetDisplayName` | `string` | true | Specify displayname for Sql managed instance audit deny initiative |
| `azSqlManagedInstanceAuditDenySetAssignmentName` | `string` | true | Specify set assignment name for Sql managed instance audit deny initiative |
| `azSqlManagedInstanceAuditDenySetAssignmentDisplayName` | `string` | true | Specify set assignment displayname for Sql managed instance audit deny initiative |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |


### Object - azSqlManagedInstanceSettings
| Name | Type | Description |
| --- | --- | --- |
| `sqlManagedInstanceAdvancedDataSecurity` | `string` | Azure Defender for SQL should be enabled for unprotected SQL Managed Instances. Allowed values are AuditIfNotExists and Disabled |
| `sqlManagedInstanceAdOnlyEnabled` | `string` | Azure SQL Managed Instance should have Azure Active Directory Only Authentication enabled. Allowed values are Audit, Deny and Disabled. |
| `sqlManagedInstanceBlockGrsBackupRedundancy` | `string` | SQL Managed Instances should avoid using GRS backup redundancy. Allowed values are Deny and Disabled. |
| `sqlManagedInstanceEnsureServerTdeIsEncryptedWithYourOwnKey` | `string` | SQL managed instances should use customer-managed keys to encrypt data at rest. Allowed values are Audit, Deny and Disabled|
| `sqlManagedInstanceMiniumTlsVersionAudit` | `string` | SQL Managed Instance should have the minimal TLS version of 1.2. Enable or disable the execution of the policy. Allowed values are Audit, Disabled|
| `sqlManagedInstanceVulnerabilityAssesment` | `string` | SQL Managed Instances Vulnerability assessment should be enabled on SQL Managed Instance. Allowed values are AuditIfNotExists and Disabled.|


## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "azSqlManagedInstanceSettings": {
            "value": {
                "sqlManagedInstanceAdvancedDataSecurity": "AuditIfNotExists",
                "sqlManagedInstanceAdOnlyEnabled": "Audit",
                "sqlManagedInstanceBlockGrsBackupRedundancy": "Deny",
                "sqlManagedInstanceEnsureServerTdeIsEncryptedWithYourOwnKey": "Audit",
                "sqlManagedInstanceMiniumTlsVersionAudit": "Audit",
                "sqlManagedInstanceVulnerabilityAssesment": "AuditIfNotExists"
            }
        },
        "azSqlManagedInstanceAuditDenySetName": {
            "value": "azsqlmanagedinstance.auditdeny.policy.set"
        },
        "azSqlManagedInstanceAuditDenySetDisplayName": {
            "value": "Sql managed instance auditdeny policy set"
        },
        "azSqlManagedInstanceAuditDenySetAssignmentName": {
            "value": "azsqlmanagedinstance.auditdeny.policy.set.assignment"
        },
        "azSqlManagedInstanceAuditDenySetAssignmentDisplayName": {
		    "value": "Sql managed instance auditdeny policy set assignment"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```