/*
SUMMARY: Exemption Solution
DESCRIPTION: Parent module to deploy the exemptions for the CIS, ISO, ASB Governance Initiatives.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.1
*/

// PARAMETERS

targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

@description('Parameter to determine the subscription using abbreviation. To be provided by the pipeline')
@allowed([
  'mgmt'
  'cnty'
])
param subscriptionType string

@description('Parameter to determine if vwan or usual hub spoke network is deployed. To be provided by the pipeline')
param deployVwan string = ''

// VARIABLES

//Variables to load in the naming convention files for resource naming.

var namingJsonData = {
  mgmt: {
    definition: json(loadTextContent('../../mgmtNaming.json'))
  }
  cnty: {
    definition: json(loadTextContent('../../cntyNaming.json'))
  }
}
var namingData = namingJsonData[subscriptionType].definition

//Variables to load exemptions.

var exemptions = loadJsonContent('./exemptions.json')

// Variables to determine policy assignment id's for CIS, ISO, ASB

var cisInitiative = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/policyAssignments/${namingData.cisAuditDenyPolicy.cisAuditDenySetAssignmentName}'
var isoInitiative = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/policyAssignments/${namingData.iso27001AuditDenyPolicy.iso27001AuditDenySetAssignmentName}'
var asbInitiative = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/policyAssignments/${namingData.securityBenchmarkAuditDenyPolicy.securityBenchmarkAuditDenySetAssignmentName}'

// Bootstrap Solution.

var artifactResourceGroup = namingData.bootstrapResourceGroup.name
var artifactStorageAccount = namingData.artifactStorageAccount.name

// Networking Solution.

var hubResourceGroup = namingData.hubResourceGroup.name
var connectivityHubNetworkVnet = namingData.connectivityHubNetworkVnet.name

var connectivityHubVnetSubNetNsg = namingData.connectivityHubVnetSubNetNsg.name

// Virtual Wan Solution.

var sharedConnectivityVirtualWanResourceGroup = namingData.sharedConnectivityNetworkResourcesResourceGroup.name
var connectivityVirtualWanHubNetworkVnet = namingData.sharedConnectivityHubNetworkVnet.name
var connectivityTlsKeyVaultName = namingData.tlsKeyVaultName.name
var connectivityVirtualWanResourceGroup = namingData.connectivityVirtualWanResourceGroup.name

// Reporting Solution.

var reportingResourceGroup = namingData.mgmtReportingResourceGroup.name
var reportingStorageAccount = namingData.managementReportingStorageAccount.name

// Metering Solution.

var billingAppService = namingData.customerBillingFunctionApp.name
var billingStorageAccount = namingData.customerBillingStorageAccount.name
var billingKeyVault = namingData.customerBillingKeyVault.name
var billingResourceGroup = namingData.customerBillingResourceGroup.name

// ITSM Solution.

var itsmResourceGroup = namingData.managementItsmResourceGroup.name
var itsmPwshStorageAccount = namingData.customerItsmPwshStorageAccount.name
var itsmPwshFunctionApp = namingData.customerItsmPwshFunctionApp.name
var itsmKeyvault = namingData.customerItsmKeyVault.name

// Compute Gallery Solution.

var computeGalleryResourceGroup = namingData.computeGalleryResourceGroup.name
var computeGalleryStorageAccount = namingData.computeGalleryStorageAccount.name

// Os Tagging Solution.

var osTaggingFunctionAppResourceGroup = namingData.osTaggingResourceGroup.name
var osTaggingStorageAccount = namingData.osTaggingFuncStorageAccount.name
var osTaggingAppServicePlan = namingData.osTaggingFuncAppServicePlan.name

// Variable which holds a unique value for deployment, which is bound to the subscription id and deployment location.
#disable-next-line no-loc-expr-outside-params
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployment().location), 0, 6)

// RESOURCE DEPLOYMENTS

// Exemptions for Bootstrap Solution.

module cisArtifactStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.bootstrapSolution.deployExemptionsForBootstrap == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(artifactResourceGroup)
  name: '${artifactStorageAccount}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.bootstrapSolution.cisArtifactStorageAccount.category
    addTime: exemptions.bootstrapSolution.cisArtifactStorageAccount.exemptionDuration
    resourceName: artifactStorageAccount
    policyAssignmentShortcode: exemptions.bootstrapSolution.cisArtifactStorageAccount.shortCode
    policyAssignmentId: exemptions.bootstrapSolution.cisArtifactStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.bootstrapSolution.cisArtifactStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.bootstrapSolution.cisArtifactStorageAccount.policyDefinitionReferenceIds
  }
}

module isoArtifactStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.bootstrapSolution.deployExemptionsForBootstrap == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(artifactResourceGroup)
  name: '${artifactStorageAccount}-isoExemption-deployment'
  params: {
    exemptionCategory: exemptions.bootstrapSolution.isoArtifactStorageAccount.category
    addTime: exemptions.bootstrapSolution.isoArtifactStorageAccount.exemptionDuration
    resourceName: artifactStorageAccount
    policyAssignmentShortcode: exemptions.bootstrapSolution.isoArtifactStorageAccount.shortCode
    policyAssignmentId: exemptions.bootstrapSolution.isoArtifactStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.bootstrapSolution.isoArtifactStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.bootstrapSolution.isoArtifactStorageAccount.policyDefinitionReferenceIds
  }
}

module asbArtifactStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.bootstrapSolution.deployExemptionsForBootstrap == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(artifactResourceGroup)
  name: '${artifactStorageAccount}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.bootstrapSolution.asbArtifactStorageAccount.category
    addTime: exemptions.bootstrapSolution.asbArtifactStorageAccount.exemptionDuration
    resourceName: artifactStorageAccount
    policyAssignmentShortcode: exemptions.bootstrapSolution.asbArtifactStorageAccount.shortCode
    policyAssignmentId: exemptions.bootstrapSolution.asbArtifactStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.bootstrapSolution.asbArtifactStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.bootstrapSolution.asbArtifactStorageAccount.policyDefinitionReferenceIds
  }
}

// Exemptions for Networking Solution.

module asbConnectivityHubNetworkVnet '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.networkingSolution.deployExemptionsForNetworking == true && (subscriptionType == 'cnty') && (deployVwan == 'no')) {
  scope: resourceGroup(hubResourceGroup)
  name: '${connectivityHubNetworkVnet}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.networkingSolution.asbVnetNetworking.category
    addTime: exemptions.networkingSolution.asbVnetNetworking.exemptionDuration
    resourceName: connectivityHubNetworkVnet
    policyAssignmentShortcode: exemptions.networkingSolution.asbVnetNetworking.shortCode
    policyAssignmentId: exemptions.networkingSolution.asbVnetNetworking.shortCode == 'asb' ? asbInitiative : exemptions.networkingSolution.asbVnetNetworking.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.networkingSolution.asbVnetNetworking.policyDefinitionReferenceIds
  }
}

module cisConnectivityHubNetworkVnet '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.networkingSolution.deployExemptionsForNetworking == true && (subscriptionType == 'cnty') && (deployVwan == 'no')) {
  scope: resourceGroup(hubResourceGroup)
  name: '${connectivityHubNetworkVnet}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.networkingSolution.cisVnetNetworking.category
    addTime: exemptions.networkingSolution.cisVnetNetworking.exemptionDuration
    resourceName: connectivityHubNetworkVnet
    policyAssignmentShortcode: exemptions.networkingSolution.cisVnetNetworking.shortCode
    policyAssignmentId: exemptions.networkingSolution.cisVnetNetworking.shortCode == 'asb' ? asbInitiative : exemptions.networkingSolution.cisVnetNetworking.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.networkingSolution.cisVnetNetworking.policyDefinitionReferenceIds
  }
}

module cisConnectivityHubVnetSubNetNsg '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.networkingSolution.deployExemptionsForNetworking == true && (subscriptionType == 'cnty') && (deployVwan == 'no')) {
  scope: resourceGroup(hubResourceGroup)
  name: '${connectivityHubVnetSubNetNsg}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.networkingSolution.cisNsgNetworking.category
    addTime: exemptions.networkingSolution.cisNsgNetworking.exemptionDuration
    resourceName: connectivityHubVnetSubNetNsg
    policyAssignmentShortcode: exemptions.networkingSolution.cisNsgNetworking.shortCode
    policyAssignmentId: exemptions.networkingSolution.cisNsgNetworking.shortCode == 'asb' ? asbInitiative : exemptions.networkingSolution.cisNsgNetworking.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.networkingSolution.cisNsgNetworking.policyDefinitionReferenceIds
  }
}

module cisConnectivityTlsKeyVaultName '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.networkingSolution.deployExemptionsForNetworking == true && (subscriptionType == 'cnty') && (deployVwan == 'no')) {
  scope: resourceGroup(hubResourceGroup)
  name: '${connectivityTlsKeyVaultName}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.networkingSolution.cisTlsKeyvault.category
    addTime: exemptions.networkingSolution.cisTlsKeyvault.exemptionDuration
    resourceName: connectivityTlsKeyVaultName
    policyAssignmentShortcode: exemptions.networkingSolution.cisTlsKeyvault.shortCode
    policyAssignmentId: exemptions.networkingSolution.cisTlsKeyvault.shortCode == 'asb' ? asbInitiative : exemptions.networkingSolution.cisTlsKeyvault.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.networkingSolution.cisTlsKeyvault.policyDefinitionReferenceIds
  }
}

