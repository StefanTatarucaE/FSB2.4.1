/*
SUMMARY: Virtual Wan solution
DESCRIPTION: Parent module to deploy Virtual Wan solution.             
AUTHOR/S: alexandru-daniel.stan@atos.net, marcin.gala@eviden.com
VERSION: 0.0.3
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

// PARAMETERS
@description('Parameter to determine the subscription using abbreviation. To be provided by the pipeline')
@allowed([
  'mgmt'
  'cnty'
  'lndz'
  'tool'
])
param subscriptionType string

@description('Specifies the location where the Azure Resource will be created')
param location string = deployment().location

@description('A mapping of tags to assign to the resource.')
param additionalNetworkingTags object = {}

@description('Specifies if Firewall TLS specific resources (Identity and Keyvault) should be deployed.')
param deployFirewallTlsPrerequisites bool = false

@description('''Enable or disable logic necessary to support legacy names. 
Set to true if the environment was\is upgraded to 2.x from a version that was deployed using 1.x version. 
Please make sure to read the documentation for additional information.
''')
param legacyNaming bool = false

@description('Provide address space for the Virtual Network. Example: 10.0.0.0/16')
param vnetAddressPrefixes array

@description('Enables VM protection in subnets (true or false)')
param enableVmProtection bool = false

@description('The DNS address(es) of the DNS Server(s) used by the virtual network. Use an empty array [] if the default Azure provided DNS should be used. Note: Arrays with a single element are not supported.')
param dnsServers array = []

@description('Array of elements to specify the subnets that should be created')
param subnets array

@description('An array of route tables that will be created')
param routes array = []

@description('Enable or disable BGP route propagation (true or false).')
param disableBgpRoutePropagation bool = true

@description('Deploy and Enable Azure Bastion Host.')
param deployBastionHost bool = false

@description('Specifies the configuration values for the Bastion host Public IP.')
param bastionHostIpConfig object = {}

@description('Specifies the configuration values for the Bastion host.')
param bastionHostConfig object = {}

@description('Specify the Connectivity Subscription ID')
param cntySubscriptionId string = ''

@description('Switch to deploy Private DNS Zone (true or false)')
param deployPrivateDnsZone bool = false

@description('Switch to deploy Private DNS Zone Virtual Network Link (true or false)')
param deploySpokePrivateDnsVirtualNetworkLink bool = false

@description('Switch to Enable Private DNS Auto registration (true of false)')
param enableSpokePrivateDnsZoneAutoRegistration bool = false

@description('The name of the zone, for example, contoso.com.')
param privateDnsZoneName string

@description('Create A record set.')
param privateDnsARecordSet array = []

@description('Create CNAME record set.')
param privateDnsCnameRecordSet array = []

@description('Create MX record set.')
param privateDnsMxRecordSet array = []

@description('Create PTR record set.')
param privateDnsPtrRecordSet array = []

@description('Create SRV record set.')
param privateDnsSrvRecordSet array = []

@description('Create TXT record set.')
param privateDnsTxtRecordSet array = []

@description('Create AAAA record set.')
param privateDnsAaaaRecordSet array = []

@description('Specifies if branch to branch traffic is allowed.')
param allowBranchToBranchTraffic bool

@description('Specifies if Vnet to Vnet traffic is allowed.')
param allowVnetToVnetTraffic bool

@description('Specifies if Vnet to Vnet traffic is allowed.')
param disableVpnEncryption bool

@description('Specifies the type of the VirtualWAN which can be either "Standard" or "Basic".')
@allowed([
  'Standard'
  'Basic'
])
param virtualWanType string = 'Standard'

@description('''Array Used for multiple Virtual WAN Hubs deployment. Each object in the array represents an individual Virtual WAN Hub configuration. Add/remove additional objects in the array to meet the number of Virtual WAN Hubs required.
- `virtualHubEnabled` - Switch to enable/disable Virtual Hub deployment.
- `vpnGatewayEnabled` - Switch to enable/disable VPN Gateway deployment on the respective Virtual WAN Hub.
    - `bgpPeeringAddress` - BGP peering address and identifier for the VPN Gateway.
    - `peerWeight` - The weight added to routes learned from this BGP speaker. Default is 5.
    - `VpnGatewayScaleUnit` - The scale unit for this vpn gateway. Default is 1.
- `expressRouteGatewayEnabled` - Switch to enable/disable ExpressRoute Gateway deployment on the respective Virtual WAN Hub.
    - `expressRouteGatewayScaleUnit` - Minimum number of scale units deployed for ExpressRoute gateway. Default used value is 1.
- `azFirewallEnabled` - Switch to enable/disable Azure Firewall deployment on the respective Virtual WAN Hub.
    - `azFirewallTier` - Azure Firewall Tier associated with the Firewall to deploy. Allowed values are: 'Basic', 'Standard', 'Premium'. If `azFirewallEnabled` is set to false, the value of this property won't matter. 
    - `azFirewallAvailabilityZones` - Availability Zones to deploy the Azure Firewall across. Region must support Availability Zones to use. If it does not then leave empty.
    - `azFirewallPolicySku` - Specifies the tier of the Firewall Policy. Allowed values are: 'Basic', 'Standard', 'Premium'. If `azFirewallEnabled` is set to false, the value of this property won't matter.
    - `azFirewallDnsProxyEnabled` - Enable DNS Proxy on Firewalls attached to the Firewall Policy (bool). If `azFirewallEnabled` is set to false, the value of this property won't matter.
    - `enableFirewallIntrusionDetection` - Specifies if Firewall Intrusion detection is enabled. Goes together with parameter firewallIntrusionDetection.
    - `enableTlsInspection` - Specify if TLS inspection should be enabled.
    - `firewallIntrusionDetection` - An object which holds the intrusion detection protection system (IDPS) configuration..
    - `threatIntelMode` - Specifies the operation mode for Threat Intelligence. Allowed values are 'Alert', 'Deny' or 'Off'.
    - `firewallPolicyWhitelistFqdns` - Specifies an array of FQDNs for the ThreatIntel Allowlist. Default: [].
    - `firewallPolicyWhitelistIpAddresses` - Specifies an array of IP addresses for the ThreatIntel Allowlist. Default: [].
- `virtualHubAddressPrefix` - The IP address range in CIDR notation for the vWAN virtual Hub to use.
- `virtualHubSku` - The SKU for the vWAN virtual Hub. Accepts either 'Basic' or 'Standard'.
- `location` - The Virtual WAN Hub location.
- `hubRoutingPreference` - The Virtual WAN Hub routing preference. The allowed values are `ASPath`, `VpnGateway`, `ExpressRoute`.
- `virtualRouterAutoScaleConfiguration` - The Virtual WAN Hub capacity. The value should be between 2 to 50.
- `virtualHubRoutingIntentDestinations` - The Virtual WAN Hub routing intent destinations, leave an empty array [] if not wanting to enable routing intent. The allowed values are `Internet`, `PrivateTraffic`.
- `virtualHubRouteTableRouteName` - The name of the route table route.
- `virtualHubRouteTableDestinationType` - The type of destinations for the hub route table route (eg: CIDR, ResourceId, Service). "CIDR" is default.
- `virtualHubRouteTableRouteDestinations` - The list of all destinations/address spaces connected to the virtual hub.
- `virtualHubRouteTableRouteNextHopType` - The next hop type for the route ("ResourceId")
''')
param virtualWanHubs array = []

@description('Specifies whether virtual Wan is enabled or disabled')
param virtualWanEnabled bool = true

@description('Deprecated: VirtualHub to RemoteVnet transit to enabled or not.')
param allowHubToRemoteVnetTransit bool

@description('Deprecated: Allow RemoteVnet to use Virtual Hub"s gateways.')
param allowRemoteVnetToUseHubVnetGateways bool

@description('Enable internet security.')
param enableInternetSecurity bool

@description('List of labels associated with the route table. Default label is "default".')
param virtualHubRouteTableLabels string = 'default'

@description('Secret ID of the Certificate for TLS Inspection')
param tlsKeyVaultCertId string = ''

@description('ID of the User Managed Identity for the TLS Inspection')
param firewallUserIdentity string = ''

@description('Specifies if DDoS protection is to be deployed.')
param deployDdos bool = false

// VARIABLES

//Variables to load in the naming convention files for resource naming.
var namingJsonData = {
  mgmt: {
    definition: json(loadTextContent('../../mgmtNaming.json'))
  }
  cnty: {
    definition: json(loadTextContent('../../cntyNaming.json'))
  }
  lndz: {
    definition: json(loadTextContent('../../lndzNaming.json'))
  }
  tool: {
    definition: json(loadTextContent('../../toolNaming.json'))
  }
}

var parentModuleConfig = loadJsonContent('parentModuleConfig.json')

var namingData = namingJsonData[subscriptionType].definition

// Variables to set the desired resourcegroup names depending on subscription type

var sharedConnectivityNetworkResourcesResourceGroup = namingData.sharedConnectivityNetworkResourcesResourceGroup.name
var resourceGroupNameSpoke = namingData.spokeResourceGroup.name
var networkingResourceGroupName = (subscriptionType == 'cnty') ? sharedConnectivityNetworkResourcesResourceGroup : resourceGroupNameSpoke

var virtualWanResourceGroupName = namingJsonData.cnty.definition.connectivityVirtualWanResourceGroup.name

var privateDnsZoneResourceGroupName = namingJsonData.cnty.definition.sharedConnectivityNetworkResourcesResourceGroup.name

// Variable to set the desired route table name depending on subscription type
var routeTableName = namingData.connectivitySpokeRouteTable.name

// Variable to set the desired virtual Wan name
var virtualWanName = namingData.connectivityVirtualWan.name

// Variable ot set the desired virtual Wan Hub name
var virtualWanHubName = namingJsonData.cnty.definition.connectivityVirtualWanHub.name

// Variable to set the desired virtual network name depending on subscription type
var virtualNetworkName = (subscriptionType == 'cnty') ? namingData.sharedConnectivityHubNetworkVnet.name : namingData.connectivitySpokeVnet.name

// Variable to set the desired network security group prefix name depending on subscription type
// This will pre-pend any network security group name
// Together with the 'subnet.name' value coming from the parameters file the full network security group name is formed
var networkSecurityGroupNamePrefix = (subscriptionType == 'cnty') ? namingData.connectivityHubVnetSubNetNsg.name : namingData.connectivitySpokeVnetSubNetNsg.name

// Variables to set the desired related names for Firewall TLS Encryption related resources

var tlsUserManagedIdentityName = namingData.tlsUserManagedIdentityName.name
var tlsKeyVaultName = namingData.tlsKeyVaultName.name

// Variable to set the desired subnet prefix name depending on subscription type
// This will pre-pend any subnet name
// Together with the 'subnet.name' value coming from the parameters file the full subnet name is formed
var subnetNamePrefix = (subscriptionType == 'cnty') ? namingData.connectivityHubVnetSubNet.name : namingData.connectivitySpokeVnetSubnet.name

// Variable to set the necessary virtualNetworkLink used by the privateDnsZoneVirtualNetworkLink child module deployment
var privateDnsZoneVirtualNetworkLinkName = legacyNaming ? '${virtualNetwork.outputs.virtualNetworkName}-link' : '${virtualNetwork.outputs.virtualNetworkName}-vnetlink'

// Variables to set the desired related bastionHost names depending on subscription type
// To prevent issues with template validation of this parentmodule when there are identical resourcegroups used in different subscriptions, resourcegroupnames get a unique (dummy) name 
// in the case the resourcegroup will not be created (for the subscriptiontype that passed as a parameter to this parentmodule).
var bastionHostPublicIpName = namingData.connectivityHubBastionPip.name
var bastionHostName = namingData.connectivityHubBastion.name

// Variable which contains a unique value based on subscriptionId & deployment location
// used to deploy the child modules on subscription level.
#disable-next-line no-loc-expr-outside-params
var uniqueDeployPrefix = take(uniqueString(subscription().subscriptionId, deployment().location), 6)

// Variable to join tags provided via parametersm with mandatory tags used by ELZ Azure product
var tagPrefix = namingData.tagPrefix.name
var tagValuePrefix = namingData.tagValuePrefix.name
var tags = union(additionalNetworkingTags, { '${tagPrefix}Managed': 'true' }, { '${tagPrefix}Purpose': (subscriptionType == 'cnty') ? '${tagValuePrefix}VirtualWanHub' : '${tagValuePrefix}NetworkingSpoke' })

// Variables to set firewall policy name
var firewallPolicyName = namingData.connectivityHubFirewallPolicy.name
var firewallPolicyNamePremium = namingData.connectivityHubFirewallPolicyPremium.name

// Variable to set firewall name
var firewallName = namingData.connectivityHubFirewall.name
var virtualWanVpnGatewayName = namingData.connectivityVirtualWanVpnGateway.name

// Variable to set Express Route Gateway name
var virtualWanExpressRouteGatewayName = namingData.connectivityVirtualWanExpressRouteGateway.name

// Variable to set virtual hub Routing Intent name
var virtualWanHubRoutingIntentName = namingData.connectivityVirtualHubRoutingIntent.name

// Variable to set the desired DDos Plan name depending on subscription type
var ddosPlanName = namingData.connectivityDdosPlanName.name

// filter subnets array if deployBastionHost is false
var filter = [for (subnet, i) in subnets: (!((deployBastionHost == false) && (subnet.name == 'AzureBastionSubnet'))) ? subnet : []]

var filteredSubnets = intersection(filter, subnets)

// RESOURCE DEPLOYMENTS

// Create a resource group to hold the Vwan resources.
resource virtualWanResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (subscriptionType == 'cnty') {
  name: virtualWanResourceGroupName
  location: location
  tags: tags
}

// Create a resource group to hold the Vnetwork resources.

// Create a resource group to hold the bastionHost resources.
resource networkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: networkingResourceGroupName
  location: location
  tags: tags
}

// Deploy Virtual Network
module virtualNetwork '../../childModules/virtualNetwork/virtualNetwork.bicep' = {
  scope: networkResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-virtualNetwork-deployment'
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressPrefixes: vnetAddressPrefixes
    location: location
    tags: tags
    ddosProtectionPlanResourceId: ((subscriptionType == 'cnty') && deployDdos) ? ddosProtectionPlan.outputs.ddosProtectionPlanResourceId : ''
    dnsServers: dnsServers
    enableVmProtection: enableVmProtection
    networkSecurityGroupName: networkSecurityGroupNamePrefix
    subnetNamePrefix: subnetNamePrefix
    subnets: [for subnet in filteredSubnets: ((subscriptionType == 'lndz') || (subscriptionType == 'tool')) ? union(subnet, { routeTable: routeTable.outputs.routeTableResourceId }) : union(subnet, { routeTable: null })]
  }
}

// Deploy Route Table
module routeTable '../../childModules/routeTable/routeTable.bicep' = if ((subscriptionType == 'lndz') || (subscriptionType == 'tool')) {
  scope: networkResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-routeTable-deployment'
  params: {
    name: routeTableName
    location: location
    tags: tags
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: routes
  }
}

// Deploy DDoS Plan
module ddosProtectionPlan '../../childModules/ddosProtectionPlan/ddosProtectionPlan.bicep' = if ((subscriptionType == 'cnty') && deployDdos) {
  scope: networkResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-ddosPlan-deployment'
  params: {
    name: ddosPlanName
    location: location
    tags: tags
  }
}

// Private DNS Zones cannot be linked currently to the Virtual WAN Hub however, they can be linked to spokes as they are normal VNets as per https://docs.microsoft.com/azure/virtual-wan/howto-private-link
module privateDnsZone '../../childModules/privateDnsZone/privateDnsZone.bicep' = if ((subscriptionType == 'cnty') && deployPrivateDnsZone) {// Private DNS will be deployed only in Connectivity
  scope: networkResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-privateDnsZone-deployment'
  params: {
    name: privateDnsZoneName
    tags: tags
    aRecordSet: privateDnsARecordSet
    aaaaRecordSet: privateDnsAaaaRecordSet
    cnameRecordSet: privateDnsCnameRecordSet
    mxRecordSet: privateDnsMxRecordSet
    ptrRecordSet: privateDnsPtrRecordSet
    srvRecordSet: privateDnsSrvRecordSet
    txtRecordSet: privateDnsTxtRecordSet
  }
  dependsOn: [
    virtualNetwork
  ]
}

// Virtual Network link between the Spoke vNet and the Private DNS Zone in Cnty sub
module privateDnsZoneVirtualNetworkLinkSpoke '../../childModules/privateDnsZoneVirtualNetworkLink/privateDnsZoneVirtualNetworkLink.bicep' = if (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deploySpokePrivateDnsVirtualNetworkLink) {
  scope: resourceGroup(cntySubscriptionId, privateDnsZoneResourceGroupName) // As the deployment is done in Lndz, the scope needs to be changed for CNTY where the Private DNS Zone resides
  name: '${uniqueDeployPrefix}-${subscriptionType}-virtualNetworkLinkSpoke-deployment'
  params: {
    privateDnsZoneName: privateDnsZoneName
    name: privateDnsZoneVirtualNetworkLinkName
    tags: tags
    registrationEnabled: enableSpokePrivateDnsZoneAutoRegistration
    virtualNetworkId: virtualNetwork.outputs.virtualNetworkResourceId
  }
}

// Deploy Public IP for bastionHost
module bastionHostPublicIpAddress '../../childModules/publicIp/publicIp.bicep' = if ((subscriptionType == 'cnty') && deployBastionHost) {
  scope: networkResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-publicIpAddressBastion-deployment'
  params: {
    name: bastionHostPublicIpName
    location: location
    tags: tags
    skuName: bastionHostIpConfig.skuName
    skuTier: bastionHostIpConfig.skuTier
    zones: bastionHostIpConfig.zones
    idleTimeoutInMinutes: bastionHostIpConfig.idleTimeoutInMinutes
    publicIpAddressVersion: bastionHostIpConfig.publicIpAddressVersion
    publicIpAllocationMethod: bastionHostIpConfig.publicIpAllocationMethod
  }
}

// Deploy bastionHost
module bastionHost '../../childModules/bastionHost/bastionHost.bicep' = if ((subscriptionType == 'cnty') && deployBastionHost) {
  scope: networkResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-bastionHost-deployment'
  params: {
    bastionHostName: bastionHostName
    location: location
    tags: tags
    sku: bastionHostConfig.sku
    enableFileCopy: bastionHostConfig.enableFileCopy
    scaleUnits: bastionHostConfig.scaleUnits
    enableShareableLink: bastionHostConfig.enableShareableLink
    publicIpName: bastionHostPublicIpName
    disableCopyPaste: bastionHostConfig.disableCopyPaste
    enableIpConnect: bastionHostConfig.enableIpConnect
    virtualNetworkId: virtualNetwork.outputs.virtualNetworkResourceId
    enableTunneling: bastionHostConfig.enableTunneling
  }
  dependsOn: [
    virtualNetwork
    bastionHostPublicIpAddress
  ]
}

// Deploy Managed Identity required by TLS Inspection
module tlsManagedIdentity '../../childModules/managedIdentity/managedIdentity.bicep' = if ((subscriptionType == 'cnty') && deployFirewallTlsPrerequisites) {
  scope: virtualWanResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-tlsManagedIdentity-deployment'
  params: {
    userManagedIdentityName: tlsUserManagedIdentityName
    location: location
    tags: tags
  }
}

// Deploy KeyVault required by TLS inspection

module tlsKeyVault '../../childModules/keyVault/keyVault.bicep' = if ((subscriptionType == 'cnty') && deployFirewallTlsPrerequisites) {
  scope: virtualWanResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-tlsKeyVault-deployment'
  params: {
    keyVaultName: tlsKeyVaultName
    location: location
    tags: tags
    skuName: parentModuleConfig.tlsKeyVaultConfig.skuName
    softDeleteRetentionInDays: parentModuleConfig.tlsKeyVaultConfig.softDeleteRetentionInDays
    publicNetworkAccess: parentModuleConfig.tlsKeyVaultConfig.publicNetworkAccess
    networkRuleBypassOptions: parentModuleConfig.tlsKeyVaultConfig.networkRuleBypassOptions
    networkRuleAction: parentModuleConfig.tlsKeyVaultConfig.networkRuleAction
    keyVaultFeatures: parentModuleConfig.tlsKeyVaultFeatures
  }
}

// Deploy KeyVault Access Policies for TLS managed identity

module tlsKeyVaultAccessPolicies '../../childModules/keyVaultAccessPolicy/keyVaultAccessPolicy.bicep' = if ((subscriptionType == 'cnty') && deployFirewallTlsPrerequisites) {
  scope: virtualWanResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-tlsKVAccessPolicies-deployment'
  params: {
    keyVaultName: ((subscriptionType == 'cnty') && deployFirewallTlsPrerequisites) ? tlsKeyVault.outputs.keyVaultName : ''
    accessPoliciesAdd: [
      {
        objectId: ((subscriptionType == 'cnty') && deployFirewallTlsPrerequisites) ? tlsManagedIdentity.outputs.userManagedIdentityPrincipalId : ''
        permissions: parentModuleConfig.tlsAccessPolicies
      }
    ]
  }
}

// Creates virtual wan and it's child resources.

module virtualWan '../../childModules/virtualWan/virtualWan.bicep' = if ((subscriptionType == 'cnty')) {
  scope: virtualWanResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-virtualWan-deployment'
  params: {
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    azFirewallName: firewallName
    azFirewallPolicyName: (virtualWanHubs[0].azFirewallPolicySku == 'Premium') ? firewallPolicyNamePremium : firewallPolicyName
    disableVpnEncryption: disableVpnEncryption
    location: location
    tags: tags
    virtualHubRoutingIntentName: virtualWanHubRoutingIntentName
    virtualWanEnabled: virtualWanEnabled
    virtualWanExpressRouteGatewayName: virtualWanExpressRouteGatewayName
    virtualWanHubName: virtualWanHubName
    virtualWanHubs: virtualWanHubs
    virtualWanName: virtualWanName
    virtualWanType: virtualWanType
    virtualWanVpnGatewayName: virtualWanVpnGatewayName
    virtualHubRouteTableLabels: virtualHubRouteTableLabels
    firewallUserIdentity: firewallUserIdentity
    tlsKeyVaultCertId: tlsKeyVaultCertId
    tlsKeyVaultName: tlsKeyVaultName
  }
}

// Only a vnet connection from Hub to Spoke needs to be created. Not needed both ways like in traditional vnet peering - https://learn.microsoft.com/en-us/azure/virtual-wan/howto-connect-vnet-hub
// Other considerations:
// Before you create a virtual network connection, be aware of the following:
// - A virtual network can only be connected to one virtual hub at a time.
// - In order to connect it to a virtual hub, the remote virtual network can't have a gateway.
// - If VPN gateways are present in the virtual hub, this operation as well as any other write operation on the connected VNet can cause disconnection to Point-to-site clients as well as reconnection of site-to-site tunnels and BGP sessions.
module hubToLndzVirtualNetworkConnection '../../childModules/virtualWanHubNetworkConnection/virtualWanHubNetworkConnection.bicep' = {
  name: '${uniqueDeployPrefix}-${subscriptionType}-hubToLndzVirtualNetworkConnection-deployment'
  scope: resourceGroup(cntySubscriptionId, virtualWanResourceGroupName)
  dependsOn: [
    virtualNetwork
    virtualWan
  ]
  params: {
    allowHubToRemoteVnetTransit: allowHubToRemoteVnetTransit
    allowRemoteVnetToUseHubVnetGateways: allowRemoteVnetToUseHubVnetGateways
    enableInternetSecurity: enableInternetSecurity
    hubToLndzVirtualNetworkConnectionName: '${virtualWanHubName}/${virtualNetwork.outputs.virtualNetworkName}'
    remoteVirtualNetworkId: virtualNetwork.outputs.virtualNetworkResourceId
  } }
