# policy/acrChange/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys one Azure policy set definition which contains four custom policies , the policy assignment and one role assignment required for the effect of the policies. This module will
- Configure container registries to disable local authentication.
- Configure container registries to disable repository scoped access token.
- Configure container registries to disable anonymous authentication.
- Configure container registries to disable public network access.


## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2020-09-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyDefinitions) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/acrChange/policy.bicep' = {
  name: 'deployAcrGovernancePolicy'
  params: {
    acrDisableLocalAuthentication: 'Modify'
    acrDisableTokenAccess: 'Disabled'
    acrDisableAnonymousAuthentication: 'Modify'
    acrDisablePublicNetworkAccess: 'Modify'
    acrDisableLocalAuthenticationDefName : 'acr.disablelocalauth.change.policy.def'
    acrDisableLocalAuthenticationDefDisplayName : 'Acr disable local auth change policy definition'
    acrDisableTokenAccessDefName : 'acr.disabletokenaccess.change.policy.def'
    acrDisableTokenAccessDefDisplayName: 'Acr disable token access change policy definition'
    acrDisableAnonymousAuthenticationDefName : 'acr.disableanonymousauthaccess.change.policy.def'
    acrDisableAnonymousAuthenticationDefDisplayName : 'Acr disable anonymous auth access change policy definition'
    acrDisablePublicNetworkAccessDefName : 'acr.disablepublicnwaccess.change.policy.def'
    acrDisablePublicNetworkAccessDefDisplayName : 'Acr disable public network access change policy definition'
    acrDisableSetName : 'acr.change.policy.set'
    acrDisableSetDisplayName : 'This initiative configures governance and security policies to Azure Container Registry'
    acrDisableSetAssignmentName : 'acr.change.policy.set.assignment'
    acrDisableSetAssignmentDisplayName : 'Acr change policy set assignment'
    policyMetadata:'EvidenELZ'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `acrDisableLocalAuthentication` | `string` | true | set Policy Effect to Disabled or Modify |
| `acrDisableTokenAccess` | `string` | true | set Policy Effect to Disabled or Modify |
| `acrDisableAnonymousAuthentication` | `string` | true | set Policy Effect to Disabled or Modify |
| `acrDisablePublicNetworkAccess` | `string` | true | set Policy Effect to Disabled or Modify |
| `deployLocation` | `string` | true | Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment |
| `acrDisableLocalAuthenticationDefName` | `string` | true | Specify policy name for disable ACR local authentication policy|
| `acrDisableLocalAuthenticationDefDisplayName` | `string` | true |Specify policy display name for disable ACR local authentication policy |
| `acrDisableTokenAccessDefName` | `string` | true |Specify policy name for disable ACR token access policy |
| `acrDisableTokenAccessDefDisplayName` | `string` | true |Specify policy display name for disable ACR token access policy |
| `acrDisableAnonymousAuthenticationDefName` | `string` | true |Specify policy name for disable ACR anonymous authentication policy |
| `acrDisableAnonymousAuthenticationDefDisplayName` | `string` | true |Specify policy display name for disable ACR anonymous authentication policy |
| `acrDisablePublicNetworkAccessDefName` | `string` | true |Specify policy name for disable ACR public network access policy |
| `acrDisablePublicNetworkAccessDefDisplayName` | `string` | true |Specify policy display name for disable ACR public network access policy |
| `acrDisableSetName` | `string` | true |Specify policy set name for acr disable initiative |
| `acrDisableSetDisplayName` | `string` | true |Specify policy set display name for acr disable initiative |
| `acrDisableSetAssignmentName` | `string` | true |Specify policy asignment name for acr disable initiative |
| `acrDisableSetAssignmentDisplayName` | `string` | true |Specify policy asignment display name for acr disable initiative |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |
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
        "acrDisableLocalAuthentication": {
            "value": "Modify"
        },
        "acrDisableTokenAccess": {
            "value": "Disabled"
        },
        "acrDisableAnonymousAuthentication": {
            "value": "Modify"
        },
        "acrDisablePublicNetworkAccess": {
            "value": "Modify"
        },
        "acrDisableLocalAuthenticationDefName": {
            "value": "acr.disablelocalauth.change.policy.def"
        },
        "acrDisableLocalAuthenticationDefDisplayName": {
            "value": "Acr disable local auth change policy definition"
        },
        "acrDisableTokenAccessDefName": {
            "value": "acr.disabletokenaccess.change.policy.def"
        },
        "acrDisableTokenAccessDefDisplayName": {
            "value": "Acr disable token access change policy definition"
        },
        "acrDisableAnonymousAuthenticationDefName": {
            "value": "acr.disableanonymousauthaccess.change.policy.def"
        },
        "acrDisableAnonymousAuthenticationDefDisplayName": {
            "value": "Acr disable anonymous auth access change policy definition"
        },
        "acrDisablePublicNetworkAccessDefName": {
            "value": "acr.disablepublicnwaccess.change.policy.def"
        },
        "acrDisablePublicNetworkAccessDefDisplayName": {
            "value": "Acr disable public network access change policy definition"
        },
        "acrDisableSetName": {
            "value": "acr.change.policy.set"
        },
        "acrDisableSetDisplayName": {
            "value": "This initiative configures governance and security policies to Azure Container Registry"
        },
        "acrDisableSetAssignmentName": {
            "value": "acr.change.policy.set.assignment"
        },
        "acrDisableSetAssignmentDisplayName": {
            "value": "Acr change policy set assignment"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        },
        "policyRuleTag": {
            "value": "EvidenManaged"
        }
    }
}

```