# policy/datafactoryChange/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy set definition, 1 policy assignment which contains one Policy Definition.

This policy configures governance and security policies for the Azure Datafactory

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-0](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyDefinitions) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/datafactoryChange/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    disablePublicNetworkAccessEffect : 'Modify'
    policyRuleTag:managedPolicyRuleTag
    disablePublicNetworkAccessDefName: 'datafactory.disablePublicNetworkAccess.change.policy.def'
    disablePublicNetworkAccessDefDisplayName: 'Datafactory disable public network access change policy definition.'
    dataFactoryChangeSetName: 'datafactory.change.policy.set'
    dataFactoryChangeSetDisplayName: 'Datafactory change policy set'
    dataFactoryChangeSetAssignmentName: 'datafactory.change.policy.set.assignment'
    dataFactoryChangeSetAssignmentDisplayName: 'Datafactory change policy set assignment'
    policyMetadata : 'EvidenELZ'
    }
  }
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `disablePublicNetworkAccessEffect` | `string` | true | Desired effect to set, when a Data Factory instance with public network access enabled is detected.|
| `deployLocation` | `string` | true | Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment |
| `disablePublicNetworkAccessDefName` | `string` | true | Datafactory disable public network access change policy definition name. |
| `disablePublicNetworkAccessDefDispalyName` | `string` | true | Datafactory disable public network access change policy definition display name |
| `dataFactoryChangeSetName` | `string` | true | set name for datafactory change initiative. |
| `dataFactoryChangeSetDisplayName` | `string` | true | set displayname for datafactory change initiative. |
| `dataFactoryChangeSetAssignmentName` | `string` | true | set assignment name for datafactory change initiative. |
| `dataFactoryChangeSetAssignmentDisplayName` | `string` | true | set assignment displayname for datafactory change initiative. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |
| `policyRuleTag` | `string` | true | Tag used for the policy rule. |

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
        "disablePublicNetworkAccessEffect": {
            "value": "Modify"
        },
        "disablePublicNetworkAccessDefName": {
            "value": "datafactory.disablePublicNetworkAccess.change.policy.def"
        },
        "disablePublicNetworkAccessDefDisplayName": {
            "value": "Datafactory disable public network access change policy definition."
        },
        "dataFactoryChangeSetName": {
            "value": "datafactory.change.policy.set"
        },
        "dataFactoryChangeSetDisplayName": {
            "value": "Datafactory change policy set"
        },
        "dataFactoryChangeSetAssignmentName": {
            "value": "datafactory.change.policy.set.assignment"
        },
        "dataFactoryChangeSetAssignmentDisplayName": {
            "value": "Datafactory change policy set assignment"
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