/*
SUMMARY: Deployment of a storage account.
DESCRIPTION: Deploy a storage account to the desired Azure region.
AUTHOR/S: klaasjan.dejager@eviden.com
VERSION: 0.6
*/

// PARAMETERS
@description('Specify unique Storage Account Name')
param storageAccountName string

@description('Specify the location where storage account is to be created')
param location string

@description('Speciy mapping of tags attached to Storage Account')
param tags object

@description('Indicates the type of storage account')
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param kind string

@description('Defines Storage SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param sku string

@description('Specify access tier used for billing')
@allowed([
  'Cool'
  'Hot'
])
param accessTier string

@description('Allow or disallow public access to all blobs or containers in the storage account. The default interpretation is true for this property')
param allowBlobPublicAccess bool

@description('Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). The default value is null, which is equivalent to true.')
param allowSharedKeyAccess bool = true

@description('Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2. This can only be true when account_tier is Standard or when account_tier is Premium and account_kind is BlockBlobStorage.')
param isHnsEnabled bool = false

@description('Network rule set; Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Default action, Allow action & the corresponding IP addresses or blocks.')
param networkAcls object

@description('The blob service properties for change feed events.')
param changeFeed object = {}

@description('The blobservice properties for soft delete. Enabled & days parameters.')
param blobSvcDeleteRetentionPolicy object = {}

@description('Specify true if container should be created.')
param shouldCreateContainers bool = false

@description('Provide array of container to be created')
param containerNames array = []

@description('The maximum size of the share, in gigabytes. Must be greater than 0, and less than or equal to 5TB (5120). For Large File Shares, the maximum size is 102400.')
param fileShareQuota int = 1

@description('Boolean flag which indicates if File Shares should be created.')
param shouldCreateShares bool = false

@description('Array to specify the names of the file share(s) to be created.')
param shareNames array = []

@description('Boolean flag which indicates if Queues should be created.')
param shouldCreateQueues bool = false

@description('Array to specify the names of the queue(s) to be created.')
param queueNames array = []

@description('Boolean flag which indicates if Tables should be created.')
param shouldCreateTables bool = false

@description('Array to specify the names of the table(s) to be created.')
param tableNames array = []


// VARIABLES
// Defaults for storage account which can not be modified by providing values (parameters.)
var saName = toLower(replace(storageAccountName, '-', '')) //extra safety to lower the case of the provided storage name + remove dashes.
var minimumTlsVersion = 'TLS1_2'
var isVersioningEnabled = true
//Allows https traffic only to storage service if sets to true.
var supportsHttpsTrafficOnly = true

var tier = (kind == 'Storage') ? null : accessTier // Check if kind is Storage(General Purpose V1) then access tier is set to null as it is not supported.


// RESOURCE DEPLOYMENTS
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: saName
  location: location
  tags: tags
  kind: kind
  sku: {
    name: sku
  }
  properties: {
    accessTier: tier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    isHnsEnabled: isHnsEnabled
    minimumTlsVersion: minimumTlsVersion
    networkAcls: {
      bypass: networkAcls.bypass
      defaultAction: networkAcls.defaultAction
      ipRules: networkAcls.ipRules
    }
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
  }
  
}


resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = if (kind != 'FileStorage') {
  name: 'default' // Always has value 'default'
  parent: storageAccount
  properties: isHnsEnabled ? {} : {
    changeFeed: {
      enabled: changeFeed.enabled
      retentionInDays: changeFeed.retentionInDays
    }
    isVersioningEnabled: isVersioningEnabled
    containerDeleteRetentionPolicy: {
      enabled: blobSvcDeleteRetentionPolicy.enabled
      days: blobSvcDeleteRetentionPolicy.days
    }
    deleteRetentionPolicy: {
      enabled: blobSvcDeleteRetentionPolicy.enabled
      days: blobSvcDeleteRetentionPolicy.days
    }
  }

  // Creating containers with provided names if condition is true
  resource containers 'containers' = [for container in containerNames: if (shouldCreateContainers) {
    name: container.containerName
    properties: {
      publicAccess: container.containerAccess
    }
  }]
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2021-08-01' = if (!((kind == 'BlockBlobStorage') || (kind == 'BlobStorage'))) {
  name: 'default'
  parent: storageAccount

  // Creating shares with provided names if condition is true
  resource shares 'shares' = [for share in shareNames: if (shouldCreateShares) {
    name: share
    properties: {
      shareQuota: fileShareQuota
    }
  }]
}


resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2021-06-01' = if (((kind == 'Storage') || (kind == 'StorageV2'))) {
  name: 'default'
  parent: storageAccount

  // Creating queues with provided names if condition is true
  resource queues 'queues' = [for queue in queueNames: if (shouldCreateQueues) {
    name: queue
  }]
}

resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2021-06-01' = if (((kind == 'Storage') || (kind == 'StorageV2'))) {
  name: 'default'
  parent: storageAccount

  // Creating tables with provided names if condition is true
  resource tables 'tables' = [for table in tableNames: if (shouldCreateTables) {
    name: table
  }]
}


// OUTPUTS 
@description('The resource ID of the storage account.')
output storageAccountResourceID string = storageAccount.id
@description('The name of the storage account.')
output storageAccountname string = storageAccount.name
@description('The resource group of the deployed storage account.')
output resourceGroupName string = resourceGroup().name

output containerObject array = [for (containerName, i) in containerNames: {
  containerName: containerName
  ContainerID: blobService::containers[i].id
}]
