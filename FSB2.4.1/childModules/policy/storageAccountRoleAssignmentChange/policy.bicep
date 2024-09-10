/*
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object Id of the tenant Key Vault App')
param keyVaultAppObjectId string

@description('Specify set name for storageAccount audit deny initiative')
param storageAccountRoleAssignmentChangePolicyName string

@description('Specify set displayname for storageAccount audit deny initiative')
param storageAccountRoleAssignmentChangePolicyDisplayName string

@description('Specify set assignment name for storageAccount audit deny initiative')
param storageAccountRoleAssignmentChangePolicyAssignmentName string

@description('Specify set assignment displayname for storageAccount audit deny initiative')
param storageAccountRoleAssignmentChangePolicyAssignmentDisplayName string

@description('Tag used for the policy rule')
param policyRuleTag array

// VARIABLES

var StorageAccountKeyMgmtDefinitionProperties = {
  description: 'Assigns Storage Account Key Operator Service Role to storage accounts'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'Storage Accounts'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
  parameters: {
    keyVaultAppObjectId: {
      type: 'String'
    }
  }
}

// Assignment properties
var storageAccountPolicyAssignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployLocation
  identitytype: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Prepares the storage accounts with specific tags for key management with key vaults'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
  }
  roleDefinitionIdOrNames: [
    'Contributor'
    'User Access Administrator'
  ]
}

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployLocation), 0, 6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(storageAccountRoleAssignmentChangePolicyName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'

// RESOURCES

resource storageAccountPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: storageAccountRoleAssignmentChangePolicyName
  properties: {
    displayName: storageAccountRoleAssignmentChangePolicyDisplayName
    policyType: StorageAccountKeyMgmtDefinitionProperties.policyType
    mode: StorageAccountKeyMgmtDefinitionProperties.mode
    description: StorageAccountKeyMgmtDefinitionProperties.description
    metadata: StorageAccountKeyMgmtDefinitionProperties.metadata
    parameters: StorageAccountKeyMgmtDefinitionProperties.parameters
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Storage/storageAccounts'
          }
          {
            field: 'tags.${policyRuleTag[0]}'
            equals: true
          }
          {
            field: 'tags.${policyRuleTag[1]}'
            equals: true
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Authorization/roleAssignments'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Authorization/roleAssignments/roleDefinitionId'
                contains: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/81a9662b-bebf-436f-a333-f67b29880f12'
              }
              {
                field: 'Microsoft.Authorization/roleAssignments/principalId'
                contains: keyVaultAppObjectId
              }
              {
                field: 'Microsoft.Authorization/roleAssignments/scope'
                contains: '[field(\'name\')]'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                keyVaultAppObjectId: {
                  value: '[parameters(\'keyVaultAppObjectId\')]'
                }
                storageAccountId: {
                  value: '[field(\'id\')]'
                }
              }
              template: {
                '$schema': 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  keyVaultAppObjectId: {
                    type: 'string'
                  }
                  storageAccountId: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    type: 'Microsoft.Authorization/roleAssignments'
                    apiVersion: '2022-04-01'
                    name: '[guid(subscription().subscriptionId, parameters(\'storageAccountId\'), \'81a9662b-bebf-436f-a333-f67b29880f12\')]'
                    scope: '[parameters(\'storageAccountId\')]'
                    properties: {
                      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '81a9662b-bebf-436f-a333-f67b29880f12')
                      principalId: '[parameters(\'keyVaultAppObjectId\')]'
                      principalType: 'ServicePrincipal'
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

// Deploy the policy assignment
resource storageAccountPolicyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: storageAccountRoleAssignmentChangePolicyAssignmentName
  location: storageAccountPolicyAssignmentProperties.location
  properties: {
    displayName: storageAccountRoleAssignmentChangePolicyAssignmentDisplayName
    description: storageAccountPolicyAssignmentProperties.description
    metadata: storageAccountPolicyAssignmentProperties.metadata
    policyDefinitionId: storageAccountPolicyDefinition.id
    parameters: {
      keyVaultAppObjectId: {
        value: keyVaultAppObjectId
      }
    }
  }
  identity: {
    type: storageAccountPolicyAssignmentProperties.identitytype
  }

}

module storageAccountPolicyRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: storageAccountPolicyAssignment.identity.principalId
    roleDefinitionIdOrNames: storageAccountPolicyAssignmentProperties.roleDefinitionIdOrNames
  }
}

// OUTPUTS
output roleAssignmentDeployName string = storageAccountPolicyRoleAssignment.name
