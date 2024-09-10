/*
SUMMARY: AKS Change Policy child module.
DESCRIPTION: Deployment of AKS Change Policy. Consists of policy definition , assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1

NOTE: This policy requires explicit "Log Analytics Contributor" permission on MGMT subscription where centralized log analytic workspace is present 
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Configure AAD integrated Azure Kubernetes Service Clusters with required Admin Group Access')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param aksAadAdminEffect string

@description('AKS Administrator Group Object IDs')
@metadata({
  displayName: 'List of the existing AKS Administrator Group Object ID to ensure administration access to the cluster. Empty list [] will remove all admin access.'
})
param aksAdminGroupIds array

@description('Enable Monitoring Addon for Azure Kubernetes Service cluster')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param aksMonitoringAddonEffect string

@description('Resource Id of existing Log Analytics workspace for connection of AKS cluster Monitoring Addon')
param logAnalyticsWorkspaceResourceId string

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

@description('Specify policy name for administrator access to AKS clusters')
param deployAksAadAdminPolicyDefName string

@description('Specify policy display name for administrator access to AKS clusters')
param deployAksAadAdminPolicyDefDisplayName string

@description('Specify policy name for enabling Monitoring Addon of AKS cluster')
param aksMonitoringAddonPolicyDefName string

@description('Specify policy display name for enabling Monitoring Addon of AKS cluster')
param aksMonitoringAddonPolicyDefDisplayName string

@description('Specify policy set name for change kubernetes services')
param kubernetesChangeSetName string

@description('Specify policy set display name for change kubernetes services')
param kubernetesChangeSetDisplayName string

@description('Specify policy assignment name for change kubernetes services')
param kubernetesChangeSetAssignmentName string

@description('Specify policy assignment display name for change kubernetes services')
param kubernetesChangeSetAssignmentDisplayName string

@description('Tag used for the policy rule')
param policyRuleTag string

// VARIABLES
// This variable holds policy details to integrate AAD with AKS
var aksAadAdminDefinitionProperties = {
  description: 'Ensure to improve cluster security by centrally govern Administrator access to Azure Active Directory integrated AKS clusters.'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
    category: 'Kubernetes'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

// This variable holds policy details to integrate AAD with AKS
var aksMonitoringAddonDefinitionProperties = {
  description: 'Enable Monitoring Addon for Azure Kubernetes Service clusters in specified scope'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
    category: 'Monitoring'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

// kubernetes change initiative properties
var kubernetesChangePolicySetDefinitionProperties = {
  description: 'This initiative configures governance and security policies for Azure Kubernetes Service'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
    category: 'Kubernetes'
  }
}

// This variable holds the assignment details for AKS change policy
var kubernetesChangeAssignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identity:'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Kubernetes has relevant governane and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  roleDefinitionIdOrNames: [
    'Azure Kubernetes Service Contributor Role'
    'Log Analytics Contributor'
  ]
}

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId,deployLocation),0 ,6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(kubernetesChangeSetName, '-'))}-${uniqueDeployPrefix}-roleAssignment'

//Variable used to construct the name of the Role Assignment Deployment on the Management Subscription
var roleAssignmentNameMgmt = '${first(split(kubernetesChangeSetName, '-'))}-${uniqueDeployPrefix}-mgmt-roleAssignment'

@description('The Id of the management subscription. To be provided by the Policy parent module')
param managementSubscriptionId string

// RESOURCES

// Policy to integrate AKS with AAD
resource deployAksAadAdminPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: deployAksAadAdminPolicyDefName
  properties: {
    displayName: deployAksAadAdminPolicyDefDisplayName
    description: aksAadAdminDefinitionProperties.description
    policyType: aksAadAdminDefinitionProperties.policyType
    mode: aksAadAdminDefinitionProperties.mode
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'effect'
        }
      }
    }
    metadata: aksAadAdminDefinitionProperties.metadata
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.ContainerService/managedClusters'
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
          {
            field: 'Microsoft.ContainerService/managedClusters/aadProfile'
            exists: true
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.ContainerService/managedClusters'
          name: '[field(\'name\')]'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8'
          ]
          existenceCondition: {
            allOf: [
              {
                count: {
                  field: 'Microsoft.ContainerService/managedClusters/aadProfile.adminGroupObjectIDs[*]'
                  where: {
                    field: 'Microsoft.ContainerService/managedClusters/aadProfile.adminGroupObjectIDs[*]'
                    in: aksAdminGroupIds
                  }
                }
                equals: length(aksAdminGroupIds)
              }
              {
                count: {
                  field: 'Microsoft.ContainerService/managedClusters/aadProfile.adminGroupObjectIDs[*]'
                }
                equals: length(aksAdminGroupIds)
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
                  clusterName: {
                    type: 'string'
                  }
                  clusterResourceGroupName: {
                    type: 'string'
                  }
                  adminGroupObjectIDs: {
                    type: 'array'
                  }
                }
                variables: {
                  clusterGetDeploymentName: '[concat(\'PolicyDeployment-Get-\', parameters(\'clusterName\'))]'
                  clusterUpdateDeploymentName: '[concat(\'PolicyDeployment-Update-\', parameters(\'clusterName\'))]'
                }
                resources: [
                  {
                    apiVersion: '2020-06-01'
                    type: 'Microsoft.Resources/deployments'
                    name: '[variables(\'clusterGetDeploymentName\')]'
                    properties: {
                      mode: 'Incremental'
                      template: {
                        '$schema': 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                        contentVersion: '1.0.0.0'
                        resources: []
                        outputs: {
                          aksCluster: {
                            type: 'object'
                            value: '[reference(resourceId(parameters(\'clusterResourceGroupName\'), \'Microsoft.ContainerService/managedClusters\', parameters(\'clusterName\')), \'2021-07-01\', \'Full\')]'
                          }
                        }
                      }
                    }
                  }
                  {
                    apiVersion: '2020-06-01'
                    type: 'Microsoft.Resources/deployments'
                    name: '[variables(\'clusterUpdateDeploymentName\')]'
                    properties: {
                      mode: 'Incremental'
                      expressionEvaluationOptions: {
                        scope: 'inner'
                      }
                      template: {
                        '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                        contentVersion: '1.0.0.0'
                        parameters: {
                          aksClusterName: {
                            type: 'string'
                          }
                          aksClusterContent: {
                            type: 'object'
                          }
                          adminGroupObjectIDs: {
                            type: 'array'
                          }
                        }
                        resources: [
                          {
                            apiVersion: '2021-07-01'
                            type: 'Microsoft.ContainerService/managedClusters'
                            name: '[parameters(\'aksClusterName\')]'
                            location: '[parameters(\'aksClusterContent\').location]'
                            sku: '[parameters(\'aksClusterContent\').sku]'
                            tags: '[if(contains(parameters(\'aksClusterContent\'), \'tags\'), parameters(\'aksClusterContent\').tags, json(\'null\'))]'
                            properties: {
                              kubernetesVersion: '[parameters(\'aksClusterContent\').properties.kubernetesVersion]'
                              dnsPrefix: '[parameters(\'aksClusterContent\').properties.dnsPrefix]'
                              agentPoolProfiles: '[if(contains(parameters(\'aksClusterContent\').properties, \'agentPoolProfiles\'), parameters(\'aksClusterContent\').properties.agentPoolProfiles, json(\'null\'))]'
                              linuxProfile: '[if(contains(parameters(\'aksClusterContent\').properties, \'linuxProfile\'), parameters(\'aksClusterContent\').properties.linuxProfile, json(\'null\'))]'
                              servicePrincipalProfile: '[if(contains(parameters(\'aksClusterContent\').properties, \'servicePrincipalProfile\'), parameters(\'aksClusterContent\').properties.servicePrincipalProfile, json(\'null\'))]'
                              addonProfiles: '[if(contains(parameters(\'aksClusterContent\').properties, \'addonProfiles\'), parameters(\'aksClusterContent\').properties.addonProfiles, json(\'null\'))]'
                              nodeResourceGroup: '[parameters(\'aksClusterContent\').properties.nodeResourceGroup]'
                              enableRBAC: '[if(contains(parameters(\'aksClusterContent\').properties, \'enableRBAC\'), parameters(\'aksClusterContent\').properties.enableRBAC, json(\'null\'))]'
                              enablePodSecurityPolicy: '[if(contains(parameters(\'aksClusterContent\').properties, \'enablePodSecurityPolicy\'), parameters(\'aksClusterContent\').properties.enablePodSecurityPolicy, json(\'null\'))]'
                              networkProfile: '[if(contains(parameters(\'aksClusterContent\').properties, \'networkProfile\'), parameters(\'aksClusterContent\').properties.networkProfile, json(\'null\'))]'
                              aadProfile: {
                                adminGroupObjectIDs: '[parameters(\'adminGroupObjectIDs\')]'
                                managed: '[if(contains(parameters(\'aksClusterContent\').properties.aadProfile, \'managed\'), parameters(\'aksClusterContent\').properties.aadProfile.managed, json(\'null\'))]'
                                enableAzureRBAC: '[if(contains(parameters(\'aksClusterContent\').properties.aadProfile, \'enableAzureRBAC\'), parameters(\'aksClusterContent\').properties.aadProfile.enableAzureRBAC, json(\'null\'))]'
                                tenantID: '[if(contains(parameters(\'aksClusterContent\').properties.aadProfile, \'tenantID\'), parameters(\'aksClusterContent\').properties.aadProfile.tenantID, json(\'null\'))]'
                                clientAppID: '[if(contains(parameters(\'aksClusterContent\').properties.aadProfile, \'clientAppID\'), parameters(\'aksClusterContent\').properties.aadProfile.clientAppID, json(\'null\'))]'
                                serverAppID: '[if(contains(parameters(\'aksClusterContent\').properties.aadProfile, \'serverAppID\'), parameters(\'aksClusterContent\').properties.aadProfile.serverAppID, json(\'null\'))]'
                                serverAppSecret: '[if(contains(parameters(\'aksClusterContent\').properties.aadProfile, \'serverAppSecret\'), parameters(\'aksClusterContent\').properties.aadProfile.serverAppSecret, json(\'null\'))]'
                              }
                              autoScalerProfile: '[if(contains(parameters(\'aksClusterContent\').properties, \'autoScalerProfile\'), parameters(\'aksClusterContent\').properties.autoScalerProfile, json(\'null\'))]'
                              autoUpgradeProfile: '[if(contains(parameters(\'aksClusterContent\').properties, \'autoUpgradeProfile\'), parameters(\'aksClusterContent\').properties.autoUpgradeProfile, json(\'null\'))]'
                              apiServerAccessProfile: '[if(contains(parameters(\'aksClusterContent\').properties, \'apiServerAccessProfile\'), parameters(\'aksClusterContent\').properties.apiServerAccessProfile, json(\'null\'))]'
                              diskEncryptionSetID: '[if(contains(parameters(\'aksClusterContent\').properties, \'diskEncryptionSetID\'), parameters(\'aksClusterContent\').properties.diskEncryptionSetID, json(\'null\'))]'
                              disableLocalAccounts: '[if(contains(parameters(\'aksClusterContent\').properties, \'disableLocalAccounts\'), parameters(\'aksClusterContent\').properties.disableLocalAccounts, json(\'null\'))]'
                              fqdnSubdomain: '[if(contains(parameters(\'aksClusterContent\').properties, \'fqdnSubdomain\'), parameters(\'aksClusterContent\').properties.fqdnSubdomain, json(\'null\'))]'
                              httpProxyConfig: '[if(contains(parameters(\'aksClusterContent\').properties, \'httpProxyConfig\'), parameters(\'aksClusterContent\').properties.httpProxyConfig, json(\'null\'))]'
                              podIdentityProfile: '[if(contains(parameters(\'aksClusterContent\').properties, \'podIdentityProfile\'), parameters(\'aksClusterContent\').properties.podIdentityProfile, json(\'null\'))]'
                              privateLinkResources: '[if(contains(parameters(\'aksClusterContent\').properties, \'privateLinkResources\'), parameters(\'aksClusterContent\').properties.privateLinkResources, json(\'null\'))]'
                              securityProfile: '[if(contains(parameters(\'aksClusterContent\').properties, \'securityProfile\'), parameters(\'aksClusterContent\').properties.securityProfile, json(\'null\'))]'
                              identityProfile: '[if(contains(parameters(\'aksClusterContent\').properties, \'identityProfile\'), parameters(\'aksClusterContent\').properties.identityProfile, json(\'null\'))]'
                            }
                          }
                        ]
                        outputs: {}
                      }
                      parameters: {
                        aksClusterName: {
                          value: '[parameters(\'clusterName\')]'
                        }
                        aksClusterContent: {
                          value: '[reference(variables(\'clusterGetDeploymentName\')).outputs.aksCluster.value]'
                        }
                        adminGroupObjectIDs: {
                          value: '[parameters(\'adminGroupObjectIDs\')]'
                        }
                      }
                    }
                  }
                ]
              }
              parameters: {
                clusterName: {
                  value: '[field(\'name\')]'
                }
                clusterResourceGroupName: {
                  value: '[resourceGroup().name]'
                }
                adminGroupObjectIDs: {
                  value: aksAdminGroupIds
                }
              }
            }
          }
        }
      }
    }
  }
}

resource aksMonitoringAddonPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: aksMonitoringAddonPolicyDefName
  properties: {
    displayName: aksMonitoringAddonPolicyDefDisplayName
    description: aksMonitoringAddonDefinitionProperties.description
    metadata: aksMonitoringAddonDefinitionProperties.metadata
    policyType: aksMonitoringAddonDefinitionProperties.policyType
    mode: aksMonitoringAddonDefinitionProperties.mode
    parameters: {
      logAnalytics: {
        type: 'String'
        metadata: {
          displayName: 'Resource Id of existing Azure Log Analytics Workspace'
          description: 'Azure Monitor Log Analytics Resource ID'
          strongType: 'omsWorkspace'
        }
      }
      effect: {
        type: 'String'
        metadata: {
          displayName: 'effect'
          description: 'policy effect (DeployIfNotExists|Disabled)'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.ContainerService/managedClusters'
          }
          {
            field: 'tags.${policyRuleTag}'
            exists: true
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.ContainerService/managedClusters'
          name: '[field(\'name\')]'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8' // Azure Kubernetes Service Contributor Role
            '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.ContainerService/managedClusters/addonProfiles.omsagent.enabled'
                equals: 'true'
              }
              {
                field: 'tags[\'logAnalyticsWorkspace\']'
                exists: true
              }
              {
                field: 'tags[\'logAnalyticsWorkspace\']'
                equals: '[last(split(parameters(\'logAnalytics\'), \'/\'))]'
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
                  clusterName: {
                    type: 'string'
                  }
                  clusterResourceGroupName: {
                      type: 'string'
                  }
                  clusterLocation: {
                    type: 'string'
                  }
                  clusterTags: {
                    type: 'object'
                  }
                  logAnalytics: {
                    type: 'string'
                  }
                }
                variables: {
                  uniqueClusterName: '[uniqueString(parameters(\'clusterName\'))]'
                  deploymentName: '[concat(\'aks-monitoring-addon-\', variables(\'uniqueClusterName\'))]'
                  logAnalyticsTag: '[json(concat(\'{"logAnalyticsWorkspace":"\', last(split(parameters(\'logAnalytics\'), \'/\')), \'"}\'))]'
                  newClusterTags: '[union(parameters(\'clusterTags\'), variables(\'logAnalyticsTag\'))]'
                }
                resources: [
                  {
                    type: 'Microsoft.Resources/deployments'
                    name: '[variables(\'deploymentName\')]'
                    apiVersion: '2019-05-01'
                    properties: {
                      mode: 'Incremental'
                      template: {
                        '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                        contentVersion: '1.0.0.0'
                        parameters: {}
                        variables: {}
                        resources: [
                          {
                            name: '[parameters(\'clusterName\')]'
                            type: 'Microsoft.ContainerService/managedClusters'
                            location: '[parameters(\'clusterLocation\')]'
                            tags: '[variables(\'newClusterTags\')]'
                            apiVersion: '2018-03-31'
                            properties: {
                              mode: 'Incremental'
                              id: '[resourceId(parameters(\'clusterResourceGroupName\'), \'Microsoft.ContainerService/managedClusters\', parameters(\'clusterName\'))]'
                              addonProfiles: {
                                omsagent: {
                                  enabled: true
                                  config: {
                                    logAnalyticsWorkspaceResourceID: '[parameters(\'logAnalytics\')]'
                                  }
                                }
                              }
                            }
                          }
                        ]
                      }
                    }
                  }
                ]
              }
              parameters: {
                clusterName: {
                  value: '[field(\'name\')]'
                }
                clusterResourceGroupName: {
                  value: '[resourceGroup().name]'
                }
                clusterLocation: {
                  value: '[field(\'location\')]'
                }
                clusterTags: {
                  value: '[field(\'tags\')]'
                }
                logAnalytics: {
                  value: '[parameters(\'logAnalytics\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}

// Deploy the Kubernetes Change policy set definition
resource kubernetesChangePolicySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: kubernetesChangeSetName
  properties: {
    description: kubernetesChangePolicySetDefinitionProperties.description
    displayName: kubernetesChangeSetDisplayName
    metadata: kubernetesChangePolicySetDefinitionProperties.metadata
    parameters: {
      aksAadAdminGroupAccess: {
        type: 'String'
        metadata: {
          displayName: 'aksAadAdminGroupAccess'
          description: 'Configure AAD integrated Azure Kubernetes Service clusters with required Admin Group Access'
        }
      }
      aksMonitoringAddon: {
        type: 'String'
        metadata: {
          displayName: 'aksMonitoringAddon'
          description: 'Enable AKS cluster Monitoring Addon'
        }
      }
      logAnalyticsWorkspaceResourceId: {
        type: 'String'
        metadata: {
          displayName: 'logAnalyticsWorkspaceResourceId'
          description: 'Resource Id of existing Log Analytics workspace for connection of AKS cluster Monitoring Addon'
        }
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: deployAksAadAdminPolicyDefinition.id
        parameters: {
          effect: {
            value: '[parameters(\'aksAadAdminGroupAccess\')]'
          }
        }
      }
      {
        policyDefinitionId: aksMonitoringAddonPolicyDefinition.id
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalyticsWorkspaceResourceId\')]'
          }
          effect: {
            value: '[parameters(\'aksMonitoringAddon\')]'
          }
        }
      }
    ]
  }
}

// Deploy the Kubernetes Change policy set assignment
resource kubernetesChangePolicySetAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: kubernetesChangeSetAssignmentName
  location: kubernetesChangeAssignmentProperties.location
  properties: {
    displayName: kubernetesChangeSetAssignmentDisplayName
    description: kubernetesChangeAssignmentProperties.description
    metadata: kubernetesChangeAssignmentProperties.metadata
    policyDefinitionId: kubernetesChangePolicySetDefinition.id
    parameters: {
      aksAadAdminGroupAccess: {
        value: aksAadAdminEffect
      }
      aksMonitoringAddon: {
        value: aksMonitoringAddonEffect
      }
      logAnalyticsWorkspaceResourceId: {
        value: logAnalyticsWorkspaceResourceId
      }
    }
  }
  identity: {
    type: kubernetesChangeAssignmentProperties.identity
  }

}

// Deploy the Role assignment for ACR change initiative
module kubernetesChangePolicyRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: kubernetesChangePolicySetAssignment.identity.principalId
    roleDefinitionIdOrNames: kubernetesChangeAssignmentProperties.roleDefinitionIdOrNames
  }
}

module kubernetesChangePolicyRoleAssignmentMgmt '../../roleAssignment/roleAssignment.bicep' = if (managementSubscriptionId != subscription().subscriptionId) {
  name: roleAssignmentNameMgmt
  scope: subscription(managementSubscriptionId)
  params: {
    managedIdentityId: kubernetesChangePolicySetAssignment.identity.principalId
    roleDefinitionIdOrNames: kubernetesChangeAssignmentProperties.roleDefinitionIdOrNames
  }
}

// OUTPUTS
output roleAssignmentDeployName string = kubernetesChangePolicyRoleAssignment.name
output roleAssignmentMgmtDeployName string = kubernetesChangePolicyRoleAssignmentMgmt.name
