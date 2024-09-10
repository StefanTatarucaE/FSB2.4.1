/*
SUMMARY: Policy solution
DESCRIPTION: Parent module to deploy the policy solution. Consists of multiple policy child modules.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.9
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Boolean to define, if the core auditdeny policies are to be deployed.')
param coreAuditDenyPolicies bool = true

@description('Boolean to define, if the network auditdeny policies are to be deployed.')
param networkAuditDenyPolicies bool = false

@description('Boolean to define, if the osmgmt auditdeny policies are to be deployed.')
param osMgmtAuditDenyPolicies bool = false

@description('Boolean to define, if the paas auditdeny policies are to be deployed.')
param paasAuditDenyPolicies bool = false

@description('Boolean to define, if the osmgmt change policies are to be deployed.')
param coreChangePolicies bool = false

@description('Boolean to define, if the osmgmt change policies are to be deployed.')
param osMgmtChangePolicies bool = false

@description('Boolean to define, if the paas change policies are to be deployed.')
param paasChangePolicies bool = false

@description('Boolean to define, if the policy is to be deployed.')
param deployAcrAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param acrAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployAcrChange bool

@description('Boolean to define, if the policy is to be deployed.')
param deployUpdateManagerChange bool

@description('Object which sets the values for the policy assignment parameters.')
param acrChangeSettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployAllowedLocations bool

@description('The approved list of Azure regions where resources & resource groups can be deployed.')
param azureRegionsAllowed array

@description('Boolean to define, if the policy is to be deployed.')
param deployAllowedVmSku bool

@description('The approved list of Virtual Machine SKUs. Use prevent_deploy for MGMT & CNTY Subscription!')
param allowedVmSkus array

@description('Boolean to define, if the policy is to be deployed.')
param deployAntiMalwareLinux bool

@description('Set the policy effect when the policy rule evaluates to true Possible values Audit, Deny or Disable.')
param antiMalwareLinuxPolicyEffect string

@description('Boolean to define, if the policy is to be deployed.')
param deployAntiMalwareWindows bool

@description('Object which sets the scheduledScanSettings used in the DINE policyRule.')
param antiMalwareWindowsScheduledScanSettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployBlockLogAnalyticsAgentAuditDeny bool

@description('Set the policy effect when the policy rule evaluates to true Possible values Audit, Deny or Disable.')
param blockLogAnalyticsAgentPolicyEffect string

@description('Boolean to define, if the policy is to be deployed.')
param deployAscPricing bool

@description('Object which sets the pricing tier for Azure Security Center for the related resource types.')
param pricingTier object

@description('Specify sub plan for Virtual machines, P1 or P2.')
param virtualMachinesSubPlan string

@description('Boolean to define, if the policy is to be deployed.')
param deployAscQualysAgent bool

@description('Boolean to define, if the Qualys agent is to be deployed for Windows VMs.')
param deployQualysWindowsPolicy bool

@description('Boolean to define, if the Qualys agent is to be deployed for Linux VMs.')
param deployQualysLinuxPolicy bool

@description('Boolean to define, if the policy is to be deployed.')
param deployBlockResourceType bool

@description('The list of Resource Types that are not allowed in the environment.')
param blockResourceTypes array

@description('Boolean to define, if the policy is to be deployed.')
param deployCis bool

@description('Boolean to define, if the policy is to be deployed.')
param deployIso2007 bool

@description('Boolean to define, if the policy is to be deployed.')
param deployNistR2 bool

@description('Object which sets the values for the NIST policy assignment parameters.')
param nistAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployPci bool

@description('Object which sets the values for the PCI policy assignment parameters.')
param pciAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployRsgNameConvention bool

@description('Set the policy effect when the policy rule evaluates to true Possible values Audit, Deny or Disable.')
@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param rsgNameConventionPolicyEffect string

@description('Boolean to define, if the policy is to be deployed.')
param deploySecurityBenchmark bool

@description('Boolean to define, if the policy is to be deployed.')
param deployTagAuditDeny bool

@description('Set the policy effect when the policy rule evaluates to true Possible values Audit, Deny or Disable.')
@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param tagAuditDenyPolicyEffect string

@description('Set the tag name to be audited (checked if set) on resources.')
param tagNameToAudit string

@description('Boolean to define, if the policy is to be deployed.')
param deployAppGatewayAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param appGatewayAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployAppServiceAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param appServiceAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployAppServiceChange bool

@description('Object which sets the values for the policy assignment parameters.')
param appServiceChangeSettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployAzMySqlAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param azMySqlAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployAzRedisAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param azRedisAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployAzSqlDbAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param azSqlDbAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployAzSqlManagedInstanceAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param azSqlManagedInstanceAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployCosmosDbAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param cosmosDbAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployDataFactoryAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param dataFactoryAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployDatabricksAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param databricksAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployMariaDbAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param mariaDbAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployPostgreSqlAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param postgreSqlAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployKubernetesAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param kubernetesAuditDenySettings object

@description('Object which sets the values for the CIS policy assignment parameters.')
param cisAuditDenySettings object

@description('Object which sets the values for the ISO policy assignment parameters.')
param iso27001AuditDenySettings object

@description('Object which sets the values for the MCSB policy assignment parameters.')
param mcsbAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployStorageAccountAuditDeny bool

@description('Object which sets the values for the policy assignment parameters.')
param storageAccountAuditDenySettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployCosmosDbChange bool

@description('Object which sets the values for the policy assignment parameters.')
param cosmosDbChangeSettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployDatafactoryChange bool

@description('String which sets the values for the policy assignment parameters.')
param datafactoryChangeSetting string

@description('Boolean to define, if the policy is to be deployed.')
param deployKubernetesChange bool

@description('String which sets the values for the policy assignment parameters.')
param kubernetesChangeSettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployVmDependencyAgent bool

@description('Object which sets the values for the policy assignment parameters')
param deployVmDependencyAgentSettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployVmssDependencyAgent bool

@description('Object which sets the values for the policy assignment parameters')
param deployVmssDependencyAgentSettings object

@description('Boolean to define, if the policy is to be deployed.')
param deployVmGuestConfigurationAgent bool

@description('Boolean to define, if the policy is to be deployed.') 
param deployAzMonitorAgentWindowsChange bool

@description('Object which sets the values for the policy assignment parameters.')
param deployAzMonitorAgentWindowsSettings object

@description('Boolean to define, if the policy is to be deployed.') 
param deployAzMonitorAgentLinuxChange bool

@description('Object which sets the values for the policy assignment parameters.') 
param deployAzMonitorAgentLinuxSettings object

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

@description('Parameter to determine the subscription using abbreviation. To be provided by the pipeline')
@allowed([
  'mgmt'
  'cnty'
  'lndz'
  'tool'
])
param subscriptionType string

@description('The Id of the management subscription. To be provided by the pipeline.')
param managementSubscriptionId string = ''

// VARIABLES
// Variable which holds a unique variable for deployment, which is bound to the subscription id.
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployLocation), 0, 6)

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

//Variables to load from the naming convention files for branding, tagging and resource naming.
var policyMeteringTag = '${namingData.company.name}${namingData.productCode.name}'
var managedPolicyRuleTag = '${namingData.tagPrefix.name}Managed'
var antiMalwarePolicyRuleTag = '${namingData.tagPrefix.name}Antimalware'
var compliancePolicyRuleTag = '${namingData.tagPrefix.name}Compliance'
var patchingPolicyRuleTag = '${namingData.tagPrefix.name}Patching'

// Name of the Loganalytics workspace
var workspaceName = namingJsonData.mgmt.definition.monitoringWorkspace.name

// Names of the Linux Data Collection Rules resource
var dcrNames = namingJsonData.mgmt.definition.azureMonitorDataCollectionRules

// Variable to load default ELZ Azure configuration. No need to expose via parameters in parent module.
var parentModuleConfig = loadJsonContent('parentModuleConfig.json')

// RESOURCE DEPLOYMENTS

// This module is called to fetch the log analytics workspace ID present in mgmt subscription. The workspace ID is used in nistR2AuditDeny policy
module existingWorkspaceInMgmt '../../helperModules/getResourceId/getResourceId.bicep' = if (!empty(managementSubscriptionId)) {
  scope: subscription(!empty(managementSubscriptionId) ? managementSubscriptionId : subscription().subscriptionId)
  name: '${uniqueDeployPrefix}-monitoringWorkspace-getResourceId'
  params: {
    resourceGroupName: namingJsonData.mgmt.definition.monitoringResourceGroup.name
    resourceName: workspaceName
    resourceType: 'monitoringWorkspace'
  }
}

// This module retrieves the resource ID of the Data Collection Rules resource for Linux systems
module existingLinuxDataCollectionRuleResourceId '../../helperModules/getResourceId/getResourceId.bicep' = if (!empty(managementSubscriptionId)) {
  scope: subscription(!empty(managementSubscriptionId) ? managementSubscriptionId : subscription().subscriptionId)
  name: '${uniqueDeployPrefix}-monitoringLinuxDcr-getResourceId'
  params: {
    resourceGroupName: namingJsonData.mgmt.definition.monitoringResourceGroup.name
    resourceName: dcrNames.dcrLinuxName
    resourceType: 'dataCollectionRules'
  }
}
// This module retrieves the resource ID of the Data Collection Rules resource for Windows systems
module existingWindowsDataCollectionRuleResourceId '../../helperModules/getResourceId/getResourceId.bicep' = if (!empty(managementSubscriptionId)) {
  scope: subscription(!empty(managementSubscriptionId) ? managementSubscriptionId : subscription().subscriptionId)
  name: '${uniqueDeployPrefix}-monitoringWindowsDcr-getResourceId'
  params: {
    resourceGroupName: namingJsonData.mgmt.definition.monitoringResourceGroup.name
    resourceName: dcrNames.dcrWindowsName
    resourceType: 'dataCollectionRules'
  }
}

// This module is called to fetch the resourceId of the metering function app. This resourceId is used in the appServiceChange policy.
module existingMeteringFunctionApp '../../helperModules/getResourceId/getResourceId.bicep' = if (subscriptionType == 'mgmt') {
  scope: subscription(!empty(managementSubscriptionId) ? managementSubscriptionId : subscription().subscriptionId)
  name: '${uniqueDeployPrefix}-meteringFunctionApp-getResourceId'
  params: {
    resourceGroupName: namingJsonData.mgmt.definition.customerBillingResourceGroup.name
    resourceName: namingJsonData.mgmt.definition.customerBillingFunctionApp.name
    resourceType: 'functionApp'
  }
}

//  This module is called to fetch the resourceId of the os tagging function app. This resourceId is used in the appServiceChange policy.
module existingOsTaggingFunctionApp '../../helperModules/getResourceId/getResourceId.bicep' = if (subscriptionType == 'mgmt') {
  scope: subscription(!empty(managementSubscriptionId) ? managementSubscriptionId : subscription().subscriptionId)
  name: '${uniqueDeployPrefix}-osTaggingFunctionApp-getResourceId'
  params: {
    resourceGroupName: namingJsonData.mgmt.definition.osTaggingResourceGroup.name
    resourceName: namingJsonData.mgmt.definition.osTaggingFuncApp.name
    resourceType: 'functionApp'
  }
}

// This module is called to fetch the resourceId of the itsm function app. This resourceId is used in the appServiceChange policy.
module existingItsmFunctionApp '../../helperModules/getResourceId/getResourceId.bicep' = if (subscriptionType == 'mgmt') {
  scope: subscription(!empty(managementSubscriptionId) ? managementSubscriptionId : subscription().subscriptionId)
  name: '${uniqueDeployPrefix}-itsmFunctionApp-getResourceId'
  params: {
    resourceGroupName: namingJsonData.mgmt.definition.managementItsmResourceGroup.name
    resourceName: namingJsonData.mgmt.definition.customerItsmPwshFunctionApp.name
    resourceType: 'functionApp'
  }
}

/* Audit deny policies are deployed always,
   but individual policies can be set to not deploy using the corresponding boolean.
   Set the boolean to false in the parameters file to deselect it.
   Audit deny policies are grouped using the core, network, osmgmt & paas categories, to be able to 'bulk' deploy categories.
   The bulk category can be deployed using the coreAuditDenyPolicies, networkAuditDenyPolicies, osMgmtAuditDenyPolicies & paasAuditDenyPolicies booleans. */

