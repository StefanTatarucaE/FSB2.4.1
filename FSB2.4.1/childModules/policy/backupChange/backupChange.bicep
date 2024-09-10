/*
SUMMARY: Enable Backup - DINE Policy
DESCRIPTION: Policy to enable Backup and add Backup Items into a Backup Policy of a specific Recovery Services Vault from a location.
AUTHOR/S: Eviden Langingzone for Azure Team
VERSION: 0.0.1
*/

// SCOPE

targetScope = 'subscription' //Deploying at Subscription scope.

// PARAMETERS
@description('Name of the policy definition that will be generated from the Naming module')
param backupDefName string

@description('Name of the policy assignment that will be generated from the Naming module')
param backupDefAssignmentName string

@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Name of the backup tag for which the DINE policy will kick in and enable backup for the tagged VM. Example: EvidenBackup')
param backupTagName string

@description('Name of the Eviden Managed tag for which the DINE policy will kick in and enable backup for the tagged VM. Example: EvidenManaged')
param managedTagName string

@description('A JSON structure used to specify the backup policy configuration. When used in a parent module, this will be the same parameter used by the RecoveryServicesVault Module')
param backupPolicyConfigurations object

@description('Specify the location of the VMs that you want to protect. VMs will be backed up to a vault in the same location.')
param vaultLocation string

@description('Provide the Recovery Services Vault ID')
param vaultId string

// VARIABLES

var backupPolicyDefinitionProperties = {
  policyType: 'Custom'
    mode: 'all'
    description: 'Enforce backup for all virtual machines by backing them up to an existing recovery services vault in the same location and subscription as the virtual machine. This is done based on presence of tags. Tag value for EvidenBackup tag will indicate in which Backup Policy the VM will be incorporated. '
    metadata: {
      version: '1.0.0-preview'
      preview: true
      category: 'Backup'
      source: policyMetadata
    }
}
var backupPolicyAssignmentProperties = {
  description: 'Backup IAAS VMs into Recovery Services Vault'
    metadata: {
      source: policyMetadata
    }
    identity: {
      type: 'SystemAssigned'
    }
}

#disable-next-line no-loc-expr-outside-params
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployment().location),0 ,6)
var roleAssignmentName = '${first(split(backupDefName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'
var roleDefinitionIdOrNames = [
  'Backup Contributor'
  'VM Contributor'
  ]


// DEPLOY POLICY DEFINITIONS

