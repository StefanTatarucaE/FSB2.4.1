/*
SUMMARY: Deployment of Azure Bastion Host.
DESCRIPTION: Deploys bastion host in desired Azure region.
AUTHOR/S: klaasjan.dejager@eviden.com
VERSION: 0.1
*/

// PARAMETERS
@description('Specify Bastion Host Name')
@maxLength(80)
param bastionHostName string

@description('Specify the location where Bastion Host is to be created')
param location string

@description('Speciy mapping of tags attached to bastion host')
param tags object

@description('Existing Virtual Network ID which should include the "AzureBastionSubnet" subnet')
param virtualNetworkId string

@description('Existing Public IP ID to associate with Bastion Host')
param publicIpName string

@description('Specify Sku for bastion host')
@allowed([
  'Basic'
  'Standard'
])
param sku string

@description('Enable/Disable Copy/Paste feature of the Bastion Host resource.')
param disableCopyPaste bool

@description('Enable/Disable File Copy feature of the Bastion Host resource.')
param enableFileCopy bool

@description('Enable/Disable IP Connect feature of the Bastion Host resource.')
param enableIpConnect bool

@description('Enable/Disable Shareable Link of the Bastion Host resource.')
param enableShareableLink bool

@description('Enable/Disable Tunneling feature of the Bastion Host resource.')
param enableTunneling bool

@description('Specify the instance count for the Bastion Host resource. Instance scaling is only supported when sku is Standard. Bastion can support 2-50 VM instances.')
param scaleUnits int

// VARIABLES

// Create Bastion Host Resources

resource bastionHostPublicIp 'Microsoft.Network/publicIPAddresses@2021-08-01' existing = {
  name: publicIpName
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: bastionHostName
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: (sku != 'Standard')?{
    ipConfigurations: [
      {
        name: '${bastionHostName}-ipconfig'
        properties: {
          subnet: {
            id: '${virtualNetworkId}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: bastionHostPublicIp.id
          }
        }
      }
    ]
  }:{
    disableCopyPaste: disableCopyPaste
    enableFileCopy: enableFileCopy
    enableIpConnect: enableIpConnect
    enableShareableLink: enableShareableLink
    enableTunneling: enableTunneling
    scaleUnits: scaleUnits
    ipConfigurations: [
      {
        name: '${bastionHostName}-ipconfig'
        properties: {
          subnet: {
            id: '${virtualNetworkId}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: bastionHostPublicIp.id
          }
        }
      }
    ]
  }
}

// OUTPUT
output bastionHostId string = bastionHost.id
