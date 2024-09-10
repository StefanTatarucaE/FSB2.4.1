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

@description('Object which sets the values of the policy set definition parameters.')
param iso27001Settings object

@description('Specify policy set Assignment name for iso 27001 Audit Deny')
param iso27001AuditDenySetAssignmentName string

@description('Specify policy set Assignment display name for iso 27001 Audit Deny')
param iso27001AuditDenySetAssignmentDisplayName string

@description('Specify the policy definition id of the built-in ISO Initiative.')
param isoPolicyDefinitionId string

// VARIABLES
//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'ISO 27001 policy set.'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  policyDefinitionId: isoPolicyDefinitionId
}

// RESOURCE DEPLOYMENTS
//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: iso27001AuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: iso27001AuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      'IncludeArcMachines': {
        value: iso27001Settings.includeArcMachines
      }
      'listOfResourceTypesWithDiagnosticLogsEnabled': {
        value: iso27001Settings.listOfResourceTypesWithDiagnosticLogsEnabled
      }
      'metricsEnabled-7f89b1eb-583c-429a-8828-af049802c1d9': {
        value: iso27001Settings.includeMetricsDiagnosticLogging
      }
      'logsEnabled-7f89b1eb-583c-429a-8828-af049802c1d9': {
        value: iso27001Settings.includeLogsDiagnosticLogging
      }
    }
    policyDefinitionId: assignmentProperties.policyDefinitionId
  }
}

// OUTPUTS
