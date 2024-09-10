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

@description('The approved list of Virtual Machine SKUs. Use prevent_deploy for MGMT & CNTY Subscription!')
param virtualMachineSkusAllowed array

@description('Specify policy asignment name for allowed VM SKU policy')
param allowedVmSkuDefAssignmentName string

@description('Specify policy asignment display name for allowed VM SKU policy')
param allowedVmSkuDefAssignmentDisplayName string

// VARIABLES

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'None' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Allowed Virtual Machine SKUs that can be deployed in this subscription.'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3'
}

// RESOURCE DEPLOYMENTS
//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: allowedVmSkuDefAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: allowedVmSkuDefAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      listOfAllowedSKUs: {
        value: virtualMachineSkusAllowed
      }
    }
    policyDefinitionId: assignmentProperties.policyDefinitionId
  }
}

// OUTPUTS
