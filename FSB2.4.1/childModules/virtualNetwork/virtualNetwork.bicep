/*
SUMMARY: Deployment of a virtual network.
DESCRIPTION: Deploy a virtual network to the desired Azure region.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.6
*/

// PARAMETERS
@description('Specifies the name of the Network Security Group (NSG).')
param networkSecurityGroupName string

@description('Specifies the location where the Azure Resource will be created.')
param location string

@description('Specifies a mapping of tags to assign to the resource.')
param tags object = {}

@description('Specifies the Virtual Network name.')
param virtualNetworkName string

@description('Specifies the array of 1 or more IP Address Prefixes for the Virtual Network.')
param virtualNetworkAddressPrefixes array

@description('Speficies the Resource ID of the DDoS protection plan. If empty, DDoS will not be enabled.')
param ddosProtectionPlanResourceId string = ''

@description('Specifies the DNS Servers to be associated to the Virtual Network.')
param dnsServers array

@description('Speficies the switch to enable or disable VM protection in subnets.')
param enableVmProtection bool

@description('Specifies the array of objects for the subnets that should be created.')
param subnets array

@description('Specifies the Subnet name prefix.')
param subnetNamePrefix string

// VARIABLES
// Variable to set the dnsServers array block
var dnsServerArray = {
  dnsServers: array(dnsServers)
}

// Variable to set the ddos protection plan resourceId block
var ddosProtectionPlan = {
  id: ddosProtectionPlanResourceId
}

// RESOURCE DEPLOYMENTS
// NETWORK SECURITY GROUP
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-08-01' = [for subnet in subnets: if (contains(subnet, 'securityRules')) {
  name: subnet.useNamingConventionModule == false && contains(subnet, 'securityRules') ? subnet.nsgName : '${networkSecurityGroupName}-${toLower(subnet.name)}'
  location: location
  tags: tags
  properties: {
    securityRules: subnet.securityRules
  }
}]

// VIRTUAL NETWORK
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: virtualNetworkAddressPrefixes
    }
    enableDdosProtection: !empty(ddosProtectionPlanResourceId)
    ddosProtectionPlan: !empty(ddosProtectionPlanResourceId) ? ddosProtectionPlan : null
    dhcpOptions: !empty(dnsServers) ? dnsServerArray : null
    enableVmProtection: enableVmProtection
    subnets: [for subnet in subnets: {
      name: contains(toLower(subnet.name), 'azurefirewallsubnet') || contains(toLower(subnet.name), 'gatewaysubnet') || contains(toLower(subnet.name), 'azurebastionsubnet') ? subnet.name : subnet.useNamingConventionModule == false ? subnet.name : '${subnetNamePrefix}-${subnet.name}'
      properties: {
        addressPrefix: subnet.addressPrefix
        addressPrefixes: contains(subnet, 'addressPrefixes') ? subnet.addressPrefixes : []
        ipAllocations: contains(subnet, 'ipAllocations') ? subnet.ipAllocations : []
        delegations: contains(subnet, 'delegations') ? subnet.delegations : []
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
        serviceEndpointPolicies: contains(subnet, 'serviceEndpointPolicies') ? subnet.serviceEndpointPolicies : []
        applicationGatewayIpConfigurations: contains(subnet, 'applicationGatewayIpConfigurations') ? subnet.applicationGatewayIpConfigurations : []
        networkSecurityGroup: contains(subnet, 'securityRules') && subnet.useNamingConventionModule == false ? {
          id: resourceId('Microsoft.Network/networkSecurityGroups', subnet.nsgName)
        } : contains(subnet, 'securityRules') ? {
          id: resourceId('Microsoft.Network/networkSecurityGroups', '${networkSecurityGroupName}-${subnet.name}')
        } : null
        routeTable: (contains(subnet, 'routeTable') ? !empty(subnet.routeTable) : false) ? {
          id: subnet.routeTable
        } : null
        privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? any(subnet.privateEndpointNetworkPolicies) : null
        privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? any(subnet.privateLinkServiceNetworkPolicies) : null
      }
    }]
  }
  dependsOn:[
    networkSecurityGroup
  ]
}

// OUTPUTS
@description('The name of the virtual network.')
output virtualNetworkName string = virtualNetwork.name

@description('The resource ID of the virtual network.')
output virtualNetworkResourceId string = virtualNetwork.id
