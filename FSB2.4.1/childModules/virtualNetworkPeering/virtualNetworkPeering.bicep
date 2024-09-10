/*
SUMMARY: Azure vNet Peering Bicep module.
DESCRIPTION: Deploy a Microsoft.Network/virtualNetworks/virtualNetworkPeerings resource.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.6
*/

//PARAMETERS
@description('Specify the name of the Virtual network peering. It needs to follow the segment length virtualNetworkName/peeringName')
param peeringName string

@description('Specify the name of the existing remote vNet')
param remoteVirtualNetworkName string

@description('Specify the name of the the existing remote vNet Resource Group')
param remoteVirtualNetworkResourceGroupName string

@description('Specify the Subscription ID of where the remote Virtual Network resides')
param remotePeeringSubscriptionId string

@description('Specify whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space. True/False')
param allowVirtualNetworkAccess bool

@description('Specify whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network. True/False')
param allowForwardedTraffic bool

@description('Specify if gateway links can be used in remote virtual networking to link to this virtual network. True/False')
param allowGatewayTransit bool

@description('Specify if remote gateways can be used on this virtual network. If the flag is set to true, and allowGatewayTransit on remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway. True/False')
param useRemoteGateways bool

//RESOURCE Deployment
resource virtualNetworkPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: peeringName
  properties: {
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: resourceId(remotePeeringSubscriptionId, remoteVirtualNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', remoteVirtualNetworkName)
    }
  }
}

//OUTPUTS
@description('The resource name of the deployed virtual network peering.')
output virtualNetworkPeeringName string = virtualNetworkPeering.name

@description('The resource ID of the deployed virtual network peering.')
output virtualNetworkPeeringResourceId string = virtualNetworkPeering.id
