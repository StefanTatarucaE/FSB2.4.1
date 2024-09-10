/*
SUMMARY: Allowed Locations Policy child module.
DESCRIPTION: Deployment of Allowed Locations Policy. Consists of assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scop for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('The approved list of Azure regions where resources & resource groups can be deployed.')
param azureRegionsAllowed array

@description('Specify policy asignment name for allowed location for resources policy')
param allowedLocationResourcesDefAssignmentName string

@description('Specify policy asignment display name for allowed location for resources policy')
param allowedLocationResourcesDefAssignmentDisplayName string


@description('Specify policy asignment name for allowed location for resource group policy')
param allowedLocationRGDefAssignmentName string

@description('Specify policy asignment display name for allowed location for resource group policy')
param allowedLocationRgDefAssignmentDisplayName string

// VARIABLES

//Variable which holds the assignments (in an array) details
var policyAssignments = [
  {
    name: allowedLocationResourcesDefAssignmentName
    #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
    location: deployment().location
    identityType: 'None' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
    displayName: allowedLocationResourcesDefAssignmentDisplayName
    description: 'Enforce the use of only compliant Azure regions for resources.'
    metadata: {
      source: policyMetadata
      version: '0.0.1'
    }
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
  }
  {
    name: allowedLocationRGDefAssignmentName
    #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
    location: deployment().location
    identityType: 'None' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
    displayName: allowedLocationRgDefAssignmentDisplayName
    description: 'Enforce the use of only compliant Azure regions for resource groups.'
    metadata: {
      source: policyMetadata
      version: '0.0.1'
    }
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988'
  }
]

// RESOURCE DEPLOYMENTS
//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = [for policy in policyAssignments: {
  name: policy.name
  location: policy.location
  identity: {
    type: policy.identityType
  }
  properties: {
    description: policy.description
    displayName: policy.displayName
    metadata: policy.metadata
    parameters: {
      listOfAllowedLocations: {
        value: azureRegionsAllowed
      }
    }
    policyDefinitionId: policy.policyDefinitionId
  }
}]

// OUTPUTS
