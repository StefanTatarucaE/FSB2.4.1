# policy/UpdateManagerChange/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys one Azure policy set definition which contains four custom policies , the policy assignment and one role assignment required for the effect of the policies. This module will:

- configure the assessment mode for Linux and Windows systems.
- configure the patch mode for Linux and Windows systems.
- set the bypassPlatformSafetyChecksOnUserSchedule to yes on Linux and Windows systems.

The policy definitions for the initiative are assembled using json definition files because of the size of the definitions. This is an exception on the usual way of working.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2020-09-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyDefinitions) |


## Module Example Use
```bicep
module updateManagerChange '../../childModules/policy/updateManagerChange/policy.bicep' = if (deployUpdateManagerChange && osMgmtChangePolicies) {
  name: '${uniqueDeployPrefix}-UpdateManagerChange-deployment'
  params: {
    policyMetadata: 'EvidenELZ'
    deployLocation: 'West Europe'
    policyRuleTag:'EvidenManaged'
    policyPatchingRuleTag:'EvidenPatching'
    windowsVmUpdateAssessmentDefName: 'windows-update-assessment-change-policy-def'
    linuxVmUpdateAssessmentDefName: 'linux-update-assessment-change-policy-def'
    updateManagerSetAssignmentName: '${policyPrefix}updatemanager-change-policy-set-assignment'
    updateManagerSetName: 'updatemanager-change-policy-set'
    updateManagerDefDisplayname: 'Update Manager change policy set'
    updateManagerAssignmentSetDisplayName: 'Update Manager change policy set assignment'
    linuxVmUpdatePatchModeDefName: 'linux-update-patch-mode-change-policy-def'
    windowsVmUpdatePatchModeDefName: 'windows-update-patch-mode-change-policy-def'
  }
}

```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `windowsVmUpdateAssessmentDefName` | `string` | true | Specify policy name for for setting the assessment mode for a Windows systems |
| `linuxVmUpdateAssessmentDefName` | `string` | true | Specify policy name for for setting the assessment mode for a Linux systems |
| `updateManagerSetAssignmentName` | `string` | true | Specify the policy set assignment name.  |
| `updateManagerSetName` | `string` | true | Specify the set definiton name for the UpdateManager Change initiative |
| `updateManagerDefDisplayname` | `string` | true | Specify set definition displayname for the UpdateManager change initiative. |
| `updateManagerAssignmentSetDisplayName` | `string` | true | Specify the set assignment displayname for the UpdateManager change initiative.  |
| `linuxVmUpdatePatchModeDefName` | `string` | true | Specify definition name for the update patch mode policy for Linux  |
| `windowsVmUpdatePatchModeDefName` | `string` | true | Specify definition name for the update patch mode policy for Windows |

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
        "windowsVmUpdateAssessmentDefName": {
            "value": "vm-enabledependencyagentwin-change-policy-def"
        },
        "linuxVmUpdateAssessmentDefName": {
            "value": "Virtual Machine enable Windows dependency agent change policy definition"
        },
        "updateManagerSetAssignmentName": {
            "value": "DeployIfNotExists"
        },
        "updateManagerSetName": {
            "value": "vm-enabledependencyagentlinux-change-policy-def"
        },
        "updateManagerDefDisplayname": {
            "value": "Virtual Machine enable Linux dependency agent change policy definition"
        },
        "updateManagerAssignmentSetDisplayName": {
            "value": "DeployIfNotExists"
        },
        "linuxVmUpdatePatchModeDefName": {
            "value": "vmdependencyagent-change-policy-set"
        },
        "windowsVmUpdatePatchModeDefName": {
            "value": "Virtual Machine dependency agent change policy initiative"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        },
        "policyRuleTag": {
            "value": "EvidenManaged"
        },
        "policyPatchingRuleTag": {
            "value": "EvidenPatching"
        }
    }
}

```