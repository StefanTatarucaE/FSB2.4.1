# childModules/privateDnsZoneVirtualNetworkLink/privateDnsZoneVirtualNetworkLink.bicep<!-- omit in toc -->

This Bicep module deploys a Virtual Network link from a Private DNS Zone to a Virtual Network.

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
| `Microsoft.Network/privateDnsZones/virtualNetworkLinks` | [2020-06-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2020-06-01/privateDnsZones/virtualNetworkLinks) |

## Parameters

### Required parameters

|  Name | Type | Description |
| :-- | :-- | :-- |
| `privateDnsZoneName` | string |  Specifies the name of the Private DNS Zone, for example, contoso.com. |
| `name` | `string` |  Specifies the name of the Virtual Network Link. |
| `registrationEnabled` | `bool` |  Specify private DNS Auto registration to be enabled or disabled. |
| `virtualNetworkId` | `string` | Specifies the ID Of the Virtual Network resource that needs to be linked. |

### Optional parameters

| Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `tags` | object | `{}` |  | A mapping of tags to assign to the resource. |

<p>

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
</p>

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `virtualNetworkLinkName` | string | The resource name of the deployed virtual network link. |
| `virtualNetworkLinkResourceId` | string | The resource ID of the deployed virtual network link. |

## Deployment example

<p>
<details>

<summary>via Bicep module</summary>

```bicep
module privateDnsZoneVirtualNetworkLinkHub '../../childModules/privateDnsZoneVirtualNetworkLink/privateDnsZoneVirtualNetworkLink.bicep' = {
  scope: exampleResourceGroup
  name: 'virtualNetworkLinkHub-deployment'
  params: {
    privateDnsZoneName: 'dcsprivatednszone.com'
    name: 'aaa-cnty-t-eune-vnet-hub-vnetlink'
    tags: {
      Environment: 'Test'
      Contact: 'sample.user@custcompany.net'
      CostCenter: '8844'
      ServiceName: 'BackendServiceXYZ'
      Role: 'BackendXYZ'
    }
    registrationEnabled: true
    virtualNetworkId: '/subscriptions/aaaabbbb-1234-3456-5678-xxxxyyyyzzzz/resourceGroups/<examplersg>/providers/Microsoft.Network/virtualNetworks/aaa-cnty-t-eune-vnet-hub'
  }
}
```

</details>
</p>