// core auditdeny policies
module allowedLocationsAuditDeny '../../childModules/policy/allowedLocationsAuditDeny/policy.bicep' = if (deployAllowedLocations && coreAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-allowedLocationsAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    azureRegionsAllowed: azureRegionsAllowed
    allowedLocationResourcesDefAssignmentDisplayName: namingData.allowedLocationsAuditDenyPolicy.allowedLocationResourcesDefAssignmentDisplayName
    allowedLocationResourcesDefAssignmentName: namingData.allowedLocationsAuditDenyPolicy.allowedLocationResourcesDefAssignmentName
    allowedLocationRgDefAssignmentDisplayName: namingData.allowedLocationsAuditDenyPolicy.allowedLocationRgDefAssignmentDisplayName
    allowedLocationRGDefAssignmentName: namingData.allowedLocationsAuditDenyPolicy.allowedLocationRGDefAssignmentName
  }
}

module rsgNameConventionAuditDeny '../../childModules/policy/rsgNameConventionAuditDeny/policy.bicep' = if (deployRsgNameConvention && coreAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-rsgNameConventionAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    policyEffect: rsgNameConventionPolicyEffect
    rsgNameConventionsAuditDenyDefAssignmentDisplayName: namingData.rsgNameConventionAuditDenyPolicy.rsgNameConventionsAuditDenyDefAssignmentDisplayName
    rsgNameConventionsAuditDenyDefAssignmentName: namingData.rsgNameConventionAuditDenyPolicy.rsgNameConventionsAuditDenyDefAssignmentName
    rsgNameConventionsAuditDenyDefDisplayName: namingData.rsgNameConventionAuditDenyPolicy.rsgNameConventionsAuditDenyDefDisplayName
    rsgNameConventionsAuditDenyDefName: namingData.rsgNameConventionAuditDenyPolicy.rsgNameConventionsAuditDenyDefName
  }
}

module mcsbAuditDeny '../../childModules/policy/mcsbAuditDeny/policy.bicep' = if (deploySecurityBenchmark && coreAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-mcsbAuditDeny-deployment'
  params: {
    mcsbPolicyDefinitionId: parentModuleConfig.mcsbPolicyDefinitionId
    policyMetadata: policyMeteringTag
    securityBenchmarkAuditDenySetAssignmentDisplayName: namingData.securityBenchmarkAuditDenyPolicy.securityBenchmarkAuditDenySetAssignmentDisplayName
    securityBenchmarkAuditDenySetAssignmentName: namingData.securityBenchmarkAuditDenyPolicy.securityBenchmarkAuditDenySetAssignmentName
    mcsbSettings: mcsbAuditDenySettings
  }
}

module tagAuditDeny '../../childModules/policy/tagAuditDeny/policy.bicep' = if (deployTagAuditDeny && coreAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-tagAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    policyEffect: tagAuditDenyPolicyEffect
    tagName: tagNameToAudit
    tagAuditDenyDefAssignmentDisplayName: namingData.tagAuditDenyPolicy.tagAuditDenyDefAssignmentDisplayName
    tagAuditDenyDefAssignmentName: namingData.tagAuditDenyPolicy.tagAuditDenyDefAssignmentName
    tagAuditDenyDefDisplayName: namingData.tagAuditDenyPolicy.tagAuditDenyDefDisplayName
    tagAuditDenyDefName: namingData.tagAuditDenyPolicy.tagAuditDenyDefName
  }
}

