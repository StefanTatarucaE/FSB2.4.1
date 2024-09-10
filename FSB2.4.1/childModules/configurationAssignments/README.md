# configurationAssignments/configurationAssignments.bicep
Bicep module to create a configuration assignment as extension to a maintenance configuration.

## Description
Configuration Assignments (formerly known as Patch Schedules) are deployed in a subscription and are linked to an existing maintenance configuration. A configuration assignment can be used to set a dynamic scope as an extension resource for the resourcetypes which allow a dynamic scope.

## Module example use
```hcl
module configurationAssignments '../../childModules/configurationAssignments/configurationAssignments.bicep' = {
  name: 'exampleConfigurationAssignment-deployment'
  params: {
    configurationAssignmentsLocations: []
    configurationAssignmentsOsTypes: []
    configurationAssignmentsResourceGroups: []
    configurationAssignmentsResourceTypes: ['Microsoft.Compute/virtualMachines']
    configurationAssignmentsTagFilter: 'All'
    configurationAssignmentsTagObject: {
        "EvidenManaged": [
          "True"
        ],
        "EvidenPatching": [
          "linux-dev5"
        ]
      }
    subscriptionId: '/subscriptions/3bed9a6a-d129-4xxx-bbe5-6df00467a2e1'
    maintenanceConfigurationId: '/subscriptions/954bc363-xxx-42af-a14d-fc3f210d94a0/resourceGroups/dv3-mgmt-d-rsg-updatemanager/providers/Microsoft.Maintenance/maintenanceConfigurations/windows-dev'
    configurationAssignmentName: 'exampleName'
    }
  }
```
## Module Arguments

| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `configurationAssignmentsLocations` | `string[]` | List of locations to scope the query to. |
| `configurationAssignmentsOsTypes` | `string[]` | List of allowed operating systems. |
| `configurationAssignmentsResourceGroups` | `string[]` | List of allowed resource groups. |
| `configurationAssignmentsResourceTypes` | `string[]` | List of allowed resources. |
| `configurationAssignmentsTagFilter` | `string` | Filter VMs by Any or All specified tags. |
| `configurationAssignmentsTagObject` | `object` | Dictionary of tags with its list of values. |
| `subscriptionId` | `string` | The unique resourceId/subscriptionId of the resource on which the configuration assignmnent needs to be deployed. |
| `maintenanceConfigurationId` | `string` | The maintenance configuration Id |
| `configurationAssignmentName` | `string` | the name of the configuration assignment |

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "configurationAssignmentsLocations": {
      "value": []
    },
    "configurationAssignmentsOsTypes": {
      "value": []
    },
    "configurationAssignmentsResourceGroups": {
      "value": []
    },
    "configurationAssignmentsResourceTypes": {
      "value": ["Microsoft.Compute/virtualMachines"]
    },
    "configurationAssignmentsTagFilter": {
      "value": "All"
    },
    "configurationAssignmentsTagObject": {
      "value": {
        "EvidenManaged": [
          "True"
        ],
        "EvidenPatching": [
          "linux-dev5"
        ]
      }
    },
    "lndzSubscriptionId": {
      "value": "/subscriptions/3bed9a6a-xxxx-47e1-bbe5-6df00467a2e1"
    },
    "maintenanceConfigurationId": {
      "value": "/subscriptions/954bc363-xxxx-42af-a14d-fc3f210d94a0/resourceGroups/dv3-mgmt-d-rsg-updatemanager/providers/Microsoft.Maintenance/maintenanceConfigurations/windows-dev"
    },
    "configurationAssignmentName": {
      "value": "test-maintenance-configuration"
    }
  }
}

```



