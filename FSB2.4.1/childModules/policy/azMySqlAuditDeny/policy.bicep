/*
SUMMARY: MySql Audit/Deny Policy child module.
DESCRIPTION: Deployment of MySql Audit/Deny Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param mySqlSettings object

@description('Specify set name for mysql audit deny initiative')
param mySqlAuditDenySetName string

@description('Specify displayname for mysql audit deny initiative')
param mySqlAuditDenySetDisplayName string

@description('Specify set assignment name for mysql audit deny initiative')
param mySqlAuditDenySetAssignmentName string

@description('Specify set assignment displayname for mysql audit deny initiative')
param mySqlAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variable for allowedValues which is different depending on allowed policy effect.
var commonAllowedValues = [
  'Audit'
  'deny'
  'Disabled'
]

var auditAllowedValues = [
  'Audit'
  'Disabled'
]

var AuditIfNotExistsAllowedValues = [
  'AuditIfNotExists'
  'Disabled'
]

//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This policy set configures governance and security policies to Azure MySql Databases'
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
  description: 'Ensures that Azure MySql Database has relevant governance and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

// RESOURCE DEPLOYMENTS
//Deploy the policy definition set for the definitions created in previous resource block
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: mySqlAuditDenySetName
  properties: {
    displayName: mySqlAuditDenySetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      enableSslConnection: {
        type: 'String'
        metadata: {
          description: 'Enforce SSL connection should be enabled.'
          displayName: 'enableSslConnection'
        }
        allowedValues: auditAllowedValues
      }
      enableGeoRedundantBackup: {
        type: 'String'
        metadata: {
          description: 'Geo-redundant backup should be enabled.'
          displayName: 'enableGeoRedundantBackup'
        }
        allowedValues: auditAllowedValues
      }
      enableInfraEncryption: {
        type: 'String'
        metadata: {
          description: 'Infrastructure encryption should be enabled.'
          displayName: 'enableInfraEncryption'
        }
        allowedValues: commonAllowedValues
      }
      useVirtualNetworkServiceEndpoint: {
        type: 'String'
        metadata: {
          description: 'Use a virtual network service endpoint.'
          displayName: 'useVirtualNetworkServiceEndpoint'
        }
        allowedValues: AuditIfNotExistsAllowedValues
      }
      useCustomerManagedKeyMySql: {
        type: 'String'
        metadata: {
          description: 'Use customer-managed keys to encrypt data at rest.'
          displayName: 'useCustomerManagedKeyMySql'
        }
        allowedValues: AuditIfNotExistsAllowedValues
      }
      enablePrivateEndpointMySql: {
        type: 'String'
        metadata: {
          description: 'Private endpoint should be enabled.'
          displayName: 'enablePrivateEndpointMySql'
        }
        allowedValues: AuditIfNotExistsAllowedValues
      }
      disablePublicAccessFlexibleMySql: {
        type: 'String'
        metadata: {
          description: 'Public network access should be disabled for flexible servers.'
          displayName: 'disablePublicAccessFlexibleMySql'
        }
        allowedValues: commonAllowedValues
      }
      disablePublicAccessMySql: {
        type: 'String'
        metadata: {
          description: 'Public network access should be disabled.'
          displayName: 'disablePublicAccessMySql'
        }
        allowedValues: commonAllowedValues
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e802a67a-daf5-4436-9ea6-f6d821dd0c5d'
        parameters: {
          effect: {
            value: '[parameters(\'enableSslConnection\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/82339799-d096-41ae-8538-b108becf0970'
        parameters: {
          effect: {
            value: '[parameters(\'enableGeoRedundantBackup\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/3a58212a-c829-4f13-9872-6371df2fd0b4'
        parameters: {
          effect: {
            value: '[parameters(\'enableInfraEncryption\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/3375856c-3824-4e0e-ae6a-79e011dd4c47'
        parameters: {
          effect: {
            value: '[parameters(\'useVirtualNetworkServiceEndpoint\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/83cef61d-dbd1-4b20-a4fc-5fbc7da10833'
        parameters: {
          effect: {
            value: '[parameters(\'useCustomerManagedKeyMySql\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/7595c971-233d-4bcf-bd18-596129188c49'
        parameters: {
          effect: {
            value: '[parameters(\'enablePrivateEndpointMySql\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/c9299215-ae47-4f50-9c54-8a392f68a052'
        parameters: {
          effect: {
            value: '[parameters(\'disablePublicAccessFlexibleMySql\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/d9844e8a-1437-4aeb-a32c-0c992f056095'
        parameters: {
          effect: {
            value: '[parameters(\'disablePublicAccessMySql\')]'
          }
        }
      }
    ]
  }
}

//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: mySqlAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: mySqlAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      enableSslConnection: {
        value: mySqlSettings.enableSslConnection
      }
      enableGeoRedundantBackup: {
        value: mySqlSettings.enableGeoRedundantBackup
      }
      enableInfraEncryption: {
        value: mySqlSettings.enableInfraEncryption
      }
      useVirtualNetworkServiceEndpoint: {
        value: mySqlSettings.useVirtualNetworkServiceEndpoint
      }
      useCustomerManagedKeyMySql: {
        value: mySqlSettings.useCustomerManagedKeyMySql
      }
      enablePrivateEndpointMySql: {
        value: mySqlSettings.enablePrivateEndpointMySql
      }
      disablePublicAccessFlexibleMySql: {
        value: mySqlSettings.disablePublicAccessFlexibleMySql
      }
      disablePublicAccessMySql: {
        value: mySqlSettings.disablePublicAccessMySql
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
}

// OUTPUTS
