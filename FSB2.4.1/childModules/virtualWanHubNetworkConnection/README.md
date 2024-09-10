# Deployment of virtual hub network connection.

This bicep module deploys virtual network connections between spoke networks and virtual hub.

## Navigation <!-- omit in toc -->

- [Parameters](#parameters)

  - [Required parameters](#required-parameters)

- [Outputs](#outputs)

- [Deployment example](#deployment-example)


## Parameters

### Required parameters

|  Name | Type | Description |
| :-- | :-- | :-- |
| `allowHubToRemoteVnetTransit` | bool | VirtualHub to RemoteVnet transit to enabled or not. |
| `allowBranchToBranchTraffic` | bool | Allow RemoteVnet to use Virtual Hub gateways. |
| `enableInternetSecurity` | bool | Enable internet security. |
| `remoteVirtualNetworkId` | string | Specifies the remote  Virtual network Id. The value is  passed in the virtualwan parent module. |
| `hubToLndzVirtualNetworkConnectionName` | string | Specify the virtual network connection name. Note the format is important: vHubName/spokeVnetName |


## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `hubToLndzVirtualNetworkConnectionResourceId` | string | The resource ID of the Hub Virtual Network Connection.  |




## Deployment example

<p>
<details>
<summary>via Bicep module</summary>

```bicep
module hubToLndzVirtualNetworkConnection '../../childModules/virtualWanHubNetworkConnection/virtualWanHubNetworkConnection.bicep' = {
  name: 'hubToLndzVirtualNetworkConnection-deployment'
  scope: exampleRG
  params: {
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: false
    hubToLndzVirtualNetworkConnectionName: '123-cnty-t-ukso-vwan-hub/123-lnd1-t-ukso-vnet-hub'
    remoteVirtualNetworkId: '/subscriptions/[nnn]/resourceGroups/exampleRG/providers/Microsoft.Network/virtualNetworks/exampleVnet'
  } }

```

</details>
</p>