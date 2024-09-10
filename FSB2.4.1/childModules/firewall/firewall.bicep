/*
SUMMARY: Azure Firewall Bicep module.
DESCRIPTION: Deploy an Azure Firewall instance in the HUB network.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

//PARAMETERS
@description('The name that will be used for the Azure Firewall resource.')
param firewallName string

@description('Specifies the SKU of the Firewall')
@allowed([
  'Standard'
  'Premium'
  ])
param azureFirewallSku string

@description('Tag/s to assign to this resource.')
param tags object

@description('Specifies the operation mode for Azure Firewall Threat Intelligence.')
@allowed([
  'Alert'
  'Deny'
  'Off'
  ''
])
param threatIntelMode string

@description('Azure Firewall Puplic IP Resource Name prefix. The array index will be added at the end of the name')
param firewallPublicIpAddressName string

@description('Number of Public IP Addresses the Firewall will use. (min 1 and max 100)')
@minValue(1)
@maxValue(100)
param hubNetworkFirewallNumberOfPublicIPAddresses int

@description('Availability zone numbers e.g. 1,2,3., Use empty array [] if no availability zones are required')
param hubNetworkPublicIPAvailabilityZones array

@description('Availability zone numbers, e.g. 1,2,3. Use empty array [] if no availability zones are required')
param hubNetworkAzureFirewallAvailabilityZones array

@description('Existing Hub Virtual Network Name which should include the "AzureFirewallSubnet" subnet.')
param hubNetworkVnetName string

@description('Name of the policy for Azure Firewall. This policy holds all the settings like firewall rules, DNS Settings, Threat intelligence.')
param firewallPolicyName string

@description('Name of the resource group where the Azure Firewall Policy is deployed.')
param firewallPolicyResourceGroup string

@description('Name of the region where the deployment will be done')
param location string

//VARIABLES

var azureFirewallPublicIpId = resourceId('Microsoft.Network/publicIPAddresses', firewallPublicIpAddressName) //variable defined to reference it in the azureFirewallIpConfigurations variable
var azureFirewallSubnetJson = json('{"id": "${azureFirewallSubnetId.id}"}') //defined to simplify the Subnet assignment in the variable azureFirewallIpConfigurations
var azureFirewallIpConfigurations = [for i in range(0, hubNetworkFirewallNumberOfPublicIPAddresses): { //variable declared to simplify the IpConfigurations property definiton for the firewall
  name: 'IpConf${i}'
  properties: {
    subnet: i == 0 ? azureFirewallSubnetJson : json('null') //Logic reason: Azure Firewall cannot have more than one subnet reference, deployment fails if the subnet is specified more than once.
    publicIPAddress: {
      id: '${azureFirewallPublicIpId}${i + 1}'
    }
  }
}]

//RESOURCES

resource azureFirewallSubnetId 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  name: '${hubNetworkVnetName}/AzureFirewallSubnet'
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2021-08-01' existing = {
  name: firewallPolicyName
  scope: resourceGroup(firewallPolicyResourceGroup)
}

resource firewallPublicIpAddressNames 'Microsoft.Network/publicIPAddresses@2021-08-01' = [for i in range(0, hubNetworkFirewallNumberOfPublicIPAddresses): {
  name: '${firewallPublicIpAddressName}${i + 1}'
  location: location
  tags: tags
  zones: ((length(hubNetworkPublicIPAvailabilityZones) == 0) ? json('null') : hubNetworkPublicIPAvailabilityZones)
  sku: {
    name: 'Standard' //Hardcoded value to avoid conflicts between Basic SKU and availability zones not supported by it. 
    tier: 'Regional' //Hardcoded value as Global tier is supported only by Cross-region load balancers. 
  }
  properties: {
    publicIPAllocationMethod: 'Static' //value hardcoded as per Microsoft documentation: https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#ip-address-assignment
    publicIPAddressVersion: 'IPv4' //value hardcoded as this is the only accepted configurationn for azure firewall at this time: https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#at-a-glance 
  }
}]

resource firewall 'Microsoft.Network/azureFirewalls@2021-03-01' = {
  name: firewallName
  tags: tags
  zones: ((length(hubNetworkAzureFirewallAvailabilityZones) == 0) ? json('null') : hubNetworkAzureFirewallAvailabilityZones)
  location: location
  properties: {
    ipConfigurations: azureFirewallIpConfigurations
    firewallPolicy: {
      id: firewallPolicy.id
    }
    threatIntelMode: threatIntelMode
    sku: {
      tier: azureFirewallSku
    }
  }
  dependsOn: [
    firewallPublicIpAddressNames
  ]
}

//OUTPUTS
output azureFirewallObject object = reference(firewall.name, '2021-08-01')
output azureFirewallResId string = firewall.id
