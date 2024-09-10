// SCOPE

targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS

@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Specify policy name for assessment of missing updates on Windows Policy')
param windowsVmUpdateAssessmentDefName string

@description('Specify policy name for assessment of missing updates on Linux Policy')
param linuxVmUpdateAssessmentDefName string

@description('Specify policy definition display name for updateManager')
param updateManagerDefDisplayname string

@description('Tag used for the policy rule')
param policyRuleTag string

@description('Tag used for the policy rule')
param policyPatchingRuleTag string

@description('Specify policy set definition display name for updateManager')
param updateManagerAssignmentSetDisplayName string

@description('Specify policy set assigment name for updateManager')
param updateManagerSetAssignmentName string

@description('Specify policy set name for updateManager')
param updateManagerSetName string

@description('Specify policy def namefor vmUpdatePatchMode')
param linuxVmUpdatePatchModeDefName string

@description('Specify policy def namefor vmUpdatePatchMode')
param windowsVmUpdatePatchModeDefName string

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment.
param deployLocation string = deployment().location

// VARIABLES

@description('loading the policy definition')
var windowsPolicyDefinition = json(replace(loadTextContent('windowsVmUpdateAssessmentDefinition.json'), '[parameter(CompanyValue)]', '${policyMetadata}'))

@description('loading the policy definition')
var linuxPolicyDefinition = json(replace(loadTextContent('linuxVmUpdateAssessmentDefinition.json'), '[parameter(CompanyValue)]', '${policyMetadata}'))

@description('loading the policy definition')
var linuxUpdatePatchModePolicyDefinition = json(replace(loadTextContent('linuxPatchModeDefinition.json'), '[parameter(CompanyValue)]', '${policyMetadata}'))

@description('loading the policy definition')
var windowsUpdatePatchModePolicyDefinition = json(replace(loadTextContent('windowsPatchModeDefinition.json'), '[parameter(CompanyValue)]', '${policyMetadata}'))

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployLocation), 0, 6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentNameUpdateManager = '${first(split(updateManagerSetName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'

// This variable holds the assignment details for the vmUpdateAssessment Change policy
var updateManagerAssignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identity: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Configure auto-assessment (every 24 hours) for OS updates on native Azure virtual machines & configuration of the patchmode.'
  metadata: {
    source: policyMetadata
  }
  roleDefinitionIdOrNames: [
    'VM Contributor'
  ]
}

// This variable holds initiative details for vmUpdateAssessment Change policy set definition
var updateManagerPolicySetDefinitionProperties = {
  description: 'The initiative holding the policy definitions to enable auto-assessment (every 24 hours) for OS updates on native Azure virtual machines & configuration of the patchmode.'
  metadata: {
    source: policyMetadata
    category: 'Azure Update Manager'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified BuiltIn Custom and Static.
}

// RESOURCES

// Deploy the policy definition for the Windows policy
resource windowsVmUpdateAssessmentPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: windowsVmUpdateAssessmentDefName
  properties: windowsPolicyDefinition.properties
}

// Deploy the policy definition for the Linux policy
resource linuxVmUpdateAssessmentPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: linuxVmUpdateAssessmentDefName
  properties: linuxPolicyDefinition.properties
}

resource linuxVmUpdatePatchModePolicyDefinition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: linuxVmUpdatePatchModeDefName
  properties: linuxUpdatePatchModePolicyDefinition.properties
}

resource windowsVmUpdatePatchModePolicyDefinition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: windowsVmUpdatePatchModeDefName
  properties: windowsUpdatePatchModePolicyDefinition.properties
}

// vmUpdateAssessment Change policy set definition
resource updateManagerPolicySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: updateManagerSetName
  properties: {
    description: updateManagerPolicySetDefinitionProperties.description
    displayName: updateManagerDefDisplayname
    metadata: updateManagerPolicySetDefinitionProperties.metadata
    parameters: {
      managedTagKey: {
        type: 'String'
      }
      patchingTag: {
        type: 'String'
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: windowsVmUpdateAssessmentPolicyDefinition.id
        parameters: {
          managedTagKey: {
            value: '[parameters(\'managedTagKey\')]'
          }
          patchingTag: {
            value: '[parameters(\'patchingTag\')]'
          }
        }
      }
      {
        policyDefinitionId: linuxVmUpdateAssessmentPolicyDefinition.id
        parameters: {
          managedTagKey: {
            value: '[parameters(\'managedTagKey\')]'
          }
          patchingTag: {
            value: '[parameters(\'patchingTag\')]'
          }
        }
      }
      {
        policyDefinitionId: linuxVmUpdatePatchModePolicyDefinition.id
        parameters: {
          managedTagKey: {
            value: '[parameters(\'managedTagKey\')]'
          }
          patchingTag: {
            value: '[parameters(\'patchingTag\')]'
          }
        }
      }
      {
        policyDefinitionId: windowsVmUpdatePatchModePolicyDefinition.id
        parameters: {
          managedTagKey: {
            value: '[parameters(\'managedTagKey\')]'
          }
          patchingTag: {
            value: '[parameters(\'patchingTag\')]'
          }
        }
      }
    ]
  }
}

// Assignment of the vmUpdateAssessment Change policy
resource updateManagerPolicyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: updateManagerSetAssignmentName
  location: updateManagerAssignmentProperties.location
  identity: {
    type: updateManagerAssignmentProperties.identity
  }
  properties: {
    displayName: updateManagerAssignmentSetDisplayName
    description: updateManagerAssignmentProperties.description
    metadata: updateManagerAssignmentProperties.metadata
    policyDefinitionId: updateManagerPolicySetDefinition.id
    parameters: {
      managedTagKey: {
        value: policyRuleTag
      }
      patchingTag: {
        value: policyPatchingRuleTag
      }
    }
  }
}

// Deploy the Role assignment for Update Manager Change policy set.
module policySystemManagedIdentityRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentNameUpdateManager
  params: {
    managedIdentityId: updateManagerPolicyAssignment.identity.principalId
    roleDefinitionIdOrNames: updateManagerAssignmentProperties.roleDefinitionIdOrNames
  }
}

// Outputs

output roleAssignmentDeployName string = policySystemManagedIdentityRoleAssignment.name
