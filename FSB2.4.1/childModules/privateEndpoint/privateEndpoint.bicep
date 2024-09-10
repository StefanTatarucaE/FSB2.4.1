/*
SUMMARY: Deployment of a Private Endpoint.
DESCRIPTION: Deploy a Private Endpoint in the desired Azure region.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

//----TARGET SCOPE --> If you're deploying at the resource group level, you don't need to set the target scope.
// targetScope = 'subscription'

//PARAMETERS
@description('Required. Name of the privateEndpoint.')  
param privateEndpointName string

@description('Required. Location of the privateEndpoint.')
param location string

@description('Optional. Tag/s to assign to this resource.')
param tags object

@description('Required. Name of the private link connection. (EX: cu1-sub3-d-plk-dscartifactstorage)')
param privateLinkServiceName string 

@description('Required. Private link external id.')
param privateLinkServiceExternalId string

@description('Required. The ID(s) of the group(s) obtained from the remote resource that this private endpoint should connect to. (EX: blob / registry )')
param privateLinkServiceGroupIDs string

@description('Required. Virtual network external Id used for deployment of the private Endpoint.')
param virtualNetworkExternalId string

@description('Required. Subnet name from the virtual network.')
param subnetName string 

@description('Required. The resource name for private endpoint connection to DNS zone group.')
param privateEndpointDnsZoneGroupName string

@description('Required. Private Dns Zone configuration name')
param privateDnsZoneConfigsName string 

@description('Required. External id of the Private Dns Zone')
param privateDnsExternalId string 

@description('Required. A message passed to the owner of the remote resource with this connection request. Restricted to 140 chars.')
param requestMessage string 

@description('Required. Indicates whether the connection has been Approved/Rejected/Removed by the owner of the service.')
param connectionStateStatus string

@description('Optional. The reason for approval/rejection of the connection.')
param connectionStateDescription string 

@description('Optional. A message indicating if changes on the service provider require any updates on the consumer.')
param connectionStateActionsRequired string 
//VARIABLES

//Creating the Private endpoint using the name provided. 
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateLinkServiceName
        properties: {
          privateLinkServiceId: privateLinkServiceExternalId
          groupIds: [
            privateLinkServiceGroupIDs
          ]
          requestMessage: requestMessage
          privateLinkServiceConnectionState: {
            status: connectionStateStatus
            description: connectionStateDescription 
            actionsRequired: connectionStateActionsRequired  
          }
        }
      }
    ]
    subnet: {
      id: '${virtualNetworkExternalId}/subnet/${subnetName}'
    }
  
  }
}

// Link the Private DNS Zone Group with the private endpoint
resource privateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-11-01' = {
  parent: privateEndpoint
  name: privateEndpointDnsZoneGroupName 
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneConfigsName
        properties: {
          privateDnsZoneId: privateDnsExternalId // privateDnsZone.id from the Private DNS Zone child module
        }
      }
    ]
  }
}

//OUTPUTS 
output privateEndpointName string = privateEndpoint.name
output privateEndpointId string = privateEndpoint.id
