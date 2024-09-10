/*
SUMMARY: Monitoring diagnostic rules Policy child module.
DESCRIPTION: These diagnostic rules cover all managed resources types, and are sending metrics and logs to the log analytics workspace.
AUTHOR/S: frederic.trapet@eviden.com
VERSION: 0.2
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. MGs are not targeted yet.

// PARAMETERS

@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Specifies the location of the diagnostic rules')
param location string = deployment().location

@description('Specifies the ResourceID of the log analytics workspace')
param workspaceResourceID string

@description('The Id of the management subscription. To be provided by the Monitoring parent module')
param managementSubscriptionId string

@description('Deployment scope for this child module')
@allowed([
  'core'
  'network'
  'osmgmt'
  'paas'
])
param deploymentScope string

@description('Tag prefix used within the policy rule')
param tagPrefix string

// VARIABLES

//Specifies the diagnostic rule name that will be created on managed resources (harcoded because it needs to be the same for all rules)
var diagnosticRuleName = '${tagPrefix}DiagnosticRule-SendToLogAnalytics'

// specify the managed tag name that will be used to filter the resource
var policyRuleTag = '${tagPrefix}Managed'


//Variable which holds the definition set details
var policySetDefinitionProperties = {
  name: '${toLower(deploymentScope)}.diagrules.change.policy.set'
  displayName: 'Diagnostic settings change policy set - ${deploymentScope} - log analytics'
  description: 'This initiative configures application Azure resources to forward diagnostic logs and metrics to an Azure Log Analytics workspace.'
  metadata: {
    category: 'Monitoring'
    source: policyMetadata
    version: '0.0.1'
  }
}

//Variable which holds the assignment details
var assignmentProperties = {
  name: '${toLower(deploymentScope)}.diagrules.change.policy.set.assignment'
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  displayName: 'Diagnostic settings change policy set assignment - ${deploymentScope} - log analytics'
  description: 'This initiative configures application Azure resources to forward diagnostic logs and metrics to an Azure Log Analytics workspace.'
  metadata: {
    category: 'Monitoring'
    source: policyMetadata
    version: '0.0.1'
  }
  roleDefinitionIdOrNames: [
    'Log Analytics Contributor'
    'Monitoring Contributor'
  ]
}

//Variable which holds the definition details
var definitionProperties = {
  nameSuffix : 'diagrule.change.policy.def'
  displayNamePrefix : 'Apply diagnostic settings for'
  displayNameSuffix : '- Log Analytics'
  description: 'This policy automatically deploys and enable diagnostic settings to Log Analytics'
  metadata: {
    category: 'Monitoring'
    source: policyMetadata
    version: '0.0.1'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
  parameters: {
    logAnalytics: {
      type: 'String'
      metadata: {
        displayName: 'Log Analytics workspace'
        description: 'Select Log Analytics workspace from dropdown list'
        strongType: 'omsWorkspace'
        assignPermissions: true
      }
    }
  }
  // Filters for company resources that have the managed tag set (including product deployed resources)
  managedTagsConditions: [
    {
      field: 'tags.${policyRuleTag}'
      exists: 'true'
    }
    {
      field: 'tags.${policyRuleTag}'
      notContains: 'false'
    }
    {
      field: 'tags.${policyRuleTag}'
      notequals: ''
    }
  ]
  // Roles definitions IDs that are needed for the diagnostic rule policies
  roleDefinitionIds: [
    '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'   // Monitoring Contributor
    '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'   // Log Analytics Contributor
  ]

  // API version for diagrule deployment. For now, we need to use this specific version because newer ones are not working as expected.
  diagRulesApiVersion: '2017-05-01-preview'

  // Common parameters for resource deployment properties
  commonDeploymentResourceProperties: {
    workspaceId: '[[parameters(\'logAnalytics\')]'
  }
}

//Load the log alerts definitions files
var diagnosticRulesData = {
  core: {
    definition: json(loadTextContent('diagnosticRulesPolicies.core.json'))
  }
  network: {
    definition: json(loadTextContent('diagnosticRulesPolicies.network.json'))
  }
  osmgmt: {
    definition: json(loadTextContent('diagnosticRulesPolicies.osmgmt.json'))
  }
  paas: {
    definition: json(loadTextContent('diagnosticRulesPolicies.paas.json'))
  }
}

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId,location),0 ,6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(definitionProperties.nameSuffix, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'

//Variable used to construct the name of the Role Assignment Deployment on the Management Subscription
var roleAssignmentNameMgmt = '${first(split(definitionProperties.nameSuffix, '-'))}-${uniqueDeployPrefix}-mgmt-roleAssignment-deployment'

// RESOURCE DEPLOYMENTS

//Deploy policies definitions for all diagnostic rules in a loop, with the rule properties taken from the JSON Data file
resource diagnosticRulesPolicyDefinitions 'Microsoft.Authorization/policyDefinitions@2021-06-01' = [for diagRule in diagnosticRulesData[deploymentScope].definition.diagnosticRules: {
  name: '${toLower(diagRule.shortName)}.${definitionProperties.nameSuffix}'
  properties: {
    description: definitionProperties.description
    displayName: '${definitionProperties.displayNamePrefix} ${diagRule.displayName} ${definitionProperties.displayNameSuffix}'
    metadata: definitionProperties.metadata
    mode: definitionProperties.mode
    parameters: definitionProperties.parameters
    policyRule: {
      if: {
        allOf: (diagRule.filterOnCompanyManagedTag == true) ? union(diagRule.policyFilters, definitionProperties.managedTagsConditions) : diagRule.policyFilters
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          deploymentScope: (diagRule.deployAtSubscriptionLevel == true) ? 'Subscription' : 'ResourceGroup'
          existenceScope: (diagRule.deployAtSubscriptionLevel == true) ? 'Subscription' : 'ResourceGroup'
          roleDefinitionIds: definitionProperties.roleDefinitionIds
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Insights/diagnosticSettings/${(diagRule.useMetricsExistenceCondition == true) ? 'metrics[*]' : 'logs'}.enabled'
                equals: 'True'
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/workspaceId'
                matchInsensitively: '[parameters(\'logAnalytics\')]'
              }
            ]
          }
          deployment: {
            location: (diagRule.deployAtSubscriptionLevel == true) ? location : null
            properties: {
              mode: 'incremental'
              template: {
                '$schema': (diagRule.deployAtSubscriptionLevel == true) ? 'https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#' : 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: {
                    type: 'string'
                  }
                  resourceFullName: {
                    type: 'string'
                  }
                  resourceId: {
                    type: 'string'
                  }
                  logAnalytics: {
                    type: 'string'
                    metadata: {
                      description: 'The ResourceID of the Log Analytics workspace where data will be sent'
                    }
                  }
                }
                resources: [for deploymentResource in diagRule.deploymentResources: {
                  // construct the diagnostic rule name Id, see README for details
                  name: startsWith(deploymentResource.name, '[') ? '[${replace(deploymentResource.name, '{diagnosticRuleName}', diagnosticRuleName)}' : replace(deploymentResource.name, '{diagnosticRuleName}', diagnosticRuleName)
                  type: deploymentResource.type
                  location: location
                  apiVersion: definitionProperties.diagRulesApiVersion
                  properties: union(definitionProperties.commonDeploymentResourceProperties, deploymentResource.properties)
                }]
              }
              parameters: {
                logAnalytics: {
                  value: '[parameters(\'logAnalytics\')]'
                }
                resourceName: {
                  value: '[field(\'name\')]'
                }
                resourceFullName: {
                  value: '[field(\'fullName\')]'
                }
                resourceId: {
                  value: '[field(\'id\')]'
                }
              }
            }
          }
        }
      }
    }
    policyType: definitionProperties.policyType
  }
}]

//Deploy the policy definition set for the definitions created in previous resource block, taking the definitions ID in a loop from the JSON Data file
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  dependsOn: [
    diagnosticRulesPolicyDefinitions
  ]
  name: policySetDefinitionProperties.name
  properties: {
    displayName: policySetDefinitionProperties.displayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      logAnalytics: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics workspace'
          description: 'Select the Log Analytics workspace from dropdown list'
          strongType: 'omsWorkspace'
        }
      }
    }
    policyDefinitions: [for diagRule in diagnosticRulesData[deploymentScope].definition.diagnosticRules: {
        policyDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/${toLower(diagRule.shortName)}.${definitionProperties.nameSuffix}'
        parameters: {
          logAnalytics: {
            value: '[[parameters(\'logAnalytics\')]'
          }
        }
    }]
  }
}

//Deploy the policy assignment for the created policy set
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: assignmentProperties.name
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: assignmentProperties.displayName
    metadata: assignmentProperties.metadata
    parameters: {
      logAnalytics: {
        value: workspaceResourceID
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
}

//Deploy the Role assignments for the policy set assignment
module diagRulePolicyRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: policyAssignment.identity.principalId
    roleDefinitionIdOrNames: assignmentProperties.roleDefinitionIdOrNames
  }
}

//Deploy also the Role assignment to the MGMT subscription if called on another subscription
module diagRulePolicyRoleAssignmentMgmtSub '../../roleAssignment/roleAssignment.bicep' = if (managementSubscriptionId != subscription().subscriptionId) {
  name: roleAssignmentNameMgmt
  scope: subscription(managementSubscriptionId)
  params: {
    managedIdentityId: policyAssignment.identity.principalId
    roleDefinitionIdOrNames: assignmentProperties.roleDefinitionIdOrNames
  }
}

// OUTPUTS
output roleAssignmentDeployName string = diagRulePolicyRoleAssignment.name