module storageAccountAuditDeny '../../childModules/policy/storageAccountAuditDeny/policy.bicep' = if (deployStorageAccountAuditDeny && coreAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-storageAccountAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    storageAccountSettings: storageAccountAuditDenySettings
    storageAccountAuditDenySetAssignmentDisplayName: namingData.storageAccountAuditDenyPolicy.storageAccountAuditDenySetAssignmentDisplayName
    storageAccountAuditDenySetAssignmentName: namingData.storageAccountAuditDenyPolicy.storageAccountAuditDenySetAssignmentName
    storageAccountAuditDenySetDisplayName: namingData.storageAccountAuditDenyPolicy.storageAccountAuditDenySetDisplayName
    storageAccountAuditDenySetName: namingData.storageAccountAuditDenyPolicy.storageAccountAuditDenySetName
    storageAccountFilesyncprivatednszoneDefDisplayName: namingData.storageAccountAuditDenyPolicy.storageAccountFilesyncprivatednszoneDefDisplayName
    storageAccountFilesyncprivatednszoneDefName: namingData.storageAccountAuditDenyPolicy.storageAccountFilesyncprivatednszoneDefName
  }
}

module cisAuditDeny '../../childModules/policy/cisAuditDeny/policy.bicep' = if (deployCis && coreAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-cisAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    cisPolicyDefinitionId: parentModuleConfig.cisPolicyDefinitionId
    cisAuditDenySetAssignmentDisplayName: namingData.cisAuditDenyPolicy.cisAuditDenySetAssignmentDisplayName
    cisAuditDenySetAssignmentName: namingData.cisAuditDenyPolicy.cisAuditDenySetAssignmentName
    cisSettings: cisAuditDenySettings
  }
}

module iso27001AuditDeny '../../childModules/policy/iso27001AuditDeny/policy.bicep' = if (deployIso2007 && coreAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-iso27001AuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    isoPolicyDefinitionId: parentModuleConfig.isoPolicyDefinitionId
    iso27001AuditDenySetAssignmentDisplayName: namingData.iso27001AuditDenyPolicy.iso27001AuditDenySetAssignmentDisplayName
    iso27001AuditDenySetAssignmentName: namingData.iso27001AuditDenyPolicy.iso27001AuditDenySetAssignmentName
    iso27001Settings: iso27001AuditDenySettings
  }
}

module nistR2AuditDeny '../../childModules/policy/nistR2AuditDeny/policy.bicep' = if (deployNistR2 && coreAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-nistR2AuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    nistPolicyDefinitionId: parentModuleConfig.nistPolicyDefinitionId
    nistR2AuditDenySetAssignmentDisplayName: namingData.nistR2AuditDenyPolicy.nistR2AuditDenySetAssignmentDisplayName
    nistR2AuditDenySetAssignmentName: namingData.nistR2AuditDenyPolicy.nistR2AuditDenySetAssignmentName
    nistSettings: nistAuditDenySettings
  }
}

module pciAuditDeny '../../childModules/policy/pciAuditDeny/policy.bicep' = if (deployPci && coreAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-pciAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    pciPolicyDefinitionId: parentModuleConfig.pciPolicyDefinitionId
    pciAuditDenySetAssignmentDisplayName: namingData.pciAuditDenyPolicy.pciAuditDenySetAssignmentDisplayName
    pciAuditDenySetAssignmentName: namingData.pciAuditDenyPolicy.pciAuditDenySetAssignmentName
    pciSettings: pciAuditDenySettings
  }
}

module blockResourceTypeAuditDeny '../../childModules/policy/blockResourceTypeAuditDeny/policy.bicep' = if (deployBlockResourceType && coreAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-blockResourceTypeAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    resourceTypesNotAllowed: blockResourceTypes
    blockResourceTypeAuditDenyDefAssignmentDisplayName: namingData.blockResourceTypeAuditDenyPolicy.blockResourceTypeAuditDenyDefAssignmentDisplayName
    blockResourceTypeAuditDenyDefAssignmentName: namingData.blockResourceTypeAuditDenyPolicy.blockResourceTypeAuditDenyDefAssignmentName
  }
}

// network auditdeny policies
module appGatewayAuditDeny '../../childModules/policy/appGatewayAuditDeny/policy.bicep' = if (deployAppGatewayAuditDeny && networkAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-appGatewayAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    wafEnableEffect: appGatewayAuditDenySettings.wafEnableEffect
    wafModeEffect: appGatewayAuditDenySettings.wafModeEffect
    modeRequirement: appGatewayAuditDenySettings.modeRequirement
    appGatewayAuditDenySetAssignmentDisplayName: namingData.appGatewayAuditDenyPolicy.appGatewayAuditDenySetAssignmentDisplayName
    appGatewayAuditDenySetAssignmentName: namingData.appGatewayAuditDenyPolicy.appGatewayAuditDenySetAssignmentName
    appGatewayAuditDenySetDisplayName: namingData.appGatewayAuditDenyPolicy.appGatewayAuditDenySetDisplayName
    appGatewayAuditDenySetName: namingData.appGatewayAuditDenyPolicy.appGatewayAuditDenySetName
  }
}

// osmgmt auditdeny policies
module allowedVmSkuAuditDeny '../../childModules/policy/allowedVmSkuAuditDeny/policy.bicep' = if (deployAllowedVmSku && osMgmtAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-allowedVmSkuAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    virtualMachineSkusAllowed: allowedVmSkus
    allowedVmSkuDefAssignmentDisplayName: namingData.allowedVmSkuAuditDenyPolicy.allowedVmSkuDefAssignmentDisplayName
    allowedVmSkuDefAssignmentName: namingData.allowedVmSkuAuditDenyPolicy.allowedVmSkuDefAssignmentName
  }
}

module antiMalwareLinuxAuditDeny '../../childModules/policy/antiMalwareLinuxAuditDeny/policy.bicep' = if (deployAntiMalwareLinux && osMgmtAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-antiMalwareDenyLinuxAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    policyRuleTag:antiMalwarePolicyRuleTag
    antimalwareLinuxEffect: antiMalwareLinuxPolicyEffect
    antiMalwareLinuxAuditDenyDefAssignmentDisplayName: namingData.antiMalwareLinuxAuditDenyPolicy.antiMalwareLinuxAuditDenyDefAssignmentDisplayName
    antiMalwareLinuxAuditDenyDefAssignmentName: namingData.antiMalwareLinuxAuditDenyPolicy.antiMalwareLinuxAuditDenyDefAssignmentName
    antiMalwareLinuxAuditDenyDefDisplayName: namingData.antiMalwareLinuxAuditDenyPolicy.antiMalwareLinuxAuditDenyDefDisplayName
    antiMalwareLinuxAuditDenyDefName: namingData.antiMalwareLinuxAuditDenyPolicy.antiMalwareLinuxAuditDenyDefName
  }
}

module blockLogAnalyticsAgentAuditDeny '../../childModules/policy/blockLogAnalyticsAgentAuditDeny/policy.bicep' = if (deployBlockLogAnalyticsAgentAuditDeny && osMgmtAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-blockLogAnalyticsAgentAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    blockLogAnalyticsAgentDefEffect: blockLogAnalyticsAgentPolicyEffect
    blockLogAnalyticsAgentDefName: namingData.blockLogAnalyticsAgentAuditDenyPolicy.blockLogAnalyticsAgentDefName
    blockLogAnalyticsAgentDefDisplayName: namingData.blockLogAnalyticsAgentAuditDenyPolicy.blockLogAnalyticsAgentDefDisplayName
    blockLogAnalyticsAgentDefAssignmentName: namingData.blockLogAnalyticsAgentAuditDenyPolicy.blockLogAnalyticsAgentDefAssignmentName
    blockLogAnalyticsAgentDefAssignmentDisplayName: namingData.blockLogAnalyticsAgentAuditDenyPolicy.blockLogAnalyticsAgentDefAssignmentDisplayName
  }
}

