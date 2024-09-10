# policy/dataFactoryAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy set definition & 1 policy assignment.

This policy configures governance and security policies for the Azure Datafactory.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/dataFactoryAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    dataFactorySettings : {
                keyvaultForStoringSecrets : 'Audit'
                sqlserverIntegrationJoinVn : 'Audit'
                disablePublicNetworkAccess : 'Audit'
                encryptWithCustomerManagedKey : 'Audit'
                resourceTypeInAllowList : 'Audit'
                allowedLinkedServiceResourceTypes : [
                    'AdlsGen2CosmosStructuredStream'
                    'AdobeExperiencePlatform'
                    'AdobeIntegration'
                    'AmazonRedshift'
                    'AmazonS3'
                    'AzureBlobFS'
                    'AzureBlobStorage'
                    'AzureDataExplorer'
                    'AzureDataLakeStore'
                    'AzureDataLakeStoreCosmosStructuredStream'
                    'AzureDataShare'
                    'AzureFileStorage'
                    'AzureKeyVault'
                    'AzureMariaDB'
                    'AzureMySql'
                    'AzurePostgreSql'
                    'AzureSearch'
                    'AzureSqlDatabase'
                    'AzureSqlDW'
                    'AzureSqlMI'
                    'AzureTableStorage'
                    'Cassandra'
                    'CommonDataServiceForApps'
                    'CosmosDb'
                    'CosmosDbMongoDbApi'
                    'Db2'
                    'DynamicsCrm'
                    'FileServer'
                    'FtpServer'
                    'GitHub'
                    'GoogleCloudStorage'
                    'Hdfs'
                    'Hive'
                    'HttpServer'
                    'Informix'
                    'Kusto'
                    'MicrosoftAccess'
                    'MySql'
                    'Netezza'
                    'Odata'
                    'Odbc'
                    'Office365'
                    'Oracle'
                    'PostgreSql'
                    'Salesforce'
                    'SalesforceServiceCloud'
                    'SapBw'
                    'SapHana'
                    'SapOpenHub'
                    'SapTable'
                    'Sftp'
                    'SharePointOnlineList'
                    'Snowflake'
                    'SqlServer'
                    'Sybase'
                    'Teradata'
                    'HDInsightOnDemand'
                    'HDInsight'
                    'AzureDataLakeAnalytics'
                    'AzureBatch'
                    'AzureFunction'
                    'AzureML'
                    'AzureMLService'
                    'MongoDb'
                    'GoogleBigQuery'
                    'Impala'
                    'ServiceNow'
                    'Dynamics'
                    'AzureDatabricks'
                    'AmazonMWS'
                    'SapCloudForCustomer'
                    'SapEcc'
                    'Web'
                    'MongoDbAtlas'
                    'HBase'
                    'Spark'
                    'Phoenix'
                    'PayPal'
                    'Marketo'
                    'Responsys'
                    'SalesforceMarketingCloud'
                    'Presto'
                    'Square'
                    'Xero'
                    'Jira'
                    'Magento'
                    'Shopify'
                    'Concur'
                    'Hubspot'
                    'Zoho'
                    'Eloqua'
                    'QuickBooks'
                    'Couchbase'
                    'Drill'
                    'Greenplum'
                    'MariaDB'
                    'Vertica'
                    'MongoDbV2'
                    'OracleServiceCloud'
                    'GoogleAdWords'
                    'RestService'
                    'DynamicsAX'
                    'AzureDataCatalog'
                    'AzureDatabricksDeltaLake'
                ]
                gitrepositoryForSourceControl: 'Audit'
                integrationRuntimeMaxCores: 'Audit'
                maxCores: 32
                usePrivateLink: 'AuditIfNotExists'
                systemAssignedManagedIdentity : 'Audit'
            }
        dataFactoryAuditDenySetName : 'datafactory.auditdeny.policy.set'
        dataFactoryAuditDenySetDisplayName : 'datafactory auditdeny policy set'
        dataFactoryAuditDenySetAssignmentName : 'datafactory.auditdeny.policy.set.assignment'
        dataFactoryAuditDenySetAssignmentDisplayName : 'datafactory auditdeny policy set assignment'
        policyMetadata : 'EvidenELZ'
    }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `dataFactorySettings` | `object` | true | Object which sets the values of the policy set definition parameters. The specific parameters & what they are for, are described in the `policySetDefinition` resource block. Additional details [`here`](#object---datafactorysettings)|
| `dataFactoryAuditDenySetName` | `string` | true | set name for datafactory audit deny initiative. |
| `dataFactoryAuditDenySetDisplayName` | `string` | true | set displayname for datafactory audit deny initiative. |
| `dataFactoryAuditDenySetAssignmentName` | `string` | true | set assignment name for datafactory audit deny initiative. |
| `dataFactoryAuditDenySetAssignmentDisplayName` | `string` | true | set assignment displayname for datafactory audit deny initiative. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |


### Object - dataFactorySettings
| Name | Type | Description |
| --- | --- | --- |
| `keyvaultForStoringSecrets` | `string` | To ensure secrets (such as connection strings) are managed securely, require users to provide secrets using an Azure Key Vault instead of specifying them inline in linked services. Allowed Values: Audit, Deny, Disabled. |
| `sqlserverIntegrationJoinVn` | `string` | Azure Virtual Network deployment provides enhanced security and isolation for your SQL Server Integration Services integration runtimes on Azure Data Factory, as well as subnets, access control policies, and other features to further restrict access. Allowed Values: Audit, Deny, Disabled. |
| `disablePublicNetworkAccess` | `string` | Disabling the public network access property improves security by ensuring your Azure Data Factory can only be accessed from a private endpoint. Allowed Values: Audit, Deny, Disabled. |
| `encryptWithCustomerManagedKey` | `string` | To ensure secrets (such as connection strings) are managed securely, require users to provide secrets using an Azure Key Vault instead of specifying them inline in linked services. Allowed Values: Audit, Deny, Disabled. |
| `resourceTypeInAllowList` | `string` | Define the allow list of Azure Data Factory linked service types. Restricting allowed resource types enables control over the boundary of data movement. For example, restrict a scope to only allow blob storage with Data Lake Storage Gen1 and Gen2 for analytics or a scope to only allow SQL and Kusto access for real-time queries. Allowed Values: Audit, Deny, Disabled. |
| `allowedLinkedServiceResourceTypes` | `string` | The list of allowed linked service resource types. |
| `gitrepositoryForSourceControl` | `string` | Enable source control on data factories, to gain capabilities such as change tracking, collaboration, continuous integration, and deployment. Allowed Values: Audit, Deny, Disabled. |
| `integrationRuntimeMaxCores` | `string` | To manage your resources and costs, limit the number of cores for an integration runtime. Allowed Values: Audit, Deny, Disabled. |
| `maxCores` | `int` | The max number of cores allowed for dataflow.  |
| `usePrivateLink` | `string` | Azure Private Link lets you connect your virtual network to Azure services without a public IP address at the source or destination. The Private Link platform handles the connectivity between the consumer and services over the Azure backbone network. By mapping private endpoints to Azure Data Factory, data leakage risks are reduced. Allowed Values: AuditIfNotExists, Disabled. |
| `systemAssignedManagedIdentity` | `string` | Using system-assigned managed identity when communicating with data stores via linked services avoids the use of less secured credentials such as passwords or connection strings. Allowed Values: Audit, Deny, Disabled. |

## Module Outputs
None.


## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "dataFactorySettings": {
            "value": {
                "keyvaultForStoringSecrets": "Audit",
                "sqlserverIntegrationJoinVn": "Audit",
                "disablePublicNetworkAccess": "Audit",
                "encryptWithCustomerManagedKey": "Audit",
                "resourceTypeInAllowList": "Audit",
                "allowedLinkedServiceResourceTypes": [
                    "AdlsGen2CosmosStructuredStream",
                    "AdobeExperiencePlatform",
                    "AdobeIntegration",
                    "AmazonRedshift",
                    "AmazonS3",
                    "AzureBlobFS",
                    "AzureBlobStorage",
                    "AzureDataExplorer",
                    "AzureDataLakeStore",
                    "AzureDataLakeStoreCosmosStructuredStream",
                    "AzureDataShare",
                    "AzureFileStorage",
                    "AzureKeyVault",
                    "AzureMariaDB",
                    "AzureMySql",
                    "AzurePostgreSql",
                    "AzureSearch",
                    "AzureSqlDatabase",
                    "AzureSqlDW",
                    "AzureSqlMI",
                    "AzureTableStorage",
                    "Cassandra",
                    "CommonDataServiceForApps",
                    "CosmosDb",
                    "CosmosDbMongoDbApi",
                    "Db2",
                    "DynamicsCrm",
                    "FileServer",
                    "FtpServer",
                    "GitHub",
                    "GoogleCloudStorage",
                    "Hdfs",
                    "Hive",
                    "HttpServer",
                    "Informix",
                    "Kusto",
                    "MicrosoftAccess",
                    "MySql",
                    "Netezza",
                    "Odata",
                    "Odbc",
                    "Office365",
                    "Oracle",
                    "PostgreSql",
                    "Salesforce",
                    "SalesforceServiceCloud",
                    "SapBw",
                    "SapHana",
                    "SapOpenHub",
                    "SapTable",
                    "Sftp",
                    "SharePointOnlineList",
                    "Snowflake",
                    "SqlServer",
                    "Sybase",
                    "Teradata",
                    "HDInsightOnDemand",
                    "HDInsight",
                    "AzureDataLakeAnalytics",
                    "AzureBatch",
                    "AzureFunction",
                    "AzureML",
                    "AzureMLService",
                    "MongoDb",
                    "GoogleBigQuery",
                    "Impala",
                    "ServiceNow",
                    "Dynamics",
                    "AzureDatabricks",
                    "AmazonMWS",
                    "SapCloudForCustomer",
                    "SapEcc",
                    "Web",
                    "MongoDbAtlas",
                    "HBase",
                    "Spark",
                    "Phoenix",
                    "PayPal",
                    "Marketo",
                    "Responsys",
                    "SalesforceMarketingCloud",
                    "Presto",
                    "Square",
                    "Xero",
                    "Jira",
                    "Magento",
                    "Shopify",
                    "Concur",
                    "Hubspot",
                    "Zoho",
                    "Eloqua",
                    "QuickBooks",
                    "Couchbase",
                    "Drill",
                    "Greenplum",
                    "MariaDB",
                    "Vertica",
                    "MongoDbV2",
                    "OracleServiceCloud",
                    "GoogleAdWords",
                    "RestService",
                    "DynamicsAX",
                    "AzureDataCatalog",
                    "AzureDatabricksDeltaLake"
                ],
                "gitrepositoryForSourceControl": "Audit",
                "integrationRuntimeMaxCores": "Audit",
                "maxCores": 32,
                "usePrivateLink": "AuditIfNotExists",
                "systemAssignedManagedIdentity": "Audit"
            }
        },
        "dataFactoryAuditDenySetName": {
            "value": "dataFactory.auditdeny.policy.set"
        },
        "dataFactoryAuditDenySetDisplayName": {
            "value": "dataFactory auditdeny policy set"
        },
        "dataFactoryAuditDenySetAssignmentName": {
            "value": "dataFactory.auditdeny.policy.set.assignment"
        },
        "dataFactoryAuditDenySetAssignmentDisplayName": {
            "value": "dataFactory auditdeny policy set assignment"
        },
        "policyMetadata": {
           "value": "EvidenELZ"
        }
    }
}
```