/*
SUMMARY: ITSM solution
DESCRIPTION: Parent module to deploy the ITSM solution. 
             Consists of resource group, key vault, storage account, function app, logic app
AUTHOR/S: frederic.trapet@eviden.com, gert.zanting@eviden.com
VERSION: 0.5
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

// PARAMETERS
@description('Required. Specifies the location of the Monitoring solution resources.')
param location string = deployment().location

@description('Optional. A mapping of additional tags to assign to the resource.')
param additionalItsmTags object

@description('Required. Name of the default functional organization for the customer in ServiceNow')
param snowTenantCode string

@description('Required. Name of the default ServiceNow environment code')
param snowEnvironmentCode string

@description('Required. Trouble ticket categories triplet (e.g. Cloud.ELZ.Azure) in ServiceNow')
param snowEventCategories string

@description('Required. Default support group for CI registrations. Can be an empty string.')
param snowSupportGroup string

@description('Required. Enable Native servicenow support. If disabled, will support ATF implementation of ServiceNow. Can be TRUE or FALSE.')
param snowNativeEnable string

@description('Required. When using Native support, allow to specify the support group for incidents. can be an empty string.')
param snowNativeIncSupportGroup string

@description('Required. When using Native support, allow to specify the URLS of the Snow instances for each environment.')
param snowNativeUrls string

@description('Required. This parameter indicates if the ITSM alerting logic-app should be enabled or not after deployment.')
param enableItsmAlerting bool

@description('Required. This parameter indicates if the ITSM CMDB logic-app should be enabled or not after deployment.')
param enableItsmCmdb bool


// VARIABLES
// Variable to load contents of the naming convention file for resource naming.
var mgmtNaming = json(loadTextContent('../../mgmtNaming.json'))

/* Define variables using naming convention variables for the resource group and related resources */
var itsmKeyVaultName = mgmtNaming.customerItsmKeyVault.name
var itsmResourceGroupName = mgmtNaming.managementItsmResourceGroup.name
var itsmListenerAppServiceStorageAccountName = mgmtNaming.customerItsmPwshStorageAccount.name
var itsmListenerAppServicePlanName = mgmtNaming.customerItsmPwshAppServicePlan.name
var itsmListenerAppInsightsName = mgmtNaming.customerItsmPwshApplicationInsights.name
var itsmListenerAppServiceName = mgmtNaming.customerItsmPwshFunctionApp.name
var itsmAlertsLogicAppName = mgmtNaming.customerItsmLogicAppAlerts.name
var itsmCmdbLogicAppName = mgmtNaming.customerItsmLogicAppCmdb.name
var monitoringResourceGroupName = mgmtNaming.monitoringResourceGroup.name
var itsmActionGroupName = mgmtNaming.managementITSMActionGroupsIntegration.name

/* Define additional variables */
var productCode = mgmtNaming.productCode.name
var customerCode = split(itsmResourceGroupName, '-')[0]
var snowGenericConfigID = '${toLower(productCode)}az-uid-${uniqueString(customerCode)}'
var itsmListenerFunctionName = 'itsm-al-listener-atf2'

// Define tags for resources
var tagPrefix = mgmtNaming.tagPrefix.name
var tagValuePrefix = mgmtNaming.tagValuePrefix.name
var tags = union(additionalItsmTags, { '${tagPrefix}Managed': 'true' })
var itsmAlertsLogicAppTags = union(tags, { '${tagPrefix}Purpose': '${tagValuePrefix}ItsmAlerts' })
var itsmCmdbLogicAppTags = union(tags, { '${tagPrefix}Purpose': '${tagValuePrefix}ItsmCmdb' })
var itsmListenerFunctionAppTags = union(tags, { '${tagPrefix}Purpose': '${tagValuePrefix}ItsmListener' })
var itsmResourceTags =  union(tags, { '${tagPrefix}Purpose': '${tagValuePrefix}ITSM' })

// ITSM Function Apps and Logic Apps all need read permissions (get) to key vault secrets. Access policy is defined to grant permissions to system managed identity of Function + Logic Apps.
var keyVaultAccessPolicy = [
  {
    objectId: itsmListenerFunctionApp.outputs.systemIdentity
    permissions: {
      secrets: [
        'get'
      ]
    }
  }
  {
    objectId: itsmAlertsLogicApp.outputs.logicAppPrincipalId
    permissions: {
      secrets: [
        'get'
      ]
    }
  }
  {
    objectId: itsmCmdbLogicApp.outputs.logicAppPrincipalId
    permissions: {
      secrets: [
        'get'
      ]
    }
}]

