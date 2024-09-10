/*
SUMMARY: Monitoring solution
DESCRIPTION: Parent module to deploy the monitoring solution.
             Consists of Log Analytics Workspace, DataSources, Solutions, Alerts and Policies
AUTHOR/S: frederic.trapet@eviden.com
VERSION: 0.5
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

// PARAMETERS
@description('Required. Specifies the location of the Monitoring solution resources.')
param location string = deployment().location

@description('Optional. A mapping of additional tags to assign to the resource.')
param additionalMonitoringTags object

@description('Deployment scope for this child module. To be provided by the pipeline')
@allowed([
  'core'
  'network'
  'osmgmt'
  'paas'
])
param deploymentScope string

@description('Required. Defines The name of the SKU. Valid options are Free, PerGB2018, Standard or Premium.')
@allowed([
  'Free'
  'PerGB2018'
  'Standard'
  'Premium'
])
param monitoringWorkspaceSkuName string

@description('Required. The workspace data retention in days.')
param dataRetentionDefault int

@description('Parameter to determine the subscription using abbreviation. To be provided by the pipeline')
@allowed([
  'mgmt'
  'cnty'
  'lndz'
  'tool'
])
param subscriptionType string

@description('The Id of the management subscription. To be provided by the pipeline.')
param managementSubscriptionId string

@description('Optional. Custom table archival periods')
param setRetentionDays array

@description('Optional. The ApplicationID of the service principal that runs the GitHub action workflow.')
param callerServicePrincipalAppId string = 'n/a'

// VARIABLES
//Variables to load in the naming convention files for resource naming.
var namingJsonData = {
  mgmt: {
    definition: json(loadTextContent('../../mgmtNaming.json'))
  }
  cnty: {
    definition: json(loadTextContent('../../cntyNaming.json'))
  }
  lndz: {
    definition: json(loadTextContent('../../lndzNaming.json'))
  }
  tool: {
    definition: json(loadTextContent('../../toolNaming.json'))
  }
}
var namingData = namingJsonData[subscriptionType].definition
var productCode = namingData.productCode.name

// Name of the monitoring resource group
var monitoringResourceGroupName = namingData.monitoringResourceGroup.name

// Name of the Update Manager resource group

var customerUpdateManagerResourceGroupName = namingJsonData.mgmt.definition.customerUpdateManagerResourceGroup.name

// Name of the Loganalytics workspace
var workspaceName = namingJsonData.mgmt.definition.monitoringWorkspace.name

// Name of the action group
var actionGroupName = namingJsonData.mgmt.definition.managementITSMActionGroupsIntegration.name
var actionGroupInternalName = '${toUpper(productCode)}AZ-ITSM' //action group internal short name is intentionally hardcoded as it's not used for any reference

//Name of the Monitoring User Assigned Managed Identity in mgmt.
var monitoringUserManagedIdentityName = namingJsonData.mgmt.definition.monitoringUserManagedIdentityName.name

// Load the Log-analytics alerts definitions from JSON files
var logAlertsData = {
  core: {
    definition: json(replace(loadTextContent('logAnalyticsAlerts.core.json'), '[parameter(callerAppId)]', '${callerServicePrincipalAppId}'))
  }
  network: {
    definition: json(replace(loadTextContent('logAnalyticsAlerts.network.json'), '[parameter(callerAppId)]', '${callerServicePrincipalAppId}'))
  }
  osmgmt: {
    definition: json(replace(replace(loadTextContent('logAnalyticsAlerts.osmgmt.json'), '[parameter(productCode)]', '${productCode}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'))
  }
  paas1: {
    definition: json(loadTextContent('logAnalyticsAlerts.paas1.json'))
  }
  paas2: {
    definition: json(loadTextContent('logAnalyticsAlerts.paas2.json'))
  }
}
// If JSON files are over 130k, they need to be splitted in different parts, and joined using union.
var scopeLogAlertsData = (deploymentScope != 'paas') ? logAlertsData[deploymentScope].definition.alertRules : union(logAlertsData.paas1.definition.alertRules, logAlertsData.paas2.definition.alertRules)

// Load the serviceHealth and resourceHealth alerts definition from JSON file
var activityLogAlertsData = json(loadTextContent('activityLogAlerts.json'))

// Set variable for workspace and action group to get the right resourceID from the module or the existing resources
var workspaceResourceID = (subscriptionType == 'mgmt') ? ((deploymentScope == 'core') ? monitoringWorkspace.outputs.workspaceResourceID : existingMonitoringWorkspace.id) : existingWorkspaceInMgmt.outputs.resourceID
var actionGroupResourceID = (subscriptionType == 'mgmt') ? ((deploymentScope == 'core') ? actionGroup.outputs.actionGroupResourceID : existingActionGroup.id) : existingActionGroupInMgmt.outputs.resourceID

// Set the variable for the monitoring user managed identity
var monitoringUserManagedIdentityPrincipleId = ((subscriptionType == 'lndz') && (deploymentScope == 'osmgmt')) ? existingMonitoringUserManagedIdentityInMgmt.outputs.resourceID : (subscriptionType == 'mgmt') ? monitoringUserManagedIdentity.outputs.userManagedIdentityPrincipalId : ''
var monitoringUserManagedIdentityResourceId = ((subscriptionType == 'lndz') && (deploymentScope == 'osmgmt')) ? existingMonitoringUserManagedIdentityInMgmt.outputs.resourceID : (subscriptionType == 'mgmt') ? monitoringUserManagedIdentity.outputs.userManagedIdentityResourceID : ''


// Names for the azDefenderDataExportChangePolicy definition & assignment
var azDefenderDataExportChangeDefName = namingData.azDefenderDataExportChangePolicy.azDefenderDataExportChangeDefName
var azDefenderDataExportChangeDefAssignmentName = namingData.azDefenderDataExportChangePolicy.azDefenderDataExportChangeDefAssignmentName
var azDefenderDataExportChangeDefAssignmentDisplayName = namingData.azDefenderDataExportChangePolicy.azDefenderDataExportChangeDefAssignmentDisplayName

// Define tags for resources
var tagPrefix = namingData.tagPrefix.name
var tagValuePrefix = namingData.tagValuePrefix.name
var managedTag = '${tagPrefix}Managed'
var tags = union(additionalMonitoringTags, { '${tagPrefix}Purpose': '${tagValuePrefix}Monitoring' })
var workspaceTags = union(tags, { '${managedTag}': 'true' })
var resourceGroupTags = union(tags, { '${managedTag}': 'true' })
var alertTags = union(tags, { '${managedTag}': 'true' })
var policyMeteringTag = '${namingData.company.name}${namingData.productCode.name}'
var actionGroupTags = union(tags, { '${managedTag}': 'true' })
var dcrTags = union(tags, { '${managedTag}': 'true' })
var userManagedIdentityTags = union(tags, { '${managedTag}': 'true' })


// Variable which holds a unique value for deployment, which is bound to the subscription id and deployment location.
#disable-next-line no-loc-expr-outside-params
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployment().location), 0, 6)

// Variable to load default ELZ for Azure configuration. No need to expose via parameters in parent module.
var parentModuleConfig = loadJsonContent('parentModuleConfig.json')

//Role definitions for the User Managed Identity used for ARG Alerts as used on the monitoring resource group in the MGMT subscription.
var roleDefinitionIdOrNamesForMgmtSubArgAlerts =  [
  'Log Analytics Reader'
]

//Role definitions for the User Managed Identity used for ARG Alerts as used on the landingzone subscription & on the Update Manager ResourceGroup.
var roleDefinitionIdOrNamesForArgAlertsReader =  [
  'Reader'
]

// RESOURCE DEPLOYMENTS

// Role assignments for the Monitoring User Managed Identity used for ARG Alerts in the MGMT subscription
module roleAssignmentResourceGroupArgAlert '../../childModules/roleAssignment/roleAssignmentResourceGroup.bicep' = if ((subscriptionType == 'mgmt') && (deploymentScope == 'core')) {
  name: 'resourceGroupRoleAssignmentMonitoring-argAlerts'
  dependsOn: [
    monitoringUserManagedIdentity
  ]
  scope: monitoringResourceGroup
  params: {
    managedIdentityId: monitoringUserManagedIdentityPrincipleId
    roleDefinitionIdOrNames: roleDefinitionIdOrNamesForMgmtSubArgAlerts
  }
}

// In any subscription type for CORE, create a resource group to hold the monitoring resources.
resource monitoringResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (deploymentScope == 'core') {
  name: monitoringResourceGroupName
  location: location
  tags: resourceGroupTags
}

// In MGMT subscription, deploy the Workspace for CORE or reference the existing workspace if already created
module monitoringWorkspace '../../childModules/workspace/workspace.bicep' = if ((subscriptionType == 'mgmt') && (deploymentScope == 'core')) {
  scope: monitoringResourceGroup
  name: 'monitoringWorkspace-deployment'
  params: {
    workspaceName: workspaceName
    skuName: monitoringWorkspaceSkuName
    location: location
    tags: workspaceTags
    retentionInDays: dataRetentionDefault
    publicNetworkAccess: parentModuleConfig.monitoringWorkspacePublicNetworkAccess
    dataSources: parentModuleConfig.dataSources
    solutions: parentModuleConfig.solutions
    setRetentionDays:setRetentionDays
  }
}

resource existingMonitoringWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if ((subscriptionType == 'mgmt') && (deploymentScope != 'core')) {
  scope: resourceGroup(monitoringResourceGroupName)
  name: workspaceName
}
module existingWorkspaceInMgmt '../../helperModules/getResourceId/getResourceId.bicep' = if (subscriptionType != 'mgmt') {
  scope: subscription(managementSubscriptionId)
  name: '${uniqueDeployPrefix}-monitoringWorkspace-getResourceId'
  params: {
    resourceGroupName: namingJsonData.mgmt.definition.monitoringResourceGroup.name
    resourceName: workspaceName
    resourceType: 'monitoringWorkspace'
  }
}

// In MGMT subscription, deploy the ActionGroup for CORE or reference the existing action group if already created
module actionGroup '../../childModules/actionGroup/actionGroup.bicep' = if ((subscriptionType == 'mgmt') && (deploymentScope == 'core')) {
  scope: monitoringResourceGroup
  name: 'monitoringActionGroup-deployment'
  params: {
    actionGroupName: actionGroupName
    actionGroupShortName: actionGroupInternalName
    tags: actionGroupTags
  }
}

resource existingActionGroup 'Microsoft.Insights/actionGroups@2022-06-01' existing = if ((subscriptionType == 'mgmt') && (deploymentScope != 'core')) {
  scope: resourceGroup(monitoringResourceGroupName)
  name: actionGroupName
}
module existingActionGroupInMgmt '../../helperModules/getResourceId/getResourceId.bicep' = if (subscriptionType != 'mgmt') {
  scope: subscription(managementSubscriptionId)
  name: '${uniqueDeployPrefix}-monitoringActionGroup-getResourceId'
  params: {
    resourceGroupName: namingJsonData.mgmt.definition.monitoringResourceGroup.name
    resourceName: actionGroupName
    resourceType: 'actionGroup'
  }
}

// Get the resource ID of monitoring user managed identity in MGMT subscription
module existingMonitoringUserManagedIdentityInMgmt '../../helperModules/getResourceId/getResourceId.bicep' = if ((subscriptionType == 'lndz') && (deploymentScope == 'osmgmt')) {
  scope: subscription(managementSubscriptionId)
  name: '${uniqueDeployPrefix}-monitoringUserManagedIdentity-getResourceId'
  params: {
    resourceGroupName: namingJsonData.mgmt.definition.monitoringResourceGroup.name
    resourceName: monitoringUserManagedIdentityName
    resourceType: 'managedIdentity'
  }
}

// in MGMT subscription for CORE, OSMGMT and PAAS, deploy the Log Alerts (Scheduled Query Rules)
module logAlertRules '../../childModules/scheduledQueryRule/scheduledQueryRule.bicep' = [for (logAlert, index) in scopeLogAlertsData: if (subscriptionType == 'mgmt') {
  scope: monitoringResourceGroup
  name: 'monitoringScheduledQueryRule${index}-${deploymentScope}-deployment'
  dependsOn: [
    monitoringWorkspace
  ]
  params: {
    location: location
    resourceId: workspaceResourceID
    actionGroupId: actionGroupResourceID
    monitoringUserAssignedIdentity: monitoringUserManagedIdentityResourceId
    tags: alertTags
    isArgAlert: contains(logAlert, 'isArgAlert') ? logAlert.isArgAlert : false
    isEnabled: contains(logAlert, 'enableAlert') ? logAlert.enableAlert : true
    isAutoMitigated: contains(logAlert, 'autoMitigate') ? logAlert.autoMitigate : false
    alertName: logAlert.alertName
    alertDescription: logAlert.alertDescription
    query: logAlert.query
    operator: logAlert.operator
    threshold: logAlert.threshold
    windowSize: logAlert.windowSize
    evaluationFrequency: logAlert.evaluationFrequency
    alertSeverity: logAlert.alertSeverity
    metricMeasureColumn: contains(logAlert, 'metricMeasureColumn') ? logAlert.metricMeasureColumn : ''
    dimensionsName: contains(logAlert, 'dimensionsName') ? split(logAlert.dimensionsName, ',') : []
    timeAggregation: logAlert.timeAggregation
    skipQueryValidation: contains(logAlert, 'skipQueryValidation') ? logAlert.skipQueryValidation : false
  }
}]

// In any subscription type for CORE, OSMGMT and PAAS, deploy the Service Health and Resource Health Alerts (Log Activity Alert Rules)
module serviceHealthAlertRules '../../childModules/activityLogAlertRule/activityLogAlertRule.bicep' = [for (resHealthAlert, index) in activityLogAlertsData.alertRules: if (resHealthAlert.alertScope == deploymentScope) {
  scope: monitoringResourceGroup
  name: 'ResourceHealthAlertRule${index}-${resHealthAlert.alertScope}-deployment'
  params: {
    actionGroupId: actionGroupResourceID
    tags: alertTags
    alertName: resHealthAlert.alertName
    alertDescription: resHealthAlert.alertDescription
    alertType: resHealthAlert.alertType
    resourceTypesCondition: resHealthAlert.resourceTypesCondition
  }
}]

// In any subscription type for CORE, OSMGMT and PAAS, deploy the Policies for Diagnostic Settings to Log analytics
module diagnosticRulesPolicies '../../childModules/policy/diagnosticRulesChange/policy.bicep' = {
  name: '${uniqueDeployPrefix}-monitoringDiagnosticRulesPolicies-deployment'
  params: {
    location: location
    policyMetadata:policyMeteringTag
    tagPrefix:tagPrefix
    workspaceResourceID: workspaceResourceID
    deploymentScope: deploymentScope
    managementSubscriptionId: managementSubscriptionId
  }
}

// In any subscription type for CORE, deploy the Policy for Azure Defender Export to Log analytics
module azDefenderDataExportPolicy '../../childModules/policy/azDefenderDataExportChange/policy.bicep' = if (deploymentScope == 'core') {
  name: '${uniqueDeployPrefix}-monitoringAzDefenderDataExportPolicy-deployment'
  params: {
    createResourceGroup: false
    policyMetadata: policyMeteringTag
    exportedDatatypes: [
      'Security recommendations'
      'Security alerts'
    ]
    isSecurityFindingsEnabled: false
    recommendationNames: []
    regulatoryComplianceStandardsNames: []
    secureScoreControlsNames: []
    azDefenderDataExportDefName: azDefenderDataExportChangeDefName
    azDefenderDataExportDefAssignmentName: azDefenderDataExportChangeDefAssignmentName
    azDefenderDataExportDefAssignmentDisplayName: azDefenderDataExportChangeDefAssignmentDisplayName
    location: location
    workspaceResourceID: workspaceResourceID
    resourceGroupName: monitoringResourceGroupName
    managementSubscriptionId: managementSubscriptionId
    recommendationSeverities: [
      'High'
      'Medium'
      'Low'
    ]
    alertSeverities: [
      'High'
      'Medium'
      'Low'
    ]
  }
}

// In MGMT subscription for OS-MGMT, deploy Data collection rules used by the Monitoring agent
module dataCollectionRules '../../childModules/dataCollectionRule/dataCollectionRule.bicep' = [for (dataCollectionRule, index) in parentModuleConfig.dataCollectionRules: if ((subscriptionType == 'mgmt') && (deploymentScope == 'osmgmt')) {
  scope: monitoringResourceGroup
  name: '${dataCollectionRule.dataCollectionRuleName}-${index}-deployment'
  params: {
    dataCollectionRuleName: '${tagPrefix}-${dataCollectionRule.dataCollectionRuleName}'
    dcrKind: dataCollectionRule.kind
    location: location
    dataFlowsDestinations: [
      workspaceName
    ]
    dataFlowStreams: dataCollectionRule.dataFlows.streams
    dcrDataSource: dataCollectionRule.dataSource
    workspaceName: workspaceName
    workspaceResourceId: workspaceResourceID
    tags: dcrTags
  }
}]

// In any subscription type for CORE, deploy the User Managed Identity used by the Azure Monitoring agent
module monitoringUserManagedIdentity '../../childModules/managedIdentity/managedIdentity.bicep' = if (deploymentScope == 'core') {
  scope: monitoringResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-monitoringUserManagedIdentity-deployment'
  params: {
    userManagedIdentityName: namingData.monitoringUserManagedIdentityName.name
    location: location
    tags: userManagedIdentityTags
  }
}

// Role assignments for the Monitoring User Managed Identity used for ARG Alerts in the MGMT subscription
module roleAssignmentResourceGroupUpdateManagerArgAlert '../../childModules/roleAssignment/roleAssignmentResourceGroup.bicep' = if ((subscriptionType == 'mgmt') && (deploymentScope == 'osmgmt')) {
  name: 'resourceGroupRoleAssignmentUpdateManager-argAlerts'
  scope: resourceGroup(customerUpdateManagerResourceGroupName)
  params: {
    managedIdentityId: monitoringUserManagedIdentityPrincipleId
    roleDefinitionIdOrNames: roleDefinitionIdOrNamesForArgAlertsReader
  }
}

// Role assignments for the Monitoring User Managed Identity used for ARG Alerts on the landingzone subscription
module roleAssignmentSubscriptionArgAlert '../../childModules/roleAssignment/roleAssignment.bicep' = if ((subscriptionType == 'lndz') && (deploymentScope == 'osmgmt')) {
  name: 'subscriptionRoleAssignment-argAlerts'
  params: {
    managedIdentityId:  monitoringUserManagedIdentityResourceId
    roleDefinitionIdOrNames: roleDefinitionIdOrNamesForArgAlertsReader
  }
}

// OUTPUTS
@description('The name of the deployed resource group.')
output monitoringResourceGroupName string = monitoringResourceGroup.name
@description('The name of the deployed monitoring Log Analytics Workspace.')
output monitoringWorkspaceName string = workspaceName
@description('The resource Id of the deployed (or existing) monitoring Log Analytics Workspace.')
output monitoringWorkspaceResourceId string = workspaceResourceID
@description('The resource Id of the deployed (or existing) monitoring Action Group.')
output actionGroupResourceId string = actionGroupResourceID
