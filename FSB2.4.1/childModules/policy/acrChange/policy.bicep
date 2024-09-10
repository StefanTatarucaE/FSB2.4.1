/*
SUMMARY: ACR Change Policy child module.
DESCRIPTION: Deployment of ACR Change Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.2
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Tag used for the policy rule')
param policyRuleTag string

@description('Configure container registries to disable local authentication.')
@allowed([
  'Modify'
  'Disabled'
])
param acrDisableLocalAuthentication string

@description('Configure container registries to disable repository scoped access token.')
@allowed([
  'Modify'
  'Disabled'
])
param acrDisableTokenAccess string

@description('Configure container registries to disable anonymous authentication.')
@allowed([
  'Modify'
  'Disabled'
])
param acrDisableAnonymousAuthentication string

@description('Configure Container registries to disable public network access')
@allowed([
  'Modify'
  'Disabled'
])
param acrDisablePublicNetworkAccess string

@description('Specify policy name for disable ACR local authentication policy')
param acrDisableLocalAuthenticationDefName string

@description('Specify policy display name for disable ACR local authentication policy')
param acrDisableLocalAuthenticationDefDisplayName string

@description('Specify policy name for disable ACR token access policy')
param acrDisableTokenAccessDefName string

@description('Specify policy display name for disable ACR token access policy')
param acrDisableTokenAccessDefDisplayName string

@description('Specify policy name for disable ACR anonymous authentication policy')
param acrDisableAnonymousAuthenticationDefName string

@description('Specify policy display name for disable ACR anonymous authentication policy')
param acrDisableAnonymousAuthenticationDefDisplayName string

@description('Specify policy name for disable ACR public network access policy')
param acrDisablePublicNetworkAccessDefName string

@description('Specify policy display name for disable ACR public network access policy')
param acrDisablePublicNetworkAccessDefDisplayName string

@description('Specify policy set name for acr disable initiative')
param acrDisableSetName string

@description('Specify policy set display name for acr disable initiative')
param acrDisableSetDisplayName string

@description('Specify policy asignment name for acr disable initiative')
param acrDisableSetAssignmentName string

@description('Specify policy asignment display name for acr disable initiative')
param acrDisableSetAssignmentDisplayName string

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

// VARIABLES

// This variable holds disable ACR local authentication policy details
var disableAcrLocalAuthenticationDefinitionProperties = {
  description: 'Disable local authentication so that your container registries exclusively require Azure Active Directory identities for authentication. Learn more about at: https://aka.ms/acr/authentication.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'Container Registry'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

// This variable holds disable ACR token access policy details
var disableAcrTokenAccessDefinitionProperties = {
  description: 'Disable repository scoped access tokens for your registry so that repositories are not accessible by tokens. Disabling local authentication methods like admin user, repository scoped access tokens and anonymous pull improves security by ensuring that container registries exclusively require Azure Active Directory identities for authentication. Learn more at: https://aka.ms/acr/authentication.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'Container Registry'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

// This variable holds disable ACR anonymous authentication policy details
var disableAcrAnonymousAuthentication = {
  description: 'Disable anonymous pull for your registry so that data not accessible by unauthenticated user. Disabling local authentication methods like admin user, repository scoped access tokens and anonymous pull improves security by ensuring that container registries exclusively require Azure Active Directory identities for authentication. Learn more at: https://aka.ms/acr/authentication.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'Container Registry'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

// This variable holds disable ACR public network access policy details
var disableAcrPublicNetworkAccess = {
  description: 'Disable public network access for your Container Registry resource so that it\'s not accessible over the public internet. This can reduce data leakage risks. Learn more at https://aka.ms/acr/portal/public-network and https://aka.ms/acr/private-link.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'Container Registry'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

// This variable holds initiative details for ACR change
var acrPolicySetDefinitionProperties = {
  description: 'This initiative configures governance and security policies to Azure Container Registry'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'Container Registry'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

// This variablethe assignment details for acr change initiative
var acrAssignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identity: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Azure Container Registry has relevant governane and security policies'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
  }
  roleDefinitionIdOrNames: [
    'Contributor'
  ]
}

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId,deployLocation),0 ,6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(acrDisableSetName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'

// RESOURCES

// ACR Disable local authentication 
resource disableAcrLocalAuthenticationPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: acrDisableLocalAuthenticationDefName
  properties: {
    displayName: acrDisableLocalAuthenticationDefDisplayName
    description: disableAcrLocalAuthenticationDefinitionProperties.description
    policyType: disableAcrLocalAuthenticationDefinitionProperties.policyType
    mode: disableAcrLocalAuthenticationDefinitionProperties.mode
    metadata: disableAcrLocalAuthenticationDefinitionProperties.metadata
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.ContainerRegistry/registries'
          }
          {
            field: 'Microsoft.ContainerRegistry/registries/adminUserEnabled'
            equals: true
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
        ]
      }
      then: {
        effect: acrDisableLocalAuthentication
        details: {
          conflictEffect: 'audit'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          operations: [
            {
              operation: 'addOrReplace'
              field: 'Microsoft.ContainerRegistry/registries/adminUserEnabled'
              value: false
            }
          ]
        }
      }
    }
  }
}

// ACR Disable token access
resource disableAcrTokenAuthenticationPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: acrDisableTokenAccessDefName
  properties: {
    displayName: acrDisableTokenAccessDefDisplayName
    description: disableAcrTokenAccessDefinitionProperties.description
    policyType: disableAcrTokenAccessDefinitionProperties.policyType
    mode: disableAcrTokenAccessDefinitionProperties.mode
    metadata: disableAcrTokenAccessDefinitionProperties.metadata
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.ContainerRegistry/registries/tokens'
          }
          {
            field: 'Microsoft.ContainerRegistry/registries/tokens/status'
            notequals: 'disabled'
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
        ]
      }
      then: {
        effect: acrDisableTokenAccess
        details: {
          conflictEffect: 'audit'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          operations: [
            {
              operation: 'addOrReplace'
              field: 'Microsoft.ContainerRegistry/registries/tokens/status'
              value: 'disabled'
            }
          ]
        }
      }
    }
  }
}

// ACR disable anonymous authentication
resource disableAcrAnonymousAuthenticationPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: acrDisableAnonymousAuthenticationDefName
  properties: {
    displayName: acrDisableAnonymousAuthenticationDefDisplayName
    description: disableAcrAnonymousAuthentication.description
    policyType: disableAcrAnonymousAuthentication.policyType
    mode: disableAcrAnonymousAuthentication.mode
    metadata: disableAcrAnonymousAuthentication.metadata
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.ContainerRegistry/registries'
          }
          {
            field: 'Microsoft.ContainerRegistry/registries/anonymousPullEnabled'
            equals: true
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
        ]
      }
      then: {
        effect: acrDisableAnonymousAuthentication
        details: {
          conflictEffect: 'audit'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          operations: [
            {
              operation: 'addOrReplace'
              field: 'Microsoft.ContainerRegistry/registries/anonymousPullEnabled'
              value: false
            }
          ]
        }
      }
    }
  }
}

// ACR disable public network access 
resource disableAcrPublicNetworkAccessPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: acrDisablePublicNetworkAccessDefName
  properties: {
    displayName: acrDisablePublicNetworkAccessDefDisplayName
    description: disableAcrPublicNetworkAccess.description
    policyType: disableAcrPublicNetworkAccess.policyType
    mode: disableAcrPublicNetworkAccess.mode
    metadata: disableAcrPublicNetworkAccess.metadata
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.ContainerRegistry/registries'
          }
          {
            field: 'Microsoft.ContainerRegistry/registries/sku.name'
            equals: 'Premium'
          }
          {
            field: 'Microsoft.ContainerRegistry/registries/publicNetworkAccess'
            notEquals: 'Disabled'
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
        ]
      }
      then: {
        effect: acrDisablePublicNetworkAccess
        details: {
          conflictEffect: 'audit'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          operations: [
            {
              operation: 'addOrReplace'
              field: 'Microsoft.ContainerRegistry/registries/publicNetworkAccess'
              value: 'Disabled'
            }
          ]
        }
      }
    }
  }
}

// ACR Change Initiative
resource acrPolicySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: acrDisableSetName
  properties: {
    description: acrPolicySetDefinitionProperties.description
    displayName: acrDisableSetDisplayName
    metadata: acrPolicySetDefinitionProperties.metadata
    parameters: {}
    policyDefinitions: [
      {
        policyDefinitionId: disableAcrLocalAuthenticationPolicyDefinition.id
      }
      {
        policyDefinitionId: disableAcrTokenAuthenticationPolicyDefinition.id
      }
      {
        policyDefinitionId: disableAcrAnonymousAuthenticationPolicyDefinition.id
      }
      {
        policyDefinitionId: disableAcrPublicNetworkAccessPolicyDefinition.id
      }
    ]
  }
}

// ACR Change Initiative Assignment
resource acrPolicyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: acrDisableSetAssignmentName
  location: acrAssignmentProperties.location
  identity: {
    type: acrAssignmentProperties.identity
  }
  properties: {
    displayName: acrDisableSetAssignmentDisplayName
    description: acrAssignmentProperties.description
    metadata: acrAssignmentProperties.metadata
    policyDefinitionId: acrPolicySetDefinition.id
    parameters: {
    }
  }
}


// Deploy the Role assignment for ACR change initiative
module policySystemManagedIdentityRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: acrPolicyAssignment.identity.principalId
    roleDefinitionIdOrNames: acrAssignmentProperties.roleDefinitionIdOrNames
  }
}
// OUTPUTS
output roleAssignmentDeployName string = policySystemManagedIdentityRoleAssignment.name
