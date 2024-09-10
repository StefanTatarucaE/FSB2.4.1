/*
SUMMARY: Vm dependency agent Change Policy child module.
DESCRIPTION: Deployment of Vm dependency agent Change Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Specify policy name for enable dependency agent for Windows Vm policy')
param vmEnableDependencyAgentWinDefName string

@description('Specify policy display name for enable dependency agent for Windows Vm policy')
param vmEnableDependencyAgentWinDefDisplayName string

@description('Desired policy effect to set dependency agent on Windows Virtual Machine.')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param vmEnableDependencyAgentWinDefEffect string

@description('Specify policy name for enable dependency agent for Linux Vm policy')
param vmEnableDependencyAgentLinuxDefName string

@description('Specify policy display name for enable dependency agent for Linux Vm policy')
param vmEnableDependencyAgentLinuxDefDisplayName string

@description('Desired policy effect to set dependency agent on Linux Virtual Machine.')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param vmEnableDependencyAgentLinuxDefEffect string

@description('Specify policy set name for vm dependency agent initiative')
param vmEnableDependencyAgentSetName string

@description('Specify policy set display name for vm dependency agent initiative')
param vmEnableDependencyAgentSetDisplayName string

@description('Specify policy asignment name for vm dependency agent initiative')
param vmEnableDependencyAgentSetAssignmentName string

@description('Specify policy asignment display name for vm dependency agent initiative')
param vmEnableDependencyAgentSetAssignmentDisplayName string

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

@description('Tag used for the policy rule')
param policyRuleTag string

// VARIABLES
// This variable holds dependency Agent for Windows VM policy details
var dependencyAgentWinVmDefinitionProperties = {
  description: 'Deploy Dependency agent for Windows virtual machines if the virtual machine image is in the list defined and the agent is not installed.'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// This variable holds dependency Agent for Linux VM policy details
var dependencyAgentLinuxVmDefinitionProperties = {
  description: 'Deploy Dependency agent for Linux virtual machines if the virtual machine image is in the list defined and the agent is not installed.'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// This variable holds initiative details for vm dependency agent 
var dependencyAgentPolicySetDefinitionProperties = {
  description: 'This initiative deploys the dependency agent for both Windows and Linux systems'
  metadata: {
    source: policyMetadata
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

// This variable holds the assignment details for vm dependency agent 
var dependencyAgentAssignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identity: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Dependency agent is installed inside the Virtual Machine'
  metadata: {
    source: policyMetadata
  }
  roleDefinitionIdOrNames: [
    'Log Analytics Contributor'
  ]
}

// Trim variable vmEnableDependencyAgentSetName to support role assignment name condition maximum length of '64'
var trimSetName = 'vmdependency'

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId,deployLocation),0 ,6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(trimSetName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'


// RESOURCES

// Dependency Agent for Windows Vm 
resource enableDependencyAgentWinVmPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: vmEnableDependencyAgentWinDefName
  properties: {
    displayName: vmEnableDependencyAgentWinDefDisplayName
    description: dependencyAgentWinVmDefinitionProperties.description
    policyType: dependencyAgentWinVmDefinitionProperties.policyType
    mode: dependencyAgentWinVmDefinitionProperties.mode
    metadata: dependencyAgentWinVmDefinitionProperties.metadata
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
            field: 'tags.DatabricksEnvironment'
            exists: false
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
        effect: vmEnableDependencyAgentWinDefEffect
        details: {
          type: 'Microsoft.Compute/virtualMachines/extensions'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                equals: 'DependencyAgentWindows'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/publisher'
                equals: 'Microsoft.Azure.Monitoring.DependencyAgent'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/provisioningState'
                equals: 'Succeeded'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade'
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
                    type: 'Microsoft.Compute/virtualMachines/extensions'
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
                    value: '[concat(\'Enabled extension for VM\', \': \', parameters(\'vmName\'))]'
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

// Dependency Agent for Linux Vm 
resource enableDependencyAgentLinuxVmPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: vmEnableDependencyAgentLinuxDefName
  properties: {
    displayName: vmEnableDependencyAgentLinuxDefDisplayName
    description: dependencyAgentLinuxVmDefinitionProperties.description
    policyType: dependencyAgentLinuxVmDefinitionProperties.policyType
    mode: dependencyAgentLinuxVmDefinitionProperties.mode
    metadata: dependencyAgentLinuxVmDefinitionProperties.metadata
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
            field: 'tags.DatabricksEnvironment'
            exists: false
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
        effect: vmEnableDependencyAgentLinuxDefEffect
        details: {
          type: 'Microsoft.Compute/virtualMachines/extensions'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                equals: 'DependencyAgentLinux'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/publisher'
                equals: 'Microsoft.Azure.Monitoring.DependencyAgent'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/provisioningState'
                equals: 'Succeeded'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade'
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
                    type: 'Microsoft.Compute/virtualMachines/extensions'
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
                    value: '[concat(\'Enabled extension for VM\', \': \', parameters(\'vmName\'))]'
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
  name: vmEnableDependencyAgentSetName
  properties: {
    description: dependencyAgentPolicySetDefinitionProperties.description
    displayName: vmEnableDependencyAgentSetDisplayName
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
  name: vmEnableDependencyAgentSetAssignmentName
  location: dependencyAgentAssignmentProperties.location
  identity: {
    type: dependencyAgentAssignmentProperties.identity
  }
  properties: {
    displayName: vmEnableDependencyAgentSetAssignmentDisplayName
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
