/*
SUMMARY: Audit Tag Policy child module.
DESCRIPTION: Deployment of Audit Tag Policy. Consists of definition & assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Set the tag name to be audited (checked if set) on resources.')
param tagName string

@description('Set the policy effect when the policy rule evaluates to true Possible values Audit, Deny or Disable.')
@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param policyEffect string

@description('Specify policy definition name for Tag Audit Deny')
param tagAuditDenyDefName string

@description('Specify policy displayname for Tag Audit Deny')
param tagAuditDenyDefDisplayName string

@description('Specify policy assignment name for Tag Audit Deny')
param tagAuditDenyDefAssignmentName string

@description('Specify policy assignment displayname for Tag Audit Deny')
param tagAuditDenyDefAssignmentDisplayName string

// VARIABLES
//Variable which holds the definition details
var definitionProperties = {
  description: 'Audit existence of a tag. Does not apply to resource groups.'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
    category: 'Tags'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Audit existence of a tag. Does not apply to resource groups.'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

// RESOURCE DEPLOYMENTS
//Deploy the policy definition
resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: tagAuditDenyDefName
  properties: {
    description: definitionProperties.description
    displayName: tagAuditDenyDefDisplayName
    metadata: definitionProperties.metadata
    mode: definitionProperties.mode
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'tagName'
        }
      }
      effect:{
        type: 'String'
        metadata: {
          displayName: 'effect'
        }
      }
    }
    policyRule: {
      if: {
        field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
        exists: 'false'
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
  name: tagAuditDenyDefAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: tagAuditDenyDefAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      tagName: {
        value: tagName
      }
      effect: {
        value: policyEffect
      }
    }
    policyDefinitionId: policyDefinition.id
  }
}

// OUTPUTS
