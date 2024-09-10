# childModules/virtualNetworkGateway/virtualNetworkGateway.bicep <!-- omit in toc -->

This Bicep module deploys a Virtual Network Gateway.

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
| `Microsoft.Network/virtualNetworkGateways` | [2021-08-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-08-01/virtualNetworkGateways) |

## Parameters

### Required parameters

|  Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `name` | string |  | Specifies the resource name of the Virtual Network Gateway.|
| `location` | string |  | Specifies the location where the Azure Resource will be created. |
| `gatewayType` | string | `[LocalGateway, Vpn, ExpressRoute]` | Specifies the gateway type of the Virtual Network Gateway. |
| `sku` | string | `[ErGw1AZ, ErGw2AZ, ErGw3AZ, Standard, HighPerformance, UltraPerformance, VpnGw1, VpnGw2, VpnGw3, VpnGw4, VpnGw5, VpnGw1AZ, VpnGw2AZ, VpnGw3AZ, VpnGw4AZ, VpnGw5AZ]` | Specifies the sku of the Virtual Network Gateway. |
| `virtualNetworkName` | string | `[Dynamic, Static, '']` | Specifies the existing Virtual Network Name where the "GatewaySubnet" subnet is created. |
| `publicIpName` | string | `[IPv4, IPv6, '']` | Specifies the existing Public IP address to be configured for the Virtual Network Gateway. |
| `vpnGatewayGeneration` | string | `[Generation1, Generation2, None]` | The generation for this Virtual Network Gateway. Must be None if gatewayType is not VPN. |
| `vpnType` | string | `[PolicyBased, RouteBased]` | Specifies the vpn type of the Virtual Network Gateway. |
| `privateIPAllocationMethod` | string | `[Dynamic, Static]` | Specifies the private IP address allocation method. |

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
| `virtualNetworkGatewayResourceId` | string | The resource ID of the deployed Virtual Network Gateway. |

## Deployment example

<p>
<details>

<summary>via Bicep module</summary>

```bicep
module virtualNetworkGateway '../../childModules/virtualNetworkGateway/virtualNetworkGateway.bicep' = {
  scope: exampleResourceGroup
  name: 'virtualNetworkGateway-deployment'
  params: {
    name: 'aaa-cnty-t-eune-vpn-hub'
    location: 'northeurope'
    tags: {
      Environment: 'Test'
      Contact: 'sample.user@custcompany.net'
      CostCenter: '8844'
      ServiceName: 'BackendServiceXYZ'
      Role: 'BackendXYZ'
    }
    sku: 'VpnGw1'
    gatewayType: 'Vpn'
    privateIPAllocationMethod: 'Static'
    publicIpName: 'aaa-cnty-t-eune-pip-gw-hub'
    virtualNetworkName: 'aaa-cnty-t-eune-vnet-hub'
    vpnGatewayGeneration: 'Generation1'
    vpnType: 'RouteBased'
  }
}
```

</details>
</p>