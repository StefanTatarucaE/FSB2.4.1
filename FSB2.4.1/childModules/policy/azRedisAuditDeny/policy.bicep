/*
SUMMARY: Redis Audit policy.
DESCRIPTION: Deployment of redis audit policy.
AUTHOR/S: alkesh.naik@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription.  ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param azRedisAuditSettings object

@description('Specify set name for Redis audit deny initiative')
param azRedisAuditDenySetName string

@description('Specify displayname for Redis audit deny initiative')
param azRedisAuditDenySetDisplayName string

@description('Specify set assignment name for Redis audit deny initiative')
param azRedisAuditDenySetAssignmentName string

@description('Specify set assignment displayname for Redis audit deny initiative')
param azRedisAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variable for allowedValues which is the same for all policy set definition parameters.
var allowedValues = [
  'Audit'
  'Deny'
  'Disabled'
]

// Variable for allowedValues which is for the SQL defender.
var allowedValuesForSqlDefender = [
  'AuditIfNotExists'
  'Disabled'
]

//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This initiative configures governance and security policies to azure redis'
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
  description: 'Ensures that Redis Cache has relevant governane and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}


resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: azRedisAuditDenySetName
  properties: {
    displayName: azRedisAuditDenySetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      disablePublicAccess: {
        type: 'String'
        metadata: {
          description: 'Redis should disable public network access. The Allowed Values: Audit, Deny, Disabled'
          displayName: 'Redis should disable public network access'
        }
        allowedValues: allowedValues
      }
      useRedisPrivateLink: {
        type: 'String'
        metadata: {
          description: 'Redis should use private link. The Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'Redis should use private link'
        }
        allowedValues: allowedValuesForSqlDefender
      }
      enableSecureConnection: {
        type: 'String'
        metadata: {
          description: 'Redis should be enabled only on secure connections. The Allowed Values: Audit, Deny, Disabled'
          displayName: 'Redis should be enabled only on secure connections'
        }
        allowedValues: allowedValues
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/470baccb-7e51-4549-8b1a-3e5be069f663'
        parameters: {
          effect: {
            value: '[parameters(\'disablePublicAccess\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/7803067c-7d34-46e3-8c79-0ca68fc4036d'
        parameters: {
          effect: {
            value: '[parameters(\'useRedisPrivateLink\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/22bee202-a82f-4305-9a2a-6d7f44d4dedb'
        parameters: {
          effect: {
            value: '[parameters(\'enableSecureConnection\')]'
          }
        }
      }
    ]
  }
}

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: azRedisAuditDenySetAssignmentName
  location: assignmentProperties.location
  properties: {
    displayName: azRedisAuditDenySetAssignmentDisplayName
    description: assignmentProperties.description
    metadata: assignmentProperties.metadata
    parameters: {
      disablePublicAccess: {
        value: azRedisAuditSettings.disablePublicAccess
      }
      useRedisPrivateLink: {
        value: azRedisAuditSettings.useRedisPrivateLink
      }
      enableSecureConnection: {
        value: azRedisAuditSettings.enableSecureConnection
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
  identity: {
    type: assignmentProperties.identityType
  }
}
