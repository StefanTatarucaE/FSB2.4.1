/*
SUMMARY: Deploy Guest Configuration Agent
DESCRIPTION: Deployment of Guest Configuration Agent (extension) for both Windows and Linux Operating Systems. Consists of definition, initiative, assignment & role assignment.
AUTHOR/S: ELZ Azure Team
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

@description('Specify policy definition name for Guest Configuration - Windows')
param guestConfigChangeWinDefName string

@description('Specify policy definition display name Guest Configuration - Windows')
param guestConfigChangeWinDefDisplayName string

@description('Specify policy definition name for Guest Configuration - Linux')
param guestConfigChangeLinuxDefName string

@description('Specify policy definition display name Guest Configuration - Linux')
param guestConfigChangeLinuxDefDisplayName string

@description('Specify policy Initative Name for Guest Configuration')
param guestConfigChangeSetName string

@description('Specify policy Initative Display Name for Guest Configuration')
param guestConfigChangeSetDisplayName string

@description('Specify policy Assignment Name for Guest Configuration')
param guestConfigChangeAssignmentName string

@description('Specify policy Assignment Display Name for Guest Configuration')
param guestConfigChangeAssignmentDisplayName string

@description('Tag used for the policy rule')
param policyRuleTag string

// VARIABLES
//Variable which holds the definition set details
var defGuestConfigAgentWin = {
  description: 'Deploy Guest Configuration agent if the virtual machine image is in the list defined and the agent is not installed.'
  metadata: {
    category: 'Guest Configuration'
    source: policyMetadata
  }
  mode: 'All'
  policyType: 'Custom'
}

//Variable which holds the definition set details
var defGuestConfigAgentLinux = {
  description: 'Deploy Dependency agent if the virtual machine image is in the list defined and the agent is not installed.'
  metadata: {
    source: policyMetadata
    category: 'Guest Configuration'
  }
  mode: 'All'
  policyType: 'Custom'
}

//Variable which holds the assignment details
var initiativeGuestConfigAgent = {
  description: 'This initiative deploys the Guest Configuration agent for both Windows and Linux'
  metadata: {
    source: policyMetadata
    category: 'Guest Configuration'
  }
}

//Variable which holds the assignment details
var assignmentGuestConfigAgent = {
  description: 'Ensures that the Guest Configuration agent is installed'
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  metadata: {
    source: policyMetadata
  }
  identityType: 'SystemAssigned'
  roleDefinitionIdOrNames: [
    'Contributor'
  ]
}

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId,deployLocation),0 ,6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(guestConfigChangeSetName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'

resource defDeployGuestConfigAgentWin 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: guestConfigChangeWinDefName
  properties: {
    displayName: guestConfigChangeWinDefDisplayName
    policyType: defGuestConfigAgentWin.policyType
    mode: defGuestConfigAgentWin.mode
    description: defGuestConfigAgentWin.description
    metadata: defGuestConfigAgentWin.metadata
    parameters: {
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
        effect: 'DeployIfNotExists'
        details: {
          type: 'Microsoft.Compute/virtualMachines/extensions'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/publisher'
                equals: 'Microsoft.GuestConfiguration'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                equals: 'ConfigurationforWindows'
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
                  vmExtensionName: 'AzurePolicyforWindows'
                  vmExtensionPublisher: 'Microsoft.GuestConfiguration'
                  vmExtensionType: 'ConfigurationforWindows'
                  vmExtensionTypeHandlerVersion: '1.1'
                }
                resources: [
                  {
                    type: 'Microsoft.Compute/virtualMachines/extensions'
                    name: '[concat(parameters(\'vmName\'), \'/\', variables(\'vmExtensionName\'))]'
                    apiVersion: '2022-03-01'
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

resource defDeployGuestConfigAgentLinux 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: guestConfigChangeLinuxDefName
  properties: {
    displayName: guestConfigChangeLinuxDefDisplayName
    policyType: defGuestConfigAgentLinux.policyType
    mode: defGuestConfigAgentLinux.mode
    description: defGuestConfigAgentLinux.description
    metadata: defGuestConfigAgentLinux.metadata
    parameters: {
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
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Compute/virtualMachines/extensions'
          name: 'AzurePolicyforLinux'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/publisher'
                equals: 'Microsoft.GuestConfiguration'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                equals: 'ConfigurationforLinux'
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
                  vmExtensionName: 'AzurePolicyforLinux'
                  vmExtensionPublisher: 'Microsoft.GuestConfiguration'
                  vmExtensionType: 'ConfigurationforLinux'
                  vmExtensionTypeHandlerVersion: '1.0'
                }
                resources: [
                  {
                    type: 'Microsoft.Compute/virtualMachines/extensions'
                    name: '[concat(parameters(\'vmName\'), \'/\', variables(\'vmExtensionName\'))]'
                    apiVersion: '2022-03-01'
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

resource initativeDeployGuestConfigAgent 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: guestConfigChangeSetName
  properties: {
    displayName: guestConfigChangeSetDisplayName
    description: initiativeGuestConfigAgent.description
    metadata: initiativeGuestConfigAgent.metadata
    parameters: {
    }
    policyDefinitions: [
      {
        policyDefinitionId: defDeployGuestConfigAgentWin.id
        parameters: {
        }
      }
      {
        policyDefinitionId: defDeployGuestConfigAgentLinux.id
        parameters: {
        }
      }
    ]
  }
}

resource assignmentDeployGuestConfigAgent 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: guestConfigChangeAssignmentName
  location: assignmentGuestConfigAgent.location
  properties: {
    displayName: guestConfigChangeAssignmentDisplayName
    description: assignmentGuestConfigAgent.description
    metadata: assignmentGuestConfigAgent.metadata
    policyDefinitionId: initativeDeployGuestConfigAgent.id
    parameters: {
    }
  }
  identity: {
    type: assignmentGuestConfigAgent.identityType
  }
}

module policySystemManagedIdentityRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: assignmentDeployGuestConfigAgent.identity.principalId
    roleDefinitionIdOrNames: assignmentGuestConfigAgent.roleDefinitionIdOrNames
  }
}
