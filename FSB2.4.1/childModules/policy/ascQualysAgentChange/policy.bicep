/*
SUMMARY: ASC Qualys agent for VMs Policy child module.
DESCRIPTION: Deployment of ASC Qualys agent for VMs if the agent is not installed Policy. Consists of definition, definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.2
*/
// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Desired effect to set, when a Linux instance with the required Tags are detected.')
@metadata({
  displayName: 'Deploy windows Qualys agent.'
})
param deployQualysWindowsPolicy bool

@description('Desired effect to set, when a Linux instance with the required Tags are detected.')
@metadata({
  displayName: 'Deploy linux Qualys agent.'
})
param deployQualysLinuxPolicy bool

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment. 
param deployLocation string = deployment().location

@description('Specify name for definition of ascQualysAgentWindows change policy.')
param ascQualysAgentChangeWindowsDefName string

@description('Specify display name for definition of ascQualysAgentWindows change policy.')
param ascQualysAgentChangeWindowsDefDisplayName string

@description('Specify name for definition of ascQualysAgentLinux change policy.')
param ascQualysAgentChangeLinuxDefName string

@description('Specify display name for definition of ascQualysAgentLinux change policy.')
param ascQualysAgentChangeLinuxDefDisplayName string

@description('Specify name for ascQualysAgent change initiative.')
param ascQualysAgentChangeSetName string

@description('Specify display name for ascQualysAgent change initiative.')
param ascQualysAgentChangeSetDisplayName string

@description('Specify name for assignment of ascQualysAgent change initiative.')
param ascQualysAgentChangeSetAssignmentName string

@description('Specify display name for assignment of ascQualysAgent change initiative.')
param ascQualysAgentChangeSetAssignmentDisplayName string

@description('Tag used for the policy rule')
param policyRuleTag array

// VARIABLES
//Variable which holds the qualys agent definition for Windows machines
var definitionDeployQualysAgentWindows = {
  description: 'Deploy ASC Qualys agent for Windows VMs if the agent is not installed'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
    category: 'Security Center'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
  parameters: {
    effect: {
      type: 'String'
    }
  }
}

//Variable which holds the qualys agent definition for Linux machines
var definitionDeployQualysAgentLinux = {
  description: 'Deploy ASC Qualys agent for Linux VMs if the agent is not installed'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
    category: 'Security Center'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
  parameters: {
    effect: {
      type: 'String'
    }
  }
}

//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This initiative deploys the ASC Qualys agent for both Windows and Linux systems'
  metadata: {
    category: 'Security Center'
    source: policyMetadata
    version: '0.0.1'
  }
}

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that ASC Qualys agent is installed for both Windows and Linux Virtual Machine'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  roleDefinitionIdOrNames: [
    'VM Contributor'
    'Security Admin'
  ]
}

//Here the policy definitions in the policy set are being conditionally added
var policyDefinitionsWindows = deployQualysWindowsPolicy ? [
  {
    policyDefinitionId: policyDefinitionWindowsQualysAgent.id
    parameters: {
      effect: {
        value: '[parameters(\'ascQualysAgentWindows\')]'
      }
    }
  }
] : []

var policyDefinitionsLinux = deployQualysLinuxPolicy ? [
  {
    policyDefinitionId: policyDefinitionLinuxQualysAgent.id
    parameters: {
      effect: {
        value: '[parameters(\'ascQualysAgentLinux\')]'
      }
    }
  }
] : []

// Joins the calculated values above with the values passeed
var policySetDefinitionsJoined = union(policyDefinitionsLinux, policyDefinitionsWindows)

//Here the parameters for the policy set definitions are being conditionally added
var paramaterPolicySetWindows = deployQualysWindowsPolicy ? {
  ascQualysAgentWindows: {
    type: 'String'
    defaultValue: 'deployIfNotExists'
    metadata: {
      displayName: 'ascQualysAgentWindows'
      description: 'Configure VM to install Qualys agent for Windows.'
    }
  }
} : {}

var paramaterPolicySetLinux = deployQualysLinuxPolicy ? {
  ascQualysAgentLinux: {
    type: 'String'
    defaultValue: 'deployIfNotExists'
    metadata: {
      displayName: 'ascQualysAgentLinux'
      description: 'Configure VM to install Qualys agparamaterAssignmentJoinedent for Linux.'
    }
  }
} : {}

// Joins the calculated values above with the values passeed
var paramaterPolicySetJoined = union(paramaterPolicySetWindows, paramaterPolicySetLinux)

//Here the parameters for the assignment are being conditionally added
var paramaterAssignmentWindows = deployQualysWindowsPolicy ? {
  ascQualysAgentWindows: {
    value: 'deployIfNotExists' //Hard coding the value here as discussed
  }
} : {}

var paramaterAssignmentLinux = deployQualysLinuxPolicy ? {
  ascQualysAgentLinux: {
    value: 'deployIfNotExists' //Hard coding the value here as discussed
  }
} : {}

