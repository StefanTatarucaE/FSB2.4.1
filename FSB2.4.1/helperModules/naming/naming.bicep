/*
SUMMARY: Naming convention child module.
DESCRIPTION: Naming convention for the Eviden Landingzones for Azure solution.
             This module will generate the naming for the ELZ Azure resources.
             The names will be outputted.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

//PARAMETERS
@minLength(3)
@maxLength(3)
@description('A three character UNIQUE Customer code according to ELZ naming convention indicating which customer we are deploying this automation for.')
param organizationCode string

@minLength(4)
@maxLength(4)
@description('A four character code according to ELZ naming convention to indicate which subscription we are deploying the automation to. Example "mgmt" for management, "lnd1" for the 1st landingzone.')
param subscriptionCode string

@minLength(1)
@maxLength(1)
@description('A one character code according to ELZ naming convention to indicate which environment type will be deployed to. Example "d" for Development, "t" for Test etc.')
param environmentCode string

@description('Supported Azure locations where the resource is being deployed.')
@allowed([
  'australiacentral' // 'auce'
  'australiacentral2' // 'auc2'
  'australiaeast' // 'auea'
  'australiasoutheast' // 'ause'
  'brazilsouth' // 'brso'
  'brazilsoutheast' // 'brse'
  'canadacentral' // 'cace'
  'canadaeast' // 'caea'
  'centralindia' // 'ince'
  'centralus' // 'usce'
  'eastasia' // 'asea'
  'eastus' // 'usea'
  'eastus2' // 'use2'
  'francecentral' // 'eufc'
  'francesouth' // 'frso'
  'germanynorth' // 'eugn'
  'germanywestcentral' // 'gewc'
  'japaneast' // 'jpea'
  'japanwest' // 'jpwe'
  'koreacentral' // 'koce'
  'koreasouth' // 'koso'
  'northcentralus' // 'usnc'
  'northeurope' // 'eune'
  'norwayeast' // 'nwea'
  'norwaywest' // 'nwwe'
  'southafricanorth' // 'sano'
  'southafricawest' // 'sawe'
  'southcentralus' // 'ussc'
  'southeastasia' // 'asse'
  'southindia' // 'inso'
  'switzerlandnorth' // 'swno'
  'switzerlandwest' // 'swwe'
  'uaecentral' // 'uace'
  'uaenorth' // 'uano'
  'uksouth' // 'ukso'
  'ukwest' // 'ukwe'
  'westcentralus' // 'uswc'
  'westeurope' // 'euwe'
  'westindia' // 'inwe'
  'westus' // 'uswe'
  'westus2' // 'usw2'
  'westus3' // 'usw3'
])
param azureLocation string

@description('It is recommended that you specify a suffix for consistency. Please use only lowercase characters when possible.')
param suffix array = []

@description('Company that releases this product. Used for branding. Provide, if required, with upper- and lowercase characters.')
param company string

@description('Companycode for company that releases this product. Used for branding. Provide, if required, with upper- and lowercase characters.')
param companyCode string

@description('Product name for the release. Provide without company name and, if required, with upper- and lowercase characters.')
param product string

@description('Product abbriviation for the release.')
param productCode string

@description('Provide a seed to generate unique names. Default to SubscriptionID')
// We generate the unique seed with the subscription ID instead of the resourceGroupID,
// because the naming resource group name is randomly generated and change each time the pipeline is deployed.
// param uniqueSeed string = resourceGroup().id
param uniqueSeed string = subscription().id

//@description('Max length of the uniqueness suffix to be added')
//param uniqueLength int = 6

@description('Use dashes as separator where applicable')
param useDash bool = true

@description('Create names using lowercase letters')
param useLowerCase bool = true

//VARIABLES
//A four character code according to ELZ naming convention to indicate which azure region we are deploying the automation to.'
var azureRegionMap = {
  australiacentral: {
    regionCode: 'auce'
  }
  australiacentral2: {
    regionCode: 'auc2'
  }
  australiaeast: {
    regionCode: 'auea'
  }
  australiasoutheast: {
    regionCode: 'ause'
  }
  brazilsouth: {
    regionCode: 'brso'
  }
  brazilsoutheast: {
    regionCode: 'brse'
  }
  canadacentral: {
    regionCode: 'cace'
  }
  canadaeast: {
    regionCode: 'caea'
  }
  centralindia: {
    regionCode: 'ince'
  }
  centralus: {
    regionCode: 'usce'
  }
  eastasia: {
    regionCode: 'asea'
  }
  eastus: {
    regionCode: 'usea'
  }
  eastus2: {
    regionCode: 'use2'
  }
  francecentral: {
    regionCode: 'eufc'
  }
  francesouth: {
    regionCode: 'frso'
  }
  germanynorth: {
    regionCode: 'eugn'
  }
  germanywestcentral: {
    regionCode: 'gewc'
  }
  japaneast: {
    regionCode: 'jpea'
  }
  japanwest: {
    regionCode: 'jpwe'
  }
  koreacentral: {
    regionCode: 'koce'
  }
  koreasouth: {
    regionCode: 'koso'
  }
  northcentralus: {
    regionCode: 'usnc'
  }
  northeurope: {
    regionCode: 'eune'
  }
  norwayeast: {
    regionCode: 'nwea'
  }
  norwaywest: {
    regionCode: 'nwwe'
  }
  southafricanorth: {
    regionCode: 'sano'
  }
  southafricawest: {
    regionCode: 'sawe'
  }
  southcentralus: {
    regionCode: 'ussc'
  }
  southeastasia: {
    regionCode: 'asse'
  }
  southindia: {
    regionCode: 'inso'
  }
  switzerlandnorth: {
    regionCode: 'swno'
  }
  switzerlandwest: {
    regionCode: 'swwe'
  }
  uaecentral: {
    regionCode: 'uace'
  }
  uaenorth: {
    regionCode: 'uano'
  }
  uksouth: {
    regionCode: 'ukso'
  }
  ukwest: {
    regionCode: 'ukwe'
  }
  westcentralus: {
    regionCode: 'uswc'
  }
  westeurope: {
    regionCode: 'euwe'
  }
  westindia: {
    regionCode: 'inwe'
  }
  westus: {
    regionCode: 'uswe'
  }
  westus2: {
    regionCode: 'usw2'
  }
  westus3: {
    regionCode: 'usw3'
  }
}

var azureRegionCode = azureRegionMap[azureLocation].regionCode

// Placeholder for the regioncodes that can only be assigned in the parentmodule because they are based on the customer parameters.
var azureRegionCodePlaceholder = '[@@@@]'

//var uniquePart = substring(uniqueString(uniqueSeed), 0, uniqueLength)
var uniqueSaPart = substring(uniqueString(uniqueSeed), 0, 10)
var delimiter = useDash ? '-' : ''

var stdPrefixInput = '${organizationCode}${delimiter}${subscriptionCode}${delimiter}${environmentCode}${delimiter}'
var extPrefixInput = '${organizationCode}${delimiter}${subscriptionCode}${delimiter}${environmentCode}${delimiter}${azureRegionCode}${delimiter}'

var standardPrefix = useLowerCase ? toLower(stdPrefixInput) : stdPrefixInput
var extendedPrefix = useLowerCase ? toLower(extPrefixInput) : extPrefixInput

var suffixJoined = empty(suffix) ? '' : '${delimiter}${replace(replace(replace(string(suffix), '["', ''), '"]', ''), '","', delimiter)}'
var suffixFinal = useLowerCase ? toLower(suffixJoined) : suffixJoined

var policyPrefix = '${subscriptionCode}${delimiter}${environmentCode}${delimiter}'

var placeholder = '[----]'

var standardName = '${standardPrefix}${placeholder}${suffixFinal}'
var extendedName = '${extendedPrefix}${placeholder}${suffixFinal}'
var saName = toLower('${organizationCode}${environmentCode}${placeholder}${uniqueSaPart}')
var sigName = toLower('${organizationCode}${subscriptionCode}${environmentCode}${placeholder}') // variable used for Shared Image Gallery name. SIG doesn't accept dash '-'

// Variables for exceptions related to keeping the arm release naming convention.

var diskEncryptionKeyvaultName = '${organizationCode}${delimiter}${subscriptionCode}${delimiter}${environmentCode}${delimiter}${'kvt'}${delimiter}${azureRegionCodePlaceholder}${delimiter}${'des'}'
var diskEncryptionSetName = '${organizationCode}${delimiter}${subscriptionCode}${delimiter}${environmentCode}${delimiter}${'des'}${delimiter}${azureRegionCodePlaceholder}'

//OUTPUTS
output naming object = {
  company: {
    name: company
    slug: 'branding'
  }
  product: {
    name: product
    slug: 'productname'
  }
  productCode: {
    name: productCode
    slug: 'productCode'
  }
  tagPrefix: {
    name: companyCode
    slug: 'tag-branding'
  }
  tagValuePrefix: {
    name: companyCode
    slug: 'tag-value-branding'
  }
  connectivityNetworkResourcesResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-network'), 0, min(length(replace(standardName, placeholder, 'rsg-network')), 90))
    slug: 'rsg-network'
  }
  sharedConnectivityNetworkResourcesResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-shared-resources'), 0, min(length(replace(standardName, placeholder, 'rsg-shared-resources')), 90))
    slug: 'rsg-shared-resources'
  }
  sharedConnectivityHubNetworkVnet: {
    name: substring(replace(extendedName, placeholder, 'vnet-shared-resources'), 0, min(length(replace(extendedName, placeholder, 'vnet-shared-resources')), 64))
    slug: 'vnet-shared-resources'
  }
  connectivityVirtualHubRoutingIntent: {
    name: substring(replace(extendedName, placeholder, 'ri-vwan'), 0, min(length(replace(extendedName, placeholder, 'ri-vwan')), 80))
    slug: 'ri-vwan'
  }
  connectivityVirtualHubRouteTable: {
    name: substring(replace(extendedName, placeholder, 'rt-vwan'), 0, min(length(replace(extendedName, placeholder, 'rt-vwan')), 80))
    slug: 'rt-vwan'
  }
  connectivityVirtualWanExpressRouteGateway: {
    name: substring(replace(extendedName, placeholder, 'expressroute-vwan'), 0, min(length(replace(extendedName, placeholder, 'expressroute-vwan')), 80))
    slug: 'expressroute-vwan'
  }
  connectivityVirtualWanVpnGateway: {
    name: substring(replace(extendedName, placeholder, 'vpn-vwan'), 0, min(length(replace(extendedName, placeholder, 'vpn-vwan')), 80))
    slug: 'vpn-vwan'
  }
  connectivityVirtualWan: {
    name: substring(replace(extendedName, placeholder, 'vwan'), 0, min(length(replace(extendedName, placeholder, 'vwan')), 64))
    slug: 'vwan'
  }
  connectivityVirtualWanHub: {
    name: substring(replace(extendedName, placeholder, 'vwan-hub'), 0, min(length(replace(extendedName, placeholder, 'vwan-hub')), 64))
    slug: 'vwan-hub'
  }
  connectivityVirtualWanResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-vwan'), 0, min(length(replace(standardName, placeholder, 'rsg-vwan')), 64))
    slug: 'rsg-vwan'
  }
  connectivityHubNetworkVnet: {
    name: substring(replace(extendedName, placeholder, 'vnet-hub'), 0, min(length(replace(extendedName, placeholder, 'vnet-hub')), 64))
    slug: 'vnet-hub'
  }
  connectivityHubVnetSubNet: {
    name: substring(replace(extendedName, placeholder, 'snet-hub'), 0, min(length(replace(extendedName, placeholder, 'snet-hub')), 80))
    slug: 'snet-hub'
  }
  connectivityHubVnetSubNetNsg: {
    name: substring(replace(extendedName, placeholder, 'nsg-hub'), 0, min(length(replace(extendedName, placeholder, 'nsg-hub')), 80))
    slug: 'nsg-hub'
  }
  connectivityHubRouteTable: {
    name: substring(replace(extendedName, placeholder, 'rt-hub'), 0, min(length(replace(extendedName, placeholder, 'rt-hub')), 80))
    slug: 'rt-hub'
  }
  connectivityHubVnetGateway: {
    name: substring(replace(extendedName, placeholder, 'vpn-hub'), 0, min(length(replace(extendedName, placeholder, 'vpn-hub')), 80))
    slug: 'vpn-hub'
  }
  connectivityHubVnetGatewayPip: {
    name: substring(replace(extendedName, placeholder, 'pip-gw-hub'), 0, min(length(replace(extendedName, placeholder, 'pip-gw-hub')), 80))
    slug: 'pip-gw-hub'
  }
  connectivityHubFirewall: {
    name: substring(replace(extendedName, placeholder, 'fw-hub'), 0, min(length(replace(extendedName, placeholder, 'fw-hub')), 80))
    slug: 'fw-hub'
  }
  connectivityHubFirewallPip: {
    name: substring(replace(extendedName, placeholder, 'pip-fw-hub'), 0, min(length(replace(extendedName, placeholder, 'pip-fw-hub')), 80))
    slug: 'pip-fw-hub'
  }
  tlsUserManagedIdentityName: {
    name: substring(replace(extendedName, placeholder, 'tls-identity'), 0, min(length(replace(extendedName, placeholder, 'tls-identity')), 80))
    slug: 'tls-identity'
  }
  tlsKeyVaultName: {
    name: substring(replace(standardName, placeholder, 'kvt-tls'), 0, min(length(replace(standardName, placeholder, 'kvt-tls')), 24))
    slug: 'kvt-tls'
  }
  connectivityHubBastionResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-hub-bastionhost'), 0, min(length(replace(standardName, placeholder, 'rsg-hub-bastionhost')), 90))
    slug: 'rsg-hub-bastionhost'
  }
  connectivityHubBastion: {
    name: substring(replace(extendedName, placeholder, 'bas-hub'), 0, min(length(replace(extendedName, placeholder, 'bas-hub')), 80))
    slug: 'bas-hub'
  }
  connectivityHubBastionPip: {
    name: substring(replace(extendedName, placeholder, 'pip-bas-hub'), 0, min(length(replace(extendedName, placeholder, 'pip-bas-hub')), 80))
     slug: 'pip-bas-hub'
  }
  connectivityHubFirewallPolicy: {
    name: substring(replace(extendedName, placeholder, 'hub-fw-policy'), 0, min(length(replace(extendedName, placeholder, 'hub-fw-policy')), 80))
    slug: 'hub-fw-policy'
  }
  connectivityHubFirewallPolicyPremium: {
    name: substring(replace(extendedName, placeholder, 'hub-fw-policy-premium'), 0, min(length(replace(extendedName, placeholder, 'hub-fw-policy-premium')), 80))
    slug: 'hub-fw-policy-premium'
  }
  connectivityDdosPlanName: {
    name: substring(replace(extendedName, placeholder, 'ddos-plan'), 0, min(length(replace(extendedName, placeholder, 'ddos-plan')), 80))
    slug: 'ddos-plan'
  }
  connectivitySpokeVnet: {
    name: substring(replace(extendedName, placeholder, 'vnet-spoke'), 0, min(length(replace(extendedName, placeholder, 'vnet-spoke')), 64))
    slug: 'vnet-spoke'
  }
  connectivitySpokeVnetSubnet: {
    name: substring(replace(extendedName, placeholder, 'snet-spoke'), 0, min(length(replace(extendedName, placeholder, 'snet-spoke')), 80))
    slug: 'snet-spoke'
  }
  connectivitySpokeVnetSubNetNsg: {
    name: substring(replace(extendedName, placeholder, 'nsg-spoke'), 0, min(length(replace(extendedName, placeholder, 'nsg-spoke')), 80))
    slug: 'nsg-spoke'
  }
  connectivitySpokeRouteTable: {
    name: substring(replace(extendedName, placeholder, 'rt-spoke'), 0, min(length(replace(extendedName, placeholder, 'rt-spoke')), 80))
    slug: 'rt-spoke'
  }
  customerAutomationAccount: {
    name: substring(replace(standardName, placeholder, 'aa-runbooks'), 0, min(length(replace(standardName, placeholder, 'aa-runbooks')), 50))
    slug: 'aa-runbooks'
  }
  osManagementAutomationAccount: {
    name: substring(replace(standardName, placeholder, 'aa-osmgmt'), 0, min(length(replace(standardName, placeholder, 'aa-osmgmt')), 50))
    slug: 'aa-osmgmt'
  }
  monitoringWorkspace: {
    name: substring(replace(standardName, placeholder, 'loganalytics'), 0, min(length(replace(standardName, placeholder, 'loganalytics')), 80))
    slug: 'loganalytics'
  }
  managementITSMActionGroupsIntegration: {
    name: substring(replace(standardName, placeholder, 'actiongroup-itsm'), 0, min(length(replace(standardName, placeholder, 'actiongroup-itsm')), 50))
    slug: 'actiongroup-itsm'
  }
  monitoringUserManagedIdentityName: {
    name: substring(replace(standardName, placeholder, 'monitoring-identity'), 0, min(length(replace(standardName, placeholder, 'monitoring-identity')), 80))
    slug: 'monitoring-identity'
  }  
  landingZoneRecoveryServicesVault: {
    name: substring(replace(extendedName, placeholder, 'recoveryvault'), 0, min(length(replace(extendedName, placeholder, 'recoveryvault')), 50))
    slug: 'recoveryvault'
  }
  landingZoneRecoveryServicesVaultResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-recovery-vaults'), 0, min(length(replace(standardName, placeholder, 'rsg-recovery-vaults')), 90))
    slug: 'rsg-recovery-vaults'
  }
  resourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg'), 0, min(length(replace(standardName, placeholder, 'rsg')), 90))
    slug: 'rsg'
  }
  hubResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-hub-network'), 0, min(length(replace(standardName, placeholder, 'rsg-hub-network')), 90))
    slug: 'rsg-hub-network'
  }
  firewallPolicyResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-hub-firewallPolicy'), 0, min(length(replace(standardName, placeholder, 'rsg-hub-firewallPolicy')), 90))
    slug: 'rsg-hub-firewallPolicy'
  }
  spokeResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-spoke-network'), 0, min(length(replace(standardName, placeholder, 'rsg-spoke-network')), 90))
    slug: 'rsg-spoke-network'
  }
  customerAutomationResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-automation'), 0, min(length(replace(standardName, placeholder, 'rsg-automation')), 90))
    slug: 'rsg-automation'
  }
  customerUpdateManagerResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-updatemanager'), 0, min(length(replace(standardName, placeholder, 'rsg-updatemanager')), 90))
    slug: 'rsg-updatemanager'
  }
  monitoringResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-monitoring'), 0, min(length(replace(standardName, placeholder, 'rsg-monitoring')), 90))
    slug: 'rsg-monitoring'
  }
  customerBillingResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-metering'), 0, min(length(replace(standardName, placeholder, 'rsg-metering')), 90))
    slug: 'rsg-metering'
  }
  artifactResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-artifact-repository'), 0, min(length(replace(standardName, placeholder, 'rsg-artifact-repository')), 90))
    slug: 'rsg-artifact-repository'
  }
  artifactStorageAccount: {
    name: substring(replace(saName, placeholder, 'saart'), 0, min(length(replace(saName, placeholder, 'saart')), 24))
    slug: 'saart'
  }
  bootstrapResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-bootstrap'), 0, min(length(replace(standardName, placeholder, 'rsg-bootstrap')), 90))
    slug: 'rsg-bootstrap'
  }
  mgmtReportingResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-reporting'), 0, min(length(replace(standardName, placeholder, 'rsg-reporting')), 90))
    slug: 'rsg-reporting'
  }
  diskEncryptionResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-disk-encryption'), 0, min(length(replace(standardName, placeholder, 'rsg-disk-encryption')), 90))
    slug: 'rsg-disk-encryption'
  }
  storageAccount: {
    name: substring(replace(saName, placeholder, 'sa'), 0, min(length(replace(saName, placeholder, 'sa')), 24))
    slug: 'sa'
  }
  managementReportingStorageAccount: {
    name: substring(replace(saName, placeholder, 'reporting'), 0, min(length(replace(saName, placeholder, 'reporting')), 24))
    slug: 'reporting'
  }
  customerBillingStorageAccount: {
    //should be {organizationCode}{environmentCode}'stgdscpriv' == another exception on the standard
    name: substring(replace(saName, placeholder, 'billing'), 0, min(length(replace(saName, placeholder, 'billing')), 24))
    slug: 'billing'
  }
  customerBillingKeyVault: {
    //in ARM template missing {environmentCode}
    name: substring(replace(standardName, placeholder, 'kvt-billing'), 0, min(length(replace(standardName, placeholder, 'kvt-billing')), 24))
    slug: 'kvt-billing'
  }
  customerItsmPwshStorageAccount: {
    //should be {organizationCode}{environmentCode}'stgdscpriv' == another exception on the standard
    name: substring(replace(saName, placeholder, 'itsmpwsh'), 0, min(length(replace(saName, placeholder, 'itsmpwsh')), 24))
    slug: 'itsmpwsh'
  }
  computeGallery: {
    //in ARM template defined as {organizationCode}_{subscriptionCode}_{environmentCode}_SharedImageGallery
    name: substring(replace(sigName, placeholder, 'computegallery'), 0, min(length(replace(sigName, placeholder, 'computegallery')), 80))
    slug: 'computegallery'
  }
  computeGalleryResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-computegallery'), 0, min(length(replace(standardName, placeholder, 'rsg-computegallery')), 90))
    slug: 'rsg-computegallery'
  }
  computeGalleryStorageAccount: {
    name: substring(replace(saName, placeholder, 'sacg'), 0, min(length(replace(saName, placeholder, 'sacg')), 24))
    slug: 'sacg'
  }
  keyVault: {
    name: substring(replace(standardName, placeholder, 'kvt'), 0, min(length(replace(standardName, placeholder, 'kvt')), 24))
    slug: 'kvt'
  }
  artifactKeyVault: {
    name: substring(replace(standardName, placeholder, 'kvt-artifact'), 0, min(length(replace(standardName, placeholder, 'kvt-artifact')), 24))
    slug: 'kvt-artifact'
  }
  customerAutomationKeyVault: {
    name: substring(replace(standardName, placeholder, 'kvt'), 0, min(length(replace(standardName, placeholder, 'kvt')), 24))
    slug: 'kvt'
  }
  diskEncryptionKeyVault: {
    //design decision to keep the old naming for disk encryption keyvaults. 
    //Name contains placeholder that will be replaced by regioncode in the parentmodule as the diskEncryptionDeploymentRegions will only be available when vmosmanagement parent module will be deployed.
    name: diskEncryptionKeyvaultName
    slug: 'kvt-des'
  }
  diskEncryptionKeyVaultKey: {
    //design decision to keep the old naming for disk encryption keys.
    //Name contains placeholder that will be replaced by regioncode in the parentmodule as the diskEncryptionDeploymentRegions will only be available when vmosmanagement parent module will be deployed.
    name: 'dcs-sse-cmk${delimiter}${azureRegionCodePlaceholder}'
    slug: 'kvt-des'
  }
  diskEncryptionSet: {
    //design decision to keep the old naming for disk encryption sets.
    //Name contains placeholder that will be replaced by regioncode in the parentmodule as the diskEncryptionDeploymentRegions will only be available when vmosmanagement parent module will be deployed.
    name: diskEncryptionSetName
    slug: 'des'
  }
  storageKeyManagementKeyvaultResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-storagekeyrotation'), 0, min(length(replace(standardName, placeholder, 'rsg-storagekeyrotation')), 90))
    slug: 'rsg-storagekeyrotation'
  }
  storageKeyManagementKeyVault: {
    name: substring(replace(standardName, placeholder, 'kvt-storagekr'), 0, min(length(replace(standardName, placeholder, 'kvt-storagekr')), 24))
    slug: 'kvt-storagekr'
  }
  landingZoneSiteRecoveryVault: {
    name: substring(replace(extendedName, placeholder, 'asrvault'), 0, min(length(replace(extendedName, placeholder, 'asrvault')), 50))
    slug: 'asrvault'
  }
  customerBillingFunctionApp: {
    name: substring(replace(standardName, placeholder, 'functionapp-billing'), 0, min(length(replace(standardName, placeholder, 'functionapp-billing')), 80))
    slug: 'functionapp-billing'
  }
  customerBillingAppServicePlan: {
    name: substring(replace(standardName, placeholder, 'hostplan-billing'), 0, min(length(replace(standardName, placeholder, 'hostplan-billing')), 80))
    slug: 'hostplan-billing'
  }
  customerItsmPwshAppServicePlan: {
    name: substring(replace(standardName, placeholder, 'hostplan-itsm-pwsh'), 0, min(length(replace(standardName, placeholder, 'hostplan-itsm-pwsh')), 80))
    slug: 'hostplan-itsm-pwsh'
  }
  osTaggingResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-ostagging'), 0, min(length(replace(standardName, placeholder, 'rsg-ostagging')), 90))
    slug: 'rsg-ostagging'
  }
  osTaggingFuncStorageAccount: {
    //should be {organizationCode}{environmentCode}'stgdscpriv' == another exception on the standard
    name: substring(replace(saName, placeholder, 'ostag'), 0, min(length(replace(saName, placeholder, 'ostag')), 24))
    slug: 'ostag'
  }
  osTaggingFuncAppServicePlan: {
    name: substring(replace(standardName, placeholder, 'hostplan-ostagging'), 0, min(length(replace(standardName, placeholder, 'hostplan-ostagging')), 80))
    slug: 'hostplan-ostagging'
  }
  osTaggingFuncApplicationInsights: {
    name: substring(replace(standardName, placeholder, 'insightsapp-ostagging'), 0, min(length(replace(standardName, placeholder, 'insightsapp-ostagging')), 80))
    slug: 'insightsapp-ostagging'
  }
  osTaggingFuncApp: {
    name: substring(replace(standardName, placeholder, 'functionapp-ostagging'), 0, min(length(replace(standardName, placeholder, 'functionapp-ostagging')), 80))
    slug: 'functionapp-ostagging'
  }
  customerBillingApplicationInsights: {
    name: substring(replace(standardName, placeholder, 'insightsapp-billing'), 0, min(length(replace(standardName, placeholder, 'insightsapp-billing')), 80))
    slug: 'insightsapp-billing'
  }
  customerItsmPwshApplicationInsights: {
    name: substring(replace(standardName, placeholder, 'insightsapp-itsm-pwsh'), 0, min(length(replace(standardName, placeholder, 'insightsapp-itsm-pwsh')), 80))
    slug: 'insightsapp-itsm-pwsh'
  }
  customerItsmPwshFunctionApp: {
    name: substring(replace(standardName, placeholder, 'functionapp-itsm-pwsh'), 0, min(length(replace(standardName, placeholder, 'functionapp-itsm-pwsh')), 80))
    slug: 'functionapp-itsm-pwsh'
  }
  customerItsmLogicAppAlerts: {
    name: substring(replace(standardName, placeholder, 'logicapp-itsm-alerts'), 0, min(length(replace(standardName, placeholder, 'logicapp-itsm-alerts')), 80))
    slug: 'logicapp-itsm-alerts'
  }
  managementItsmResourceGroup: {
    name: substring(replace(standardName, placeholder, 'rsg-itsm'), 0, min(length(replace(standardName, placeholder, 'rsg-itsm')), 90))
    slug: 'rsg-itsm'
  }
  customerItsmKeyVault: {
    name: substring(replace(standardName, placeholder, 'kvt-itsm'), 0, min(length(replace(standardName, placeholder, 'kvt-itsm')), 24))
    slug: 'kvt-itsm'
  }
  customerItsmLogicAppCmdb: {
    name: substring(replace(standardName, placeholder, 'logicapp-itsm-cmdb'), 0, min(length(replace(standardName, placeholder, 'logicapp-itsm-cmdb')), 80))
    slug: 'logicapp-itsm-cmdb'
  }
  eventgridSubscriptionFuncOsTagging: {
    name: 'evgs-func-ostagging'
    slug: 'evgs-func-ostagging'
  }
  eventgridSubscriptionLogicItsmNetwork: {
    name: 'evgs-logic-network'
    slug: 'evgs-logic-network'
  }
  eventgridSubscriptionLogicItsmOsMgmt: {
    name: 'evgs-logic-osmgmt'
    slug: 'evgs-logic-osmgmt'
  }
  eventgridSubscriptionLogicItsmPaas1: {
    name: 'evgs-logic-paas-p1'
    slug: 'evgs-logic-paas-p1'
  }
  eventgridSubscriptionLogicItsmPaas2: {
    name: 'evgs-logic-paas-p2'
    slug: 'evgs-logic-paas-p2'
  }
  eventgridSubscriptionRbOsMgmt: {
    name: 'evgs-rb-osmgmt'
    slug: 'evgs-rb-osmgmt'
  }
  eventgridSubscriptionRbOsDiskEncrypt: {
    name: 'evgs-rb-osdiskencrypt'
    slug: 'evgs-rb-osdiskencrypt'
  }
  eventgridSubscriptionRbPaasDbEncrypt: {
    name: 'evgs-rb-paasdbencrypt'
    slug: 'evgs-rb-paasdbencrypt'
  }
  azureMonitorDataCollectionRules: {
    dcrWindowsName: '${companyCode}-DCR-Windows'
    dcrLinuxName: '${companyCode}-DCR-Linux'
  }
  antiMalwareWindowsChangePolicy: {
    antiMalwareWindowsChangeDefName: 'antimalwarewin-change-policy-def'
    antiMalwareWindowsChangeDefDisplayName: 'Managedos-deploy anti-malware agent for windows vms policy definition'
    antiMalwareWindowsChangeDefAssignmentName: '${policyPrefix}antimalwarewin-change-policy-def-assignment'
    antiMalwareWindowsChangeDefAssignmentDisplayName: 'Antimalware windows change policy definition assignment'
  }
  antiMalwareLinuxAuditDenyPolicy: {
    antiMalwareLinuxAuditDenyDefName: 'antimalwarelinux-audit-deny-policy-def'
    antiMalwareLinuxAuditDenyDefDisplayName: 'Antimalware Linux auditdeny policy definition'
    antiMalwareLinuxAuditDenyDefAssignmentName: '${policyPrefix}antimalwarelinux-audit-deny-policy-def-assignment'
    antiMalwareLinuxAuditDenyDefAssignmentDisplayName: 'Antimalware Linux auditdeny policy definition assignment'
  }
  acrChangePolicy: {
    acrDisableLocalAuthenticationDefName: 'acr-disablelocalauth-change-policy-def'
    acrDisableLocalAuthenticationDefDisplayName: 'Acr disable local auth change policy definition'
    acrDisableTokenAccessDefName: 'acr-disabletokenaccess-change-policy-def'
    acrDisableTokenAccessDefDisplayName: 'Acr disable token access change policy definition'
    acrDisableAnonymousAuthenticationDefName: 'acr-disableanonymousauthaccess-change-policy-def'
    acrDisableAnonymousAuthenticationDefDisplayName: 'Acr disable anonymous auth access change policy definition'
    acrDisablePublicNetworkAccessDefName: 'acr-disablepublicnwaccess-change-policy-def'
    acrDisablePublicNetworkAccessDefDisplayName: 'Acr disable public network access change policy definition'
    acrDisableSetName: 'acr-change-policy-set'
    acrDisableSetDisplayName: 'This initiative configures governance and security policies to Azure Container Registry policy set'
    acrDisableSetAssignmentName: '${policyPrefix}acr-change-policy-set-assignment'
    acrDisableSetAssignmentDisplayName: 'Acr change policy set assignment'
  }
  acrAuditDenyPolicy: {
    acrAuditDenySetName: 'acr-audit-deny-policy-set'
    acrAuditDenySetDisplayName: 'Acr auditdeny policy set'
    acrAuditDenySetAssignmentName: '${policyPrefix}acr-audit-deny-policy-set-assignment'
    acrAuditDenySetAssignmentDisplayName: 'Acr auditdeny policy set assignment'
  }
  allowedLocationsAuditDenyPolicy: {
    allowedLocationResourcesDefAssignmentName: '${policyPrefix}allowed-location-res-audit-deny-policy-def-assignment'
    allowedLocationResourcesDefAssignmentDisplayName: 'Allowed location resources auditdeny policy definition assignment'
    allowedLocationRGDefAssignmentName: '${policyPrefix}allowed-location-rsg-audit-deny-policy-def-assignment'
    allowedLocationRgDefAssignmentDisplayName: 'Allowed location resource groups auditdeny policy definition assignment'
  }
  allowedVmSkuAuditDenyPolicy: {
    allowedVmSkuDefAssignmentName: '${policyPrefix}allowed-vm-sku-audit-deny-policy-def-assignment'
    allowedVmSkuDefAssignmentDisplayName: 'Allowed vm skus auditdeny policy definition assignment'
  }
  appGatewayAuditDenyPolicy: {
    appGatewayAuditDenySetName: 'appgateway-audit-deny-policy-set'
    appGatewayAuditDenySetDisplayName: 'Application gateway auditdeny policy set'
    appGatewayAuditDenySetAssignmentName: '${policyPrefix}appgateway-audit-deny-policy-set-assignment'
    appGatewayAuditDenySetAssignmentDisplayName: 'Application gateway auditdeny policy set assignment'
  }
  appServiceAuditDenyPolicy: {
    appServiceAuditDenySetName: 'appservice-audit-deny-policy-set'
    appServiceAuditDenySetDisplayName: 'App service auditdeny policy set'
    appServiceAuditDenySetAssignmentName: '${policyPrefix}appservice-audit-deny-policy-set-assignment'
    appServiceAuditDenySetAssignmentDisplayName: 'App service auditdeny policy set assignment'
  }
  appServiceChangePolicy: {
    appServiceDisableSlotsFtpLocalAuthenticationDefName: 'appservice-ftpsdisablebasicauth-change-policy-def'
    appServiceDisableSlotsFtpLocalAuthenticationDefDisplayName: 'App service ftp disable basic auth change policy definition.'
    appServiceDisablePublicNetworkAccessDefName: 'appservice-disablepublicnetworkaccess-change-policy-def'
    appServiceDisablePublicNetworkAccessDefDisplayName: 'App service disable public network access change policy definition.'
    appServiceDisableScmLocalAuthenticationDefName: 'appservice-disablescmlocalauth-change-policy-def'
    appServiceDisableScmLocalAuthenticationDefDisplayName: 'App service disable scm local auth change policy definition.'
    appServiceDisableFtpsDeploymentDefName: 'appservice-disableslotsftplocalauth-change-policy-def'
    appServiceDisableFtpsDeploymentDefDisplayName: 'App service disable slots ftp local auth change policy definition.'
    appServiceDisableSlotsScmLocalAuthenticationDefName: 'appservice-disableslotsscmlocalauth-change-policy-def'
    appServiceDisableSlotsScmLocalAuthenticationDefDisplayName: 'App service disable slots scm local auth change policy definition'
    appServiceChangeSetName: 'appservice-change-policy-set'
    appServiceChangeSetDisplayName: 'Azure app service change policy set.'
    appServiceChangeSetAssignmentName: '${policyPrefix}appservice-change-policy-set-assignment'
    appServiceChangeSetAssignmentDisplayName: 'Azure app service change policy set assignment'
  }
  ascPricingChangePolicy: {
    ascPricingChangeDefName: 'asc-pricing-change-policy-def'
    ascPricingChangeDefDisplayName: 'ASC pricing change policy definition'
    ascPricingChangeDefAssignmentName: '${policyPrefix}asc-pricing-change-policy-def-assignment'
    ascPricingChangeDefAssignmentDisplayName: 'ASC pricing change policy definition assignment'
  }
  ascQualysAgentChangePolicy: {
    ascQualysAgentChangeWindowsDefName: 'ascqualysagent-windows-change-policy-def'
    ascQualysAgentChangeWindowsDefDisplayName: 'Azure security center qualys agent windows change policy definition'
    ascQualysAgentChangeLinuxDefName: 'ascqualysagent-linux-change-policy-def'
    ascQualysAgentChangeLinuxDefDisplayName: 'Azure security center qualys agent linux change policy definition'
    ascQualysAgentChangeSetName: 'ascqualysagent-change-policy-set'
    ascQualysAgentChangeSetDisplayName: 'Azure security center qualys agent change policy set'
    ascQualysAgentChangeSetAssignmentName: '${policyPrefix}ascqualysagent-change-policy-set-assignment'
    ascQualysAgentChangeSetAssignmentDisplayName: 'Azure security center qualys agent change policy set assignment'
  }
  azDefenderDataExportChangePolicy: {
    azDefenderDataExportChangeDefName: 'azdefenderexport-change-policy-def'
    azDefenderDataExportChangeDefAssignmentName: '${policyPrefix}azdefenderexport-change-policy-def-assignment'
    azDefenderDataExportChangeDefAssignmentDisplayName: 'Azure defender export change policy definition assignment'
  }
  azMySqlAuditDenyPolicy: {
    mySqlAuditDenySetName: 'mysql-auditdeny-policy-set'
    mySqlAuditDenySetDisplayName: 'Mysql auditdeny policy set'
    mySqlAuditDenySetAssignmentName: '${policyPrefix}mysql-auditdeny-policy-set-assignment'
    mySqlAuditDenySetAssignmentDisplayName: 'Mysql auditdeny policy set assignment'
  }
  azRedisAuditDenyPolicy: {
    azRedisAuditDenySetName: 'azredis-auditdeny-policy-set'
    azRedisAuditDenySetDisplayName: 'Redis auditdeny policy set'
    azRedisAuditDenySetAssignmentName: '${policyPrefix}azredis-auditdeny-policy-set-assignment'
    azRedisAuditDenySetAssignmentDisplayName: 'Redis auditdeny policy set assignment'
  }
  azSqlDbAuditDenyPolicy: {
    azSqlDbAuditDenySetName: 'azsqldb-auditdeny-policy-set'
    azSqlDbAuditDenySetDisplayName: 'Sql auditdeny policy set'
    azSqlDbAuditDenySetAssignmentName: '${policyPrefix}azsqldb-auditdeny-policy-set-assignment'
    azSqlDbAuditDenySetAssignmentDisplayName: 'Sql auditdeny policy set assignment'
  }
  azSqlManagedInstanceAuditDenyPolicy: {
    azSqlManagedInstanceAuditDenySetName: 'azsqlmanagedinstance-auditdeny-policy-set'
    azSqlManagedInstanceAuditDenySetDisplayName: 'Sql managed instance auditdeny policy set'
    azSqlManagedInstanceAuditDenySetAssignmentName: '${policyPrefix}azsqlmanagedinstance-auditdeny-policy-set-assignment'
    azSqlManagedInstanceAuditDenySetAssignmentDisplayName: 'Sql managed instance auditdeny policy set assignment'
  }
  backupChangePolicy: {
    backupDefName: '${policyPrefix}backup-policy-def'
    backupDefAssignmentName: '${policyPrefix}backup-policy-assignment'
  }
  blockResourceTypeAuditDenyPolicy: {
    blockResourceTypeAuditDenyDefAssignmentName: '${policyPrefix}blockresourcetype-auditdeny-policy-def-assignment'
    blockResourceTypeAuditDenyDefAssignmentDisplayName: 'Auditdeny resource type change policy definition assignment'
  }
  cisAuditDenyPolicy: {
    cisAuditDenySetAssignmentName: '${policyPrefix}cis-auditdeny-policy-set-assignment'
    cisAuditDenySetAssignmentDisplayName: 'Cis 2.0.0 auditdeny policy set assignment'
  }
  cosmosDbAuditDenyPolicy: {
    cosmosDbAuditDenySetName: 'cosmosdb-auditdeny-policy-set'
    cosmosdbAuditDenySetDisplayName: 'Cosmosdb auditdeny policy set'
    cosmosdbAuditDenySetAssignmentName: '${policyPrefix}cosmosdb-auditdeny-policy-set-assignment'
    cosmosdbAuditDenySetAssignmentDisplayName: 'Cosmosdb auditdeny policy set assignment'
  }
  cosmosDbChangePolicy: {
    cosmosdbAdvancedThreatProtectionDefName: 'cosmosdb-advancedthreatprotection-change-policy-def'
    cosmosdbAdvancedThreatProtectionDefDisplayName: 'Cosmosdb advanced threat protection change policy definition.'
    cosmosdbDisableLocalAuthenticationDefName: 'cosmosdb-disablelocalauthentication-change-policy-def'
    cosmosdbDisableLocalAuthenticationDefDisplayName: 'Cosmosdb disable local authentication change policy definition.'
    cosmosDbDisableMetadataWriteAccessDefName: 'cosmosdb-disablemetadatawriteaccess-change-policy-def'
    cosmosDbDisableMetadataWriteAccessDefDisplayName:'Cosmosdb disable metadata write access change policy definition.'
    cosmosdbChangeSetName: 'cosmosdb-change-policy-set'
    cosmosdbChangeSetDisplayName: 'Cosmosdb change policy set'
    cosmosdbChangeSetAssignmentName: '${policyPrefix}cosmosdb-change-policy-set-assignment'
    cosmosdbChangeSetAssignmentDisplayName: 'Cosmosdb change policy set assignment'
  }
  dataFactoryAuditDenyPolicy: {
    dataFactoryAuditDenySetName: 'datafactory-auditdeny-policy-set'
    dataFactoryAuditDenySetDisplayName: 'Datafactory auditdeny policy set'
    dataFactoryAuditDenySetAssignmentName: '${policyPrefix}datafactory-auditdeny-policy-set-assignment'
    dataFactoryAuditDenySetAssignmentDisplayName: 'Datafactory auditdeny policy set assignment'
  }
  dataFactoryChangePolicy: {
    disablePublicNetworkAccessDefName: 'datafactory-disablePublicNetworkAccess-change-policy-def'
    disablePublicNetworkAccessDefDisplayName: 'Datafactory disable public network access change policy definition.'
    dataFactoryChangeSetName: 'datafactory-change-policy-set'
    dataFactoryChangeSetDisplayName: 'Datafactory change policy set'
    dataFactoryChangeSetAssignmentName: '${policyPrefix}datafactory-change-policy-set-assignment'
    dataFactoryChangeSetAssignmentDisplayName: 'Datafactory change policy set assignment'
  }
  databricksAuditDenyPolicy: {
    databricksAuditDenySetName: 'databricks-auditdeny-policy-set'
    databricksAuditDenySetDisplayName: 'Databricks auditdeny policy set'
    databricksAuditDenySetAssignmentName: '${policyPrefix}databricks-auditdeny-policy-set-assignment'
    databricksAuditDenySetAssignmentDisplayName: 'Databricks auditdeny policy set assignment'
  }
  diagnosticRulesChangePolicy: {
    diagnosticRulesChangeSetAssignmentName: '${policyPrefix}diagrules-change-policy-set-assignment'
  }
  iso27001AuditDenyPolicy: {
    iso27001AuditDenySetAssignmentName: '${policyPrefix}iso27001-auditdeny-policy-set'
    iso27001AuditDenySetAssignmentDisplayName: 'ISO 27001 auditdeny policy set assignment'
  }
  kubernetesAuditDenyPolicy: {
    kubernetesAuditDenySetName: 'kubernetes-auditdeny-policy-set'
    kubernetesAuditDenySetDisplayName: 'Kubernetes auditdeny policy set'
    kubernetesAuditDenySetAssignmentName: '${policyPrefix}kubernetes-auditdeny-policy-set-assignment'
    kubernetesAuditDenySetAssignmentDisplayName: 'Kubernetes auditdeny policy set assignment'
  }
  kubernetesChangePolicy: {
    deployAksAadAdminPolicyDefName: 'aks-aadconfig-change-policy-def'
    deployAksAadAdminPolicyDefDisplayName: 'Azure kubernetes services aad config change policy definition'
    aksMonitoringAddonPolicyDefName: 'aks-monitoringaddon-change-policy-def'
    aksMonitoringAddonPolicyDefDisplayName: 'Azure Kubernetes Service Monitoring Addon change policy definition'
    kubernetesChangeSetName: 'kubernetes-change-policy-set'
    kubernetesChangeSetDisplayName: 'Kubernetes change policy set'
    kubernetesChangeSetAssignmentName: '${policyPrefix}aks-change-policy-set-assignment'
    kubernetesChangeSetAssignmentDisplayName: 'Kubernetes change policy set assignment'
  }
  mariaDbAuditDenyPolicy: {
    mariaDbAuditDenySetName: 'mariadb-auditdeny-policy-set'
    mariaDbAuditDenySetDisplayName: 'MariaDb auditdeny policy set'
    mariaDbAuditDenySetAssignmentName: '${policyPrefix}mariadb-auditdeny-policy-set-assignment'
    mariaDbAuditDenySetAssignmentDisplayName: 'MariaDb auditdeny policy set assignment'
  }
  nistR2AuditDenyPolicy: {
    nistR2AuditDenySetAssignmentName: '${policyPrefix}nistr2-auditdeny-policy-set'
    nistR2AuditDenySetAssignmentDisplayName: 'Nist 800-171 r2 auditdeny policy set assignment'
  }
  pciAuditDenyPolicy: {
    pciAuditDenySetAssignmentName: '${policyPrefix}pciV4-auditdeny-policy-set-assignment'
    pciAuditDenySetAssignmentDisplayName: 'PCI v4 auditdeny policy set assignment'
  }
  postgreSqlAuditDenyPolicy: {
    postgreSqlAuditDenySetName: 'postgresql-auditdeny-policy-set'
    postgreSqlAuditDenySetDisplayName: 'Postgresql auditdeny policy set'
    postgreSqlAuditDenySetAssignmentName: '${policyPrefix}postgresql-auditdeny-policy-set-assignment'
    postgreSqlAuditDenySetAssignmentDisplayName: 'Postgresql auditdeny policy set assignment'
  }
  rsgNameConventionAuditDenyPolicy: {
    rsgNameConventionsAuditDenyDefName: 'rsgNameConvention-auditdeny-policy-def'
    rsgNameConventionsAuditDenyDefDisplayName: 'Audit Resource Group naming convention policy definition'
    rsgNameConventionsAuditDenyDefAssignmentName: '${policyPrefix}rsgNameConvention-auditdeny-policy-def-assignment'
    rsgNameConventionsAuditDenyDefAssignmentDisplayName: 'Name convention auditdeny policy definition assignment'
  }
  securityBenchmarkAuditDenyPolicy: {
    securityBenchmarkAuditDenySetAssignmentName: '${policyPrefix}securitybenchmark-auditdeny-policy-def-assignment'
    securityBenchmarkAuditDenySetAssignmentDisplayName: 'Microsoft cloud security benchmark auditdeny policy set assignment'
  }
  storageAccountAuditDenyPolicy: {
    storageAccountFilesyncprivatednszoneDefName: 'storageaccount-filesyncprivatednszone-auditdeny-policy-def'
    storageAccountFilesyncprivatednszoneDefDisplayName: 'Storage account azure file sync auditdeny policy definition'
    storageAccountAuditDenySetName: 'storageaccount-auditdeny-policy-set'
    storageAccountAuditDenySetDisplayName: 'Storage account auditdeny policy set'
    storageAccountAuditDenySetAssignmentName: '${policyPrefix}storageaccount-auditdeny-policy-set-assignment'
    storageAccountAuditDenySetAssignmentDisplayName: 'Storage account auditdeny policy set assignment'
  }
  storageAccountRoleAssignmentChange: {
    storageAccountRoleAssignmentChangeName: 'storage-roleassg-change-policy-def' 
    storageAccountRoleAssignmentChangeDisplayName: 'Storage account role assignment change policy definition'
    storageAccountRoleAssignmentChangeAssignmentName: '${policyPrefix}storage-roleassg-change-policy-def-assignment' 
    storageAccountRoleAssignmentChangeAssignmentDisplayName: 'Storage account role assignment change policy definition assignment'
  }
  tagAuditDenyPolicy: {
    tagAuditDenyDefName: 'tag-auditdeny-policy-def'
    tagAuditDenyDefDisplayName: 'Tag auditdeny policy definition'
    tagAuditDenyDefAssignmentName: '${policyPrefix}tag-auditdeny-policy-def-assignment'
    tagAuditDenyDefAssignmentDisplayName: 'Tag auditdeny policy definition assignment'
  }
  blockLogAnalyticsAgentAuditDenyPolicy: {
    blockLogAnalyticsAgentDefName: 'blockloganalyticsagent.auditdeny.policy.def'
    blockLogAnalyticsAgentDefDisplayName: 'Prevent Log Analytics monitoring agent extension on all Virtual Machines and Scale sets auditdeny policy definition'
    blockLogAnalyticsAgentDefAssignmentName: '${policyPrefix}blockloganalyticsagent.auditdeny.policy.def.assignment'
    blockLogAnalyticsAgentDefAssignmentDisplayName: 'Prevent Log Analytics monitoring agent extension on all Virtual Machines and Scale sets auditdeny policy definition assignment'
  }
  guestConfigurationChangePolicy: {
    guestConfigChangeWinDefName: 'guestconfig-win-change-policy-def'
    guestConfigChangeWinDefDisplayName: 'Install Guest Configuration agent for Windows OS'
    guestConfigChangeLinuxDefName: 'guestconfig-linux-change-policy-def'
    guestConfigChangeLinuxDefDisplayName: 'Install Guest Configuration agent for Linux OS'
    guestConfigChangeSetName: 'guestconfig-change-policy-set'
    guestConfigChangeSetDisplayName: 'Guest Configuration agent policy set'
    guestConfigChangeAssignmentName: '${policyPrefix}guestconfig-change-policy-set-assignment'
    guestConfigChangeAssignmentDisplayName: 'Install Guest Configuration agent for both Windows and Linux'
  }
  vmDependencyAgentChangePolicy: {
    vmEnableDependencyAgentLinuxDefDisplayName: 'Virtual Machine enable Linux dependency agent change policy definition'
    vmEnableDependencyAgentLinuxDefName: 'vm-enabledependencyagentlinux-change-policy-def'
    vmEnableDependencyAgentSetAssignmentDisplayName: 'Virtual Machine dependency agent change policy set assignment'
    vmEnableDependencyAgentSetAssignmentName: '${policyPrefix}vmdependencyagent-change-policy-set-assignment'
    vmEnableDependencyAgentSetDisplayName: 'Virtual Machine dependency agent change policy set'
    vmEnableDependencyAgentSetName: 'vmdependencyagent-change-policy-set'
    vmEnableDependencyAgentWinDefDisplayName: 'Virtual Machine enable Windows dependency agent change policy definition'
    vmEnableDependencyAgentWinDefName: 'vm-enabledependencyagentwin-change-policy-def'
  }
  vmssDependencyAgentChangePolicy: {
    vmssEnableDependencyAgentLinuxDefDisplayName: 'Virtual Machine Scale Set enable Linux dependency agent change policy definition'
    vmssEnableDependencyAgentLinuxDefName: 'vmss-enabledependencyagentlinux-change-policy-def'
    vmssEnableDependencyAgentSetAssignmentDisplayName: 'Virtual Machine Scale Set dependency agent change policy set assignment'
    vmssEnableDependencyAgentSetAssignmentName: '${policyPrefix}vmssdependencyagent-change-policy-set-assignment'
    vmssEnableDependencyAgentSetDisplayName: 'Virtual Machine Scale Set dependency agent change policy set'
    vmssEnableDependencyAgentSetName: 'vmssdependencyagent-change-policy-set'
    vmssEnableDependencyAgentWinDefDisplayName: 'Virtual Machine Scale Set enable Windows dependency agent change policy definition'
    vmssEnableDependencyAgentWinDefName: 'vmss-enabledependencyagentwin-change-policy-def'
  }
  azMonitorAgentLinuxChangePolicy: {
    enableAmAgentLinuxVmDefName: 'vm-enableamagentlnx-change-policy-def'
    enableAmAgentLinuxVmDefDisplayName: 'Enable Azure Monitor Agent for Linux Virtual Machines change policy definition'
    enableAmAgentLinuxVmssDefName: 'vmss-enableamagentlnx-change-policy-def'
    enableAmAgentLinuxVmssDefDisplayName: 'Enable Azure Monitor Agent for Linux Virtual Machine Scale Sets change policy definition'
    dcrAssociationLinuxDefName: 'dcr-amagent-association-lnx-change-policy-def'
    dcrAssociationLinuxDefDisplayName: 'DCR - Azure Monitor Agent association linux change policy definition'
    enableAmAgentLinuxSetName: 'amagent-linux-change-policy-set'
    enableAmAgentLinuxSetDisplayName: 'Azure Monitor Agent Linux change policy set'
    enableAmAgentLinuxSetAssignmentName: '${policyPrefix}amagent-linux-change-policy-set-assignment'
    enableAmAgentLinuxSetAssignmentDisplayName: 'Azure Monitor Agent Linux change policy set assignment'
  }
  azMonitorAgentWindowsChangePolicy: {
    enableAmAgentWindowsVmDefName: 'vm-enableamagentwin-change-policy-def'
    enableAmAgentWindowsVmDefDisplayName: 'Enable Azure Monitor Agent for Windows Virtual Machines change policy definition'
    enableAmAgentWindowsVmssDefName: 'vmss-enableamagentwin-change-policy-def'
    enableAmAgentWindowsVmssDefDisplayName: 'Enable Azure Monitor Agent for Windows Virtual Machine Scale Sets change policy definition'
    dcrAssociationWindowsDefName: 'dcr-amagent-association-win-change-policy-def'
    dcrAssociationWindowsDefDisplayName: 'DCR - Azure Monitor Agent association Windows change policy definition'
    enableAmAgentWindowsSetName: 'amagent-windows-change-policy-set'
    enableAmAgentWindowsSetDisplayName: 'Azure Monitor Agent Windows change policy set'
    enableAmAgentWindowsSetAssignmentName: '${policyPrefix}amagent-windows-change-policy-set-assignment'
    enableAmAgentWindowsSetAssignmentDisplayName: 'Azure Monitor Agent Windows change policy set assignment'
  }
  // We keep names for the old log analytics agent policies for some time, to allow the cleanup task in the workflow.
  oldLogAnalyticsAgentPolicy: {
    vmEnableLogAnalyticsAgentLinuxDefName: 'vm-enableloganalyticsagentlinux-change-policy-def'
    vmEnableLogAnalyticsAgentSetAssignmentName: '${policyPrefix}vmloganalyticsagent-change-policy-set-assignment'
    vmEnableLogAnalyticsAgentSetName: 'vmloganalyticsagent-change-policy-set'
    vmEnableLogAnalyticsAgentWinDefName: 'vm-enableloganalyticsagentwin-change-policy-def'
    vmssEnableLogAnalyticsAgentLinuxDefName: 'vmss-enableloganalyticsagentlinux-change-policy-def'
    vmssEnableLogAnalyticsAgentSetAssignmentName: '${policyPrefix}vmssloganalyticsagent-change-policy-set-assignment'
    vmssEnableLogAnalyticsAgentSetName: 'vmssloganalyticsagent-change-policy-set'
    vmssEnableLogAnalyticsAgentWinDefName: 'vmss-enableloganalyticsagentwin-change-policy-def'
  }
  updateManagerChange: {
    windowsVmUpdateAssessmentDefName: 'windows-update-assessment-change-policy-def'
    linuxVmUpdateAssessmentDefName: 'linux-update-assessment-change-policy-def'
    updateManagerSetAssignmentName: '${policyPrefix}updatemanager-change-policy-set-assignment'
    updateManagerSetName: 'updatemanager-change-policy-set'
    updateManagerDefDisplayname: 'Update Manager change policy set'
    updateManagerAssignmentSetDisplayName: 'Update Manager change policy set assignment'
    linuxVmUpdatePatchModeDefName: 'linux-update-patch-mode-change-policy-def'
    windowsVmUpdatePatchModeDefName: 'windows-update-patch-mode-change-policy-def'
  }
  // Azure regions are used for VM encryption in vmosmanagement parent module, where the azureRegionCodePlaceholder will be replaced by the required regioncode.
  // This is required for multi-region deployment of keyvault, disk encryption sets and disk encryption keys inside keyvaults.
  azureRegions: azureRegionMap
  regionCodePlaceholder: azureRegionCodePlaceholder
}
