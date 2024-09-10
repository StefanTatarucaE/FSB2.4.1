/*
SUMMARY: Azure Monitor agent for Linux Change Policy child module.
DESCRIPTION: Deployment of Azure Monitor agent for Linux Change Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: frederic.trapet@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. MGs not supported yet.

// PARAMETERS

@description('Specify wether the policy will apply only to supported images or also to custom linux images')
param scopeToSupportedImages bool

@description('List of virtual machine images that have supported Linux OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\'')
param listOfLinuxImageIdToInclude array = []

@description('Specify the resource ID of the Data Collection Rule for association')
param dataCollectionRuleResourceId string

@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('The Id of the management subscription. To be provided by the Monitoring parent module')
param managementSubscriptionId string

@description('Specify the name to be used for the Azure Monitor Agent for Linux Vm policy')
param enableAmAgentLinuxVmDefName string

@description('Specify the display name to be used for the Azure Monitor Agent for Linux Vm policy')
param enableAmAgentLinuxVmDefDisplayName string

@description('Specify the name to be used for the Azure Monitor Agent for Linux Vmss policy')
param enableAmAgentLinuxVmssDefName string

@description('Specify the display name to be used for Azure Monitor Agent for Linux Vm policy')
param enableAmAgentLinuxVmssDefDisplayName string

@description('Specify te name for the Azure Monitor Agent - Data Collection Rule association for Linux policy')
param dcrAssociationLinuxDefName string

@description('Specify the display name for the Azure Monitor Agent - Data Collection Rule association for Linux policy')
param dcrAssociationLinuxDefDisplayName string

@description('Desired policy effect to set Azure Monitor Agent on Linux Virtual Machines')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param enableAmAgentLinuxVmDefEffect string

@description('Desired policy effect to set Azure Monitor Agent on Linux Virtual Machine Scale Sets')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param enableAmAgentLinuxVmssDefEffect string

@description('Desired policy effect to associate the Azure Monitor Agent extension resource with a Data Collection Rule resource.')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param dcrAssociationLinuxDefEffect string

@description('Specify policy set name for Linux Azure Monitor Agent initiative')
param enableAmAgentLinuxSetName string

@description('Specify policy set display name for Linux Azure Monitor Agent initiative')
param enableAmAgentLinuxSetDisplayName string

@description('Specify policy asignment name for Linux Azure Monitor Agent initiative')
param enableAmAgentLinuxSetAssignmentName string

@description('Specify policy asignment display name for Linux Azure Monitor Agent initiative')
param enableAmAgentLinuxSetAssignmentDisplayName string

@description('Tag used for the policy rule')
param policyRuleTag string

@description('Name of the existing user assigned managed identity for monitoring in this subscription')
param userAssignedManagedIdentityName string

@description('Resource group where the existing user assigned managed identity for monitoring in this subscription is stored')
param userAssignedManagedIdentityResourceGroup string

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

// VARIABLES
// This variable holds log analytics agent for Linux VM policy details

var dataCollectionRulesResourceType = 'Microsoft.Insights/dataCollectionRules'

var amAgentLinuxVmDefinitionProperties = {
  description: 'Deploy Azure Monitoring Agent for Linux VMs if the agent is not installed'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// This variable holds the Azure Monitor agent for Linux VMSS policy details
var amAgentLinuxVmssDefinitionProperties = {
  description: 'Deploy Azure Monitoring Agent for Linux VM Scale Sets if the agent is not installed'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// This variable holds the DCR - Azure Monitor Agent association policy details
var dcrAssociationLinuxDefinitionProperties = {
  description: 'Deploy Association to link Linux virtual machines and virtual machine scale sets to the specified Data Collection Rule or the specified Data Collection Endpoint. The list of locations and OS images are updated over time as support is increased.'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// This variable holds initiative details for vm log analytics agent 
var amAgentPolicySetDefinitionProperties = {
  description: 'This initiative configures Linux machines to run Azure Monitor Agent and associates them to a Data Collection Rule'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// This variable holds the assignment details for vm log analytics agent 
var amAgentAssignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identity: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Install Azure Monitor Agent for Linux systems'
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
var trimSetName = 'lnxamagent'

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployLocation), 0, 6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(trimSetName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'

//Variable used to construct the name of the Role Assignment Deployment on the Management Subscription
var roleAssignmentNameMgmt = '${first(split(trimSetName, '-'))}-${uniqueDeployPrefix}-mgmt-roleAssignment-deployment'

// RESOURCES

// Azure Monitor Agent for Linux Vm 
resource enableAmAgentLinuxVmPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: enableAmAgentLinuxVmDefName
  properties: {
    displayName: enableAmAgentLinuxVmDefDisplayName
    description: amAgentLinuxVmDefinitionProperties.description
    policyType: amAgentLinuxVmDefinitionProperties.policyType
    mode: amAgentLinuxVmDefinitionProperties.mode
    metadata: amAgentLinuxVmDefinitionProperties.metadata
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
      listOfLinuxImageIdToInclude: {
        type: 'Array'
        metadata: {
          displayName: 'Additional Virtual Machine Images'
          description: 'List of virtual machine images that have supported Linux OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
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
              'centraluseuap'
              'eastasia'
              'eastus'
              'eastus2'
              'eastus2euap'
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
              'qatarcentral'
              'southafricanorth'
              'southcentralus'
              'southeastasia'
              'southindia'
              'swedencentral'
              'switzerlandnorth'
              'uaenorth'
              'uksouth'
              'ukwest'
              'westcentralus'
              'westeurope'
              'westindia'
              'westus'
              'westus2'
              'westus3'
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
                    like: 'Linux*'
                  }
                ]
              }
              {
                field: 'Microsoft.Compute/imageId'
                in: '[parameters(\'listOfLinuxImageIdToInclude\')]'
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'RedHat'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'RHEL'
                      'RHEL-ARM64'
                      'RHEL-BYOS'
                      'RHEL-HA'
                      'RHEL-SAP'
                      'RHEL-SAP-APPS'
                      'RHEL-SAP-HA'
                    ]
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '8*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: 'rhel-lvm7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: 'rhel-lvm8*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'SUSE'
                  }
                  {
                    anyOf: [
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'SLES'
                              'SLES-HPC'
                              'SLES-HPC-Priority'
                              'SLES-SAP'
                              'SLES-SAP-BYOS'
                              'SLES-Priority'
                              'SLES-BYOS'
                              'SLES-SAPCAL'
                              'SLES-Standard'
                            ]
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '12*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '15*'
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: 'sles-12*'
                              }
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: 'sles-15*'
                              }
                            ]
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            in: [
                              'gen1'
                              'gen2'
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'Canonical'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        equals: 'UbuntuServer'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '0001-com-ubuntu-server-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '0001-com-ubuntu-pro-*'
                      }
                    ]
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    in: [
                      '14.04.0-lts'
                      '14.04.1-lts'
                      '14.04.2-lts'
                      '14.04.3-lts'
                      '14.04.4-lts'
                      '14.04.5-lts'
                      '16_04_0-lts-gen2'
                      '16_04-lts-gen2'
                      '16.04-lts'
                      '16.04.0-lts'
                      '18_04-lts-arm64'
                      '18_04-lts-gen2'
                      '18.04-lts'
                      '20_04-lts-arm64'
                      '20_04-lts-gen2'
                      '20_04-lts'
                      '22_04-lts-gen2'
                      '22_04-lts'
                      'pro-16_04-lts-gen2'
                      'pro-16_04-lts'
                      'pro-18_04-lts-gen2'
                      'pro-18_04-lts'
                      'pro-20_04-lts-gen2'
                      'pro-20_04-lts'
                      'pro-22_04-lts-gen2'
                      'pro-22_04-lts'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'Oracle'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'Oracle-Linux'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '8*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: 'ol7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: 'ol8*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'OpenLogic'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'CentOS'
                      'Centos-LVM'
                      'CentOS-SRIOV'
                    ]
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '6*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '8*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'cloudera'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'cloudera-centos-os'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    like: '7*'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'almalinux'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'almalinux'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    like: '8*'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'ctrliqinc1648673227698'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    like: 'rocky-8*'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    like: 'rocky-8*'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'credativ'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'Debian'
                    ]
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    equals: '9'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'Debian'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'debian-10'
                      'debian-11'
                    ]
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    in: [
                      '10'
                      '10-gen2'
                      '11'
                      '11-gen2'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'microsoftcblmariner'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'cbl-mariner'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    in: [
                      '1-gen2'
                      'cbl-mariner-1'
                      'cbl-mariner-2'
                      'cbl-mariner-2-arm64'
                      'cbl-mariner-2-gen2'
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
      then: {
        effect: enableAmAgentLinuxVmDefEffect
        details: {
          type: 'Microsoft.Compute/virtualMachines/extensions'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                equals: 'AzureMonitorLinuxAgent'
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
                  extensionName: 'AzureMonitorLinuxAgent'
                  extensionPublisher: 'Microsoft.Azure.Monitor'
                  extensionType: 'AzureMonitorLinuxAgent'
                  extensionTypeHandlerVersion: '1.29'
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

// Azure Monitor Agent for Linux Vmss
resource enableAmAgentLinuxVmssPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: enableAmAgentLinuxVmssDefName
  properties: {
    displayName: enableAmAgentLinuxVmssDefDisplayName
    policyType: amAgentLinuxVmssDefinitionProperties.policyType
    mode: amAgentLinuxVmssDefinitionProperties.mode
    description: amAgentLinuxVmssDefinitionProperties.description
    metadata: amAgentLinuxVmssDefinitionProperties.metadata
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
      listOfLinuxImageIdToInclude: {
        type: 'Array'
        metadata: {
          displayName: 'Additional Virtual Machine Images'
          description: 'List of virtual machine images that have supported Linux OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
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
              'centraluseuap'
              'eastasia'
              'eastus'
              'eastus2'
              'eastus2euap'
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
              'qatarcentral'
              'southafricanorth'
              'southcentralus'
              'southeastasia'
              'southindia'
              'swedencentral'
              'switzerlandnorth'
              'uaenorth'
              'uksouth'
              'ukwest'
              'westcentralus'
              'westeurope'
              'westindia'
              'westus'
              'westus2'
              'westus3'
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
                    like: 'Linux*'
                  }
                ]
              }
              {
                field: 'Microsoft.Compute/imageId'
                in: '[parameters(\'listOfLinuxImageIdToInclude\')]'
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'RedHat'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'RHEL'
                      'RHEL-ARM64'
                      'RHEL-BYOS'
                      'RHEL-HA'
                      'RHEL-SAP'
                      'RHEL-SAP-APPS'
                      'RHEL-SAP-HA'
                    ]
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '8*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: 'rhel-lvm7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: 'rhel-lvm8*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'SUSE'
                  }
                  {
                    anyOf: [
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'SLES'
                              'SLES-HPC'
                              'SLES-HPC-Priority'
                              'SLES-SAP'
                              'SLES-SAP-BYOS'
                              'SLES-Priority'
                              'SLES-BYOS'
                              'SLES-SAPCAL'
                              'SLES-Standard'
                            ]
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '12*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '15*'
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: 'sles-12*'
                              }
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: 'sles-15*'
                              }
                            ]
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            in: [
                              'gen1'
                              'gen2'
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'Canonical'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        equals: 'UbuntuServer'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '0001-com-ubuntu-server-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '0001-com-ubuntu-pro-*'
                      }
                    ]
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    in: [
                      '14.04.0-lts'
                      '14.04.1-lts'
                      '14.04.2-lts'
                      '14.04.3-lts'
                      '14.04.4-lts'
                      '14.04.5-lts'
                      '16_04_0-lts-gen2'
                      '16_04-lts-gen2'
                      '16.04-lts'
                      '16.04.0-lts'
                      '18_04-lts-arm64'
                      '18_04-lts-gen2'
                      '18.04-lts'
                      '20_04-lts-arm64'
                      '20_04-lts-gen2'
                      '20_04-lts'
                      '22_04-lts-gen2'
                      '22_04-lts'
                      'pro-16_04-lts-gen2'
                      'pro-16_04-lts'
                      'pro-18_04-lts-gen2'
                      'pro-18_04-lts'
                      'pro-20_04-lts-gen2'
                      'pro-20_04-lts'
                      'pro-22_04-lts-gen2'
                      'pro-22_04-lts'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'Oracle'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'Oracle-Linux'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '8*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: 'ol7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: 'ol8*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'OpenLogic'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'CentOS'
                      'Centos-LVM'
                      'CentOS-SRIOV'
                    ]
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '6*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '8*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'cloudera'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'cloudera-centos-os'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    like: '7*'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'almalinux'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'almalinux'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    like: '8*'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'ctrliqinc1648673227698'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    like: 'rocky-8*'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    like: 'rocky-8*'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'credativ'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'Debian'
                    ]
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    equals: '9'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'Debian'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'debian-10'
                      'debian-11'
                    ]
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    in: [
                      '10'
                      '10-gen2'
                      '11'
                      '11-gen2'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'microsoftcblmariner'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'cbl-mariner'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    in: [
                      '1-gen2'
                      'cbl-mariner-1'
                      'cbl-mariner-2'
                      'cbl-mariner-2-arm64'
                      'cbl-mariner-2-gen2'
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
      then: {
        effect: enableAmAgentLinuxVmssDefEffect
        details: {
          type: 'Microsoft.Compute/virtualMachineScaleSets/extensions'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/type'
                equals: 'AzureMonitorLinuxAgent'
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
                  extensionName: 'AzureMonitorLinuxAgent'
                  extensionPublisher: 'Microsoft.Azure.Monitor'
                  extensionType: 'AzureMonitorLinuxAgent'
                  extensionTypeHandlerVersion: '1.29'
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

// Association between Azure Monitor Agent and Data collection rules for Linux Operating Systems
resource dataCollectionRuleAssociationLinux 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: dcrAssociationLinuxDefName
  properties: {
    displayName: dcrAssociationLinuxDefDisplayName
    policyType: dcrAssociationLinuxDefinitionProperties.policyType
    mode: dcrAssociationLinuxDefinitionProperties.mode
    description: dcrAssociationLinuxDefinitionProperties.description
    metadata: dcrAssociationLinuxDefinitionProperties.metadata
    parameters: {
      listOfLinuxImageIdToInclude: {
        type: 'Array'
        metadata: {
          displayName: 'Additional Linux Machine Images'
          description: 'List of machine images that have supported Linux OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
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
                    equals: 'linux'
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
                        in: '[parameters(\'listOfLinuxImageIdToInclude\')]'
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'RedHat'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'RHEL'
                              'RHEL-ARM64'
                              'RHEL-BYOS'
                              'RHEL-HA'
                              'RHEL-SAP'
                              'RHEL-SAP-APPS'
                              'RHEL-SAP-HA'
                            ]
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '7*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '8*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: 'rhel-lvm7*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: 'rhel-lvm8*'
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'SUSE'
                          }
                          {
                            anyOf: [
                              {
                                allOf: [
                                  {
                                    field: 'Microsoft.Compute/imageOffer'
                                    in: [
                                      'SLES'
                                      'SLES-HPC'
                                      'SLES-HPC-Priority'
                                      'SLES-SAP'
                                      'SLES-SAP-BYOS'
                                      'SLES-Priority'
                                      'SLES-BYOS'
                                      'SLES-SAPCAL'
                                      'SLES-Standard'
                                    ]
                                  }
                                  {
                                    anyOf: [
                                      {
                                        field: 'Microsoft.Compute/imageSku'
                                        like: '12*'
                                      }
                                      {
                                        field: 'Microsoft.Compute/imageSku'
                                        like: '15*'
                                      }
                                    ]
                                  }
                                ]
                              }
                              {
                                allOf: [
                                  {
                                    anyOf: [
                                      {
                                        field: 'Microsoft.Compute/imageOffer'
                                        like: 'sles-12*'
                                      }
                                      {
                                        field: 'Microsoft.Compute/imageOffer'
                                        like: 'sles-15*'
                                      }
                                    ]
                                  }
                                  {
                                    field: 'Microsoft.Compute/imageSku'
                                    in: [
                                      'gen1'
                                      'gen2'
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'Canonical'
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                equals: 'UbuntuServer'
                              }
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: '0001-com-ubuntu-server-*'
                              }
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: '0001-com-ubuntu-pro-*'
                              }
                            ]
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            in: [
                              '14.04.0-lts'
                              '14.04.1-lts'
                              '14.04.2-lts'
                              '14.04.3-lts'
                              '14.04.4-lts'
                              '14.04.5-lts'
                              '16_04_0-lts-gen2'
                              '16_04-lts-gen2'
                              '16.04-lts'
                              '16.04.0-lts'
                              '18_04-lts-arm64'
                              '18_04-lts-gen2'
                              '18.04-lts'
                              '20_04-lts-arm64'
                              '20_04-lts-gen2'
                              '20_04-lts'
                              '22_04-lts-gen2'
                              '22_04-lts'
                              'pro-16_04-lts-gen2'
                              'pro-16_04-lts'
                              'pro-18_04-lts-gen2'
                              'pro-18_04-lts'
                              'pro-20_04-lts-gen2'
                              'pro-20_04-lts'
                              'pro-22_04-lts-gen2'
                              'pro-22_04-lts'
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'Oracle'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            equals: 'Oracle-Linux'
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '7*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '8*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: 'ol7*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: 'ol8*'
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'OpenLogic'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'CentOS'
                              'Centos-LVM'
                              'CentOS-SRIOV'
                            ]
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '6*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '7*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '8*'
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'cloudera'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            equals: 'cloudera-centos-os'
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            like: '7*'
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'almalinux'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            equals: 'almalinux'
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            like: '8*'
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'ctrliqinc1648673227698'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            like: 'rocky-8*'
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            like: 'rocky-8*'
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'credativ'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'Debian'
                            ]
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            equals: '9'
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'Debian'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'debian-10'
                              'debian-11'
                            ]
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            in: [
                              '10'
                              '10-gen2'
                              '11'
                              '11-gen2'
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imagePublisher'
                            equals: 'microsoftcblmariner'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            equals: 'cbl-mariner'
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            in: [
                              '1-gen2'
                              'cbl-mariner-1'
                              'cbl-mariner-2'
                              'cbl-mariner-2-arm64'
                              'cbl-mariner-2-gen2'
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
        ]
      }
      then: {
        effect: dcrAssociationLinuxDefEffect
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

// Azure Monitor Agent Change Initiative for Linux Systems
resource amAgentPolicySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: enableAmAgentLinuxSetName
  properties: {
    description: amAgentPolicySetDefinitionProperties.description
    displayName: enableAmAgentLinuxSetDisplayName
    metadata: amAgentPolicySetDefinitionProperties.metadata
    parameters: {
      scopeToSupportedImages: {
        type: 'boolean'
        metadata: {
          displayName: 'Scope Policy to Azure Monitor Agent-Supported Operating Systems'
          description: 'If set to true, the policy will apply only to virtual machines with supported operating systems. Otherwise, the policy will apply to all virtual machine resources in the assignment scope. For supported operating systems, see https://aka.ms/AMAOverview.'
        }
      }
      listOfLinuxImageIdToInclude: {
        type: 'Array'
        metadata: {
          displayName: 'Additional Linux Virtual Machine Images'
          description: 'List of virtual machine images that have a supported Linux OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
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
        policyDefinitionId: enableAmAgentLinuxVmPolicyDefinition.id
        parameters: {
          scopeToSupportedImages: {
            value: '[parameters(\'scopeToSupportedImages\')]'
          }
          listOfLinuxImageIdToInclude: {
            value: '[parameters(\'listOfLinuxImageIdToInclude\')]'
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
        policyDefinitionId: enableAmAgentLinuxVmssPolicyDefinition.id
        parameters: {
          scopeToSupportedImages: {
            value: '[parameters(\'scopeToSupportedImages\')]'
          }
          listOfLinuxImageIdToInclude: {
            value: '[parameters(\'listOfLinuxImageIdToInclude\')]'
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
        policyDefinitionId: dataCollectionRuleAssociationLinux.id
        parameters: {
          listOfLinuxImageIdToInclude: {
            value: '[parameters(\'listOfLinuxImageIdToInclude\')]'
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
  name: enableAmAgentLinuxSetAssignmentName
  location: amAgentAssignmentProperties.location
  identity: {
    type: amAgentAssignmentProperties.identity
  }
  properties: {
    displayName: enableAmAgentLinuxSetAssignmentDisplayName
    description: amAgentAssignmentProperties.description
    metadata: amAgentAssignmentProperties.metadata
    policyDefinitionId: amAgentPolicySetDefinition.id
    parameters: {
      scopeToSupportedImages: {
        value: scopeToSupportedImages
      }
      listOfLinuxImageIdToInclude: {
        value: listOfLinuxImageIdToInclude
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

// Deploy the Role assignment for Azure Monitor Agent change initiative for Linux
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
