/*
SUMMARY: Resourcegroup naming convention audit Policy child module.
DESCRIPTION: Deployment of Resourcegroup naming convention audit Policy. Consists of definition & assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Set the policy effect when the policy rule evaluates to true Possible values Audit, Deny or Disable.')
@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param policyEffect string

@description('Specify policy name for RsgName convention Audit Deny')
param rsgNameConventionsAuditDenyDefName string

@description('Specify policy display name for RsgName convention Audit Deny')
param rsgNameConventionsAuditDenyDefDisplayName string

@description('Specify policy assignment name for RsgName convention Audit Deny')
param rsgNameConventionsAuditDenyDefAssignmentName string

@description('Specify policy assignment display name for RsgName convention Audit Deny')
param rsgNameConventionsAuditDenyDefAssignmentDisplayName string

// VARIABLES
//Variable which holds the definition details
var definitionProperties = {
  description: 'Name convention auditdeny policy definition'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
    category: 'General'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'None' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Audit naming convention compliance'
  metadata: {
    source: policyMetadata 
    version: '0.0.1'
  }
}

// RESOURCE DEPLOYMENTS
//Deploy the policy definition
resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: rsgNameConventionsAuditDenyDefName
  properties: {
    description: definitionProperties.description
    displayName: rsgNameConventionsAuditDenyDefDisplayName
    metadata: definitionProperties.metadata
    mode: definitionProperties.mode
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'effect'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Resources/subscriptions/resourceGroups'
          }
          {
            not: {
              anyOf: [
                {
                  value: '[take(field(\'Name\'), 15)]'
                  match: '...-....-?-rsg-'
                }
                {
                  value: '[take(field(\'Name\'), 13)]'
                  contains: 'databricks-rg'
                }
              ]
            }
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
    policyType: definitionProperties.policyType
  }
}

//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: rsgNameConventionsAuditDenyDefAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: rsgNameConventionsAuditDenyDefAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      effect: {
        value: policyEffect
      }
    }
    policyDefinitionId: policyDefinition.id
  }
}

// OUTPUTS
