# childModules/ddosProtectionPlan/ddosProtectionPlan.bicep <!-- omit in toc -->

This Bicep module deploys a DDoS Protection Plan.

## Navigation <!-- omit in toc -->

- [Resource types](#resource-types)
- [Parameters](#parameters)
  - [Required parameters](#required-parameters)
  - [Optional parameters](#optional-parameters)
  - [Parameter usage: `tags`](#parameter-usage-tags)
- [Outputs](#outputs)
- [Deployment example](#deployment-example)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Network/ddosProtectionPlans` | [2021-02-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2021-02-01/ddosprotectionplans) |

## Parameters

### Required parameters

|  Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string |  The resource name of the DDoS Protection Plan.|
| `location` | string |  Specify the location where the DDoS Protection Plan is to be created. |

### Optional parameters

| Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `tags` | object | `{}` |  | A mapping of tags to assign to the resource. |

### Parameter usage: `tags`

Tag names and tag values can be provided as needed. A tag can be left without a value.

<details>

<summary>Parameter JSON format</summary>

```json
"tags": {
    "value": {
        "Environment": "Test",
        "Contact": "sample.user@custcompany.net",
        "CostCenter": "8844",
        "ServiceName": "BackendServiceXYZ",
        "Role": "BackendXYZ"
    }
}
```

</details>

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `ddosProtectionPlanResourceId` | string | The resource ID of the network security group. |

## Deployment example

<p>
<details>

<summary>via Bicep module</summary>

```bicep
module ddosProtectionPlan './childModules/ddosProtectionPlan/ddosProtectionPlan.bicep' = {
  name: '${uniqueString(deployment().name, location)}-ddosPlan-deployment'
  params: {
    name: 'xxx-cnty-x-eune-ddos-plan'
    location: 'northeurope'
    tags: {
      Environment: 'Test'
      Contact: 'sample.user@custcompany.net'
      CostCenter: '8844'
      ServiceName: 'BackendServiceXYZ'
      Role: 'BackendXYZ'
    }
  }
}
```

</details>
</p>
