# Reporting Parent module
Azure Bicep parent module to create the DashBoard resources for Eviden Landing Zones for Azure.

## Description
This parent module calls the storageAccount, the dashboard and the workbook child modules in the childModules folder and deploys a storage account for reporting, several workbooks and the dashboard resources required for the dashboards in the customer management subscriptions

The following resources are created:

 - A resource group for all the resources
 - A storage account for reporting
 - The workbooks for each dashboards that will be deployed
 - The dashboards as selected in the parameters for this module.

### Naming convention module
To ensure & enforce the required naming convention, the helper naming module is used by all other child modules. The names being generated by the naming module are the actual resource names which are used on the Azure platform.

The naming convention module is run in a previous stage of the workflow. The output from the module is saved to a file and published as a workflow artifact. In subsequent jobs the artifact is downloaded and used by Bicep parent modules.

The downloaded artifact is referenced by parent modules by declaring a '*Naming' variable. For example: var mgmtNaming = json(loadTextContent('../../mgmtNaming.json'))

### Parent module overview
The parent module has been configured as follows:
1. Defined the variables for the workbooks and dashboards
2. The output of the naming module is loaded via variables.
3. The resource group and storage account for reporting are defined next based on naming module.
4. In the following section the workbooks are created in the resourceGroup.
5. In the last section the parameters in the json of the dashboards are replaced by the parameters, variables and workbook resource Id's created in this parentmodule and the dashboards are defined.

### Parent module parameters

**Required parameters**

| Name | Type | Description |
| --- | --- | --- |
| `deploymentScope` | `string` | Deployment scope for the reporting parent module. Allowed values: 'core', 'network', 'osmgmt', 'paas'. To be provided by the pipeline.|
| `location` | `string` | Specifies the location where the resource will be deployed. To be provided by the pipeline.|

**Optional parameters**
None

## Example parameters file
The required customerspecific parameters are provided by the pipeline already. There is no need for a customer parameter file

## Azure Configuration Values

The parentModule folder (where the reporting.bicep file resides) contains a `parentModuleConfig.json` file. This json file holds the default configuration for the reporting deployment. The values from the json file maps to the storageAccount and dashboard child module parameters.

The `parentModuleConfig.json` file is referenced by the Reporting parent module by declaring a 'parentModuleConfig' variable; `var parentModuleConfig = loadJsonContent('parentModuleConfig.json')`.

In the following table the configuration defaults are described.

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| `reportingTags` | `object` | `{}` | A mapping of tags to assign to the resource. | 
| `storageAccountSku` | `string` | `Standard_LRS` | Defines Storage SKU. For the storage tier Standard_LRS is selected because the storage account does not contain critical information that cannot be easily recreated. |
| `storageAccountKind` | `string` | `StorageV2` | Indicates the type of storage account. Microsofts recommends StorageV2 for storage accounts. The  default configuration follows this recommendation. |
| `storageAccountAccessTier` | `string` | `Hot`| Specify access tier used for reporting. (Artifact) Blobs on this storage account need to be available when accessed through the dashboards. So, the default is set to Hot. |
| `storageAccountAllowBlobPublicAccess` | `bool` | `true` | Allow or disallow public access to all blobs or containers in the storage account. Public access level is set to true to be able to configure acls on specific containers, like the artifact container. |
| `storageAccountIsHnsEnabled` | `bool` | `false` |Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2. This can only be true when account_tier is Standard or when account_tier is Premium and account_kind is BlockBlobStorage. Hierarchical Namespace is not needed for this storage account |
| `storageAccountNetworkAcls` | `object` | `{bypass: 'AzureServices, Logging, Metrics', defaultAction: 'Allow', ipRules: '[]'}` | The  default configuration for access to the storage account via network is as follows: AzureServices, Logging & Metrics will bypass any restrictions. The default action when no other rules match is to Allow the traffic. No IP addresses are set as allowed in the storage account firewall. |
| `storageAccountChangeFeed` | `object` | `{enabled: 'true', retentionInDays: '7'}` | It is best practice to enable change feed to track changes (on blobs & blob metadata). By default is to set the logging to 7 days.|
| `storageAccountBlobSvcDeleteRetentionPolicy` | `object` | `{enabled: 'true', retentionInDays: '7'}` | The blobservice properties for soft delete. Enabled & days parameters. By default is to retain deleted blobs for 7 days.|
| `storageAccountshouldCreateContainers` | `bool` | `true` | Specify if containers should be created at the storage account. This is set to true to enable the creation of the containers specified in storageAccountContainerNames |
| `storageAccountContainerNames` | `array` | `[{containerName: 'artifacts', containerAccess: 'Blob'}, {containerName: 'customerdoc', containerAccess: 'None'}, {containerName: 'iamsubscriptionreport', containerAccess: 'None'}, {containerName: 'offlinereports', containerAccess: 'None'}]` | Provide array of container names (containerName, value: name of container in lowercase) and the access tier (containerAccess, allowed values 'Blob', 'Container', 'None' ) per container to be created. Will create container only if deployContainer parameter is set to true. The artifact container for the dashboard artifacts and the containers for the reports that are referenced from the dashboards are created by default. |
| `release` | `string` | `Release 2.3`| Specifies the release that will be deployed. Will be visible in cloud core dashboard |
| `releaseNotes` | `string` | `https://docs.cloud.eviden.com/02.%20Eviden%20Landing%20Zones/02.%20AZURE/01.-Release-Notes/000-Overview/` | Specifies the url for the release notes page in the public site.|
| `coreDashboardDisplayName` | `string` | `CloudCoreReportingDashboard` | The name for the core dashboard. Only alphanumerics and hyphens are allowed in the name.|
| `osMgmtDashboardDisplayName` | `string` | `VMOSManagementReportingDashboard` | The name for the os management dashboard. Only alphanumerics and hyphens are allowed in the name.| 
| `paasDashboardDisplayName` | `string` | `PaaSServicesReportingDashboard` | The name for the paas dashboard. Only alphanumerics and hyphens are allowed in the name.|

For more information on the storage account parameters, for which these default values are set please check the storageAccount child module [README](../../childModules/storageAccount/README.md).

For more information on the dashboard parameters, for which these default values are set please check the dashboard child module [README](../../childModules/dashboard/README.md).

> **Note**
> 
> It is recommended to only change these values after consulting the Eviden Landing Zones for Azure engineering team.

## Outputs

None.