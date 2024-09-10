/*
SUMMARY: Deployment of a Function App and required components (App service Plan, Insight Components).
DESCRIPTION: Deploy a Function App and it's related components
AUTHOR/S: frederic.trapet@eviden.com
VERSION: 0.0.1
*/

//----TARGET SCOPE --> If you're deploying at the resource group level, you don't need to set the target scope.

//PARAMETERS
@description('Specifies the location of resources.')
param location string 

@description('Function App tags')
param tags object

@description('Storage Account name used for Function App')
param appServiceStorageName string

@description('The name of the App service Plan')
param appServicePlanName string

@description('Hosting Plan SKU object (name and tier). See Microsoft documentation for choosing the right SKU. ')
param appServicePlanSku object

@description('Hosting Plan Kind (possible values: Windows, Linux, elastic, FunctionApp)')
param appServicePlanKind string

@description('The name of the App Insights resource')
param appInsightsName string

@description('The name of the App Service (FunctionApp)')
param appServiceName string

@description('App Insights Kind (possible values: web, ios, other, store, java, phone)')
param appInsightsKind string

@description('App Insights properties. Array of elements)')
param appInsightsProperties object

@description('App Service kind. Possible values: "api", "app", "app,linux", "functionapp", "functionapp,linux")')
param appServiceKind string

@description('Function App settings. Array of elements with required key and value pair for specific functionality')
param appServiceProperties array

@description('KeyVault used for Function App')
param appServiceKeyVaultName string = ''

@description('App Service Client Affinity enabled. (possible values: True or False)')
param appServiceClientAffinityEnabled bool

@description('App Service Https Only. (possible values: True or False)')
param appServiceHttpsOnly bool

@description('App Client certificate enabled. (possible values: True or False)')
param appServiceClientCertEnabled bool

@description('App Service Site Config object')
param appServiceSiteConfig object

@description('Function App tags')
param appServiceTags object

//VARIABLES

var appServicePropertiesLocal = [
  //  Below values will be calculated based on pre-deployments and used for Linux Consumption plans or Windows or Linux Dedicated plans
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${functionAppSa.name};AccountKey=${listKeys(functionAppSa.id, functionAppSa.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsights.properties.InstrumentationKey
  }
]

var appServicePropertiesLocalPremium = [
  //  Below values will be calculated based on pre-deployments and used for Windows or Linux Premium plan or to a Windows Consumption plan
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${functionAppSa.name};AccountKey=${listKeys(functionAppSa.id, functionAppSa.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: 'DefaultEndpointsProtocol=https;AccountName=${functionAppSa.name};AccountKey=${listKeys(functionAppSa.id, functionAppSa.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsights.properties.InstrumentationKey
  }
]

var appServiceKeyVaultConfig = appServiceKeyVaultName != '' ? [
  {
    name: 'AZ_KEYVAULT_NAME'
    value: appServiceKeyVaultName
  }
] : []

var appServicePropertiesJoined = contains(appServicePlanKind, 'linux') ? union(appServicePropertiesLocal, appServiceProperties,appServiceKeyVaultConfig) : union(appServicePropertiesLocalPremium, appServiceProperties,appServiceKeyVaultConfig) // Joins the calculated values above with the values passeed from parameter file and uses the new object in the AppSettings block on App Service resource

//RESOURCES

resource functionAppSa 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  // existing or pre-deployed (as part of previous) storage account used for Function App
  name: appServiceStorageName
}

//DEPLOY APP SERVICE PLAN
resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: appServicePlanSku
  kind: appServicePlanKind
  properties: {
    reserved: contains(appServicePlanKind, 'linux') ? true : false // Linux hosting plan requires reserved : true value
  }
}

//DEPLOY APP INSIGHTS
resource appInsights 'microsoft.insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: appInsightsKind
  properties: appInsightsProperties
}

//DEPLOY APP SERVICE
resource appService 'Microsoft.Web/sites@2021-03-01' = {
  name: appServiceName
  location: location
  tags: appServiceTags
  kind: appServiceKind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      appSettings: appServicePropertiesJoined // conditional variable construced out of combined values from variables section and values from parameters section
    }
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: appServiceClientAffinityEnabled
    httpsOnly: appServiceHttpsOnly
    clientCertEnabled: appServiceClientCertEnabled
  }
}

resource siteConfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${appServiceName}/web'
  properties: appServiceSiteConfig
  dependsOn: [ //needs specific dependsOn appService
    appService
  ]
}

//OUTPUTS

output appServicePlanId string = appServicePlan.id
output appInsightsId string = appInsights.id
output appServiceId string = appService.id
output appServiceName string = appService.name
output systemIdentity string = appService.identity.principalId
