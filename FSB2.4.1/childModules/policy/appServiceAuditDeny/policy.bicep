/*
SUMMARY: App Service Audit/Deny Policy child module.
DESCRIPTION: Deployment of App Service Audit/Deny Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

//SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

//PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param appServiceSettings object

@description('Specify set name for Application Service audit deny initiative')
param appServiceAuditDenySetName string

@description('Specify set displayname for Application Service audit deny initiative')
param appServiceAuditDenySetDisplayName string

@description('Specify set assignment name for Application Service audit deny initiative')
param appServiceAuditDenySetAssignmentName string

@description('Specify set assignment displayname for Application Service audit deny initiative')
param appServiceAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variable for allowedValues.

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

var effectAuditDisableDeny = concat(effectAuditDisabled,effectDeny)

//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This policy set configures governance and security policies to App Service'
  metadata: {
    category: 'App Service'
    source: policyMetadata
    version: '0.0.1'
  }
}

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that App Service has relevant governance and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

//RESOURCE DEPLOYMENTS
//Deploy the policy definition set for the definitions created in previous resource block
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: appServiceAuditDenySetName
  properties: {
    displayName: appServiceAuditDenySetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      functionAppHttps: {
        type: 'String'
        metadata: {
          description: 'Function App should only be accessible over HTTPS. Allowed Values: Audit, Disabled'
          displayName: 'functionAppHttps'
        }
        allowedValues: effectAuditDisabled
      }
      appServiceAppsHttps: {
        type: 'String'
        metadata: {
          description: 'App Service apps should only be accessible over HTTPS. Allowed Values: Audit, Disabled, Deny'
          displayName: 'appServiceAppsHttps'
        }
        allowedValues: effectAuditDisableDeny
      }
      appServiceFtpBasicAuthenticationDisabled: {
        type: 'String'
        metadata: {
          description: 'App Service should have local authentication methods disabled for FTP deployments. Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'appServiceFtpBasicAuthenticationDisabled'
        }
        allowedValues: effectAuditIfNotExistDisabled
      }
      appServiceUseVnet: {
        type: 'String'
        metadata: {
          description: 'App Service Apps should be injected into a virtual network. Allowed Values: Audit, Deny, Disabled'
          displayName: 'appServiceUseVnet'
        }
        allowedValues: effectAuditDisableDeny
      }
      appServiceDisableTLS1: {
        type: 'String'
        metadata: { 
          description: 'App Service Environment should disable TLS 1.0 and 1.1. Allowed Values: Audit, Deny, Disabled'
          displayName: 'appServiceDisableTLS1'
        }
        allowedValues: effectAuditDisableDeny
      }
      remoteDebuggingForFunctionApp: {
        type: 'String'
        metadata: {
          description: 'Remote debugging should be turned off for Function Apps. Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'remoteDebuggingForFunctionApp'
        }
        allowedValues: effectAuditIfNotExistDisabled
      }
      remoteDebuggingForWebApp: {
        type: 'String'
        metadata: {
          description: 'Remote debugging should be turned off for Web Apps. Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'remoteDebuggingForWebApp'
        }
        allowedValues: effectAuditIfNotExistDisabled
      }
      appServiceEnableInternalEncryption: {
        type: 'String'
        metadata: { 
          description: 'App Service Environment should enable internal encryption. Allowed Values: Audit, Disabled'
          displayName: 'appServiceEnableInternalEncryption'
        }
        allowedValues: effectAuditDisabled
      }
      appServiceEnvShouldNotBeReachableOverPublicInternet: {
        type: 'String'
        metadata: {
          description: 'App Service Environment apps should not be reachable over public internet. Allowed Values: Audit, Deny, Disabled'
          displayName: 'appServiceEnvShouldNotBeReachableOverPublicInternet'
        }
        allowedValues: effectAuditDisableDeny
        defaultValue: 'Audit'
      }
      appServiceLatestVersion: {
        type: 'String'
        metadata: {
          description: 'App Service Environment should be provisioned with latest versions. Allowed Values: Audit, Deny, Disabled'
          displayName: 'appServiceLatestVersion'
        }
        allowedValues: effectAuditDisableDeny
      }
      functionAppUseFileShare: {
        type: 'String'
        metadata: {
          description: 'Function apps should use an Azure file share for its content directory. Allowed Values: Audit, Disabled'
          displayName: 'functionAppUseFileShare'
        }
        allowedValues: effectAuditDisabled
      }
      webAppUseFileShare: {
        type: 'String'
        metadata: {
          description: 'Web apps should use an Azure file share for its content directory. Allowed Values: Audit, Disabled'
          displayName: 'webAppUseFileShare'
        }
        allowedValues: effectAuditDisabled
      }
      enableResourceLogs: {
        type: 'String'
        metadata: {
          description: 'Resource logs in App Services should be enabled. Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'enableResourceLogs'
        }
        allowedValues: effectAuditIfNotExistDisabled
      }
      denyCorsAccessFunctionApp: {
        type: 'String'
        metadata: {
          description: 'CORS should not allow every resource to access your Function Apps. Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'denyCorsAccessFunctionApp'
        }
        allowedValues: effectAuditIfNotExistDisabled
      }
      denyCorsAccessWebApp: {
        type: 'String'
        metadata: {
          description: 'CORS should not allow every resource to access your Web Applications. Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'denyCorsAccessWebApp'
        }
        allowedValues: effectAuditIfNotExistDisabled
      }
      appServiceSkuSupportsPrivateLink: {
        type: 'String'
        metadata: {
          description: 'App Service apps should use a SKU that supports private link. Allowed Values: Audit, Deny, Disabled'
          displayName: 'appServiceSkuSupportsPrivateLink'
        }
        allowedValues: effectAuditDisableDeny
      }
      appServiceLatestTLS: {
        type: 'String'
        metadata: {
          description: 'App Service Environment should be configured with strongest TLS Cipher suites. Allowed Values: Audit, Disabled'
          displayName: 'appServiceLatestTLS'
        }
        allowedValues: effectAuditDisabled
      }
      appServiceUsePrivateLink: {
        type: 'String'
        metadata: {
          description: 'App Service should use private link. Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'appServiceUsePrivateLink'
        }
        allowedValues: effectAuditIfNotExistDisabled
      }
      appServiceScmDisableLocalAuth: {
        type: 'String'
        metadata: {
          description: 'App Service should have local authentication methods disabled for SCM site deployments. Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'appServiceScmDisableLocalAuth'
        }
        allowedValues: effectAuditIfNotExistDisabled
      }
      appServiceSlotsDisableLocalAuth: {
        type: 'String'
        metadata: {
          description: 'App Service slots should have local authentication methods disabled for FTP deployments. Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'appServiceSlotsDisableLocalAuth'
        }
        allowedValues: effectAuditIfNotExistDisabled
      }
      appServiceSlotsScmDisableLocalAuth: {
        type: 'String'
        metadata: {
          description: 'App Service slots should have local authentication methods disabled for SCM site deployments. Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'appServiceSlotsScmDisableLocalAuth'
        }
        allowedValues: effectAuditIfNotExistDisabled
      }
      appServiceShouldNotBeReachableOverPublicInternet: {
        type: 'String'
        metadata: {
          description: 'App Service should have public network access disabled so that it is not accessible over the public internet. Allowed Values: AuditIfNotExists, Disabled'
          displayName: 'appServiceShouldNotBeReachableOverPublicInternet'
        }
        allowedValues: effectAuditDisableDeny
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/6d555dd1-86f2-4f1c-8ed7-5abae7c6cbab'
        parameters: {
          effect: {
            value: '[parameters(\'functionAppHttps\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a4af4a39-4135-47fb-b175-47fbdf85311d'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceAppsHttps\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/871b205b-57cf-4e1e-a234-492616998bf7'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceFtpBasicAuthenticationDisabled\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/72d04c29-f87d-4575-9731-419ff16a2757'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceUseVnet\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/d6545c6b-dd9d-4265-91e6-0b451e2f1c50'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceDisableTLS1\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0e60b895-3786-45da-8377-9c6b4b6ac5f9'
        parameters: {
          effect: {
            value: '[parameters(\'remoteDebuggingForFunctionApp\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/cb510bfd-1cba-4d9f-a230-cb0976f4bb71'
        parameters: {
          effect: {
            value: '[parameters(\'remoteDebuggingForWebApp\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/fb74e86f-d351-4b8d-b034-93da7391c01f'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceEnableInternalEncryption\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/2d048aca-6479-4923-88f5-e2ac295d9af3'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceEnvShouldNotBeReachableOverPublicInternet\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/eb4d34ab-0929-491c-bbf3-61e13da19f9a'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceLatestVersion\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/4d0bc837-6eff-477e-9ecd-33bf8d4212a5'
        parameters: {
          effect: {
            value: '[parameters(\'functionAppUseFileShare\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/dcbc65aa-59f3-4239-8978-3bb869d82604'
        parameters: {
          effect: {
            value: '[parameters(\'webAppUseFileShare\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/91a78b24-f231-4a8a-8da9-02c35b2b6510'
        parameters: {
          effect: {
            value: '[parameters(\'enableResourceLogs\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0820b7b9-23aa-4725-a1ce-ae4558f718e5'
        parameters: {
          effect: {
            value: '[parameters(\'denyCorsAccessFunctionApp\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/5744710e-cc2f-4ee8-8809-3b11e89f4bc9'
        parameters: {
          effect: {
            value: '[parameters(\'denyCorsAccessWebApp\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/546fe8d2-368d-4029-a418-6af48a7f61e5'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceSkuSupportsPrivateLink\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/817dcf37-e83d-4999-a472-644eada2ea1e'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceLatestTLS\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/687aa49d-0982-40f8-bf6b-66d1da97a04b'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceUsePrivateLink\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/aede300b-d67f-480a-ae26-4b3dfb1a1fdc'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceScmDisableLocalAuth\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ec71c0bc-6a45-4b1f-9587-80dc83e6898c'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceSlotsDisableLocalAuth\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/847ef871-e2fe-4e6e-907e-4adbf71de5cf'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceSlotsScmDisableLocalAuth\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1b5ef780-c53c-4a64-87f3-bb9c8c8094ba'
        parameters: {
          effect: {
            value: '[parameters(\'appServiceShouldNotBeReachableOverPublicInternet\')]'
          }
        }
      }
    ]
  }
}

//Deploy the policy assignemnt 
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: appServiceAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties:{
    description: assignmentProperties.description
    displayName: appServiceAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      functionAppHttps: {
        value: appServiceSettings.functionAppHttps
      }
      appServiceAppsHttps: {
        value: appServiceSettings.appServiceAppsHttps
      }
      appServiceFtpBasicAuthenticationDisabled: {
        value: appServiceSettings.appServiceFtpBasicAuthenticationDisabled
      }
      appServiceUseVnet: {
        value: appServiceSettings.appServiceUseVnet
      }
      appServiceDisableTLS1: {
        value: appServiceSettings.appServiceDisableTLS1
      }
      remoteDebuggingForFunctionApp: {
        value: appServiceSettings.remoteDebuggingForFunctionApp
      }
      remoteDebuggingForWebApp: {
        value: appServiceSettings.remoteDebuggingForWebApp
      }
      appServiceEnableInternalEncryption: {
        value: appServiceSettings.appServiceEnableInternalEncryption
      }
      appServiceEnvShouldNotBeReachableOverPublicInternet: {
        value: appServiceSettings.appServiceEnvShouldNotBeReachableOverPublicInternet
      }
      appServiceLatestVersion: {
        value: appServiceSettings.appServiceLatestVersion
      }
      functionAppUseFileShare: {
        value: appServiceSettings.functionAppUseFileShare
      }
      webAppUseFileShare: {
        value: appServiceSettings.webAppUseFileShare
      }
      enableResourceLogs: {
        value: appServiceSettings.enableResourceLogs
      }
      denyCorsAccessFunctionApp: {
        value: appServiceSettings.denyCorsAccessFunctionApp
      }
      denyCorsAccessWebApp: {
        value: appServiceSettings.denyCorsAccessWebApp
      }
      appServiceSkuSupportsPrivateLink: {
        value: appServiceSettings.appServiceSkuSupportsPrivateLink
      }
      appServiceLatestTLS: {
        value: appServiceSettings.appServiceLatestTLS
      }
      appServiceUsePrivateLink: {
        value: appServiceSettings.appServiceUsePrivateLink
      }
      appServiceScmDisableLocalAuth: {
        value: appServiceSettings.appServiceScmDisableLocalAuth
      }
      appServiceSlotsDisableLocalAuth: {
        value: appServiceSettings.appServiceSlotsDisableLocalAuth
      }
      appServiceSlotsScmDisableLocalAuth: {
        value: appServiceSettings.appServiceSlotsScmDisableLocalAuth
      }
      appServiceShouldNotBeReachableOverPublicInternet: {
        value: appServiceSettings.appServiceShouldNotBeReachableOverPublicInternet
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
}

//OUTPUTS

