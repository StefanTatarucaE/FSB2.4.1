# policy/appServiceAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy definition, 1 policy assignment & 1 role assignment.

This policy will audit the existence of a App Service on a resource. Does not apply to resource groups.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/appServiceAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    appServiceSettings:{
      functionAppHttps: 'Audit'
      appServiceFtpBasicAuthenticationDisabled: 'AuditIfNotExists'
      appServiceUseVnet: 'Audit'
      appServiceDisableTLS1: 'Audit'
      remoteDebuggingForFunctionApp: 'AuditIfNotExists'
      remoteDebuggingForWebApp: 'AuditIfNotExists'
      appServiceEnableInternalEncryption: 'Audit'
      appServiceEnvShouldNotBeReachableOverPublicInternet: 'Audit'
      appServiceLatestVersion: 'Audit'
      functionAppUseFileShare: 'Audit'
      webAppUseFileShare: 'Audit'
      enableResourceLogs: 'AuditIfNotExists'
      denyCorsAccessFunctionApp: 'AuditIfNotExists'
      denyCorsAccessWebApp: 'AuditIfNotExists'
      appServiceSkuSupportsPrivateLink: 'Audit'
      appServiceLatestTLS: 'Audit'
      appServiceUsePrivateLink: 'AuditIfNotExists'
      appServiceScmDisableLocalAuth: 'AuditIfNotExists'
      appServiceSlotsDisableLocalAuth: 'AuditIfNotExists'
      appServiceSlotsScmDisableLocalAuth: 'AuditIfNotExists'
      appServiceShouldNotBeReachableOverPublicInternet: 'Audit'
    }
    appServiceAuditDenySetName: 'appservice.auditdeny.policy.set'
    appServiceAuditDenySetDisplayName: 'App service auditdeny policy set'
    appServiceAuditDenySetAssignmentName: 'appservice.auditdeny.policy.set.assignment'
    appServiceAuditDenySetAssignmentDisplayName: 'App service auditdeny policy set assignment'
    policyMetadata : 'EvidenELZ'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `appServiceSettings` | `object` | true | Object which sets the values of the policy set definition parameters. The specific parameters & what they are for, are described in the `policySetDefinition` resource block. Additional Details [here](#array---appservicesettings).|
| `appServiceAuditDenySetName` | `string` | true | Specify set name for Application Service audit deny initiative. |
| `appServiceAuditDenySetDisplayName` | `string` | true | Specify set displayname for Application Service audit deny initiative. |
| `appServiceAuditDenySetAssignmentName` | `string` | true | Specify set assignment name for Application Service audit deny initiative. |
| `appServiceAuditDenySetAssignmentDisplayName` | `string` | true | Specify set assignment displayname for Application Service audit deny initiative. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

### Array - appServiceSettings
| Name | Type | Description |
| --- | --- | --- |
| `functionAppHttps` | `string` | Function App should only be accessible over HTTPS. Allowed Values: Audit, Disabled |
| `appServiceFtpBasicAuthenticationDisabled` | `string` | App Service should have local authentication methods disabled for FTP deployments. Allowed Values: AuditIfNotExists, Disabled|
| `appServiceUseVnet` | `string` | App Service Apps should be injected into a virtual network. Allowed Values: Audit, Deny, Disabled |
| `appServiceDisableTLS1` | `string` | App Service Environment should disable TLS 1.0 and 1.1. Allowed Values: Audit, Deny, Disabled |
| `remoteDebuggingForFunctionApp` | `string` | Remote debugging should be turned off for Function Apps. Allowed Values: AuditIfNotExists, Disabled|
| `remoteDebuggingForWebApp` | `string` | Remote debugging should be turned off for Web Apps. Allowed Values: AuditIfNotExists, Disabled |
| `appServiceEnableInternalEncryption` | `string` | App Service Environment should enable internal encryption. Allowed Values: Audit, Disabled |
| `appServiceEnvShouldNotBeReachableOverPublicInternet` | `string` | App Service Environment apps should not be reachable over public internet. Allowed Values: Audit, Deny, Disabled|
| `appServiceLatestVersion` | `string` | App Service Environment should be provisioned with latest versions. Allowed Values: Audit, Deny, Disabled |
| `functionAppUseFileShare` | `string` | Function apps should use an Azure file share for its content directory. Allowed Values: Audit, Disabled |
| `webAppUseFileShare` | `string` | Web apps should use an Azure file share for its content directory. Allowed Values: Audit, Disabled |
| `enableResourceLogs` | `string` | Resource logs in App Services should be enabled. Allowed Values: AuditIfNotExists, Disabled|
| `denyCorsAccessFunctionApp` | `string` | CORS should not allow every resource to access your Function Apps. Allowed Values: AuditIfNotExists, Disabled |
| `denyCorsAccessWebApp` | `string` | CORS should not allow every resource to access your Web Applications. Allowed Values: AuditIfNotExists, Disabled|
| `appServiceSkuSupportsPrivateLink` | `string` | App Service apps should use a SKU that supports private link. Allowed Values: Audit, Deny, Disabled|
| `appServiceLatestTLS` | `string` | App Service Environment should be configured with strongest TLS Cipher suites. Allowed Values: Audit, Disabled |
| `appServiceUsePrivateLink` | `string` | App Service should use private link. Allowed Values: AuditIfNotExists, Disabled |
| `appServiceScmDisableLocalAuth` | `string` | App Service should have local authentication methods disabled for SCM site deployments. Allowed Values: AuditIfNotExists, Disabled |
| `appServiceSlotsDisableLocalAuth` | `string` | App Service slots should have local authentication methods disabled for FTP deployments. Allowed Values: AuditIfNotExists, Disabled |
| `appServiceSlotsScmDisableLocalAuth` | `string` | App Service slots should have local authentication methods disabled for SCM site deployments. Allowed Values: AuditIfNotExists, Disabled|
| `appServiceAppsHttps` | `string` | Function apps should only be accessible over HTTPS. Allowed Values: Audit, Disabled |
| `appServiceShouldNotBeReachableOverPublicInternet` | `string` | App Service apps should not be reachable over public internet. Allowed Values: Audit, Deny, Disabled|

## Module Outputs

None.

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "appServiceSettings": {
      "value": {
        "functionAppHttps": "Audit",
        "appServiceFtpBasicAuthenticationDisabled": "AuditIfNotExists",
        "appServiceUseVnet": "Audit",
        "appServiceDisableTLS1": "Audit",
        "appServiceAppsHttps": "Audit",
        "remoteDebuggingForFunctionApp": "AuditIfNotExists",
        "remoteDebuggingForWebApp": "AuditIfNotExists",
        "appServiceEnableInternalEncryption": "Audit",
        "appServiceEnvShouldNotBeReachableOverPublicInternet": "Audit",
        "appServiceLatestVersion": "Audit",
        "functionAppUseFileShare": "Audit",
        "webAppUseFileShare": "Audit",
        "enableResourceLogs": "AuditIfNotExists",
        "denyCorsAccessFunctionApp": "AuditIfNotExists",
        "denyCorsAccessWebApp": "AuditIfNotExists",
        "appServiceSkuSupportsPrivateLink": "Audit",
        "appServiceLatestTLS": "Audit",
        "appServiceUsePrivateLink": "AuditIfNotExists",
        "appServiceScmDisableLocalAuth": "AuditIfNotExists",
        "appServiceSlotsDisableLocalAuth": "AuditIfNotExists",
        "appServiceAppsHttps": "Audit",
        "appServiceSlotsScmDisableLocalAuth": "AuditIfNotExists",
        "appServiceShouldNotBeReachableOverPublicInternet": "Audit"
      }
    },
    "appServiceAuditDenySetName": {
      "value": "appservice.auditdeny.policy.set"
    },
    "appServiceAuditDenySetDisplayName": {
      "value": "App service auditdeny policy set"
    },
    "appServiceAuditDenySetAssignmentName": {
      "value": "appservice.auditdeny.policy.set.assignment"
    },
    "appServiceAuditDenySetAssignmentDisplayName": {
      "value": "App service auditdeny policy set assignment"
    },
    "policyMetadata": {
       "value": "EvidenELZ"
    }
  }
}
```