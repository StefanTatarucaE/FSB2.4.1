/*
SUMMARY: Azure Defender Export to Loganalytics policy child module
DESCRIPTION: Deployment of Azure defender export change policy.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scop for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Resource group name where the export to Log Analytics Workspace configuration will be stored, will be created if not exists')
param resourceGroupName string

@description('Specifies the location of the policy assignment')
param location string = deployment().location

@description('Specify name for assignment of Defender export change policy')
param azDefenderDataExportDefAssignmentName string

@description('Specify policy assignment display name for azure defender data export')
param azDefenderDataExportDefAssignmentDisplayName string

@description('Specify policy definition name for azure defender data export')
param azDefenderDataExportDefName string

@description('The Id of the management subscription. To be provided by the Monitoring parent module')
param managementSubscriptionId string

@description('The data types to be exported. To export a snapshot (preview) of the data once a week, choose the data types which contains snapshot, other data types will be sent in real-time streaming.')
@allowed([
  'Security recommendations'
  'Security alerts'
  'Overall secure score'
  'Secure score controls'
  'Regulatory compliance'
  'Overall secure score snapshot'
  'Secure score controls - snapshot'
  'Regulatory compliance - snapshot'
  'Security recommendations - snapshot'
  'Security findings - snapshot'
])
param exportedDatatypes array

@description('Applicable only for export of security recommendations. To export all recommendations, leave this empty.')
param recommendationNames array

@description('Applicable only for export of security recommendations. Determines recommendation severities')
@allowed([
  'High'
  'Medium'
  'Low'
])
param recommendationSeverities array

@description('Security findings are results from vulnerability assessment solutions, and can be thought of as sub recommendations grouped into a parent recommendation.')
param isSecurityFindingsEnabled bool

param createResourceGroup bool
@description('If a resource group does not exists in the scope, a new resource group will be created. If the resource group exists and this flag is set to true the policy will re-deploy the resource group.')
param secureScoreControlsNames array

@description('Alert Severities array')
@allowed([
  'High'
  'Medium'
  'Low'
  'Informational'
])
param alertSeverities array

@description('Applicable only for export of regulatory compliance. To export all regulatory compliance, leave this empty.')
param regulatoryComplianceStandardsNames array

@description('Specifies the ResourceID of the log analytics workspace')
param workspaceResourceID string

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(azDefenderDataExportDefName, '-'))}-${uniqueDeployPrefix}-role-deploy'

//Variable used to construct the name of the Role Assignment Deployment on the Management Subscription
var roleAssignmentNameMgmt = '${first(split(azDefenderDataExportDefName, '-'))}-${uniqueDeployPrefix}-mgmt-role-deploy'

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, location), 0, 6)

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Deploy export to Log Analytics workspace for Microsoft Defender for Cloud data'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
    category: 'Monitoring'
  }
  roleDefinitionIdOrNames: [
    'Contributor' // The contributor permission is needed to allow the workflow automation resource to be created by the policy
  ]
  policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ffb6f416-7bd2-4488-8828-56585fef2be9'
}

// RESOURCE DEPLOYMENTS
//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: azDefenderDataExportDefAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: azDefenderDataExportDefAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      'resourceGroupName': {
        value: resourceGroupName
      }
      'resourceGroupLocation': {
        value: location
      }
      'exportedDataTypes': {
        value: exportedDatatypes
      }
      'isSecurityFindingsEnabled': {
        value: isSecurityFindingsEnabled
      }
      'workspaceResourceId': {
        value: workspaceResourceID
      }
      'createResourceGroup': {
        value: createResourceGroup
      }
      'recommendationNames': {
        value: recommendationNames
      }
      'recommendationSeverities': {
        value: recommendationSeverities
      }
      'secureScoreControlsNames': {
        value: secureScoreControlsNames
      }
      'alertSeverities': {
        value: alertSeverities
      }
      'regulatoryComplianceStandardsNames': {
        value: regulatoryComplianceStandardsNames
      }
    }
    policyDefinitionId: assignmentProperties.policyDefinitionId
  }
}

//Deploy the Role assignments for the policy set assignment
module policyRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: policyAssignment.identity.principalId
    roleDefinitionIdOrNames: assignmentProperties.roleDefinitionIdOrNames
  }
}

//Deploy also the Role assignment to the MGMT subscription if called on another subscription
module policyRoleAssignmentMgmtSub '../../roleAssignment/roleAssignment.bicep' = if (managementSubscriptionId != subscription().subscriptionId) {
  name: roleAssignmentNameMgmt
  scope: subscription(managementSubscriptionId)
  params: {
    managedIdentityId: policyAssignment.identity.principalId
    roleDefinitionIdOrNames: assignmentProperties.roleDefinitionIdOrNames
  }
}

// OUTPUTS
