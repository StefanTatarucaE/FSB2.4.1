/*
SUMMARY: SQL DB Audit/Deny Policy child module.
DESCRIPTION: Deployment of SQL DB Audit/Deny Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param sqlSettings object

@description('Specify set name for azSqlDb audit deny initiative')
param azSqlDbAuditDenySetName string

@description('Specify displayname for azSqlDb audit deny initiative')
param azSqlDbAuditDenySetDisplayName string

@description('Specify set assignment name for azSqlDb audit deny initiative')
param azSqlDbAuditDenySetAssignmentName string

@description('Specify set assignment displayname for azSqlDb audit deny initiative')
param azSqlDbAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variable for allowedValues which is the same for all policy set definition parameters.
var auditAllowedValues = [
  'Audit'
  'Disabled'
]

var denyValue = [
  'Deny'
  'Disabled'
]

var auditIfNotExistsAllowedValues = [
  'AuditIfNotExists'
  'Disabled'
]

var auditDenyAllowedValues = union(auditAllowedValues, denyValue)

//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This policy set configures governance and security policies to Azure SQL Databases.'
  metadata: {
    category: 'Monitoring'
    source: policyMetadata
    version: '0.0.1'
  }
}

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Azure SQL Databases have relevant governance and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

// RESOURCE DEPLOYMENTS
//Deploy the policy definition set for the definitions created in previous resource block
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: azSqlDbAuditDenySetName
  properties: {
    displayName: azSqlDbAuditDenySetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      sqlDbAdvancedDataSecurity: {
        type: 'String'
        metadata: {
          description: 'Audit if Azure Defender for SQL is enabled for unprotected Azure SQL servers.'
          displayName: 'defenderSqlDatabase'
        }
        allowedValues: auditIfNotExistsAllowedValues
        defaultValue: 'AuditIfNotExists'
      }
      sqlDbAdOnlyEnabled: {
        type: 'String'
        metadata: {
          description: 'Azure SQL Database should have Azure Active Directory Only Authentication enabled'
          displayName: 'adAuthenticationOnlySqlDatabase'
        }
        allowedValues: auditDenyAllowedValues
        defaultValue: 'Audit'
      }
      azureSqlDbAvoidGrsBackup: {
        type: 'String'
        metadata: {
          description: 'Databases should avoid using the default geo-redundant storage for backups, if data residency rules require data to stay within a specific region.'
          displayName: 'AzureSqlDbAvoidGrsBackup'
        }
        allowedValues: denyValue
        defaultValue: 'Deny'
      }
      vulnerabilitySqlDatabase: {
        type: 'String'
        metadata: {
          description: 'Audit each Sql Database which doesnt have recurring vulnerability assessment scans enabled.'
          displayName: 'vulnerabilitySqlDatabase'
        }
        allowedValues: auditIfNotExistsAllowedValues
        defaultValue: 'AuditIfNotExists'
      }
      sqlDbEnsureServerTdeIsEncryptedWithYourOwnKey: {
        type: 'String'
        metadata: {
          description: 'Audit if SQL Servers are using customer-managed keys to encrypt data at rest'
          displayName: 'cmkEncryptionSqlDatabase'
        }
        allowedValues: auditDenyAllowedValues
        defaultValue: 'Audit'
      }
      enableSqlTlsPolicy: {
        type: 'String'
        metadata: {
          description: 'Azure Sql Database should be running TLS version 1.2 or newer.'
          displayName: 'enableSqlTlsPolicy'
        }
        allowedValues: auditAllowedValues
        defaultValue: 'Audit'
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/32e6bbec-16b6-44c2-be37-c5b672d103cf' //Audit, Deny, Disabled
        parameters: {
          effect: {
            value: '[parameters(\'enableSqlTlsPolicy\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/b219b9cf-f672-4f96-9ab0-f5a3ac5e1c13' //Deny, Disabled
        parameters: {
          effect: {
            value: '[parameters(\'azureSqlDbAvoidGrsBackup\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ef2a8f2a-b3d9-49cd-a8a8-9a3aaaf647d9' //AuditIfNotExists, Disabled
        parameters: {
          effect: {
            value: '[parameters(\'vulnerabilitySqlDatabase\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/abfb4388-5bf4-4ad7-ba82-2cd2f41ceae9' //AuditIfNotExists, Disabled
        parameters: {
          effect: {
            value: '[parameters(\'sqlDbAdvancedDataSecurity\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0a370ff3-6cab-4e85-8995-295fd854c5b8' //Audit, Deny, Disabled
        parameters: {
          effect: {
            value: '[parameters(\'sqlDbEnsureServerTdeIsEncryptedWithYourOwnKey\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/abda6d70-9778-44e7-84a8-06713e6db027' //Audit, Deny, Disabled
        parameters: {
          effect: {
            value: '[parameters(\'sqlDbAdOnlyEnabled\')]'
          }
        }
      }
    ]
  }
}

//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: azSqlDbAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: azSqlDbAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      enableSqlTlsPolicy: {
        value: sqlSettings.enableSqlTlsPolicy
      }
      azureSqlDbAvoidGrsBackup: {
        value: sqlSettings.azureSqlDbAvoidGrsBackup
      }
      vulnerabilitySqlDatabase: {
        value: sqlSettings.vulnerabilitySqlDatabase
      }
      sqlDbAdvancedDataSecurity: {
        value: sqlSettings.sqlDbAdvancedDataSecurity
      }
      sqlDbEnsureServerTdeIsEncryptedWithYourOwnKey: {
        value: sqlSettings.sqlDbEnsureServerTdeIsEncryptedWithYourOwnKey
      }
      sqlDbAdOnlyEnabled: {
        value: sqlSettings.sqlDbAdOnlyEnabled
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
}

// OUTPUTS
