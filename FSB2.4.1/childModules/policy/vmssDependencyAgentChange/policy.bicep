/*
SUMMARY: Virtual Machine Scale Sets dependency agent Change Policy child module.
DESCRIPTION: Deployment of Vm Scale Sets dependency agent Change Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Specify policy name for enable dependency agent for Windows Vm Scale Set policy')
param vmssEnableDependencyAgentWinDefName string

@description('Specify policy display name for enable dependency agent for Windows Vm Scale Set policy')
param vmssEnableDependencyAgentWinDefDisplayName string

@description('Desired policy effect to set dependency agent on Windows Virtual Machine Sets.')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param vmssEnableDependencyAgentWinDefEffect string

@description('Specify policy name for enable dependency agent for Linux Vm Scale Sets policy')
param vmssEnableDependencyAgentLinuxDefName string

@description('Specify policy display name for enable dependency agent for Linux Vm Scale Sets policy')
param vmssEnableDependencyAgentLinuxDefDisplayName string

@description('Desired policy effect to set dependency agent on Linux Virtual Machine Sets.')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param vmssEnableDependencyAgentLinuxDefEffect string

@description('Specify policy set name for vm scale sets dependency agent initiative')
param vmssEnableDependencyAgentSetName string

@description('Specify policy set display name for vm scale sets dependency agent initiative')
param vmssEnableDependencyAgentSetDisplayName string

@description('Specify policy asignment name for vm scale sets dependency agent initiative')
param vmssEnableDependencyAgentSetAssignmentName string

@description('Specify policy asignment display name for vm scale sets dependency agent initiative')
param vmssEnableDependencyAgentSetAssignmentDisplayName string

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

@description('Tag used for the policy rule')
param policyRuleTag string

// VARIABLES
// This variable holds dependency Agent for Windows VM policy details
var dependencyAgentWinVmssDefinitionProperties = {
  description: 'Deploy Dependency agent for Windows Scalesets if the virtual machine image is in the list defined and the agent is not installed.'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// This variable holds dependency Agent for Linux VM policy details
var dependencyAgentLinuxVmssDefinitionProperties = {
  description: 'Deploy Dependency agent for Linux Scalesets if the virtual machine image is in the list defined and the agent is not installed.'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// This variable holds initiative details for vm dependency agent 
var dependencyAgentPolicySetDefinitionProperties = {
  description: 'This initiative deploys the Dependency agent for both Windows and Linux ScaleSets'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// This variable holds the assignment details for vm dependency agent 
var dependencyAgentAssignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identity: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Dependency agent is installed on ScaleSets'
  metadata: {
    source: policyMetadata
  }
  roleDefinitionIdOrNames: [
    'VM Contributor'
  ]
}

// Trim variable vmssEnableDependencyAgentSetName to support role assignment name condition maximum length of '64'
var trimSetName = 'vmssdependency'

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId,deployLocation),0 ,6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(trimSetName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'


// RESOURCES

// Dependency Agent for Windows Vmss
resource enableDependencyAgentWinVmPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: vmssEnableDependencyAgentWinDefName
  properties: {
    displayName: vmssEnableDependencyAgentWinDefDisplayName
    description: dependencyAgentWinVmssDefinitionProperties.description
    policyType: dependencyAgentWinVmssDefinitionProperties.policyType
    mode: dependencyAgentWinVmssDefinitionProperties.mode
    metadata: dependencyAgentWinVmssDefinitionProperties.metadata
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
            anyOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/storageProfile.osDisk.osType'
                contains: 'Windows'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'MicrosoftWindowsServer'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'MicrosoftWindowsServerHPCPack'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'MicrosoftSQLServer'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'MicrosoftRServer'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'MicrosoftVisualStudio'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'MicrosoftDynamicsAX'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'microsoft-ads'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'MicrosoftWindowsDesktop'
              }
            ]
          }
        ]
      }
      then: {
        effect: vmssEnableDependencyAgentWinDefEffect
        details: {
          type: 'Microsoft.Compute/virtualMachineScaleSets/extensions'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/type'
                equals: 'DependencyAgentWindows'
              }
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/publisher'
                equals: 'Microsoft.Azure.Monitoring.DependencyAgent'
              }
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/EnableAutomaticUpgrade'
                equals: true
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  vmName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {
                  vmExtensionName: 'DependencyAgentWindows'
                  vmExtensionPublisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
                  vmExtensionType: 'DependencyAgentWindows'
                  vmExtensionTypeHandlerVersion: '9.10'
                }
                resources: [
                  {
                    type: 'Microsoft.Compute/virtualMachineScaleSets/extensions'
                    name: '[concat(parameters(\'vmName\'), \'/\', variables(\'vmExtensionName\'))]'
                    apiVersion: '2021-04-01'
                    location: '[parameters(\'location\')]'
                    properties: {
                      publisher: '[variables(\'vmExtensionPublisher\')]'
                      type: '[variables(\'vmExtensionType\')]'
                      typeHandlerVersion: '[variables(\'vmExtensionTypeHandlerVersion\')]'
                      autoUpgradeMinorVersion: true
                      enableAutomaticUpgrade: true
                    }
                  }
                ]
                outputs: {
                  policy: {
                    type: 'string'
                    value: '[concat(\'Enabled extension for \', \': \', parameters(\'vmName\'))]'
                  }
                }
              }
              parameters: {
                vmName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}

// Dependency Agent for Linux Vmss
resource enableDependencyAgentLinuxVmPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: vmssEnableDependencyAgentLinuxDefName
  properties: {
    displayName: vmssEnableDependencyAgentLinuxDefDisplayName
    description: dependencyAgentLinuxVmssDefinitionProperties.description
    policyType: dependencyAgentLinuxVmssDefinitionProperties.policyType
    mode: dependencyAgentLinuxVmssDefinitionProperties.mode
    metadata: dependencyAgentLinuxVmssDefinitionProperties.metadata
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
            anyOf: [

              {
                field: 'Microsoft.Compute/virtualMachines/storageProfile.osDisk.osType'
                contains: 'Linux'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'RedHat'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'SUSE'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'Canonical'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'OpenLogic'
              }
              {
                field: 'Microsoft.Compute/imagePublisher'
                equals: 'cloudera'
              }
            ]
          }
        ]
      }
      then: {
        effect: vmssEnableDependencyAgentLinuxDefEffect
        details: {
          type: 'Microsoft.Compute/virtualMachineScaleSets/extensions'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/type'
                equals: 'DependencyAgentLinux'
              }
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/publisher'
                equals: 'Microsoft.Azure.Monitoring.DependencyAgent'
              }
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/EnableAutomaticUpgrade'
                equals: true
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  vmName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {
                  vmExtensionName: 'DependencyAgentLinux'
                  vmExtensionPublisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
                  vmExtensionType: 'DependencyAgentLinux'
                  vmExtensionTypeHandlerVersion: '9.10'
                }
                resources: [
                  {
                    type: 'Microsoft.Compute/virtualMachineScaleSets/extensions'
                    name: '[concat(parameters(\'vmName\'), \'/\', variables(\'vmExtensionName\'))]'
                    apiVersion: '2021-04-01'
                    location: '[parameters(\'location\')]'
                    properties: {
                      publisher: '[variables(\'vmExtensionPublisher\')]'
                      type: '[variables(\'vmExtensionType\')]'
                      typeHandlerVersion: '[variables(\'vmExtensionTypeHandlerVersion\')]'
                      autoUpgradeMinorVersion: true
                      enableAutomaticUpgrade: true
                    }
                  }
                ]
                outputs: {
                  policy: {
                    type: 'string'
                    value: '[concat(\'Enabled extension for \', \': \', parameters(\'vmName\'))]'
                  }
                }
              }
              parameters: {
                vmName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}

// Vm Dependency Agent Change Initiative
resource dependencyAgentPolicySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: vmssEnableDependencyAgentSetName
  properties: {
    description: dependencyAgentPolicySetDefinitionProperties.description
    displayName: vmssEnableDependencyAgentSetDisplayName
    metadata: dependencyAgentPolicySetDefinitionProperties.metadata
    parameters: {}
    policyDefinitions: [
      {
        policyDefinitionId: enableDependencyAgentWinVmPolicyDefinition.id
      }
      {
        policyDefinitionId: enableDependencyAgentLinuxVmPolicyDefinition.id
      }
    ]
  }
}

// Vm Dependency Agent Change Initiative Assignment
resource dependencyAgentPolicyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: vmssEnableDependencyAgentSetAssignmentName
  location: dependencyAgentAssignmentProperties.location
  identity: {
    type: dependencyAgentAssignmentProperties.identity
  }
  properties: {
    displayName: vmssEnableDependencyAgentSetAssignmentDisplayName
    description: dependencyAgentAssignmentProperties.description
    metadata: dependencyAgentAssignmentProperties.metadata
    policyDefinitionId: dependencyAgentPolicySetDefinition.id
    parameters: {
    }
  }
}

// Deploy the Role assignment for ACR change initiative
module policySystemManagedIdentityRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: dependencyAgentPolicyAssignment.identity.principalId
    roleDefinitionIdOrNames: dependencyAgentAssignmentProperties.roleDefinitionIdOrNames
  }
}

// OUTPUT
output roleAssignmentDeployName string = policySystemManagedIdentityRoleAssignment.name
