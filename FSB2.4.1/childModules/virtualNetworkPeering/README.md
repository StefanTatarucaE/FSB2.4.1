# childModules/virtualNetworkNew/virtualNetworkPeering/virtualNetworkPeering.bicep <!-- omit in toc -->

This Bicep module deploys an Azure Virtual Network Peering between two existing virtual networks.

## Navigation <!-- omit in toc -->

- [Resource types](#resource-types)
- [Parameters](#parameters)
  - [Required parameters](#required-parameters)
- [Outputs](#outputs)
- [Deployment example](#deployment-example)
  
## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Network/virtualNetworks/virtualNetworkPeerings` | [2021-08-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-08-01/virtualNetworks/virtualNetworkPeerings) |

## Parameters

### Required parameters

|  Name | Type | Description |
| :-- | :-- | :-- |
| `peeringName` | `string` | "Specify the name of the Virtual network peering. It needs to follow the segment length virtualNetworkName/peeringName. |
| `remoteVirtualNetworkName` | `string` | Specifies the name of the existing remote virtual network. |
| `remoteVirtualNetworkResourceGroupName` | `string`| Specifies the name of the the existing remote virtual network Resource Group. |
| `remotePeeringSubscriptionId` | `string` | Subscription ID of the remote virtual network. |
| `allowVirtualNetworkAccess` | `bool` | Specifies whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space. Set this option to true if you wish to allow communication between the two virtual networks. |
| `allowForwardedTraffic` | `bool` | Specify whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network. Set this option to true if you want to allow spoke-to-spoke connectivity via the NVA in the Hub. |
| `allowGatewayTransit` | `bool` | This allows the peer virtual network to use your virtual network gateway for transit |
| `useRemoteGateways` | `bool` | Specifies if remote gateways can be used on this virtual network. If the flag is set to true, and allowGatewayTransit on remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway. |

## Outputs

| Name | Type | Description |
| :-- | :-- | :-- |
| `virtualNetworkPeeringName` | `string` | The resource name of the deployed virtual network peering. |
| `virtualNetworkPeeringResourceId` | `string` |The resource id of the deployed virtual network peering.  |

## Deployment example

<p>
<details>

<summary>via Bicep module</summary>

```bicep
module virtualNetworkPeering './childModules/virtualNetworkNew/virtualNetworkPeering/virtualNetworkPeering.bicep' = {
  name: '${uniqueString(deployment().name, location)}-peer-deployment'
  params: {
    peeringName: 'aaa-lnd2-t-eune-vnet-spoke/peering-to-aaa-cnty-t-eune-vnet-hub'
    remoteVirtualNetworkName: 'aaa-cnty-d-eune-vnet-hub'
    remoteVirtualNetworkResourceGroup: 'aaa-cnty-x-rsg-hub-network'
    remotePeeringSubscriptionId: 'aaaabbbb-ccdd-eeff-gghh-aaaxyyyyzzzz'
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}
```

</details>
</p>