// paas auditdeny policies
module acrAuditDeny '../../childModules/policy/acrAuditDeny/policy.bicep' = if (deployAcrAuditDeny && paasAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-acrAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    acrSettings: acrAuditDenySettings
    acrAuditDenySetAssignmentDisplayName: namingData.acrAuditDenyPolicy.acrAuditDenySetAssignmentDisplayName
    acrAuditDenySetAssignmentName: namingData.acrAuditDenyPolicy.acrAuditDenySetAssignmentName
    acrAuditDenySetDisplayName: namingData.acrAuditDenyPolicy.acrAuditDenySetDisplayName
    acrAuditDenySetName: namingData.acrAuditDenyPolicy.acrAuditDenySetName
  }
}

module appServiceAuditDeny '../../childModules/policy/appServiceAuditDeny/policy.bicep' = if (deployAppServiceAuditDeny && paasAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-appServiceAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    appServiceSettings: appServiceAuditDenySettings
    appServiceAuditDenySetAssignmentDisplayName: namingData.appServiceAuditDenyPolicy.appServiceAuditDenySetAssignmentDisplayName
    appServiceAuditDenySetAssignmentName: namingData.appServiceAuditDenyPolicy.appServiceAuditDenySetAssignmentName
    appServiceAuditDenySetDisplayName: namingData.appServiceAuditDenyPolicy.appServiceAuditDenySetDisplayName
    appServiceAuditDenySetName: namingData.appServiceAuditDenyPolicy.appServiceAuditDenySetName
  }
}

module azMySqlAuditDeny '../../childModules/policy/azMySqlAuditDeny/policy.bicep' = if (deployAzMySqlAuditDeny && paasAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-azMySqlAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    mySqlSettings: azMySqlAuditDenySettings
    mySqlAuditDenySetAssignmentDisplayName: namingData.azMySqlAuditDenyPolicy.mySqlAuditDenySetAssignmentDisplayName
    mySqlAuditDenySetAssignmentName: namingData.azMySqlAuditDenyPolicy.mySqlAuditDenySetAssignmentName
    mySqlAuditDenySetDisplayName: namingData.azMySqlAuditDenyPolicy.mySqlAuditDenySetDisplayName
    mySqlAuditDenySetName: namingData.azMySqlAuditDenyPolicy.mySqlAuditDenySetName
  }
}

module azRedisAuditDeny '../../childModules/policy/azRedisAuditDeny/policy.bicep' = if (deployAzRedisAuditDeny && paasAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-azRedisAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    azRedisAuditSettings: azRedisAuditDenySettings
    azRedisAuditDenySetAssignmentDisplayName: namingData.azRedisAuditDenyPolicy.azRedisAuditDenySetAssignmentDisplayName
    azRedisAuditDenySetAssignmentName: namingData.azRedisAuditDenyPolicy.azRedisAuditDenySetAssignmentName
    azRedisAuditDenySetDisplayName: namingData.azRedisAuditDenyPolicy.azRedisAuditDenySetDisplayName
    azRedisAuditDenySetName: namingData.azRedisAuditDenyPolicy.azRedisAuditDenySetName
  }
}

module azSqlDbAuditDeny '../../childModules/policy/azSqlDbAuditDeny/policy.bicep' = if (deployAzSqlDbAuditDeny && paasAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-azSqlDbAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    sqlSettings: azSqlDbAuditDenySettings
    azSqlDbAuditDenySetAssignmentDisplayName: namingData.azSqlDbAuditDenyPolicy.azSqlDbAuditDenySetAssignmentDisplayName
    azSqlDbAuditDenySetAssignmentName: namingData.azSqlDbAuditDenyPolicy.azSqlDbAuditDenySetAssignmentName
    azSqlDbAuditDenySetDisplayName: namingData.azSqlDbAuditDenyPolicy.azSqlDbAuditDenySetDisplayName
    azSqlDbAuditDenySetName: namingData.azSqlDbAuditDenyPolicy.azSqlDbAuditDenySetName
  }
}

module azSqlManagedInstanceAuditDeny '../../childModules/policy/azSqlManagedInstanceAuditDeny/policy.bicep' = if (deployAzSqlManagedInstanceAuditDeny && paasAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-azSqlManagedInstanceAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    azSqlManagedInstanceSettings: azSqlManagedInstanceAuditDenySettings
    azSqlManagedInstanceAuditDenySetAssignmentDisplayName: namingData.azSqlManagedInstanceAuditDenyPolicy.azSqlManagedInstanceAuditDenySetAssignmentDisplayName
    azSqlManagedInstanceAuditDenySetAssignmentName: namingData.azSqlManagedInstanceAuditDenyPolicy.azSqlManagedInstanceAuditDenySetAssignmentName
    azSqlManagedInstanceAuditDenySetDisplayName: namingData.azSqlManagedInstanceAuditDenyPolicy.azSqlManagedInstanceAuditDenySetDisplayName
    azSqlManagedInstanceAuditDenySetName: namingData.azSqlManagedInstanceAuditDenyPolicy.azSqlManagedInstanceAuditDenySetName
  }
}

module cosmosDbAuditDeny '../../childModules/policy/cosmosDbAuditDeny/policy.bicep' = if (deployCosmosDbAuditDeny && paasAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-cosmosDbAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    cosmosDbSettings: cosmosDbAuditDenySettings
    cosmosdbAuditDenySetAssignmentDisplayName: namingData.cosmosDbAuditDenyPolicy.cosmosdbAuditDenySetAssignmentDisplayName
    cosmosdbAuditDenySetAssignmentName: namingData.cosmosDbAuditDenyPolicy.cosmosdbAuditDenySetAssignmentName
    cosmosdbAuditDenySetDisplayName: namingData.cosmosDbAuditDenyPolicy.cosmosdbAuditDenySetDisplayName
    cosmosDbAuditDenySetName: namingData.cosmosDbAuditDenyPolicy.cosmosDbAuditDenySetName
  }
}

module dataFactoryAuditDeny '../../childModules/policy/dataFactoryAuditDeny/policy.bicep' = if (deployDataFactoryAuditDeny && paasAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-dataFactoryAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    dataFactorySettings: dataFactoryAuditDenySettings
    dataFactoryAuditDenySetAssignmentDisplayName: namingData.dataFactoryAuditDenyPolicy.dataFactoryAuditDenySetAssignmentDisplayName
    dataFactoryAuditDenySetAssignmentName: namingData.dataFactoryAuditDenyPolicy.dataFactoryAuditDenySetAssignmentName
    dataFactoryAuditDenySetDisplayName: namingData.dataFactoryAuditDenyPolicy.dataFactoryAuditDenySetDisplayName
    dataFactoryAuditDenySetName: namingData.dataFactoryAuditDenyPolicy.dataFactoryAuditDenySetName
  }
}
module databricksAuditDeny '../../childModules/policy/databricksAuditDeny/policy.bicep' = if (deployDatabricksAuditDeny && paasAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-databricksAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    databricksSettings: databricksAuditDenySettings
    databricksAuditDenySetAssignmentDisplayName: namingData.databricksAuditDenyPolicy.databricksAuditDenySetAssignmentDisplayName
    databricksAuditDenySetAssignmentName: namingData.databricksAuditDenyPolicy.databricksAuditDenySetAssignmentName
    databricksAuditDenySetDisplayName: namingData.databricksAuditDenyPolicy.databricksAuditDenySetDisplayName
    databricksAuditDenySetName: namingData.databricksAuditDenyPolicy.databricksAuditDenySetName
  }
}
module mariaDbAuditDeny '../../childModules/policy/mariaDbAuditDeny/policy.bicep' = if (deployMariaDbAuditDeny && paasAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-mariaDbAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    mariaDbSettings: mariaDbAuditDenySettings
    mariaDbAuditDenySetAssignmentDisplayName: namingData.mariaDbAuditDenyPolicy.mariaDbAuditDenySetAssignmentDisplayName
    mariaDbAuditDenySetAssignmentName: namingData.mariaDbAuditDenyPolicy.mariaDbAuditDenySetAssignmentName
    mariaDbAuditDenySetDisplayName: namingData.mariaDbAuditDenyPolicy.mariaDbAuditDenySetDisplayName
    mariaDbAuditDenySetName: namingData.mariaDbAuditDenyPolicy.mariaDbAuditDenySetName
  }
}

