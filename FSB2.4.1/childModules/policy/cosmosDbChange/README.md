# policy/cosmosDbChange/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys one Azure policy set definition which contains two custom policies and one built-in policy, the associated policies and the assignment and role assignment(s) required for the effect of the policies.

This policy set configures governance policies for CosmosDB resources

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-0](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyDefinitions) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/cosmosDbChange/policy.bicep' = {
  name: 'deployCosmosDbGovernancePolicy'
  params: {
    disableLocalAuthenticationEffect: 'Modify'
    advancedThreatProtectionEffect: 'DeployIfNotExists'
    policyRuleTag:'EvidenManaged'
    cosmosdbChangeSetName : 'cosmosdb.change.policy.set'
    cosmosdbChangeSetDisplayName : 'Cosmosdb change policy set'
    cosmosdbChangeSetAssignmentName : 'cosmosdb.change.policy.set.assignment'
    cosmosdbChangeSetAssignmentDisplayName : 'Cosmosdb change policy set assignment'
    cosmosdbAdvancedThreatProtectionDefName : 'cosmosdb.advancedthreatprotection.change.policy.def'
    cosmosdbAdvancedThreatProtectionDefDisplayName : 'Cosmosdb advanced threat protection change policy definition.'
    cosmosdbDisableLocalAuthenticationDefName : 'cosmosdb.disablelocalauthentication.change.policy.def'
    cosmosdbDisableLocalAuthenticationDefDisplayName : 'Cosmosdb disable local authentication change policy definition.'
    policyMetadata : 'EvidenELZ'
    }
  }
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `disableLocalAuthenticationEffect` | `string` | true | set Policy Effect to Disabled or Modify |
| `advancedThreatProtectionEffect` | `string` | true | set Policy Effect to Disabled or DeployIfNotExists |
| `deployLocation` | `string` | true | Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment |
| `cosmosdbChangeSetName` | `string` | true | set name for cosmosdb change initiative. |
| `cosmosdbChangeSetDisplayName` | `string` | true | set displayname for cosmosdb change initiative. |
| `cosmosdbChangeSetAssignmentName` | `string` | true | set assignment name for cosmosdb change initiative. |
| `cosmosdbChangeSetAssignmentDisplayName` | `string` | true | set assignment displayname for cosmosdb change initiative. |
| `cosmosdbAdvancedThreatProtectionDefName` | `string` | true | def name for the AdvancedThreatProtection policy within the initiative. |
| `cosmosdbAdvancedThreatProtectionDefDisplayName` | `string` | true | def displayname displayname for AdvancedThreatProtection within the initiative. |
| `cosmosdbDisableLocalAuthenticationDefName` | `string` | true | def name for the DisableLocalAuthentication policy within the initiative. |
| `cosmosdbDisableLocalAuthenticationDefDisplayName` | `string` | true | def  assignment displayname for DisableLocalAuthentication within the initiative |
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
    "disableLocalAuthenticationEffect": {
      "value": "Modify"
    },
    "advancedThreatProtectionEffect": {
      "value": "DeployIfNotExists"
    },
    "cosmosdbChangeSetName": {
      "value": "cosmosdb.change.policy.set"
    },
    "cosmosdbChangeSetDisplayName": {
      "value": "Cosmosdb change policy set"
    },
    "cosmosdbChangeSetAssignmentName": {
      "value": "cosmosdb.change.policy.set.assignment"
    },
    "cosmosdbChangeSetAssignmentDisplayName": {
      "value": "Cosmosdb change policy set assignment"
    },
    "cosmosdbAdvancedThreatProtectionDefName": {
      "value": "cosmosdb.advancedthreatprotection.change.policy.def"
    },
    "cosmosdbAdvancedThreatProtectionDefDisplayName": {
      "value": "Cosmosdb advanced threat protection change policy definition."
    },
    "cosmosdbDisableLocalAuthenticationDefName": {
      "value": "cosmosdb.disablelocalauthentication.change.policy.def"
    },
    "cosmosdbDisableLocalAuthenticationDefDisplayName": {
      "value": "Cosmosdb disable local authentication change policy definition."
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