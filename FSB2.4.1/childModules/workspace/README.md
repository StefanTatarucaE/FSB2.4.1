# workspace/workspace.bicep
Bicep module to create a Workspace. 'Microsoft.OperationalInsights/workspaces'

## Description
This module deploys a Workspace, its data sources and solutions. Optionally a linked automation account can be deployed, whenever required. The module also allows for setting custom interactive retention and archival retention periods for user defined tables.

## Module example use
```bicep
module exampleWorkspace './childModules/workspace/workspace.bicep' = {
  name: 'exampleWorkspace-deployment'
  scope: resourceGroup('cux-subx-d-rsg-development')
  params: {
    workspaceName: 'cux-subx-d-workspace'
    capacityReservationLevel: 100
    skuName: 'perNode'
    retentionInDays: 365
    location: 'westeurope'
    tags: {
      EvidenManaged: 'true'
    }
    automationAccountId: '<referencedSymbolicAutomationAccount.id>' //optional, if the workspace needs a linked automation account (case of Management subscription)
    linkedServiceName: 'exampleWorkspaceName/Automation' //optional, if the workspace needs a linked automation account (case of Management subscription)
  }
}
```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `workspaceName` | `string` | true | Specifies the name of the Workspace. |
| `location` | `string` | true | Specifies the location of the Workspace. |
| `skuName` | `string` | true | Defines The name of the SKU. Valid options are Free, PerGB2018, Standard or Premium. |
| `dailyQuotaGb` | `int` | false | The workspace daily quota for ingestion. |
| `retentionInDays` | `int` | true | The workspace data retention in days.|
| `publicNetworkAccess` | `object` | true | The network access type for operating on the Workspace. By default it is Enabled. Additional Details [here](#object---publicnetworkaccess). |
| `dataSources` | `array` | false | Datasources to add to the Workspace. Additional Details [here](#array---datasources). |
| `solutions` | `array` | false| Solutions to add to the Workspace. Additional Details [here](#array---solutions). |
| `tags` | `object` | true | Specifies the resource specific tags. Additional Details [here](#object---tags). |
| `setRetentionDays` | `array` | false| Custom retention times for user defined tables. Additional Details [here](#array---setRetentionDays). |

### Object - publicNetworkAccess

| Name | Type | Description |
| --- | --- | --- |
| `forIngestion` | `string` |The network access type for accessing Log Analytics ingestion. Values are 'Disabled','Enabled'|
| `forQuery` | `bool` | The network access type for accessing Log Analytics query.Values are 'Disabled','Enabled'|

### Array - setRetentionDays

| Name | Type | Description |
| --- | --- | --- |
| `name` | `string` |name of the table for which the interactive and archival retention time must be set.|
| `retentionInDays` | `int` | The table retention in days, between 4 and 730. Setting this property to -1 will default to the workspace retention. |
| `totalRetentionInDays` | `int` | The table total retention in days, between 4 and 2555. Setting this property to -1 will default to table retention.|

### Array - dataSources

| Name | Type | Description |
| --- | --- | --- |
| `name` | `string` |The resource name|
| `plan` | `string` | The kind of the DataSource. Values are 'ApplicationInsights','AzureActivityLog','AzureAuditLog','ChangeTrackingContentLocation','ChangeTrackingCustomPath','ChangeTrackingDataTypeConfiguration','ChangeTrackingDefaultRegistry','ChangeTrackingLinuxPath','ChangeTrackingPath','ChangeTrackingRegistry','ChangeTrackingServices','CustomLog','CustomLogCollection','DnsAnalytics','GenericDataSource','IISLogs','ImportComputerGroup','Itsm','LinuxChangeTrackingPath','LinuxPerformanceCollection','LinuxPerformanceObject','LinuxSyslog','LinuxSyslogCollection','NetworkMonitoring','Office365','SecurityCenterSecurityWindowsBaselineConfiguration','SecurityEventCollectionConfiguration','SecurityInsightsSecurityEventCollectionConfiguration','SecurityWindowsBaselineConfiguration','SqlDataClassification','WindowsEvent','WindowsPerformanceCounter','WindowsTelemetry' |
| `properties` | `object` | The data source properties in raw json format, each kind of data source have it's own schema.For Bicep, you can use the any() function. For more details check the [parameter example](#parameters-file-example)|


### Array - solutions

| Name | Type | Description |
| --- | --- | --- |
| `name` | `string` |name of the solution to be created. For Microsoft published solution it should be in the format of solutionType(workspaceName). SolutionType part is case sensitive. For third party solution, it can be anything.|
| `product` | `string` | 	name of the solution to enabled/add. For Microsoft published gallery solution it should be in the format of OMSGallery/{solutionType}. This is case sensitive |
| `promotionCode` | `string` | promotionCode, Not really used now, can you left as empty|
| `publisher` | `string` | Publisher name. For gallery solution, it is Microsoft.|



### Object - tags
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

## Module Outputs

| Name | Description | Value
| --- | --- | --- |
| `workspaceName` | The name of the deployed Workspace | `workspace.name` |
| `workspaceResourceID` | The resource ID of the deployed Workspace | `workspace.id` |


## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "workspaceName": {
            "value": "ats-msp1-d-loganalytics-msp"
        },
        "location": {
            "value": "westeurope"
        },
        "skuName": {
            "value": "PerGB2018"
        },
        "retentionInDays": {
            "value": 31
        },
        "publicNetworkAccess": {
            "value": {
                "forIngestion": "Enabled",
                "forQuery": "Enabled"
            }
        },
        "tags": {
            "value": {
                "Owner": "Sandro",
                "Project": "LAW Child Module",
                "Environment": "Dev",
                "UserStory": "DCSAZ-1686",
                "EvidenManaged": "true",
                "ManagedBy": "AzureBicep"
            }
        },
        "dataSources": {
            "value": []
        },
        "solutions": {
            "value": [
                {
                    "name": "SecurityCenterFree",
                    "publisher": "Microsoft",
                    "product": "OMSGallery/SecurityCenterFree",
                    "promotionCode": ""
                },
                {
                    "name": "AgentHealthAssessment",
                    "publisher": "Microsoft",
                    "product": "OMSGallery/AgentHealthAssessment",
                    "promotionCode": ""
                },
                {
                    "name": "AzureActivity",
                    "publisher": "Microsoft",
                    "product": "OMSGallery/AzureActivity",
                    "promotionCode": ""
                },
                {
                    "name": "AlertManagement",
                    "publisher": "Microsoft",
                    "product": "OMSGallery/AlertManagement",
                    "promotionCode": ""
                },
                {
                    "name": "NetworkMonitoring",
                    "publisher": "Microsoft",
                    "product": "OMSGallery/NetworkMonitoring",
                    "promotionCode": ""
                },
                {
                    "name": "ADAssessment",
                    "publisher": "Microsoft",
                    "product": "OMSGallery/ADAssessment",
                    "promotionCode": ""
                },
                {
                    "name": "AzureSQLAnalytics",
                    "publisher": "Microsoft",
                    "product": "OMSGallery/AzureSQLAnalytics",
                    "promotionCode": ""
                },
                {
                    "name": "KeyVaultAnalytics",
                    "publisher": "Microsoft",
                    "product": "OMSGallery/KeyVaultAnalytics",
                    "promotionCode": ""
                },
                {
                    "name": "VMInsights",
                    "publisher": "Microsoft",
                    "product": "OMSGallery/VMInsights",
                    "promotionCode": ""
                }
            ]
        }
    }
}
```