module postgreSqlAuditDeny '../../childModules/policy/postgreSqlAuditDeny/policy.bicep' = if (deployPostgreSqlAuditDeny && paasAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-postgreSqlAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    postgreSqlSettings: postgreSqlAuditDenySettings
    postgreSqlAuditDenySetAssignmentDisplayName: namingData.postgreSqlAuditDenyPolicy.postgreSqlAuditDenySetAssignmentDisplayName
    postgreSqlAuditDenySetAssignmentName: namingData.postgreSqlAuditDenyPolicy.postgreSqlAuditDenySetAssignmentName
    postgreSqlAuditDenySetDisplayName: namingData.postgreSqlAuditDenyPolicy.postgreSqlAuditDenySetDisplayName
    postgreSqlAuditDenySetName: namingData.postgreSqlAuditDenyPolicy.postgreSqlAuditDenySetName
  }
}

module kubernetesAuditDeny '../../childModules/policy/kubernetesAuditDeny/policy.bicep' = if (deployKubernetesAuditDeny && paasAuditDenyPolicies) {
  name: '${uniqueDeployPrefix}-kubernetesAuditDeny-deployment'
  params: {
    policyMetadata: policyMeteringTag
    kubernetesAuditDenySetAssignmentDisplayName: namingData.kubernetesAuditDenyPolicy.kubernetesAuditDenySetAssignmentDisplayName
    kubernetesAuditDenySetAssignmentName: namingData.kubernetesAuditDenyPolicy.kubernetesAuditDenySetAssignmentName
    kubernetesAuditDenySetDisplayName: namingData.kubernetesAuditDenyPolicy.kubernetesAuditDenySetDisplayName
    kubernetesAuditDenySetName: namingData.kubernetesAuditDenyPolicy.kubernetesAuditDenySetName
    kubernetesSettings: kubernetesAuditDenySettings
  }

}

/* Change policies which are grouped using the core, (network), osmgmt & paas categories
Change policies are not deployed by default, this is set using the coreChangePolicies, osMgmtChangePolicies & paasChangePolicies booleans.
These booleans are set to false by default in this parent module. */

// core change policies
module ascPricingChange '../../childModules/policy/ascPricingChange/policy.bicep' = if (deployAscPricing && coreChangePolicies) {
  name: '${uniqueDeployPrefix}-ascPricingChange-deployment'
  params: {
    policyMetadata: policyMeteringTag
    pricingTier: pricingTier
    deployLocation: deployLocation
    virtualMachinesSubPlan: virtualMachinesSubPlan
    ascPricingChangeDefAssignmentDisplayName: namingData.ascPricingChangePolicy.ascPricingChangeDefAssignmentDisplayName
    ascPricingChangeDefAssignmentName: namingData.ascPricingChangePolicy.ascPricingChangeDefAssignmentName
    ascPricingChangeDefDisplayName: namingData.ascPricingChangePolicy.ascPricingChangeDefDisplayName
    ascPricingChangeDefName: namingData.ascPricingChangePolicy.ascPricingChangeDefName
  }
}

// network change policies
// no policies at this moment.

// osmgmt change policies
module antiMalwareWindowsChange '../../childModules/policy/antiMalwareWindowsChange/policy.bicep' = if (deployAntiMalwareWindows && osMgmtChangePolicies) {
  name: '${uniqueDeployPrefix}-antiMalwareWindowsChange-deployment'
  params: {
    policyMetadata: policyMeteringTag
    policyRuleTag:[
      managedPolicyRuleTag
      antiMalwarePolicyRuleTag
      ]
    scheduledScanSettings: antiMalwareWindowsScheduledScanSettings
    deployLocation: deployLocation
    antiMalwareWindowsChangeDefAssignmentDisplayName: namingData.antiMalwareWindowsChangePolicy.antiMalwareWindowsChangeDefAssignmentDisplayName
    antiMalwareWindowsChangeDefAssignmentName: namingData.antiMalwareWindowsChangePolicy.antiMalwareWindowsChangeDefAssignmentName
    antiMalwareWindowsChangeDefDisplayName: namingData.antiMalwareWindowsChangePolicy.antiMalwareWindowsChangeDefDisplayName
    antiMalwareWindowsChangeDefName: namingData.antiMalwareWindowsChangePolicy.antiMalwareWindowsChangeDefName
  }
}

module ascQualysAgentChange '../../childModules/policy/ascQualysAgentChange/policy.bicep' = if (deployAscQualysAgent && osMgmtChangePolicies) {
  name: '${uniqueDeployPrefix}-ascQualysAgentChange-deployment'
  params: {
    policyMetadata: policyMeteringTag
    policyRuleTag:[
      managedPolicyRuleTag
      compliancePolicyRuleTag
      ]
    deployQualysWindowsPolicy: deployQualysWindowsPolicy
    deployQualysLinuxPolicy: deployQualysLinuxPolicy
    deployLocation: deployLocation
    ascQualysAgentChangeLinuxDefDisplayName: namingData.ascQualysAgentChangePolicy.ascQualysAgentChangeLinuxDefDisplayName
    ascQualysAgentChangeLinuxDefName: namingData.ascQualysAgentChangePolicy.ascQualysAgentChangeLinuxDefName
    ascQualysAgentChangeSetAssignmentDisplayName: namingData.ascQualysAgentChangePolicy.ascQualysAgentChangeSetAssignmentDisplayName
    ascQualysAgentChangeSetAssignmentName: namingData.ascQualysAgentChangePolicy.ascQualysAgentChangeSetAssignmentName
    ascQualysAgentChangeSetDisplayName: namingData.ascQualysAgentChangePolicy.ascQualysAgentChangeSetDisplayName
    ascQualysAgentChangeSetName: namingData.ascQualysAgentChangePolicy.ascQualysAgentChangeSetName
    ascQualysAgentChangeWindowsDefDisplayName: namingData.ascQualysAgentChangePolicy.ascQualysAgentChangeWindowsDefDisplayName
    ascQualysAgentChangeWindowsDefName: namingData.ascQualysAgentChangePolicy.ascQualysAgentChangeWindowsDefName
  }
}