var itsmAlertsGenericWorkflowDefinition = loadJsonContent('./workflowDefinitions/itsmAlerts.json')
var itsmCmdbGenericWorkflowDefinition = loadJsonContent('./workflowDefinitions/itsmCmdb.json')
// set defaultValue for itsm-alerts Logic App parameters, constructed from bicep module parameters and/or outputs
var itsmAlertsWorkflowDefinitionParameters = {
  parameters: {
    ListenerFunctionResourceID: {
      defaultValue: '${itsmListenerFunctionApp.outputs.appServiceId}/functions/${itsmListenerFunctionName}'
    }
    ListenerFunctionUrl: {
      defaultValue: 'https://${itsmListenerFunctionApp.outputs.appServiceName}.azurewebsites.net/api/${itsmListenerFunctionName}'
    }
    ServiceProviderManagedTag: {
      defaultValue: '${toLower(tagPrefix)}managed'
    }
    ServiceProviderMonitoringCITag: {
      defaultValue: '${toLower(tagPrefix)}monitoringid'
    }
    ServiceProviderMaintenanceTag: {
      defaultValue: '${toLower(tagPrefix)}maintenance'
    }
    SnowCatOverideTag: {
      defaultValue: '${tagPrefix}ITSMServiceNowCategories'
    }
    SnowEnvOverideTag: {
      defaultValue: '${tagPrefix}ITSMServiceNowEnvironment'
    }
    SnowFoOverideTag: {
      defaultValue: '${tagPrefix}ITSMServiceNowFO'
    }
    SnowGenericCiOverideTag: {
      defaultValue: '${tagPrefix}ITSMServiceNowGenericConfigID'
    }
  }
}
// replace defaultValue for parameters in generic workflow definition json file with customer specific deployment value
var itsmAlertsWorkflowDefinition = union(itsmAlertsGenericWorkflowDefinition, itsmAlertsWorkflowDefinitionParameters)
// set 'Actual value' for parameters that need to have fixed value (not changeable for end user)
var itsmAlertsWorkflowParameters = {
}

// set defaultValue for itsm-cmdb Logic App parameters, constructed from bicep module parameters and/or outputs
var itsmCmdbWorkflowDefinitionParameters = {
  parameters: {
    ListenerFunctionResourceID: {
      defaultValue: '${itsmListenerFunctionApp.outputs.appServiceId}/functions/${itsmListenerFunctionName}'
    }
    ListenerFunctionUrl: {
      defaultValue: 'https://${itsmListenerFunctionApp.outputs.appServiceName}.azurewebsites.net/api/${itsmListenerFunctionName}'
    }
    ServiceProviderManagedTag: {
      defaultValue: '${toLower(tagPrefix)}managed'
    }
    SnowEnvOverideTag: {
      defaultValue: '${tagPrefix}ITSMServiceNowEnvironment'
    }
    SnowFoOverideTag: {
      defaultValue: '${tagPrefix}ITSMServiceNowFO'
    }
    DiagnosticRuleName: {
      defaultValue: '${tagPrefix}DiagnosticRule-SendToLogAnalytics'
    }

  }
}
// replace defaultValue for parameters in generic workflow definition json file with customer specific deployment value
var itsmCmdbWorkflowDefinition = union(itsmCmdbGenericWorkflowDefinition, itsmCmdbWorkflowDefinitionParameters)
// set 'Actual value' for parameters, if any, that need to have fixed value (not changeable for end user)
var itsmCmdbWorkflowParameters = {
}

// Create array of dynamic parameters that will be added to static paramaters for the listener function app
var itsmListenerAdditionalProperties = [
  {
    name: 'COMPANY_TAG_PREFIX'
    value: '${tagPrefix}'
  }
  {
    name: 'PRODUCT_CODE'
    value: '${productCode}'
  }
  {
    name: 'CFG_DEFAULT_SNOW_FO'
    value: snowTenantCode
  }
  {
    name: 'CFG_DEFAULT_SNOW_ENV'
    value: snowEnvironmentCode
  }
  {
    name: 'CFG_DEFAULT_SNOW_SUPPORT_GROUP'
    value: snowSupportGroup
  }
  {
    name: 'CFG_DEFAULT_INC_CATEGORY'
    value: snowEventCategories
  }
  {
    name: 'CFG_DEFAULT_INC_GENERIC_CI_MONITORINGID'
    value: snowGenericConfigID
  }
  {
    name: 'CFG_NATIVE_SERVICENOW'
    value: snowNativeEnable
  }
  {
    name: 'CFG_NATIVE_INC_SUPPORT_GROUP'
    value: snowNativeIncSupportGroup
  }
  {
    name: 'CFG_NATIVE_SNOW_URLS'
    value: snowNativeUrls
  }
]

