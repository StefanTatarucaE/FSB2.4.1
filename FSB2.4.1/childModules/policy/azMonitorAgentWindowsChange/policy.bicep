/*
SUMMARY: Azure Monitor agent for Windows Change Policy child module.
DESCRIPTION: Deployment of Azure Monitor agent for Windows Change Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: frederic.trapet@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. MGs not supported yet.

// PARAMETERS

@description('Specify wether the policy will apply only to supported images or also to custom windows images')
param scopeToSupportedImages bool

@description('List of virtual machine images that have supported Windows OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\'')
param listOfWindowsImageIdToInclude array = []

@description('Specify the resource ID of the Data Collection Rule for association')
param dataCollectionRuleResourceId string

@description('Specify the metadata source value required for billing and monitoring')
param policyMetadata string

@description('The Id of the management subscription. To be provided by the parent module')
param managementSubscriptionId string

@description('Specify the name to be used for the Azure Monitor Agent for Windows Vm policy')
param enableAmAgentWindowsVmDefName string

@description('Specify the display name to be used for the Azure Monitor Agent for Windows Vm policy')
param enableAmAgentWindowsVmDefDisplayName string

@description('Specify the name to be used for the Azure Monitor Agent for Windows Vmss policy')
param enableAmAgentWindowsVmssDefName string

@description('Specify the display name to be used for Azure Monitor Agent for Windows Vm policy')
param enableAmAgentWindowsVmssDefDisplayName string

@description('Specify te name for the Azure Monitor Agent - Data Collection Rule association for Windows policy')
param dcrAssociationWindowsDefName string

@description('Specify the display name for the Azure Monitor Agent - Data Collection Rule association for Windows policy')
param dcrAssociationWindowsDefDisplayName string

@description('Desired policy effect to set Azure Monitor Agent on Windows Virtual Machines')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param enableAmAgentWindowsVmDefEffect string

@description('Desired policy effect to set Azure Monitor Agent on Windows Virtual Machine Scale Sets')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param enableAmAgentWindowsVmssDefEffect string

@description('Desired policy effect to associate the Azure Monitor Agent extension resource with a Data Collection Rule resource.')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param dcrAssociationWindowsDefEffect string

@description('Specify policy set name for vm log analytics agent initiative')
param enableAmAgentWindowsSetName string

@description('Specify policy set display name for vm log analytics agent initiative')
param enableAmAgentWindowsSetDisplayName string

@description('Specify policy asignment name for vm log analytics agent initiative')
param enableAmAgentWindowsSetAssignmentName string

@description('Specify policy asignment display name for vm log analytics agent initiative')
param enableAmAgentWindowsSetAssignmentDisplayName string

@description('Tag used for the policy rule')
param policyRuleTag string

@description('Name of the existing user assigned managed identity for monitoring in this subscription')
param userAssignedManagedIdentityName string

@description('Resource group where the existing user assigned managed identity for monitoring in this subscription is stored')
param userAssignedManagedIdentityResourceGroup string

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

// VARIABLES
// This variable holds the Azure Monitor agent for Windows VM policy details

var dataCollectionRulesResourceType = 'Microsoft.Insights/dataCollectionRules'

var amAgentWindowsVmDefinitionProperties = {
  description: 'Deploy Azure Monitoring Agent for Windows VMs if the agent is not installed'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// This variable holds the Azure Monitor agent for Windows VMSS policy details
var amAgentWindowsVmssDefinitionProperties = {
  description: 'Deploy Azure Monitoring Agent for Windows VM Scale Sets if the agent is not installed'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}


// This variable holds the DCR - Azure Monitor Agent association policy details
var dcrAssociationWindowsDefinitionProperties = {
  description: 'Deploy Association to link Windows virtual machines and virtual machine scale sets to the specified Data Collection Rule or the specified Data Collection Endpoint. The list of locations and OS images are updated over time as support is increased.'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// This variable holds the details for the Azure Monitor Agent Windows policy initiatve
var amAgentPolicySetDefinitionProperties = {
  description: 'This initiative configures Windows machines to run Azure Monitor Agent and associates them to a Data Collection Rule'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// This variable holds the details for the Azure Monitor policy set assignment
var amAgentAssignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identity: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Install Azure Monitor Agent for Windows systems'
  metadata: {
    source: policyMetadata
  }
  roleDefinitionIdOrNames: [
    'Log Analytics Contributor'
    'VM Contributor'
    'Monitoring Contributor'
  ]
}

// Trim variable to support role assignment name condition maximum length of '64'
var trimSetName = 'winamagent'

// Variable which holds a unique string for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployLocation), 0, 6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(trimSetName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'

//Variable used to construct the name of the Role Assignment Deployment on the Management Subscription
var roleAssignmentNameMgmt = '${first(split(trimSetName, '-'))}-${uniqueDeployPrefix}-mgmt-roleAssignment-deployment'

// RESOURCES

// Azure Monitor Agent for Windows Vm
resource enableAmAgentWindowsVmPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: enableAmAgentWindowsVmDefName
  properties: {
    displayName: enableAmAgentWindowsVmDefDisplayName
    description: amAgentWindowsVmDefinitionProperties.description
    policyType: amAgentWindowsVmDefinitionProperties.policyType
    mode: amAgentWindowsVmDefinitionProperties.mode
    metadata: amAgentWindowsVmDefinitionProperties.metadata

    parameters: {
      scopeToSupportedImages: {
        type: 'Boolean'
        metadata: {
          displayName: 'Scope Policy to Azure Monitor Agent-Supported Operating Systems'
          description: 'If set to true, the policy will apply only to virtual machines with supported operating systems. Otherwise, the policy will apply to all virtual machine resources in the assignment scope. For supported operating systems, see https://aka.ms/AMAOverview.'
        }
        allowedValues: [
          true
          false
        ]
        defaultValue: true
      }
      listOfWindowsImageIdToInclude: {
        type: 'Array'
        metadata: {
          displayName: 'Additional Virtual Machine Images'
          description: 'List of virtual machine images that have supported Windows OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
        }
        defaultValue: []
      }
      bringYourOwnUserAssignedManagedIdentity: {
        type: 'Boolean'
        metadata: {
          displayName: 'Bring Your Own User-Assigned Managed Identity'
          description: 'If set to true, Azure Monitor Agent will use the user-assigned managed identity specified via the \'User-Assigned Managed Identity ...\' parameters for authentication. Otherwise, Azure Monitor Agent will use the user-assigned managed identity /subscriptions/<subscription-id>/resourceGroups/built-in-identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/built-in-identity-<location> for authentication.'
        }
        allowedValues: [
          false
          true
        ]
      }
      userAssignedManagedIdentityName: {
        type: 'String'
        metadata: {
          displayName: 'User-Assigned Managed Identity Name'
          description: 'The name of the user-assigned managed identity which Azure Monitor Agent will use for authentication when \'Bring Your Own User-Assigned Managed Identity\' is set to true.'
        }
        defaultValue: ''
      }
      userAssignedManagedIdentityResourceGroup: {
        type: 'String'
        metadata: {
          displayName: 'User-Assigned Managed Identity Resource Group'
          description: 'The resource group of the user-assigned managed identity which Azure Monitor Agent will use for authentication when \'Bring Your Own User-Assigned Managed Identity\' is set to true.'
        }
        defaultValue: ''
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
          {
            field: 'location'
            in: [
              'australiacentral'
              'australiaeast'
              'australiasoutheast'
              'brazilsouth'
              'canadacentral'
              'canadaeast'
              'centralindia'
              'centralus'
              'eastasia'
              'eastus2euap'
              'eastus'
              'eastus2'
              'francecentral'
              'germanywestcentral'
              'japaneast'
              'japanwest'
              'jioindiawest'
              'koreacentral'
              'koreasouth'
              'northcentralus'
              'northeurope'
              'norwayeast'
              'southafricanorth'
              'southcentralus'
              'southeastasia'
              'southindia'
              'switzerlandnorth'
              'uaenorth'
              'uksouth'
              'ukwest'
              'westcentralus'
              'westeurope'
              'westindia'
              'westus'
              'westus2'
              'chinaeast'
              'chinaeast2'
              'chinaeast3'
              'chinanorth'
              'chinanorth2'
              'chinanorth3'
              'usgovarizona'
              'usgovtexas'
              'usgovvirginia'
              'usdodeast'
              'usdodcentral'
            ]
          }
          {
            anyOf: [
              {
                allOf: [
                  {
                    value: '[parameters(\'scopeToSupportedImages\')]'
                    equals: false
                  }
                  {
                    field: 'Microsoft.Compute/virtualMachines/storageProfile.osDisk.osType'
                    like: 'Windows*'
                  }
                ]
              }
              {
                field: 'Microsoft.Compute/imageId'
                in: '[parameters(\'listOfWindowsImageIdToInclude\')]'
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServer'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2008-R2-SP1*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2012-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2016-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2019-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2022-*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServerSemiAnnual'
                  }
                  {
                    field: 'Microsoft.Compute/imageSKU'
                    in: [
                      'Datacenter-Core-1709-smalldisk'
                      'Datacenter-Core-1709-with-Containers-smalldisk'
                      'Datacenter-Core-1803-with-Containers-smalldisk'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServerHPCPack'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServerHPCPack'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftSQLServer'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2022'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2022-BYOL'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2019'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2019-BYOL'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2016'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2016-BYOL'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2012R2'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2012R2-BYOL'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftRServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'MLServer-WS2016'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftVisualStudio'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'VisualStudio'
                      'Windows'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftDynamicsAX'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'Dynamics'
                  }
                  {
                    field: 'Microsoft.Compute/imageSKU'
                    equals: 'Pre-Req-AX7-Onebox-U8'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'microsoft-ads'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'windows-data-science-vm'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsDesktop'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    like: 'Windows-1*'
                  }
                ]
              }
            ]
          }
        ]
      }
      then: {
        effect: enableAmAgentWindowsVmDefEffect
        details: {
          type: 'Microsoft.Compute/virtualMachines/extensions'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                equals: 'AzureMonitorWindowsAgent'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/publisher'
                equals: 'Microsoft.Azure.Monitor'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/provisioningState'
                equals: 'Succeeded'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  vmName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                  userAssignedManagedIdentity: {
                    type: 'string'
                  }                  
                }
                variables: {
                  extensionName: 'AzureMonitorWindowsAgent'
                  extensionPublisher: 'Microsoft.Azure.Monitor'
                  extensionType: 'AzureMonitorWindowsAgent'
                  extensionTypeHandlerVersion: '1.2'
                }
                resources: [
                  {
                    name: '[concat(parameters(\'vmName\'), \'/\', variables(\'extensionName\'))]'
                    type: 'Microsoft.Compute/virtualMachines/extensions'
                    location: '[parameters(\'location\')]'
                    apiVersion: '2019-07-01'
                    properties: {
                      publisher: '[variables(\'extensionPublisher\')]'
                      type: '[variables(\'extensionType\')]'
                      typeHandlerVersion: '[variables(\'extensionTypeHandlerVersion\')]'
                      autoUpgradeMinorVersion: true
                      enableAutomaticUpgrade: true
                      settings: {
                        authentication: {
                          managedIdentity: {
                            'identifier-name': 'mi_res_id'
                            'identifier-value': '[parameters(\'userAssignedManagedIdentity\')]'
                          }
                        }
                      }                      
                    }
                  }
                ]
              }
              parameters: {
                vmName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
                userAssignedManagedIdentity: {
                  value: '[if(parameters(\'bringYourOwnUserAssignedManagedIdentity\'), concat(\'/subscriptions/\', subscription().subscriptionId, \'/resourceGroups/\', parameters(\'userAssignedManagedIdentityResourceGroup\'), \'/providers/Microsoft.ManagedIdentity/userAssignedIdentities/\', parameters(\'userAssignedManagedIdentityName\')), concat(\'/subscriptions/\', subscription().subscriptionId, \'/resourceGroups/built-in-identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/built-in-identity-\', field(\'location\')))]'
                }
              }
            }
          }
        }
      }
    }
  }
}

// Azure Monitor Agent for Windows Vmss
resource enableAmAgentWindowsVmssPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: enableAmAgentWindowsVmssDefName
  properties: {
    displayName: enableAmAgentWindowsVmssDefDisplayName
    description: amAgentWindowsVmssDefinitionProperties.description
    policyType: amAgentWindowsVmssDefinitionProperties.policyType
    mode: amAgentWindowsVmssDefinitionProperties.mode
    metadata: amAgentWindowsVmssDefinitionProperties.metadata
    parameters: {
      scopeToSupportedImages: {
        type: 'Boolean'
        metadata: {
          displayName: 'Scope Policy to Azure Monitor Agent-Supported Operating Systems'
          description: 'If set to true, the policy will apply only to virtual machine scale sets with supported operating systems. Otherwise, the policy will apply to all virtual machine scale set resources in the assignment scope. For supported operating systems, see https://aka.ms/AMAOverview.'
        }
        allowedValues: [
          true
          false
        ]
        defaultValue: true
      }
      listOfWindowsImageIdToInclude: {
        type: 'Array'
        metadata: {
          displayName: 'Additional Virtual Machine Images'
          description: 'List of virtual machine images that have supported Windows OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
        }
        defaultValue: []
      }
      bringYourOwnUserAssignedManagedIdentity: {
        type: 'Boolean'
        metadata: {
          displayName: 'Bring Your Own User-Assigned Managed Identity'
          description: 'If set to true, Azure Monitor Agent will use the user-assigned managed identity specified via the \'User-Assigned Managed Identity ...\' parameters for authentication. Otherwise, Azure Monitor Agent will use the user-assigned managed identity /subscriptions/<subscription-id>/resourceGroups/built-in-identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/built-in-identity-<location> for authentication.'
        }
        allowedValues: [
          false
          true
        ]
      }
      userAssignedManagedIdentityName: {
        type: 'String'
        metadata: {
          displayName: 'User-Assigned Managed Identity Name'
          description: 'The name of the user-assigned managed identity which Azure Monitor Agent will use for authentication when \'Bring Your Own User-Assigned Managed Identity\' is set to true.'
        }
        defaultValue: ''
      }
      userAssignedManagedIdentityResourceGroup: {
        type: 'String'
        metadata: {
          displayName: 'User-Assigned Managed Identity Resource Group'
          description: 'The resource group of the user-assigned managed identity which Azure Monitor Agent will use for authentication when \'Bring Your Own User-Assigned Managed Identity\' is set to true.'
        }
        defaultValue: ''
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachineScaleSets'
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
          {
            field: 'location'
            in: [
              'australiacentral'
              'australiaeast'
              'australiasoutheast'
              'brazilsouth'
              'canadacentral'
              'canadaeast'
              'centralindia'
              'centralus'
              'eastasia'
              'eastus2euap'
              'eastus'
              'eastus2'
              'francecentral'
              'germanywestcentral'
              'japaneast'
              'japanwest'
              'jioindiawest'
              'koreacentral'
              'koreasouth'
              'northcentralus'
              'northeurope'
              'norwayeast'
              'southafricanorth'
              'southcentralus'
              'southeastasia'
              'southindia'
              'switzerlandnorth'
              'uaenorth'
              'uksouth'
              'ukwest'
              'westcentralus'
              'westeurope'
              'westindia'
              'westus'
              'westus2'
              'chinaeast'
              'chinaeast2'
              'chinaeast3'
              'chinanorth'
              'chinanorth2'
              'chinanorth3'
              'usgovarizona'
              'usgovtexas'
              'usgovvirginia'
              'usdodeast'
              'usdodcentral'
            ]
          }
          {
            anyOf: [
              {
                allOf: [
                  {
                    value: '[parameters(\'scopeToSupportedImages\')]'
                    equals: false
                  }
                  {
                    field: 'Microsoft.Compute/virtualMachineScaleSets/virtualMachineProfile.storageProfile.osDisk.osType'
                    like: 'Windows*'
                  }
                ]
              }
              {
                field: 'Microsoft.Compute/imageId'
                in: '[parameters(\'listOfWindowsImageIdToInclude\')]'
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServer'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2008-R2-SP1*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2012-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2016-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2019-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2022-*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServerSemiAnnual'
                  }
                  {
                    field: 'Microsoft.Compute/imageSKU'
                    in: [
                      'Datacenter-Core-1709-smalldisk'
                      'Datacenter-Core-1709-with-Containers-smalldisk'
                      'Datacenter-Core-1803-with-Containers-smalldisk'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServerHPCPack'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServerHPCPack'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftSQLServer'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2022'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2022-BYOL'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2019'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2019-BYOL'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2016'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2016-BYOL'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2012R2'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2012R2-BYOL'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftRServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'MLServer-WS2016'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftVisualStudio'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'VisualStudio'
                      'Windows'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftDynamicsAX'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'Dynamics'
                  }
                  {
                    field: 'Microsoft.Compute/imageSKU'
                    equals: 'Pre-Req-AX7-Onebox-U8'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'microsoft-ads'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'windows-data-science-vm'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsDesktop'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    like: 'Windows-1*'
                  }
                ]
              }
            ]
          }
        ]
      }
      then: {
        effect: enableAmAgentWindowsVmssDefEffect
        details: {
          type: 'Microsoft.Compute/virtualMachineScaleSets/extensions'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/type'
                equals: 'AzureMonitorWindowsAgent'
              }
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/publisher'
                equals: 'Microsoft.Azure.Monitor'
              }
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/provisioningState'
                equals: 'Succeeded'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  vmName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                  userAssignedManagedIdentity: {
                    type: 'string'
                  }
                }
                variables: {
                  extensionName: 'AzureMonitorWindowsAgent'
                  extensionPublisher: 'Microsoft.Azure.Monitor'
                  extensionType: 'AzureMonitorWindowsAgent'
                  extensionTypeHandlerVersion: '1.2'
                }
                resources: [
                  {
                    name: '[concat(parameters(\'vmName\'), \'/\', variables(\'extensionName\'))]'
                    type: 'Microsoft.Compute/virtualMachineScaleSets/extensions'
                    location: '[parameters(\'location\')]'
                    apiVersion: '2019-07-01'
                    properties: {
                      publisher: '[variables(\'extensionPublisher\')]'
                      type: '[variables(\'extensionType\')]'
                      typeHandlerVersion: '[variables(\'extensionTypeHandlerVersion\')]'
                      autoUpgradeMinorVersion: true
                      enableAutomaticUpgrade: true
                      settings: {
                        authentication: {
                          managedIdentity: {
                            'identifier-name': 'mi_res_id'
                            'identifier-value': '[parameters(\'userAssignedManagedIdentity\')]'
                          }
                        }
                      }
                    }
                  }
                ]
              }
              parameters: {
                vmName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
                userAssignedManagedIdentity: {
                  value: '[if(parameters(\'bringYourOwnUserAssignedManagedIdentity\'), concat(\'/subscriptions/\', subscription().subscriptionId, \'/resourceGroups/\', parameters(\'userAssignedManagedIdentityResourceGroup\'), \'/providers/Microsoft.ManagedIdentity/userAssignedIdentities/\', parameters(\'userAssignedManagedIdentityName\')), concat(\'/subscriptions/\', subscription().subscriptionId, \'/resourceGroups/built-in-identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/built-in-identity-\', field(\'location\')))]'
                }
              }
            }
          }
        }
      }
    }
  }
}

// Association between Azure Monitor Agent and Data collection rules for Windows Operating Systems
resource dataCollectionRuleAssociationWindows 'Microsoft.Authorization/policydefinitions@2020-03-01' = {
  name: dcrAssociationWindowsDefName
  properties: {
    displayName: dcrAssociationWindowsDefDisplayName
    policyType: dcrAssociationWindowsDefinitionProperties.policyType
    mode: dcrAssociationWindowsDefinitionProperties.mode
    description: dcrAssociationWindowsDefinitionProperties.description
    metadata: dcrAssociationWindowsDefinitionProperties.metadata
    parameters: {
      listOfWindowsImageIdToInclude: {
        type: 'Array'
        metadata: {
          displayName: 'Additional Windows Machine Images'
          description: 'List of machine images that have supported Windows OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
        }
        defaultValue: []
      }
      dcrResourceId: {
        type: 'String'
        metadata: {
          displayName: 'Data Collection Rule Resource Id or Data Collection Endpoint Resource Id'
          description: 'Resource Id of the Data Collection Rule or the Data Collection Endpoint to be applied on the Linux machines in scope.'
          portalReview: 'true'
        }
      }
      resourceType: {
        type: 'String'
        metadata: {
          displayName: 'Resource Type'
          description: 'Either a Data Collection Rule (DCR) or a Data Collection Endpoint (DCE)'
          portalReview: 'true'
        }
        allowedValues: [
          'Microsoft.Insights/dataCollectionRules'
          'Microsoft.Insights/dataCollectionEndpoints'
        ]
        defaultValue: 'Microsoft.Insights/dataCollectionRules'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
          {
            field: 'location'
            in: [
              'australiacentral'
              'australiacentral2'
              'australiaeast'
              'australiasoutheast'
              'brazilsouth'
              'brazilsoutheast'
              'canadacentral'
              'canadaeast'
              'centralindia'
              'centralus'
              'eastasia'
              'eastus'
              'eastus2'
              'eastus2euap'
              'francecentral'
              'francesouth'
              'germanywestcentral'
              'japaneast'
              'japanwest'
              'jioindiawest'
              'koreacentral'
              'koreasouth'
              'northcentralus'
              'northeurope'
              'norwayeast'
              'norwaywest'
              'southafricanorth'
              'southcentralus'
              'southeastasia'
              'southindia'
              'swedencentral'
              'switzerlandnorth'
              'switzerlandwest'
              'uaenorth'
              'uksouth'
              'ukwest'
              'westcentralus'
              'westeurope'
              'westindia'
              'westus'
              'westus2'
              'westus3'
            ]
          }
          {
            anyOf: [
              {
                allOf: [
                  {
                    field: 'type'
                    equals: 'Microsoft.HybridCompute/machines'
                  }
                  {
                    field: 'Microsoft.HybridCompute/machines/osName'
                    equals: 'Windows'
                  }
                ]
              }
              {
                allOf: [
                  {
                    anyOf: [
                      {
                        field: 'type'
                        equals: 'Microsoft.Compute/virtualMachines'
                      }
                      {
                        field: 'type'
                        equals: 'Microsoft.Compute/virtualMachineScaleSets'
                      }
                    ]
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageId'
                        in: '[parameters(\'listOfWindowsImageIdToInclude\')]'
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'MicrosoftWindowsServer'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            equals: 'WindowsServer'
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '2008-R2-SP1*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '2012-*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '2016-*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '2019-*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '2022-*'
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'MicrosoftWindowsServer'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            equals: 'WindowsServerSemiAnnual'
                          }
                          {
                            field: 'Microsoft.Compute/imageSKU'
                            in: [
                              'Datacenter-Core-1709-smalldisk'
                              'Datacenter-Core-1709-with-Containers-smalldisk'
                              'Datacenter-Core-1803-with-Containers-smalldisk'
                              'Datacenter-Core-1809-with-Containers-smalldisk'
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'MicrosoftWindowsServerHPCPack'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            equals: 'WindowsServerHPCPack'
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'MicrosoftSQLServer'
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: '*-WS2016'
                              }
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: '*-WS2016-BYOL'
                              }
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: '*-WS2012R2'
                              }
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: '*-WS2012R2-BYOL'
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'MicrosoftRServer'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            equals: 'MLServer-WS2016'
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'MicrosoftVisualStudio'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'VisualStudio'
                              'Windows'
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'MicrosoftDynamicsAX'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            equals: 'Dynamics'
                          }
                          {
                            field: 'Microsoft.Compute/imageSKU'
                            equals: 'Pre-Req-AX7-Onebox-U8'
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'microsoft-ads'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            equals: 'windows-data-science-vm'
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'MicrosoftWindowsDesktop'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            like: 'Windows-1*'
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
      then: {
        effect: dcrAssociationWindowsDefEffect
        details: {
          type: 'Microsoft.Insights/dataCollectionRuleAssociations'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
            '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          ]
          evaluationDelay: 'AfterProvisioning'
          existenceCondition: {
            anyOf: [
              {
                field: 'Microsoft.Insights/dataCollectionRuleAssociations/dataCollectionRuleId'
                equals: '[parameters(\'dcrResourceId\')]'
              }
              {
                field: 'Microsoft.Insights/dataCollectionRuleAssociations/dataCollectionEndpointId'
                equals: '[parameters(\'dcrResourceId\')]'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                  dcrResourceId: {
                    type: 'string'
                  }
                  type: {
                    type: 'string'
                  }
                  resourceType: {
                    type: 'string'
                  }
                }
                variables: {
                  dcrAssociationName: '[concat(\'assoc-\', uniqueString(concat(parameters(\'resourceName\'), parameters(\'dcrResourceId\'))))]'
                  dceAssociationName: 'configurationAccessEndpoint'
                  dcrResourceType: 'Microsoft.Insights/dataCollectionRules'
                  dceResourceType: 'Microsoft.Insights/dataCollectionEndpoints'
                }
                resources: [
                  {
                    condition: '[and(equals(toLower(parameters(\'type\')), \'microsoft.compute/virtualmachines\'), equals(parameters(\'resourceType\'), variables(\'dcrResourceType\')))]'
                    name: '[variables(\'dcrAssociationName\')]'
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                    apiVersion: '2021-04-01'
                    properties: {
                      dataCollectionRuleId: '[parameters(\'dcrResourceId\')]'
                    }
                    scope: '[concat(\'Microsoft.Compute/virtualMachines/\', parameters(\'resourceName\'))]'
                  }
                  {
                    condition: '[and(equals(toLower(parameters(\'type\')), \'microsoft.compute/virtualmachines\'), equals(parameters(\'resourceType\'), variables(\'dceResourceType\')))]'
                    name: '[variables(\'dceAssociationName\')]'
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                    apiVersion: '2021-04-01'
                    properties: {
                      dataCollectionEndpointId: '[parameters(\'dcrResourceId\')]'
                    }
                    scope: '[concat(\'Microsoft.Compute/virtualMachines/\', parameters(\'resourceName\'))]'
                  }
                  {
                    condition: '[and(equals(toLower(parameters(\'type\')), \'microsoft.compute/virtualmachinescalesets\'), equals(parameters(\'resourceType\'), variables(\'dcrResourceType\')))]'
                    name: '[variables(\'dcrAssociationName\')]'
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                    apiVersion: '2021-04-01'
                    properties: {
                      dataCollectionRuleId: '[parameters(\'dcrResourceId\')]'
                    }
                    scope: '[concat(\'Microsoft.Compute/virtualMachineScaleSets/\', parameters(\'resourceName\'))]'
                  }
                  {
                    condition: '[and(equals(toLower(parameters(\'type\')), \'microsoft.compute/virtualmachinescalesets\'), equals(parameters(\'resourceType\'), variables(\'dceResourceType\')))]'
                    name: '[variables(\'dceAssociationName\')]'
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                    apiVersion: '2021-04-01'
                    properties: {
                      dataCollectionEndpointId: '[parameters(\'dcrResourceId\')]'
                    }
                    scope: '[concat(\'Microsoft.Compute/virtualMachineScaleSets/\', parameters(\'resourceName\'))]'
                  }
                  {
                    condition: '[and(equals(toLower(parameters(\'type\')), \'microsoft.hybridcompute/machines\'), equals(parameters(\'resourceType\'), variables(\'dcrResourceType\')))]'
                    name: '[variables(\'dcrAssociationName\')]'
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                    apiVersion: '2021-04-01'
                    properties: {
                      dataCollectionRuleId: '[parameters(\'dcrResourceId\')]'
                    }
                    scope: '[concat(\'Microsoft.HybridCompute/machines/\', parameters(\'resourceName\'))]'
                  }
                  {
                    condition: '[and(equals(toLower(parameters(\'type\')), \'microsoft.hybridcompute/machines\'), equals(parameters(\'resourceType\'), variables(\'dceResourceType\')))]'
                    name: '[variables(\'dceAssociationName\')]'
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                    apiVersion: '2021-04-01'
                    properties: {
                      dataCollectionEndpointId: '[parameters(\'dcrResourceId\')]'
                    }
                    scope: '[concat(\'Microsoft.HybridCompute/machines/\', parameters(\'resourceName\'))]'
                  }
                ]
              }
              parameters: {
                resourceName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
                dcrResourceId: {
                  value: '[parameters(\'dcrResourceId\')]'
                }
                type: {
                  value: '[field(\'type\')]'
                }
                resourceType: {
                  value: '[parameters(\'resourceType\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}

// Azure Monitor Agent Change Initiative for Windows Operating Systems
resource amAgentPolicySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: enableAmAgentWindowsSetName
  properties: {
    description: amAgentPolicySetDefinitionProperties.description
    displayName: enableAmAgentWindowsSetDisplayName
    metadata: amAgentPolicySetDefinitionProperties.metadata
    parameters: {
      scopeToSupportedImages: {
        type: 'boolean'
        metadata: {
          displayName: 'Scope Policy to Azure Monitor Agent-Supported Operating Systems'
          description: 'If set to true, the policy will apply only to virtual machines with supported operating systems. Otherwise, the policy will apply to all virtual machine resources in the assignment scope. For supported operating systems, see https://aka.ms/AMAOverview.'
        }
      }
      listOfWindowsImageIdToInclude: {
        type: 'Array'
        metadata: {
          displayName: 'Additional Windows Virtual Machine Images'
          description: 'List of virtual machine images that have a supported Windows OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
        }
      }
      dcrResourceId: {
        type: 'string'
        metadata: {
          displayName: 'Data Collection Rule resource Id'
          description: 'The resource Id of the Data Collection Rule resource to which the Azure Monitor Agent will be associated'
        }
      }
      resourceType: {
        type: 'string'
        metadata: {
          displayName: 'Data Collection Rule resource type'
          description: 'The type of resource to wich to associate the Azure Monitor Agent: Microsoft.Insights/dataCollectionRules or Microsoft.Insights/dataCollectionEndpoints'
        }
      }
      bringYourOwnUserAssignedManagedIdentity: {
        type: 'Boolean'
        metadata: {
          displayName: 'Bring Your Own User-Assigned Managed Identity'
          description: 'If set to true, Azure Monitor Agent will use the user-assigned managed identity specified via the \'User-Assigned Managed Identity ...\' parameters for authentication. Otherwise, Azure Monitor Agent will use the user-assigned managed identity /subscriptions/<subscription-id>/resourceGroups/built-in-identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/built-in-identity-<location> for authentication.'
        }
      }
      userAssignedManagedIdentityName: {
        type: 'String'
        metadata: {
          displayName: 'User-Assigned Managed Identity Name'
          description: 'The name of the user-assigned managed identity which Azure Monitor Agent will use for authentication when \'Bring Your Own User-Assigned Managed Identity\' is set to true.'
        }
      }
      userAssignedManagedIdentityResourceGroup: {
        type: 'String'
        metadata: {
          displayName: 'User-Assigned Managed Identity Resource Group'
          description: 'The resource group of the user-assigned managed identity which Azure Monitor Agent will use for authentication when \'Bring Your Own User-Assigned Managed Identity\' is set to true.'
        }
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: enableAmAgentWindowsVmPolicyDefinition.id
        parameters: {
          scopeToSupportedImages: {
            value: '[parameters(\'scopeToSupportedImages\')]'
          }
          listOfWindowsImageIdToInclude: {
            value: '[parameters(\'listOfWindowsImageIdToInclude\')]'
          }
          bringYourOwnUserAssignedManagedIdentity: {
            value: '[parameters(\'bringYourOwnUserAssignedManagedIdentity\')]'
          }
          userAssignedManagedIdentityName: {
            value: '[parameters(\'userAssignedManagedIdentityName\')]'
          }
          userAssignedManagedIdentityResourceGroup: {
            value: '[parameters(\'userAssignedManagedIdentityResourceGroup\')]'
          }
        }
      }
      {
        policyDefinitionId: enableAmAgentWindowsVmssPolicyDefinition.id
        parameters: {
          scopeToSupportedImages: {
            value: '[parameters(\'scopeToSupportedImages\')]'
          }
          listOfWindowsImageIdToInclude: {
            value: '[parameters(\'listOfWindowsImageIdToInclude\')]'
          }
          bringYourOwnUserAssignedManagedIdentity: {
            value: '[parameters(\'bringYourOwnUserAssignedManagedIdentity\')]'
          }
          userAssignedManagedIdentityName: {
            value: '[parameters(\'userAssignedManagedIdentityName\')]'
          }
          userAssignedManagedIdentityResourceGroup: {
            value: '[parameters(\'userAssignedManagedIdentityResourceGroup\')]'
          }
        }
      }
      {
        policyDefinitionId: dataCollectionRuleAssociationWindows.id
        parameters: {
          listOfWindowsImageIdToInclude: {
            value: '[parameters(\'listOfWindowsImageIdToInclude\')]'
          }
          dcrResourceId: {
            value: '[parameters(\'dcrResourceId\')]'
          }
          resourceType: {
            value: '[parameters(\'resourceType\')]'
          }
        }
      }
    ]
  }
}

// Azure Monitor Agent Change Initiative Assignment
resource amAgentPolicySetAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: enableAmAgentWindowsSetAssignmentName
  location: amAgentAssignmentProperties.location
  identity: {
    type: amAgentAssignmentProperties.identity
  }
  properties: {
    displayName: enableAmAgentWindowsSetAssignmentDisplayName
    description: amAgentAssignmentProperties.description
    metadata: amAgentAssignmentProperties.metadata
    policyDefinitionId: amAgentPolicySetDefinition.id
    parameters: {
      scopeToSupportedImages: {
        value: scopeToSupportedImages
      }
      listOfWindowsImageIdToInclude: {
        value: listOfWindowsImageIdToInclude
      }
      dcrResourceId: {
        value: dataCollectionRuleResourceId
      }
      resourceType: {
        value: dataCollectionRulesResourceType
      }
      bringYourOwnUserAssignedManagedIdentity: {
        value: true
      }
      userAssignedManagedIdentityName: {
        value: userAssignedManagedIdentityName
      }
      userAssignedManagedIdentityResourceGroup: {
        value: userAssignedManagedIdentityResourceGroup
      }
    }
  }
}

// Deploy the Role assignment for Azure Monitor Agent change initiative for Windows
module policySystemManagedIdentityRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: amAgentPolicySetAssignment.identity.principalId
    roleDefinitionIdOrNames: amAgentAssignmentProperties.roleDefinitionIdOrNames
  }
}

//Deploy also the Role assignment to the MGMT subscription if called on another subscription
module diagRulePolicyRoleAssignmentWinMgmtSub '../../roleAssignment/roleAssignment.bicep' = if (managementSubscriptionId != subscription().subscriptionId) {
  name: roleAssignmentNameMgmt
  scope: subscription(managementSubscriptionId)
  params: {
    managedIdentityId: amAgentPolicySetAssignment.identity.principalId
    roleDefinitionIdOrNames: amAgentAssignmentProperties.roleDefinitionIdOrNames
  }
}


// OUTPUT
output roleAssignmentDeployName string = policySystemManagedIdentityRoleAssignment.name
