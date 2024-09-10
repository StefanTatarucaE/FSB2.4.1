/*
SUMMARY: Storage Account Audit/Deny Policy child module.
DESCRIPTION: Deployment of Sorage Account Audit/Deny Policy set. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param storageAccountSettings object

@description('Specify def name for the AccountFilesyncprivatednszone policy within the initiative')
param storageAccountFilesyncprivatednszoneDefName string

@description('Specify def displayname for the AccountFilesyncprivatednszone policy within the initiative')
param storageAccountFilesyncprivatednszoneDefDisplayName string

@description('Specify set name for storageAccount audit deny initiative')
param storageAccountAuditDenySetName string

@description('Specify set displayname for storageAccount audit deny initiative')
param storageAccountAuditDenySetDisplayName string

@description('Specify set assignment name for storageAccount audit deny initiative')
param storageAccountAuditDenySetAssignmentName string

@description('Specify set assignment displayname for storageAccount audit deny initiative')
param storageAccountAuditDenySetAssignmentDisplayName string

// VARIABLES
var effectAuditDisabled = [
  'Audit'
  'Disabled'
]

var effectDeny = [
  'Deny'
]

var effectAuditIfNotExistsDisabled = [
  'AuditIfNotExists'
  'Disabled'
]

var effectAuditDenyDisabled = concat(effectAuditDisabled, effectDeny)

var storageSyncPrivateDnsZoneDefinitionProperties = {
  description: 'To access the private endpoint(s) for Storage Sync Service resource interfaces from a registered server, you need to configure your DNS to resolve the correct names to your private endpoint\'s private IP addresses. This policy creates the requisite Azure Private DNS Zone and A records for the interfaces of your Storage Sync Service private endpoint(s).'
  metadata: {
    source: policyMetadata
    version: '1.0.0' //not incremented since only the deployment language was changed.
    category: 'Storage'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

var policySetDefinitionProperties = {
  description: 'This policy set configures Governance and Security policies to Azure Storage Account'
  metadata: {
    category: 'Monitoring'
    source: policyMetadata
    verion: '0.0.1'
  }
}

var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Storage Account has relevant Governance and Security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

// RESOURCE DEPLOYMENTS
resource storageSyncPrivateDnsZonePolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: storageAccountFilesyncprivatednszoneDefName
  properties: {
    displayName: storageAccountFilesyncprivatednszoneDefDisplayName
    description: storageSyncPrivateDnsZoneDefinitionProperties.description
    metadata: storageSyncPrivateDnsZoneDefinitionProperties.metadata
    policyType: storageSyncPrivateDnsZoneDefinitionProperties.policyType
    mode: storageSyncPrivateDnsZoneDefinitionProperties.mode
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Network/privateEndpoints'
          }
          {
            count: {
              field: 'Microsoft.Network/privateEndpoints/privateLinkServiceConnections[*].groupIds[*]'
              where: {
                field: 'Microsoft.Network/privateEndpoints/privateLinkServiceConnections[*].groupIds[*]'
                equals: 'afs'
              }
            }
            greaterOrEquals: 1
          }
        ]
      }
      then: {
        effect: storageAccountSettings.storageSyncPrivateDnsZoneAuditIfNotExists
      }
    }
  }
}

resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: storageAccountAuditDenySetName
  properties: {
    displayName: storageAccountAuditDenySetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      allowedStorageSkusAudit: {
        type: 'string'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Storage accounts should be limited by allowed SKUs'
        }
        allowedValues: effectAuditDenyDisabled
      }
      auditForClassicStorage: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Storage accounts should be migrated to new Azure Resource Manager resources'
        }
        allowedValues: effectAuditDenyDisabled
      }
      geoRedundantStorageAccountsAudit: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Geo-redundant storage should be enabled for Storage Accounts'

        }
        allowedValues: effectAuditDenyDisabled
      }
      storageAccountAllowCrossTenantReplicationAudit: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Storage accounts should prevent cross tenant object replication'
        }
        allowedValues: effectAuditDenyDisabled
      }
      storageAccountAllowSharedKeyAccessAudit: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Storage accounts should prevent shared key access'
        }
        allowedValues: effectAuditDenyDisabled
      }
      storageAccountInfrastructureEncryptionEnabledAudit: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Storage accounts should have infrastructure encryption'
        }
        allowedValues: effectAuditDenyDisabled
      }
      storageAccountKeysExpiredRestrict: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Storage account keys should not be expired'
        }
        allowedValues: effectAuditDenyDisabled
      }
      storageAccountPrivateEndpointEnabledAudit: {
        type: 'String'
        metadata: {
          description: 'Allowed values are AuditIfNotExists and Disabled'
          displayName: 'Storage accounts should use private link'
        }
        allowedValues: effectAuditIfNotExistsDisabled
      }
      storageAccountSasPolicyRestrict: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Storage accounts should have shared access signature (SAS) policies configured'
        }
        allowedValues: effectAuditDenyDisabled
      }
      storageEncryptionScopesShouldUseDoubleEncryptionAudit: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Storage account encryption scopes should use double encryption for data at rest'
        }
        allowedValues: effectAuditDenyDisabled
      }
      storageQueueCustomerManagedKeyEnabledAudit: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Queue Storage should use customer-managed key for encryption'
        }
        allowedValues: effectAuditDenyDisabled
      }
      storageSyncIncomingTrafficPolicyAuditDeny: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Public network access should be disabled for Azure File Sync'
        }
        allowedValues: effectAuditDenyDisabled
      }
      storageSyncPrivateEndpointAuditIfNotExists: {
        type: 'String'
        metadata: {
          description: 'Allowed values are AuditIfNotExists and Disabled'
          displayName: 'Azure File Sync should use private link'
        }
        allowedValues: effectAuditIfNotExistsDisabled
      }
      storageTableCustomerManagedKeyEnabledAudit: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Table Storage should use customer-managed key for encryption'
        }
        allowedValues: effectAuditDenyDisabled
      }
      storageEncryptionScopesShouldUseCmkAudit: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit, Deny and Disabled'
          displayName: 'Storage account encryption scopes should use customer-managed keys to encrypt data at rest'
        }
        allowedValues: effectAuditDenyDisabled
      }
      virtualNetworkServiceEndpointStorageAccountAudit: {
        type: 'String'
        metadata: {
          description: 'Allowed values are Audit and Disabled'
          displayName: 'Storage Accounts should use a virtual network service endpoint'
        }
        allowedValues: effectAuditDisabled
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/7433c107-6db4-4ad1-b57a-a76dce0154a1'
        parameters: {
          effect: {
            value: '[parameters(\'allowedStorageSkusAudit\')]'
          }
          listOfAllowedSKUs: {
            value: storageAccountSettings.storageAccountListOfAllowedSkus
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/37e0d2fe-28a5-43d6-a273-67d37d1f5606'
        parameters: {
          effect: {
            value: '[parameters(\'auditForClassicStorage\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/bf045164-79ba-4215-8f95-f8048dc1780b'
        parameters: {
          effect: {
            value: '[parameters(\'geoRedundantStorageAccountsAudit\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/92a89a79-6c52-4a7e-a03f-61306fc49312'
        parameters: {
          effect: {
            value: '[parameters(\'storageAccountAllowCrossTenantReplicationAudit\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/8c6a50c6-9ffd-4ae7-986f-5fa6111f9a54'
        parameters: {
          effect: {
            value: '[parameters(\'storageAccountAllowSharedKeyAccessAudit\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/4733ea7b-a883-42fe-8cac-97454c2a9e4a'
        parameters: {
          effect: {
            value: '[parameters(\'storageAccountInfrastructureEncryptionEnabledAudit\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/044985bb-afe1-42cd-8a36-9d5d42424537'
        parameters: {
          effect: {
            value: '[parameters(\'storageAccountKeysExpiredRestrict\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/6edd7eda-6dd8-40f7-810d-67160c639cd9'
        parameters: {
          effect: {
            value: '[parameters(\'storageAccountPrivateEndpointEnabledAudit\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/bc1b984e-ddae-40cc-801a-050a030e4fbe'
        parameters: {
          effect: {
            value: '[parameters(\'storageAccountSasPolicyRestrict\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/bfecdea6-31c4-4045-ad42-71b9dc87247d'
        parameters: {
          effect: {
            value: '[parameters(\'storageEncryptionScopesShouldUseDoubleEncryptionAudit\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/f0e5abd0-2554-4736-b7c0-4ffef23475ef'
        parameters: {
          effect: {
            value: '[parameters(\'storageQueueCustomerManagedKeyEnabledAudit\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/21a8cd35-125e-4d13-b82d-2e19b7208bb7'
        parameters: {
          effect: {
            value: '[parameters(\'storageSyncIncomingTrafficPolicyAuditDeny\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1d320205-c6a1-4ac6-873d-46224024e8e2'
        parameters: {
          effect: {
            value: '[parameters(\'storageSyncPrivateEndpointAuditIfNotExists\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/7c322315-e26d-4174-a99e-f49d351b4688'
        parameters: {
          effect: {
            value: '[parameters(\'storageTableCustomerManagedKeyEnabledAudit\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/b5ec538c-daa0-4006-8596-35468b9148e8'
        parameters: {
          effect: {
            value: '[parameters(\'storageEncryptionScopesShouldUseCmkAudit\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/60d21c4f-21a3-4d94-85f4-b924e6aeeda4'
        parameters: {
          effect: {
            value: '[parameters(\'virtualNetworkServiceEndpointStorageAccountAudit\')]'
          }
        }
      }
      {
        policyDefinitionId: storageSyncPrivateDnsZonePolicy.id
      }
    ]
  }
}

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: storageAccountAuditDenySetAssignmentName
  location: assignmentProperties.location
  properties: {
    displayName: storageAccountAuditDenySetAssignmentDisplayName
    description: assignmentProperties.description
    metadata: assignmentProperties.metadata
    policyDefinitionId: policySetDefinition.id
    parameters: {
      allowedStorageSkusAudit: {
        value: storageAccountSettings.allowedStorageSkusAudit
      }
      auditForClassicStorage: {
        value: storageAccountSettings.auditForClassicStorage
      }
      geoRedundantStorageAccountsAudit: {
        value: storageAccountSettings.geoRedundantStorageAccountsAudit
      }
      storageAccountAllowCrossTenantReplicationAudit: {
        value: storageAccountSettings.storageAccountAllowCrossTenantReplicationAudit
      }
      storageAccountAllowSharedKeyAccessAudit: {
        value: storageAccountSettings.storageAccountAllowSharedKeyAccessAudit
      }
      storageAccountInfrastructureEncryptionEnabledAudit: {
        value: storageAccountSettings.storageAccountInfrastructureEncryptionEnabledAudit
      }
      storageAccountKeysExpiredRestrict: {
        value: storageAccountSettings.storageAccountKeysExpiredRestrict
      }
      storageAccountPrivateEndpointEnabledAudit: {
        value: storageAccountSettings.storageAccountPrivateEndpointEnabledAudit
      }
      storageAccountSasPolicyRestrict: {
        value: storageAccountSettings.storageAccountSasPolicyRestrict
      }
      storageEncryptionScopesShouldUseDoubleEncryptionAudit: {
        value: storageAccountSettings.storageEncryptionScopesShouldUseDoubleEncryptionAudit
      }
      storageQueueCustomerManagedKeyEnabledAudit: {
        value: storageAccountSettings.storageQueueCustomerManagedKeyEnabledAudit
      }
      storageSyncIncomingTrafficPolicyAuditDeny: {
        value: storageAccountSettings.storageSyncIncomingTrafficPolicyAuditDeny
      }
      storageSyncPrivateEndpointAuditIfNotExists: {
        value: storageAccountSettings.storageSyncPrivateEndpointAuditIfNotExists
      }
      storageTableCustomerManagedKeyEnabledAudit: {
        value: storageAccountSettings.storageTableCustomerManagedKeyEnabledAudit
      }
      storageEncryptionScopesShouldUseCmkAudit: {
        value: storageAccountSettings.storageEncryptionScopesShouldUseCmkAudit
      }
      virtualNetworkServiceEndpointStorageAccountAudit: {
        value: storageAccountSettings.virtualNetworkServiceEndpointStorageAccountAudit
      }
    }
  }
  identity: {
    type: assignmentProperties.identityType
  }
}
