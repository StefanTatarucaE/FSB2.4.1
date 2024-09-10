/*
SUMMARY: VM OS Management solution
DESCRIPTION: Parent module to deploy the VM OS Management solution.
             Consists of Azure Update Manager Maintenance Configurations (aka 'patch schedules'),
             Custom Image structure & organization for VMs,
             OS Version information provided via Tag ,
             Backups for VMs &
             Disk Encryption for VMs functionality.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.8
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

// PARAMETERS
@description('Required. Specifies the location of the Monitoring solution resources.')
param location string = deployment().location

@description('Parameter to determine the subscription using abbreviation. To be provided by the pipeline')
@allowed([ 'mgmt', 'lndz', 'tool' ])
param subscriptionType string

@description('Specifies if the OS Update Management component is to be deployed.')
param deployUpdateManager bool = false

@description('Specifies if the Custom Image structure & organization for VMs component is to be deployed.')
param deployComputeGallery bool = false

@description('Specifies if the Backups for VMs component is to be deployed.')
param deployRecoveryServicesVault bool = false

@description('Specifies if the Disk encryption for VMs component is to be deployed.')
param deployDiskEncryption bool = false

@description('Specifies a mapping of tags to assign to resources of the OS Update management component.')
param additionalUpdateManagerTags object = {}

@description('Specifies the JSON structure used to specify the patch schedules to be created.')
param maintenanceConfigurations array = []

@description('Specifies a mapping of additional tags to assign to resources of the OS Version information provided via Tag component.')
param additionalOsTaggingTags object = {}

@description('Description for the Compute Gallery.')
param computeGalleryDescription string = ''

@description('Specifies a mapping of additional tags to assign to resources of the Custom Image structure & organization for VM component.')
param additionalComputeGalleryTags object = {}

@description('Specifies a mapping of additional tags to assign to resources of the Backups for VMs component.')
param additionalRecoveryServicesVaultTags object = {}

@description('Specifies the JSON structure used to specify the backup policy configuration to be created.')
param backupPolicyConfigurations object = {}

@description('Enable disk encryption set auto-updating to the latest key version.')
param diskEncryptionKeyRotationEnabled bool = false

@description('Disk encryption Keyvault Key object for configuration properties related to key enablement, size & type.')
param diskEncryptionKeyVaultKeyConfig object = {}

@description('Locations where disk encryption solution will be deployed')
param diskEncryptionDeploymentRegions array = []

@description('Specifies a mapping of additional tags to assign to resources of the Disk encryption for VMs component.')
param additionalDiskEncryptionTags object = {}

@description('Specifies a mapping of additional tags to assign to resources of the patch schedules.')
param additionalmaintenanceConfigurationsTags object = {}

@description('Specifies the current time when the parent runs which is later used to calculate the start of the maintenance configuration.')
param currentTime string = utcNow('u')

// VARIABLES

// Variables to load in the naming convention files for resource naming.
var namingJsonData = {
  mgmt: {
    definition: json(loadTextContent('../../mgmtNaming.json'))
  }
  cnty: {
    definition: json(loadTextContent('../../cntyNaming.json'))
  }
  lndz: {
    definition: json(loadTextContent('../../lndzNaming.json'))
  }
  tool: {
    definition: json(loadTextContent('../../toolNaming.json'))
  }
}
var namingData = namingJsonData[subscriptionType].definition

// Regioncodes for Azure locations
var azureRegionMap = namingData.azureRegions

// placeholder for Regioncode
var azureRegionCodePlaceholder = namingData.RegionCodePlaceholder

// Variable to load default Azure configuration. No need to expose via parameters in parent module.
var parentModuleConfigMgmt = loadJsonContent('parentModuleConfig.json', 'management')
var parentModuleConfigLndz = loadJsonContent('parentModuleConfig.json', 'landingzone')

// Variables holding the values for names from the naming module
// To prevent issues with template validation of this parentmodule when there are identical resourcegroups used in different subscriptions, resourcegroupnames get a unique (dummy) name 
// in the case the resourcegroup will not be created (for the subscriptiontype that passed as a parameter to this parentmodule).
var computeGalleryResourceGroupName = (subscriptionType == 'mgmt') ? namingData.computeGalleryResourceGroup.name : uniqueString(subscription().id, namingData.computeGalleryResourceGroup.name)
var osTaggingFunctionAppResourceGroupName = (subscriptionType == 'mgmt') ? namingData.osTaggingResourceGroup.name : uniqueString(subscription().id, namingData.osTaggingResourceGroup.name)
var updateManagerResourceGroupName = (subscriptionType == 'mgmt') ? namingData.customerUpdateManagerResourceGroup.name : uniqueString(subscription().id, namingData.customerUpdateManagerResourceGroup.name)

var recoveryVaultResourceGroupName = ((subscriptionType == 'lndz') || (subscriptionType == 'tool')) ? namingData.landingZoneRecoveryServicesVaultResourceGroup.name : uniqueString(subscription().id, namingData.landingZoneRecoveryServicesVaultResourceGroup.name)
var diskEncryptionResourceGroupName = ((subscriptionType == 'lndz') || (subscriptionType == 'tool')) ? namingData.diskEncryptionResourceGroup.name : uniqueString(subscription().id, namingData.diskEncryptionResourceGroup.name)

var recoveryServicesVaultName = namingData.landingZoneRecoveryServicesVault.name
var backupPolicyDefinitionAssignmentName = namingData.backupChangePolicy.backupDefAssignmentName
var backupPolicyDefinitionName = namingData.backupChangePolicy.backupDefName

var diskEncryptionKeyVaultName = [for encryptionLocation in diskEncryptionDeploymentRegions: '${replace(namingData.diskEncryptionKeyVault.name, azureRegionCodePlaceholder, azureRegionMap[encryptionLocation].regionCode)}']
var diskEncryptionKeyVaultKeyName = [for encryptionLocation in diskEncryptionDeploymentRegions: '${replace(namingData.diskEncryptionKeyVaultKey.name, azureRegionCodePlaceholder, azureRegionMap[encryptionLocation].regionCode)}']
var diskEncryptionSetName = [for encryptionLocation in diskEncryptionDeploymentRegions: '${replace(namingData.diskEncryptionSet.name, azureRegionCodePlaceholder, azureRegionMap[encryptionLocation].regionCode)}']

var computeGalleryStorageAccountName = namingData.computeGalleryStorageAccount.name
var computeGalleryName = namingData.computeGallery.name

var osTaggingStorageAccountName = namingData.osTaggingFuncStorageAccount.name
var osTaggingAppServicePlanName = namingData.osTaggingFuncAppServicePlan.name
var osTaggingAppInsightsName = namingData.osTaggingFuncApplicationInsights.name
var osTaggingAppServiceName = namingData.osTaggingFuncApp.name

//Variables to load from the naming convention files for branding, tagging and resource naming.
var tagPrefix = namingData.tagPrefix.name
var tagValuePrefix = namingData.tagValuePrefix.name

//tag used for backup policy.
var managedTag = '${namingData.tagPrefix.name}Managed'
var policyMeteringTag = '${namingData.company.name}${namingData.productCode.name}'
var backupTagName = '${namingData.tagPrefix.name}Backup'

// Variables holding tagging values using input from params files
var joinedOsTaggingTags = union(additionalOsTaggingTags, { '${tagPrefix}Purpose': '${tagValuePrefix}OsTagging' }, { '${tagPrefix}Managed': 'true' })
var joinedUpdateManagerTags = union(additionalUpdateManagerTags, { '${tagPrefix}Purpose': '${tagValuePrefix}UpdateManager' }, { '${tagPrefix}Managed': 'true' })
var joinedRecoveryServicesVaultTags = union(additionalRecoveryServicesVaultTags, { '${tagPrefix}Purpose': '${tagValuePrefix}RecoveryServicesVault' }, { '${tagPrefix}Managed': 'true' })
var joinedDiskEncryptionTags = union(additionalDiskEncryptionTags, { '${tagPrefix}Purpose': '${tagValuePrefix}DiskEncryption' }, { '${tagPrefix}Managed': 'true' })
var joinedComputeGalleryTags = union(additionalComputeGalleryTags, { '${tagPrefix}Purpose': '${tagValuePrefix}SharedImageGallery' }, { '${tagPrefix}Managed': 'true' })
var joinedMaintenancecheduleTag = union(additionalmaintenanceConfigurationsTags, { '${tagPrefix}Purpose': '${tagValuePrefix}MaintenanceConfig' }, { '${tagPrefix}Managed': 'true' })

// Tagging specific to the functionApp AppService
// Needed to target for eventgrid subscription creation
var osTaggingAppServiceTags = union(additionalOsTaggingTags, { '${tagPrefix}Purpose': 'FuncOsTagging' }, { '${tagPrefix}Managed': 'true' })

#disable-next-line no-loc-expr-outside-params
var uniqueDeployPrefix = take(uniqueString(subscription().subscriptionId, deployment().location), 6)

// Create array of dynamic parameters that will be added to static paramaters for the os-tagging function-app
var osTaggingAppServiceAdditionalProperties = [
  {
    name: 'COMPANY_TAG_PREFIX'
    value: '${namingData.tagPrefix.name}'
  }
]

// variable needed to create the start time for the Maintenance Configuration
var shortDate = substring(dateTimeAdd(currentTime, 'P1D'), 0, 10)

// Create final array of properties for os-tagging function-app
var osTaggingAppServiceProperties = union(parentModuleConfigMgmt.osTaggingAppServiceProperties, osTaggingAppServiceAdditionalProperties)

// RESOURCE DEPLOYMENTS

// Reference the Update Manager Resource Group if deploying to mgmt & update management boolean is set to true
resource updateManagerAutomationResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if ((subscriptionType == 'mgmt') && deployUpdateManager) {
  name: updateManagerResourceGroupName
  location: location
  tags: joinedUpdateManagerTags
}

// Create the Compute Gallery Resource Group if deploying to mgmt & compute gallery boolean is set to true
resource computeGalleryResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if ((subscriptionType == 'mgmt') && deployComputeGallery) {
  name: computeGalleryResourceGroupName
  location: location
  tags: joinedComputeGalleryTags
}

// Create a resource group to hold all OS Tagging resources if deploying to mgmt.
resource osTaggingFunctionAppResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (subscriptionType == 'mgmt') {
  name: osTaggingFunctionAppResourceGroupName
  location: location
  tags: joinedOsTaggingTags
}

// Create the RecoveryServices Vault Resource Group if deploying to lndz & recovery services vault boolean is set to true
resource recoveryServicesVaultResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployRecoveryServicesVault) {
  name: recoveryVaultResourceGroupName
  location: location
  tags: joinedRecoveryServicesVaultTags
}

// Create the Disk Encryption Resource Group if deploying to lndz & disk encryption boolean is set to true
resource diskEncryptionResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) {
  name: diskEncryptionResourceGroupName
  location: location
  tags: joinedDiskEncryptionTags
}

// Deploy the Azure Update Manager related resources
module maintenanceConfiguration '../../childModules/maintenanceConfigurations/maintenanceConfigurations.bicep' = [for maintenanceConfiguration in maintenanceConfigurations: if ((subscriptionType == 'mgmt') && deployUpdateManager) {
  scope: updateManagerAutomationResourceGroup
  name: '${maintenanceConfiguration.maintenanceConfigurationName}-maintenanceConfig-deployment'
  params: {
    maintenanceConfigurationName: maintenanceConfiguration.maintenanceConfigurationName
    location: location
    maintenanceConfigurationTag: joinedMaintenancecheduleTag
    linuxUpdateClassificationsToInclude: maintenanceConfiguration.installPatches.linuxParameters.classificationsToInclude
    linuxUpdatePackageNameMasksToExclude: maintenanceConfiguration.installPatches.linuxParameters.packageNameMasksToExclude
    linuxUpdatePackageNameMasksToInclude: maintenanceConfiguration.installPatches.linuxParameters.packageNameMasksToInclude
    updateRebootSetting: maintenanceConfiguration.installPatches.rebootSetting
    windowsUpdateClassificationsToInclude: maintenanceConfiguration.installPatches.windowsParameters.classificationsToInclude
    windowsExcludeKbsRequiringReboot: maintenanceConfiguration.installPatches.windowsParameters.excludeKbsRequiringReboot
    windowsKbNumbersToExclude: maintenanceConfiguration.installPatches.windowsParameters.kbNumbersToExclude
    windowsKbNumbersToInclude: maintenanceConfiguration.installPatches.windowsParameters.kbNumbersToInclude
    maintenanceWindowDuration: maintenanceConfiguration.maintenanceWindow.duration
    maintenanceScope: parentModuleConfigMgmt.maintenanceScope
    maintenanceWindowExpirationDateTime: maintenanceConfiguration.maintenanceWindow.expirationDateTime
    maintenanceWindowRecurEvery: maintenanceConfiguration.maintenanceWindow.recurEvery
    maintenanceWindowStartTime: '${shortDate} ${maintenanceConfiguration.maintenanceWindow.startTime}'
    maintenanceWindowTimeZone: maintenanceConfiguration.maintenanceWindow.timeZone
  }
}]

// Deploy the Compute Gallery related resources
module computeGalleryStorageAccount '../../childModules/storageAccount/storageAccount.bicep' = if ((subscriptionType == 'mgmt') && deployComputeGallery) {
  scope: computeGalleryResourceGroup
  name: '${uniqueDeployPrefix}-computeImageGalleryStorageAccount-deployment'
  params: {
    storageAccountName: computeGalleryStorageAccountName
    location: location
    tags: joinedComputeGalleryTags
    kind: parentModuleConfigMgmt.computeGalleryStorageAccountKind
    sku: parentModuleConfigMgmt.computeGalleryStorageAccountSku
    accessTier: parentModuleConfigMgmt.computeGalleryStorageAccountAccessTier
    allowBlobPublicAccess: parentModuleConfigMgmt.computeGalleryStorageAccountAllowBlobPublicAccess
    networkAcls: parentModuleConfigMgmt.computeGalleryStorageAccountNetworkAcls
    changeFeed: parentModuleConfigMgmt.computeGalleryStorageAccountChangeFeed
    blobSvcDeleteRetentionPolicy: parentModuleConfigMgmt.computeGalleryStorageAccountBlobSvcDeleteRetentionPolicy
    shouldCreateContainers: parentModuleConfigMgmt.computeGalleryStorageAccountShouldCreateContainers
    containerNames: parentModuleConfigMgmt.computeGalleryStorageAccountArtifactContainerNames
  }
}

module computeGallery '../../childModules/computeGallery/computeGallery.bicep' = if ((subscriptionType == 'mgmt') && deployComputeGallery) {
  scope: computeGalleryResourceGroup
  name: '${uniqueDeployPrefix}-computeImageGallery-deployment'
  params: {
    computeGalleryName: computeGalleryName
    location: location
    tags: joinedComputeGalleryTags
    computeGalleryDescription: computeGalleryDescription
  }
}

// Deploy the OSTagging FunctionApp related resources
module osTaggingFunctionAppStorageAccount '../../childModules/storageAccount/storageAccount.bicep' = if (subscriptionType == 'mgmt') {
  scope: osTaggingFunctionAppResourceGroup
  name: '${uniqueDeployPrefix}-osTaggingStorageAccount-deployment'
  params: {
    storageAccountName: osTaggingStorageAccountName
    location: location
    tags: joinedOsTaggingTags
    kind: parentModuleConfigMgmt.osTaggingStorageAccountKind
    sku: parentModuleConfigMgmt.osTaggingStorageAccountSku
    accessTier: parentModuleConfigMgmt.osTaggingStorageAccountAccessTier
    allowBlobPublicAccess: parentModuleConfigMgmt.osTaggingStorageAccountAllowBlobPublicAccess
    networkAcls: parentModuleConfigMgmt.osTaggingStorageAccountNetworkAcls
    changeFeed: parentModuleConfigMgmt.osTaggingStorageAccountChangeFeed
    blobSvcDeleteRetentionPolicy: parentModuleConfigMgmt.osTaggingStorageAccountBlobSvcDeleteRetentionPolicy
  }
}

module osTaggingFunctionApp '../../childModules/functionApp/functionApp.bicep' = if (subscriptionType == 'mgmt') {
  scope: osTaggingFunctionAppResourceGroup
  name: '${uniqueDeployPrefix}-osTaggingFunctionApp-deployment'
  params: {
    location: location
    tags: joinedOsTaggingTags
    appServiceStorageName: osTaggingStorageAccountName
    appServicePlanName: osTaggingAppServicePlanName
    appServicePlanSku: parentModuleConfigMgmt.osTaggingAppServicePlanConfig.sku
    appServicePlanKind: parentModuleConfigMgmt.osTaggingAppServicePlanConfig.kind
    appInsightsName: osTaggingAppInsightsName
    appInsightsKind: parentModuleConfigMgmt.osTaggingAppInsightsConfig.kind
    appInsightsProperties: parentModuleConfigMgmt.osTaggingAppInsightsConfig.properties
    appServiceName: osTaggingAppServiceName
    appServiceTags: osTaggingAppServiceTags
    appServiceKind: parentModuleConfigMgmt.osTaggingAppServiceKind
    appServiceProperties: osTaggingAppServiceProperties
    appServiceSiteConfig: parentModuleConfigMgmt.osTaggingAppServiceSiteConfig
    appServiceClientAffinityEnabled: parentModuleConfigMgmt.osTaggingAppServiceConfig.clientAffinityEnabled
    appServiceClientCertEnabled: parentModuleConfigMgmt.osTaggingAppServiceConfig.clientCertEnabled
    appServiceHttpsOnly: parentModuleConfigMgmt.osTaggingAppServiceConfig.httpsOnly
  }
  dependsOn: [
    osTaggingFunctionAppStorageAccount
  ]
}

// Deploy the VM OS Backup related resources
module recoveryServicesVault '../../childModules/recoveryServicesVault/recoveryServicesVault.bicep' = if (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployRecoveryServicesVault) {
  scope: recoveryServicesVaultResourceGroup
  name: '${uniqueDeployPrefix}-recoveryServicesVault-deployment'
  params: {
    recoveryServicesVaultName: recoveryServicesVaultName
    location: location
    tags: joinedRecoveryServicesVaultTags
    backupStorageType: parentModuleConfigLndz.backupStorageConfig.storageType
    storageTypeState: parentModuleConfigLndz.backupStorageConfig.storageTypeState
    backupPolicyConfigurations: backupPolicyConfigurations
  }
}

module backupPolicy '../../childModules/policy/backupChange/backupChange.bicep' = if (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployRecoveryServicesVault) {
  name: '${uniqueDeployPrefix}-backup-policy-deployment'
  params: {
    backupTagName: backupTagName
    managedTagName: managedTag
    policyMetadata: policyMeteringTag
    backupPolicyConfigurations: backupPolicyConfigurations
    vaultLocation: (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployRecoveryServicesVault) ? recoveryServicesVault.outputs.vaultLocation : ''
    vaultId: (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployRecoveryServicesVault) ? recoveryServicesVault.outputs.vaultID : ''
    backupDefAssignmentName: backupPolicyDefinitionAssignmentName
    backupDefName: backupPolicyDefinitionName
  }
}

// Deploy the Disk Encryption related resources
module diskEncryptionKeyVault '../../childModules/keyVault/keyVault.bicep' = [for (encryptionLocation, i) in diskEncryptionDeploymentRegions: if (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) {
  scope: diskEncryptionResourceGroup
  name: '${uniqueDeployPrefix}-diskEncryptionKeyVault-${encryptionLocation}-deployment'
  params: {
    keyVaultName: diskEncryptionKeyVaultName[i]
    location: encryptionLocation
    tags: joinedDiskEncryptionTags
    skuName: parentModuleConfigLndz.diskEncryptionKeyVaultConfig.skuName
    softDeleteRetentionInDays: parentModuleConfigLndz.diskEncryptionKeyVaultConfig.softDeleteRetentionInDays
    publicNetworkAccess: parentModuleConfigLndz.diskEncryptionKeyVaultConfig.publicNetworkAccess
    networkRuleBypassOptions: parentModuleConfigLndz.diskEncryptionKeyVaultConfig.networkRuleBypassOptions
    networkRuleAction: parentModuleConfigLndz.diskEncryptionKeyVaultConfig.networkRuleAction
    keyVaultFeatures: parentModuleConfigLndz.diskEncryptionkeyVaultFeatures
  }
}]

module diskEncryptionKeyVaultKey '../../childModules/keyVaultKey/keyVaultKey.bicep' = [for (encryptionLocation, i) in diskEncryptionDeploymentRegions: if (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) {
  scope: diskEncryptionResourceGroup
  name: '${uniqueDeployPrefix}-diskEncryptionKeyVaultKey-${encryptionLocation}-deployment'
  params: {
    keyVaultName: (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) ? diskEncryptionKeyVault[i].outputs.keyVaultName : ''
    keyVaultKeyName: diskEncryptionKeyVaultKeyName[i]
    keyVaultKeyEnabled: parentModuleConfigLndz.diskEncryptionKeyVaultKeyConfig.keyEnabled
    keyVaultKeySize: parentModuleConfigLndz.diskEncryptionKeyVaultKeyConfig.keySize
    keyVaultKeyType: parentModuleConfigLndz.diskEncryptionKeyVaultKeyConfig.keyType
    keyVaultKeyRotationPolicy: contains(diskEncryptionKeyVaultKeyConfig, 'keyVaultKeyRotationPolicy') ? diskEncryptionKeyVaultKeyConfig.keyVaultKeyRotationPolicy : {}
  }
}]

module diskEncryptionKeyVaultAccessPolicy '../../childModules/keyVaultAccessPolicy/keyVaultAccessPolicy.bicep' = [for (encryptionLocation, i) in diskEncryptionDeploymentRegions: if (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) {
  name: '${uniqueDeployPrefix}-diskEncryptionKVAccessPolicy-${encryptionLocation}-deployment'
  scope: diskEncryptionResourceGroup
  params: {
    keyVaultName: (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) ? diskEncryptionKeyVault[i].outputs.keyVaultName : ''
    accessPoliciesAdd: [
      {
        objectId: (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) ? diskEncryptionSet[i].outputs.diskEncryptionSetPrincipalId : ''
        permissions: {
          keys: [
            'Get'
            'WrapKey'
            'UnwrapKey'
          ]
        }
      }
    ]
  }
}]
module diskEncryptionSet '../../childModules/diskEncryptionSet/diskEncryptionSet.bicep' = [for (encryptionLocation, i) in diskEncryptionDeploymentRegions: if (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) {
  scope: diskEncryptionResourceGroup
  name: '${uniqueDeployPrefix}-diskEncryptionSet-${encryptionLocation}-deployment'
  params: {
    diskEncryptionSetName: diskEncryptionSetName[i]
    location: encryptionLocation
    tags: joinedDiskEncryptionTags
    keyVaultName: (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) ? diskEncryptionKeyVault[i].outputs.keyVaultName : ''
    keyName: (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) ? diskEncryptionKeyVaultKey[i].outputs.keyVaultKeyName : ''
    keyRotationEnabled: false
  }
}]

module diskEncryptionSetKeyRotationEnabled '../../childModules/diskEncryptionSet/diskEncryptionSet.bicep' = [for (encryptionLocation, i) in diskEncryptionDeploymentRegions: if (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption && diskEncryptionKeyRotationEnabled) {
  scope: diskEncryptionResourceGroup
  name: 'diskEncryptionSet-${encryptionLocation}-key-rotation-deployment'
  params: {
    diskEncryptionSetName: diskEncryptionSetName[i]
    location: encryptionLocation
    tags: joinedDiskEncryptionTags
    keyVaultName: (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) ? diskEncryptionKeyVault[i].outputs.keyVaultName : ''
    keyName: (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) ? diskEncryptionKeyVaultKey[i].outputs.keyVaultKeyName : ''
    keyRotationEnabled: (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deployDiskEncryption) ? diskEncryptionKeyRotationEnabled : false
  }
  dependsOn: [
    diskEncryptionKeyVaultAccessPolicy
    diskEncryptionSet
  ]
}]

// OUTPUTS
