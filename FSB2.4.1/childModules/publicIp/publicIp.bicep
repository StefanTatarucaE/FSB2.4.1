/*
SUMMARY: Azure Public IP address Bicep module.
DESCRIPTION: Deploy a Public Ip Address in the HUB network.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.6
*/

//PARAMETERS
@description('The name that will be used for the Public Ip Address resource.')
param name string

@description('Name of the region where the deployment will be done')
param location string

@description('Tag/s to assign to this resource.')
param tags object

@description('Specifies the SKU types of the Public Ip Address')
@allowed([
  'Basic'
  'Standard'
  ''
])
param skuName string

@description('Array with the Availability zones for Public Ip Address')
param zones array

@description('Specifies the tier of the Public Ip Address')
@allowed([
  'Regional'
  'Global'
  ''
])
param skuTier string

@description('Specifies the Public IP Address allocation method.')
@allowed([
  'Dynamic'
  'Static'
  ''
])
param publicIpAllocationMethod string

@description('Specifies the idle timeout of the Public IP Address.')
param idleTimeoutInMinutes int

@description('Specifies the Public IP Address version.')
@allowed([
  'IPv4'
  'IPv6'
  ''
])
param publicIpAddressVersion string

// VARIABLES
// None

//RESOURCE Deployment
// Create Public Ip Address
resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  zones: zones
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
    idleTimeoutInMinutes: idleTimeoutInMinutes
    publicIPAddressVersion: publicIpAddressVersion
  }
}

//OUTPUTS
@description('The resource name of the deployed Public IP address.')
output publicIpAddressName string = publicIpAddress.name

@description('The resource id of the deployed Public IP address.')
output publicIpAddressResourceId string = publicIpAddress.id
