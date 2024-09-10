/*
SUMMARY: Virtual Network module.
DESCRIPTION: Child Module for deployment of the virtual network.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.6
*/

// PARAMETERS
@description('Specifies the Route Table Name')
param name string

@description('Specifies the location where the Azure Resource will be created')
param location string

@description('A mapping of tags to assign to the resource.')
param tags object = {}

@description('Enable or disable BGP route propagation.')
param disableBgpRoutePropagation bool

@description('Collection of routes contained within a route table.')
param routes array

// VARIABLES
// None

// RESOURCE DEPLOYMENTS
resource routeTable 'Microsoft.Network/routeTables@2021-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: routes
  }
}

// OUTPUTS
@description('The resource ID of the Route Table')
output routeTableResourceId string = routeTable.id
