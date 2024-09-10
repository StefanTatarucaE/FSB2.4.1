# policy/guestConfigurationChange/guestConfigurationChange.bicep

Bicep module to create Azure policy resource.
## Module Features

This module deploys policy definition, policy initative, policy assignment and role assignments for installing the Guest Configuration Agent.
The policy will install Guest Configuration agent on both Windows and Linux Virtual machines once the <company>Managed tag is set to 'true'

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions) |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/roleAssignments` (via roleAssignment module) | [2020-10-01-preview](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2020-10-01-preview/roleassignments) |

## Module Example Use

```bicep
module guestConfigPolicy '../../childModules/policy/guestConfigurationChange/policy.bicep' =  {
  name: 'policy-deployment'
  params: {
    guestConfigChangeWinDefName: 'guestconfig-win-change-policy-def'
    policyRuleTag:'EvidenELZ'
    guestConfigChangeWinDefDisplayName: 'Install Guest Configuration agent for Windows OS'
    guestConfigChangeLinuxDefName: 'guestconfig-linux-change-policy-def'
    guestConfigChangeLinuxDefDisplayName: 'Install Guest Configuration agent for Linux OS'
    guestConfigChangeSetName: 'guestconfig-change-policy-set'
    guestConfigChangeSetDisplayName: 'Guest Configuration agent policy set'
    guestConfigChangeAssignmentName: 'sub1-d-guestconfig-change-policy-set-assignment'
    guestConfigChangeAssignmentDisplayName: 'Install Guest Configuration agent for both Windows and Linux'
    policyMetadata : 'EvidenELZ'
  }
}
```
## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `guestConfigChangeWinDefName` | `string` | true | Name of the Guest Configuration Windows Policy definition |
| `guestConfigChangeWinDefDisplayName` | `string` | true | Display Name for the Guest Configuration Windows Policy definition |
| `guestConfigChangeLinuxDefName` | `string` | true | Name of the Guest Configuration Linux Policy definition  |
| `guestConfigChangeLinuxDefDisplayName` | `string` | true | Display Name for the Guest Configuration Linux Policy definition |
| `guestConfigChangeSetName` | `string` | true | Name of the Guest Configuration Policy Initative |
| `guestConfigChangeSetDisplayName` | `string` | true | Display Name for the Guest Configuration Policy Initative |
| `guestConfigChangeAssignmentName` | `string` | true | Name of the Guest Configuration Policy Assignment |
| `guestConfigChangeAssignmentDisplayName` | `string` | true | Display Name for the Guest Configuration Policy Assignment |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |
| `policyRuleTag` | `string` | true | Tag used for the policy rule. |


## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "guestConfigChangeWinDefName": {
        "value": "guestconfig-win-change-policy-def"
      },
      "guestConfigChangeWinDefDisplayName": {
        "value": "Install Guest Configuration agent for Windows OS"
      },
      "guestConfigChangeLinuxDefName": {
        "value": "guestconfig-linux-change-policy-def"
      },
      "guestConfigChangeLinuxDefDisplayName": {
        "value": "Install Guest Configuration agent for Linux OS"
      },
      "guestConfigChangeSetName": {
        "value": "guestconfig-change-policy-set"
      },
      "guestConfigChangeSetDisplayName": {
        "value": "Guest Configuration agent policy set"
      },
      "guestConfigChangeAssignmentName": {
        "value": "sub1-d-guestconfig-change-policy-set-assignment"
      },
      "guestConfigChangeAssignmentDisplayName": {
        "value": "Install Guest Configuration agent for both Windows and Linux"
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
