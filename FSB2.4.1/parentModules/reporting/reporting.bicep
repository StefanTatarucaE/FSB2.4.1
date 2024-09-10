/*
SUMMARY: Reporting solution
DESCRIPTION: Parent module to deploy the shared dashboards. Consists of multiple child modules.
AUTHOR/S: klaasjan.dejager@Eviden.com
VERSION: 0.6
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

//PARAMETERS

@description('Required. Deployment scope for this parent module to determine which dashboard will be deployed.')
@allowed([
  'core'
  'network'
  'osmgmt'
  'paas'
])
param deploymentScope string

@description('Required. Specifies the location of the Reporting solution resources.')
param location string = deployment().location

// VARIABLES
// Variable to load default ELZ Azure configuration. No need to expose via parameters in parent module.
var parentModuleConfig = loadJsonContent('parentModuleConfig.json')

//Variables to load from the naming convention files for branding, tagging and resource naming.
var mgmtNaming = json(loadTextContent('../../mgmtNaming.json'))
var companyName = mgmtNaming.company.name
var productName = mgmtNaming.product.name
var productCode = mgmtNaming.productCode.name
var tagPrefix = mgmtNaming.tagPrefix.name
var tagValuePrefix = mgmtNaming.tagValuePrefix.name
var tagPrefixLc = toLower(mgmtNaming.tagPrefix.name)
var tagValuePrefixLc = toLower(mgmtNaming.tagValuePrefix.name)

var tags = union(parentModuleConfig.reportingTags,{ '${tagPrefix}Purpose': '${tagValuePrefix}Reporting' }, {'${tagPrefix}Managed': 'true'})

@description('Specifies the DashBoard that will be deployed.')
var deployCore = (deploymentScope == 'core') ? true : false
var deployOsMgmt = (deploymentScope == 'osmgmt') ? true : false
var deployPaas = (deploymentScope == 'paas') ? true : false

var reportingResourceGroup = mgmtNaming.mgmtReportingResourceGroup.name
var reportingStorageAccountName = mgmtNaming.managementReportingStorageAccount.name

@description('Specifies if storage account and resourcegroup need to be deployed.')
var deployResource = deployCore ? true : deployOsMgmt ? true : deployPaas ? true : false

@description('Configuration of a particular dashboard. Configuration data is a string containing valid JSON.')
var coreManagementDashboard = loadTextContent('./dashboards/coreDashBoardLenses.json')
var osManagementDashboard = loadTextContent('./dashboards/osMgmtDashBoardLenses.json')
var paasDashboard = loadTextContent('./dashboards/paasDashBoardLenses.json')

@description('definition of variables for all dashboards')
var dashboardSubscription = subscription().subscriptionId

@description('Load configuration of a particular Core management workbook. Configuration data is a string containing valid JSON of the Gallery Template.')
var coreWorkbooks = [
  {
    displayName: 'Azure Consumption'
    content: string(loadJsonContent('./coreWorkbooks/azureConsumption.json'))
  }
  {
    displayName: 'PIM Role Assignments'
    content: replace(replace(replace(replace(string(loadJsonContent('./coreWorkbooks/pimRoleAssignments.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}')
  }
  {
    displayName: 'Security Log Except.'
    content: string(loadJsonContent('./coreWorkbooks/securityLogExcept.json'))
  }
  {
    displayName: 'Log Analytics Workspace'
    content: replace(replace(replace(replace(string(loadJsonContent('./coreWorkbooks/logAnalyticsWorkspaces.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}')
  }
  {
    displayName: 'Orphan resources'
    content: replace(replace(replace(replace(string(loadJsonContent('./coreWorkbooks/orphanResources.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}')
  }
  {
    displayName: 'Maintenance Report'
    content: replace(replace(replace(replace(string(loadJsonContent('./coreWorkbooks/maintenanceResources.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}')
  }
  {
    displayName: 'Virtual WAN'
    content: replace(replace(replace(replace(string(loadJsonContent('./coreWorkbooks/virtualWan.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}')
  }
]

@description('Load configuration of OS Management workbooks. Configuration data is a string containing valid JSON of the Gallery Template.')
var osMgmtWorkbooks = [
  {
    displayName: 'Availability'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./osMgmtWorkbooks/availability.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'VM OS Image Gallery'
    // Update links in VM OS Image Gallery workbook with storage account name for reporting
    content: replace(replace(replace(string(loadJsonContent('./osMgmtWorkbooks/vmOSImageGallery.json')), '[parameter(storageAccountName)]', '${reportingStorageAccountName}'), '[parameter(productName)]', '${productName}'), '[parameter(companyName)]', '${companyName}') 
  }
  {
    displayName: 'Backup'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('osMgmtWorkbooks/backup.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'VM Tagging'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./osMgmtWorkbooks/vmTagging.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Antimalware'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./osMgmtWorkbooks/antimalware.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Availability Sets'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./osMgmtWorkbooks/availabilitySets.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Scale Sets'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./osMgmtWorkbooks/scaleSets.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Disk Encryption'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./osMgmtWorkbooks/diskEncryption.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Storage Accounts'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./osMgmtWorkbooks/storageAccounts.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
]

@description('Load configuration of a particular workbook for PAAS management. Configuration data is a string containing valid JSON of the Gallery Template.')
var paasWorkbooks = [
  {
    displayName: 'SQL Database'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/sqlDatabase.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Data Factory'
    content: replace(replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/dataFactory.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}'), '[parameter(productName)]', '${productName}')
  }
  {
    displayName: 'Analysis Service'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/analysisService.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')

  }
  {
    displayName: 'App Service'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/appService.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
    
  }
  {
    displayName: 'SQL Man Instance'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/sqlManInstance.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Cosmos DB'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/cosmosDB.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Cache for Redis'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/cacheForRedis.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Cache for Redis Ent'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/cacheForRedisEnt.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Application Gateway'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/applicationGateway.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'MySQL Server'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/mySQLServer.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'MySQL Flex Server'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/mySQLFlexServer.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'PostgreSQL Server'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/postgreSQLServer.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'PostgreSQL Flex Svr'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/postgreSQLFlexSvr.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }  
  {
    displayName: 'MariaDB'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/mariaDB.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Databricks'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/dataBricks.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Synapse Analytics'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/synapseAnalytics.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'SQL Svr Stretch DB'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/sqlSvrStretchDB.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Dedicated SQL pools'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/dedicatedSQLPools.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Cosmos DB PostgreSQL'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/cosmosDBPostgreSQL.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Data explorer cluster'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/dataExplorerCluster.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Container Registry'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/containerRegistry.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'AKS-Overview'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/aksOverview.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')

  }
  {
    displayName: 'AKS-Workload'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/aksWorkloads.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
  {
    displayName: 'Azure Function'
    content: replace(replace(replace(replace(replace(string(loadJsonContent('./paasWorkbooks/function.json')), '[parameter(tagPrefix)]', '${tagPrefix}'), '[parameter(tagPrefixLc)]', '${tagPrefixLc}'), '[parameter(tagValuePrefix)]', '${tagValuePrefix}'), '[parameter(tagValuePrefixLc)]', '${tagValuePrefixLc}'), '[parameter(companyName)]', '${companyName}')
  }
]

//RESOURCES

//Create a resource group to hold the Reporting resources and storage account if core, osMgmt or paas reporting will be deployed.
resource reportResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (deployResource) {
  name: reportingResourceGroup
  location: location
  tags: tags
}

//Deploy the storageAccount used for reporting if core, osMgmt or paas reporting will be deployed
module storageAccount '../../childModules/storageAccount/storageAccount.bicep' = if (deployResource) {
  scope: reportResourceGroup
  name: reportingStorageAccountName
  params: {
    storageAccountName: reportingStorageAccountName
    location: location
    tags: tags
    kind: parentModuleConfig.storageAccountKind
    sku: parentModuleConfig.storageAccountSku
    accessTier: parentModuleConfig.storageAccountAccessTier
    isHnsEnabled: parentModuleConfig.storageAccountIsHnsEnabled
    allowBlobPublicAccess: parentModuleConfig.storageAccountAllowBlobPublicAccess
    networkAcls: parentModuleConfig.storageAccountNetworkAcls
    changeFeed: parentModuleConfig.storageAccountChangeFeed
    blobSvcDeleteRetentionPolicy: parentModuleConfig.storageAccountBlobSvcDeleteRetentionPolicy
    shouldCreateContainers: parentModuleConfig.storageAccountShouldCreateContainers
    containerNames: parentModuleConfig.storageAccountContainerNames
  }
}

// Create workbooks
// Create workbooks for Core Management
module coreWorkbook '../../childModules/workbook/workbook.bicep' = [for workbooks in coreWorkbooks: if (deployCore) {
  scope: reportResourceGroup
  name: guid('${workbooks.displayName}')
  params: {
    workbookDisplayName: '${workbooks.displayName}'
    location: location
    tags: tags
    workbookContent: '${workbooks.content}'
  }
}]

@description('The resource Ids to use to access the workbooks for Core management.')
var workbookResourceIdConsumption = deployCore ? coreWorkbook[0].outputs.workbookResourceId : ''
var workbookResourceIdPim = deployCore ? coreWorkbook[1].outputs.workbookResourceId : ''
var workbookResourceIdSecurity = deployCore ? coreWorkbook[2].outputs.workbookResourceId : ''
var workbookResourceIdLaw = deployCore ? coreWorkbook[3].outputs.workbookResourceId : ''
var workbookResourceIdOrphan = deployCore ? coreWorkbook[4].outputs.workbookResourceId : ''
var workbookResourceIdMaintenance = deployCore ? coreWorkbook[5].outputs.workbookResourceId : ''
var workbookResourceIdVirtualWan = deployCore ? coreWorkbook[6].outputs.workbookResourceId : ''


//Create workbooks for OS Management
module osMgmtWorkbook '../../childModules/workbook/workbook.bicep' = [for workbooks in osMgmtWorkbooks: if (deployOsMgmt) {
  scope: reportResourceGroup
  name: guid('${workbooks.displayName}')
  params: {
    workbookDisplayName: '${workbooks.displayName}'
    location: location
    tags: tags
    workbookContent: '${workbooks.content}'
  }
}]

@description('The resource Ids to use to access the workbooks for OS management.')
var workbookResourceIdAvailability = deployOsMgmt ? osMgmtWorkbook[0].outputs.workbookResourceId : ''
var workbookResourceIdOsImgGallery = deployOsMgmt ? osMgmtWorkbook[1].outputs.workbookResourceId : ''
var workbookResourceIdBackup = deployOsMgmt ? osMgmtWorkbook[2].outputs.workbookResourceId : ''
var workbookResourceIdOsTagging = deployOsMgmt ? osMgmtWorkbook[3].outputs.workbookResourceId : ''
var workbookResourceIdAntiMalware = deployOsMgmt ? osMgmtWorkbook[4].outputs.workbookResourceId : ''
var workbookResourceIdOSAvailabilitySet = deployOsMgmt ? osMgmtWorkbook[5].outputs.workbookResourceId : ''
var workbookResourceIdOsScaleSets = deployOsMgmt ? osMgmtWorkbook[6].outputs.workbookResourceId : ''
var workbookResourceIdDiskEncryption = deployOsMgmt ? osMgmtWorkbook[7].outputs.workbookResourceId : ''
var workbookResourceIdStorageAccounts = deployOsMgmt ? osMgmtWorkbook[8].outputs.workbookResourceId : ''

//Create workbooks for PAAS Management
module paasWorkbook '../../childModules/workbook/workbook.bicep' = [for workbooks in paasWorkbooks: if (deployPaas) {
  scope: reportResourceGroup
  name: guid('${workbooks.displayName}')
  params: {
    workbookDisplayName: '${workbooks.displayName}'
    location: location
    tags: tags
    workbookContent: '${workbooks.content}'
  }
}]

@description('Define the resource Ids to use to access the workbooks for PAAS management.')
var workbookResourceIdSqlDb = deployPaas ? paasWorkbook[0].outputs.workbookResourceId : ''
var workbookResourceIdDataFactory = deployPaas ? paasWorkbook[1].outputs.workbookResourceId : ''
var workbookResourceIdAnalysisService = deployPaas ? paasWorkbook[2].outputs.workbookResourceId : ''
var workbookResourceIdAppService = deployPaas ? paasWorkbook[3].outputs.workbookResourceId : ''
var workbookResourceIdSqlManagedInstance = deployPaas ? paasWorkbook[4].outputs.workbookResourceId : ''
var workbookResourceIdCosmosDb = deployPaas ? paasWorkbook[5].outputs.workbookResourceId : ''
var workbookResourceIdRedisCache = deployPaas ? paasWorkbook[6].outputs.workbookResourceId : ''
var workbookResourceIdRedisCacheEnt = deployPaas ? paasWorkbook[7].outputs.workbookResourceId : ''
var workbookResourceIdApplicationGateway = deployPaas ? paasWorkbook[8].outputs.workbookResourceId : ''
var workbookResourceIdMySql = deployPaas ? paasWorkbook[9].outputs.workbookResourceId : ''
var workbookResourceIdMySqlFlexServer = deployPaas ? paasWorkbook[10].outputs.workbookResourceId : ''
var workbookResourceIdPostgreSqlServer = deployPaas ? paasWorkbook[11].outputs.workbookResourceId : ''
var workbookResourceIdPostgreSqlFlexServer = deployPaas ? paasWorkbook[12].outputs.workbookResourceId : ''
var workbookResourceIdMariaDb = deployPaas ? paasWorkbook[13].outputs.workbookResourceId : ''
var workbookResourceIdDatabricks = deployPaas ? paasWorkbook[14].outputs.workbookResourceId : ''
var workbookResourceIdSynapseAnalytics = deployPaas ? paasWorkbook[15].outputs.workbookResourceId : ''
var workbookResourceIdSqlServerStretchDb = deployPaas ? paasWorkbook[16].outputs.workbookResourceId : ''
var workbookResourceIdDedicatedSqlPool = deployPaas ? paasWorkbook[17].outputs.workbookResourceId : ''
var workbookResourceIdPostgreSqlHyperScale = deployPaas ? paasWorkbook[18].outputs.workbookResourceId : ''
var workbookResourceIdDataExplorerCluster = deployPaas ? paasWorkbook[19].outputs.workbookResourceId : ''
var workbookResourceIdContainerRegistry = deployPaas ? paasWorkbook[20].outputs.workbookResourceId : ''
var workbookResourceIdAzureKubernetesServiceOverView = deployPaas ? paasWorkbook[21].outputs.workbookResourceId : ''
var workbookResourceIdAzureKubernetesServiceWorkload = deployPaas ? paasWorkbook[22].outputs.workbookResourceId : ''
var workbookResourceIdAzureFunction = deployPaas ? paasWorkbook[23].outputs.workbookResourceId : ''

// Update parameters in properties json string for Core Management dashboard
var coredb1 = replace(coreManagementDashboard, '[parameter(storageAccountName)]', '${reportingStorageAccountName}')
var coredb2 = replace(coredb1, '[parameter(location)]', '${location}')
var coredb3 = replace(coredb2, '[parameter(subscription)]', '${dashboardSubscription}')
var coredb4 = replace(coredb3, '[parameter(resourceGroup)]', '${reportingResourceGroup}')
var coredb5 = replace(coredb4, '[parameter(companyName)]', '${companyName}')
var coredb6 = replace(coredb5, '[parameter(productName)]', '${productName}')
var coredb7 = replace(coredb6, '[parameter(releaseName)]', '${parentModuleConfig.release}')
var coredb8 = replace(coredb7, '[parameter(releaseNotes)]', '${parentModuleConfig.releaseNotes}')

// Update Core management workbook id's in json string for Core Management dashboard. Start at osdb11 as 1-10 is reservered for generic dashboard parameters
var coredb11 = replace(coredb8, '[parameter(workbookResourceIdConsumption)]', '${workbookResourceIdConsumption}')
var coredb12 = replace(coredb11, '[parameter(workbookResourceIdSecurity)]', '${workbookResourceIdSecurity}')
var coredb13 = replace(coredb12, '[parameter(workbookResourceIdPim)]', '${workbookResourceIdPim}')
var coredb14 = replace(coredb13, '[parameter(workbookResourceIdLaw)]', '${workbookResourceIdLaw}')
var coredb15 = replace(coredb14, '[parameter(workbookResourceIdMaintenance)]', '${workbookResourceIdMaintenance}')
var coredb16 = replace(coredb15, '[parameter(workbookResourceIdVirtualWan)]', '${workbookResourceIdVirtualWan}')
var coreDbLenses = json(replace(coredb16, '[parameter(workbookResourceIdOrphan)]', '${workbookResourceIdOrphan}'))

// Update parameters in properties json string for OS Management dashboard
var osdb1 = replace(osManagementDashboard, '[parameter(storageAccountName)]', '${reportingStorageAccountName}')
var osdb2 = replace(osdb1, '[parameter(location)]', '${location}')
var osdb3 = replace(osdb2, '[parameter(subscription)]', '${dashboardSubscription}')
var osdb4 = replace(osdb3, '[parameter(resourceGroup)]', '${reportingResourceGroup}')
var osdb5 = replace(osdb4, '[parameter(companyName)]', '${companyName}')
var osdb6 = replace(osdb5, '[parameter(productName)]', '${productName}')
var osdb7 = replace(osdb6, '[parameter(productCode)]', '${productCode}')

// Update OS management workbook id's in json string for OS Management dashboard. Start at osdb11 as 1-10 is reservered for generic dashboard parameters
var osdb11 = replace(osdb7, '[parameter(workbookResourceIdAvailability)]', '${workbookResourceIdAvailability}')
var osdb13 = replace(osdb11, '[parameter(workbookResourceIdBackup)]', '${workbookResourceIdBackup}')
var osdb14 = replace(osdb13, '[parameter(workbookResourceIdAntimalware)]', '${workbookResourceIdAntiMalware}')
var osdb15 = replace(osdb14, '[parameter(workbookResourceIdOsTagging)]', '${workbookResourceIdOsTagging}')
var osdb16 = replace(osdb15, '[parameter(workbookResourceIdOsImgGallery)]', '${workbookResourceIdOsImgGallery}')
var osdb17 = replace(osdb16, '[parameter(workbookResourceIdOSAvailabilitySet)]', '${workbookResourceIdOSAvailabilitySet}')
var osdb18 = replace(osdb17, '[parameter(workbookResourceIdOsScaleSets)]', '${workbookResourceIdOsScaleSets}')
var osdb19 = replace(osdb18, '[parameter(workbookResourceIdDiskEncryption)]', '${workbookResourceIdDiskEncryption}')
var osMgmtDbLenses = json(replace(osdb19, '[parameter(workbookResourceIdStorageAccounts)]', '${workbookResourceIdStorageAccounts}'))

// Update parameters in properties in json string for PAAS Management dashboard
var paasdb1 = replace(paasDashboard, '[parameter(storageAccountName)]', '${reportingStorageAccountName}')
var paasdb2 = replace(paasdb1, '[parameter(location)]', '${location}')
var paasdb3 = replace(paasdb2, '[parameter(subscription)]', '${dashboardSubscription}')
var paasdb4 = replace(paasdb3, '[parameter(resourceGroup)]', '${reportingResourceGroup}')
var paasdb5 = replace(paasdb4, '[parameter(companyName)]', '${companyName}')
var paasdb6 = replace(paasdb5, '[parameter(productName)]', '${productName}')

// Update PAAS management workbook id's in json string for PAAS Management dashboard. Start at paasdb11 as 1-10 is reservered for generic dashboard parameters
var paasdb11 = replace(paasdb6, '[parameter(workbookResourceIdSqlDb)]', '${workbookResourceIdSqlDb}')
var paasdb12 = replace(paasdb11, '[parameter(workbookResourceIdDataFactory)]', '${workbookResourceIdDataFactory}')
var paasdb13 = replace(paasdb12, '[parameter(workbookResourceIdAnalysisService)]', '${workbookResourceIdAnalysisService}')
var paasdb14 = replace(paasdb13, '[parameter(workbookResourceIdAppService)]', '${workbookResourceIdAppService}')
var paasdb15 = replace(paasdb14, '[parameter(workbookResourceIdSqlManagedInstance)]', '${workbookResourceIdSqlManagedInstance}')
var paasdb16 = replace(paasdb15, '[parameter(workbookResourceIdCosmosDb)]', '${workbookResourceIdCosmosDb}')
var paasdb17 = replace(paasdb16, '[parameter(workbookResourceIdRedisCache)]', '${workbookResourceIdRedisCache}')
var paasdb18 = replace(paasdb17, '[parameter(workbookResourceIdRedisCacheEnt)]', '${workbookResourceIdRedisCacheEnt}')
var paasdb19 = replace(paasdb18, '[parameter(workbookResourceIdApplicationGateway)]', '${workbookResourceIdApplicationGateway}')
var paasdb20 = replace(paasdb19, '[parameter(workbookResourceIdMySql)]', '${workbookResourceIdMySql}')
var paasdb21 = replace(paasdb20, '[parameter(workbookResourceIdMySqlFlexServer)]', '${workbookResourceIdMySqlFlexServer}')
var paasdb22 = replace(paasdb21, '[parameter(workbookResourceIdPostgreSqlServer)]', '${workbookResourceIdPostgreSqlServer}')
var paasdb23 = replace(paasdb22, '[parameter(workbookResourceIdPostgreSqlFlexServer)]', '${workbookResourceIdPostgreSqlFlexServer}')
var paasdb24 = replace(paasdb23, '[parameter(workbookResourceIdMariaDb)]', '${workbookResourceIdMariaDb}')
var paasdb25 = replace(paasdb24, '[parameter(workbookResourceIdDatabricks)]', '${workbookResourceIdDatabricks}')
var paasdb26 = replace(paasdb25, '[parameter(workbookResourceIdSynapseAnalytics)]', '${workbookResourceIdSynapseAnalytics}')
var paasdb27 = replace(paasdb26, '[parameter(workbookResourceIdSqlServerStretchDb)]', '${workbookResourceIdSqlServerStretchDb}')
var paasdb28 = replace(paasdb27, '[parameter(workbookResourceIdDedicatedSqlPool)]', '${workbookResourceIdDedicatedSqlPool}')
var paasdb29 = replace(paasdb28, '[parameter(workbookResourceIdPostgreSqlHyperScale)]', '${workbookResourceIdPostgreSqlHyperScale}')
var paasdb30 = replace(paasdb29, '[parameter(workbookResourceIdDataExplorerCluster)]', '${workbookResourceIdDataExplorerCluster}')
var paasdb31 = replace(paasdb30, '[parameter(workbookResourceIdContainerRegistry)]', '${workbookResourceIdContainerRegistry}')
var paasdb32 = replace(paasdb31, '[parameter(workbookResourceIdAzureKubernetesServiceOverView)]', '${workbookResourceIdAzureKubernetesServiceOverView}')
var paasdb33 = replace(paasdb32, '[parameter(workbookResourceIdAzureKubernetesServiceWorkload)]', '${workbookResourceIdAzureKubernetesServiceWorkload}')
var paasDbLenses = json(replace(paasdb33, '[parameter(workbookResourceIdAzureFunction)]', '${workbookResourceIdAzureFunction}'))

//Create Dashboard resources for Core, OS Management and PAAS Management
module coreSharedDashboard '../../childModules/dashboard/dashboard.bicep' = if (deployCore) {
  scope: reportResourceGroup
  name: parentModuleConfig.coreDashboardDisplayName
  params: {
    dashboardDisplayName: parentModuleConfig.coreDashboardDisplayName
    location: location
    tags: tags
    dashboardLenses: coreDbLenses
  }
}

module osMgmtSharedDashboard '../../childModules/dashboard/dashboard.bicep' = if (deployOsMgmt) {
  scope: reportResourceGroup
  name: parentModuleConfig.osMgmtDashboardDisplayName
  params: {
    dashboardDisplayName: parentModuleConfig.osMgmtDashboardDisplayName
    location: location
    tags: tags
    dashboardLenses: osMgmtDbLenses
  }
}

module paasSharedDashboard '../../childModules/dashboard/dashboard.bicep' = if (deployPaas) {
  scope: reportResourceGroup
  name: parentModuleConfig.paasDashboardDisplayName
  params: {
    dashboardDisplayName: parentModuleConfig.paasDashboardDisplayName
    location: location
    tags: tags
    dashboardLenses: paasDbLenses
  }
}
