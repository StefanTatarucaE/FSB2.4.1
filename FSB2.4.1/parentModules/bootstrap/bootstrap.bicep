/*
SUMMARY: Bootstrap solution
DESCRIPTION: Parent module to deploy the Bootstrap solution.
             Consists of resource group, storage account & keyvault
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.6
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

// PARAMETERS
@description('Required. Specifies the location of the Monitoring solution resources.')
param location string = deployment().location

@description('Optional. A mapping of additional tags to assign to the resource.')
param additionalBootstrapTags object

// VARIABLES
//Variables to load in the naming convention files for resource naming.
var mgmtNaming = json(loadTextContent('../../mgmtNaming.json'))

/*Variables to determine which naming variables to use for the resource group &  related resources */
var resourceGroupName = mgmtNaming.bootstrapResourceGroup.name
var artifactStorageAccountName = mgmtNaming.artifactStorageAccount.name

// Variable to create a unique prefix seeded to the resource group, needed for consistency when redeploying the same template
var uniqueDeployPrefix = substring(uniqueString(bootstrapResourceGroup.id), 0, 6)

//Variables to load from the naming convention files for branding, tagging and resource naming.

var tagPrefix = mgmtNaming.tagPrefix.name
var productCode = mgmtNaming.productCode.name
var tagValuePrefix = mgmtNaming.tagValuePrefix.name
var tags = union(additionalBootstrapTags, { '${tagPrefix}Purpose': '${tagValuePrefix}Bootstrap' }, { '${tagPrefix}Managed': 'true' })

// Variable to hold the artificat container name
var artifactContainer = '${toLower(productCode)}-artifacts'

// Variable to load default ELZ Azure configuration. No need to expose via parameters in parent module.
var parentModuleConfig = loadJsonContent('parentModuleConfig.json')

// RESOURCE DEPLOYMENTS
//Create a resource group to hold the ITSM resources.
resource bootstrapResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

//Deploy the storageAccount used for artifacts
module artifactStorageAccount '../../childModules/storageAccount/storageAccount.bicep' = {
  scope: bootstrapResourceGroup
  name: '${uniqueDeployPrefix}-storageAccount-deployment'
  params: {
    storageAccountName: artifactStorageAccountName
    location: location
    tags: tags
    kind: parentModuleConfig.kind
    sku: parentModuleConfig.sku
    accessTier: parentModuleConfig.accessTier
    allowBlobPublicAccess: parentModuleConfig.allowBlobPublicAccess
    networkAcls: parentModuleConfig.networkAcls
    changeFeed: parentModuleConfig.changeFeed
    blobSvcDeleteRetentionPolicy: parentModuleConfig.blobSvcDeleteRetentionPolicy
    shouldCreateContainers: parentModuleConfig.shouldCreateContainers
    containerNames: [  {
        containerName: artifactContainer
        containerAccess: 'None'
      }  ]
  }
}

// OUTPUTS
