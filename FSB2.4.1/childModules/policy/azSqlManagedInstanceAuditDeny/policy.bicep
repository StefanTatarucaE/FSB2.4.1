/*
SUMMARY: Managed instance policy.
DESCRIPTION: Policy for managed SQL Instance.
AUTHOR/S: alkesh.naik@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param azSqlManagedInstanceSettings object

@description('Specify set name for Sql managed instance audit deny initiative')
param azSqlManagedInstanceAuditDenySetName string

@description('Specify displayname for Sql managed instance audit deny initiative')
param azSqlManagedInstanceAuditDenySetDisplayName string

@description('Specify set assignment name for Sql managed instance audit deny initiative')
param azSqlManagedInstanceAuditDenySetAssignmentName string

@description('Specify set assignment displayname for Sql managed instance audit deny initiative')
param azSqlManagedInstanceAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variable for allowedValues which is the same for all policy set definition parameters.
var allowedValues = [
  'Audit'
  'Deny'
  'Disabled'
  'AuditIfNotExists'
]

// Variable for allowedValues which is for the SQL defender.
var allowedValuesForSqlDefender = [
  'AuditIfNotExists'
  'Disabled'
]

var allowedValuesForGrs = [
  'Deny'
  'Disabled'
]

//Variable which holds the definition set details
var policySetDefinitionProperties = {
    description: 'This initiative configures governance and security policies to Azure SQL Managed Instance'
    metadata: {
      category: 'Monitoring'
      source: policyMetadata
      version: '0.0.1'
    }
}

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  description: 'Ensures that SQL Managed Instance has relevant governane and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
}

// RESOURCE DEPLOYMENTS

resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: azSqlManagedInstanceAuditDenySetName
  properties: {
    displayName: azSqlManagedInstanceAuditDenySetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      sqlManagedInstanceAdvancedDataSecurity: {
        type: 'String'
        metadata: {
          description: 'Allowed values are AuditIfNotExists and Disabled'
          displayName: 'Azure Defender for SQL should be enabled for unprotected SQL Managed Instances'
        }
        allowedValues: allowedValuesForSqlDefender
      }
      sqlManagedInstanceAdOnlyEnabled: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Azure SQL Managed Instance should have Azure Active Directory Only Authentication enabled'
        }
        allowedValues: allowedValues
      }
      sqlManagedInstanceBlockGrsBackupRedundancy: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Deny and Disabled'
          displayName: 'SQL Managed Instances should avoid using GRS backup redundancy'
        }
        allowedValues: allowedValuesForGrs
      }
      sqlManagedInstanceVulnerabilityAssesment: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'SQL Managed Instances Vulnerability assessment should be enabled on SQL Managed Instance'
        }
        allowedValues: allowedValuesForSqlDefender
      }
      sqlManagedInstanceEnsureServerTdeIsEncryptedWithYourOwnKey: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'SQL managed instances should use customer-managed keys to encrypt data at rest'
        }
        allowedValues: allowedValues
      }
      sqlManagedInstanceMiniumTlsVersionAudit: {
        type: 'String'
        metadata: {
          description: 'Enable or disable the execution of the policy'
          displayName: 'SQL Managed Instance should have the minimal TLS version of 1.2'
        }
        allowedValues: allowedValues
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/abfb7388-5bf4-4ad7-ba99-2cd2f41cebb9'
        parameters: {
          effect: {
            value: '[parameters(\'sqlManagedInstanceAdvancedDataSecurity\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ac01ad65-10e5-46df-bdd9-6b0cad13e1d2'
        parameters: {
          effect: {
            value: '[parameters(\'sqlManagedInstanceEnsureServerTdeIsEncryptedWithYourOwnKey\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a8793640-60f7-487c-b5c3-1d37215905c4'
        parameters: {
          effect: {
            value: '[parameters(\'sqlManagedInstanceMiniumTlsVersionAudit\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/78215662-041e-49ed-a9dd-5385911b3a1f'
        parameters: {
          effect: {
            value: '[parameters(\'sqlManagedInstanceAdOnlyEnabled\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a9934fd7-29f2-4e6d-ab3d-607ea38e9079'
        parameters: {
          effect: {
            value: '[parameters(\'sqlManagedInstanceBlockGrsBackupRedundancy\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1b7aa243-30e4-4c9e-bca8-d0d3022b634a'
        parameters: {
          effect: {
            value: '[parameters(\'sqlManagedInstanceVulnerabilityAssesment\')]'
          }
        }
      }
    ]
}
}

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: azSqlManagedInstanceAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: azSqlManagedInstanceAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      sqlManagedInstanceAdvancedDataSecurity: {
        value: azSqlManagedInstanceSettings.sqlManagedInstanceAdvancedDataSecurity
      }
      sqlManagedInstanceAdOnlyEnabled: {
        value: azSqlManagedInstanceSettings.sqlManagedInstanceAdOnlyEnabled
      }
      sqlManagedInstanceBlockGrsBackupRedundancy : {
        value: azSqlManagedInstanceSettings.sqlManagedInstanceBlockGrsBackupRedundancy
      }
      sqlManagedInstanceEnsureServerTdeIsEncryptedWithYourOwnKey: {
        value: azSqlManagedInstanceSettings.sqlManagedInstanceEnsureServerTdeIsEncryptedWithYourOwnKey
      }
      sqlManagedInstanceMiniumTlsVersionAudit: {
        value: azSqlManagedInstanceSettings.sqlManagedInstanceMiniumTlsVersionAudit
      }
      sqlManagedInstanceVulnerabilityAssesment: {
        value: azSqlManagedInstanceSettings.sqlManagedInstanceVulnerabilityAssesment
      }  
  }
    policyDefinitionId: policySetDefinition.id
}
}
