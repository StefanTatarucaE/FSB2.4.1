/*
SUMMARY: Deployment of virtual hub network connection.
DESCRIPTION: Deploy virtual network connections between spoke networks and virtual hub.
AUTHOR/S: alexandru-daniel.stan@atos.net
VERSION: 0.0.1
*/

// PARAMETERS

@description('VirtualHub to RemoteVnet transit to enabled or not.')
param allowHubToRemoteVnetTransit bool

@description('Allow RemoteVnet to use Virtual Hub gateways.')
param allowRemoteVnetToUseHubVnetGateways bool

@description('Enable internet security.')
param enableInternetSecurity bool

@description('Specifies the remote  Virtual network Id. The value is  passed in the virtualwan parent module.')
param remoteVirtualNetworkId string

@description('Specify the virtual network connection name. Note the format is important: vHubName/spokeVnetName')
param hubToLndzVirtualNetworkConnectionName string

// RESOURCES

resource hubToLndzVirtualNetworkConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2023-04-01' = {
  name: hubToLndzVirtualNetworkConnectionName
  properties: {
    allowHubToRemoteVnetTransit: allowHubToRemoteVnetTransit
    allowRemoteVnetToUseHubVnetGateways: allowRemoteVnetToUseHubVnetGateways
    enableInternetSecurity: enableInternetSecurity
    remoteVirtualNetwork: {
      id: remoteVirtualNetworkId
    }
  }
}

// OUTPUTS
@description('The resource ID of the Hub Virtual Network Connection.')
output hubToLndzVirtualNetworkConnectionResourceId string = hubToLndzVirtualNetworkConnection.id
