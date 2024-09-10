# policy/allowedVmSize/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy assignment.

It deploys the approved list  of allowed Virtual Machine SKUs that can be deployed in this subscription.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyAssignments@2021-06-01` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/allowedVmSkuAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    virtualMachineSkusAllowed: [
      'prevent_deploy'
    ]
    policyMetadata: 'EvidenELZ'
    allowedVmSkuDefAssignmentName : 'allowedvmsku.auditdeny.policy.def.assignment' 
    allowedVmSkuDefAssignmentDisplayName : 'Allowed vm skus auditdeny policy definition'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `virtualMachineSkusAllowed` | `string[]` | true | The approved list of Virtual Machine SKUs. For values to be added, please check this [link](https://docs.microsoft.com/azure/virtual-machines/sizes).|
| `allowedVmSkuDefAssignmentName` | `string` | true | Specify policy asignment name for allowed VM SKU policy  |
| `allowedVmSkuDefAssignmentDisplayName` | `string` | true | Specify policy asignment display name for allowed VM SKU policy |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |


## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "virtualMachineSkusAllowed": {
            "value": [
                "prevent_deploy"
            ]
        },
        "allowedVmSkuDefAssignmentName": {
            "value": "allowedvmsku.auditdeny.policy.def.assignment"
        },
        "allowedVmSkuDefAssignmentDisplayName": {
            "value": "Allowed vm skus auditdeny policy definition"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```