/*
SUMMARY: dataFactory Audit/Deny Policy child module.
DESCRIPTION: Deployment of dataFactory Audit/Deny Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param dataFactorySettings object

@description('Specify set name for datafactory audit deny initiative')
param dataFactoryAuditDenySetName string

@description('Specify set displayname for datafactory audit deny initiative')
param dataFactoryAuditDenySetDisplayName string

@description('Specify set assignment name for datafactory audit deny initiative')
param dataFactoryAuditDenySetAssignmentName string

@description('Specify set assignment displayname for datafactory audit deny initiative')
param dataFactoryAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variable for allowedValues which is the same for all policy set definition parameters.
var allowedValues = [
  'Audit'
  'Deny'
  'Disabled'
]

// Variable for allowedLinkedResourceTypes which can be used in built-in policy 6809a3d0-d354-42fb-b955-783d207c62a8

var allowedLinkedResourceTypes = [
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

//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This policy set configures governance and security policies to Azure Data Factory'
  metadata: {
    category: 'Monitoring'
    source: policyMetadata
    version: '0.0.1'
  }
}

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Azure Data Factory has relevant governance and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

// RESOURCE DEPLOYMENTS
//Deploy the policy definition set for the definitions created in previous resource block
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: dataFactoryAuditDenySetName
  properties: {
    displayName: dataFactoryAuditDenySetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      sqlserverIntegrationJoinVn: {
        type: 'String'
        metadata: {
          description: 'Azure Virtual Network deployment provides enhanced security and isolation for your SQL Server Integration Services integration runtimes on Azure Data Factory, as well as subnets, access control policies, and other features to further restrict access.'
          displayName: 'sqlserverIntegrationJoinVn'
        }
        allowedValues: allowedValues
      }
      keyvaultForStoringSecrets: {
        type: 'String'
        metadata: {
          description: 'To ensure secrets (such as connection strings) are managed securely, require users to provide secrets using an Azure Key Vault instead of specifying them inline in linked services.'
          displayName: 'keyvaultForStoringSecrets'
        }
        allowedValues: allowedValues
      }
      disablePublicNetworkAccess: {
        type: 'String'
        metadata: {
          description: 'Disabling the public network access property improves security by ensuring your Azure Data Factory can only be accessed from a private endpoint.'
          displayName: 'disablePublicNetworkAccess'
        }
        allowedValues: allowedValues
      }
      encryptWithCustomerManagedKey: {
        type: 'String'
        metadata: {
          description: 'To ensure secrets (such as connection strings) are managed securely, require users to provide secrets using an Azure Key Vault instead of specifying them inline in linked services.'
          displayName: 'encryptWithCustomerManagedKey'
        }
        allowedValues: allowedValues
      }
      resourceTypeInAllowList: {
        type: 'String'
        metadata: {
          description: 'Define the allow list of Azure Data Factory linked service types. Restricting allowed resource types enables control over the boundary of data movement. For example, restrict a scope to only allow blob storage with Data Lake Storage Gen1 and Gen2 for analytics or a scope to only allow SQL and Kusto access for real-time queries.'
          displayName: 'resourceTypeInAllowList'
        }
        allowedValues: allowedValues
      }

      allowedLinkedServiceResourceTypes: {
        type: 'Array'
        metadata: {
          description: 'The list of allowed linked service resource types.'
          displayName: 'allowedLinkedServiceResourceTypes'
        }
        allowedValues: allowedLinkedResourceTypes
      }

      gitrepositoryForSourceControl: {
        type: 'String'
        metadata: {
          description: 'Enable source control on data factories, to gain capabilities such as change tracking, collaboration, continuous integration, and deployment.'
          displayName: 'gitrepositoryForSourceControl'
        }
        allowedValues: allowedValues
      }
      integrationRuntimeMaxCores: {
        type: 'String'
        metadata: {
          description: 'To manage your resources and costs, limit the number of cores for an integration runtime.'
          displayName: 'integrationRuntimeMaxCores'
        }
        allowedValues: allowedValues
      }
      maxCores: {
        type: 'Integer'
        metadata: {
          description: 'The max number of cores allowed for dataflow.'
          displayName: ' maxCores'
        }
      }
      usePrivateLink: {
        type: 'String'
        metadata: {
          description: 'Azure Private Link lets you connect your virtual network to Azure services without a public IP address at the source or destination. The Private Link platform handles the connectivity between the consumer and services over the Azure backbone network. By mapping private endpoints to Azure Data Factory, data leakage risks are reduced. Learn more about private links at: https://docs.microsoft.com/azure/data-factory/data-factory-private-link.'
          displayName: 'usePrivateLink'
        }
        allowedValues: [
          'AuditIfNotExists'
          'Disabled'
        ]
      }
      systemAssignedManagedIdentity: {
        type: 'String'
        metadata: {
          description: 'Using system-assigned managed identity when communicating with data stores via linked services avoids the use of less secured credentials such as passwords or connection strings.'
          displayName: 'systemAssignedManagedIdentity'
        }
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0088bc63-6dee-4a9c-9d29-91cfdc848952'
        parameters: {
          effect: {
            value: '[parameters(\'sqlserverIntegrationJoinVn\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/127ef6d7-242f-43b3-9eef-947faf1725d0'
        parameters: {
          effect: {
            value: '[parameters(\'keyvaultForStoringSecrets\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1cf164be-6819-4a50-b8fa-4bcaa4f98fb6'
        parameters: {
          effect: {
            value: '[parameters(\'disablePublicNetworkAccess\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/4ec52d6d-beb7-40c4-9a9e-fe753254690e'
        parameters: {
          effect: {
            value: '[parameters(\'encryptWithCustomerManagedKey\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/6809a3d0-d354-42fb-b955-783d207c62a8'
        parameters: {
          effect: {
            value: '[parameters(\'resourceTypeInAllowList\')]'
          }
          allowedLinkedServiceResourceTypes: {
            value: '[parameters(\'allowedLinkedServiceResourceTypes\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/77d40665-3120-4348-b539-3192ec808307'
        parameters: {
          effect: {
            value: '[parameters(\'gitrepositoryForSourceControl\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/85bb39b5-2f66-49f8-9306-77da3ac5130f'
        parameters: {
          effect: {
            value: '[parameters(\'integrationRuntimeMaxCores\')]'
          }
          maxcores: {
            value: '[parameters(\'maxCores\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/8b0323be-cc25-4b61-935d-002c3798c6ea'
        parameters: {
          effect: {
            value: '[parameters(\'usePrivateLink\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/f78ccdb4-7bf4-4106-8647-270491d2978a'
        parameters: {
          effect: {
            value: '[parameters(\'systemAssignedManagedIdentity\')]'
          }
        }
      }
    ]
  }
}

//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: dataFactoryAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: dataFactoryAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      sqlserverIntegrationJoinVn: {
        value: dataFactorySettings.sqlserverIntegrationJoinVn
      }
      keyvaultForStoringSecrets: {
        value: dataFactorySettings.keyvaultForStoringSecrets
      }
      disablePublicNetworkAccess: {
        value: dataFactorySettings.disablePublicNetworkAccess
      }
      encryptWithCustomerManagedKey: {
        value: dataFactorySettings.encryptWithCustomerManagedKey
      }
      resourceTypeInAllowList: {
        value: dataFactorySettings.resourceTypeInAllowList
      }
      allowedLinkedServiceResourceTypes: {
        value: dataFactorySettings.allowedLinkedServiceResourceTypes
      }
      gitrepositoryForSourceControl: {
        value: dataFactorySettings.gitrepositoryForSourceControl
      }
      integrationRuntimeMaxCores: {
        value: dataFactorySettings.integrationRuntimeMaxCores
      }
      maxCores: {
        value: dataFactorySettings.maxCores
      }
      usePrivateLink: {
        value: dataFactorySettings.usePrivateLink
      }
      systemAssignedManagedIdentity: {
        value: dataFactorySettings.systemAssignedManagedIdentity
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
}

// OUTPUTS
