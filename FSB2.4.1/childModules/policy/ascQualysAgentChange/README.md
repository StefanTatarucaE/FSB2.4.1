# policy/ascQualysAgent/policy.bicep
Bicep module to create Azure policy resources for the Qualys agent.

## Module Features
This module deploys the policy to install qualys agents in Windows and Linux machines if the below tags are available
| Tags key | Value|
| --- | --- |
| EvidenManaged | true|
| EvidenCompliance | true |

This module deploys 2 Azure policy definitions, 1 Azure policy set definition, 1 policy assignment & 1 role assignment.

This policy will deploy the Qualys agent for Virtual Machines if the agent is not installed.

P.S.:
Below are some of the things to remember
1. Both the parameters should never be false together
1. If both Linux and Windows policies are deployed, Azure does not allow removing a policy definition from the policy set. it will throw the below error
 ```diff
-New-AzDeployment: 11:59:12 AM - The deployment 'policy' failed with error(s). Showing 1 out of 1 error(s).
-Status Message: The existing policy has '2' parameter(s) which is greater than the count of parameter(s) '1' in the policy being -added. Policy parameters cannot be removed during policy update. (Code:InvalidPolicySetParameterUpdate)
-CorrelationId: efea465b-78ad-4c3a-8647-29b537b994b2
```
For this scenario where both policy definitions have been added previously and one needs to be removed delete the assignment and polciy set and re-add it. This is not an issue during adding a policy definition in the set.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions) |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/roleAssignments` (via roleAssignment module) | [2020-10-01-preview](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2020-10-01-preview/roleassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/ascQualysAgentChange/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
        deployQualysWindowsPolicy : true 
        deployQualysLinuxPolicy : true
        ascQualysAgentChangeWindowsDefName: 'ascqualysagent.windows.change.policy.def'
        ascQualysAgentChangeWindowsDefDisplayName: 'Azure security center qualys agent windows change policy definition'
        ascQualysAgentChangeLinuxDefName: 'ascqualysagent.linux.change.policy.def'
        ascQualysAgentChangeLinuxDefDisplayName: 'Azure security center qualys agent linux change policy definition'
        ascQualysAgentChangeSetName: 'ascqualysagent.change.policy.set'
        ascQualysAgentChangeSetDisplayName: 'Azure security center qualys agent change policy set'
        ascQualysAgentChangeSetAssignmentName: 'ascqualysagent.change.policy.set.assignment'
        ascQualysAgentChangeSetAssignmentDisplayName: 'Azure security center qualys agent change policy assignment'
        policyMetadata : 'EvidenELZ'
        policyRuleTag:[
            'EvidenManaged'
            'EvidenCompliance'
            ]
     }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `deployQualysWindowsPolicy` | `bool` | true | This parameter will allow deployment of Windows qualys agent if set true  |
| `deployQualysLinuxPolicy` | `bool` | true | This parameter will allow deployment of Linux qualys agent if set true  |
| `deployLocation` | `string` | true |  Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment |
| `ascQualysAgentChangeWindowsDefName` | `string` | true | Specify name for definition of ascQualysAgentWindows change policy.  |
| `ascQualysAgentChangeWindowsDefDisplayName` | `string` | true | Specify display name for definition of ascQualysAgentWindows change policy. |
| `ascQualysAgentChangeLinuxDefName` | `string` | true | Specify name for definition of ascQualysAgentLinux change policy. |
| `ascQualysAgentChangeLinuxDefDisplayName` | `string` | true | Specify display name for definition of ascQualysAgentLinux change policy. |
| `ascQualysAgentChangeSetName` | `string` | true | Specify name for ascQualysAgent change initiative. |
| `ascQualysAgentChangeSetDisplayName` | `string` | true | Specify display name for ascQualysAgent change initiative. |
| `ascQualysAgentChangeSetAssignmentName` | `string` | true | Specify name for assignment of ascQualysAgent change initiative. |
| `ascQualysAgentChangeSetAssignmentDisplayName` | `string` | true | Specify display name for assignment of ascQualysAgent change initiative. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |
| `policyRuleTag` | `array` | true | Tag used for the policy rule. |


## Module Outputs

| Name | Description | Value |
| --- | --- | --- |
| `roleAssignmentDeployName` | Object containing the Role Assigment Deployment Name. | `policySystemManagedIdentityRoleAssignment.name` |

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "deployQualysWindowsPolicy": {
            "value": true
        },
        "deployQualysLinuxPolicy": {
            "value": true
        },
        "ascQualysAgentChangeWindowsDefName": {
            "value": "ascqualysagent.windows.change.policy.def"
        },
        "ascQualysAgentChangeWindowsDefDisplayName": {
            "value": "Azure security center qualys agent windows change policy definition"
        },
        "ascQualysAgentChangeLinuxDefName": {
            "value": "ascqualysagent.linux.change.policy.def"
        },
        "ascQualysAgentChangeLinuxDefDisplayName": {
            "value": "Azure security center qualys agent linux change policy definition"
        },
        "ascQualysAgentChangeSetName": {
            "value": "ascqualysagent.change.policy.set"
        },
        "ascQualysAgentChangeSetDisplayName": {
            "value": "Azure security center qualys agent change policy set"
        },
        "ascQualysAgentChangeSetAssignmentName": {
            "value": "ascqualysagent.change.policy.set.assignment"
        },
        "ascQualysAgentChangeSetAssignmentDisplayName": {
            "value": "Azure security center qualys agent change policy assignment"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        },
        "policyRuleTag": {
            "value": [
                "EvidenManaged",
                "EvidenCompliance"
            ]
        }
    }
}
```