module vmDependencyAgentChange '../../childModules/policy/vmDependencyAgentChange/policy.bicep' = if (deployVmDependencyAgent && osMgmtChangePolicies) {
  name: '${uniqueDeployPrefix}-vmDependencyAgent-deployment'
  params: {
    policyMetadata: policyMeteringTag
    deployLocation: deployLocation
    policyRuleTag: managedPolicyRuleTag
    vmEnableDependencyAgentLinuxDefEffect: deployVmDependencyAgentSettings.vmEnableDependencyAgentLinuxDefEffect
    vmEnableDependencyAgentWinDefEffect: deployVmDependencyAgentSettings.vmEnableDependencyAgentWinDefEffect
    vmEnableDependencyAgentLinuxDefDisplayName: namingData.vmDependencyAgentChangePolicy.vmEnableDependencyAgentLinuxDefDisplayName
    vmEnableDependencyAgentLinuxDefName: namingData.vmDependencyAgentChangePolicy.vmEnableDependencyAgentLinuxDefName
    vmEnableDependencyAgentSetAssignmentDisplayName: namingData.vmDependencyAgentChangePolicy.vmEnableDependencyAgentSetAssignmentDisplayName
    vmEnableDependencyAgentSetAssignmentName: namingData.vmDependencyAgentChangePolicy.vmEnableDependencyAgentSetAssignmentName
    vmEnableDependencyAgentSetDisplayName: namingData.vmDependencyAgentChangePolicy.vmEnableDependencyAgentSetDisplayName
    vmEnableDependencyAgentSetName: namingData.vmDependencyAgentChangePolicy.vmEnableDependencyAgentSetName
    vmEnableDependencyAgentWinDefDisplayName: namingData.vmDependencyAgentChangePolicy.vmEnableDependencyAgentWinDefDisplayName
    vmEnableDependencyAgentWinDefName: namingData.vmDependencyAgentChangePolicy.vmEnableDependencyAgentWinDefName
  }
}

module updateManagerChange '../../childModules/policy/updateManagerChange/policy.bicep' = if (deployUpdateManagerChange && osMgmtChangePolicies) {
  name: '${uniqueDeployPrefix}-UpdateManagerChange-deployment'
  params: {
    policyMetadata: policyMeteringTag
    deployLocation: deployLocation
    policyRuleTag:managedPolicyRuleTag
    policyPatchingRuleTag:patchingPolicyRuleTag
    updateManagerDefDisplayname: namingData.updateManagerChange.updateManagerDefDisplayname
    windowsVmUpdateAssessmentDefName: namingData.updateManagerChange.windowsVmUpdateAssessmentDefName
    linuxVmUpdateAssessmentDefName: namingData.updateManagerChange.linuxVmUpdateAssessmentDefName
    linuxVmUpdatePatchModeDefName: namingData.updateManagerChange.linuxVmUpdatePatchModeDefName
    windowsVmUpdatePatchModeDefName: namingData.updateManagerChange.windowsVmUpdatePatchModeDefName
    updateManagerAssignmentSetDisplayName: namingData.updateManagerChange.updateManagerAssignmentSetDisplayName
    updateManagerSetAssignmentName: namingData.updateManagerChange.updateManagerSetAssignmentName
    updateManagerSetName: namingData.updateManagerChange.updateManagerSetName
  }
}

module vmssDependencyAgentChange '../../childModules/policy/vmssDependencyAgentChange/policy.bicep' = if (deployVmssDependencyAgent && osMgmtChangePolicies) {
  name: '${uniqueDeployPrefix}-vmssDependencyAgent-deployment'
  params: {
    policyMetadata: policyMeteringTag
    policyRuleTag: managedPolicyRuleTag
    deployLocation: deployLocation
    vmssEnableDependencyAgentLinuxDefEffect: deployVmssDependencyAgentSettings.vmssEnableDependencyAgentLinuxDefEffect
    vmssEnableDependencyAgentWinDefEffect: deployVmssDependencyAgentSettings.vmssEnableDependencyAgentWinDefEffect
    vmssEnableDependencyAgentLinuxDefDisplayName: namingData.vmssDependencyAgentChangePolicy.vmssEnableDependencyAgentLinuxDefDisplayName
    vmssEnableDependencyAgentLinuxDefName: namingData.vmssDependencyAgentChangePolicy.vmssEnableDependencyAgentLinuxDefName
    vmssEnableDependencyAgentSetAssignmentDisplayName: namingData.vmssDependencyAgentChangePolicy.vmssEnableDependencyAgentSetAssignmentDisplayName
    vmssEnableDependencyAgentSetAssignmentName: namingData.vmssDependencyAgentChangePolicy.vmssEnableDependencyAgentSetAssignmentName
    vmssEnableDependencyAgentSetDisplayName: namingData.vmssDependencyAgentChangePolicy.vmssEnableDependencyAgentSetDisplayName
    vmssEnableDependencyAgentSetName: namingData.vmssDependencyAgentChangePolicy.vmssEnableDependencyAgentSetName
    vmssEnableDependencyAgentWinDefDisplayName: namingData.vmssDependencyAgentChangePolicy.vmssEnableDependencyAgentWinDefDisplayName
    vmssEnableDependencyAgentWinDefName: namingData.vmssDependencyAgentChangePolicy.vmssEnableDependencyAgentWinDefName
  }
}

module vmGuestConfigurationChange '../../childModules/policy/guestConfigurationChange/policy.bicep' = if (deployVmGuestConfigurationAgent && osMgmtChangePolicies) {
  name: '${uniqueDeployPrefix}-vmGuestConfigurationAgent-deployment'
  params: {
    policyMetadata: policyMeteringTag
    deployLocation: deployLocation
    policyRuleTag: managedPolicyRuleTag
    guestConfigChangeAssignmentDisplayName: namingData.guestConfigurationChangePolicy.guestConfigChangeAssignmentDisplayName
    guestConfigChangeAssignmentName: namingData.guestConfigurationChangePolicy.guestConfigChangeAssignmentName
    guestConfigChangeLinuxDefDisplayName: namingData.guestConfigurationChangePolicy.guestConfigChangeLinuxDefDisplayName
    guestConfigChangeLinuxDefName: namingData.guestConfigurationChangePolicy.guestConfigChangeLinuxDefName
    guestConfigChangeSetDisplayName: namingData.guestConfigurationChangePolicy.guestConfigChangeSetDisplayName
    guestConfigChangeSetName: namingData.guestConfigurationChangePolicy.guestConfigChangeSetName
    guestConfigChangeWinDefDisplayName: namingData.guestConfigurationChangePolicy.guestConfigChangeWinDefDisplayName
    guestConfigChangeWinDefName: namingData.guestConfigurationChangePolicy.guestConfigChangeWinDefName
  }
}

module azMonitorAgentLinuxChange '../../childModules/policy/azMonitorAgentLinuxChange/policy.bicep' = if (deployAzMonitorAgentLinuxChange && osMgmtChangePolicies) {
  name: '${uniqueDeployPrefix}-azMonitorAgentLinux-deployment'
  params: {
    deployLocation: deployLocation
    policyMetadata: policyMeteringTag
    policyRuleTag: managedPolicyRuleTag
    dataCollectionRuleResourceId: !empty(managementSubscriptionId) ? existingLinuxDataCollectionRuleResourceId.outputs.resourceID : ''
    scopeToSupportedImages: deployAzMonitorAgentLinuxSettings.scopeToSupportedImages
    listOfLinuxImageIdToInclude: contains(deployAzMonitorAgentLinuxSettings,'listOfLinuxImageIdToInclude') ? deployAzMonitorAgentLinuxSettings.listOfLinuxImageIdToInclude : []
    managementSubscriptionId: managementSubscriptionId
    enableAmAgentLinuxVmDefName: namingData.azMonitorAgentLinuxChangePolicy.enableAmAgentLinuxVmDefName
    enableAmAgentLinuxVmDefDisplayName: namingData.azMonitorAgentLinuxChangePolicy.enableAmAgentLinuxVmDefDisplayName
    enableAmAgentLinuxVmDefEffect: deployAzMonitorAgentLinuxSettings.enableAmAgentLinuxVmDefEffect
    enableAmAgentLinuxVmssDefName: namingData.azMonitorAgentLinuxChangePolicy.enableAmAgentLinuxVmssDefName
    enableAmAgentLinuxVmssDefDisplayName: namingData.azMonitorAgentLinuxChangePolicy.enableAmAgentLinuxVmssDefDisplayName
    enableAmAgentLinuxVmssDefEffect: deployAzMonitorAgentLinuxSettings.enableAmAgentLinuxVmssDefEffect
    dcrAssociationLinuxDefName: namingData.azMonitorAgentLinuxChangePolicy.dcrAssociationLinuxDefName
    dcrAssociationLinuxDefDisplayName: namingData.azMonitorAgentLinuxChangePolicy.dcrAssociationLinuxDefDisplayName
    dcrAssociationLinuxDefEffect: deployAzMonitorAgentLinuxSettings.dcrAssociationLinuxDefEffect
    enableAmAgentLinuxSetName: namingData.azMonitorAgentLinuxChangePolicy.enableAmAgentLinuxSetName
    enableAmAgentLinuxSetDisplayName: namingData.azMonitorAgentLinuxChangePolicy.enableAmAgentLinuxSetDisplayName
    enableAmAgentLinuxSetAssignmentName: namingData.azMonitorAgentLinuxChangePolicy.enableAmAgentLinuxSetAssignmentName
    enableAmAgentLinuxSetAssignmentDisplayName: namingData.azMonitorAgentLinuxChangePolicy.enableAmAgentLinuxSetAssignmentDisplayName
    userAssignedManagedIdentityName: namingData.monitoringUserManagedIdentityName.name
    userAssignedManagedIdentityResourceGroup: namingData.monitoringResourceGroup.name
  }
}

