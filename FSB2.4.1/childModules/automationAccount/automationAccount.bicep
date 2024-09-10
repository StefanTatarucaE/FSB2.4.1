/*
SUMMARY: Automation Account module
DESCRIPTION: Module utilised for deployment of Azure Automation Account
AUTHOR/S: klaasjan.dejager@eviden.com
VERSION: 0.1
*/

// PARAMETERS
@description('Specifies the name of the Automation Account.')
param automationAccountName string

@description('Specifies the location of the Automation Account.')
param location string

@description('A mapping of tags to assign to the resource.')
param tags object

@description('The SKU of the automation account account. Valid options are Free, Basic')
param skuName string

@description('Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool

@description('The ID(s) to assign to the resource.')
param userAssignedIdentities object

@description('naming for mgmt subscription as loaded in parentmodule. Used for branding variables.')
param mgmtNaming object

// VARIABLES

//Variables from the naming convention files for branding, tagging and resource naming.

var companyVariableDetails = {
  name: 'company'
  description: 'company brand name'
  isEncrypted: true
  value: '"${mgmtNaming.company.name}"'
}

var productVariableDetails = {
  name: 'product'
  description: 'product name'
  isEncrypted: true
  value: '"${mgmtNaming.product.name}"'
}

var productCodeVariableDetails = {
  name: 'productCode'
  description: 'product name'
  isEncrypted: true
  value: '"${mgmtNaming.productCode.name}"'
}

var tagPrefixVariableDetails = {
  name: 'tagPrefix'
  description: 'tagPrefix name'
  isEncrypted: true
  value: '"${mgmtNaming.tagPrefix.name}"'
}

var tagValuePrefixVariableDetails = {
  name: 'tagValuePrefix'
  description: 'tagValuePrefix name'
  isEncrypted: true
  value: '"${mgmtNaming.tagValuePrefix.name}"'
}

var subscriptionInfo = subscription()

var subscriptionVariableDetails = {
  name: 'AzureSubscriptionId'
  description: 'Azure subscription Id'
  isEncrypted: true
  value: '"${subscriptionInfo.subscriptionId}"'
}


var identityType = systemAssignedIdentity ? 'SystemAssigned' : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

// RESOURCE DEPLOYMENTS 

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: automationAccountName
  location: location
  tags: tags
  properties: {
    sku: {
      name: skuName
    }
  }
  identity: identity
}

resource automationAccountVariable 'Microsoft.Automation/automationAccounts/variables@2020-01-13-preview' = {
  name: subscriptionVariableDetails.name
  parent: automationAccount
  properties: {
    description: subscriptionVariableDetails.description
    isEncrypted: subscriptionVariableDetails.isEncrypted
    value: subscriptionVariableDetails.value
  }
}
  resource automationAccountCompanyVariable 'Microsoft.Automation/automationAccounts/variables@2020-01-13-preview' = {
    name: companyVariableDetails.name
    parent: automationAccount
    properties: {
      description: companyVariableDetails.description
      isEncrypted: companyVariableDetails.isEncrypted
      value: companyVariableDetails.value
    }
}
resource automationAccountProductVariable 'Microsoft.Automation/automationAccounts/variables@2020-01-13-preview' = {
  name: productVariableDetails.name
  parent: automationAccount
  properties: {
    description: productVariableDetails.description
    isEncrypted: productVariableDetails.isEncrypted
    value: productVariableDetails.value
  }
}
resource automationAccountProductCodeVariable 'Microsoft.Automation/automationAccounts/variables@2020-01-13-preview' = {
  name: productCodeVariableDetails.name
  parent: automationAccount
  properties: {
    description: productCodeVariableDetails.description
    isEncrypted: productCodeVariableDetails.isEncrypted
    value: productCodeVariableDetails.value
  }
}
resource automationAccountTagPrefixVariable 'Microsoft.Automation/automationAccounts/variables@2020-01-13-preview' = {
  name: tagPrefixVariableDetails.name
  parent: automationAccount
  properties: {
    description: tagPrefixVariableDetails.description
    isEncrypted: tagPrefixVariableDetails.isEncrypted
    value: tagPrefixVariableDetails.value
  }
}
resource automationAccountTagvaluePrefixVariable 'Microsoft.Automation/automationAccounts/variables@2020-01-13-preview' = {
  name: tagValuePrefixVariableDetails.name
  parent: automationAccount
  properties: {
    description: tagValuePrefixVariableDetails.description
    isEncrypted: tagValuePrefixVariableDetails.isEncrypted
    value: tagValuePrefixVariableDetails.value
  }
}


// OUTPUTS

output automationAccountId string = automationAccount.id
output automationAccountName string = automationAccount.name
output automationAccountLocation string = automationAccount.location
output AutomationAccManagedIdentityPrincipalId string = identityType == 'SystemAssigned' ? automationAccount.identity.principalId : 'None'
