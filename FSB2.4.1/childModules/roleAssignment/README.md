# roleAssignment/roleAssignment.bicep
Bicep module to create a Role Assignments for an existing User Managed Identity.

## Module Features
Module can deploy Role Assignments (1 or more) to existing User Managed Identity resources.
There are two bicep child modules that target different scopes (subscription and resource group). The parameters and everything else remains the same.

**At Subscription level**

Use the roleAssignment.bicep

**At resource group level**

Use the roleAssignmentResourceGroup.bicep

## Module Example Use for role assignment at subscription level
```bicep
module exampleManagedIdentityRoleAssignment '../childModules/roleAssignment/roleAssignment.bicep' = {
  name: 'deployExampleRoleAssignments'
  params: {
    userManagedIdentityId: naming.customerUserManagedIdentity.Id
    roleDefinitionIdOrNames: roleDefinitionIdOrNames
  }
  dependsOn:[
    exampleManagedIdentity
  ]
}
```

## Module Example Use for role assignment at resource group level
```bicep
module exampleManagedIdentityRoleAssignment '../childModules/roleAssignment/roleAssignmentResourceGroup.bicep' = {
  scope: automationResourceGroup
  name: 'deployExampleRoleAssignments'
  params: {
    userManagedIdentityId: naming.customerUserManagedIdentity.Id
    roleDefinitionIdOrNames: roleDefinitionIdOrNames
  }
  dependsOn:[
    exampleManagedIdentity
  ]
}
```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `userManagedIdentityId` | `string` | true | The resource ID of the resource to apply the role assignment to. |
| `roleDefinitionIdOrNames` | `string` | true | Specifies the names of the role(s) to assign. If it cannot be found you can specify the role definition ID instead. |

## Module outputs
None

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "managedIdentityId": {
            "value": "818807b4-bb80-4024-8dd7-122ca23cf41a"
        },
        "roleDefinitionIdOrNames": {
            "value": [
                "Reader"
            ]
        }
    }
}
```