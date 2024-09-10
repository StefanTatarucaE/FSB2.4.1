/*
SUMMARY: Audit Tag Policy child module.
DESCRIPTION: Deployment of Audit Tag Policy. Consists of definition & assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Set the policy effect when the policy rule evaluates to true Possible values Audit, Deny or Disable.')
@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param blockLogAnalyticsAgentDefEffect string

@description('Specify policy definition name for block Vm Loganalytics Agent Audit Deny')
param blockLogAnalyticsAgentDefName string

@description('Specify policy displayname for block Vm Loganalytics Agent Audit Deny')
param blockLogAnalyticsAgentDefDisplayName string

@description('Specify policy assignment name for block Vm Loganalytics Agent Audit Deny')
param blockLogAnalyticsAgentDefAssignmentName string

@description('Specify policy assignment displayname for block Vm Loganalytics Agent Audit Deny')
param blockLogAnalyticsAgentDefAssignmentDisplayName string


// VARIABLES
//Variable which holds the definition details
var definitionProperties = {
  description: 'Automatically prevent installation of the legacy Log Analytics Agent as the final step of migrating from legacy agents to Azure Monitor Agent. After you have uninstalled existing legacy extensions, this policy will deny all future installations of the legacy agent extension on Windows and Linux virtual machines and scale sets. Learn more: https://aka.ms/migratetoAMA'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'Monitoring'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'None' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: definitionProperties.description
  metadata: {
    source: policyMetadata
    version: '1.0.0'
  }
}

// RESOURCE DEPLOYMENTS
//Deploy the policy definition
resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: blockLogAnalyticsAgentDefName
  properties: {
    description: definitionProperties.description
    displayName: blockLogAnalyticsAgentDefDisplayName
    metadata: definitionProperties.metadata
    mode: definitionProperties.mode
    parameters: {
      effect:{
        type: 'String'
        metadata: {
          displayName: 'effect'
        }
      }
    }
    policyRule: {
      if: {
        anyOf: [
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Compute/virtualMachines/extensions'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/publisher'
                equals: 'Microsoft.EnterpriseCloud.Monitoring'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                equals: 'MicrosoftMonitoringAgent'
              }
            ]
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Compute/virtualMachines/extensions'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/publisher'
                equals: 'Microsoft.EnterpriseCloud.Monitoring'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                equals: 'OmsAgentForLinux'
              }
            ]
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Compute/virtualMachineScaleSets/extensions'
              }
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/publisher'
                equals: 'Microsoft.EnterpriseCloud.Monitoring'
              }
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/type'
                equals: 'MicrosoftMonitoringAgent'
              }
            ]
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Compute/virtualMachineScaleSets/extensions'
              }
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/publisher'
                equals: 'Microsoft.EnterpriseCloud.Monitoring'
              }
              {
                field: 'Microsoft.Compute/virtualMachineScaleSets/extensions/type'
                equals: 'OmsAgentForLinux'
              }
            ]
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Compute/virtualMachineScaleSets'
              }
              {
                count: {
                  field: 'Microsoft.Compute/VirtualMachineScaleSets/extensionProfile.extensions[*]'
                  where: {
                    field: 'Microsoft.Compute/VirtualMachineScaleSets/extensionProfile.extensions[*].type'
                    equals: 'MicrosoftMonitoringAgent'
                  }
                }
                greater: 0
              }
            ]
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Compute/virtualMachineScaleSets'
              }
              {
                count: {
                  field: 'Microsoft.Compute/VirtualMachineScaleSets/extensionProfile.extensions[*]'
                  where: {
                    field: 'Microsoft.Compute/VirtualMachineScaleSets/extensionProfile.extensions[*].type'
                    equals: 'OmsAgentForLinux'
                  }
                }
                greater: 0
              }
            ]
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
    policyType: definitionProperties.policyType
  }
}

//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: blockLogAnalyticsAgentDefAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: blockLogAnalyticsAgentDefAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      effect: {
        value: blockLogAnalyticsAgentDefEffect
      }
    }
    policyDefinitionId: policyDefinition.id
  }
}

// OUTPUTS
