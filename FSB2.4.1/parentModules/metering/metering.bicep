/*
SUMMARY: Metering/Billing solution
DESCRIPTION: Parent module to deploy the metering solution. 
             Consists of resource group, storage account, functionApp
AUTHOR/S: alkesh.naik@eviden.com, frederic.trapet@eviden.com
VERSION: 0.2
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

// PARAMETERS
@description('Required. Specifies the location of the Monitoring solution resources.')
param location string = deployment().location

@description('Optional. A mapping of additional tags to assign to the resource.')
param additionalMeteringTags object

@description('Function App settings. Array of elements with required key and value pair for specific functionality')
param appServiceProperties array

// VARIABLES
//Variables to load in the naming convention files for resource naming.
var mgmtNaming = json(loadTextContent('../../mgmtNaming.json'))

/*Variables to determine which naming variables to use for the resource group &  related resources */
var resourceGroupName = mgmtNaming.customerBillingResourceGroup.name
var appServicePlanName = mgmtNaming.customerBillingAppServicePlan.name
var appInsightsName = mgmtNaming.customerBillingApplicationInsights.name
var appServiceName = mgmtNaming.customerBillingFunctionApp.name
var billingStorageAccountName = mgmtNaming.customerBillingStorageAccount.name
var billingKeyVaultName = mgmtNaming.customerBillingKeyVault.name
var productCode = mgmtNaming.productCode.name

// Define tags for resources
var tagPrefix = mgmtNaming.tagPrefix.name
var tagValuePrefix = mgmtNaming.tagValuePrefix.name
var policyMeteringTag = '${mgmtNaming.company.name}${mgmtNaming.productCode.name}'
var tags = union(additionalMeteringTags, { '${tagPrefix}Managed': 'true' }, { '${tagPrefix}Purpose': '${tagValuePrefix}Billing' })

//This is the parameter to pass to the access policy module. Here we have passed the function app system identity and the permission is provided only to secret, as the billing function app only needs access to secrets and only needs read only i.e. Get and list. 
var functionAppAccessPoliciesKeyvaultAdd = [
  {
    objectId: billingFunctionApp.outputs.systemIdentity
    permissions: {
      secrets: [
        'list'
        'Get'
      ]
    }
  }
]


// Variable to create a unique prefix seeded to the resource group, needed for consistency when redeploying the same template
var uniqueDeployPrefix = substring(uniqueString(billingResourceGroup.id),0 ,6)

// Variable to load default configuration. No need to expose via parameters in parent module.
var parentModuleConfig = loadJsonContent('parentModuleConfig.json')


// Create array of dynamic parameters that will be added to static paramaters for the function app
var appServiceAdditionalProperties = [
  {
    name: 'CUSTOM_POLICIES_METADATA'
    value: '{"TagName": "source","TagValue": "${policyMeteringTag}"}'
  }
  {
    name: 'MAINTENANCE_CONFIG_TAG'
    value: '{"TagName": "${tagPrefix}Purpose","TagValue": "${tagValuePrefix}MaintenanceConfig"}'
  }
  {
    name: 'RECOVERY_VAULT_TAG'
    value: '{"TagName": "${tagPrefix}Purpose","TagValue": "${tagValuePrefix}RecoveryServicesVault"}'
  }		
  {
    name: 'IMG_GALLERY_TAG'
    value: '{"TagName": "${tagPrefix}Purpose","TagValue": "${tagValuePrefix}SharedImageGallery"}'
  }	
  {
    name: 'VM_BACKUP_TAG'
    value: '{"TagName": "${tagPrefix}Backup","TagValue": "*"}'
  }
  {
    name: 'VM_COMPL_TAG'
    value: '{"TagName": "${tagPrefix}Managed","TagValue": "true"}'
  }
  {
    name: 'VM_OSVERSION_TAG'
    value: '{"TagName": "${tagPrefix}OsVersion"}'
  }
  {
    name: 'VM_PATCH_TAG'
    value: '{"TagName": "${tagPrefix}Patching","TagValue": "*"}'
  }
  {
    name: 'VNET_SPOKES_TAG'
    value: '{"TagName": "${tagPrefix}Purpose","TagValue": "${tagValuePrefix}NetworkingSpoke"}'
  }
  {
    name: 'COMPANY_TAG_PREFIX'
    value: '${tagPrefix}'
  }  
  {
    name: 'PRODUCT_PURPOSE_TAG'
    value: '${tagPrefix}Purpose'
  }    
  {
    name: 'PRODUCT_CODE'
    value: productCode
  }  
]

