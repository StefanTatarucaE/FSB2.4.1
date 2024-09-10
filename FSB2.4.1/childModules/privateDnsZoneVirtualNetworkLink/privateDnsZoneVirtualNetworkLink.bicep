/*
SUMMARY: Deployment of a Private DNS Zone.
DESCRIPTION: Deploy a Private DNS Zone in the desired Azure region.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

//PARAMETERS
@description('Specifies the name of the zone, for example, contoso.com.')
param privateDnsZoneName string

@description('Specifies the name of the Virtual Network Link')
param name string

@description('Switch to Enable private DNS Auto registration.')
param registrationEnabled bool

@description('Specifies the ID Of the Virtual Network resource that needs to be linked.')
param virtualNetworkId string

@description('Tags to assign to this resource.')
param tags object

// VARIABLES
// None

// RESOURCES
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
}

// Link a Virtual Network to this Private DNS Zone. You can link multiple virtual networks to a single DNS zone.
resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: name
  parent: privateDnsZone
  location: 'global' //This is always global.
  tags: tags
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

// OUTPUTS
@description('The resource name of the deployed virtual network link.')
output virtualNetworkLinkName string = virtualNetworkLink.name

@description('The resource ID of the deployed virtual network link.')
output virtualNetworkLinkResourceId string = virtualNetworkLink.id