// Exemptions for Virtual Wan Solution.

module asbConnectivityVirtualWanHubNetworkVnet '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.virtualWanSolution.deployExemptionsForVirtualWan == true && (subscriptionType == 'cnty') && (deployVwan == 'yes')) {
  scope: resourceGroup(sharedConnectivityVirtualWanResourceGroup)
  name: '${connectivityVirtualWanHubNetworkVnet}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.virtualWanSolution.asbVnetNetworking.category
    addTime: exemptions.virtualWanSolution.asbVnetNetworking.exemptionDuration
    resourceName: connectivityVirtualWanHubNetworkVnet
    policyAssignmentShortcode: exemptions.virtualWanSolution.asbVnetNetworking.shortCode
    policyAssignmentId: exemptions.virtualWanSolution.asbVnetNetworking.shortCode == 'asb' ? asbInitiative : exemptions.virtualWanSolution.asbVnetNetworking.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.virtualWanSolution.asbVnetNetworking.policyDefinitionReferenceIds
  }
}

module cisConnectivityVirtualWanHubNetworkVnet '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.virtualWanSolution.deployExemptionsForVirtualWan == true && (subscriptionType == 'cnty') && (deployVwan == 'yes')) {
  scope: resourceGroup(sharedConnectivityVirtualWanResourceGroup)
  name: '${connectivityVirtualWanHubNetworkVnet}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.virtualWanSolution.cisVnetNetworking.category
    addTime: exemptions.virtualWanSolution.cisVnetNetworking.exemptionDuration
    resourceName: connectivityVirtualWanHubNetworkVnet
    policyAssignmentShortcode: exemptions.virtualWanSolution.cisVnetNetworking.shortCode
    policyAssignmentId: exemptions.virtualWanSolution.cisVnetNetworking.shortCode == 'asb' ? asbInitiative : exemptions.virtualWanSolution.cisVnetNetworking.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.virtualWanSolution.cisVnetNetworking.policyDefinitionReferenceIds
  }
}

module cisConnectivityVwanHubVnetSubNetNsg '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.virtualWanSolution.deployExemptionsForVirtualWan == true && (subscriptionType == 'cnty') && (deployVwan == 'yes')) {
  scope: resourceGroup(sharedConnectivityVirtualWanResourceGroup)
  name: '${connectivityHubVnetSubNetNsg}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.virtualWanSolution.cisNsgNetworking.category
    addTime: exemptions.virtualWanSolution.cisNsgNetworking.exemptionDuration
    resourceName: connectivityVirtualWanHubNetworkVnet
    policyAssignmentShortcode: exemptions.virtualWanSolution.cisNsgNetworking.shortCode
    policyAssignmentId: exemptions.virtualWanSolution.cisNsgNetworking.shortCode == 'asb' ? asbInitiative : exemptions.virtualWanSolution.cisNsgNetworking.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.virtualWanSolution.cisNsgNetworking.policyDefinitionReferenceIds
  }
}

module cisConnectivityVwanTlsKeyVaultName '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.virtualWanSolution.deployExemptionsForVirtualWan == true && (subscriptionType == 'cnty') && (deployVwan == 'yes')) {
  scope: resourceGroup(sharedConnectivityVirtualWanResourceGroup)
  name: '${connectivityTlsKeyVaultName}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.virtualWanSolution.cisTlsKeyvault.category
    addTime: exemptions.virtualWanSolution.cisTlsKeyvault.exemptionDuration
    resourceName: connectivityTlsKeyVaultName
    policyAssignmentShortcode: exemptions.virtualWanSolution.cisTlsKeyvault.shortCode
    policyAssignmentId: exemptions.virtualWanSolution.cisTlsKeyvault.shortCode == 'asb' ? asbInitiative : exemptions.virtualWanSolution.cisTlsKeyvault.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.virtualWanSolution.cisTlsKeyvault.policyDefinitionReferenceIds
  }
}

// Exemptions for Reporting Solution.

module cisReportingStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.reportingSolution.deployExemptionsForReporting == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(reportingResourceGroup)
  name: '${reportingStorageAccount}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.reportingSolution.cisReportingStorageAccount.category
    addTime: exemptions.reportingSolution.cisReportingStorageAccount.exemptionDuration
    resourceName: reportingStorageAccount
    policyAssignmentShortcode: exemptions.reportingSolution.cisReportingStorageAccount.shortCode
    policyAssignmentId: exemptions.reportingSolution.cisReportingStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.reportingSolution.cisReportingStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.reportingSolution.cisReportingStorageAccount.policyDefinitionReferenceIds
  }
}

module isoReportingStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.reportingSolution.deployExemptionsForReporting == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(reportingResourceGroup)
  name: '${reportingStorageAccount}-isoExemption-deployment'
  params: {
    exemptionCategory: exemptions.reportingSolution.isoReportingStorageAccount.category
    addTime: exemptions.reportingSolution.isoReportingStorageAccount.exemptionDuration
    resourceName: reportingStorageAccount
    policyAssignmentShortcode: exemptions.reportingSolution.isoReportingStorageAccount.shortCode
    policyAssignmentId: exemptions.reportingSolution.isoReportingStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.reportingSolution.isoReportingStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.reportingSolution.isoReportingStorageAccount.policyDefinitionReferenceIds
  }
}

module asbReportingStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.reportingSolution.deployExemptionsForReporting == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(reportingResourceGroup)
  name: '${reportingStorageAccount}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.reportingSolution.asbReportingStorageAccount.category
    addTime: exemptions.reportingSolution.asbReportingStorageAccount.exemptionDuration
    resourceName: reportingStorageAccount
    policyAssignmentShortcode: exemptions.reportingSolution.asbReportingStorageAccount.shortCode
    policyAssignmentId: exemptions.reportingSolution.asbReportingStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.reportingSolution.asbReportingStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.reportingSolution.asbReportingStorageAccount.policyDefinitionReferenceIds
  }
}
// Exemptions for Metering Solution.

module meteringAppService '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.meteringSolution.deployExemptionsForMetering == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(billingResourceGroup)
  name: '${billingAppService}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.meteringSolution.cisMeteringAppService.category
    addTime: exemptions.meteringSolution.cisMeteringAppService.exemptionDuration
    resourceName: billingAppService
    policyAssignmentShortcode: exemptions.meteringSolution.cisMeteringAppService.shortCode
    policyAssignmentId: exemptions.meteringSolution.cisMeteringAppService.shortCode == 'asb' ? asbInitiative : exemptions.meteringSolution.cisMeteringAppService.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.meteringSolution.cisMeteringAppService.policyDefinitionReferenceIds
  }
}

module cisBillingStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.meteringSolution.deployExemptionsForMetering == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(billingResourceGroup)
  name: '${billingStorageAccount}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.meteringSolution.cisBillingStorageAccount.category
    addTime: exemptions.meteringSolution.cisBillingStorageAccount.exemptionDuration
    resourceName: billingStorageAccount
    policyAssignmentShortcode: exemptions.meteringSolution.cisBillingStorageAccount.shortCode
    policyAssignmentId: exemptions.meteringSolution.cisBillingStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.meteringSolution.cisBillingStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.meteringSolution.cisBillingStorageAccount.policyDefinitionReferenceIds
  }
}

module cisBillingKeyVault '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.meteringSolution.deployExemptionsForMetering == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(billingResourceGroup)
  name: '${billingKeyVault}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.meteringSolution.cisBillingKeyVault.category
    addTime: exemptions.meteringSolution.cisBillingKeyVault.exemptionDuration
    resourceName: billingKeyVault
    policyAssignmentShortcode: exemptions.meteringSolution.cisBillingKeyVault.shortCode
    policyAssignmentId: exemptions.meteringSolution.cisBillingKeyVault.shortCode == 'asb' ? asbInitiative : exemptions.meteringSolution.cisBillingKeyVault.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.meteringSolution.cisBillingKeyVault.policyDefinitionReferenceIds
  }
}

module isoBillingStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.meteringSolution.deployExemptionsForMetering == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(billingResourceGroup)
  name: '${billingStorageAccount}-isoExemption-deployment'
  params: {
    exemptionCategory: exemptions.meteringSolution.isoBillingStorageAccount.category
    addTime: exemptions.meteringSolution.isoBillingStorageAccount.exemptionDuration
    resourceName: billingStorageAccount
    policyAssignmentShortcode: exemptions.meteringSolution.isoBillingStorageAccount.shortCode
    policyAssignmentId: exemptions.meteringSolution.isoBillingStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.meteringSolution.isoBillingStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.meteringSolution.isoBillingStorageAccount.policyDefinitionReferenceIds
  }
}

module asbBillingStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.meteringSolution.deployExemptionsForMetering == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(billingResourceGroup)
  name: '${billingStorageAccount}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.meteringSolution.asbBillingStorageAccount.category
    addTime: exemptions.meteringSolution.asbBillingStorageAccount.exemptionDuration
    resourceName: billingStorageAccount
    policyAssignmentShortcode: exemptions.meteringSolution.asbBillingStorageAccount.shortCode
    policyAssignmentId: exemptions.meteringSolution.asbBillingStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.meteringSolution.asbBillingStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.meteringSolution.asbBillingStorageAccount.policyDefinitionReferenceIds
  }
}

module asbBillingKeyVault '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.meteringSolution.deployExemptionsForMetering == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(billingResourceGroup)
  name: '${billingKeyVault}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.meteringSolution.asbBillingKeyVault.category
    addTime: exemptions.meteringSolution.asbBillingKeyVault.exemptionDuration
    resourceName: billingKeyVault
    policyAssignmentShortcode: exemptions.meteringSolution.asbBillingKeyVault.shortCode
    policyAssignmentId: exemptions.meteringSolution.asbBillingKeyVault.shortCode == 'asb' ? asbInitiative : exemptions.meteringSolution.asbBillingKeyVault.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.meteringSolution.asbBillingKeyVault.policyDefinitionReferenceIds
  }
}

module asbBillingAppService '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.meteringSolution.deployExemptionsForMetering == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(billingResourceGroup)
  name: '${billingAppService}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.meteringSolution.asbBillingAppService.category
    addTime: exemptions.meteringSolution.asbBillingAppService.exemptionDuration
    resourceName: billingAppService
    policyAssignmentShortcode: exemptions.meteringSolution.asbBillingAppService.shortCode
    policyAssignmentId: exemptions.meteringSolution.asbBillingAppService.shortCode == 'asb' ? asbInitiative : exemptions.meteringSolution.asbBillingAppService.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.meteringSolution.asbBillingAppService.policyDefinitionReferenceIds
  }
}

// Exemptions for ITSM Solution.

module cisItsmPwshStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.itsmSolution.deployExemptionsForItsm == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(itsmResourceGroup)
  name: '${itsmPwshStorageAccount}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.itsmSolution.cisItsmPwshStorageAccount.category
    addTime: exemptions.itsmSolution.cisItsmPwshStorageAccount.exemptionDuration
    resourceName: itsmPwshStorageAccount
    policyAssignmentShortcode: exemptions.itsmSolution.cisItsmPwshStorageAccount.shortCode
    policyAssignmentId: exemptions.itsmSolution.cisItsmPwshStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.itsmSolution.cisItsmPwshStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.itsmSolution.cisItsmPwshStorageAccount.policyDefinitionReferenceIds
  }
}

module cisItsmPwshFunctionApp '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.itsmSolution.deployExemptionsForItsm == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(itsmResourceGroup)
  name: '${itsmPwshFunctionApp}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.itsmSolution.cisItsmPwshFunctionApp.category
    addTime: exemptions.itsmSolution.cisItsmPwshFunctionApp.exemptionDuration
    resourceName: itsmPwshFunctionApp
    policyAssignmentShortcode: exemptions.itsmSolution.cisItsmPwshFunctionApp.shortCode
    policyAssignmentId: exemptions.itsmSolution.cisItsmPwshFunctionApp.shortCode == 'asb' ? asbInitiative : exemptions.itsmSolution.cisItsmPwshFunctionApp.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.itsmSolution.cisItsmPwshFunctionApp.policyDefinitionReferenceIds
  }
}

module cisItsmKeyVaultExemptions '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.itsmSolution.deployExemptionsForItsm == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(itsmResourceGroup)
  name: '${itsmKeyvault}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.itsmSolution.cisItsmKeyVault.category
    addTime: exemptions.itsmSolution.cisItsmKeyVault.exemptionDuration
    resourceName: itsmKeyvault
    policyAssignmentShortcode: exemptions.itsmSolution.cisItsmKeyVault.shortCode
    policyAssignmentId: exemptions.itsmSolution.cisItsmKeyVault.shortCode == 'asb' ? asbInitiative : exemptions.itsmSolution.cisItsmKeyVault.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.itsmSolution.cisItsmKeyVault.policyDefinitionReferenceIds
  }
}

module asbItsmPwshFunctionApp '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.itsmSolution.deployExemptionsForItsm == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(itsmResourceGroup)
  name: '${itsmPwshFunctionApp}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.itsmSolution.asbItsmPwshFunctionApp.category
    addTime: exemptions.itsmSolution.asbItsmPwshFunctionApp.exemptionDuration
    resourceName: itsmPwshFunctionApp
    policyAssignmentShortcode: exemptions.itsmSolution.asbItsmPwshFunctionApp.shortCode
    policyAssignmentId: exemptions.itsmSolution.asbItsmPwshFunctionApp.shortCode == 'asb' ? asbInitiative : exemptions.itsmSolution.asbItsmPwshFunctionApp.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.itsmSolution.asbItsmPwshFunctionApp.policyDefinitionReferenceIds
  }
}

module asbItsmPwshStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.itsmSolution.deployExemptionsForItsm == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(itsmResourceGroup)
  name: '${itsmPwshStorageAccount}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.itsmSolution.asbItsmPwshStorageAccount.category
    addTime: exemptions.itsmSolution.asbItsmPwshStorageAccount.exemptionDuration
    resourceName: itsmPwshStorageAccount
    policyAssignmentShortcode: exemptions.itsmSolution.asbItsmPwshStorageAccount.shortCode
    policyAssignmentId: exemptions.itsmSolution.asbItsmPwshStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.itsmSolution.asbItsmPwshStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.itsmSolution.asbItsmPwshStorageAccount.policyDefinitionReferenceIds
  }
}

module asbItsmKeyVaultExemptions '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.itsmSolution.deployExemptionsForItsm == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(itsmResourceGroup)
  name: '${itsmKeyvault}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.itsmSolution.asbItsmKeyVault.category
    addTime: exemptions.itsmSolution.asbItsmKeyVault.exemptionDuration
    resourceName: itsmKeyvault
    policyAssignmentShortcode: exemptions.itsmSolution.asbItsmKeyVault.shortCode
    policyAssignmentId: exemptions.itsmSolution.asbItsmKeyVault.shortCode == 'asb' ? asbInitiative : exemptions.itsmSolution.asbItsmKeyVault.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.itsmSolution.asbItsmKeyVault.policyDefinitionReferenceIds
  }
}

module isoItsmPwshStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.itsmSolution.deployExemptionsForItsm == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(itsmResourceGroup)
  name: '${itsmPwshStorageAccount}-isoExemption-deployment'
  params: {
    exemptionCategory: exemptions.itsmSolution.isoItsmPwshStorageAccount.category
    addTime: exemptions.itsmSolution.isoItsmPwshStorageAccount.exemptionDuration
    resourceName: itsmPwshStorageAccount
    policyAssignmentShortcode: exemptions.itsmSolution.isoItsmPwshStorageAccount.shortCode
    policyAssignmentId: exemptions.itsmSolution.isoItsmPwshStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.itsmSolution.isoItsmPwshStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.itsmSolution.isoItsmPwshStorageAccount.policyDefinitionReferenceIds
  }
}

// Exemptions for Compute Gallery Solution.

module cisComputeGalleryStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.computeGallerySolution.deployExemptionsForComputeGallery == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(computeGalleryResourceGroup)
  name: '${computeGalleryStorageAccount}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.computeGallerySolution.cisComputeGalleryStorageAccount.category
    addTime: exemptions.computeGallerySolution.cisComputeGalleryStorageAccount.exemptionDuration
    resourceName: computeGalleryStorageAccount
    policyAssignmentShortcode: exemptions.computeGallerySolution.cisComputeGalleryStorageAccount.shortCode
    policyAssignmentId: exemptions.computeGallerySolution.cisComputeGalleryStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.computeGallerySolution.cisComputeGalleryStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.computeGallerySolution.cisComputeGalleryStorageAccount.policyDefinitionReferenceIds
  }
}

module isoComputeGalleryStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.computeGallerySolution.deployExemptionsForComputeGallery == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(computeGalleryResourceGroup)
  name: '${computeGalleryStorageAccount}-isoExemption-deployment'
  params: {
    exemptionCategory: exemptions.computeGallerySolution.isoComputeGalleryStorageAccount.category
    addTime: exemptions.computeGallerySolution.isoComputeGalleryStorageAccount.exemptionDuration
    resourceName: computeGalleryStorageAccount
    policyAssignmentShortcode: exemptions.computeGallerySolution.isoComputeGalleryStorageAccount.shortCode
    policyAssignmentId: exemptions.computeGallerySolution.isoComputeGalleryStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.computeGallerySolution.isoComputeGalleryStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.computeGallerySolution.isoComputeGalleryStorageAccount.policyDefinitionReferenceIds
  }
}

module asbComputeGalleryStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.computeGallerySolution.deployExemptionsForComputeGallery == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(computeGalleryResourceGroup)
  name: '${computeGalleryStorageAccount}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.computeGallerySolution.asbComputeGalleryStorageAccount.category
    addTime: exemptions.computeGallerySolution.asbComputeGalleryStorageAccount.exemptionDuration
    resourceName: computeGalleryStorageAccount
    policyAssignmentShortcode: exemptions.computeGallerySolution.asbComputeGalleryStorageAccount.shortCode
    policyAssignmentId: exemptions.computeGallerySolution.asbComputeGalleryStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.computeGallerySolution.asbComputeGalleryStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.computeGallerySolution.asbComputeGalleryStorageAccount.policyDefinitionReferenceIds
  }
}

// Exemptions for Os Tagging Solution.

module cisOsTaggingStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.osTaggingSolution.deployExemptionsForOsTagging == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(osTaggingFunctionAppResourceGroup)
  name: '${osTaggingStorageAccount}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.osTaggingSolution.cisOsTaggingStorageAccount.category
    addTime: exemptions.osTaggingSolution.cisOsTaggingStorageAccount.exemptionDuration
    resourceName: osTaggingStorageAccount
    policyAssignmentShortcode: exemptions.osTaggingSolution.cisOsTaggingStorageAccount.shortCode
    policyAssignmentId: exemptions.osTaggingSolution.cisOsTaggingStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.osTaggingSolution.cisOsTaggingStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.osTaggingSolution.cisOsTaggingStorageAccount.policyDefinitionReferenceIds
  }
}

module isoOsTaggingStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.osTaggingSolution.deployExemptionsForOsTagging == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(osTaggingFunctionAppResourceGroup)
  name: '${osTaggingStorageAccount}-isoExemption-deployment'
  params: {
    exemptionCategory: exemptions.osTaggingSolution.isoOsTaggingStorageAccount.category
    addTime: exemptions.osTaggingSolution.isoOsTaggingStorageAccount.exemptionDuration
    resourceName: osTaggingStorageAccount
    policyAssignmentShortcode: exemptions.osTaggingSolution.isoOsTaggingStorageAccount.shortCode
    policyAssignmentId: exemptions.osTaggingSolution.isoOsTaggingStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.osTaggingSolution.isoOsTaggingStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.osTaggingSolution.isoOsTaggingStorageAccount.policyDefinitionReferenceIds
  }
}

module asbOsTaggingStorageAccount '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.osTaggingSolution.deployExemptionsForOsTagging == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(osTaggingFunctionAppResourceGroup)
  name: '${osTaggingStorageAccount}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.osTaggingSolution.asbOsTaggingStorageAccount.category
    addTime: exemptions.osTaggingSolution.asbOsTaggingStorageAccount.exemptionDuration
    resourceName: osTaggingStorageAccount
    policyAssignmentShortcode: exemptions.osTaggingSolution.asbOsTaggingStorageAccount.shortCode
    policyAssignmentId: exemptions.osTaggingSolution.asbOsTaggingStorageAccount.shortCode == 'asb' ? asbInitiative : exemptions.osTaggingSolution.asbOsTaggingStorageAccount.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.osTaggingSolution.asbOsTaggingStorageAccount.policyDefinitionReferenceIds
  }
}

module cisOsTaggingAppServicePlan '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.osTaggingSolution.deployExemptionsForOsTagging == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(osTaggingFunctionAppResourceGroup)
  name: '${osTaggingAppServicePlan}-cisExemption-deployment'
  params: {
    exemptionCategory: exemptions.osTaggingSolution.cisOsTaggingFunctionApp.category
    addTime: exemptions.osTaggingSolution.cisOsTaggingFunctionApp.exemptionDuration
    resourceName: osTaggingAppServicePlan
    policyAssignmentShortcode: exemptions.osTaggingSolution.cisOsTaggingFunctionApp.shortCode
    policyAssignmentId: exemptions.osTaggingSolution.cisOsTaggingFunctionApp.shortCode == 'asb' ? asbInitiative : exemptions.osTaggingSolution.cisOsTaggingFunctionApp.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.osTaggingSolution.cisOsTaggingFunctionApp.policyDefinitionReferenceIds
  }
}

module asbOsTaggingAppServicePlan '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.osTaggingSolution.deployExemptionsForOsTagging == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(osTaggingFunctionAppResourceGroup)
  name: '${osTaggingAppServicePlan}-asbExemption-deployment'
  params: {
    exemptionCategory: exemptions.osTaggingSolution.asbOsTaggingFunctionApp.category
    addTime: exemptions.osTaggingSolution.asbOsTaggingFunctionApp.exemptionDuration
    resourceName: osTaggingAppServicePlan
    policyAssignmentShortcode: exemptions.osTaggingSolution.asbOsTaggingFunctionApp.shortCode
    policyAssignmentId: exemptions.osTaggingSolution.asbOsTaggingFunctionApp.shortCode == 'asb' ? asbInitiative : exemptions.osTaggingSolution.asbOsTaggingFunctionApp.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.osTaggingSolution.asbOsTaggingFunctionApp.policyDefinitionReferenceIds
  }
}

