# policy/securityCenter/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy definitions, 1 policy assignment & 1 role assignment.

This policy will set the pricing tier for Azure Security Center for several resource types.
The resource types are:
  - api
  - virtualMachinesTier
  - appServicesTier
  - sqlServersTier
  - sqlServerVirtualMachinesTier
  - storageAccountsTier
  - opensourcerelationaldatabases
  - arm
  - dns
  - containers
  - CosmosDbs
  - cloudPosture
  - keyVaultsTier

  The preview, deprecated and currently unsupported pricing plans are filtered out from this policy.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyDefinitions`  | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/roleAssignments` (via roleAssignment module) | [2020-10-01-preview](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2020-10-01-preview/roleassignments) |

## Module Example Use
```bicep
module examplePolicy '../childModules/policy/ascPricingChange/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    pricingTier: {
        api: 'Free'
        virtualMachinesTier: 'Free'
        appServicesTier: 'Free'
        sqlServersTier: 'Free'
        sqlServerVirtualMachinesTier: 'Free'
        storageAccountsTier: 'Free'
        opensourcerelationaldatabases: 'Free'
        arm: 'Free'
        dns: 'Free'
        containers: 'Free'
        cloudPosture: 'Free',
        cloudPostureExtensions:{
          sensitiveDataDiscovery: 'True',
          containerRegistriesVulnerabilityAssessments: 'True',
          agentlessDiscoveryForKubernetes: 'True'
        },
        CosmosDbs: 'Free'
        keyVaultsTier: 'Standard'
    },
    virtualMachinesSubPlan: 'P2'
    ascPricingChangeDefName: 'asc.pricing.change.policy.def'
    ascPricingChangeDefDisplayName: 'ASC pricing change policy definition'
    ascPricingChangeDefAssignmentName: 'asc.pricing.change.policy.def.assignment'
    ascPricingChangeDefAssignmentDisplayName: 'ASC pricing change policy definition assignment'
    policyMetadata : 'EvidenELZ'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `pricingTier`| `object` | true | Object which sets the pricing tier for Azure Security Center for the related resource types. Additional Details [here](#object---pricingtier) .|
| `virtualMachinesSubPlan` | `string` | true | Parameter to set sub plan for virtual machine defender plan. 
| `deployLocation` | `string` | true | Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment |
| `ascPricingChangeDefName` | `string` | true | definition name for ASC pricing change policy. |
| `ascPricingChangeDefDisplayName` | `string` | true | definition displayname for ASC pricing change policy. |
| `ascPricingChangeDefAssignmentName` | `string` | true | definition assignment name for ASC pricing change policy. |
| `ascPricingChangeDefAssignmentDisplayName` | `string` | true | definition assignment displayname for ASC pricing change policy. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

### Object - pricingTier
| Name | Type | Description |
| --- | --- | --- |
| `api` | `string` | Specifiy whether you want to enable Standard tier for API resource type. |
| `virtualMachinesTier` | `string` | Specifiy whether you want to enable Standard tier for Virtual Machine resource type. |
| `appServicesTier` | `string` | Specify whether you want to enable Standard tier for Azure App Service resource type. |
| `sqlServersTier` | `string` | Specify whether you want to enable Standard tier for PaaS SQL Service resource type. |
| `sqlServerVirtualMachinesTier` | `string` | Specify whether you want to enable Standard tier for SQL Server on VM resource type. |
| `storageAccountsTier` | `string` | Specify whether you want to enable Standard tier for Storage Account resource type. |
| `opensourcerelationaldatabases` | `string` | Specify whether you want to enable Standard tier for opensourcerelationaldatabases. |
| `arm` | `string` | Specify whether you want to enable Standard tier for arm. |
| `dns` | `string` | Specify whether you want to enable Standard tier for DNS. |
| `containers` | `string` | Specify whether you want to enable Standard tier for containers. |
| `CosmosDbs` | `string` | Specify whether you want to enable Standard tier for CosmosDbs Service resource type. |
| `cloudPosture` | `string` | Specify whether you want to enable Standard tier Cloud Security Posture Management. |
| `sensitiveDataDiscovery` | `string` | Enable sensitive Data Discovery within CSPM Plan. |
| `containerRegistriesVulnerabilityAssessments` | `string` | Enable Container Registries Vulnerability Assessments within CSPM Plan. |
| `agentlessDiscoveryForKubernetes` | `string` | Enable Agentless Discovery For Kubernetes within CSPM Plan. |
| `keyVaultsTier` | `string` | Specify whether you want to enable Standard tier for Key Vault resource type. |

## Module Outputs

| Name | Description | Value |
| --- | --- | --- |
| `roleAssignmentDeployName` | Object containing the Role Assigment Deployment Name. | `ascPolicyRoleAssignment.name` |


## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "pricingTier": {
            "value": {
                "api": "Free",
                "virtualMachinesTier": "Free",
                "appServicesTier": "Free",
                "sqlServersTier": "Free",
                "sqlServerVirtualMachinesTier": "Free",
                "storageAccountsTier": "Free",
                "opensourcerelationaldatabases": "Free",
                "arm": "Free",
                "dns": "Free",
                "containers": "Free",
                "CosmosDbs": "Free",
                "cloudPosture":"Free",
                "cloudPostureExtensions":{
                     "sensitiveDataDiscovery": "True",
                     "containerRegistriesVulnerabilityAssessments": "True",
                     "agentlessDiscoveryForKubernetes": "True"
                },
                "keyVaultsTier": "Standard"
            }
        },
        "virtualMachinesSubPlan": {
            "value": "P2"
        },
        "ascPricingChangeDefName": {
            "value": "asc.pricing.change.policy.def"
        },
        "ascPricingChangeDefDisplayName": {
            "value": "ASC pricing change policy definition"
        },
        "ascPricingChangeDefAssignmentName": {
            "value": "asc.pricing.change.policy.def.assignment"
        },
        "ascPricingChangeDefAssignmentDisplayName": {
            "value": "ASC pricing change policy definition assignment"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```