/*
SUMMARY: Application Gateway Audit/Deny Policy child module.
DESCRIPTION: Deployment of Application Gateway Audit/Deny Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('''Set the policy effect for when the policy rule evaluates to true.
Policy rule: Web Application Firewall (WAF) should be enabled for Application Gateway. 
''')
param wafEnableEffect string

@description('''Set the policy effect for when the policy rule evaluates to true.
Policy rule: Web Application Firewall (WAF) should use the specified mode for Application Gateway. 
''')
param wafModeEffect string

@description('Mode required for all WAF policies.')
param modeRequirement string

@description('Specify set name for Application Gateway audit deny initiative')
param appGatewayAuditDenySetName string

@description('Specify set displayname for Application Gateway audit deny initiative')
param appGatewayAuditDenySetDisplayName string

@description('Specify set assignment name for Application Gateway audit deny initiative')
param appGatewayAuditDenySetAssignmentName string

@description('Specify set assignment displayname for Application Gateway audit deny initiative')
param appGatewayAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variable for allowedValues which is the same for all policy set definition parameters.
var allowedValues = [
  'Audit'
  'Deny'
  'Disabled'
]

// Variable for allowedValuesMode which is used to set the Mode required for all WAF policies.
var allowedValuesModeRequirement = [
  'Prevention'
  'Detection'
]

@description('Specifies the ID of the policy definitions being assigned via the policy set definition.')
var policyDefinitionProperties = {
  wafEnable:{
    id: '564feb30-bf6a-4854-b4bb-0d2d2d1e6c66'
  }
  wafMode:{
    id: '12430be1-6cc8-4527-a9a8-e3d38f250096'
  }
}


//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This policy set configures governance and security policies to Application Gateway'
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
  description: 'Ensures that Application Gateway has relevant governance and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

// RESOURCE DEPLOYMENTS
//Deploy the policy definition set for the definitions created in previous resource block
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: appGatewayAuditDenySetName
  properties: {
    displayName: appGatewayAuditDenySetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      wafEnableEffect: {
        type: 'String'
        metadata: {
          description: 'Web Application Firewall (WAF) should be enabled for Application Gateway'
          displayName: 'wafEnableEffect'
        }
        allowedValues: allowedValues
      }
      wafModeEffect: {
        type: 'String'
        metadata: {
          description: 'Web Application Firewall (WAF) should use the specified mode for Application Gateway'
          displayName: 'wafModeEffect'
        }
        allowedValues: allowedValues
      }
      modeRequirement: {
        type: 'String'
        metadata: {
          description: 'Mode required for all WAF policies'
          displayName: 'modeRequirement'
        }
        allowedValues: allowedValuesModeRequirement
      }
    }
  policyDefinitions: [
    {
      policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.wafEnable.id)
      parameters: {
        effect: {
          value: '[parameters(\'wafEnableEffect\')]'
        }
      }
    }
    {
      policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionProperties.wafMode.id)
      parameters: {
        effect: {
          value: '[parameters(\'wafModeEffect\')]'
        }
        modeRequirement: {
          value: '[parameters(\'modeRequirement\')]'
        }
      }
    }
  ]  
  }
}  

//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: appGatewayAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: appGatewayAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      wafEnableEffect: {
        value: wafEnableEffect
      }
      wafModeEffect: {
        value: wafModeEffect
      }
      modeRequirement: {
        value: modeRequirement
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
}

// OUTPUTS
