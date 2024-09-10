# childModules/ipGroup/ipGroup.bicep <!-- omit in toc -->

This Bicep module deploys an IP Group.

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
| `Microsoft.Network/ipGroups` | [2021-05-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-05-01/ipGroups) |

## Parameters

### Required parameters

|  Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string |  Specifies the resource name of the IP Group.|
| `location` | string |  Specifies the location where the Azure Resource will be created. |
| `ipAddresses` | string |  Specifies the IP address in CIDR notation which should be attached to the IP group. |

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
| `ipGroupName` | string | The name of the IP Group. |
| `ipGroupResourceId` | string | The resource ID of the IP Group. |

## Deployment example

<p>
<details>

<summary>via Bicep module</summary>

```bicep
module ipGroups '../../childModules/ipGroup/ipGroup.bicep' = {
  scope: exampleResourceGroup
  name: 'ipGroups-deployment'
  params: {
    name: 'aaa-lnd1-d-eune-snet-spoke-ipgroup'
    location: 'northeuope'
    tags: {
      Environment: 'Test'
      Contact: 'sample.user@custcompany.net'
      CostCenter: '8844'
      ServiceName: 'BackendServiceXYZ'
      Role: 'BackendXYZ'
    }
    ipAddresses: '10.10.1.0/24'
  }
}
```

</details>
</p>