var itsmListenerAppServiceProperties = union(parentModuleConfig.itsmListenerAppServiceProperties, itsmListenerAdditionalProperties)

//Role definitions for the logic apps. The logic apps need "Contributor" access at the resource group where the ITSM function apps will be deployed.
var roleDefinitionIdOrNamesForLogicApp =  [
  'Contributor'
]

//Role definitions for the Alert logic app. The logic apps need "Monitoring Contributor" access at the resource group where the Alerts reside.
var roleDefinitionIdOrNamesForLogicAppItsm =  [
  'Monitoring Contributor'
]

// Variable to load default ELZ Azure configuration. No need to expose via parameters in parent module.
var parentModuleConfig = loadJsonContent('./parentModuleConfig.json')

// RESOURCE DEPLOYMENTS

// Create a resource group to hold all ITSM resources.
resource itsmResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: itsmResourceGroupName
  location: location
  tags: itsmResourceTags
}

// Create a key vault that will hold customer provided secrets for ServiceNow authentication
module itsmKeyVault '../../childModules/keyVault/keyVault.bicep' = {
  scope: itsmResourceGroup
  name: 'itsmKeyVault-deployment'
  params: {
    keyVaultName: itsmKeyVaultName
    location: location
    tags: itsmResourceTags
    skuName: parentModuleConfig.keyVaultSkuName
    keyVaultFeatures: parentModuleConfig.keyVaultFeatures
    publicNetworkAccess: parentModuleConfig.keyVaultPublicNetworkAccess
    softDeleteRetentionInDays: parentModuleConfig.keyVaultSoftDeleteRetentionInDays
    networkRuleBypassOptions: parentModuleConfig.keyVaultNetworkRuleBypassOptions
    networkRuleAction: parentModuleConfig.keyVaultNetworkRuleAction
  }
}

// Deploy the storageAccount to be used with the Function App for ITSM Listener
module itsmListenerStorageAccount '../../childModules/storageAccount/storageAccount.bicep' = {
  scope: itsmResourceGroup
  name: 'itsmListenerStorageAccount-deployment'
  params: {
    storageAccountName: itsmListenerAppServiceStorageAccountName
    location: location
    tags: itsmResourceTags
    kind: parentModuleConfig.storageAccountKind
    sku: parentModuleConfig.storageAccountSku
    accessTier: parentModuleConfig.storageAccountAccessTier
    allowBlobPublicAccess: parentModuleConfig.storageAccountAllowBlobPublicAccess
    networkAcls: parentModuleConfig.storageAccountNetworkAcls
    changeFeed: parentModuleConfig.storageAccountChangeFeed
    blobSvcDeleteRetentionPolicy: parentModuleConfig.storageAccountBlobSvcDeleteRetentionPolicy
  }
}

// Deploy the ITSM-Listener Function App
module itsmListenerFunctionApp '../../childModules/functionApp/functionApp.bicep' = {
  scope: itsmResourceGroup
  name: 'itsmListenerFunctionApp-deployment'
  params: {
    location: location
    tags: itsmListenerFunctionAppTags
    appServiceStorageName: itsmListenerStorageAccount.outputs.storageAccountname
    appServicePlanName: itsmListenerAppServicePlanName
    appServicePlanSku: parentModuleConfig.appServicePlanSku
    appServicePlanKind: parentModuleConfig.itsmListenerAppServicePlanKind
    appInsightsName: itsmListenerAppInsightsName
    appInsightsKind: parentModuleConfig.appInsightsKind
    appInsightsProperties: parentModuleConfig.appInsightsProperties
    appServiceName: itsmListenerAppServiceName
    appServiceKind: parentModuleConfig.itsmListenerAppServiceKind
    appServiceTags: itsmListenerFunctionAppTags
    appServiceProperties: itsmListenerAppServiceProperties
    appServiceKeyVaultName: itsmKeyVault.outputs.keyVaultName
    appServiceClientAffinityEnabled: parentModuleConfig.appServiceClientAffinityEnabled
    appServiceHttpsOnly: parentModuleConfig.appServiceHttpsOnly
    appServiceClientCertEnabled: parentModuleConfig.appServiceClientCertEnabled
    appServiceSiteConfig: parentModuleConfig.itsmListenerAppServiceSiteConfig
  }
}

// Deploy the Logic App for ITSM Alerts
module itsmAlertsLogicApp '../../childModules/logicApp/logicApp.bicep' = {
  name: 'itsmAlertsLogicApp-deployment'
  scope: itsmResourceGroup
  params: {
    definition: itsmAlertsWorkflowDefinition
    location: location
    logicAppName: itsmAlertsLogicAppName
    definitionParameters: itsmAlertsWorkflowParameters
    logicAppState: enableItsmAlerting ? 'Enabled' : 'Disabled'
    systemAssignedIdentity : true // Always create system assigned service principal, to be used in access policies
    userAssignedIdentities : {} // Leave empty as system assigned identity is used
    tags: itsmAlertsLogicAppTags
  }
}

