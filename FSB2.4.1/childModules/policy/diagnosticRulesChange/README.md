# policy/diagnosticRulesChange/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys all the Azure policy diagnostic rules for monitoring in a dedicated policy initiative, for the current scope (example: core)
These diagnostic rules cover all managed resources types, and are sending metrics and logs to the log analytics workspace.

The diagnostic rule properties are stored in JSON files, one for each deployment scope.
Depending on the deployment scope parameter, the appropriate Json file will be used.

See below for the detail of the schema used in the JSON file for the diagnostic rule definition.

*NOTE: This policy requires explicit "Log Analytics Contributor" permission on MGMT subscription where centralized log analytic workspace is present*

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions) |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/roleAssignments` (via roleAssignment module) | [2020-10-01-preview](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2020-10-01-preview/roleassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/diagnosticRulesChange/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    deploymentScope: 'core'
    location: location
    policyMetadata:policyMeteringTag
    tagPrefix:tagPrefix
    workspaceResourceID: workspaceResourceID
    deploymentScope: deploymentScope
    managementSubscriptionId: managementSubscriptionId
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `workspaceResourceID` | `string` | true | The ResouredId of the log analytics workspace |
| `location` | `string` | false| Specifies the location where the resource will be deployed. Defaults to resource group location |
| `deploymentScope` | `string` | true | Deployment scope for this parent module. Can be 'core', 'network',  'osmgmt', 'paas' |
| `managementSubscriptionId` | `string` | true | The Id of the management subscription, to be provided by the Monitoring parent module. This is used to give permissions to the MGMT subscription for the policy assignment |
| `deployLocation` | `string` | true | Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment |
| `tagPrefix` | `string` | true | Tag prefix used within the policy rule. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

## Object - JSON diagnostic rule definition schema
| Name | Type | Description |
| --- | --- | --- |
| `shortName` | `string`| The short name of the resource type, used to construct the internal policy name |
| `displayName` | `string`| The display name of the resource type, used to construct the rule display name |
| `deployAtSubscriptionLevel` | `bool`| Specify if the policy will be deployed at subscription level or resource group|
| `useMetricsExistenceCondition` | `bool`| Specify if the policy will use the metrics existence in filters instead of logs |
| `filterOnCompanyManagedTag` | `bool`| Specify if the company managed tag needs to be used in filters in addition to the resource type |
| `policyFilters` |  `object`| Array of filter objects for that will be used in the policy definition. This needs to include the resource type filter. Additional Details [here](#object---policyfilters). |
| `deploymentResources` |`object`| Array of filter objects for that will be used in the policy deployment.Additional Details [here](#object---deploymentresources).  |

### Object - policyFilters
| Name | Type | Description |
| --- | --- | --- |
| `field` | `string` | The type of resource to be used eg. `type`, `tags` etc. |
| `equals` | `string` | The Azure resource for which the policy has to be set. |

### Object - deploymentResources
| Name | Type | Description |
| --- | --- | --- |
| `type` | `string` | Name of the diagnostic rule resource type|
| `name` | `string` | Formated string that will contruct the diagnostic rule name for the given resource. The value '{diagnosticRuleName}' will be replaced at runtime. |
| `properties` | `object` | Properties of a Diagnostic Settings Resource. For more details [click here](https://docs.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings?pivots=deployment-language-bicep#diagnosticsettings) |

## Module Outputs

| Name | Description | Value |
| --- | --- | --- |
| `roleAssignmentDeployName` | Object containing the Role Assigment Deployment Name. | `policySystemManagedIdentityRoleAssignment.name` |.


## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "workspaceResourceID": {
      "value": "/subscriptions/54c0f1b6-842e-4d1c-884f-9c1ae0db98d9/resourcegroups/cu1-sub1-d-rsg-monitoring/providers/microsoft.operationalinsights/workspaces/cu1-sub1-d-loganalytics"
    },
    "deploymentScope": {
      "value": "core"
    },
    "tagPrefix": {
      "value": "Eviden"
    },
    "policyMetadata": {
      "value": "EvidenELZ"
    }
  }
}
```


## Json diagnostic rule definition example entry
```json
{
  "shortName": "kvault",
  "displayName": "Key Vaults",
  "deployAtSubscriptionLevel": false,
  "useMetricsExistenceCondition": false,
  "filterOnCompanyManagedTag": true,
  "policyFilters": [
    {
      "field": "type",
      "equals": "Microsoft.KeyVault/vaults"
    }
  ],
  "deploymentResources": [
    {
      "type": "Microsoft.KeyVault/vaults/providers/diagnosticSettings",
      "name": "[concat(parameters('resourceName'), '/', 'Microsoft.Insights/{diagnosticRuleName}')]",
      "properties": {
        "metrics": [],
        "logs": []
      }
    }
  ]
}
```