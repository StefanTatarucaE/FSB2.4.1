# policy/appServiceChange/policy.bicep
Bicep module to create Azure policy resources.

## Module Features 
This module deploys 5 Azure policy definitions, 1 policy assignment & 1 role assignment.

This module deploys, if not existing for Azure App Services, several resources to ensure the governance and security. This module will: 
- Configure App Service to disable local authentication on FTP deployments.
- Configure App Services to disable public network access
- Configure App Service to disable local authentication for SCM sites.
- Configure App Service Slots to disable local authentication for FTP deployments.
- Configure App Service Slots to disable local authentication for SCM sites.
## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyDefinitions`  | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions) |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions?tabs=bicep) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/roleAssignments` (via roleAssignment module) | [2020-10-01-preview](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2020-10-01-preview/roleassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/appServiceChange/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    appServiceDisableFtpDeployments: 'DeployIfNotExists'
    appServiceUsePrivateDnsZone: 'DeployIfNotExists'
    appServiceDisablePublicNetwork: 'DeployIfNotExists'
    appServiceDisableScmLocalAuthentication: 'Disabled'
    appServiceDisableSlotsFtpLocalAuthentication: 'Disabled'
    appServiceDisableSlotsScmLocalAuthentication: 'Disabled'
    appServiceChangeSetName: 'appservice.change.policy.set'
    appServiceChangeSetDisplayName: 'Azure app service change policy set.'
    appServiceDisableFtpsDeploymentDefName: 'appservice.ftpsdisablebasicauth.change.policy.def'
    appServiceDisableFtpsDeploymentDefDisplayName: 'App service ftp disable basic auth change policy definition.'
    appServiceDisablePublicNetworkAccessDefName: 'appservice.disablepublicnetworkaccess.change.policy.def'
    appServiceDisablePublicNetworkAccessDefDisplayName: 'App service disable public network access change policy definition.'
    appServiceDisableScmLocalAuthenticationDefName: 'appservice.disablescmlocalauth.change.policy.def'
    appServiceDisableScmLocalAuthenticationDefDisplayName: 'App service disable scm local auth change policy definition.'	
    appServiceDisableSlotsFtpLocalAuthenticationDefName: 'appservice.disableslotsftplocalauth.change.policy.def'
    appServiceDisableSlotsFtpLocalAuthenticationDefDisplayName: 'App service disable slots ftp local auth change policy definition.'
    appServiceDisableSlotsScmLocalAuthenticationDefName: 'appservice.disableslotsscmlocalauth.change.policy.def'
    appServiceDisableSlotsScmLocalAuthenticationDefDisplayName: 'App service disable slots scm local auth change policy definition.'
    appServiceChangeSetAssignmentName: 'appservice.change.policy.set.assignment'
    appServiceChangeSetAssignmentDisplayName: 'Azure app service change policy set assignment'
    policyMetadata : 'EvidenELZ'
    policyRuleTag: 'EvidenManaged'
    }
}
```

## Module Parameters 
| Name | Type | Required | Description |
| --- | --- | --- | --- |
|`appServiceDisableFtpDeployments` | `string` | true | Configure App Service to disable local authentication on FTP deployments. Allowed Values: `DeployIfNotExists`,`Disabled`| 
|`appServiceDisablePublicNetwork` | `string` | true | Configure App Services to disable public network access. Allowed Values: `DeployIfNotExists`,`Disabled`|
|`appServiceDisableScmLocalAuthentication` | `string` | true | Configure App Service to disable local authentication for SCM sites. Allowed Values: `DeployIfNotExists`,`Disabled`| 
|`appServiceDisableSlotsFtpLocalAuthentication` | `string` | true |  Configure App Service Slots to disable local authentication for FTP deployments. Allowed Values: `DeployIfNotExists`,`Disabled`| 
|`appServiceDisableSlotsScmLocalAuthentication` | `string` | true | Configure App Service Slots to disable local authentication for SCM sites. Allowed Values: `DeployIfNotExists`,`Disabled`|
| `deployLocation` | `string` | true | Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment |
| `appServiceChangeSetName` | `string` | true | Specify policy definition name for Application Service Change Policy. |
| `appServiceChangeSetDisplayName` | `string` | true | Specify policy displayname for Application Service Change Policy. |
| `appServiceDisableFtpsDeploymentDefName` | `string` | true | Specify policy definition name for Ftp Disable Basic Auth Change Policy. |
| `appServiceDisableFtpsDeploymentDefDisplayName` | `string` | true | Specify policy displayname for Ftp Disable Basic Auth Change Policy. |
| `appServiceDisablePublicNetworkAccessDefName` | `string` | true | Specify policy definition name for Disable Public Network Access Change Policy. |
| `appServiceDisablePublicNetworkAccessDefDisplayName` | `string` | true | Specify policy displayname for Disable Public Network Access Change Policy. |
| `appServiceDisableScmLocalAuthenticationDefName` | `string` | true | Specify policy definition name for Disable Scm Local Auth Change Policy. |
| `appServiceDisableScmLocalAuthenticationDefDisplayName` | `string` | true | Specify policy displayname for Disable Scm Local Auth Change Policy. |
| `appServiceDisableSlotsFtpLocalAuthenticationDefName` | `string` | true | Specify policy definition name for Disable Slots Ftp Local Auth Change Policy. |
| `appServiceDisableSlotsFtpLocalAuthenticationDefDisplayName` | `string` | true | Specify policy displayname for Disable Slots Ftp Local Auth Change Policy. |
| `appServiceDisableSlotsScmLocalAuthenticationDefName` | `string` | true | Specify policy definition name for Disable Slots Scm Local Auth Change Policy. |
| `appServiceDisableSlotsScmLocalAuthenticationDefDisplayName` | `string` | true | Specify policy displayname for Disable Slots Scm Local Auth Change Policy. |
| `appServiceChangeSetAssignmentName` | `string` | true | Specify set assignment name for Application Service Change Policy. |
| `appServiceChangeSetAssignmentDisplayName` | `string` | true | Specify set assignment displayname for Application Service Change Policy. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |
| `excludedResources` | `string[]` | true | Specify the resources excluded from this policy by resourceId |
| `policyRuleTag` | `string` | true | Tag used for the policy rule. |


## Module Outputs

| Name | Description | Value |
| --- | --- | --- |
| `roleAssignmentDeployName` | Object containing the Role Assigment Deployment Name. | `policySystemManagedIdentityRoleAssignment.name` |


## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "appServiceDisableFtpDeployments": {
      "value": "DeployIfNotExists"
    },
    "appServiceDisablePublicNetwork": {
      "value": "DeployIfNotExists"
    },
    "appServiceDisableScmLocalAuthentication": {
      "value": "Disabled"
    },
    "appServiceDisableSlotsFtpLocalAuthentication": {
      "value": "Disabled"
    },
    "appServiceDisableSlotsScmLocalAuthentication": {
      "value": "Disabled"
    },
    "appServiceChangeSetName": {
      "value": "appservice.change.policy.set"
    },
    "appServiceChangeSetDisplayName": {
      "value": "Azure app service change policy set."
    },
    "appServiceDisableFtpsDeploymentDefName": {
      "value": "appservice.ftpsdisablebasicauth.change.policy.def"
    },
    "appServiceDisableFtpsDeploymentDefDisplayName": {
      "value": "App service ftp disable basic auth change policy definition."
    },
    "appServiceDisablePublicNetworkAccessDefName": {
      "value": "appservice.disablepublicnetworkaccess.change.policy.def"
    },
    "appServiceDisablePublicNetworkAccessDefDisplayName": {
      "value": "App service disable public network access change policy definition."
    },
    "appServiceDisableScmLocalAuthenticationDefName": {
      "value": "appservice.disablescmlocalauth.change.policy.def"
    },
    "appServiceDisableScmLocalAuthenticationDefDisplayName": {
      "value": "App service disable scm local auth change policy definition."
    },
    "appServiceDisableSlotsFtpLocalAuthenticationDefName": {
      "value": "appservice.disableslotsftplocalauth.change.policy.def"
    },
    "appServiceDisableSlotsFtpLocalAuthenticationDefDisplayName": {
      "value": "App service disable slots ftp local auth change policy definition."
    },
    "appServiceDisableSlotsScmLocalAuthenticationDefName": {
      "value": "appservice.disableslotsscmlocalauth.change.policy.def"
    },
    "appServiceDisableSlotsScmLocalAuthenticationDefDisplayName": {
      "value": "App service disable slots scm local auth change policy definition."
    },
    "appServiceChangeSetAssignmentName": {
      "value": "appservice.change.policy.set.assignment"
    },
    "appServiceChangeSetAssignmentDisplayName": {
      "value": "Azure app service change policy set assignment"
    },
    "policyMetadata": {
      "value": "EvidenELZ"
    },
    "policyRuleTag": {
      "value": "EvidenManaged"
    },
    "excludedResources": {
      "value": [
        "/subscriptions/3e3ae977-9abe-4702-8132-b41d3107928b/resourceGroups/dv5-mgmt-d-rsg-ostagging/providers/Microsoft.Web/sites/dv5-mgmt-d-functionapp-ostagging"
      ]
    }
  }
}
```