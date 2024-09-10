# activityLogAlertRule/activityLogAlertRule.bicep
Bicep module to create an activity Log Alert Rule (for service and resource health alert)

## Module Features
Module can deploy an activity log alert rule, to create the following alerts type :
- Service health
- Resource health

## Folder Structure Example
```hcl
modules
├── activityLogAlertRule
|    ├── activityLogAlertRule.bicep
|    ├── preDeploy.tests.ps1
├── storageAccount
├── virtualNetwork
```

## Parent Module Example Use
```hcl
module ResourceHealthAlertRules '../../childModules/activityLogAlertRule/activityLogAlertRule.bicep' = {
  scope: monitoringResourceGroup
  name: 'ResourceHealthAlertRule-deployment'
  params: {
    location: 'global'
    actionGroupId: actionGroupResourceID
    tags: tags
    alertName: resHealthAlert.alertName
    alertDescription: resHealthAlert.alertDescription
    alertType: resHealthAlert.alertType
    resourceTypesCondition: resHealthAlert.resourceTypesCondition
  }
}
```

## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `alertName` | `string` | true | Specifies the name of the alert rule. |
| `alertDescription` | `string` | true | Specifies the description of the alert rule. |
| `tags` | `object` | true | A mapping of tags to assign to the resource. Additional Details [here](#object---tags).|
| `actionGroupId` | `string` | true | Specifies the resourceID of the action group that will be triggered by the alert |
| `resourceTypesCondition` | `array` | false| Array of resources types condition to filter the resource health alert (see documentation for syntax : https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/activitylogalerts). Additional Details [here](#array---resourcetypescondition).  |
| `alertType` | `string` | true | Specifies the short internal name of the actionGroup.   'ServiceHealth' or 'ResourceHealth' |


For a complete list of all the possible parameters, see the parameters section in the `activityLogAlertRule.bicep` file in this modules folder.

### Object - tags
Below is an example of the tags object

`"key"`:`"value"`

**Example:**
```json
{
    "EvidenManaged": "true",
    "Project": "Monitoring Parent Module",
    "ManagedBy": "AzureBicep"
}
```


### Array - resourceTypesCondition
| Name | Type | Description |
| --- | --- |--- |
| `field` | `string`| The name of the Activity Log event's field that this condition will examine.The possible values for this field are (case-insensitive): 'resourceId', 'category', 'caller', 'level', 'operationName', 'resourceGroup', 'resourceProvider', 'status', 'subStatus', 'resourceType', or anything beginning with 'properties'. |
| `equals`| `string` | The value of the event's field will be compared to this value (case-insensitive) to determine if the condition is met.|
| `containsAny`| `string[]` | The value of the event's field will be compared to the values in this array (case-insensitive) to determine if the condition is met.|


## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `activityLogAlertRuleResourceID` | The resource ID of the created activity log alert. | `activityLogAlertRule.id` |
| `activityLogAlertRuleName` | The name of the created activity log alert. | `activityLogAlertRule.name` |

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "alertName": {
      "value": "Azure Resource Health alert rule - Virtual machines OS"
    },
    "alertDescription": {
      "value": "Cloud.IaaS.DCS-Azure-OS - This Resource Health alert is triggered when an issue occurs in Azure platform "
    },
    "tags": {
      "value": {
        "EvidenManaged": "true",
        "Owner": "Fred",
        "Project": "Monitoring Parent Module",
        "ManagedBy": "AzureBicep"
      }
    },
    "actionGroupId": {
      "value": "/subscriptions/54c0f1b6-842e-4d1c-884f-9c1ae0db98d9/resourceGroups/cu1-mgmt-d-rsg-monitoring-CESAZURE-219/providers/microsoft.insights/actionGroups/cu1-mgmt-d-actiongroup-itsm"
    },
    "alertType": {
      "value": "ServiceHealth"
    },
    "resourceTypesCondition": {
      "value" : [
        {
          "field": "resourceType",
          "equals": "Microsoft.compute/virtualmachines",
          "containsAny": null
        },
        {
          "field": "resourceType",
          "equals": "Microsoft.classiccompute/virtualmachines",
          "containsAny": null
        },
        {
          "field": "resourceType",
          "equals": "Microsoft.classiccompute/domainnames",
          "containsAny": null
        }
      ]
    }      
  }
}
```