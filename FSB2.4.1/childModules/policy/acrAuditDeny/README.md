# policy/paasAcrAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy set definition & 1 policy assignment.

This policy configures governance and security policies for the Azure Container Registry.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/acrAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    acrSettings:{
        adminAccountDisabled: 'Audit',
        anonymousPullDisabled: 'Audit',
        cmkEncryptionEnabled: 'Audit',
        exportPolicy: 'Audit',
        networkRulesExist: 'Audit',
        privateEndpointEnabled: 'Audit',
        publicNetworkAccess: 'Audit',
        skuSupportsPrivateEndpoints: 'Audit',
        tokenDisabled: 'Audit'
        }
    acrAuditDenySetName: 'acr.auditdeny.policy.set'
    acrAuditDenySetDisplayName: 'Acr auditdeny policy set'
    acrAuditDenySetAssignmentName:'acr.auditdeny.policy.set.assignment'
    acrAuditDenySetAssignmentDisplayName: 'Acr auditdeny policy set assignment'
    policyMetadata: 'EvidenELZ'
  } 
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `acrSettings` | `object` | true | Object which sets the values of the policy set definition parameters. The specific parameters & what they are for, are described in the `policySetDefinition` resource block. Additional Details [here](#array---acrsettings).|
| `acrAuditDenySetName` | `string` | true | Policy set name for acr auditdeny. |
| `acrAuditDenySetDisplayName` | `string` | true | Policy set display name for acr auditdeny. |
| `acrAuditDenySetAssignmentName` | `string` | true | Policy set assignment name for acr auditdeny. |
| `acrAuditDenySetAssignmentDisplayName` | `string` | true | Policy set assignment display name for auditdeny. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

### Array - acrSettings
| Name | Type | Description |
| --- | --- | --- |
| `adminAccountDisabled` | `string` | Container registries should have local authentication methods disabled. Allowed Values: Audit, Deny, Disabled. |
| `anonymousPullDisabled` | `string` | Container registries should have anonymous authentication disabled. Allowed Values: Audit, Deny, Disabled. |
| `cmkEncryptionEnabled` | `string` | Container registries should be encrypted with a customer-managed key. Allowed Values: Audit, Deny, Disabled.  |
| `exportPolicy` | `string` | Container registries should have exports disabled. Allowed Values: Audit, Deny, Disabled.  |
| `networkRulesExist` | `string` | Container registries should have network rules configured. Allowed Values: Audit, Deny, Disabled.  |
| `privateEndpointEnabled` | `string` | Container registries should use private link. Allowed Values: Audit, Disabled.  |
| `publicNetworkAccess` | `string` | Public network access should be disabled for Container registries. Allowed Values: Audit, Deny, Disabled.  |
| `skuSupportsPrivateEndpoints` | `string` | Container registries should have SKUs that support Private Links. Allowed Values: Audit, Deny, Disabled.  |
| `tokenDisabled` | `string` | Container registries should have repository scoped access token disabled. Allowed Values: Audit, Deny, Disabled.  |


## Module Outputs

None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "acrSettings": {
            "value": {
                "adminAccountDisabled": "Audit",
                "anonymousPullDisabled": "Audit",
                "cmkEncryptionEnabled": "Audit",
                "exportPolicy": "Audit",
                "networkRulesExist": "Audit",
                "privateEndpointEnabled": "Audit",
                "publicNetworkAccess": "Audit",
                "skuSupportsPrivateEndpoints": "Audit",
                "tokenDisabled": "Audit"
            }
        },
        "acrAuditDenySetName":{
            "value": "acr.auditdeny.policy.set"
        },
        "acrAuditDenySetDisplayName":{
            "value": "Acr auditdeny policy set"
        },
        "acrAuditDenySetAssignmentName":{
            "value": "acr.auditdeny.policy.set.assignment"
        },
        "acrAuditDenySetAssignmentDisplayName":{
            "value": "Acr auditdeny policy set assignment"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```

