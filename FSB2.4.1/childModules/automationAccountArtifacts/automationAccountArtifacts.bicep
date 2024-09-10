/*
SUMMARY: Upload Artifacts Module
DESCRIPTION: Module resposible to upload runbooks and create webhooks or schedules as per requirments
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.2

Note: The runbooks artifacts must be present in below format in storage account
Format: <Storgae-Acc>/elz-artifacts/runbooks
e.g: https://atsc3h4bvbaksbiq.blob.core.windows.net/elz-artifacts/runbooks
*/

// PARAMETERS

@description('Specifies the name of the Automation Account.')
param automationAccountName string

@description('Specifies the location of the Automation Account.')
param location string

@description('List of runbooks needed to be uploaded in automation account')
param runbooks array

@description('Specifies the name of the Artifact Storage Account.')
param artifactStorageAccount string

@description('Specifies the name of the Resource Group where Artifact Storage Account resides.')
param artifactStorageAccountResourceGroup string

@description('Specifies the current time when the module is triggered')
param currentTime string = utcNow('u')

@description('Specifies the Modules that needs to be updated or uploaded to Automation Account')
param modules array

@description('Specifies the Timezone where runbook schedules are displayed')
param timeZone string

@description('naming for mgmt subscription as loaded in parentmodule. Used for branding variables.')
param productCode string

@description('naming for mgmt subscription as loaded in parentmodule. Used for branding variables.')
param company string

// VARIABLES

//Variables from the naming convention files for branding, tagging and resource naming.

var artifactContainer = '${toLower(productCode)}-artifacts'

var expiryTimeWebhookRegisternode = dateTimeAdd(currentTime, 'PT96H')

var tommorowsdate = split(dateTimeAdd(currentTime, 'P1D'), 'T')[0]

var sasTokenParams = {
  signedPermission: 'r'
  signedExpiry: dateTimeAdd(currentTime, 'PT1H')
  signedProtocol: 'https'
  signedResourceTypes: 'sco'
  signedServices: 'b'
}

// RESOURCE DEPLOYMENTS 

resource linkedAutomationAccount 'Microsoft.Automation/automationAccounts@2019-06-01' existing = {
  // existing or pre-deployed (as part of previous) storage account used for Function App
  name: automationAccountName
}

resource linkedStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  // existing or pre-deployed (as part of previous) storage account used for Function App
  name: artifactStorageAccount
  scope: resourceGroup(artifactStorageAccountResourceGroup)
}

resource automationAccountRunbooks 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = [for runbook in runbooks: {
  name: '${automationAccountName}/${runbook.name}'
  location: location
  tags: contains(runbook, 'tag') ? {
    '${company}Purpose': runbook.tagValue
  } : null
  properties: {
    description: runbook.description
    runbookType: runbook.type
    logProgress: false
    logVerbose: true
    publishContentLink: {
      uri: '${linkedStorageAccount.properties.primaryEndpoints.blob}${artifactContainer}/runbooks/${runbook.filename}?${linkedStorageAccount.listAccountSas(linkedStorageAccount.apiVersion, sasTokenParams).accountSasToken}'
      version: runbook.version
    }
  }
}]

resource automationAccountWebhooks 'Microsoft.Automation/automationAccounts/webhooks@2015-10-31' = [for (runbook, i) in runbooks: if (contains(runbook, 'webhookName')) {
  name: contains(runbook, 'webhookName') ? '${automationAccountName}/${runbook.webhookName}' : '${automationAccountName}/${i}empty'
  properties: {
    isEnabled: true
    expiryTime: expiryTimeWebhookRegisternode
    runbook: {
      name: runbook.name
    }
  }
  dependsOn: [
    automationAccountRunbooks
  ]
}]

resource automationAccountSchedule 'Microsoft.Automation/automationAccounts/schedules@2023-11-01' = [for (runbook, i) in runbooks: if (contains(runbook, 'scheduleName')) {
  name: contains(runbook, 'scheduleName') ? '${automationAccountName}/${runbook.scheduleName}' : '${automationAccountName}/${i}empty'
  properties: {
    startTime: contains(runbook.startTime, 'PT') ? dateTimeAdd(currentTime, '${runbook.startTime}') : '${tommorowsdate}T${runbook.startTime}:00Z'
    expiryTime: '9999-12-31T23:59:59.9999999+00:00'
    interval: contains(runbook, 'scheduleName') ? runbook.interval : 0
    frequency: runbook.frequency
    isEnabled: contains(runbook, 'scheduleIsEnabled') ? runbook.scheduleIsEnabled : true
    timeZone: timeZone
  }
  dependsOn: [
    automationAccountRunbooks
  ]
}]

resource automationAccountJobScheduleName 'Microsoft.Automation/automationAccounts/jobSchedules@2019-06-01' = [for (runbook, i) in runbooks: if (contains(runbook, 'scheduleName')) {
  name: contains(runbook, 'scheduleName') ? guid('${runbook.scheduleName}${currentTime}') : guid('${currentTime}${i}')
  parent: linkedAutomationAccount
  properties: {
    runbook: {
      name: runbook.name
    }
    schedule: {
      name: contains(runbook, 'scheduleName') ? runbook.scheduleName : 'empty'
    }
  }
  dependsOn: [
    automationAccountRunbooks
    automationAccountSchedule
  ]
}]

resource automationAccountNameModules 'Microsoft.Automation/automationAccounts/modules@2019-06-01' = [for module in modules: {
  name: contains(module.name, 'moduleNamePlaceHolder') ? '${automationAccountName}/${company}.RunbookAutomation' : '${automationAccountName}/${module.name}'
  location: location
  properties: {
    contentLink: {
      uri: contains(module.name, 'moduleNamePlaceHolder') ? '${linkedStorageAccount.properties.primaryEndpoints.blob}${artifactContainer}/runbooks/Modules/${company}.RunbookAutomation.zip?${linkedStorageAccount.listAccountSas(linkedStorageAccount.apiVersion, sasTokenParams).accountSasToken}' : module.url
    }
  }
}]

// OUTPUTS
output automationAccountName string = linkedAutomationAccount.name
