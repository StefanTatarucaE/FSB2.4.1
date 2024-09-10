/*
SUMMARY: Postgresql Audit/Deny Policy child module.
DESCRIPTION: Deployment of Postgresql Audit/Deny Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: abhijit.kakade@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. ELZ Azure doesn't target Management groups.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param postgreSqlSettings object

@description('Specify policy name for postgreSql auditdeny.')
param postgreSqlAuditDenySetName string

@description('Specify policy display name for postgreSql auditdeny.')
param postgreSqlAuditDenySetDisplayName string

@description('Specify policy assignment name for postgreSql auditdeny.')
param postgreSqlAuditDenySetAssignmentName string

@description('Specify policy assignment display name for postgreSql auditdeny.')
param postgreSqlAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variable for allowedValues which is the same for all policy set definition parameters.
var allowedValues = [
  'Audit'
  'Deny'
  'Disabled'
  'AuditIfNotExists'
]

var enforceSslConnectionValues = [
  'Audit'
  'Disabled'
]

@description('Specifies the ID of the policy definitions being assigned via the policy set definition.')
var policyDefinitionProperties = {
  enableConnectionThrottling:{
    id: '5345bb39-67dc-4960-a1bf-427e16b9a0bd'
  }
  disconnectionLogged:{
    id: 'eb6f77b9-bd53-4e35-a23d-7f65d5f0e446'
  }
  enforceSslConnection:{
    id: 'd158790f-bfb0-486c-8631-2dc6b4e8e6af'
  }
  geoRedundantBackup:{
    id: '48af4db5-9b8b-401c-8e74-076be876a430'
  }
  enableInfrastructureEncryption:{
    id: '24fba194-95d6-48c0-aea7-f65bf859c598'
  }
  enableLogCheckpoints:{
    id: 'eb6f77b9-bd53-4e35-a23d-7f65d5f0e43d'
  }
  enableLogConnection:{
    id: 'eb6f77b9-bd53-4e35-a23d-7f65d5f0e442'
  }
  enableLogDuration:{
    id: 'eb6f77b9-bd53-4e35-a23d-7f65d5f0e8f3'
  }
  useVirtualNetworkServiceEndpoint:{
    id: '3c14b034-bcb6-4905-94e7-5b8e98a47b65'
  }
  usePostgreCustomerManagedkey:{
    id: '18adea5e-f416-4d0f-8aa8-d24321e3e274'
  }
  enablePrivateEndpoint:{
    id: '0564d078-92f5-4f97-8398-b9f58a51f70b'
  }
  disablePublicAccessFlexi:{
    id: '5e1de0e3-42cb-4ebc-a86d-61d0c619ca48'
  }
  disablePostgresPublicAccess:{
    id: 'b52376f7-9612-48a1-81cd-1ffe4b61032c'
  }
}

//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This initiative configures governance and security policies to azure Postgresql'
  metadata: {
    category: 'SQL'
    source: policyMetadata
    version: '0.0.1'
  }
}

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Azure postgresql has relevant governance and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

// RESOURCE DEPLOYMENTS
//Deploy the policy definition set.
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: postgreSqlAuditDenySetName
  properties: {
    displayName: postgreSqlAuditDenySetDisplayName 
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      enableConnectionThrottlingEffect: {
        type: 'String'
        metadata: {
          description: 'Azure PostgreSql connection throttling effect should be enabled.'
          displayName: 'enableConnectionThrottlingEffect'
        }
        allowedValues: allowedValues
      }
      disconnectionLoggedEffect: {
        type: 'String'
        metadata: {
          description: 'Enable log disconnection effort for Azure PostgreSql.'
          displayName: 'disconnectionLoggedEffect'
        }
        allowedValues: allowedValues
      }
      enforceSslConnectionEffect: {
        type: 'String'
        metadata: {
          description: 'Enable SSL connection.'
          displayName: 'enforceSslConnectionEffect'
        }
        allowedValues: enforceSslConnectionValues
      }
      geoRedundantBackupEffect: {
        type: 'String'
        metadata: {
          description: 'Enable geo-redundant backup.'
          displayName: 'geoRedundantBackupEffect'
        }
        allowedValues: allowedValues
      }
      enableInfrastructureEncryptionEffect: {
        type: 'String'
        metadata: {
          description: 'Enable infrastructure encryption.'
          displayName: 'enableInfrastructureEncryptionEffect'
        }
        allowedValues: allowedValues
      }
      enableLogCheckpointsEffect: {
        type: 'String'
        metadata: {
          description: 'Enable log checkpoints.'
          displayName: 'enableLogCheckpointsEffect'
        }
        allowedValues: allowedValues
      }
      enableLogConnectionEffect: {
        type: 'String'
        metadata: {
          description: 'Enable log connections.'
          displayName: 'enableLogCheckpointsEffect'
        }
        allowedValues: allowedValues
      }
      enableLogDurationEffect: {
        type: 'String'
        metadata: {
          description: 'Enabled log duration.'
          displayName: 'enableLogDurationEffect'
        }
        allowedValues: allowedValues
      }
      useVirtualNetworkServiceEndpointEffect: {
        type: 'String'
        metadata: {
          description: 'Use a virtual network service endpoint.'
          displayName: 'useVirtualNetworkServiceEndpointEffect'
        }
        allowedValues: allowedValues
      }
      usePostgreCustomerManagedkeyEffect: {
        type: 'String'
        metadata: {
          description: 'Use customer-managed keys to encrypt data at rest.'
          displayName: 'usePostgreCustomerManagedkeyEffect'
        }
        allowedValues: allowedValues
      }
      enablePrivateEndpointEffect: {
        type: 'String'
        metadata: {
          description: 'Private endpoint connections enforce secure communication by enabling private connectivity to Azure Database for PostgreSQL. Configure a private endpoint connection to enable access to traffic coming only from known networks and prevent access from all other IP addresses, including within Azure.'
          displayName: 'enablePrivateEndpointEffect'
        }
        allowedValues: allowedValues
      }
      disablePublicAccessFlexiEffect: {
        type: 'String'
        metadata: {
          description: 'Disabled public network access for flexible servers.'
          displayName: 'disablePublicAccessFlexiEffect'
        }
        allowedValues: allowedValues
      }
      disablePostgresPublicAccessEffect: {
        type: 'String'
        metadata: {
          description: 'Disabled public network access for servers.'
          displayName: 'usePostgreCustomerManagedkeyEffect'
        }
        allowedValues: allowedValues
      }
    }

    policyDefinitions: [
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.enableConnectionThrottling.id)
        parameters: {
          effect: {
            value: '[parameters(\'enableConnectionThrottlingEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.disconnectionLogged.id)
        parameters: {
          effect: {
            value: '[parameters(\'disconnectionLoggedEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.enforceSslConnection.id)
        parameters: {
          effect: {
            value: '[parameters(\'enforceSslConnectionEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.geoRedundantBackup.id)
        parameters: {
          effect: {
            value: '[parameters(\'geoRedundantBackupEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.enableInfrastructureEncryption.id)
        parameters: {
          effect: {
            value: '[parameters(\'enableInfrastructureEncryptionEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.enforceSslConnection.id)
        parameters: {
          effect: {
            value: '[parameters(\'enableLogCheckpointsEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.enableLogConnection.id)
        parameters: {
          effect: {
            value: '[parameters(\'enableLogConnectionEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.enableLogDuration.id)
        parameters: {
          effect: {
            value: '[parameters(\'enableLogDurationEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.useVirtualNetworkServiceEndpoint.id)
        parameters: {
          effect: {
            value: '[parameters(\'useVirtualNetworkServiceEndpointEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.usePostgreCustomerManagedkey.id)
        parameters: {
          effect: {
            value: '[parameters(\'usePostgreCustomerManagedkeyEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.enablePrivateEndpoint.id)
        parameters: {
          effect: {
            value: '[parameters(\'enablePrivateEndpointEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.disablePublicAccessFlexi.id)
        parameters: {
          effect: {
            value: '[parameters(\'disablePublicAccessFlexiEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.disablePostgresPublicAccess.id)
        parameters: {
          effect: {
            value: '[parameters(\'disablePostgresPublicAccessEffect\')]'
          }
        }
      }
    ]
  }
}

//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: postgreSqlAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: postgreSqlAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      enableConnectionThrottlingEffect: {
        value: postgreSqlSettings.enableConnectionThrottlingEffect
      }
      disconnectionLoggedEffect: {
        value: postgreSqlSettings.disconnectionLoggedEffect
      }
      enforceSslConnectionEffect: {
        value: postgreSqlSettings.enforceSslConnectionEffect
      }
      geoRedundantBackupEffect: {
        value: postgreSqlSettings.geoRedundantBackupEffect
      }
      enableInfrastructureEncryptionEffect: {
        value: postgreSqlSettings.enableInfrastructureEncryptionEffect
      }
      enableLogConnectionEffect: {
        value: postgreSqlSettings.enableLogConnectionEffect
      }
      enableLogCheckpointsEffect: {
        value: postgreSqlSettings.enableLogCheckpointsEffect
      }
      enableLogDurationEffect: {
        value: postgreSqlSettings.enableLogDurationEffect
      }
      useVirtualNetworkServiceEndpointEffect: {
        value: postgreSqlSettings.useVirtualNetworkServiceEndpointEffect
      }
      usePostgreCustomerManagedkeyEffect: {
        value: postgreSqlSettings.usePostgreCustomerManagedkeyEffect
      }
      enablePrivateEndpointEffect: {
        value: postgreSqlSettings.enablePrivateEndpointEffect
      }
      disablePublicAccessFlexiEffect: {
        value: postgreSqlSettings.disablePublicAccessFlexiEffect
      }
      disablePostgresPublicAccessEffect: {
        value: postgreSqlSettings.disablePostgresPublicAccessEffect
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
}
