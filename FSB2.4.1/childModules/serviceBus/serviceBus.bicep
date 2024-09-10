/*
SUMMARY: Deployment of a service bus.
DESCRIPTION: Deploys a service bus to the desired Azure region, with the specified name.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// PARAMETERS
@description('Required. Name of the Service Bus Namespace.')
param name string

@description('Required. Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Required. Name of this SKU. - Basic, Standard, Premium.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param skuName string

@description('Optional. Enabling this property creates a Premium Service Bus Namespace in regions supported availability zones.')
param zoneRedundant bool = false

@description('Required. Name of the Service Bus Queue.')
param queueName string

@description('Required. The queue configuration to create in the service bus namespace.')
param queueConfig object

@description('Required. The name of the authorization rule.')
param authorizationRuleName string

@description('Optional. The rights associated with the rule.')
@allowed([
  'Listen'
  'Manage'
  'Send'
])
param authorizationRuleRights array = []

// RESOURCE DEPLOYMENTS 
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    zoneRedundant: zoneRedundant
  }

  // Deploy the servicesBus queue(s) with its properties
  resource serviceBusQueue 'queues' = {
    name: queueName
    properties: {
      lockDuration: queueConfig.lockDuration
      maxSizeInMegabytes: queueConfig.maxSizeInMegabytes
      requiresDuplicateDetection: queueConfig.requiresDuplicateDetection
      requiresSession: queueConfig.requiresSession
      defaultMessageTimeToLive: queueConfig.defaultMessageTimeToLive
      deadLetteringOnMessageExpiration: queueConfig.deadLetteringOnMessageExpiration
      enableBatchedOperations: queueConfig.enableBatchedOperations
      duplicateDetectionHistoryTimeWindow: queueConfig.duplicateDetectionHistoryTimeWindow
      maxDeliveryCount: queueConfig.maxDeliveryCount
      status: queueConfig.status
      enablePartitioning: queueConfig.enablePartitioning
      enableExpress: queueConfig.enableExpress
    }
  }

  // Deploy the serviceBus authorization rules with the specified rights.
  resource serviceBusAuthorizationRule 'AuthorizationRules' = {
    name: authorizationRuleName
    properties: {
      rights: authorizationRuleRights
    }
  }
}

// OUTPUTS
@description('The name of the deployed service bus namespace.')
output serviceBusName string = serviceBusNamespace.name
@description('The resource ID of the deployed service bus namespace.')
output serviceBusResourceId string = serviceBusNamespace.id
@description('The resource group of the deployed service bus namespace.')
output resourceGroupName string = resourceGroup().name
