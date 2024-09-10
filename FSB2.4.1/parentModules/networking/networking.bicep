/*
SUMMARY: Networking solution
DESCRIPTION: Parent module to deploy the networking components for Connectivity and Landing Zone subscriptions.             
AUTHOR/S: frederic.trapet@eviden.com, marcin.gala@eviden.com
VERSION: 0.0.8
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

@description('A mapping of additional tags to assign to the resource.')
param additionalNetworkingTags object = {}

@description('Specifies if DDoS protection is to be deployed.')
param deployDdos bool = false

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

@description('Deploy and Enable VPN Gateway.')
param deployVpnGateway bool = false

@description('Specifies the configuration values for the VPN Gateway Public IP.')
param vpnGatewayIpconfig object = {}

@description('Specifies the configuration values for the VPN Gateway.')
param vpnGatewayConfig object = {}

@description('Deploy and Enable Azure Bastion Host.')
param deployBastionHost bool = false

@description('Specifies the configuration values for the Bastion host Public IP.')
param bastionHostIpConfig object = {}

@description('Specifies the configuration values for the Bastion host.')
param bastionHostConfig object = {}


@description('Specify the Connectivity Subscription ID')
param cntySubscriptionId string = ''

@description('Spoke peering configuration')
param spokePeeringConfig object = {}

@description('Hub peering configuration')
param hubPeeringConfig object = {}

@description('Switch to deploy Private DNS Zone (true or false)')
param deployPrivateDnsZone bool = false

@description('Switch to deploy Private DNS Zone Virtual Network Link (true or false)')
param deployHubPrivateDnsVirtualNetworkLink bool = false

@description('Switch to deploy Private DNS Zone Virtual Network Link (true or false)')
param deploySpokePrivateDnsVirtualNetworkLink bool = false

@description('Switch to Enable Private DNS Auto registration (true of false)')
param enableHubPrivateDnsZoneAutoRegistration bool = false

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

var namingData = namingJsonData[subscriptionType].definition

var parentModuleConfig = loadJsonContent('parentModuleConfig.json')

// Variables to set the desired resourcegroup names depending on subscription type
var resourceGroupNameHub = namingData.hubResourceGroup.name
var resourceGroupNameSpoke = namingData.spokeResourceGroup.name
var networkingResourceGroupName = (subscriptionType == 'cnty') ? resourceGroupNameHub : resourceGroupNameSpoke

// Variable to set the desired route table name depending on subscription type
var routeTableName = (subscriptionType == 'cnty') ? namingData.connectivityHubRouteTable.name : namingData.connectivitySpokeRouteTable.name

// Variable to set the desired DDos Plan name depending on subscription type
var ddosPlanName = namingData.connectivityDdosPlanName.name

// Variable to set the desired virtual network name depending on subscription type
var virtualNetworkName = (subscriptionType == 'cnty') ? namingData.connectivityHubNetworkVnet.name : namingData.connectivitySpokeVnet.name

// Variables to set the desired names for connectivity virtual network & resource group name
// Used by virtual network peering. The dynamic 'virtualNetworkName' variable cannot be used.
var hubVirtualNetworkName = namingJsonData.cnty.definition.connectivityHubNetworkVnet.name
var hubVirtualNetworkResourceGroupName = namingJsonData.cnty.definition.hubResourceGroup.name
var spokeVirtualNetworkName = (subscriptionType == 'tool') ? namingJsonData.tool.definition.connectivitySpokeVnet.name : namingJsonData.lndz.definition.connectivitySpokeVnet.name
var spokeVirtualNetworkResourceGroupName = (subscriptionType == 'tool') ? namingJsonData.tool.definition.spokeResourceGroup.name : namingJsonData.lndz.definition.spokeResourceGroup.name
var hubVirtualNetworkPeeringName = legacyNaming ? '${hubVirtualNetworkName}/peering-to-spoke-${spokeVirtualNetworkName}' : '${hubVirtualNetworkName}/peering-to-${spokeVirtualNetworkName}'
var spokeVirtualNetworkPeeringName = legacyNaming ? '${spokeVirtualNetworkName}/peering-to-Hub-${hubVirtualNetworkName}' : '${spokeVirtualNetworkName}/peering-to-${hubVirtualNetworkName}'

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

// Variables to set the desired related vpnGateway names depending on subscription type
var vpnGatewayPublicIpName = namingData.connectivityHubVnetGatewayPip.name
var vpnGatewayName = namingData.connectivityHubVnetGateway.name

// Variables to set the desired related bastionHost names depending on subscription type
// To prevent issues with template validation of this parentmodule when there are identical resourcegroups used in different subscriptions, resourcegroupnames get a unique (dummy) name 
// in the case the resourcegroup will not be created (for the subscriptiontype that passed as a parameter to this parentmodule).
var bastionHostNetworkResourceGroupName = (subscriptionType == 'cnty') ? namingData.connectivityHubBastionResourceGroup.name : uniqueString(subscription().id, namingData.connectivityHubBastionResourceGroup.name) 
var bastionHostPublicIpName = namingData.connectivityHubBastionPip.name
var bastionHostName = namingData.connectivityHubBastion.name


// Variable which contains a unique value based on subscriptionId & deployment location
// used to deploy the child modules on subscription level.
#disable-next-line no-loc-expr-outside-params
var uniqueDeployPrefix = take(uniqueString(subscription().subscriptionId, deployment().location), 6)

//Variables to load from the naming convention files for branding, tagging and resource naming.
var tagPrefix = namingData.tagPrefix.name
var tagValuePrefix = namingData.tagValuePrefix.name
var tags = union(additionalNetworkingTags,{ '${tagPrefix}Managed': 'true' }, { '${tagPrefix}Purpose': (subscriptionType == 'cnty') ? '${tagValuePrefix}NetworkingHub' : '${tagValuePrefix}NetworkingSpoke' })

// filter subnets array if deployBastionHost is false
var filter = [for (subnet, i) in subnets: (!((deployBastionHost == false) && (subnet.name == 'AzureBastionSubnet'))) ? subnet : []]
var filteredSubnets = intersection(filter, subnets)

// RESOURCE DEPLOYMENTS

// Create a resource group to hold the Networking resources.
resource networkingResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: networkingResourceGroupName
  location: location
  tags: tags
}

// Create a resource group to hold the bastionHost resources.
resource bastionHostNetworkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if ((subscriptionType == 'cnty') && deployBastionHost) {
  name: bastionHostNetworkResourceGroupName
  location: location
  tags: tags
} 

// Deploy Route Table
module routeTable '../../childModules/routeTable/routeTable.bicep' = if ((subscriptionType == 'lndz') || (subscriptionType == 'tool') || ((subscriptionType == 'cnty') && deployVpnGateway)) {
  scope: networkingResourceGroup
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
  scope: networkingResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-ddosPlan-deployment'
  params: {
    name: ddosPlanName
    location: location
    tags: tags
  }
}

// Deploy Virtual Network
module virtualNetwork '../../childModules/virtualNetwork/virtualNetwork.bicep' = {
  scope: networkingResourceGroup
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
    subnets: [for subnet in filteredSubnets: ((subscriptionType == 'lndz') || (subscriptionType == 'tool') || ((subscriptionType == 'cnty') && deployVpnGateway && (contains(toLower(subnet.name), 'gatewaysubnet')))) ? union(subnet, {routeTable: routeTable.outputs.routeTableResourceId}) : union(subnet, {routeTable: null}) ]
  }
}

module tlsManagedIdentity '../../childModules/managedIdentity/managedIdentity.bicep' = if ((subscriptionType == 'cnty') && deployFirewallTlsPrerequisites ) {
  scope: networkingResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-tlsManagedIdentity-deployment'
  params: {
    userManagedIdentityName: tlsUserManagedIdentityName
    location: location
    tags: tags
  }
}

// Deploy KeyVault required by TLS inspection

module tlsKeyVault '../../childModules/keyVault/keyVault.bicep' = if ((subscriptionType == 'cnty') && deployFirewallTlsPrerequisites ) {
  scope: networkingResourceGroup
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

module tlsKeyVaultAccessPolicies '../../childModules/keyVaultAccessPolicy/keyVaultAccessPolicy.bicep' = if ((subscriptionType == 'cnty') && deployFirewallTlsPrerequisites ) {
  scope: networkingResourceGroup
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

// Deploy Public IP for Gateway
module vpnGatewayPublicIpAddress '../../childModules/publicIp/publicIp.bicep' = if ((subscriptionType == 'cnty') && deployVpnGateway) {
  scope: networkingResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-publicIpAddressVPN-deployment'
  params: {
    name: vpnGatewayPublicIpName
    location: location
    tags: tags
    skuName: vpnGatewayIpconfig.skuName
    skuTier: vpnGatewayIpconfig.skuTier
    zones: vpnGatewayIpconfig.zones
    idleTimeoutInMinutes: vpnGatewayIpconfig.idleTimeoutInMinutes
    publicIpAddressVersion: vpnGatewayIpconfig.publicIpAddressVersion
    publicIpAllocationMethod: vpnGatewayIpconfig.publicIpAllocationMethod
  }
}

// Deploy Public IP for bastionHost
module bastionHostPublicIpAddress '../../childModules/publicIp/publicIp.bicep' = if ((subscriptionType == 'cnty') && deployBastionHost) {
  scope: bastionHostNetworkResourceGroup
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

// Deploy Virtual Network Gateway
module virtualNetworkGateway '../../childModules/virtualNetworkGateway/virtualNetworkGateway.bicep' = if ((subscriptionType == 'cnty') && deployVpnGateway) {
  scope: networkingResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-vpnGateway-deployment'
  params: {
    name: vpnGatewayName
    location: location
    tags: tags
    sku: vpnGatewayConfig.sku
    gatewayType: vpnGatewayConfig.gatewayType
    privateIPAllocationMethod: vpnGatewayIpconfig.privateIPAllocationMethod
    publicIpName: vpnGatewayPublicIpName
    virtualNetworkName: virtualNetworkName
    vpnGatewayGeneration: vpnGatewayConfig.vpnGatewayGeneration
    vpnType: vpnGatewayConfig.vpnType
  }
  dependsOn: [
    virtualNetwork
    vpnGatewayPublicIpAddress
  ]
}

// Deploy bastionHost
module bastionHost '../../childModules/bastionHost/bastionHost.bicep' = if ((subscriptionType == 'cnty') && deployBastionHost) {
  scope: bastionHostNetworkResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-bastionHost-deployment'
  params: {
    bastionHostName: bastionHostName
    location: location
    tags: tags
    sku: bastionHostConfig.sku
    enableFileCopy: bastionHostConfig.enableFileCopy
    scaleUnits: bastionHostConfig.scaleUnits
    enableShareableLink: bastionHostConfig.enableShareableLink
    publicIpName: bastionHostPublicIpName //bastionHostPublicIpAddress.outputs.publicIpAddressResourceId
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

// Deploy Landing Zone Peering
module virtualNetworkPeeringLndz '../../childModules/virtualNetworkPeering/virtualNetworkPeering.bicep' = if ((subscriptionType == 'lndz') || (subscriptionType == 'tool')) { // peering will done bothyways, only when the deployment will be scoped for landing zone
  scope: networkingResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-peeringLndz-deployment'
  params: {
    remoteVirtualNetworkName: hubVirtualNetworkName
    remoteVirtualNetworkResourceGroupName: hubVirtualNetworkResourceGroupName
    remotePeeringSubscriptionId: cntySubscriptionId
    allowForwardedTraffic: spokePeeringConfig.allowForwardedTraffic
    allowGatewayTransit: spokePeeringConfig.allowGatewayTransit
    allowVirtualNetworkAccess: spokePeeringConfig.allowVirtualNetworkAccess
    useRemoteGateways: spokePeeringConfig.useRemoteGateways
    peeringName: spokeVirtualNetworkPeeringName
  }
  dependsOn: [
    virtualNetwork
  ]
}

// Deploy Hub Peering
//Peering will done bothyways, only when the deployment will be scoped for landing zone
module networkingVirtualNetworkPeeringHub '../../childModules/virtualNetworkPeering/virtualNetworkPeering.bicep' = if ((subscriptionType == 'lndz') || (subscriptionType == 'tool')) { 
  scope: resourceGroup(cntySubscriptionId, hubVirtualNetworkResourceGroupName) //scope for Hub Resource Group to perform the peering from Connectivity side
  name: '${uniqueDeployPrefix}-${subscriptionType}-peeringHub-deployment'
  params: {
    remoteVirtualNetworkName: spokeVirtualNetworkName
    remoteVirtualNetworkResourceGroupName: spokeVirtualNetworkResourceGroupName
    remotePeeringSubscriptionId: subscription().subscriptionId
    allowForwardedTraffic: hubPeeringConfig.allowForwardedTraffic
    allowGatewayTransit: hubPeeringConfig.allowGatewayTransit
    allowVirtualNetworkAccess: hubPeeringConfig.allowVirtualNetworkAccess
    useRemoteGateways: hubPeeringConfig.useRemoteGateways
    peeringName: hubVirtualNetworkPeeringName
  }
  dependsOn: [
    virtualNetwork
    virtualNetworkPeeringLndz
  ]
}

// Deploy Private DNS Zone
module privateDnsZone '../../childModules/privateDnsZone/privateDnsZone.bicep' = if ((subscriptionType == 'cnty') && deployPrivateDnsZone) { // Private DNS will be deployed only in Connectivity
  scope: networkingResourceGroup
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

// Deploy Virtual Network Links to the deployed Private DNS Zone
// Virtual Network link between the Hub vNet and the Private DNS Zone in Hub
module privateDnsZoneVirtualNetworkLinkHub '../../childModules/privateDnsZoneVirtualNetworkLink/privateDnsZoneVirtualNetworkLink.bicep' = if ((subscriptionType == 'cnty') && deployHubPrivateDnsVirtualNetworkLink) {
  scope: networkingResourceGroup
  name: '${uniqueDeployPrefix}-${subscriptionType}-virtualNetworkLinkHub-deployment'
  params: {
    privateDnsZoneName: ((subscriptionType == 'cnty') && deployPrivateDnsZone) ? (privateDnsZone.outputs.privateDNSZoneName) : privateDnsZoneName
    name: privateDnsZoneVirtualNetworkLinkName
    tags: tags
    registrationEnabled: enableHubPrivateDnsZoneAutoRegistration
    virtualNetworkId: virtualNetwork.outputs.virtualNetworkResourceId
  }
}

// Virtual Network link between the Spoke vNet and the Private DNS Zone in Hub
module privateDnsZoneVirtualNetworkLinkSpoke '../../childModules/privateDnsZoneVirtualNetworkLink/privateDnsZoneVirtualNetworkLink.bicep' = if (((subscriptionType == 'lndz') || (subscriptionType == 'tool')) && deploySpokePrivateDnsVirtualNetworkLink) {
  scope: resourceGroup(cntySubscriptionId, hubVirtualNetworkResourceGroupName) // As the deployment is done in Lndz, the scope needs to be changed for CNTY where the Private DNS Zone resides
  name: '${uniqueDeployPrefix}-${subscriptionType}-virtualNetworkLinkSpoke-deployment'
  params: {
    privateDnsZoneName: privateDnsZoneName
    name: privateDnsZoneVirtualNetworkLinkName
    tags: tags
    registrationEnabled: enableSpokePrivateDnsZoneAutoRegistration
    virtualNetworkId: virtualNetwork.outputs.virtualNetworkResourceId
  }
}

// OUTPUTS
// None