resource backupPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2019-06-01' = [for config in backupPolicyConfigurations.list: {
  name: '${backupDefName}-${config.backupTagNamePrefix}-Enhanced' 
  properties: {
    displayName: 'Enable VM backup in a Recovery Vault in the same location as the VM and include the VM in the ${config.backupTagNamePrefix}-Enhanced backup policy'
    policyType: backupPolicyDefinitionProperties.policyType
    mode: backupPolicyDefinitionProperties.mode
    description: backupPolicyDefinitionProperties.description
    metadata: backupPolicyDefinitionProperties.metadata
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            field: 'location'
            equals: vaultLocation
          }
          {
            field: 'tags[${backupTagName}]'
            equals: '${config.backupTagNamePrefix}-Enhanced'
          }
          {
            field: 'tags[${managedTagName}]'
            equals: 'true'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
            '/providers/microsoft.authorization/roleDefinitions/5e467623-bb1f-42f4-a55d-6e525e11384b'
          ]
          existenceCondition: {
            field: 'Microsoft.RecoveryServices/backupprotecteditems/policyId'
            contains: '${config.backupTagNamePrefix}-Enhanced'
          }
          type: 'Microsoft.RecoveryServices/backupprotecteditems'
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  backupPolicyId: {
                    type: 'String'
                  }
                  fabricName: {
                    type: 'String'
                  }
                  protectionContainers: {
                    type: 'String'
                  }
                  protectedItems: {
                    type: 'String'
                  }
                  sourceResourceId: {
                    type: 'String'
                  }
                }
                resources: [
                  {
                    apiVersion: '2017-05-10'
                    name: '[concat(\'DeployProtection-\',uniqueString(parameters(\'protectedItems\')))]'
                    type: 'Microsoft.Resources/deployments'
                    resourceGroup: '[first(skip(split(parameters(\'backupPolicyId\'), \'/\'), 4))]'
                    subscriptionId: '[first(skip(split(parameters(\'backupPolicyId\'), \'/\'), 2))]'
                    properties: {
                      mode: 'Incremental'
                      template: {
                        '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                        contentVersion: '1.0.0.0'
                        parameters: {
                          backupPolicyId: {
                            type: 'String'
                          }
                          fabricName: {
                            type: 'String'
                          }
                          protectionContainers: {
                            type: 'String'
                          }
                          protectedItems: {
                            type: 'String'
                          }
                          sourceResourceId: {
                            type: 'String'
                          }
                        }
                        resources: [
                          {
                            type: 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems'
                            name: '[concat(first(skip(split(parameters(\'backupPolicyId\'), \'/\'), 8)), \'/\', parameters(\'fabricName\'), \'/\',parameters(\'protectionContainers\'), \'/\', parameters(\'protectedItems\'))]'
                            apiVersion: '2016-06-01'
                            properties: {
                              protectedItemType: 'Microsoft.Compute/virtualMachines'
                              policyId: '[parameters(\'backupPolicyId\')]'
                              sourceResourceId: '[parameters(\'sourceResourceId\')]'
                            }
                          }
                        ]
                      }
                      parameters: {
                        backupPolicyId: {
                          value: '[parameters(\'backupPolicyId\')]'
                        }
                        fabricName: {
                          value: '[parameters(\'fabricName\')]'
                        }
                        protectionContainers: {
                          value: '[parameters(\'protectionContainers\')]'
                        }
                        protectedItems: {
                          value: '[parameters(\'protectedItems\')]'
                        }
                        sourceResourceId: {
                          value: '[parameters(\'sourceResourceId\')]'
                        }
                      }
                    }
                  }
                ]
              }
              parameters: {
                backupPolicyId: {
                  value: '${vaultId}/backuppolicies/${config.backupTagNamePrefix}-Enhanced'
                }
                fabricName: {
                  value: 'Azure'
                }
                protectionContainers: {
                  value: '[concat(\'iaasvmcontainer;iaasvmcontainerv2;\', resourceGroup().name, \';\' ,field(\'name\'))]'
                }
                protectedItems: {
                  value: '[concat(\'vm;iaasvmcontainerv2;\', resourceGroup().name, \';\' ,field(\'name\'))]'
                }
                sourceResourceId: {
                  value: '[concat(\'/subscriptions/\', subscription().subscriptionId, \'/resourceGroups/\', resourceGroup().name, \'/providers/Microsoft.Compute/virtualMachines/\',field(\'name\'))]'
                }
              }
            }
          }
        }
      }
    }
  }
}]

// DEPLOY POLICY ASSIGNMENTS

resource backupPolicyAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = [for config in backupPolicyConfigurations.list : {
  name: '${backupDefAssignmentName}-${config.backupTagNamePrefix}-Enhanced'
  location: vaultLocation
  properties: {
    displayName: 'Enable VM backup in a Recovery Vault in the same location as the VM and include the VM in the ${config.backupTagNamePrefix}-Enhanced backup policy'
    description: backupPolicyAssignmentProperties.description
    metadata: backupPolicyAssignmentProperties.metadata
    policyDefinitionId: '${subscription().id}/providers/Microsoft.Authorization/policyDefinitions/${backupDefName}-${config.backupTagNamePrefix}-Enhanced'
    parameters: {}
  }
  identity: backupPolicyAssignmentProperties.identity
  dependsOn: [
    backupPolicyDefinition
  ]
}]

// DEPLOY ROLE ASSIGNMENTS

module policySystemManagedIdentityRoleAssignment '../../roleAssignment/roleAssignment.bicep' = [for config in backupPolicyConfigurations.list : {
  name: '${roleAssignmentName}-${config.backupTagNamePrefix}-Enhanced'
  params: {
    managedIdentityId: toLower(reference('/providers/Microsoft.Authorization/policyAssignments/${backupDefAssignmentName}-${config.backupTagNamePrefix}-Enhanced', '2018-05-01', 'Full').identity.principalId)
    roleDefinitionIdOrNames: roleDefinitionIdOrNames
  }
}]
