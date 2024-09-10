# childModules/publicIp/publicIp.bicep <!-- omit in toc -->

This Bicep module deploys a Public IP address.

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
| `Microsoft.Network/publicIPAddresses` | [2022-05-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2022-05-01/publicIPAddresses) |

## Parameters

### Required parameters

|  Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `name` | string |  | Specifies the resource name of the Public IP address.|
| `location` | string |  | Specifies the location where the Azure Resource will be created. |
| `skuName` | string | `[Basic, Standard, '']` | Specifies the SKU types of the Public Ip address. |
| `skuTier` | string | `[Regional, Global, '']` | Specifies the tier of the Public Ip address. |
| `publicIpAllocationMethod` | string | `[Dynamic, Static, '']` | Specifies the Public IP address allocation method. |
| `publicIpAddressVersion` | string | `[IPv4, IPv6, '']` | Specifies the Public IP address version. |
| `idleTimeoutInMinutes` | int |  | Specifies the idle timeout of the Public IP address. |
| `zones` | array |  | Specifies an array with the Availability zones for the Public IP address. |

### Optional parameters

| Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `tags` | object | `{}` |  | A mapping of tags to assign to the resource. |

### Parameter usage: `tags`

Tag names and tag values can be provided as needed. A tag can be left without a value.

<p>
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
</p>

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `publicIpAddressName` | string | The resource name of the deployed Public IP address. |
| `publicIpAddressResourceId` | string | The resource ID of the deployed Public IP address. |

## Deployment example

<p>
<details>

<summary>via Bicep module</summary>

```bicep
module examplePublicIpAddress '../../childModules/publicIp/publicIp.bicep' = {
  scope: exampleResourceGroup
  name: 'publicIpAddressFirewall-deployment'
  params: {
    name: 'aaa-cnty-t-eune-pip-fw-hub'
    location: 'northeurope'
    tags: {
      Environment: 'Test'
      Contact: 'sample.user@custcompany.net'
      CostCenter: '8844'
      ServiceName: 'BackendServiceXYZ'
      Role: 'BackendXYZ'
    }
    skuName: 'Standard'
    skuTier: 'Regional'
    zones: []
    idleTimeoutInMinutes: 4
    publicIpAddressVersion: 'IPv4'
    publicIpAllocationMethod: 'Dynamic'
  }
}
```

</details>
</p>