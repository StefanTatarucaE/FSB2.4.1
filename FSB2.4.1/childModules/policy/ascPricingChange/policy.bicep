/*
SUMMARY: Security Center Policy child module.
DESCRIPTION: Deployment of Security Center Policy. Consists of definitionassignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the pricing tier for Azure Security Center for the related resource types.')
param pricingTier object

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

@description('Specify policy definition name for ASC pricing change')
param ascPricingChangeDefName string

@description('Specify policy definition display name for ASC pricing change')
param ascPricingChangeDefDisplayName string

@description('Specify policy assignment name for ASC pricing change')
param ascPricingChangeDefAssignmentName string

@description('Specify policy assignment display name for ASC pricing change')
param ascPricingChangeDefAssignmentDisplayName string

@allowed([
  'P1'
  'P2'
])
@description('Specify sub plan for Virtual machines')
param virtualMachinesSubPlan string

// VARIABLES
// This variable holds the assignment details for ASC Pricing policy 
var ascPricingChangeAssignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identity: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Standard Tier is enabled for Azure Security Center'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  roleDefinitionIdOrNames: [
    'Contributor'
  ]
}

// This variable holds pricing tier details for Azure Security Center 
var ascPricingChangeDefinitionProperties = {
  description: 'This policy automatically enforce Standard tier for Azure Security Center'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

var deploymentInfo = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
}

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployLocation), 0, 6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(ascPricingChangeDefName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'

// RESOURCES

// Policy to set pricing tier for Microsoft Defender(ASC)
resource deployAscPricingPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: ascPricingChangeDefName
  properties: {
    displayName: ascPricingChangeDefDisplayName
    description: ascPricingChangeDefinitionProperties.description
    policyType: ascPricingChangeDefinitionProperties.policyType
    mode: ascPricingChangeDefinitionProperties.mode
    metadata: ascPricingChangeDefinitionProperties.metadata
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Security/pricings'
          }
          {
            field: 'Microsoft.Security/pricings/deprecated'
            notequals: true
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Security/pricings'
          deploymentScope: 'Subscription'
          existenceScope: 'Subscription'
          name: '[field(\'name\')]'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          existenceCondition: {
            anyOf: [
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'appServicesTier') ? pricingTier.appServicesTier : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'AppServices'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'Containers') ? pricingTier.Containers : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'Containers'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'Api') ? pricingTier.api : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'Api'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'cloudposture') ? pricingTier.cloudposture : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'cloudposture'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'CosmosDbs') ? pricingTier.CosmosDbs : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'CosmosDbs'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'dns') ? pricingTier.dns : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'dns'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'arm') ? pricingTier.arm : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'arm'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'opensourcerelationaldatabases') ? pricingTier.opensourcerelationaldatabases : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'opensourcerelationaldatabases'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'keyVaultsTier') ? pricingTier.keyVaultsTier : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'KeyVaults'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'sqlServersTier') ? pricingTier.sqlServersTier : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'SqlServers'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'sqlServerVirtualMachinesTier') ? pricingTier.sqlServerVirtualMachinesTier : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'SqlServerVirtualMachines'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'storageAccountsTier') ? pricingTier.storageAccountsTier : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'StorageAccounts'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Security/pricings/pricingTier'
                    equals: contains(pricingTier, 'virtualMachinesTier') ? pricingTier.virtualMachinesTier : 'Free'
                  }
                  {
                    field: 'name'
                    equals: 'VirtualMachines'
                  }
                ]
              }
            ]
          }
          deployment: {
            location: deploymentInfo.location
            properties: {
              mode: 'incremental'
              parameters: {
                api: {
                  value: contains(pricingTier, 'api') ? pricingTier.api : 'Free'
                }
                virtualMachinesTier: {
                  value: contains(pricingTier, 'virtualMachinesTier') ? pricingTier.virtualMachinesTier : 'Free'
                }
                virtualMachinesSubPlan: {
                  value: contains(pricingTier, 'virtualMachinesTier') && (pricingTier.virtualMachinesTier != 'Free') ? virtualMachinesSubPlan : ''
                }
                appServicesTier: {
                  value: contains(pricingTier, 'appServicesTier') ? pricingTier.appServicesTier : 'Free'
                }
                sqlServersTier: {
                  value: contains(pricingTier, 'sqlServersTier') ? pricingTier.sqlServersTier : 'Free'
                }
                CosmosDbs: {
                  value: contains(pricingTier, 'CosmosDbs') ? pricingTier.CosmosDbs : 'Free'
                }
                cloudPosture: {
                  value: contains(pricingTier, 'cloudPosture') ? pricingTier.cloudPosture : 'Free'
                }
                sqlServerVirtualMachinesTier: {
                  value: contains(pricingTier, 'sqlServerVirtualMachinesTier') ? pricingTier.sqlServerVirtualMachinesTier : 'Free'
                }
                storageAccountsTier: {
                  value: contains(pricingTier, 'storageAccountsTier') ? pricingTier.storageAccountsTier : 'Free'
                }
                containers: {
                  value: contains(pricingTier, 'Containers') ? pricingTier.Containers : 'Free'
                }
                dns: {
                  value: contains(pricingTier, 'dns') ? pricingTier.dns : 'Free'
                }
                opensourcerelationaldatabases: {
                  value: contains(pricingTier, 'opensourcerelationaldatabases') ? pricingTier.opensourcerelationaldatabases : 'Free'
                }
                arm: {
                  value: contains(pricingTier, 'arm') ? pricingTier.arm : 'Free'
                }
                keyVaultsTier: {
                  value: contains(pricingTier, 'keyVaultsTier') ? pricingTier.keyVaultsTier : 'Free'
                }
                sensitiveDataDiscovery: {
                  value: pricingTier.cloudPosture == 'Free' ? 'False' : pricingTier.cloudPostureExtensions.sensitiveDataDiscovery
                }
                containerRegistriesVulnerabilityAssessments: {
                  value: pricingTier.cloudPosture == 'Free' ? 'False' : pricingTier.cloudPostureExtensions.containerRegistriesVulnerabilityAssessments
                }
                agentlessDiscoveryForKubernetes: {
                  value:pricingTier.cloudPosture == 'Free' ? 'False' : pricingTier.cloudPostureExtensions.agentlessDiscoveryForKubernetes
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  virtualMachinesTier: {
                    type: 'String'
                    metadata: {
                      displayName: 'virtualMachinesTier'
                      description: 'Specifiy whether you want to enable Standard tier for Virtual Machine resource type'
                    }
                  }
                  api: {
                    type: 'String'
                    metadata: {
                      displayName: 'apiTier'
                      description: 'Specifiy whether you want to enable Standard tier for API resource type'
                    }
                  }
                  appServicesTier: {
                    type: 'String'
                    metadata: {
                      displayName: 'appServicesTier'
                      description: 'Specify whether you want to enable Standard tier for Azure App Service resource type'
                    }
                  }
                  sqlServersTier: {
                    type: 'String'
                    metadata: {
                      displayName: 'sqlServersTier'
                      description: 'Specify whether you want to enable Standard tier for PaaS SQL Service resource type'
                    }
                  }
                  CosmosDbs: {
                    type: 'String'
                    metadata: {
                      displayName: 'CosmosDbs'
                      description: 'Specify whether you want to enable Standard tier for CosmosDbs Service resource type'
                    }
                  }
                  cloudPosture: {
                    type: 'String'
                    metadata: {
                      displayName: 'cloudPosture'
                      description: 'Specify whether you want to enable Standard tier Cloud Security Posture Management.'
                    }
                  }
                  sensitiveDataDiscovery: {
                    type: 'String'
                    metadata: {
                      displayName: 'sensitiveDataDiscovery'
                      description: 'Enable sensitive Data Discovery within CSPM Plan'
                    }
                  }
                  containerRegistriesVulnerabilityAssessments: {
                    type: 'String'
                    metadata: {
                      displayName: 'containerRegistriesVulnerabilityAssessments'
                      description: 'Enable Container Registries Vulnerability Assessments within CSPM Plan'
                    }
                  }
                  agentlessDiscoveryForKubernetes: {
                    type: 'String'
                    metadata: {
                      displayName: 'agentlessDiscoveryForKubernetes'
                      description: 'Enable Agentless Discovery For Kubernetes within CSPM Plan'
                    }
                  }
                  sqlServerVirtualMachinesTier: {
                    type: 'String'
                    metadata: {
                      displayName: 'sqlServerVirtualMachinesTier'
                      description: 'Specify whether you want to enable Standard tier for SQL Server on VM resource type'
                    }
                  }
                  storageAccountsTier: {
                    type: 'String'
                    metadata: {
                      displayName: 'storageAccountsTier'
                      description: 'Specify whether you want to enable Standard tier for Storage Account resource type'
                    }
                  }
                  containers: {
                    type: 'String'
                    metadata: {
                      displayName: 'container'
                      description: 'Specify whether you want to enable Standard tier for containers'
                    }
                  }
                  dns: {
                    type: 'String'
                    metadata: {
                      displayName: 'dns'
                      description: 'Specify whether you want to enable Standard tier for DNS'
                    }
                  }
                  opensourcerelationaldatabases: {
                    type: 'String'
                    metadata: {
                      displayName: 'opensourcerelationaldatabases'
                      description: 'Specify whether you want to enable Standard tier for opensourcerelationaldatabases'
                    }
                  }
                  arm: {
                    type: 'String'
                    metadata: {
                      displayName: 'arms'
                      description: 'Specify whether you want to enable Standard tier for arm'
                    }
                  }
                  keyVaultsTier: {
                    type: 'String'
                    metadata: {
                      displayName: 'keyVaultsTier'
                      description: 'Specify whether you want to enable Standard tier for Key Vault resource type'
                    }
                  }
                  virtualMachinesSubPlan: {
                    type: 'String'
                    metadata: {
                      displayName: 'virtualMachinesSubPlan'
                      description: 'Specify Sub plan which you want to enable for Servers (Virtual Machine)'
                    }
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2022-03-01'
                    name: 'VirtualMachines'
                    properties: {
                      pricingTier: '[parameters(\'virtualMachinesTier\')]'
                      subPlan: ('[parameters(\'virtualMachinesSubPlan\')]')
                    }
                  }
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2018-06-01'
                    name: 'AppServices'
                    dependsOn: [
                      '[concat(\'Microsoft.Security/pricings/VirtualMachines\')]'
                    ]
                    properties: {
                      pricingTier: '[parameters(\'appServicesTier\')]'
                    }
                  }
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2018-06-01'
                    name: 'SqlServers'
                    dependsOn: [
                      '[concat(\'Microsoft.Security/pricings/AppServices\')]'
                    ]
                    properties: {
                      pricingTier: '[parameters(\'sqlServersTier\')]'
                    }
                  }
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2018-06-01'
                    name: 'SqlServerVirtualMachines'
                    dependsOn: [
                      '[concat(\'Microsoft.Security/pricings/SqlServers\')]'
                    ]
                    properties: {
                      pricingTier: '[parameters(\'sqlServerVirtualMachinesTier\')]'
                    }
                  }
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2018-06-01'
                    name: 'StorageAccounts'
                    dependsOn: [
                      '[concat(\'Microsoft.Security/pricings/SqlServerVirtualMachines\')]'
                    ]
                    properties: {
                      pricingTier: '[parameters(\'storageAccountsTier\')]'
                    }
                  }
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2018-06-01'
                    name: 'Containers'
                    dependsOn: [
                      '[concat(\'Microsoft.Security/pricings/storageaccounts\')]'
                    ]
                    properties: {
                      pricingTier: '[parameters(\'containers\')]'
                    }
                  }
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2018-06-01'
                    name: 'KeyVaults'
                    dependsOn: [
                      '[concat(\'Microsoft.Security/pricings/Containers\')]'
                    ]
                    properties: {
                      pricingTier: '[parameters(\'keyVaultsTier\')]'
                    }
                  }
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2018-06-01'
                    name: 'dns'
                    dependsOn: [
                      '[concat(\'Microsoft.Security/pricings/Keyvaults\')]'
                    ]
                    properties: {
                      pricingTier: '[parameters(\'dns\')]'
                    }
                  }
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2018-06-01'
                    name: 'arm'
                    dependsOn: [
                      '[concat(\'Microsoft.Security/pricings/dns\')]'
                    ]
                    properties: {
                      pricingTier: '[parameters(\'arm\')]'
                    }
                  }
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2018-06-01'
                    name: 'opensourcerelationaldatabases'
                    dependsOn: [
                      '[concat(\'Microsoft.Security/pricings/arm\')]'
                    ]
                    properties: {
                      pricingTier: '[parameters(\'opensourcerelationaldatabases\')]'
                    }
                  }
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2018-06-01'
                    name: 'CosmosDbs'
                    dependsOn: [
                      '[concat(\'Microsoft.Security/pricings/opensourcerelationaldatabases\')]'
                    ]
                    properties: {
                      pricingTier: '[parameters(\'CosmosDbs\')]'
                    }
                  }
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2018-06-01'
                    name: 'api'
                    dependsOn: [
                      '[concat(\'Microsoft.Security/pricings/CosmosDbs\')]'
                    ]
                    properties: {
                      pricingTier: '[parameters(\'api\')]'
                    }
                  }
                  {
                    type: 'Microsoft.Security/pricings'
                    apiVersion: '2023-01-01'
                    name: 'cloudposture'
                    dependsOn: [
                      '[concat(\'Microsoft.Security/pricings/api\')]'
                    ]
                    properties: {
                      pricingTier: '[parameters(\'cloudPosture\')]'
                      extensions: pricingTier.cloudPosture == 'Standard' ? [
                        {
                          name: 'SensitiveDataDiscovery'
                          isEnabled: '[parameters(\'sensitiveDataDiscovery\')]'
                        }
                        {
                          name: 'ContainerRegistriesVulnerabilityAssessments'
                          isEnabled: '[parameters(\'containerRegistriesVulnerabilityAssessments\')]'
                        }
                        {
                          name: 'AgentlessDiscoveryForKubernetes'
                          isEnabled: '[parameters(\'agentlessDiscoveryForKubernetes\')]'
                        }
                      ] : null
                    }
                  }
                ]
                outputs: {}
              }
            }
          }
        }
      }
    }
  }
}

//ASC pricing policy assignment 
resource ascPolicyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: ascPricingChangeDefAssignmentName
  location: ascPricingChangeAssignmentProperties.location
  properties: {
    displayName: ascPricingChangeDefAssignmentDisplayName
    description: ascPricingChangeAssignmentProperties.description
    metadata: ascPricingChangeAssignmentProperties.metadata
    policyDefinitionId: deployAscPricingPolicyDefinition.id
    parameters: {}
  }
  identity: {
    type: ascPricingChangeAssignmentProperties.identity
  }
}

//Deploy the Role assignment for the app service policy assignment
module ascPolicyRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: ascPolicyAssignment.identity.principalId
    roleDefinitionIdOrNames: ascPricingChangeAssignmentProperties.roleDefinitionIdOrNames
  }
}

// OUTPUTS
output roleAssignmentDeployName string = ascPolicyRoleAssignment.name
