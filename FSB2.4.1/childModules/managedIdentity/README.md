# managedIdentity/managedIdentity.bicep
Bicep module to create a User Managed Identity.

## Module Features
Module can deploy a user Managed Identity resource.

## Module Example Use
```hcl
module exampleManagedIdentity '../childModules/managedIdentity/managedIdentity.bicep' = {
  scope: exampleResourceGroup
  name: 'deployExampleUserManagedIdentity'
  params: {
    userManagedIdentityName: userManagedIdentityName
    location: location
    tags: tags
  }
}
```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `userManagedIdentityName` | `string` | true | Specifies the name of the User Managed Identity. |
| `location` | `string` | true| Specifies the location where the resource will be deployed. |
| `tags` | `object` | false | A mapping of tags to assign to the resource. Additional Details [here](#object---tags).|

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

## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `userManagedIdentityName` | The resource name of the created User Managed Identity. | `userManagedIdentity.name` |
| `userManagedIdentityResourceID` | The resource ID of the created User Managed Identity. | `userManagedIdentity.id` |
| `userManagedIdentityPrincipalId` | The principal ID of the created User Managed Identity. | `userManagedIdentity.properties.principalId` |
| `resourceGroupName` | The resource group name where the created User Managed Identity resides. | `resourceGroup().name` |

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "userManagedIdentityName": {
            "value": "managedIdtesting002"
        },
        "location": {
            "value": "westeurope"
        },
        "tags": {
            "value": {
                "Owner": "Sandro Christiaan",
                "Project": "Bicep conversion",
                "UserStory": "DCSAZ-1533",
                "ResourceType": "UserManagedIdentity",
                "ManagedBy": "Pipeline - Bicep"
            }
        }
    }
}
```