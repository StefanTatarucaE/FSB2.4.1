# virtualMachine/virtualMachine.bicep
Module used for deployment of the Virtual Machine for both Windows and Linux os types.

## Description
Azure Virtual Machines (VM) is one of several types of on-demand, scalable computing resources that Azure offers. Typically, you choose a VM when you need more control over the computing environment than the other choices offer. An Azure VM gives you the flexibility of virtualization without having to buy and maintain the physical hardware that runs it. However, you still need to maintain the VM by performing tasks, such as configuring, patching, and installing the software that runs on it.

## Module example use
Windows:
```hcl
module devVirtualMachine '../../childModules/virtualMachine/virtualMachine.bicep' = {
  scope: resourceGroup('20220215-LGTesting')
  name: 'devVMModule'
  params: {
    computerName: 'TestVM20220223'
    adminUsername: 'AdminVM1'
    adminPassword: 'AdminTest!555@!'
    vmSize: 'Standard_DS1_v2'
    deployPublicIp: false
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-Datacenter'
      version: 'latest'
    }
    osDiskStorageAccountType: 'StandardSSD_LRS'
    dataDiskSizeGB: 1023
    subnetId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/cu2-sub3-d-rsg-spoke-network/providers/Microsoft.Network/virtualNetworks/cu2-sub3-d-uswe-vnet-spoke/subnets/cu2-sub3-d-uswe-snet-spoke-back'
    diagnosticStorageAccountName: 'bootdiagstestvm1'
    diagnosticStorageAccountSKU: 'Standard_LRS'
    publicIpName: 'TestVM1-pip'
    publicIPAllocationMethod: 'Dynamic'
    publicIpSku: 'Basic'
    domainNameLabel: 'testvm20220223'
    nicName: 'nicName'
    tags: {
        EvidenManaged: 'Yes'
        Environment: 'Development' 
    }
  }
}
```

