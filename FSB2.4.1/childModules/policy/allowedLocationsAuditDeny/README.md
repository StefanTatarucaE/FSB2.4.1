# policy/allowedLocations/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 2 Azure policy assignments.

It deploys the approved list of Azure regions where resources & resource groups can be deployed.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyAssignments@2021-06-01` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/allowedLocationsAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    azureRegionsAllowed: [
      'global'
      'westeurope'
      'northeurope'
    ]
    policyMetadata:'EvidenELZ'
    allowedLocationResourcesDefAssignmentName : 'allowedlocationresources.auditdeny.policy.def.assignment'
    allowedLocationResourcesDefAssignmentDisplayName : 'Allowed location resources auditdeny policy definition'
    allowedLocationRGDefAssignmentName : 'allowedlocationrsg.auditdeny.policy.def.assignment'
    allowedLocationRGDefAssignmentDisplayName : 'Allowed location resource groups auditdeny policy definition' 
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `azureRegionsAllowed` | `string[]` | true | The approved list of Azure regions where resources & resource groups can be deployed. Allowed values are "Global" and the regions in provided in Azue eg. "westeurope", "northeurope" etcs |
| `allowedLocationResourcesDefAssignmentName` | `string` | true | Specify policy asignment name for allowed location for resources policy|
| `allowedLocationResourcesDefAssignmentDisplayName` | `string` | true | Specify policy asignment display name for allowed location for resources policy |
| `allowedLocationRGDefAssignmentName` | `string` | true | Specify policy asignment name for allowed location for resource group policy |
| `allowedLocationRGDefAssignmentDisplayName` | `string` | true | Specify policy asignment display name for allowed location for resource group policy |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |


## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "azureRegionsAllowed": {
            "value": [
                "global",
                "northeurope",
                "westeurope"
            ]
        },
        "allowedLocationResourcesDefAssignmentName": {
            "value": "allowedlocationresources.auditdeny.policy.def.assignment"
        },
        "allowedLocationResourcesDefAssignmentDisplayName": {
            "value": "Allowed location resources auditdeny policy definition"
        },
        "allowedLocationRGDefAssignmentName": {
            "value": "allowedlocationrsg.auditdeny.policy.def.assignment"
        },
        "allowedLocationRGDefAssignmentDisplayName": {
            "value": "Allowed location resource groups auditdeny policy definition"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```