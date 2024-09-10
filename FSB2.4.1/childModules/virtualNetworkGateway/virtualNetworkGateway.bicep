/*
SUMMARY: Deployment of a virtual network gateway.
DESCRIPTION: Deploy a virtual network gateway to the desired Azure region.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.6
*/

// PARAMETERS
@description('Specify Virtual Network Gateway Name')
param name string

@description('Specify the location where Virtual Network Gateway is to be created')
param location string

@description('Speciy mapping of tags attached to Storage Account')
param tags object

@description('Specify type of virtual network gateway')
@allowed([
  'ExpressRoute'
  'Vpn'
  ''
])
param gatewayType string

@description('Specify Sku of the Gateway')
@allowed([
  'ErGw1AZ'
  'ErGw2AZ'
  'ErGw3AZ'
  'HighPerformance'
  'Standard'
  'UltraPerformance'
  'VpnGw1'
  'VpnGw1AZ'
  'VpnGw2'
  'VpnGw2AZ'
  'VpnGw3'
  'VpnGw3AZ'
  'VpnGw4'
  'VpnGw4AZ'
  'VpnGw5'
  'VpnGw5AZ'
  ''
])
param sku string

@description('Existing Virtual Network Name which should include the "GatewaySubnet" subnet')
param virtualNetworkName string

@description('Existing Public IP Name')
param publicIpName string

@description('The generation for this VirtualNetworkGateway. Must be None if gatewayType is not VPN')
@allowed([
  'Generation1'
  'Generation2'
  'None'
  ''
])
param vpnGatewayGeneration string

@description('Specify the type of virtual network gateway')
@allowed([
  'PolicyBased'
  'RouteBased'
  ''
])
param vpnType string

@description('Specifies the private IP address allocation method.')
param privateIPAllocationMethod string

// VARIABLES
// Default values which are hardcoded as per existing ELZ standard
var defaultIpConfig = {
  name: 'default'
}

// RESOURCES
// Refer existing GatewaySubnet
resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  name: '${virtualNetworkName}/GatewaySubnet'
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-08-01' existing = {
  name: publicIpName
}

resource virtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    gatewayType: gatewayType
    sku: {
      name: sku
      tier: sku
    }
    ipConfigurations: [
      {
        name: defaultIpConfig.name
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          subnet: {
            id: gatewaySubnet.id
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    vpnGatewayGeneration: (gatewayType != 'ExpressRoute') ? vpnGatewayGeneration : null
    vpnType: (gatewayType != 'ExpressRoute') ? vpnType : null
  }
}

// OUTPUT
@description('The resource ID of the Virtual Network Gateway.')
output virtualNetworkGatewayResourceId string = virtualNetworkGateway.id