Linux:
```hcl
module devVirtualMachine '../../childModules/virtualMachine/virtualMachine.bicep' = {
  scope: resourceGroup('20220215-LGTesting')
  name: 'devVMModule'
  params: {
    computerName: 'TestVM20220223'
    adminUsername: 'AdminVM1'
    adminPassword: 'AdminTest!555@!'
    vmSize: 'Standard_DS1_v2'
    imageReference: {
      publisher: 'Canonical'
      offer: 'UbuntuServer'
      sku: '18.04-LTS'
      version: 'latest'
    }
    osDiskStorageAccountType: 'StandardSSD_LRS'
    dataDiskSizeGB: 1023
    subnetId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/cu2-sub3-d-rsg-spoke-network/providers/Microsoft.Network/virtualNetworks/cu2-sub3-d-uswe-vnet-spoke/subnets/cu2-sub3-d-uswe-snet-spoke-back'
    diagnosticStorageAccountName: 'bootdiagstestvm1'
    diagnosticStorageAccountSKU: 'Standard_LRS'
    publicIpName: 'TestVM1-pip'
    publicIPAllocationMethod: 'Dynamic'
    publicIpSku: 'Basic'
    domainNameLabel: 'testvm20220223'
    nicName: 'nicName'
    tags: {
        EvidenManaged: 'Yes'
        Environment: 'Development' 
    }
  }
}
```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `computerName` | `string` | true | Name of the virtual machine. |
| `adminUsername` | `string` | true | Username for the Virtual Machine. |
| `adminPassword` | `string` | true | Password for the Virtual Machine. |
| `vmSize` | `string` | true | Size of the virtual machine. |
| `imageReference` | `object` | true | Specifies the details of the image used for OS. Additional Details [here](#object---imagereference). |
| `osDiskStorageAccountType` | `string` | true | Specifies the storage account type for the managed disk. |
| `dataDiskSizeGB` | `int` | true | Specifies the size of an empty data disk in gigabytes. This value cannot be larger than 1023 GB |
| `domainNameLabel` | `string` | true | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| `deployPublicIp` | `boolean` | true | Parameter used to specify if Public IP should be deployed for the Virtual Machine. |
| `publicIpName` | `string` | true | Name for the Public IP used to access the Virtual Machine. |
| `publicIPAllocationMethod` | `string` | true | Allocation method for the Public IP used to access the Virtual Machine. |
| `publicIpSku` | `string` | true | SKU for the Public IP used to access the Virtual Machine. |
| `subnetId` | `string` | true | Id of the subnet used for the Virtual Machine. |
| `nicName` | `string` | true | Name of the network interface for the Virtual Machine. |
| `diagnosticStorageAccountSKU` | `string` | true | SKU of the diagnostic storage account used for the Virtual Machine. |
| `diagnosticStorageAccountName` | `string` | true | Name of the diagnostic storage account used for the Virtual Machine. |
| `tags` | `object` | true | A mapping of tags to assign to the resource. Additional Details [here](#object---tags). |


### Object - imageReference

| Name | Type | Description |
| --- | --- | --- |
| `communityGalleryImageId` | `string` |Specified the community gallery image unique id for vm deployment. This can be fetched from community gallery image GET call. |
| `id` | `string` | Resource Id |
| `offer` | `string` | Specifies the offer of the platform image or marketplace image used to create the virtual machine. |
| `publisher` | `string` | The image publisher.|
| `sharedGalleryImageId` | `string` | Specified the shared gallery image unique id for vm deployment. This can be fetched from shared gallery image GET call.|
| `sku` | `string` | The image SKU.|
| `version` | `string` | Specifies the version of the platform image or marketplace image used to create the virtual machine. The allowed formats are Major.Minor.Build or 'latest'. Major, Minor, and Build are decimal numbers. Specify 'latest' to use the latest version of an image available at deploy time. Even if you use 'latest', the VM image will not automatically update after deploy time even if a new version becomes available. Please do not use field 'version' for gallery image deployment, gallery image should always use 'id' field for deployment, to use 'latest' version of gallery image, just set '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/galleries/{galleryName}/images/{imageName}' in the 'id' field without version input.|

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
| `hostname` | Hostname of the virtual machine. | `pip.properties.dnsSettings.fqdn` |

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "computerName":{
            "value": "LGTestVM1"
        },
        "adminUsername": {
            "value": "admintest1"
        },
        "adminPassword": {
            "value": "AdminTest!555@!"
        },
        "vmSize": {
            "value": "Standard_DS1_v2"
        },
        "imageReference": {
            "value": {
                "publisher": "Canonical",
                "offer": "UbuntuServer",
                "sku": "18.04-LTS",
                "version": "latest"
            }
        },
        "osDiskStorageAccountType": {
            "value": "StandardSSD_LRS"
        },
        "dataDiskSizeGB": {
            "value": 1023
        },
        "subnetId": {
            "value": "/subscriptions/742e5c18-1754-419f-9b6c-9905e2483c9e/resourceGroups/cu2-sub3-d-rsg-spoke-network/providers/Microsoft.Network/virtualNetworks/cu2-sub3-d-uswe-vnet-spoke/subnets/cu2-sub3-d-uswe-snet-spoke-back"
        },
        "deployPublicIp": {
            "value": false
        },
        "publicIpName": {
            "value": "TestVM1-pip"
        },
        "publicIPAllocationMethod": {
            "value": "Dynamic"
        },
        "publicIpSku": {
            "value": "Basic"
        },
        "domainNameLabel": {
            "value": "lgtestvm1"
        },
        "nicName": {
            "value": "nicName"
        },
        "tags": {
            "value": {
                "Owner": "Lukasz Grzejszczyk",
                "Project": "BicepModule",
                "UserStory": "DCSAZ-xxx",
                "ManagedBy": "Bicep"
            }
        }
    }
}
```