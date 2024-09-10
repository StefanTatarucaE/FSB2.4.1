# bastionHost/bastionHost.bicep
Bicep module to create Azure Bastion Host.

## Description
This module deploys Azure Bastion Host in desired region.
(ELZ Azure Network solution parent module will deploy Bastion in the connectivity subscription.)
The below are prereq for this module:
 - Azure Public IP with Standard SKU
 - Virtual Network should contain AzureBastionSubnet (ELZ Azure uses hub virtual network)

Copy-paste between your local device and the remote session is enabled by default In Standard and Basic SKU. 
With Standard SKU below additional features are supported: 
- Host scaling
- Upload and download files
- Disable copy-paste (for web clients)
- Specify custom inbound port (with basic it is 3389 and 22)
- Connect to Linux VM using RDP
- Connect to Windows VM using SSH

## Configuration requirements

The subnet name must be AzureBastionSubnet. The subnet cannot contain additional resources.
The subnet must be at least /26 or larger to accommodate features available with the Standard SKU.
The Public IP address SKU must be Standard, static and in the same region as the Bastion resource you're creating.

UDR isn't supported on an Azure Bastion subnet.

In case NSG are required on the Bastion Subnet the following set of rules are required:
https://docs.microsoft.com/en-us/azure/bastion/bastion-nsg

IMPORTANT!
If you use Private DNS Zone linked with the Hub Vnet (where Bastion subnet is) it should never have the following exact names:
 - management.azure.com
 - blob.core.windows.net
 - core.windows.net
 - vaultcore.windows.net
 - vault.azure.com
 - azure.com

Otherwise the Bastion will stop working because is a resource that needs access to vault/storage/management

## Module Example Use
```bicep

module networkingBastionHost '../../childModules/bastionHost/bastionHost.bicep' = if ((subscriptionType == 'cnty') && enableBastion) {
scope: networkingResourceGroup
name: 'bastionHost-deployment'
dependsOn: [
  networkingVirtualNetwork
  networkingBastionPublicIpAddress
]
params:{
  location: location
  sku: bastionSku
  tags: tags
  bastionHostName: namingData.connectivityHubBastion.name
  enableFileCopy: enableFileCopy
  scaleUnits: scaleUnits
  enableShareableLink: enableShareableLink
  publicIpName: namingData.connectivityHubBastionPip.name
  disableCopyPaste: disableCopyPaste
  enableIpConnect: enableIpConnect
  virtualNetworkId: networkingVirtualNetwork.outputs.virtualNetworkResourceId
  enableTunneling: enableTunneling
}
}

```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `bastionHostName` | `string` | true | Specify Bastion Host Name |
| `location` | `string` | true | Specify the location where Bastion Host is to be created|
| `tags` | `string` | true | Speciy mapping of tags attached to bastion host|
| `virtualNetworkId` | `string` | true | Existing Virtual Network ID which should include the "AzureBastionSubnet" subnet|
| `publicIpName` | `string` | true | Existing Public IP name to associate with Bastion Host |
| `sku` | `string` | true | Specify Sku for bastion host|
| `disableCopyPaste` | `bool` | true | Enable/Disable Copy/Paste feature of the Bastion Host resource. |
| `enableFileCopy` | `bool` | true | Enable/Disable File Copy feature of the Bastion Host resource. |
| `enableIpConnect` | `bool` | true | Enable/Disable IP Connect feature of the Bastion Host resource.|
| `enableShareableLink` | `bool` | true | Enable/Disable Shareable Link of the Bastion Host resource.|
| `enableTunneling` | `bool` | true | Enable/Disable Tunneling feature of the Bastion Host resource.|
| `scaleUnits` | `int` | true | Specify the instance count for the Bastion Host resource. Instance scaling is only supported when sku is Standard. Bastion can support 2-50 VM instances.|


## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `bastionHostId` | The resource ID of the created bastion host. | `bastionHost.id` |