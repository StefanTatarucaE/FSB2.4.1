/*
SUMMARY: Azure Database for MariaDB Audit/Deny Policy child module.
DESCRIPTION: Deployment of Azure Database for MariaDB Audit/Deny Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.
 
// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param mariaDbSettings object

@description('Specify set name for mariaDb audit deny initiative')
param mariaDbAuditDenySetName string

@description('Specify set displayname for mariaDb audit deny initiative')
param mariaDbAuditDenySetDisplayName string

@description('Specify set assignment name for mariaDb audit deny initiative')
param mariaDbAuditDenySetAssignmentName string

@description('Specify set assignment displayname for mariaDb audit deny initiative')
param mariaDbAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variable for allowedValues relevant for 'Geo-redundant backup should be enabled for Azure Database for MariaDB' and 'Public network access should be disabled for MariaDB servers' policies set definition parameters.
var effectAuditDisabled = [
  'Audit'
  'Disabled'
]
// Variable for allowedValues relevant for 'MariaDB server should use a virtual network service endpoint' and 'Private endpoint should be enabled for MariaDB servers' policies set definition parameters.
var effectAuditIfNotExistsDisabled = [
  'AuditIfNotExists'
  'Disabled'
]

//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This policy set configures governance and security policies to Azure Database for MariaDB'
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
  description: 'Ensures that Azure Database for MariaDB has relevant governance and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

// RESOURCE DEPLOYMENTS
//Deploy the policy definition set for the definitions created in previous resource block
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: mariaDbAuditDenySetName
  properties: {
    displayName: mariaDbAuditDenySetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      geoRedundantBackupEnabledEffect: {
        type: 'String'
        metadata: {
          description: 'Geo-redundant backup should be enabled for Azure Database for MariaDB'
          displayName: 'geoRedundantBackupEnabledEffect'
        }
        allowedValues: effectAuditDisabled
      }
      useVirtualNetwokServiceEndPointEffect: {
        type: 'String'
        metadata: {
          description: 'MariaDB server should use a virtual network service endpoint'
          displayName: 'useVirtualNetwokServiceEndPointEffect'
        }
        allowedValues: effectAuditIfNotExistsDisabled
      } 
      privateEndPointEnabledEffect: {
        type: 'String'
        metadata: {
          description: 'Private endpoint should be enabled for MariaDB servers'
          displayName: 'privateEndPointEnabledEffect'
        }
        allowedValues: effectAuditIfNotExistsDisabled
      }
      mariadbPublicNetworkAccessDisableEffect: {
        type: 'String'
        metadata: {
          description: 'Public network access should be disabled for MariaDB servers'
          displayName: 'mariadbPublicNetworkAccessDisableEffect'
        }
        allowedValues: effectAuditDisabled
      }
    }
  policyDefinitions: [
    {
      policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0ec47710-77ff-4a3d-9181-6aa50af424d0'
      parameters: {
        effect: {
          value: '[parameters(\'geoRedundantBackupEnabledEffect\')]'
        }
      }
    }
    {
      policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/dfbd9a64-6114-48de-a47d-90574dc2e489'
      parameters: {
        effect: {
          value: '[parameters(\'useVirtualNetwokServiceEndPointEffect\')]'
        }
      }
    }
    {
      policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0a1302fb-a631-4106-9753-f3d494733990'
      parameters: {
        effect: {
          value: '[parameters(\'privateEndPointEnabledEffect\')]'
        }
      }
    }
    {
      policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/fdccbe47-f3e3-4213-ad5d-ea459b2fa077'
      parameters: {
        effect: {
          value: '[parameters(\'mariadbPublicNetworkAccessDisableEffect\')]'
        }
      }
    }
  ]  
  }
}  

//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: mariaDbAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: mariaDbAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      geoRedundantBackupEnabledEffect: {
        value: mariaDbSettings.geoRedundantBackupEnabledEffect
      }
      useVirtualNetwokServiceEndPointEffect: {
        value: mariaDbSettings.useVirtualNetwokServiceEndPointEffect
      }
      privateEndPointEnabledEffect: {
        value: mariaDbSettings.privateEndPointEnabledEffect
      }
      mariadbPublicNetworkAccessDisableEffect: {
        value: mariaDbSettings.mariadbPublicNetworkAccessDisableEffect
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
}

// OUTPUTS
