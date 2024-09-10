/*
SUMMARY: Automation solution
DESCRIPTION: Parent module to deploy the automation solution. Consists of automation account and uploading runbooks
AUTHOR/S: klaasjan.dejager@eviden.com
VERSION: 0.7
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

// PARAMETERS
@description('Required. Specifies the location of the Automation solution resources.')
param location string = deployment().location

@description('A mapping of tags to assign to the resource.')
param additionalAutomationTags object

@description('Specify the type of deployment. Allowed values are config and deploy.')
@metadata({
  displayName: 'Use deploy to create automation account. Use config to upload runbooks in automation account'
})
@allowed([
  'deploy'
  'config'
])
param deploymentType string

@description('Specify the type of artifacts to upload in automation account.')
@metadata({
  displayName: 'This parameter is mandatory when deploymentType is config'
})
@allowed([
    'core'
    'os-mgmt'
    'paas-mgmt'
    'monitoring-core'
  ]
)
param typeOfArtifacts string = 'core' // The default value is set to make this parameter optional, when deploymentType is 'deploy'. If the deploymentType is 'config' this parameter is mandatory.

@description('Specifies the Timezone where runbook schedules are displayed')
param artifactsTimeZone string = 'Europe/Amsterdam'

// VARIABLES
//Variables to load in the naming convention files for branding and resource naming.
var mgmtNaming = json(loadTextContent('../../mgmtNaming.json'))
var mgmtResourceGroupName = mgmtNaming.customerAutomationResourceGroup.name
var mgmtAutomationAccountName = mgmtNaming.customerAutomationAccount.name
var storageAccResourceGroupName = mgmtNaming.bootstrapResourceGroup.name
var storageAccountName = mgmtNaming.artifactStorageAccount.name
var companyName = mgmtNaming.company.name
//var productName = mgmtNaming.product.name
var productCode = mgmtNaming.productCode.name
var tagPrefix = mgmtNaming.tagPrefix.name
var tagValuePrefix = mgmtNaming.tagValuePrefix.name
var tags = union(additionalAutomationTags,{ '${tagPrefix}Purpose': '${tagValuePrefix}Automation' }, {'${tagPrefix}Managed': 'true'})

var rbacAutomationAccountMsiRoles = [
  'Reader'
  'Automation Operator'
]

// Variable to create a unique prefix seeded to the resource group, needed for consistency when redeploying the same template
#disable-next-line no-loc-expr-outside-params
var uniqueDeployPrefix = substring(uniqueString(automationResourceGroup.id, deployment().location), 0, 6)

// Variable to load runbook details depending on type of artifact
var artifactsJson = {
  core: {
    json: loadJsonContent('../../childModules/automationAccountArtifacts/core.params.json')
  }
  'os-mgmt': {
    json: loadJsonContent('../../childModules/automationAccountArtifacts/osMgmt.params.json')
  }
  'paas-mgmt': {
    json: loadJsonContent('../../childModules/automationAccountArtifacts/paasMgmt.params.json')
  }
  'monitoring-core': {
    json: loadJsonContent('../../childModules/automationAccountArtifacts/monitoring.core.params.json')
  }
}

// Variable to load default ELZ Azure configuration. No need to expose via parameters in parent module.
var parentModuleConfig = loadJsonContent('parentModuleConfig.json')

// RESOURCE DEPLOYMENTS
//Create a resource group to hold the automation resources.
resource automationResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (deploymentType == 'deploy') {
  name: mgmtResourceGroupName
  location: location
  tags: tags
}

//Deploy the automationAccount for automation (with System assigned identity enabled)
module automationAutomationAccount '../../childModules/automationAccount/automationAccount.bicep' = if (deploymentType == 'deploy') {
  scope: automationResourceGroup
  name: '${uniqueDeployPrefix}-automationAutomationAccount-deployment'
  params: {
    automationAccountName: mgmtAutomationAccountName
    location: location
    skuName: parentModuleConfig.automationAccountSkuName
    tags: tags
    systemAssignedIdentity: true
    userAssignedIdentities: {}
    mgmtNaming: mgmtNaming
  }
}

//Deploy the Role assignment for the Automation account MSI
//We only give limited permissions for now, because runbooks needs to be able to connect to the subscription soon after creation.
//More permissions will be given to this MSI during the pipeline final step
module automationAccountRoleAssignment '../../childModules/roleAssignment/roleAssignment.bicep' = if (deploymentType == 'deploy') {
  name: '${uniqueDeployPrefix}-roleAssignment-automationAccountMsi'
  params: {
    managedIdentityId: automationAutomationAccount.outputs.AutomationAccManagedIdentityPrincipalId
    roleDefinitionIdOrNames: rbacAutomationAccountMsiRoles
  }
}

// Configure runbooks , schedule and webhook on automation account
module automationArtifacts '../../childModules/automationAccountArtifacts/automationAccountArtifacts.bicep' = if (deploymentType == 'config') {
  scope: automationResourceGroup
  name: '${uniqueDeployPrefix}-automationArtifacts-${typeOfArtifacts}-deployment'
  params: {
    location: automationResourceGroup.location
    productCode:productCode
    company:companyName
    artifactStorageAccount: storageAccountName
    runbooks: artifactsJson[typeOfArtifacts].json.parameters.runbooks.value
    artifactStorageAccountResourceGroup: storageAccResourceGroupName
    modules: artifactsJson[typeOfArtifacts].json.parameters.modules.value
    automationAccountName: mgmtAutomationAccountName
    timeZone: artifactsTimeZone
  }
}

// OUTPUTS
output automationResourceGroupName string = automationResourceGroup.name
output automationResourceGroupResourceId string = automationResourceGroup.id
output customerAutomationAccountName string = automationAutomationAccount.outputs.automationAccountName
