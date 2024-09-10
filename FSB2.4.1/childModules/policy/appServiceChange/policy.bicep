/*
SUMMARY: App Service Change Policy child module.
DESCRIPTION: Deployment of App Service Change Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Specify the resources excluded from this policy by resourceId')
param excludedResources array

@description('Enable or disable the execution of the policy')
@metadata({
  displayName: 'Configure App Service to disable local authentication on FTP deployments.'
})
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param appServiceDisableFtpDeployments string

@description('Allowed Values: DeployIfNotExists, Disabled')
@metadata({
  displayName: 'Enable or disable the public network access for Azure App Service'
})
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param appServiceDisablePublicNetwork string

@description('Allowed Values: DeployIfNotExists, Disabled')
@metadata({
  displayName: 'App Service should have local authentication methods disabled for SCM site deployments'
})
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param appServiceDisableScmLocalAuthentication string

@description('Allowed Values: DeployIfNotExists, Disabled')
@metadata({
  displayName: 'App Service slots should have local authentication methods disabled for FTP deployments'
})
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param appServiceDisableSlotsFtpLocalAuthentication string

@description('Allowed Values: DeployIfNotExists, Disabled')
@metadata({
  displayName: 'App Service slots should have local authentication methods disabled for SCM site deployments'
})
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param appServiceDisableSlotsScmLocalAuthentication string

//Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment. 
param deployLocation string = deployment().location

@description('Specify policy definition name for Application Service Change Policy')
param appServiceChangeSetName string

@description('Specify policy displayname for Application Service Change Policy')
param appServiceChangeSetDisplayName string

@description('Specify policy definition name for Ftp Disable Basic Auth Change Policy')
param appServiceDisableFtpsDeploymentDefName string

@description('Specify policy displayname for Ftp Disable Basic Auth Change Policy')
param appServiceDisableFtpsDeploymentDefDisplayName string

@description('Specify policy definition name for Disable Public Network Access Change Policy')
param appServiceDisablePublicNetworkAccessDefName string

@description('Specify policy displayname for Disable Public Network Access Change Policy')
param appServiceDisablePublicNetworkAccessDefDisplayName string

@description('Specify policy definition name for Disable Scm Local Auth Change Policy')
param appServiceDisableScmLocalAuthenticationDefName string

@description('Specify policy displayname for Disable Scm Local Auth Change Policy')
param appServiceDisableScmLocalAuthenticationDefDisplayName string

@description('Specify policy definition name for Disable Slots Ftp Local Auth Change Policy')
param appServiceDisableSlotsFtpLocalAuthenticationDefName string

@description('Specify policy displayname for Disable Slots Ftp Local Auth Change Policy')
param appServiceDisableSlotsFtpLocalAuthenticationDefDisplayName string

@description('Specify policy definition name for Disable Slots Scm Local Auth Change Policy')
param appServiceDisableSlotsScmLocalAuthenticationDefName string

@description('Specify policy displayname for Disable Slots Scm Local Auth Change Policy')
param appServiceDisableSlotsScmLocalAuthenticationDefDisplayName string

@description('Specify set assignment name for Application Service Change Policy')
param appServiceChangeSetAssignmentName string

@description('Specify set assignment displayname for Application Service Change Policy')
param appServiceChangeSetAssignmentDisplayName string

@description('Tag used for the policy rule')
param policyRuleTag string

// VARIABLES
//Variable which holds the definition details.
var appServicePolicySetDefinitionProperties = {
  description: 'This configures governance and security policies to Azure App Service'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
    category: 'App Service'
  }
  mode: 'All'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

//Variable which holds the disable FTPs deployment.
var disableFtpsDeploymentDefinitionProperties = {
  description: 'Disable local authentication methods for FTP deployments so that your App Services exclusively require Azure Active Directory identities for authentication. Learn more at: https://aka.ms/app-service-disable-basic-auth.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'App Service'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

//Variable which holds the app service disable public network access.
var disablePublicNetworkAccessDefinitionProperties = {
  description: 'Disable public network access for your App Services so that it is not accessible over the public internet. This can reduce data leakage risks. Learn more at: https://aka.ms/app-service-private-endpoint.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'App Service'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

//Variable which holds the app service disable scm local authentication.
var disableScmLocalAuthenticationDefinitionProperties = {
  description: 'Disable local authentication methods for SCM sites so that your App Services exclusively require Azure Active Directory identities for authentication. Learn more at: https://aka.ms/app-service-disable-basic-auth.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'App Service'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

//Variable which holds the app service disable local authentication methods for FTP deployments.
var disableAppServiceSlotsFtpLocalAuthenticationDefinitionProperties = {
  description: 'Disable local authentication methods for FTP deployments so that your App Services slots exclusively require Azure Active Directory identities for authentication. Learn more at: https://aka.ms/app-service-disable-basic-auth.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'App Service'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

//Variable which holds the app service disable local authentication methods for SCM sites.
var disableAppServiceSlotsScmLocalAuthenticationDefinitionProperties = {
  description: 'Disable local authentication methods for FTP deployments so that your App Services slots exclusively require Azure Active Directory identities for authentication. Learn more at: https://aka.ms/app-service-disable-basic-auth.'
  metadata: {
    source: policyMetadata
    version: '1.0.0'
    category: 'App Service'
  }
  mode: 'Indexed'
  policyType: 'Custom' //The type of policy definition. Possible values are NotSpecified, BuiltIn, Custom, and Static.
}

//Variables which holds the assignment details for app service
var appServiceAssignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identity: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'This configures governance and security policies to Azure App Service'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  roleDefinitionIdOrNames: [
    'Website Contributor'
  ]
}

// Variable which holds a unique variable for deployment, which is bound to the subscription id and the location of the policy deployment
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployLocation), 0, 6)

//Variable used to construct the name of the Role Assignment Deployment
var roleAssignmentName = '${first(split(appServiceChangeSetName, '-'))}-${uniqueDeployPrefix}-roleAssignment-deployment'

// RESOURCE DEPLOYMENTS
//Deploy the policy definition

//App Service Disable FTP's Deployment policy - DeployIfNotExists
resource disableFTPsDeploymentPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: appServiceDisableFtpsDeploymentDefName
  properties: {
    displayName: appServiceDisableFtpsDeploymentDefDisplayName
    description: disableFtpsDeploymentDefinitionProperties.description
    policyType: disableFtpsDeploymentDefinitionProperties.policyType
    mode: disableFtpsDeploymentDefinitionProperties.mode
    metadata: disableFtpsDeploymentDefinitionProperties.metadata
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          description: 'Configure App Service to disable local authentication on FTP deployments.'
          displayName: 'appServiceDisableFtpDeployments'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Web/sites'
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          name: 'ftp'
          type: 'Microsoft.Web/sites/basicPublishingCredentialsPolicies'
          existenceCondition: {
            field: 'Microsoft.Web/sites/basicPublishingCredentialsPolicies/allow'
            equals: 'false'
          }
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/de139f84-1756-47ae-9be6-808fbbe84772'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                siteName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  siteName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.Web/sites/basicPublishingCredentialsPolicies'
                    name: '[concat(parameters(\'siteName\'), \'/ftp\')]'
                    apiVersion: '2021-02-01'
                    location: '[parameters(\'location\')]'
                    tags: {}
                    properties: {
                      allow: 'false'
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

//App Service Disable Network Access policy - DeployIfNotExists
resource disablePublicNetworkAccessPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: appServiceDisablePublicNetworkAccessDefName
  properties: {
    displayName: appServiceDisablePublicNetworkAccessDefDisplayName
    policyType: disablePublicNetworkAccessDefinitionProperties.policyType
    mode: disablePublicNetworkAccessDefinitionProperties.mode
    description: disablePublicNetworkAccessDefinitionProperties.description
    metadata: disablePublicNetworkAccessDefinitionProperties.metadata
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          description: 'Enable or disable the public network access for Azure App Service'
          displayName: 'appServiceDisablePublicNetwork'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Web/sites'
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Web/sites/config'
          existenceCondition: {
            field: 'Microsoft.Web/sites/config/publicNetworkAccess'
            equals: 'Disabled'
          }
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/de139f84-1756-47ae-9be6-808fbbe84772'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                webAppName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  webAppName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    name: '[concat(parameters(\'webAppName\'), \'/web\')]'
                    type: 'Microsoft.Web/sites/config'
                    apiVersion: '2020-09-01'
                    location: '[parameters(\'location\')]'
                    properties: {
                      publicNetworkAccess: 'Disabled'
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

//App Service Disable Scm Local Authentication policy - DeployIfNotExists
resource disableScmLocalAuthenticationPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: appServiceDisableScmLocalAuthenticationDefName
  properties: {
    displayName: appServiceDisableScmLocalAuthenticationDefDisplayName
    description: disableScmLocalAuthenticationDefinitionProperties.description
    policyType: disableScmLocalAuthenticationDefinitionProperties.policyType
    mode: disableScmLocalAuthenticationDefinitionProperties.mode
    metadata: disableScmLocalAuthenticationDefinitionProperties.metadata
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          description: 'App Service should have local authentication methods disabled for SCM site deployments'
          displayName: 'appServiceDisableScmLocalAuthentication'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Web/sites'
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          name: 'scm'
          type: 'Microsoft.Web/sites/basicPublishingCredentialsPolicies'
          existenceCondition: {
            field: 'Microsoft.Web/sites/basicPublishingCredentialsPolicies/allow'
            equals: 'false'
          }
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/de139f84-1756-47ae-9be6-808fbbe84772'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                siteName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  siteName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.Web/sites/basicPublishingCredentialsPolicies'
                    name: '[concat(parameters(\'siteName\'), \'/scm\')]'
                    apiVersion: '2021-02-01'
                    location: '[parameters(\'location\')]'
                    tags: {}
                    properties: {
                      allow: 'false'
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

//App Service Disable Slots local authentication methods for FTP deployments - DeployIfNotExists
resource disableAppServiceSlotsFtpLocalAuthenticationPolicyDefinition 'Microsoft.Authorization/policydefinitions@2020-09-01' = {
  name: appServiceDisableSlotsFtpLocalAuthenticationDefName
  properties: {
    displayName: appServiceDisableSlotsFtpLocalAuthenticationDefDisplayName
    description: disableAppServiceSlotsFtpLocalAuthenticationDefinitionProperties.description
    policyType: disableAppServiceSlotsFtpLocalAuthenticationDefinitionProperties.policyType
    mode: disableAppServiceSlotsFtpLocalAuthenticationDefinitionProperties.mode
    metadata: disableAppServiceSlotsFtpLocalAuthenticationDefinitionProperties.metadata
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          description: 'App Service slots should have local authentication methods disabled for FTP deployments'
          displayName: 'appServiceDisableSlotsFtpLocalAuthentication'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Web/sites/slots'
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          name: 'ftp'
          type: 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies'
          existenceCondition: {
            field: 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies/allow'
            equals: 'false'
          }
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/de139f84-1756-47ae-9be6-808fbbe84772'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                siteName: {
                  value: '[field(\'fullName\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  siteName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies'
                    name: '[concat(parameters(\'siteName\'), \'/ftp\')]'
                    apiVersion: '2021-02-01'
                    location: '[parameters(\'location\')]'
                    tags: {}
                    properties: {
                      allow: 'false'
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

//App Service Disable Slots local authentication methods for SCM deployments - DeployIfNotExists
resource disableAppServiceSlotsScmLocalAuthenticationPolicyDefinition 'Microsoft.Authorization/policydefinitions@2020-09-01' = {
  name: appServiceDisableSlotsScmLocalAuthenticationDefName
  properties: {
    displayName: appServiceDisableSlotsScmLocalAuthenticationDefDisplayName
    description: disableAppServiceSlotsScmLocalAuthenticationDefinitionProperties.description
    policyType: disableAppServiceSlotsScmLocalAuthenticationDefinitionProperties.policyType
    mode: disableAppServiceSlotsScmLocalAuthenticationDefinitionProperties.mode
    metadata: disableAppServiceSlotsScmLocalAuthenticationDefinitionProperties.metadata
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          description: 'App Service slots should have local authentication methods disabled for SCM site deployments'
          displayName: 'appServiceDisableSlotsScmLocalAuthentication'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Web/sites/slots'
          }
          {
            field: 'tags.${policyRuleTag}'
            equals: true
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          name: 'scm'
          type: 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies'
          existenceCondition: {
            field: 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies/allow'
            equals: 'false'
          }
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/de139f84-1756-47ae-9be6-808fbbe84772'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                siteName: {
                  value: '[field(\'fullName\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  siteName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies'
                    name: '[concat(parameters(\'siteName\'), \'/scm\')]'
                    apiVersion: '2021-02-01'
                    location: '[parameters(\'location\')]'
                    tags: {}
                    properties: {
                      allow: 'false'
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

//App Service Change Initiative policy definitions
resource appServicePolicySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: appServiceChangeSetName
  properties: {
    description: appServicePolicySetDefinitionProperties.description
    displayName: appServiceChangeSetDisplayName
    metadata: appServicePolicySetDefinitionProperties.metadata
    parameters: {
      appServiceDisableFtpDeployments: {
        type: 'String'
        metadata: {
          description: 'Configure App Service to disable local authentication on FTP deployments.'
          displayName: 'appServiceDisableFtpDeployments'
        }
      }
      appServiceDisablePublicNetwork: {
        type: 'String'
        metadata: {
          description: 'Enable or disable the public network access for Azure App Service'
          displayName: 'appServiceDisablePublicNetwork'
        }
      }
      appServiceDisableScmLocalAuthentication: {
        type: 'String'
        metadata: {
          description: 'App Service should have local authentication methods disabled for SCM site deployments'
          displayName: 'appServiceDisableScmLocalAuthentication'
        }
      }
      appServiceDisableSlotsFtpLocalAuthentication: {
        type: 'String'
        metadata: {
          description: 'App Service slots should have local authentication methods disabled for FTP deployments'
          displayName: 'appServiceDisableSlotsFtpLocalAuthentication'
        }
      }
      appServiceDisableSlotsScmLocalAuthentication: {
        type: 'String'
        metadata: {
          description: 'App Service slots should have local authentication methods disabled for SCM site deployments'
          displayName: 'appServiceDisableSlotsScmLocalAuthentication'
        }
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: disableFTPsDeploymentPolicyDefinition.id
        parameters: {
          effect: {
            value: '[parameters(\'appServiceDisableFtpDeployments\')]'
          }
        }
      }
      {
        policyDefinitionId: disablePublicNetworkAccessPolicyDefinition.id
        parameters: {
          effect: {
            value: '[parameters(\'appServiceDisablePublicNetwork\')]'
          }
        }
      }
      {
        policyDefinitionId: disableScmLocalAuthenticationPolicyDefinition.id
        parameters: {
          effect: {
            value: '[parameters(\'appServiceDisableScmLocalAuthentication\')]'
          }
        }
      }
      {
        policyDefinitionId: disableAppServiceSlotsFtpLocalAuthenticationPolicyDefinition.id
        parameters: {
          effect: {
            value: '[parameters(\'appServiceDisableSlotsFtpLocalAuthentication\')]'
          }
        }
      }
      {
        policyDefinitionId: disableAppServiceSlotsScmLocalAuthenticationPolicyDefinition.id
        parameters: {
          effect: {
            value: '[parameters(\'appServiceDisableSlotsScmLocalAuthentication\')]'
          }
        }
      }
    ]

  }
}

//App Service Policy assignment
resource appServicePolicyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: appServiceChangeSetAssignmentName
  location: appServiceAssignmentProperties.location
  properties: {
    displayName: appServiceChangeSetAssignmentDisplayName
    description: appServiceAssignmentProperties.description
    metadata: appServiceAssignmentProperties.metadata
    policyDefinitionId: appServicePolicySetDefinition.id
    notScopes: excludedResources != [] ? excludedResources : null
    parameters: {
      appServiceDisableFtpDeployments: {
        value: appServiceDisableFtpDeployments
      }
      appServiceDisablePublicNetwork: {
        value: appServiceDisablePublicNetwork
      }
      appServiceDisableScmLocalAuthentication: {
        value: appServiceDisableScmLocalAuthentication
      }
      appServiceDisableSlotsFtpLocalAuthentication: {
        value: appServiceDisableSlotsFtpLocalAuthentication
      }
      appServiceDisableSlotsScmLocalAuthentication: {
        value: appServiceDisableSlotsScmLocalAuthentication
      }
    }
  }
  identity: {
    type: appServiceAssignmentProperties.identity
  }
}

//Deploy the Role assignment for the app service policy assignment
module appServicePolicyRoleAssignment '../../roleAssignment/roleAssignment.bicep' = {
  name: roleAssignmentName
  params: {
    managedIdentityId: appServicePolicyAssignment.identity.principalId
    roleDefinitionIdOrNames: appServiceAssignmentProperties.roleDefinitionIdOrNames
  }
}

// OUTPUTS
output roleAssignmentDeployName string = appServicePolicyRoleAssignment.name
