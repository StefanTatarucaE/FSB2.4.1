/*
SUMMARY: Allowed VM Sizes Policy child module.
DESCRIPTION: Deployment of Allowed VM Sizes Policy. Consists of assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription'

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('The list of Resource Types that are not allowed in the environment.')
param resourceTypesNotAllowed array

@description('Specify policy assignment name for Block Resource Type Change')
param blockResourceTypeAuditDenyDefAssignmentName string

@description('Specify policy assignment display name for Block Resource Type Change')
param blockResourceTypeAuditDenyDefAssignmentDisplayName string

// VARIABLES
//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'None' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Resource Types that are not allowed in the environment'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749'
}

// RESOURCE DEPLOYMENTS
//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: blockResourceTypeAuditDenyDefAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: blockResourceTypeAuditDenyDefAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      listOfResourceTypesNotAllowed: {
        value: resourceTypesNotAllowed
      }
    }
    policyDefinitionId: assignmentProperties.policyDefinitionId
  }
}

// OUTPUTS
