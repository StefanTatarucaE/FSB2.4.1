/*
SUMMARY: Workspace module.
DESCRIPTION: Deployment of Workspace solution for the Eviden Landingzones for Azure solution.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.5
*/

// PARAMETERS
@description('Required. Specifies the name of the Workspace.')
param workspaceName string

@description('Required. Specifies the location of the Workspace.')
param location string

@description('Required. Defines The name of the SKU. Valid options are Free, PerGB2018, Standard or Premium.')
@allowed([
  'Free'
  'PerGB2018'
  'Standard'
  'Premium'
])
param skuName string

@description('Optional. The workspace daily quota for ingestion.')
param dailyQuotaGb int = -1

@description('Required. The workspace data retention in days.')
param retentionInDays int

@description('Required. The network access type for operating on the Workspace. By default it is Enabled')
param publicNetworkAccess object

@description('Optional. Custom table archival periods')
param setRetentionDays array = []

@description('Optional. Datasources to add to the Workspace')
@metadata({
  name: 'Datasource name'
  kind: 'Datasource kind'
  properties: 'Object containing datasource properties'
})
param dataSources array = []

@description('Optional. Solutions to add to the Workspace')
@metadata({
  name: 'Solution name'
  product: 'Product name, e.g. OMSGallery/AzureActivity'
  publisher: 'Publisher name'
  promotionCode: 'Promotion code if applicable'
})
param solutions array = []

@description('Optional. A mapping of tags to assign to the resource.')
param tags object

// RESOURCE DEPLOYMENTS
resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: skuName
    }
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    retentionInDays: retentionInDays
    publicNetworkAccessForIngestion: publicNetworkAccess.forIngestion
    publicNetworkAccessForQuery: publicNetworkAccess.forQuery

  }
  tags: tags

  //Workspace DataSources
  resource workspaceDatasources 'datasources@2020-08-01' = [for dataSource in dataSources: {
    name: dataSource.name
    kind: dataSource.kind
    properties: dataSource.properties
  }]
}

//Workspace Solutions
resource workspaceSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in solutions: {
  name: '${solution.name}(${workspace.name})'
  location: location
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: '${solution.name}(${workspace.name})'
    product: solution.product
    publisher: solution.publisher
    promotionCode: solution.promotionCode
  }
}]

//Workspace custom table retention periods

resource tableRetention 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = [for table in setRetentionDays: if (!empty(setRetentionDays)) {
  name: '${table.name}'
  parent: workspace
  properties: {
    retentionInDays: table.retentionInDays
    totalRetentionInDays: table.totalRetentionInDays
  }
}]

// OUTPUTS
output workspaceName string = workspace.name
output workspaceResourceID string = workspace.id
