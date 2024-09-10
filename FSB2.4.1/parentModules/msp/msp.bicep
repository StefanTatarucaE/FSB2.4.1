/*
SUMMARY: MSP Solution
DESCRIPTION: Parent module to deploy the optional MSP Subscription (For the cases where the customer Azure estate is managed through Lighthouse delegation).
             Consists of Log Analytics Workspace, Action Group, Azure Active Directory diagnostic settings, Alerts and Policies
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

// PARAMETERS
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

@description('Optional. Custom table archival periods')
param setRetentionDays array

@description('Optional. A mapping of additional tags to assign to the resource.')
param additionalMonitoringTags object = {}

@description('Boolean to define, if the policy is to be deployed.')
param deployCis bool

@description('Boolean to define, if the policy is to be deployed.')
param deployIso20071 bool

@description('Boolean to define, if the policy is to be deployed.')
param deploySecurityBenchmark bool

@description('Object which sets the values for the CIS policy assignment parameters.')
param cisAuditDenySettings object

@description('Object which sets the values for the ISO policy assignment parameters.')
param iso27001AuditDenySettings object

@description('Object which sets the values for the MCSB policy assignment parameters.')
param mcsbAuditDenySettings object

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

//VARIABLES
//variable as the parent module is MSP specific.
var deploymentScope = 'msp' 

//action group internal short name is intentionally hardcoded as it's not used for any reference
var actionGroupInternalName = 'MSPMonitor'

// Variable which holds a unique variable for deployment, which is bound to the subscription id.
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployLocation), 0, 6)

//Variables to load in the naming convention files for resource naming.
var namingData = json(loadTextContent('../../mspNaming.json'))

// Load the Log-analytics alerts definitions from JSON files
var logAlertsData = {
  msp: {
    definition: json(loadTextContent('../monitoring/logAnalyticsAlerts.msp.json'))
  }
}

// Variable to load default ELZ Azure configuration. No need to expose via parameters in parent module.
var parentModuleConfig = loadJsonContent('parentModuleConfig.json')

// Name of the monitoring resource group
var monitoringResourceGroupName = namingData.monitoringResourceGroup.name

// Name of the Log Analytics Workspace
var workspaceName = namingData.monitoringWorkspace.name

// Resource ID of the Log Analytics Workspace
var workspaceResourceID = mspMonitoringWorkspace.outputs.workspaceResourceID

// Resource ID of the Action Group
var actionGroupResourceID = mspActionGroup.outputs.actionGroupResourceID

// Name of the action group
var actionGroupName = namingData.managementITSMActionGroupsIntegration.name

//Variables to load from the naming convention files for branding, tagging and resource naming.
var tagPrefix = namingData.tagPrefix.name
var tagValuePrefix = namingData.tagValuePrefix.name
var tags = union(additionalMonitoringTags, { '${tagPrefix}Purpose': '${tagValuePrefix}MspAlerts' })
var workspaceTags = union(tags, { '${tagPrefix}Managed': 'true' })
var resourceGroupTags = union(tags, { '${tagPrefix}Managed': 'true' })
var policyMeteringTag = '${namingData.company.name}${namingData.productCode.name}'

//Specifies the diagnostic rule name
var diagnosticsRuleName = '${tagPrefix}DiagnosticRule-SendToLogAnalytics'

//RESOURCE DEPLOYMENTS
resource mspMonitoringResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: monitoringResourceGroupName
  location: deployLocation
  tags: resourceGroupTags
}

module mspMonitoringWorkspace '../../childModules/workspace/workspace.bicep' = {
  scope: mspMonitoringResourceGroup
  name: 'mspMonitoringWorkspace-deployment'
  params: {
    workspaceName: workspaceName
    skuName: monitoringWorkspaceSkuName
    location: deployLocation
    tags: workspaceTags
    retentionInDays: dataRetentionDefault
    publicNetworkAccess: parentModuleConfig.monitoringWorkspacePublicNetworkAccess
    dataSources: parentModuleConfig.dataSources
    solutions: parentModuleConfig.solutions
    setRetentionDays:setRetentionDays
  }
}

module mspActionGroup '../../childModules/actionGroup/actionGroup.bicep' = {
  scope: mspMonitoringResourceGroup
  name: 'mspActionGroup-deployment'
  params: {
    actionGroupName: actionGroupName
    actionGroupShortName: actionGroupInternalName
    tags: tags
  }
}

module aadDiagnostics '../../childModules/aadDiagnostics/aadDiagnostics.bicep' = {
  scope: mspMonitoringResourceGroup
  name: 'aadDiagnosticSettings-deployment'
  params: {
    aadLogsProperties: parentModuleConfig.aadLogsProperties
    logAnalyticsWorkspaceResourceId: workspaceResourceID
    aadDiagnosticsRuleName: diagnosticsRuleName 
  }
}

module cisAuditDeny '../../childModules/policy/cisAuditDeny/policy.bicep' = if (deployCis) {
  name: '${uniqueDeployPrefix}-cisAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    cisPolicyDefinitionId: parentModuleConfig.cisPolicyDefinitionId
    cisAuditDenySetAssignmentDisplayName: namingData.cisAuditDenyPolicy.cisAuditDenySetAssignmentDisplayName
    cisAuditDenySetAssignmentName: namingData.cisAuditDenyPolicy.cisAuditDenySetAssignmentName
    cisSettings: cisAuditDenySettings
  }
}

module iso27001AuditDeny '../../childModules/policy/iso27001AuditDeny/policy.bicep' = if (deployIso20071) {
  name: '${uniqueDeployPrefix}-iso27001AuditDeny-deployment'
  params: {
    policyMetadata:policyMeteringTag
    isoPolicyDefinitionId: parentModuleConfig.isoPolicyDefinitionId
    iso27001AuditDenySetAssignmentDisplayName: namingData.iso27001AuditDenyPolicy.iso27001AuditDenySetAssignmentDisplayName
    iso27001AuditDenySetAssignmentName: namingData.iso27001AuditDenyPolicy.iso27001AuditDenySetAssignmentName
    iso27001Settings: iso27001AuditDenySettings
  }
}

module mcsbAuditDeny '../../childModules/policy/mcsbAuditDeny/policy.bicep' = if (deploySecurityBenchmark) {
  name: '${uniqueDeployPrefix}-mcsbAuditDeny-deployment'
  params: {
    policyMetadata:policyMeteringTag
    mcsbPolicyDefinitionId: parentModuleConfig.mcsbPolicyDefinitionId
    securityBenchmarkAuditDenySetAssignmentDisplayName: namingData.securityBenchmarkAuditDenyPolicy.securityBenchmarkAuditDenySetAssignmentDisplayName
    securityBenchmarkAuditDenySetAssignmentName: namingData.securityBenchmarkAuditDenyPolicy.securityBenchmarkAuditDenySetAssignmentName
    mcsbSettings: mcsbAuditDenySettings
  }
}

module logAlertRules '../../childModules/scheduledQueryRule/scheduledQueryRule.bicep' = [for (logAlert, index) in logAlertsData[deploymentScope].definition.alertRules: {
  scope: mspMonitoringResourceGroup
  name: 'monitoringScheduledQueryRule${index}-${deploymentScope}-deployment'
  dependsOn: [
    mspMonitoringWorkspace
  ]
  params: {
    location: deployLocation
    resourceId: workspaceResourceID
    actionGroupId: actionGroupResourceID
    tags: tags
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
    metricColumn: contains(logAlert, 'metricColumn') ? logAlert.metricColumn : ''
    metricThresholdOperator: contains(logAlert, 'metricthresholdOperator') ? logAlert.metricthresholdOperator : ''
    metricThreshold: contains(logAlert, 'metricthreshold') ? logAlert.metricthreshold : 0
    metricTriggerType: contains(logAlert, 'metricTriggerType') ? logAlert.metricTriggerType : ''
  }
}]

// OUTPUTS
// N/A
