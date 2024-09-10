/*
SUMMARY: Databricks Audit/Deny Policy child module.
DESCRIPTION: Deployment of Databricks Audit/Deny Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

//SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

//PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param databricksSettings object

@description('Specify set name for cosmosdb audit deny initiative')
param databricksAuditDenySetName string

@description('Specify set displayname for cosmosdb audit deny initiative')
param databricksAuditDenySetDisplayName string

@description('Specify set assignment name for cosmosdb audit deny initiative')
param databricksAuditDenySetAssignmentName string

@description('Specify set assignment displayname for cosmosdb audit deny initiative')
param databricksAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variables for allowedValues.
var effectAuditIfNotExistDisabled = [
  'AuditIfNotExists'
  'Disabled'
]

var effectAuditDisabled = [
  'Audit'
  'Disabled'
]

var effectDeny = [
  'Deny'
]

var effectAuditDenyDisabled = concat(effectAuditDisabled, effectDeny)

//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This policy set configures governance and security policies for Azure Databricks'
  metadata: {
    category: 'Monitoring'
    source: policyMetadata
    version: '0.0.1'
  }
}

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Databricks resources have relevant governance and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

//RESOURCE DEPLOYMENTS
//Deploy the policy definition set for the definitions created in previous resource block
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: databricksAuditDenySetName
  properties: {
    displayName: databricksAuditDenySetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      disablePublicNetworkAccessEffect: {
        type: 'String'
        metadata: {
          description: 'Disable public network access effect. Allowed Values: Audit, Deny, Disabled'
          displayName: 'disablePublicNetworkAccessEffect'
        }
        allowedValues: effectAuditDenyDisabled
      }
      disablePublicIpEffect: {
        type: 'String'
        metadata: {
          description: 'Disable public IP effect. Allowed Values: Audit, Deny, Disabled'
          displayName: 'disablePublicIpEffect'
        }
        allowedValues: effectAuditDenyDisabled
      }
      enableWorkspaceResourceLogsEffect: {
        type: 'String'
        metadata: {
          description: 'Enable Databricks workspace resource logs effect. Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'enableWorkspaceResourceLogsEffect'
        }
        allowedValues: effectAuditIfNotExistDisabled
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0e7849de-b939-4c50-ab48-fc6b0f5eeba2'
        parameters: {
          effect: {
            value: '[parameters(\'disablePublicNetworkAccessEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/51c1490f-3319-459c-bbbc-7f391bbed753'
        parameters: {
          effect: {
            value: '[parameters(\'disablePublicIpEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/138ff14d-b687-4faa-a81c-898c91a87fa2'
        parameters: {
          effect: {
            value: '[parameters(\'enableWorkspaceResourceLogsEffect\')]'
          }
        }
      }
    ]
  }
}

//Deploy the policy assignemnt 
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: databricksAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: databricksAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      disablePublicNetworkAccessEffect: {
        value: databricksSettings.disablePublicNetworkAccessEffect
      }
      disablePublicIpEffect: {
        value: databricksSettings.disablePublicIpEffect
      }
      enableWorkspaceResourceLogsEffect: {
        value: databricksSettings.enableWorkspaceResourceLogsEffect
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
}

//OUTPUTS
