# workspaceLinkedServices/workspaceLinkedServices.bicep
Bicep module to create Link Service between Log Analytics Workspace and Automation Account

## Description
Bicep module to create Link Service between Log Analytics Workspace and Automation Account


## Module Example Use

```bicep

module linkedServices '../../childModules/workspaceLinkedServices/workspaceLinkedServices.bicep' = {
  scope: workspaceResourceGroup
  name: 'workspaceLinkedServices-deployment'
  params: {
    linkedWorkspaceName: linkedWorkspaceName
    automationAccountId: automationAccountId
  }
}

```

## Module Arguments

|  Name | Type | Required | Description |
| --- | --- | --- | --- |
| `linkedWorkspaceName` | `string` | true | Name of the Log Analytics Workspace |
| `automationAccountId` | `string` | true | The resource id of the automation account that will be linked to the workspace. |


## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "linkedWorkspaceName": {
      "value": "dcs-mgmt-d-ws"
    },
    "automationAccountId": {
      "value": "/subscriptions/xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx/resourceGroups/bicep/providers/Microsoft.Automation/automationAccounts/dcs-mgmt-d-aa"
    }
  }
}
```