# privateEndpoint/privateEndpoint.bicep
Bicep module to create an Azure Private Endpoint.

## Description
A private endpoint is a network interface that uses a private IP address from your virtual network. 
This network interface connects you privately and securely to a service that's powered by Azure Private Link. 
By enabling a private endpoint, you're bringing the service into your virtual network.

This module will create: 
- Private Endpoint
- Link to a Private DNS Zone

## ModuleExample 
```bicep
module devPrivateEndpoint '../../childModules/privateEndpoint/privateEndpoint.bicep' = {
  scope: resourceGroup('cux-subx-d-rsg-functionapp')
  name: 'devPrivateEndpointModule'
  params: {
    privateEndpointName: privateEndpointName
    tags: tags
    location: location
    privateLinkServiceName: privateLinkServiceName
    privateLinkServiceExternalId: privateLinkServiceExternalId
    privateLinkServiceGroupIDs: privateLinkServiceGroupIDs
    requestMessage: requestMessage
    connectionStateStatus: connectionStateStatus
    connectionStateDescription: connectionStateDescription
    connectionActionsRequired: connectionStateActionsRequired
    virtualNetworkExternalId: virtualNetworkExternalId
    subnetName: subnetName
    privateEndpointDnsZoneGroupName: privateEndpointDnsZoneGroupName
    privateDnsZoneConfigsName: privateDnsZoneConfigsName
    privateDnsExternalId: privateDnsExternalId 
}
```
 Note: The parameter 'privateDnsExternalId' can be link with the private dns zone child module or it can be used by providing an existing private dns zone external id that has already created.



## Module Arguments 

| Name | Type | Required | Description |
| --- | --- | --- | --- |
|`privateEndpointName` | `string` | true | Name of the private endpoint. |
|`location` | `string` | true | Location of the private Endpoint. |
|`tags` | `object` | false | Tag/s to assign to private Endpoint resource. Additional Details [here](#object---tags). | 
|`privateLinkServiceName` | `string` | true | Name of the private link connection. (EX: cux-subx-d-plk-dscartifactstorage) | 
|`privateLinkServiceExternalId` | `string` | true | Private link external id. |
|`privateLinkServiceGroupIDs` | `string` | true | The ID(s) of the group(s) obtained from the remote resource that this private endpoint should connect to. (EX: blob, registry ) | 
|`virtualNetworkExternalId` | `string` | true | Virtual network external Id used for deployment of the private Endpoint. |
|`subnetName` | `string` | true | Name of the subnet from the Virtual Network used for deployment of the private Endpoint. |
|`privateEndpointDnsZoneGroupName`| `string` | true | The resource name for private endpoint connection to DNS zone group.
|`privateDnsZoneConfigsName` | `string` | true | Name of the resource that is unique within a resource group. This name can be used to access the resource. (EX: 'PrivateEndPoints' )
|`privateDnsExternalId` | `string` | true | External id of the private dns zone used for linking the private Endpoint with the DNS Zones. |
|`requestMessage` | `string` | true | A message passed to the owner of the remote resource with this connection request. Restricted to 140 chars. |
|`connectionStateStatus` | `string` | true | Indicates whether the connection has been Approved/Rejected/Removed by the owner of the service. This should be Approved, Rejected or Removed. | 
|`connectionStateDescription` | `string` | false | The reason for approval/rejection of the connection. | 
|`connectionStateActionsRequired` | `string` | false | A message indicating if changes on the service provider require any updates on the consumer. |

Note: Private DNS Zone should be deployed before linking it with the Private Endpoint, otherwise the linking process will not be possible. 

### Object - tags
Below is an example of the tags object

`"key"`:`"value"`

**Example:**
```json
{
    "EvidenManaged": "true",
    "Project": "Monitoring Parent Module",
    "ManagedBy": "AzureBicep"
}
```

## Module outputs

| Name | Description | Value |
| --- | --- | --- |
| `privateEndpointName` | The name of the private Endpoint that has been created. | `privateEndpoint.name` | 
| `privateEndpointId` | The resource id of the private Endpoint that has been created. | `privateEndpoint.id` | 


## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "privateEndpointName": {
            "value": "Required. Name of the private endpoint"
        },
        "location": {
            "value": "Required. Location of the private endpoint"
        },
        "tags": {
            "value": {
            "tag1": "value1",
            "tag2": "value2"
            }
        },
        "privateLinkServiceName": {
            "value": "Required. Private Link service name"
        },
        "privateLinkServiceExternalId": {
            "value": "Required. Ex: /subscriptions/{subscription}/resourceGroups/{resource_group}/providers/Microsoft.Storage/storageAccounts/{storage_account_name}"
        },
        "privateLinkServiceGroupIDs":{
            "value": "Required. The ID(s) of the group(s) obtained from the remote resource that this private endpoint should connect to. (EX: blob, registry )"
        },
        "virtualNetworkExternalId": {
            "value": "Required. Ex: /subscriptions/{subscription}/resourceGroups/{resource_group}/providers/Microsoft.Network/virtualNetworks/{virtualNetwork_name}"
        },
        "subnetName":{
            "value": "Required. Subnet name from the virtual network"
        },
        "privateEndpointDnsZoneGroupName":{
            "value": "Required. The resource name for private endpoint connection to DNS zone group."
        },
        "privateDnsZoneConfigsName":{
            "value": "Required. Name of the resource that is unique within a resource group. This name can be used to access the resource. (EX: 'PrivateEndPoints' )"
        },
        "privateDnsExternalId": {
            "value": "Required. Ex: /subscriptions/{subscription}/resourceGroups/{resource_group}/providers/Microsoft.Network/privateDnsZones/{privatelink.blob.core.windows.net}"
        },
        "requestMessage": {
          "value": "Required. A message passed to the owner of the remote resource with this connection request. Restricted to 140 chars."
        },
        "connectionStateStatus": {
          "value": "Required. EX: Approved/Rejected/Removed"
        },
        "connectionStateDescription": {
          "value": "Optional. The reason for approval/rejection of the connection. EX: Auto-Approved" 
        },
        "connectionStateActionsRequired": {
          "value": "Optional. A message indicating if changes on the service provider require any updates on the consumer. EX: None"
        }
    }
}
```