// MGMT Subscription Exemptions.

module cisMgmtSubscriptionDeployment '../../childModules/subPolicyExemption/subPolicyExemption.bicep' = if (exemptions.mgmtSubscriptionExemptions.deployExemptionsForMgmtSub == true && (subscriptionType == 'mgmt')) {
  scope: subscription()
  name: '${uniqueDeployPrefix}-cisMgmtExemption-deployment'
  params: {
    exemptionCategory: exemptions.mgmtSubscriptionExemptions.cisMgmtSubExemptions.category
    addTime: exemptions.mgmtSubscriptionExemptions.cisMgmtSubExemptions.exemptionDuration
    policyAssignmentShortcode: exemptions.mgmtSubscriptionExemptions.cisMgmtSubExemptions.shortCode
    policyAssignmentId: exemptions.mgmtSubscriptionExemptions.cisMgmtSubExemptions.shortCode == 'asb' ? asbInitiative : exemptions.mgmtSubscriptionExemptions.cisMgmtSubExemptions.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.mgmtSubscriptionExemptions.cisMgmtSubExemptions.policyDefinitionReferenceIds
  }
}

module asbMgmtSubscriptionDeployment '../../childModules/subPolicyExemption/subPolicyExemption.bicep' = if (exemptions.mgmtSubscriptionExemptions.deployExemptionsForMgmtSub == true && (subscriptionType == 'mgmt')) {
  scope: subscription()
  name: '${uniqueDeployPrefix}-asbMgmtExemption-deployment'
  params: {
    exemptionCategory: exemptions.mgmtSubscriptionExemptions.asbMgmtSubExemptions.category
    addTime: exemptions.mgmtSubscriptionExemptions.asbMgmtSubExemptions.exemptionDuration
    policyAssignmentShortcode: exemptions.mgmtSubscriptionExemptions.asbMgmtSubExemptions.shortCode
    policyAssignmentId: exemptions.mgmtSubscriptionExemptions.asbMgmtSubExemptions.shortCode == 'asb' ? asbInitiative : exemptions.mgmtSubscriptionExemptions.asbMgmtSubExemptions.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.mgmtSubscriptionExemptions.asbMgmtSubExemptions.policyDefinitionReferenceIds
  }
}

// CNTY Subscription Exemptions

module asbCntySubscriptionDeployment '../../childModules/subPolicyExemption/subPolicyExemption.bicep' = if (exemptions.cntySubscriptionExemptions.deployExemptionsForCntytSub == true && (subscriptionType == 'cnty')) {
  scope: subscription()
  name: '${uniqueDeployPrefix}-asbCntyExemption-deployment'
  params: {
    exemptionCategory: exemptions.cntySubscriptionExemptions.asbCntySubExemptions.category
    addTime: exemptions.cntySubscriptionExemptions.asbCntySubExemptions.exemptionDuration
    policyAssignmentShortcode: exemptions.cntySubscriptionExemptions.asbCntySubExemptions.shortCode
    policyAssignmentId: exemptions.cntySubscriptionExemptions.asbCntySubExemptions.shortCode == 'asb' ? asbInitiative : exemptions.cntySubscriptionExemptions.asbCntySubExemptions.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.cntySubscriptionExemptions.asbCntySubExemptions.policyDefinitionReferenceIds
  }
}

module cisCntySubscriptionDeployment '../../childModules/subPolicyExemption/subPolicyExemption.bicep' = if (exemptions.cntySubscriptionExemptions.deployExemptionsForCntytSub == true && (subscriptionType == 'cnty')) {
  scope: subscription()
  name: '${uniqueDeployPrefix}-cisCntyExemption-deployment'
  params: {
    exemptionCategory: exemptions.cntySubscriptionExemptions.cisCntySubExemptions.category
    addTime: exemptions.cntySubscriptionExemptions.cisCntySubExemptions.exemptionDuration
    policyAssignmentShortcode: exemptions.cntySubscriptionExemptions.cisCntySubExemptions.shortCode
    policyAssignmentId: exemptions.cntySubscriptionExemptions.cisCntySubExemptions.shortCode == 'asb' ? asbInitiative : exemptions.cntySubscriptionExemptions.asbCntySubExemptions.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.cntySubscriptionExemptions.cisCntySubExemptions.policyDefinitionReferenceIds
  }
}

// OUTPUTS
