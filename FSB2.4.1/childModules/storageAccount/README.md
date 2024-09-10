#storageAccount/storageAccount.bicep
Bicep module to create an Azure Storage Account with blob containers.

## Description
An Azure storage account module deploys storage account along with blobs, file shares, queues and tables. 

Multiple containers can only be deployed if deployContainer is set to true.

## Module Example Use
```hcl

module storageModule '../childModules/storageAccount/storageAccount.bicep' = {
  scope: storageRG1
  name: storageAccountName
  params: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    blobSvcDeleteRetentionPolicy: blobSvcDeleteRetentionPolicy
    changeFeed: changeFeed
    deployContainer: deployContainer 
    containerNames: containerNames
    fileShareQuota: fileShareQuota
    isHnsEnabled: isHnsEnabled
    kind: kind
    location: location
    networkAcls: networkAcls
    queueNames:queueNames
    resourceTags: resourceTags
    shareNames: shareNames
    shouldCreateQueues: shouldCreateQueues
    shouldCreateShares: shouldCreateShares
    shouldCreateTables: shouldCreateTables
    sku: sku
    storageAccountName: storageAccountName
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    tableNames: tableNames
  }
}


// Deploy multiple storage accounts

module storageModule '../childModules/storageAccount/storageAccount.bicep' = [for i in range(0, storageCount): {
  scope: storageRG1
  name: 'storageDeploy-${i}'
  params: {
    storageAccountName: '${storageAccountName}${i}'
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    blobSvcDeleteRetentionPolicy: blobSvcDeleteRetentionPolicy
    changeFeed: changeFeed
    containerNames: containerNames
    deployContainer: deployContainer 
    fileShareQuota: fileShareQuota
    isHnsEnabled: isHnsEnabled
    kind: kind
    location: location
    networkAcls: networkAcls
    queueNames:queueNames
    resourceTags: resourceTags
    shareNames: shareNames
    shouldCreateQueues: shouldCreateQueues
    shouldCreateShares: shouldCreateShares
    shouldCreateTables: shouldCreateTables
    sku: sku
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    tableNames: tableNames
  }
}]

```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `storageAccountName` | `string` | true | Specify unique Storage Account Name |
| `sku` | `string` | false | Defines Storage SKU |
| `location` | `string` | false| Specify the location where storage account is to be created |
| `containerNames` | `array` | true | Provide array of container names (containerName, value: name of container in lowercase) and the access tier (containerAccess, allowed values 'Blob', 'Container', 'None' ) per container to be created. Will create container only if deployContainer parameter is set to true.  Additional Details [here](#array---containernames). |
| `deployContainer` | `bool` | true | Specify true if container is to be deployed |
| `resourceTags` | `object` | true | Speciy mapping of tags attached to Storage Account. Additional Details [here](#object---resourcetags) |
| `kind` | `string` | true | Indicates the type of storage account. |
| `containerAccess` | `string` | true | Specify access tier used for billing |
| `allowBlobPublicAccess` | `bool` | false | Allow or disallow public access to all blobs or containers in the storage account. The default interpretation is true for this property|
| `allowSharedKeyAccess` | `bool` | false |Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). The default value is null, which is equivalent to true. |
| `isHnsEnabled` | `bool` | false |Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2. This can only be true when account_tier is Standard or when account_tier is Premium and account_kind is BlockBlobStorage. |
| `supportsHttpsTrafficOnly` | `bool` | false |Allows https traffic only to storage service if sets to true |
| `networkAcls` | `object` | true |Network rule set; Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Default action, Allow action & the corresponding IP addresses or blocks.  Additional Details [here](#object---networkacls).|
| `changeFeed` | `object` | true | The blob service properties for change feed events. Additional Details [here](#object---changefeed).|
| `shouldCreateShares` | `bool` | true | Boolean flag which indicates if File Shares should be created.|
| `shareNames` | `array` | true | Array to specify the names of the file share(s) to be created. |
| `fileShareQuota` | `int` | true | The maximum size of the share, in gigabytes. Must be greater than 0, and less than or equal to 5TB (5120). For Large File Shares, the maximum size is 102400.|
| `shouldCreateQueues` | `bool` | true | Boolean flag which indicates if Queues should be created. |
| `queueNames` | `array` | true | Array to specify the names of the queue(s) to be created.|
| `shouldCreateTables` | `bool` | true | Boolean flag which indicates if Tables should be created. |
| `tableNames` | `array` | true | IArray to specify the names of the table(s) to be created.|
| `blobSvcDeleteRetentionPolicy` | `object` | true | The blobservice properties for soft delete. Enabled & days parameters.  Additional Details [here](#object---blobsvcdeleteretentionpolicy).|


### Array - containerNames

| Name | Type | Description |
| --- | --- | --- |
| `defaultEncryptionScope` | `string` |Default the container to use specified encryption scope for all writes. |
| `denyEncryptionScopeOverride` | `bool` | Block override of encryption scope from the container default. |
| `enableNfsV3AllSquash` | `bool` | Enable NFSv3 all squash on blob container. |
| `enableNfsV3RootSquash` | `bool` | Enable NFSv3 root squash on blob container.|
| `immutableStorageWithVersioning` | `object` | The object level immutability property of the container. The property is immutable and can only be set to true at the container creation time. Existing containers must undergo a migration process. Additional Details [here](#object---immutablestoragewithversioning) .|
| `metadata` | `object` | A name-value pair to associate with the container as metadata. `key`:`value`|
| `publicAccess` | `string` | Specifies whether data in the container may be accessed publicly and the level of access. Values are 'Blob','Container','None'|

#### Object - immutableStorageWithVersioning

| Name | Type | Description |
| --- | --- | --- |
| `enabled` | `bool` |This is an immutable property, when set to true it enables object level immutability at the container level. |

### Object - resourceTags
Below is an example of the tags object

`"key"`:`"value"`

**Example:**
```json
{
    "EvidenManaged": "true",
    "Project": "Monitoring Parent Module",
    "ManagedBy": "AzureBicep"
}
```

### Object - networkAcls

| Name | Type | Description |
| --- | --- | --- |
| `bypass` | `string` |Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging,Metrics,AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics. Values are  'AzureServices','Logging','Metrics','None'|
| `defaultAction` | `string` | Specifies the default action of allow or deny when no other rules match. |
| `ipRules`| `object` | Sets the IP ACL rules.  Additional Details [here](#object---iprules) . |
| `resourceAccessRules` | `object` | Sets the resource access rules.  Additional Details [here](#object---resourceaccessrules).|
| `virtualNetworkRules`| `object` | Sets the virtual network rules.  Additional Details [here](#object---virtualnetworkrules).|

#### Object - ipRules

| Name | Type | Description |
| --- | --- | --- |
| `action` | `string` |The action of IP ACL rule. Value of 'Allow' or Deny|
| `value` | `string` |Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed.|


#### Object - resourceAccessRules

| Name | Type | Description |
| --- | --- | --- |
| `resourceId` | `string` |Resource Id|
| `tenantId` | `string` |	Tenant Id|

#### Object - virtualNetworkRules

| Name | Type | Description |
| --- | --- | --- |
| `action` | `string` |The action of virtual network rule. Values are 'Allow'|
| `id` | `string` |	Resource ID of a subnet, for example: /subscriptions/{subscriptionId}/resourceGroups/{groupName}/providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}.	|
| `state` | `string` |	Gets the state of virtual network rule.	Values are 'Deprovisioning','Failed','NetworkSourceDeleted','Provisioning','Succeeded'|


### Object - changeFeed

| Name | Type | Description |
| --- | --- | --- |
| `enabled` | `bool` |Indicates whether change feed event logging is enabled for the Blob service.|
| `retentionInDays` | `int` | Indicates the duration of changeFeed retention in days. Minimum value is 1 day and maximum value is 146000 days (400 years). A null value indicates an infinite retention of the change feed.|


### Object - blobSvcDeleteRetentionPolicy

| Name | Type | Description |
| --- | --- | --- |
| `enabled` | `bool` |Indicates whether DeleteRetentionPolicy is enabled.|
| `allowPermanentDelete` | `bool` | This property when set to true allows deletion of the soft deleted blob versions and snapshots. This property cannot be used blob restore policy. This property only applies to blob service and does not apply to containers or file share.|
| `days` | `int` | Indicates the number of days that the deleted item should be retained. The minimum specified value can be 1 and the maximum value can be 365.|




## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `storageAccountID` | The resource ID of the created storage account. | `storageAccount.id` |
| `containerObject` | List of container ID's created. | `[for (containerName, i) in containerNames: { containerName: containerName ContainerID: blobService::containers[i].id }]` |

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storageAccountName": {
            "value": "sargpsc130522"
        },
        "kind": {
            "value": "StorageV2"
        },
        "sku": {
            "value": "Standard_LRS"
        },
        "accessTier": {
            "value": "Hot"
        },
        "isHnsEnabled": {
            "value": false
        },
        "shouldCreateContainers": {
            "value": true
        },
        "changeFeed": {
            "value": {
                "enabled": true,
                "retentionInDays": 7
            }
        },
        "blobSvcDeleteRetentionPolicy": {
            "value": {
                "enabled": true,
                "days": 7
            }
        },
        "networkAcls": {
            "value": {
                "bypass": "AzureServices, Logging, Metrics",
                "defaultAction": "Allow",
                "ipRules": [
                    {
                        "action": "Allow",
                        "value": "84.106.218.12"
                    },
                    {
                        "action": "Allow",
                        "value": "147.161.183.93"
                    }
                ]
            }
        },
        "shouldCreateShares": {
            "value": true
        },
        "shouldCreateQueues": {
            "value": true
        },
        "shouldCreateTables": {
            "value": true
        },
        "containerNames": {
            "value": [
                {
                    "containerName": "devcontainer001",
                    "containerAccess": "None"
                },
                {
                    "containerName": "devcontainer002",
                    "containerAccess": "None"
                },
                {
                    "containerName": "devcontainer003",
                    "containerAccess": "None"
                },
                {
                    "containerName": "artifactcontainer",
                    "containerAccess": "Blob"
                },
                {
                    "containerName": "publicaccesscontainer",
                    "containerAccess": "Container"
                }
            ]
        },
        "shareNames": {
            "value": [
                "devshare01",
                "devshare02",
                "devshare03"
            ]
        },
        "fileShareQuota": {
            "value": 100
        },
        "queueNames": {
            "value": [
                "devqueue01",
                "devqueue02",
                "devqueue03"
            ]
        },
        "tableNames": {
            "value": [
                "devtable01",
                "devtable02",
                "devtable03",
                "devtable04"
            ]
        },
        "location": {
            "value": "westeurope"
        },
        "tags": {
            "value": {
                "Owner": "Sandro",
                "Project": "Storage Account Child Module",
                "UserStory": "DCSAZ-1707",
                "Environment": "Test",
                "ManagedBy": "AzureBicep"
            }
        },
        "allowBlobPublicAccess": {
            "value": true
        },
        "allowSharedKeyAccess": {
            "value": true
        }
    }
}
```