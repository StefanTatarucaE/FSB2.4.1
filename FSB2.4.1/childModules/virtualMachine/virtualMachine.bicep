/*
SUMMARY: Virtual Machine module
DESCRIPTION: Module used for deployment of the Virtual Machine for both Windows and Linux os types.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// PARAMETERS

@description('Name of the virtual machine.')
param computerName string

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Size of the virtual machine.')
param vmSize string

@description('Specifies the details of the image used for OS.')
param imageReference object

@description('Specifies the storage account type for the managed disk.')
param osDiskStorageAccountType string

@description('Specifies the size of an empty data disk in gigabytes. This value cannot be larger than 1023 GB')
param dataDiskSizeGB int

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param domainNameLabel string

@description('Parameter used to specify if Public IP should be deployed for the Virtual Machine.')
param deployPublicIp bool = false

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string

@description('Allocation method for the Public IP used to access the Virtual Machine.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string

@description('SKU for the Public IP used to access the Virtual Machine.')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string

@description('Id of the subnet used for the Virtual Machine.')
param subnetId string

@description('Name of the network interface for the Virtual Machine.')
param nicName string

@description('A mapping of tags to assign to the resource.')
param tags object

//Variable to set the Public IP ID
var publicIPAddress = {
  id: pip.id
}

// RESOURCE DEPLOYMENTS 

resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = if (deployPublicIp != false) {
  name: deployPublicIp ? publicIpName : 'n.a'
  location: location
  tags: tags
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: domainNameLabel
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: deployPublicIp ? publicIPAddress : null
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: computerName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imageReference.publisher
        offer: imageReference.offer
        sku: imageReference.sku
        version: imageReference.version
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskStorageAccountType
        }
      }
      dataDisks: [
        {
          diskSizeGB: dataDiskSizeGB
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// OUTPUTS

output hostname string = vm.name