module azMonitorAgentWindowsChange '../../childModules/policy/azMonitorAgentWindowsChange/policy.bicep' = if (deployAzMonitorAgentWindowsChange && osMgmtChangePolicies) {
  name: '${uniqueDeployPrefix}-azMonitorAgentWindows-deployment'
  params: {
    deployLocation: deployLocation
    policyMetadata: policyMeteringTag
    policyRuleTag: managedPolicyRuleTag
    dataCollectionRuleResourceId: !empty(managementSubscriptionId) ? existingWindowsDataCollectionRuleResourceId.outputs.resourceID : ''
    scopeToSupportedImages: deployAzMonitorAgentWindowsSettings.scopeToSupportedImages
    listOfWindowsImageIdToInclude: contains(deployAzMonitorAgentWindowsSettings,'listOfWindowsImageIdToInclude') ? deployAzMonitorAgentWindowsSettings.listOfWindowsImageIdToInclude : []
    managementSubscriptionId: managementSubscriptionId
    enableAmAgentWindowsVmDefName: namingData.azMonitorAgentWindowsChangePolicy.enableAmAgentWindowsVmDefName
    enableAmAgentWindowsVmDefDisplayName: namingData.azMonitorAgentWindowsChangePolicy.enableAmAgentWindowsVmDefDisplayName
    enableAmAgentWindowsVmDefEffect: deployAzMonitorAgentWindowsSettings.enableAmAgentWindowsVmDefEffect
    enableAmAgentWindowsVmssDefName: namingData.azMonitorAgentWindowsChangePolicy.enableAmAgentWindowsVmssDefName
    enableAmAgentWindowsVmssDefDisplayName: namingData.azMonitorAgentWindowsChangePolicy.enableAmAgentWindowsVmssDefDisplayName
    enableAmAgentWindowsVmssDefEffect: deployAzMonitorAgentWindowsSettings.enableAmAgentWindowsVmssDefEffect
    dcrAssociationWindowsDefName: namingData.azMonitorAgentWindowsChangePolicy.dcrAssociationWindowsDefName
    dcrAssociationWindowsDefDisplayName: namingData.azMonitorAgentWindowsChangePolicy.dcrAssociationWindowsDefDisplayName
    dcrAssociationWindowsDefEffect: deployAzMonitorAgentWindowsSettings.dcrAssociationWindowsDefEffect
    enableAmAgentWindowsSetName: namingData.azMonitorAgentWindowsChangePolicy.enableAmAgentWindowsSetName
    enableAmAgentWindowsSetDisplayName: namingData.azMonitorAgentWindowsChangePolicy.enableAmAgentWindowsSetDisplayName
    enableAmAgentWindowsSetAssignmentName: namingData.azMonitorAgentWindowsChangePolicy.enableAmAgentWindowsSetAssignmentName
    enableAmAgentWindowsSetAssignmentDisplayName: namingData.azMonitorAgentWindowsChangePolicy.enableAmAgentWindowsSetAssignmentDisplayName
    userAssignedManagedIdentityName: namingData.monitoringUserManagedIdentityName.name
    userAssignedManagedIdentityResourceGroup: namingData.monitoringResourceGroup.name
  }
}

// paas change policies
module acrChange '../../childModules/policy/acrChange/policy.bicep' = if (deployAcrChange && paasChangePolicies) {
  name: '${uniqueDeployPrefix}-acrChange-deployment'
  params: {
    policyMetadata: policyMeteringTag
    policyRuleTag: managedPolicyRuleTag
    acrDisableTokenAccess: acrChangeSettings.acrDisableTokenAccess
    acrDisableAnonymousAuthentication: acrChangeSettings.acrDisableAnonymousAuthentication
    acrDisablePublicNetworkAccess: acrChangeSettings.acrDisablePublicNetworkAccess
    acrDisableLocalAuthentication: acrChangeSettings.acrDisableLocalAuthentication
    deployLocation: deployLocation
    acrDisableAnonymousAuthenticationDefDisplayName: namingData.acrChangePolicy.acrDisableAnonymousAuthenticationDefDisplayName
    acrDisableAnonymousAuthenticationDefName: namingData.acrChangePolicy.acrDisableAnonymousAuthenticationDefName
    acrDisableLocalAuthenticationDefDisplayName: namingData.acrChangePolicy.acrDisableLocalAuthenticationDefDisplayName
    acrDisableLocalAuthenticationDefName: namingData.acrChangePolicy.acrDisableLocalAuthenticationDefName
    acrDisablePublicNetworkAccessDefDisplayName: namingData.acrChangePolicy.acrDisablePublicNetworkAccessDefDisplayName
    acrDisablePublicNetworkAccessDefName: namingData.acrChangePolicy.acrDisablePublicNetworkAccessDefName
    acrDisableSetAssignmentDisplayName: namingData.acrChangePolicy.acrDisableSetAssignmentDisplayName
    acrDisableSetAssignmentName: namingData.acrChangePolicy.acrDisableSetAssignmentName
    acrDisableSetDisplayName: namingData.acrChangePolicy.acrDisableSetDisplayName
    acrDisableSetName: namingData.acrChangePolicy.acrDisableSetName
    acrDisableTokenAccessDefDisplayName: namingData.acrChangePolicy.acrDisableTokenAccessDefDisplayName
    acrDisableTokenAccessDefName: namingData.acrChangePolicy.acrDisableTokenAccessDefName
  }
}

