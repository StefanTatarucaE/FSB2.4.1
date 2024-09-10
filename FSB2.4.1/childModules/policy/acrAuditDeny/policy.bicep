/*
SUMMARY: ACR Audit/Deny Policy child module.
DESCRIPTION: Deployment of ACR Audit/Deny Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param acrSettings object

@description('Specify policy set name for acr auditdeny')
param acrAuditDenySetName string

@description('Specify policy set display name for acr auditdeny')
param acrAuditDenySetDisplayName string

@description('Specify policy set Assignment name for acr auditdeny')
param acrAuditDenySetAssignmentName string

@description('Specify policy set Assignment display name for auditdeny')
param acrAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variable for allowedValues.
var effectAuditDisabled = [
  'Audit'
  'Disabled'
]

var effectDeny = [
  'Deny'
]

var effectAuditDisabledDeny = concat(effectAuditDisabled,effectDeny)

@description('Specifies the ID of the policy definitions being assigned via the policy set definition.')
var policyDefinitionProperties = {
  adminAccountDisabled:{
    id: 'dc921057-6b28-4fbe-9b83-f7bec05db6c2'
  }
  anonymousPullDisabled:{
    id: '9f2dea28-e834-476c-99c5-3507b4728395'
  }
  cmkEncryptionEnabled:{
    id: '5b9159ae-1701-4a6f-9a7a-aa9c8ddd0580'
  }
  exportPolicy:{
    id: '524b0254-c285-4903-bee6-bb8126cde579'
  }
  networkRulesExist:{
    id: 'd0793b48-0edc-4296-a390-4c75d1bdfd71'
  }
  privateEndpointEnabled:{
    id: 'e8eef0a8-67cf-4eb4-9386-14b0e78733d4'
  }
  publicNetworkAccess:{
    id: '0fdf0491-d080-4575-b627-ad0e843cba0f'
  }
  skuSupportsPrivateEndpoints:{
    id: 'bd560fc0-3c69-498a-ae9f-aa8eb7de0e13'
  }
  tokenDisabled:{
    id: 'ff05e24e-195c-447e-b322-5e90c9f9f366'
  }
}

//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This policy set configures governance and security policies to Azure Container Registry'
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
  description: 'Ensures that Azure Container Registry has relevant governance and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

// RESOURCE DEPLOYMENTS
//Deploy the policy definition set for the definitions created in previous resource block
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: acrAuditDenySetName
  properties: {
    displayName: acrAuditDenySetDisplayName 
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      adminAccountDisabled: {
        type: 'String'
        metadata: {
          description: 'Container registries should have local authentication methods disabled. Allowed Values: Audit, Deny, Disabled'
          displayName: 'adminAccountDisabled'
        }
        allowedValues: effectAuditDisabledDeny
      }
      anonymousPullDisabled: {
        type: 'String'
        metadata: {
          description: 'Container registries should have anonymous authentication disabled. Allowed Values: Audit, Deny, Disabled'
          displayName: 'anonymousPullDisabled'
        }
        allowedValues: effectAuditDisabledDeny
      }
      cmkEncryptionEnabled: {
        type: 'String'
        metadata: {
          description: 'Container registries should be encrypted with a customer-managed key. Allowed Values: Audit, Deny, Disabled'
          displayName: 'cmkEncryptionEnabled'
        }
        allowedValues: effectAuditDisabledDeny
      }
      exportPolicy: {
        type: 'String'
        metadata: {
          description: 'Container registries should have exports disabled. Allowed Values: Audit, Deny, Disabled'
          displayName: 'exportPolicy'
        }
        allowedValues: effectAuditDisabledDeny
      }
      networkRulesExist: {
        type: 'String'
        metadata: {
          description: 'Container registries should have network rules configured. Allowed Values: Audit, Deny, Disabled'
          displayName: 'networkRulesExist'
        }
        allowedValues: effectAuditDisabledDeny
      }
      privateEndpointEnabled: {
        type: 'String'
        metadata: {
          description: 'Container registries should use private link. Allowed Values: Audit, Disabled'
          displayName: 'privateEndpointEnabled'
        }
        allowedValues: effectAuditDisabled
      }
      publicNetworkAccess: {
        type: 'String'
        metadata: {
          description: 'Public network access should be disabled for Container registries. Allowed Values: Audit, Deny, Disabled'
          displayName: 'publicNetworkAccess'
        }
        allowedValues: effectAuditDisabledDeny
      }
      skuSupportsPrivateEndpoints: {
        type: 'String'
        metadata: {
          description: 'Container registries should have SKUs that support Private Links. Allowed Values: Audit, Deny, Disabled'
          displayName: 'skuSupportsPrivateEndpoints'
        }
        allowedValues: effectAuditDisabledDeny
      }
      tokenDisabled: {
        type: 'String'
        metadata: {
          description: 'Container registries should have repository scoped access token disabled. Allowed Values: Audit, Deny, Disabled'
          displayName: 'tokenDisabled'
        }
        allowedValues: effectAuditDisabledDeny
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.adminAccountDisabled.id)
        parameters: {
          effect: {
            value: '[parameters(\'adminAccountDisabled\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.anonymousPullDisabled.id)
        parameters: {
          effect: {
            value: '[parameters(\'anonymousPullDisabled\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.cmkEncryptionEnabled.id)
        parameters: {
          effect: {
            value: '[parameters(\'cmkEncryptionEnabled\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.exportPolicy.id)
        parameters: {
          effect: {
            value: '[parameters(\'exportPolicy\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.networkRulesExist.id)
        parameters: {
          effect: {
            value: '[parameters(\'networkRulesExist\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.privateEndpointEnabled.id)
        parameters: {
          effect: {
            value: '[parameters(\'privateEndpointEnabled\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0fdf0491-d080-4575-b627-ad0e843cba0f'
        parameters: {
          effect: {
            value: '[parameters(\'publicNetworkAccess\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.skuSupportsPrivateEndpoints.id)
        parameters: {
          effect: {
            value: '[parameters(\'skuSupportsPrivateEndpoints\')]'
          }
        }
      }
      {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.tokenDisabled.id)
        parameters: {
          effect: {
            value: '[parameters(\'tokenDisabled\')]'
          }
        }
      }
    ]
  }
}

//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: acrAuditDenySetAssignmentName //assignmentProperties.name
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: acrAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      adminAccountDisabled: {
        value: acrSettings.adminAccountDisabled
      }
      anonymousPullDisabled: {
        value: acrSettings.anonymousPullDisabled
      }
      cmkEncryptionEnabled: {
        value: acrSettings.cmkEncryptionEnabled
      }
      exportPolicy: {
        value: acrSettings.exportPolicy
      }
      networkRulesExist: {
        value: acrSettings.networkRulesExist
      }
      privateEndpointEnabled: {
        value: acrSettings.privateEndpointEnabled
      }
      publicNetworkAccess: {
        value: acrSettings.publicNetworkAccess
      }
      skuSupportsPrivateEndpoints: {
        value: acrSettings.skuSupportsPrivateEndpoints
      }
      tokenDisabled: {
        value: acrSettings.tokenDisabled
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
}

// OUTPUTS
