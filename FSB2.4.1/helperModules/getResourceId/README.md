# getResourceId/getResourceId.bicep
Bicep helper module to get the resourceId of an existing resource in another subscription

## Module Features
This module doesnt deploy anything, but it allow to get the ID of an existing resource in a different subscription.

The module call needs to be scoped to the subscription that is containing the resource, for example the MGMT subscription.
For this, the subscription ID needs to be passed to the parent module as a parameter from the pipeline to be used in the parent module.

The name of the resource group and the name of the resource needs to come from the naming template for the appropriate subscription type.
For example, to get a resource located in the MGMT subscription, the 'mgmtNaming.json' template needs to be used to get the right names.

The module needs to be extended to allow other resources type to be managed when necessary.

## Folder Structure Example
```hcl
modules
├── getResourceId
|    ├── getResourceId.bicep
|    ├── preDeploy.tests.ps1
├── storageAccount
├── virtualNetwork
```

## Parent Module Example Use
```hcl
module existingActionGroupInMgmt '../../childModules/getResourceId/getResourceId.bicep' {
  scope: subscription(mgmtSubId)
  name: 'monitoringActionGroup-getResource'
  params: {
    resourceGroupName: monitoringResourceGroupName
    resourceName: actionGroupName
    resourceType: 'actionGroup'
  }
}

var actionGroupResourceID = existingActionGroupInMgmt.outputs.resourceID
```

## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `resourceGroupName` | `string` | true | Specify the name of the Resource group in the scoped subscription that contains the resource |
| `resourceName` | `string` | true | Specifies the name of the resource in the specified resource group |
| `resourceType` | `string` | true | Specifies the type of the resource. can be 'actionGroup','monitoringWorkspace' |

## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `resourceID` | The resource ID of the resource | n/a |