module appServiceChange '../../childModules/policy/appServiceChange/policy.bicep' = if (deployAppServiceChange && paasChangePolicies) {
  name: '${uniqueDeployPrefix}-appServiceChange-deployment'
  params: {
    excludedResources: subscriptionType == 'mgmt' ? [
      existingItsmFunctionApp.outputs.resourceID
      existingMeteringFunctionApp.outputs.resourceID
      existingOsTaggingFunctionApp.outputs.resourceID
    ] : []
    policyMetadata: policyMeteringTag
    policyRuleTag: managedPolicyRuleTag
    appServiceDisableFtpDeployments: appServiceChangeSettings.appServiceDisableFtpDeployments
    appServiceDisableSlotsFtpLocalAuthentication: appServiceChangeSettings.appServiceDisableSlotsFtpLocalAuthentication
    appServiceDisableSlotsScmLocalAuthentication: appServiceChangeSettings.appServiceDisableSlotsScmLocalAuthentication
    appServiceDisableScmLocalAuthentication: appServiceChangeSettings.appServiceDisableScmLocalAuthentication
    appServiceDisablePublicNetwork: appServiceChangeSettings.appServiceDisablePublicNetwork
    deployLocation: deployLocation
    appServiceChangeSetAssignmentDisplayName: namingData.appServiceChangePolicy.appServiceChangeSetAssignmentDisplayName
    appServiceChangeSetAssignmentName: namingData.appServiceChangePolicy.appServiceChangeSetAssignmentName
    appServiceChangeSetDisplayName: namingData.appServiceChangePolicy.appServiceChangeSetDisplayName
    appServiceChangeSetName: namingData.appServiceChangePolicy.appServiceChangeSetName
    appServiceDisableFtpsDeploymentDefDisplayName: namingData.appServiceChangePolicy.appServiceDisableFtpsDeploymentDefDisplayName
    appServiceDisableFtpsDeploymentDefName: namingData.appServiceChangePolicy.appServiceDisableFtpsDeploymentDefName
    appServiceDisablePublicNetworkAccessDefDisplayName: namingData.appServiceChangePolicy.appServiceDisablePublicNetworkAccessDefDisplayName
    appServiceDisablePublicNetworkAccessDefName: namingData.appServiceChangePolicy.appServiceDisablePublicNetworkAccessDefName
    appServiceDisableScmLocalAuthenticationDefDisplayName: namingData.appServiceChangePolicy.appServiceDisableScmLocalAuthenticationDefDisplayName
    appServiceDisableScmLocalAuthenticationDefName: namingData.appServiceChangePolicy.appServiceDisableScmLocalAuthenticationDefName
    appServiceDisableSlotsFtpLocalAuthenticationDefDisplayName: namingData.appServiceChangePolicy.appServiceDisableSlotsFtpLocalAuthenticationDefDisplayName
    appServiceDisableSlotsFtpLocalAuthenticationDefName: namingData.appServiceChangePolicy.appServiceDisableSlotsFtpLocalAuthenticationDefName
    appServiceDisableSlotsScmLocalAuthenticationDefDisplayName: namingData.appServiceChangePolicy.appServiceDisableSlotsScmLocalAuthenticationDefDisplayName
    appServiceDisableSlotsScmLocalAuthenticationDefName: namingData.appServiceChangePolicy.appServiceDisableSlotsScmLocalAuthenticationDefName
  }
}

module cosmosDbChange '../../childModules/policy/cosmosDbChange/policy.bicep' = if (deployCosmosDbChange && paasChangePolicies) {
  name: '${uniqueDeployPrefix}-cosmosDbChange-deployment'
  params: {
    policyMetadata: policyMeteringTag
    disableLocalAuthenticationEffect: cosmosDbChangeSettings.disableLocalAuthenticationEffect
    advancedThreatProtectionEffect: cosmosDbChangeSettings.advancedThreatProtectionEffect
    disableMetadataWriteAccessEffect: cosmosDbChangeSettings.disableMetadataWriteAccessEffect
    policyRuleTag: managedPolicyRuleTag
    deployLocation: deployLocation
    cosmosdbAdvancedThreatProtectionDefDisplayName: namingData.cosmosDbChangePolicy.cosmosdbAdvancedThreatProtectionDefDisplayName
    cosmosdbAdvancedThreatProtectionDefName: namingData.cosmosDbChangePolicy.cosmosdbAdvancedThreatProtectionDefName
    cosmosdbChangeSetAssignmentDisplayName: namingData.cosmosDbChangePolicy.cosmosdbChangeSetAssignmentDisplayName
    cosmosdbChangeSetAssignmentName: namingData.cosmosDbChangePolicy.cosmosdbChangeSetAssignmentName
    cosmosdbChangeSetDisplayName: namingData.cosmosDbChangePolicy.cosmosdbChangeSetDisplayName
    cosmosdbChangeSetName: namingData.cosmosDbChangePolicy.cosmosdbChangeSetName
    cosmosdbDisableLocalAuthenticationDefDisplayName: namingData.cosmosDbChangePolicy.cosmosdbDisableLocalAuthenticationDefDisplayName
    cosmosdbDisableLocalAuthenticationDefName: namingData.cosmosDbChangePolicy.cosmosdbDisableLocalAuthenticationDefName
    cosmosDbDisableMetadataWriteAccessDefDisplayName:namingData.cosmosDbChangePolicy.cosmosDbDisableMetadataWriteAccessDefDisplayName
    cosmosDbDisableMetadataWriteAccessDefName:namingData.cosmosDbChangePolicy.cosmosDbDisableMetadataWriteAccessDefName
  }
}

module datafactoryChange '../../childModules/policy/datafactoryChange/policy.bicep' = if (deployDatafactoryChange && paasChangePolicies) {
  name: '${uniqueDeployPrefix}-datafactoryChange-deployment'
  params: {
    policyMetadata: policyMeteringTag
    policyRuleTag: managedPolicyRuleTag
    disablePublicNetworkAccessEffect: datafactoryChangeSetting
    deployLocation: deployLocation
    dataFactoryChangeSetAssignmentDisplayName: namingData.datafactoryChangePolicy.dataFactoryChangeSetAssignmentDisplayName
    dataFactoryChangeSetAssignmentName: namingData.datafactoryChangePolicy.dataFactoryChangeSetAssignmentName
    dataFactoryChangeSetDisplayName: namingData.datafactoryChangePolicy.dataFactoryChangeSetDisplayName
    dataFactoryChangeSetName: namingData.datafactoryChangePolicy.dataFactoryChangeSetName
    disablePublicNetworkAccessDefDisplayName: namingData.datafactoryChangePolicy.disablePublicNetworkAccessDefDisplayName
    disablePublicNetworkAccessDefName: namingData.datafactoryChangePolicy.disablePublicNetworkAccessDefName
  }
}

module kubernetesChange '../../childModules/policy/kubernetesChange/policy.bicep' = if (deployKubernetesChange && paasChangePolicies) {
  name: '${uniqueDeployPrefix}-kubernetesChange-deployment'
  params: {
    managementSubscriptionId: managementSubscriptionId
    policyMetadata: policyMeteringTag
    policyRuleTag: managedPolicyRuleTag
    aksAadAdminEffect: kubernetesChangeSettings.aksAADAdminEffect
    aksAdminGroupIds: kubernetesChangeSettings.aksAdminGroupIds
    aksMonitoringAddonEffect: kubernetesChangeSettings.aksMonitoringAddonEffect
    logAnalyticsWorkspaceResourceId: !empty(managementSubscriptionId) ? existingWorkspaceInMgmt.outputs.resourceID : ''
    deployLocation: deployLocation
    deployAksAadAdminPolicyDefDisplayName: namingData.kubernetesChangePolicy.deployAksAadAdminPolicyDefDisplayName
    deployAksAadAdminPolicyDefName: namingData.kubernetesChangePolicy.deployAksAadAdminPolicyDefName
    aksMonitoringAddonPolicyDefDisplayName: namingData.kubernetesChangePolicy.aksMonitoringAddonPolicyDefDisplayName
    aksMonitoringAddonPolicyDefName: namingData.kubernetesChangePolicy.aksMonitoringAddonPolicyDefName
    kubernetesChangeSetDisplayName: namingData.kubernetesChangePolicy.kubernetesChangeSetDisplayName
    kubernetesChangeSetName: namingData.kubernetesChangePolicy.kubernetesChangeSetName
    kubernetesChangeSetAssignmentDisplayName: namingData.kubernetesChangePolicy.kubernetesChangeSetAssignmentDisplayName
    kubernetesChangeSetAssignmentName: namingData.kubernetesChangePolicy.kubernetesChangeSetAssignmentName
  }
}

// OUTPUTS
