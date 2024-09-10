/*
SUMMARY: Datafactory Change Policy child module.
DESCRIPTION: Deployment of Datafactory Change Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Desired effect to set, when a Data Factory instance with public network access enabled is detected.')
@metadata({
  displayName: 'Configure Data Factory to disable public network access.'
})
@allowed([
  'Modify'
  'Disabled'
])
param disablePublicNetworkAccessEffect string

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

@description('Specify policy definition name for data factory change')
param dataFactoryChangeSetName string

@description('Specify policy definition display name for data factory change')
param dataFactoryChangeSetDisplayName string

@description('Specify policy assignment name for datafactory change')
param dataFactoryChangeSetAssignmentName string

@description('Specify policy assignment display name for datafactory change')
param dataFactoryChangeSetAssignmentDisplayName string

@description('Specify policy definition name for data factory change')
param disablePublicNetworkAccessDefName string

@description('Specify policy definition display name for data factory change')
param disablePublicNetworkAccessDefDisplayName string

@description('Tag used for the policy rule')
param policyRuleTag string

// VARIABLES
// Variable which holds the disable public network access definition
var disablePublicNetworkAccessDefinitionProperties = {
  description: 'Disable public network access for your data Factory so that it is not accessible over the public internet. This can reduce data leakage risks.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'Data Factory'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
  parameters: {
    effect: {
      type: 'String'
    }
  }
}

// Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This policy set configures governance and security policies to Azure Datafactory'
  metadata: {
    category: 'Monitoring'
    source: policyMetadata
    version: '0.0.1'
  }
}

// Variables which holds the assignment details
var dataFactoryAssignmentProperties = {
   #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identity: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Azure Data Factory has relevant governance and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  roleDefinitionIdOrNames: [
    'Contributor'
  ]
}

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId,deployLocation),0 ,6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(dataFactoryChangeSetName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'

// RESOURCE DEPLOYMENTS
// Deploy the Datafactory Disable Public Network Deployment policy definition
resource disablePublicNetworkPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: disablePublicNetworkAccessDefName
  properties: {
    displayName: disablePublicNetworkAccessDefDisplayName
    description: disablePublicNetworkAccessDefinitionProperties.description
    policyType: disablePublicNetworkAccessDefinitionProperties.policyType
    mode: disablePublicNetworkAccessDefinitionProperties.mode
    metadata: disablePublicNetworkAccessDefinitionProperties.metadata
    parameters: disablePublicNetworkAccessDefinitionProperties.parameters
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DataFactory/factories'
          }
          {
            field: 'Microsoft.DataFactory/factories/publicNetworkAccess'
            notEquals: 'Disabled'
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
          conflictEffect: 'audit'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/673868aa-7521-48a0-acc6-0f60742d39f5'
          ]
          operations: [
            {
              operation: 'addOrReplace'
              field: 'Microsoft.DataFactory/factories/publicNetworkAccess'
              value: 'Disabled'
            }
          ]
        }
      }
    }
  }
}

// Deploy the Data Factory Change policy set definition
resource dataFactoryPolicySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: dataFactoryChangeSetName
  properties: {
    description: policySetDefinitionProperties.description
    displayName: dataFactoryChangeSetDisplayName
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      disablePublicNetworkAccess:{
        type: 'String'
        metadata: {
          displayName: 'disablePublicNetworkAccess'
          description: 'Disable public network access effect'
        }
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: disablePublicNetworkPolicy.id
        parameters: {
          effect: {
            value: '[parameters(\'disablePublicNetworkAccess\')]'
          }
        }
      }
    ]
  }
}

// Deploy the policy assignment
resource dataFactoryPolicyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: dataFactoryChangeSetAssignmentName
  location: dataFactoryAssignmentProperties.location
  properties: {
    displayName: dataFactoryChangeSetAssignmentDisplayName
    description: dataFactoryAssignmentProperties.description
    metadata: dataFactoryAssignmentProperties.metadata
    policyDefinitionId: dataFactoryPolicySetDefinition.id
    parameters: {
      disablePublicNetworkAccess: {
        value: disablePublicNetworkAccessEffect
      }
    }
  }
  identity: {
    type: dataFactoryAssignmentProperties.identity
  }
}

module policySystemManagedIdentityRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: dataFactoryPolicyAssignment.identity.principalId
    roleDefinitionIdOrNames: dataFactoryAssignmentProperties.roleDefinitionIdOrNames
  }
}

// OUTPUTS
output roleAssignmentDeployName string = policySystemManagedIdentityRoleAssignment.name