// Joins the calculated values above with the values passeed
var paramaterAssignmentJoined = union(paramaterAssignmentWindows, paramaterAssignmentLinux)

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployLocation), 0, 6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(ascQualysAgentChangeSetName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'

// RESOURCE DEPLOYMENTS
//Deploy the policy definitions for windows
resource policyDefinitionWindowsQualysAgent 'Microsoft.Authorization/policyDefinitions@2021-06-01' = if (deployQualysWindowsPolicy) {
  name: ascQualysAgentChangeWindowsDefName
  properties: {
    displayName: ascQualysAgentChangeWindowsDefDisplayName
    description: definitionDeployQualysAgentWindows.description
    policyType: definitionDeployQualysAgentWindows.policyType
    mode: definitionDeployQualysAgentWindows.mode
    metadata: definitionDeployQualysAgentWindows.metadata
    parameters: definitionDeployQualysAgentWindows.parameters
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            field: 'tags.${policyRuleTag[0]}'
            equals: 'true'
          }
          {
            field: 'tags.${policyRuleTag[1]}'
            equals: 'true'
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
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Compute/virtualMachines/extensions'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
            '/providers/Microsoft.Authorization/roleDefinitions/fb1c8493-542b-48eb-b624-b4c8fea62acd'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                in: [
                  'WindowsAgent.AzureSecurityCenter'
                  'LinuxAgent.AzureSecurityCenter'
                ]
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/publisher'
                equals: 'Qualys'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/provisioningState'
                equals: 'Succeeded'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'Incremental'
              template: {
                contentVersion: '1.0.0.0'
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                parameters: {
                  vmName: {
                    type: 'string'
                  }
                  apiVersionByEnv: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    type: 'Microsoft.Compute/virtualMachines/providers/serverVulnerabilityAssessments'
                    name: '[concat(parameters(\'vmName\'), \'/Microsoft.Security/default\')]'
                    apiVersion: '[parameters(\'apiVersionByEnv\')]'
                  }
                ]
              }
              parameters: {
                vmName: {
                  value: '[field(\'name\')]'
                }
                apiVersionByEnv: {
                  value: '2020-01-01'
                }
              }
            }
          }
        }
      }
    }
  }
}

//Deploy the policy definitions for Linux
resource policyDefinitionLinuxQualysAgent 'Microsoft.Authorization/policyDefinitions@2021-06-01' = if (deployQualysLinuxPolicy) {
  name: ascQualysAgentChangeLinuxDefName
  properties: {
    displayName: ascQualysAgentChangeLinuxDefDisplayName
    description: definitionDeployQualysAgentLinux.description
    policyType: definitionDeployQualysAgentLinux.policyType
    mode: definitionDeployQualysAgentLinux.mode
    metadata: definitionDeployQualysAgentLinux.metadata
    parameters: definitionDeployQualysAgentLinux.parameters
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            field: 'tags.${policyRuleTag[0]}'
            equals: 'true'
          }
          {
            field: 'tags.${policyRuleTag[1]}'
            equals: 'true'
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
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Compute/virtualMachines/extensions'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
            '/providers/Microsoft.Authorization/roleDefinitions/fb1c8493-542b-48eb-b624-b4c8fea62acd'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                equals: 'LinuxAgent.AzureSecurityCenter'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/publisher'
                equals: 'Qualys'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/provisioningState'
                in: [
                  'Succeeded'
                  'Provisioning succeeded'
                ]
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
                  apiVersionByEnv: {
                    type: 'string'
                  }
                }
                variables: {
                  vmExtensionName: '/Microsoft.Security/default'
                }
                resources: [
                  {
                    name: '[concat(parameters(\'vmName\'), \'/Microsoft.Security/default\')]'
                    type: 'Microsoft.Compute/virtualMachines/providers/serverVulnerabilityAssessments'
                    apiVersion: '2020-01-01'
                  }
                ]
              }
              parameters: {
                vmName: {
                  value: '[field(\'name\')]'
                }
                apiVersionByEnv: {
                  value: '2020-01-01'
                }
              }
            }
          }
        }
      }
    }
  }
}

//Deploy the policy definition set for the definitions created in previous resource block
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: ascQualysAgentChangeSetName
  properties: {
    displayName: ascQualysAgentChangeSetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: paramaterPolicySetJoined
    policyDefinitions: policySetDefinitionsJoined
  }
}

//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: ascQualysAgentChangeSetAssignmentName
  location: assignmentProperties.location
  properties: {
    description: assignmentProperties.description
    displayName: ascQualysAgentChangeSetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    policyDefinitionId: policySetDefinition.id
    parameters: paramaterAssignmentJoined
  }
  identity: {
    type: assignmentProperties.identityType
  }
}

//Deploy the Role assignment for the created Managed Identity
module policySystemManagedIdentityRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: policyAssignment.identity.principalId
    roleDefinitionIdOrNames: assignmentProperties.roleDefinitionIdOrNames
  }
}

// OUTPUTS
output roleAssignmentDeployName string = policySystemManagedIdentityRoleAssignment.name
