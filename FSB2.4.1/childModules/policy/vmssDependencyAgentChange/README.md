# policy/vmssDependencyAgentChange/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys one Azure policy set definition which contains two custom policies , the policy assignment and one role assignment required for the effect of the policies. This module will
- install dependency agent on Windows Virtual Machine Scale Set
- install dependency agent on Linux Virtual Machine Scale Set


## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2020-09-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyDefinitions) |


## Module Example Use
```bicep
module vmssDependencyAgentChange '../../childModules/policy/vmssDependencyAgentChange/policy.bicep' = {
  name: '${uniqueDeployPrefix}-vmssDependencyAgent-deployment'
  params: {
        vmssEnableDependencyAgentWinDefName : 'vmss-enabledependencyagentwin-change-policy-def'
        vmssEnableDependencyAgentWinDefDisplayName : 'Virtual Machine Scale Set enable Windows dependency agent change policy definition'
        vmssEnableDependencyAgentWinDefEffect : 'DeployIfNotExists'
        vmssEnableDependencyAgentLinuxDefName : 'vmss-enabledependencyagentlinux-change-policy-def'
        vmssEnableDependencyAgentLinuxDefDisplayName : 'Virtual Machine Scale Set enable Linux dependency agent change policy definition'
        vmssEnableDependencyAgentLinuxDefEffect : 'DeployIfNotExists'
        vmssEnableDependencyAgentSetName : 'vmssdependencyagent-change-policy-set'
        vmssEnableDependencyAgentSetDisplayName : 'Virtual Machine Scale Set dependency agent change policy initiative'
        vmssEnableDependencyAgentSetAssignmentName : 'vmssdependencyagent-change-policy-set-assignment'
        policyMetadata : 'EvidenELZ'
  }
}

```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `vmssEnableDependencyAgentWinDefName` | `string` | true | Specify policy name for enable dependency agent for Windows Vm Scale Set policy |
| `vmssEnableDependencyAgentWinDefDisplayName` | `string` | true | Specify policy display name for enable dependency agent for Windows Vm Scale Set policy |
| `vmssEnableDependencyAgentWinDefEffect` | `string` | true | Desired policy effect to set dependency agent on Windows Virtual Machine Scale Set. Allowed values:  DeployIfNotExists and Disabled  |
| `vmssEnableDependencyAgentLinuxDefName` | `string` | true | Specify policy name for enable dependency agent for Linux Vm Scale Set policy |
| `vmssEnableDependencyAgentLinuxDefDisplayName` | `string` | true | Specify policy display name for enable dependency agent for Linux Vm Scale Set policy |
| `vmssEnableDependencyAgentLinuxDefEffect` | `string` | true | Desired policy effect to set dependency agent on Linux Virtual Machine Scale Set. Allowed values:  DeployIfNotExists and Disabled  |
| `vmssEnableDependencyAgentSetName` | `string` | true | Specify policy set name for vm scale set dependency agent initiative |
| `vmssEnableDependencyAgentSetDisplayName` | `string` | true | Specify policy set display name for vm scale set dependency agent initiative |
| `vmssEnableDependencyAgentSetAssignmentName` | `string` | true | Specify policy asignment name for vm scale set dependency agent initiative |
| `vmssEnableDependencyAgentSetAssignmentDisplayName` | `string` | true | Specify policy asignment display name for vm scale set dependency agent initiative |
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
        "vmssEnableDependencyAgentWinDefName": {
            "value": "vmss-enabledependencyagentwin-change-policy-def"
        },
        "vmssEnableDependencyAgentWinDefDisplayName": {
            "value": "Virtual Machine Scale Set enable Windows dependency agent change policy definition"
        },
        "vmssEnableDependencyAgentWinDefEffect": {
            "value": "DeployIfNotExists"
        },
        "vmssEnableDependencyAgentLinuxDefName": {
            "value": "vmss-enabledependencyagentlinux-change-policy-def"
        },
        "vmssEnableDependencyAgentLinuxDefDisplayName": {
            "value": "Virtual Machine Scale Set enable Linux dependency agent change policy definition"
        },
        "vmssEnableDependencyAgentLinuxDefEffect": {
            "value": "DeployIfNotExists"
        },
        "vmssEnableDependencyAgentSetName": {
            "value": "vmssdependencyagent-change-policy-set"
        },
        "vmssEnableDependencyAgentSetDisplayName": {
            "value": "Virtual Machine Scale Set dependency agent change policy initiative"
        },
        "vmssEnableDependencyAgentSetAssignmentName": {
            "value": "vmssdependencyagent-change-policy-set-assignment"
        },
        "vmssEnableDependencyAgentSetAssignmentDisplayName": {
            "value": "Virtual Machine Scale Set dependency agent change policy initiative assignment"
        },
        "vmssEnableDependencyAgentSetAssignmentName": {
            "value": "vmssdependencyagent-change-policy-set-assignment"
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