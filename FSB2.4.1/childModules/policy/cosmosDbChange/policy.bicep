/*
SUMMARY: CosmosDB Governance and Security policies child module
DESCRIPTION: Deployment of CosmosDB governance and security policy set. 
             Module deploys the policy definitions, policy set, assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.3
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Desired effect to set, when a CosmosDb instance with local authentication is detected.')
@allowed([
  'Modify'
  'Disabled'
])
param disableLocalAuthenticationEffect string

@description('Desired effect to set, when a CosmosDb instance with local authentication is detected.')
@allowed([
  'Append'
  'Disabled'
])
param disableMetadataWriteAccessEffect string

@description('Desired effect to set for adisable Meta Data Write, when a managed CosmosDb instance is detected.')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param advancedThreatProtectionEffect string

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

@description('Specify def name for the AdvancedThreatProtection policy within the initiative')
param cosmosdbAdvancedThreatProtectionDefName string

@description('Specify def name for the DisableMetadataWriteAccess policy within the initiative')
param cosmosDbDisableMetadataWriteAccessDefName string

@description('Specify displayname for the AdvancedThreatProtection policy within the initiative')
param cosmosdbAdvancedThreatProtectionDefDisplayName string

@description('Specify displayname for the DisableMetadataWriteAccess policy within the initiative')
param cosmosDbDisableMetadataWriteAccessDefDisplayName string

@description('Specify def name for the DisableLocalAuthentication policy within the initiative')
param cosmosdbDisableLocalAuthenticationDefName string

@description('Specify displayname for the DisableLocalAuthentication policy within the initiative')
param cosmosdbDisableLocalAuthenticationDefDisplayName string

@description('Specify set name for storageAccount audit deny initiative')
param cosmosdbChangeSetName string

@description('Specify set displayname for storageAccount audit deny initiative')
param cosmosdbChangeSetDisplayName string

@description('Specify set assignment name for storageAccount audit deny initiative')
param cosmosdbChangeSetAssignmentName string

@description('Specify set assignment displayname for storageAccount audit deny initiative')
param cosmosdbChangeSetAssignmentDisplayName string

@description('Tag used for the policy rule')
param policyRuleTag string

// VARIABLES
//Variable which holds the definition set details
var disableLocalAuthenticationDefinitionProperties = {
  description: 'Disable local authentication methods so that your Cosmos DB database accounts exclusively require Azure Active Directory identities for authentication. Learn more at: https://docs.microsoft.com/azure/cosmos-db/how-to-setup-rbac#disable-local-auth.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'Cosmos DB'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
  parameters: {
    effect: {
      type: 'String'
    }
  }
}

//Variable which holds the definition set details
var disableMetadataWriteAccessDefinitionProperties = {
  description: 'This policy disables Metadata Write Access across Cosmos DB accounts.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'Cosmos DB'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
  parameters: {
    effect: {
      type: 'String'
    }
  }
}

//Variable which holds the definition set details
var advanceThreatProtectionDefinitionProperties = {
  description: 'This policy enables Advanced Threat Protection across Cosmos DB accounts.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'Cosmos DB'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
  parameters: {
    effect: {
      type: 'String'
    }
  }
}

// CosmosDB governance initiative properties
var cosmosDbPolicySetDefinitionProperties = {
  description: 'This initiative configures governance and security policies to Cosmos Db'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
    category: 'Monitoring'
  }
}

// Assignment properties
var cosmosDbPolicyAssignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identitytype: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Cosmos DB has relevant governane and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  roleDefinitionIdOrNames: [
    'Security Admin'
    'DocumentDB Contributor'
  ]
}

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployLocation), 0, 6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(cosmosdbChangeSetName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'

// RESOURCES
// Deploy the custom disable local authentication policy definition
resource disableLocalAuthenticationPolicyDefinition 'Microsoft.Authorization/policydefinitions@2020-09-01' = {
  name: cosmosdbDisableLocalAuthenticationDefName
  properties: {
    displayName: cosmosdbDisableLocalAuthenticationDefDisplayName
    policyType: disableLocalAuthenticationDefinitionProperties.policyType
    mode: disableLocalAuthenticationDefinitionProperties.mode
    description: disableLocalAuthenticationDefinitionProperties.description
    metadata: disableLocalAuthenticationDefinitionProperties.metadata
    parameters: disableLocalAuthenticationDefinitionProperties.parameters
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DocumentDB/databaseAccounts'
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
          {
            field: 'Microsoft.DocumentDB/databaseAccounts/disableLocalAuth'
            notEquals: true
          }
          {
            field: 'Microsoft.DocumentDB/databaseAccounts/capabilities[*].name'
            notin: [
              'EnableMongo'
              'EnableCassandra'
              'EnableTable'
              'EnableGremlin'
            ]
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/5bd9cd88-fe45-4216-938b-f97437e15450'
          ]
          conflictEffect: 'audit'
          operations: [
            {
              condition: '[greaterOrEquals(requestContext().apiVersion, \'2021-06-15\')]'
              operation: 'addOrReplace'
              field: 'Microsoft.DocumentDB/databaseAccounts/disableLocalAuth'
              value: true
            }
          ]
        }
      }
    }
  }
}

// Deploy the custom disable local authentication policy definition
resource disableMetadataWriteAccessPolicyDefinition 'Microsoft.Authorization/policydefinitions@2020-09-01' = {
  name: cosmosDbDisableMetadataWriteAccessDefName
  properties: {
    displayName: cosmosDbDisableMetadataWriteAccessDefDisplayName
    policyType: disableMetadataWriteAccessDefinitionProperties.policyType
    mode: disableMetadataWriteAccessDefinitionProperties.mode
    description: disableMetadataWriteAccessDefinitionProperties.description
    metadata: disableMetadataWriteAccessDefinitionProperties.metadata
    parameters: disableMetadataWriteAccessDefinitionProperties.parameters
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DocumentDB/databaseAccounts'
          }
          {
            field: 'Microsoft.DocumentDB/databaseAccounts/disableKeyBasedMetadataWriteAccess'
            notEquals: true
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: [ {
            roleDefinitionIds: [
              '/providers/Microsoft.Authorization/roleDefinitions/5bd9cd88-fe45-4216-938b-f97437e15450'
            ]

            field: 'Microsoft.DocumentDB/databaseAccounts/disableKeyBasedMetadataWriteAccess'
            value: true
          } ]

      }
    }
  }
}

// Deploy the custom advanced threat protection policy definition
resource advanceThreatProtectionPolicyDefinition 'Microsoft.Authorization/policydefinitions@2020-09-01' = {
  name: cosmosdbAdvancedThreatProtectionDefName
  properties: {
    displayName: cosmosdbAdvancedThreatProtectionDefDisplayName
    policyType: advanceThreatProtectionDefinitionProperties.policyType
    mode: advanceThreatProtectionDefinitionProperties.mode
    description: advanceThreatProtectionDefinitionProperties.description
    metadata: advanceThreatProtectionDefinitionProperties.metadata
    parameters: advanceThreatProtectionDefinitionProperties.parameters
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DocumentDB/databaseAccounts'
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Security/advancedThreatProtectionSettings'
          name: 'current'
          existenceCondition: {
            field: 'Microsoft.Security/advancedThreatProtectionSettings/isEnabled'
            equals: 'true'
          }
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/fb1c8493-542b-48eb-b624-b4c8fea62acd'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  cosmosDbAccountName: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    apiVersion: '2019-01-01'
                    type: 'Microsoft.DocumentDB/databaseAccounts/providers/advancedThreatProtectionSettings'
                    name: '[concat(parameters(\'cosmosDbAccountName\'), \'/Microsoft.Security/current\')]'
                    properties: {
                      isEnabled: true
                    }
                  }
                ]
              }
              parameters: {
                cosmosDbAccountName: {
                  value: '[field(\'name\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}

// Deploy the CosmosDB Change policy set definition
resource cosmosDbPolicySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: cosmosdbChangeSetName
  properties: {
    description: cosmosDbPolicySetDefinitionProperties.description
    displayName: cosmosdbChangeSetDisplayName
    metadata: cosmosDbPolicySetDefinitionProperties.metadata
    parameters: {
      disableLocalAuthentication: {
        type: 'String'
        metadata: {
          displayName: 'disableLocalAuthentication'
          description: 'Disable local authentication effect'
        }
      }
      advanceThreatProtection: {
        type: 'String'
        metadata: {
          displayName: 'advanceThreatProtection'
          description: 'Enable Advanced Threat Protection effect'
        }
      }
      disableMetadataWriteAccess: {
        type: 'String'
        metadata: {
          displayName: 'disableMetadataWriteAccess'
          description: 'Disable Metadata Write Access effect'
        }
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: disableLocalAuthenticationPolicyDefinition.id
        parameters: {
          effect: {
            value: '[parameters(\'disableLocalAuthentication\')]'
          }
        }
      }
      {
        policyDefinitionId: disableMetadataWriteAccessPolicyDefinition.id
        parameters: {
          effect: {
            value: '[parameters(\'disableMetadataWriteAccess\')]'
          }
        }
      }
      {
        policyDefinitionId: advanceThreatProtectionPolicyDefinition.id
        parameters: {
          effect: {
            value: '[parameters(\'advanceThreatProtection\')]'
          }
        }
      }
    ]
  }
}

// Deploy the policy assignment
resource cosmosDbPolicyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: cosmosdbChangeSetAssignmentName
  location: cosmosDbPolicyAssignmentProperties.location
  properties: {
    displayName: cosmosdbChangeSetAssignmentDisplayName
    description: cosmosDbPolicyAssignmentProperties.description
    metadata: cosmosDbPolicyAssignmentProperties.metadata
    policyDefinitionId: cosmosDbPolicySetDefinition.id
    parameters: {
      disableLocalAuthentication: {
        value: disableLocalAuthenticationEffect
      }
      advanceThreatProtection: {
        value: advancedThreatProtectionEffect
      }
      disableMetadataWriteAccess: {
        value: disableMetadataWriteAccessEffect
      }
    }
  }
  identity: {
    type: cosmosDbPolicyAssignmentProperties.identitytype
  }

}

module comsosDbPolicyRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: cosmosDbPolicyAssignment.identity.principalId
    roleDefinitionIdOrNames: cosmosDbPolicyAssignmentProperties.roleDefinitionIdOrNames
  }
}

// OUTPUTS
output roleAssignmentDeployName string = comsosDbPolicyRoleAssignment.name
