# actionGroup/actionGroup.bicep
Bicep module to create an Azure Action Group for monitoring


## Module Features
Module can deploy an Azure Action Group for monitoring with the following feature :
- LogicApp receiver webhooks (optional)

If needed, this module can be extended later with the possibility of defining actions for Email,webhooks, ...


## Folder Structure Example
```hcl
modules
├── actionGroup
|    ├── actionGroup.bicep
|    ├── preDeploy.tests.ps1
├── storageAccount
├── virtualNetwork
```

## Parent Module Example Use
```hcl
module actionGroup '../../childModules/actionGroup/actionGroup.bicep' {
  scope: monitoringResourceGroup
  name: 'monitoringActionGroup-deployment'
  params: {
    actionGroupName: mgmtActionGroupName
    actionGroupShortName: 'ELZAZ-ITSM' 
    location: 'global'
    tags: tags
    logicAppReceivers: [
      {
        callbackUrl: logicApp.callBackUrl
        name: 'ITSM integration'
        resourceId: logicApp.id
        useCommonAlertSchema: 'True'
      }
    ]
  }
}
```

## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `actionGroupName` | `string` | true | Specifies the name of the actionGroup. |
| `actionGroupShortName` | `string` | true | Specifies the short internal name of the actionGroup. |
| `tags` | `object` | true | A mapping of tags to assign to the resource. Additional Details [here](#object---tags).|
| `logicAppReceivers` | `array` | false | Optional - An array of logicapp receiver objects that will be triggered by the actiongroup. Additional Details [here](#object---logicappreceivers). |

For a complete list of all the possible parameters, see the parameters section in the `actionGroup.bicep` file in this modules folder.

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


### Object - logicAppReceivers
| Name | Type  | Description |
| --- | --- | --- |--- |
| `name`| `string` | The name of the logic app action
| `callbackUrl` | `string`| The callback Url of the logic app|
| `resourceId` | `string`| The Azure resourceId of the logic app|
| `useCommonAlertSchema`| `bool` | Set to true to enable the common alert schema for this logic app|

## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `actionGroupID` | The resource ID of the created actionGroup. | `actionGroup.id` |
| `actionGroupName` | The name of the created actionGroup. | `actionGroup.name` |


## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "actionGroupName": {
      "value": "cu1-mgmt-d-actiongroup-itsm"
    },
    "actionGroupShortName": {
      "value": "ELZAZ-ITSM"
    },
    "tags": {
      "value": {
        "EvidenManaged": "true",
        "Owner": "Fred",
        "Project": "Monitoring Parent Module",
        "ManagedBy": "AzureBicep"
      }
    },
    "logicAppReceivers": {
      "value": [
        {
          "callbackUrl": "<logic app callback url>",
          "name": "ITSM integration",
          "resourceId": "/subscriptions/54c0f1b6-842e-4d1c-884f-9c1ae0db98d9/resourceGroups/cu1-sub1-d-rsg-monitoring/providers/Microsoft.Logic/workflows/cu1-sub1-d-logicapp-itsm",
          "useCommonAlertSchema": "True"
        }
      ]
    }
  }
}
```