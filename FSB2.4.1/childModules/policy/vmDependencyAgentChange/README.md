# policy/vmDependencyAgentChange/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys one Azure policy set definition which contains two custom policies , the policy assignment and one role assignment required for the effect of the policies. This module will
- install dependency agent on Windows Machine
- install dependency agent on Linux Machine


## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2020-09-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyDefinitions) |


## Module Example Use
```bicep

module vmDependencyAgentChange '../../childModules/policy/vmDependencyAgentChange/policy.bicep' = {
  name: '${uniqueDeployPrefix}-vmDependencyAgent-deployment'
  params: {
        vmEnableDependencyAgentWinDefName : 'vm-enabledependencyagentwin-change-policy-def'
        vmEnableDependencyAgentWinDefDisplayName : 'Virtual Machine enable Windows dependency agent change policy definition'
        policyRuleTag:'EvidenManaged'
        vmEnableDependencyAgentWinDefEffect : 'DeployIfNotExists'
        vmEnableDependencyAgentLinuxDefName : 'vm-enabledependencyagentlinux-change-policy-def'
        vmEnableDependencyAgentLinuxDefDisplayName : 'Virtual Machine enable Linux dependency agent change policy definition'
        vmEnableDependencyAgentLinuxDefEffect : 'DeployIfNotExists'
        vmEnableDependencyAgentSetName : 'vmdependencyagent-change-policy-set'
        vmEnableDependencyAgentSetDisplayName : 'Virtual Machine dependency agent change policy initiative'
        vmEnableDependencyAgentSetAssignmentName : 'vmdependencyagent-change-policy-set-assignment'
        vmEnableDependencyAgentSetAssignmentDisplayName : 'Virtual Machine dependency agent change policy initiative assignment'
        policyMetadata : 'EvidenELZ'
  }
}

```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `vmEnableDependencyAgentWinDefName` | `string` | true | Specify policy name for enable dependency agent for Windows Vm policy |
| `vmEnableDependencyAgentWinDefDisplayName` | `string` | true | Specify policy display name for enable dependency agent for Windows Vm policy |
| `vmEnableDependencyAgentWinDefEffect` | `string` | true | Desired policy effect to set dependency agent on Windows Virtual Machine. Allowed values:  DeployIfNotExists and Disabled  |
| `vmEnableDependencyAgentLinuxDefName` | `string` | true | Specify policy name for enable dependency agent for Linux Vm policy |
| `vmEnableDependencyAgentLinuxDefDisplayName` | `string` | true | Specify policy display name for enable dependency agent for Linux Vm policy |
| `vmEnableDependencyAgentLinuxDefEffect` | `string` | true | Desired policy effect to set dependency agent on Linux Virtual Machine. Allowed values:  DeployIfNotExists and Disabled  |
| `vmEnableDependencyAgentSetName` | `string` | true | Specify policy set name for vm dependency agent initiative |
| `vmEnableDependencyAgentSetDisplayName` | `string` | true | Specify policy set display name for vm dependency agent initiative |
| `vmEnableDependencyAgentSetAssignmentName` | `string` | true | Specify policy asignment name for vm dependency agent initiative |
| `vmEnableDependencyAgentSetAssignmentDisplayName` | `string` | true | Specify policy asignment display name for vm dependency agent initiative |
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
        "vmEnableDependencyAgentWinDefName": {
            "value": "vm-enabledependencyagentwin-change-policy-def"
        },
        "vmEnableDependencyAgentWinDefDisplayName": {
            "value": "Virtual Machine enable Windows dependency agent change policy definition"
        },
        "vmEnableDependencyAgentWinDefEffect": {
            "value": "DeployIfNotExists"
        },
        "vmEnableDependencyAgentLinuxDefName": {
            "value": "vm-enabledependencyagentlinux-change-policy-def"
        },
        "vmEnableDependencyAgentLinuxDefDisplayName": {
            "value": "Virtual Machine enable Linux dependency agent change policy definition"
        },
        "vmEnableDependencyAgentLinuxDefEffect": {
            "value": "DeployIfNotExists"
        },
        "vmEnableDependencyAgentSetName": {
            "value": "vmdependencyagent-change-policy-set"
        },
        "vmEnableDependencyAgentSetDisplayName": {
            "value": "Virtual Machine dependency agent change policy initiative"
        },
        "vmEnableDependencyAgentSetAssignmentName": {
            "value": "vmdependencyagent-change-policy-set-assignment"
        },
        "vmEnableDependencyAgentSetAssignmentDisplayName": {
            "value": "Virtual Machine dependency agent change policy initiative assignment"
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