// Deploy the Logic App for ITSM CMDB discovery
module itsmCmdbLogicApp '../../childModules/logicApp/logicApp.bicep' = {
  name: 'itsmCmdbLogicApp-deployment'
  scope: itsmResourceGroup
  params: {
    definition: itsmCmdbWorkflowDefinition
    location: location
    logicAppName: itsmCmdbLogicAppName
    definitionParameters: itsmCmdbWorkflowParameters
    logicAppState: enableItsmCmdb ? 'Enabled' : 'Disabled'
    systemAssignedIdentity : true // Always create system assigned service principal, to be used in access policies
    userAssignedIdentities : {} // Leave empty as system assigned identity is used
    tags: itsmCmdbLogicAppTags
  }
}

// Function Apps and Logic Apps need access to secrets stored in Key Vault, so additional access policies are deployed
module itsmKeyVaultAccessPolicy '../../childModules/keyVaultAccessPolicy/keyVaultAccessPolicy.bicep' = {
  name: 'itsmKeyVaultAccessPolicy-deployment'
  scope: itsmResourceGroup
  params: {
    keyVaultName: itsmKeyVault.outputs.keyVaultName
    accessPoliciesAdd: keyVaultAccessPolicy
  }
}

// redeploy existing ITSM monitoring actionGroup with additional Logic App receiver for newly deployed itsm-alerts logic app
resource existingActionGroup 'Microsoft.Insights/actionGroups@2022-06-01' existing = {
  scope: resourceGroup(monitoringResourceGroupName)
  name: itsmActionGroupName
}

module itsmActionGroup '../../childModules/actionGroup/actionGroup.bicep' = {
  name: 'monitoringActionGroup-deployment'
  scope: resourceGroup(monitoringResourceGroupName)
  params: {
    actionGroupName: existingActionGroup.name
    actionGroupShortName: '${toUpper(productCode)}AZ-ITSM' // Static value; just used as extra identifier in Azure Portal
    logicAppReceivers: [{
        name: 'ITSM integration' // Static value; descriptive name for receiver
        callbackUrl: itsmAlertsLogicApp.outputs.logicAppCallbackUrl
        resourceId: itsmAlertsLogicApp.outputs.logicAppID
        useCommonAlertSchema: 'True' // Always true for ServiceNow integration
    }]
    tags: existingActionGroup.tags
  }
}

module roleAssignmentResourceGroupItsmAlertsLogicApp '../../childModules/roleAssignment/roleAssignmentResourceGroup.bicep' = {
  name: 'roleAssignment-itsmAlertLogicApp'
  scope: itsmResourceGroup
  params: {
    managedIdentityId: itsmAlertsLogicApp.outputs.logicAppPrincipalId
    roleDefinitionIdOrNames: roleDefinitionIdOrNamesForLogicApp
  }
}

module roleAssignmentResourceGroupMonitoringItsmAlertsLogicApp '../../childModules/roleAssignment/roleAssignmentResourceGroup.bicep' = {
  name: 'roleAssignment-monitoringItsmAlertLogicApp'
  scope: resourceGroup(monitoringResourceGroupName)
  params: {
    managedIdentityId: itsmAlertsLogicApp.outputs.logicAppPrincipalId
    roleDefinitionIdOrNames: roleDefinitionIdOrNamesForLogicAppItsm
  }
}

module roleAssignmentResourceGroupItsmCmdbLogicApp '../../childModules/roleAssignment/roleAssignmentResourceGroup.bicep' = {
  name: 'roleAssignment-itsmCmdbLogicApp'
  scope: itsmResourceGroup
  params: {
    managedIdentityId: itsmCmdbLogicApp.outputs.logicAppPrincipalId
    roleDefinitionIdOrNames: roleDefinitionIdOrNamesForLogicApp
  }
}


// OUTPUTS
output itsmResourceGroupName string = itsmResourceGroup.name
output itsmKeyVaultName string = itsmKeyVault.outputs.keyVaultName
output itsmListenerFunctionAppName string = itsmListenerFunctionApp.outputs.appServiceName
output itsmListenerFunctionAppResourceId string = itsmListenerFunctionApp.outputs.appServiceId
output itsmAlertsLogicAppResourceId string = itsmAlertsLogicApp.outputs.logicAppID
output itsmCmdbLogicAppResourceId string = itsmCmdbLogicApp.outputs.logicAppID
