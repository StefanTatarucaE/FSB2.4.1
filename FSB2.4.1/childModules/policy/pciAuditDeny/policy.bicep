/*
SUMMARY: PCI Policy child module.
DESCRIPTION: Deployment of PCI Policy. Consists of assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription'

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param pciSettings object

@description('Specifies the policy set assignment name for pci change policy set')
param pciAuditDenySetAssignmentName string

@description('Specifies the policy set assignment display name for pci change policy set')
param pciAuditDenySetAssignmentDisplayName string

@description('Specify the policy definition id of the built-in PCI Initiative.')
param pciPolicyDefinitionId string

// VARIABLES
//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'PCI v4'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  policyDefinitionId: pciPolicyDefinitionId
}

// RESOURCE DEPLOYMENTS
//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: pciAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: pciAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      IncludeArcMachines: {
        value: pciSettings.includeArcMachines
      }
      listOfResourceTypesWithDiagnosticLogsEnabled: {
        value: pciSettings.listOfResourceTypesWithDiagnosticLogsEnabled
      }
    }
    policyDefinitionId: assignmentProperties.policyDefinitionId
  }
}

// OUTPUTS
