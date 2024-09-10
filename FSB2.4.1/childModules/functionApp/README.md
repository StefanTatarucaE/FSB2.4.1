# functionApp/functionApp.bicep
Bicep module to create a Function App and it's related components.

## Description
Azure Functions allows you to implement your system's logic into readily-available blocks of code. These code blocks are called "functions".
Azure Functions is the serverless computing service hosted on the Microsoft Azure public cloud. Azure Functions, and serverless computing, in general, is designed to accelerate and simplify application development.
The idea behind serverless computing, also known as function as a service, is to eliminate those infrastructure considerations for the user. With serverless, a user can simply create and upload code, and then define the triggers or events that will execute the code

This module will create: 
- App Service Plan (Hosting Plan)
- Inisghts Component
- Azure Function App

Based on appServiceSiteConfig and appServiceProperties parameters, the module will be flexible to deploy the Function App with different settings depending on the desired scope (ITSM, Billing, OSVersion, etc).

The `SystemAssigned` identity to the function app as this will be needed by all function apps to authenticate.

## Module Example
```bicep
module devFunctionApp '../../modules/functionApp/functionApp.bicep' = {
  scope: resourceGroup('cux-subx-d-rsg-functionapp')
  name: 'devFunctionAppModule'
  params: {
    appServicePlanName: appServicePlanName
    appServiceName: appServiceName
    appInsightsName: appInsightsName
    appInsightsProperties: appInsightsProperties
    tags: functionAppTags
    hostingPlanSku: hostingPlanSku
    hostingPlanKind: hostingPlanKind
    appInsightsKind: appInsightsKind
    appServiceStorageName: appServiceStorageName
    appServiceKeyVaultName: appServiceKeyVaultName
    appServiceKind: appServiceKind
    appServiceProperties: appServiceProperties
    appServiceClientAffinityEnabled: appServiceClientAffinityEnabled
    appServiceHttpsOnly: appServiceHttpsOnly
    appServiceClientCertEnabled: appServiceClientCertEnabled
    appServiceSiteConfig: appServiceSiteConfig
}
```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `appServicePlanName` | `string` | true | The name of the App service Plan |
| `appServiceName` | `string` | true | The name of the App Service (FunctionApp) |
| `appInsightsName` | `string` | true | The name of the App Insights component |
| `location` | `string` | true | Location for App Service and related components |
| `appInsightsProperties`| `object` | true | 'App Insights properties. Array of elements. See details below.  Additional Details [here](#object---appinsightsproperties) .|
| `tags` | `object` | true | A mapping of tags to assign to the resource.  Additional Details [here](#object---tags).|
| `appServicePlanSku` | `object` | true | Hosting Plan SKU object (name and tier). See details below. Additional Details [here](#object---appserviceplansku). |
| `appServicePlanKind` | `string` | true | Hosting Plan Kind (possible values: Windows, Linux, elastic, FunctionApp) |
| `appInsightsKind` | `string` | true | App Insights Kind (possible values: web, ios, other, store, java, phone) |
| `appServiceStorageName` | `string` | true | Storage Account name used for Function App |
| `appServiceKeyVaultName` | `string` | false | KeyVault used for Function App. This parameter is optional, and will only be used if the function app needs a key vault. Hence this will be empty by default.|
| `appServiceKind` | `string` | true | App Service kind. Possible values: "api", "app", "app,linux", "functionapp", "functionapp,linux") |
| `appServiceProperties` | `object` | true | App Insights properties. Array of elements. See details below. Additional Details [here](#object---appserviceproperties). |
| `appServiceClientAffinityEnabled` | `bool` | true | App Service Client Affinity enabled. (possible values: True or False) |
| `appServiceHttpsOnly` | `bool` | true | App Service Https Only. (possible values: True or False) |
| `appServiceClientCertEnabled` | `bool` | true |App Service Client certificate enabled. (possible values: True or False) |
| `appServiceSiteConfig` | `object` | true | App Service Site Config object. Array of elements. See details below.  Additional Details [here](#object---appservicesiteconfig).|

### Object - appInsightsProperties
| Name | Type | Description |
| --- | --- | --- |
| `Application\_Type`| `string` | Type of application being monitored. Values are `other', 'web'`|
| `DisableIpMasking` | `bool`| Disable IP masking.|
| `DisableLocalAuth` | `bool`| Disable Non-AAD based Auth.|
| `Flow\_Type` | `string`| This is to be set to 'Bluefield' when creating/updating a component via the REST API. |
| `ForceCustomerStorageForProfiler` | `bool`| Force users to create their own storage account for profiler and debugger.|
| `HockeyAppId` | `string`| The unique application ID created when a new application is added to HockeyApp, used for communications with HockeyApp. |
| `ImmediatePurgeDataOn30Days` | `bool`| Purge data immediately after 30 days. |
| `IngestionMode` |`string` | Indicates the flow of the ingestion.  `ApplicationInsights', 'ApplicationInsightsWithDiagnosticSettings''LogAnalytics'` |
| `publicNetworkAccessForIngestion`|`string` | The network access type for operating on the Application Insights Component. By default it is Enabled| `Disabled', 'Enabled'`|
| `publicNetworkAccessForQuery`|`string` | The network access type for operating on the Application Insights Component. By default it is Enabled | `Disabled', 'Enabled'` |
| `Request\_Source` |`string`| Describes what tool created this Application Insights component. Customers using this API should set this to the default 'rest'. | `'rest'`|
| `RetentionInDays`  | `int`| Retention period in days.  |
| `SamplingPercentage` | `int` | Percentage of the data produced by the application being monitored that is being sampled for Application Insights telemetry. |
| `WorkspaceResourceId` | `string`| Resource Id of the log analytics workspace which the data will be ingested to.  |

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

### Object - appServicePlanSku
| Name | Type  | Description |
| --- | --- | --- |
| `capabilities` | `string`| Capabilities of the SKU, e.g., is traffic manager enabled?  |
| `capacity` | `int`| Current number of instances assigned to the resource.  |
| `family` | `string`| Family code of the resource SKU.  |
| `locations` | `string`| Locations of the SKU. |
| `name` | `string`| Name of the resource SKU.  |
| `size` | `string`| Size specifier of the resource SKU.  |
| `skuCapacity`| `string` | Description of the App Service plan scale options.   Additional Details [here](#object---skucapacity).|
| `tier` | `string`| Service tier of the resource SKU.  |

#### Object - skuCapacity
| Name | Type  | Description |
| --- | --- | --- |
| `default` | `int`| Default number of workers for this App Service plan SKU.  |
| `elasticMaximum` | `int`| Maximum number of Elastic workers for this App Service plan SKU.  |
| `maximum` | `int`| Maximum number of workers for this App Service plan SKU.  |
| `minimum` | `int`| Minimum number of workers for this App Service plan SKU. |
| `scaleType` | `string`| Available scale configurations for an App Service plan.  |

### Object - appServiceProperties
| Name | Type  | Description |
| --- | --- | --- |
| `name` | `string`| The name of the app setting for the function app.  |
| `value` | `int`| The value for the corresponding app settings.  |

### Object - appServiceSiteConfig
| Name | Type | Description |
| --- | --- | --- |
| `acrUseManagedIdentityCreds` | `bool`| Flag to use Managed Identity Creds for ACR pull  |
| `acrUserManagedIdentityID` | `string`| If using user managed identity, the user managed identity ClientId  |
| `alwaysOn` | `bool`| `true` if Always On is enabled; otherwise, `false`.  |
| `apiDefinition` | `object`| Information about the formal API definition for the app.  Additional Details [here](#object---apidefinition).|
| `apiManagementConfig`| `object` | Azure API management (APIM) configuration linked to the app.  Additional Details [here](#object---apimanagementconfig).|
| `appCommandLine` | `string`| App command line to launch.  |
| `appSettings` | `object`| Application settings. Additional Details [here](#object---appsettings).|
| `autoHealEnabled` | `bool` | if Auto Heal is enabled; otherwise, `false`. |
| `autoHealRules` | `object`| Rules that can be defined for auto-heal. Details can be found [here](https://docs.microsoft.com/azure/templates/microsoft.web/sites/config-web?pivots=deployment-language-bicep#autohealrules) |
| `autoSwapSlotName` | `string`| Auto-swap slot name.  |
| `azureStorageAccounts` | `object`| List of Azure Storage Accounts. Details can be found [here](https://docs.microsoft.com/azure/templates/microsoft.web/sites/config-azurestorageaccounts?pivots=deployment-language-bicep) |
| `connectionStrings` | `object`| Connection strings. Additional Details [here](#object---connectionstrings).|
| `cors` | `string`| Cross-Origin Resource Sharing (CORS) settings for the app.  Additional Details [here](#object---cors).|
| `defaultDocuments` | `string`| Default documents.  |
| `detailedErrorLoggingEnabled` | `bool`| `true` if detailed error logging is enabled; otherwise, `false`.  |
| `documentRoot` | `string`| Document root.  |
| `experiments` | `string`| This is work around for polymorphic types. Details can be found [here](https://docs.microsoft.com/azure/templates/microsoft.web/sites/config-web?pivots=deployment-language-bicep#experiments)|
| `ftpsState` | `string`| State of FTP / FTPS service. Allowed values are `'AllAllowed' 'Disabled' 'FtpsOnly'` |
| `functionAppScaleLimit` | `int`| Maximum number of workers that a site can scale out to.This setting only applies to the Consumption and Elastic Premium Plans  |
| `functionsRuntimeScaleMonitoringEnabled` | `bool`| Gets or sets a value indicating whether functions runtime scale monitoring is enabled.  |
| `handlerMappings`| `object` | Handler mappings.  Details can be found [here](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites/config-web?pivots=deployment-language-bicep#handlermapping)|
| `healthCheckPath` | `string`| Health check path  |
| `http20Enabled` | `bool`| Http20Enabled: configures a web site to allow clients to connect over http2.0 |
| `httpLoggingEnabled` | `bool`| `true` if HTTP logging is enabled; otherwise, `false`.  |
| `ipSecurityRestrictions` | `object` | IP security restrictions for main. Details can be found [here](https://docs.microsoft.com/azure/templates/microsoft.web/sites/config-web?pivots=deployment-language-bicep#ipsecurityrestriction) |
| `javaContainer`|`string` | Java container.  |
| `javaContainerVersion` | `string`| Java container version.  |
| `javaVersion` | `string`| Java version.  |
| `keyVaultReferenceIdentity` | `string`| Identity to use for Key Vault Reference authentication.  |
| `limits` | `object`| Metric limits set on an app. Details can be found [here](https://docs.microsoft.com/azure/templates/microsoft.web/sites/config-web?pivots=deployment-language-bicep#sitelimits) |
| `linuxFxVersion` | `string`| Linux App Framework and version  |
| `loadBalancing` | `string`| Site load balancing. Allowed values are `'LeastRequests''LeastResponseTime''PerSiteRoundRobin''RequestHash''WeightedRoundRobin''WeightedTotalTraffic'` |
| `localMySqlEnabled` | `bool`| `true` to enable local MySQL; otherwise, `false`.  |
| `logsDirectorySizeLimit` | `int`| HTTP logs directory size limit.  |
| `managedPipelineMode` | `string`| Managed pipeline mode. Allowed values are `'Classic''Integrated'` |
| `managedServiceIdentityId` | `int` | Managed Service Identity Id |
| `minimumElasticInstanceCount` | `int`| Number of minimum instance count for a siteThis setting only applies to the Elastic Plans  |
| `minTlsVersion` | `string`| MinTlsVersion: configures the minimum version of TLS required for SSL requests. Allowed values are `'1.0''1.1''1.2'` |
| `netFrameworkVersion` | `string`| .NET Framework version.  |
| `nodeVersion` | `string`| Version of Node.js.  |
| `numberOfWorkers` | `int`| Number of workers.  |
| `phpVersion` | `string` | Version of PHP. |
| `powerShellVersion` | `string`| Version of PowerShell.  |
| `preWarmedInstanceCount`  | `int`| Number of preWarmed instances.This setting only applies to the Consumption and Elastic Plans |
| `publicNetworkAccess` | `string`| Property to allow or block all public traffic.  |
| `publishingUsername` | `string`| Publishing user name.  |
| `push` | `object`| Push settings for the App. Details can be found [here](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites/config-web?pivots=deployment-language-bicep#pushsettings) |
| `pythonVersion` | `string`| Version of Python.  |
| `remoteDebuggingEnabled`  | `bool`| `true` if remote debugging is enabled; otherwise, `false`. |
| `remoteDebuggingVersion` | `string`| Remote debugging version.  |
| `requestTracingEnabled`  | `bool`| `true` if request tracing is enabled; otherwise, `false`. |
| `requestTracingExpirationTime` | `string`| Request tracing expiration time.  |
| `scmIpSecurityRestrictions` | `object`| IP security restrictions for scm.  Details can be found [here](https://docs.microsoft.com/azure/templates/microsoft.web/sites/config-web?pivots=deployment-language-bicep#ipsecurityrestriction)  |
| `scmIpSecurityRestrictionsUseMain`  | `bool`| IP security restrictions for scm to use main. |
| `scmMinTlsVersion` | `string`| MinTlsVersion: configures the minimum version of TLS required for SSL requests. Allowed values are `'1.0''1.1''1.2'` |
| `scmType` | `string`| SCM type. Allowed values are`'BitbucketGit''BitbucketHg''CodePlexGit''CodePlexHg''Dropbox''ExternalGit''ExternalHg''GitHub''LocalGit''None''OneDrive''Tfs''VSO''VSTSRM'` |
| `tracingOptions`| `string` | Tracing options.  |
| `use32BitWorkerProcess` | `bool`| `true` to use 32-bit worker process; otherwise, `false`.  |
| `virtualApplications` | `object`| Virtual applications.  Details can be found [here](https://docs.microsoft.com/azure/templates/microsoft.web/sites/config-web?pivots=deployment-language-bicep#virtualapplication) |
| `vnetName` | `string` | Virtual Network name. |
| `vnetPrivatePortsCount` | `int`| The number of private ports assigned to this app. These will be assigned dynamically on runtime.  |
| `vnetRouteAllEnabled` | `bool`| Virtual Network Route All enabled. This causes all outbound traffic to have Virtual Network Security Groups and User Defined Routes applied.  |
| `websiteTimeZone` | `string`| Sets the time zone a site uses for generating timestamps. Compatible with Linux and Windows App Service.  |
| `webSocketsEnabled` | `bool`| `true` if WebSocket is enabled; otherwise, `false`.  |
| `windowsFxVersion` | `string`| Xenon App Framework and version  |
| `xManagedServiceIdentityId`  | `int`| Explicit Managed Service Identity Id |


#### Object - apiDefinition
| Name | Type  | Description |
| --- | --- | --- |
| `url` | `string`| The URL of the API definition.  |

#### Object - apiManagementConfig
| Name | Type  | Description |
| --- | --- | --- |
| `id` | `string`| APIM-Api Identifier.  |

#### Object - appSettings
| Name | Type  | Description |
| --- | --- | --- |
| `name` | `string`| Pair name.  |
| `value` | `string`| Pair value.  |

#### Object - connectionStrings
| Name | Type  | Description |
| --- | --- | --- |
| `connectionString` | `string`| Connection string value.  |
| `name` | `string`| 	Name of connection string.  |
| `type` | `string`| 	Type of database. 'ApiHub','Custom','DocDb','EventHub','MySql','NotificationHub','PostgreSQL','RedisCache','SQLAzure','SQLServer','ServiceBus'|

#### Object - cors
| Name | Type  | Description |
| --- | --- | --- |
| `allowedOrigins` | `string[]`| Gets or sets the list of origins that should be allowed to make cross-origin calls (for example: http://example.com:12345). Use "*" to allow all. |
| `supportCredentials	` | `string`| 	Gets or sets whether CORS requests with credentials are allowed. See https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Requests_with_credentials
for more details.  |


## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `appServicePlanId` | The resource ID of the App Service Plan created. | `appServicePlan.id` |
| `appInsightsId` | The resource ID of the App Insights created. | `appInsights.id` |
| `appServiceId` | The resource ID of the App Service (function App) created. | `appService.id` |
| `appServiceName` | The name of the App Service (function App) created. | `appService.name` |
| `systemIdentity` | The principal id of the system assigned identity for the function app. | `appService.identity.principalId` |

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "appServicePlanName": {
            "value": "cu1-msp1-d-hostplan-itsm"
        },
        "appServiceName": {
            "value": "cu1-msp1-d-functionapp-itsm"
        },
        "appInsightsName": {
            "value": "cu6-msp3-d-insightsapp-itsm"
        },
        "appInsightsProperties": {
            "value": {
                "ApplicationId": "cu6-msp3-d-insightsapp-itsm",
                "Request_Source": "IbizaWebAppExtensionCreate"
            }
        },
        "tags": {
            "value": {
                "EvidenManaged": "true",
                "tag2": "value2"
            }
        },
        "hostingPlanSku": {
            "value": {
                "name": "Y1",
                "tier": "Dynamic"
            }
        },
        "hostingPlanKind": {
            "value": "linux"
        },
        "appInsightsKind": {
            "value": "web"
        },
        "appServiceStorageName": {
            "value": "saccfunctionapp"
        },
        "appServiceKeyVaultName": {
            "value": "box-msp1-t-kvt-001"
        },
        "appServiceKind": {
            "value": "functionapp,linux"
        },
        "appServiceProperties": {
            "value": [
                {
                    "name": "FUNCTIONS_WORKER_RUNTIME",
                    "value": "python"
                },
                {
                    "name": "FUNCTIONS_EXTENSION_VERSION",
                    "value": "~4"
                },
                {
                    "name": "SECRET_NAME_EVENT",
                    "value": "global-monitoring-snow-event"
                },
                {
                    "name": "SECRET_NAME_CMDB",
                    "value": "global-monitoring-snow-event"
                },
                {
                    "name": "SNOW_URLS",
                    "value": "{\"PROD\":\"https://atosglobal.service-now.com\",\"CAT\":\"https://atosglobalcat.service-now.com\",\"DEV\":\"https://atosglobaldev.service-now.com\",\"SAND\":\"https://atosglobalsandbox.service-now.com\"}"
                }
            ]
        },
        "appServiceClientAffinityEnabled": {
            "value": true
        },
        "appServiceHttpsOnly": {
            "value": true
        },
        "appServiceClientCertEnabled": {
            "value": false
        },
        "appServiceSiteConfig": {
            "value": {
                "numberOfWorkers": -1,
                "defaultDocuments": [
                    "Default.htm",
                    "Default.html",
                    "Default.asp",
                    "index.htm",
                    "index.html",
                    "iisstart.htm",
                    "default.aspx",
                    "index.php"
                ],
                "netFrameworkVersion": "v4.0",
                "linuxFxVersion": "PYTHON|3.8",
                "requestTracingEnabled": false,
                "remoteDebuggingEnabled": false,
                "remoteDebuggingVersion": "VS2019",
                "httpLoggingEnabled": false,
                "logsDirectorySizeLimit": 35,
                "detailedErrorLoggingEnabled": false,
                "publishingUsername": "$ats-sub1-d-func-billing",
                "azureStorageAccounts": {},
                "scmType": "None",
                "use32BitWorkerProcess": false,
                "webSocketsEnabled": false,
                "alwaysOn": false,
                "managedPipelineMode": "Integrated",
                "virtualApplications": [
                    {
                        "virtualPath": "/",
                        "physicalPath": "site\\wwwroot",
                        "preloadEnabled": false
                    }
                ],
                "loadBalancing": "LeastRequests",
                "experiments": {
                    "rampUpRules": []
                },
                "autoHealEnabled": false,
                "cors": {
                    "allowedOrigins": [
                        "https://functions.azure.com",
                        "https://functions-staging.azure.com",
                        "https://functions-next.azure.com"
                    ],
                    "supportCredentials": false
                },
                "localMySqlEnabled": false,
                "managedServiceIdentityId": 6564,
                "ipSecurityRestrictions": [
                    {
                        "ipAddress": "Any",
                        "action": "Allow",
                        "priority": 1,
                        "name": "Allow all",
                        "description": "Allow all access"
                    }
                ],
                "scmIpSecurityRestrictions": [
                    {
                        "ipAddress": "Any",
                        "action": "Allow",
                        "priority": 1,
                        "name": "Allow all",
                        "description": "Allow all access"
                    }
                ],
                "scmIpSecurityRestrictionsUseMain": false,
                "http20Enabled": true,
                "minTlsVersion": "1.2",
                "ftpsState": "FtpsOnly",
                "preWarmedInstanceCount": 0
            }
        }
    }
}
```