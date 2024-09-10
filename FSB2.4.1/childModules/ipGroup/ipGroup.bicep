/*
SUMMARY: Deployment of an IP Group.
DESCRIPTION: Deploy an IP Group to the desired Azure region.
AUTHOR/S: frederic.trapet@eviden.com
VERSION: 0.0.6
*/

// PARAMETERS
@description('Specifies the name of the IP Group.')
param name string

@description('Specifies the location where the Azure Resource will be created.')
param location string

@description('Specifies a mapping of tags to assign to the resource.')
param tags object = {}

@description('Specifies the IP address in CIDR notation which should be attached to the IP group.')
param ipAddressesArray array

// VARIABLES
// None

// RESOURCE DEPLOYMENTS
// IP GROUPS
resource ipGroup 'Microsoft.Network/ipGroups@2021-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    ipAddresses: ipAddressesArray
  }
}

// OUTPUTS
@description('The name of the IP Group.')
output ipGroupName string = ipGroup.name

@description('The resource ID of the IP Group.')
output ipGroupResourceId string = ipGroup.id