// Create final parameters array for the function app, including parameters from all sources
var appServicePropertiesUnion = union(parentModuleConfig.appServiceProperties,appServiceProperties,appServiceAdditionalProperties)

// RESOURCE DEPLOYMENTS
//Create a resource group to hold the metering resources.
resource billingResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module billingKeyvault '../../childModules/keyVault/keyVault.bicep' = {
  scope: billingResourceGroup
  name: '${uniqueDeployPrefix}-keyvaultBilling-deployment'
  params: {
    keyVaultName: billingKeyVaultName
    location: location
    tags: tags
    skuName: parentModuleConfig.skuName
    keyVaultFeatures: parentModuleConfig.keyVaultFeatures
    publicNetworkAccess: parentModuleConfig.publicNetworkAccess
    softDeleteRetentionInDays: parentModuleConfig.softDeleteRetentionInDays
    networkRuleBypassOptions: parentModuleConfig.networkRuleBypassOptions
    networkRuleAction: parentModuleConfig.networkRuleAction
  }
}

//Deploy the storageAccount used with the functionApp for metering
module storageAccount '../../childModules/storageAccount/storageAccount.bicep' = {
  scope: billingResourceGroup
  name: '${uniqueDeployPrefix}-storageAccountBilling-deployment'
  params: {
    storageAccountName: billingStorageAccountName
    location: location
    tags: tags
    kind: parentModuleConfig.storageAccountKind
    sku: parentModuleConfig.storageAccountSku
    accessTier: parentModuleConfig.storageAccountAccessTier
    allowBlobPublicAccess: parentModuleConfig.storageAccountAllowBlobPublicAccess
    networkAcls: parentModuleConfig.storageAccountNetworkAcls
    changeFeed: parentModuleConfig.storageAccountChangeFeed
    blobSvcDeleteRetentionPolicy: parentModuleConfig.storageAccountBlobSvcDeleteRetentionPolicy
    shouldCreateTables: parentModuleConfig.storageAccountshouldCreateTables
    tableNames: parentModuleConfig.storageAccounttableNames
  }
}

//Deploy the Billing functionApp
module billingFunctionApp '../../childModules/functionApp/functionApp.bicep' = {
  scope: billingResourceGroup
  name: '${uniqueDeployPrefix}-functionAppBilling-deployment'
  params: {
    location: location
    tags: tags
    appServiceStorageName: storageAccount.outputs.storageAccountname
    appServicePlanName: appServicePlanName
    appServicePlanSku: parentModuleConfig.appServicePlanSku
    appServicePlanKind: parentModuleConfig.appServicePlanKind
    appInsightsName: appInsightsName
    appInsightsKind: parentModuleConfig.appInsightsKind
    appInsightsProperties: parentModuleConfig.appInsightsProperties
    appServiceName: appServiceName
    appServiceKind: parentModuleConfig.appServiceKind
    appServiceTags: tags
    appServiceProperties: appServicePropertiesUnion
    appServiceKeyVaultName: billingKeyVaultName
    appServiceClientAffinityEnabled: parentModuleConfig.appServiceClientAffinityEnabled
    appServiceHttpsOnly: parentModuleConfig.appServiceHttpsOnly
    appServiceClientCertEnabled: parentModuleConfig.appServiceClientCertEnabled
    appServiceSiteConfig: parentModuleConfig.appServiceSiteConfig
  }
}

//Assign the Access policy on the key vault to the billing function app system identity
module keyVaultAccessPolicy '../../childModules/keyVaultAccessPolicy/keyVaultAccessPolicy.bicep' = {
  scope: billingResourceGroup
  name: '${uniqueDeployPrefix}-keyvaultaccesspolicyBilling-deployment'
  params: {
    keyVaultName: billingKeyVaultName
    accessPoliciesAdd: functionAppAccessPoliciesKeyvaultAdd
  }
  dependsOn: [
    billingKeyvault
    billingFunctionApp
  ]
}


// OUTPUTS
output billingResourceGroupName string = billingResourceGroup.name
output billingFunctionAppName string = billingFunctionApp.outputs.appServiceName
