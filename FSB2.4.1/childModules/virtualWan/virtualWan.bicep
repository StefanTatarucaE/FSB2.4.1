/*
SUMMARY: Deployment of virtual wan.
DESCRIPTION: Deploy a virtual wan and child resources to the desired Azure region.
AUTHOR/S: marcin.gala@eviden.com
VERSION: 0.0.1
*/

// PARAMETERS

@description('Azure Region to which resources will be deployed.')
param location string

@description('Specifies if branch to branch traffic is allowed on the Virtual Wan.')
param allowBranchToBranchTraffic bool

@description('Specifies if Vnet to Vnet traffic is allowed on the Virtual Wan.')
param allowVnetToVnetTraffic bool

@description('Specifies whether Vpn encryption should be disabled for the Virtual Wan or not.')
param disableVpnEncryption bool

@description('Specifies the type of the VirtualWAN which can be either "Standard" or "Basic".')
@allowed([
  'Standard'
  'Basic'
])
param virtualWanType string

@description('Specifies Virtual Wan Name.')
param virtualWanName string

@description('Specifies whether Virtual Wan is enabled or disabled.')
param virtualWanEnabled bool

@description('Specifies mapping of tags.')
param tags object

@description('Specifies name used for Virtual WAN Hub.')
param virtualWanHubName string

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
- `virtualHubRouteTableRouteNextHopType` - The next hop type for the route ("ResourceId").
''')
param virtualWanHubs array

@description('List of labels associated with the route table. Default label is "default".')
param virtualHubRouteTableLabels string = 'default'

@description('Name for the virtual Hub Routing Intent. The value is passed as a variable into the parent module, which generates a name based on naming module.')
param virtualHubRoutingIntentName string

@description('Name for the Virtual Hub Azure Firewall. The value is passed as a variable into the parent module, which generates a name based on naming module.')
param azFirewallName string

@description('Name for the Virtual Hub ExpressRoute Gateway. The value is passed as a variable into the parent module, which generates a name based on naming module.')
param virtualWanExpressRouteGatewayName string

@description('Name for the Virtual Hub VPN Gateway. The value is passed as a variable into the parent module, which generates a name based on naming module.')
param virtualWanVpnGatewayName string

@description('ID of the User Managed Identity for the TLS Inspection.')
param firewallUserIdentity string = ''

@description('KeyVault Name for TLS Inspection.')
param tlsKeyVaultName string

@description('Secret ID of the Certificate for TLS Inspection.')
param tlsKeyVaultCertId string

@description('Name for the Azure Firewall Policy. The value doesn`t matter as it`s passed as a variable into the parent module, which generates a name based on the helper (naming) module.')
param azFirewallPolicyName string

// VARIABLES

var tlsUserIdentity = {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '${firewallUserIdentity}': {}
  }
}

var tlsConfig = {
  certificateAuthority: {
    name: tlsKeyVaultName
    keyVaultSecretId: tlsKeyVaultCertId
  }
}

// RESOURCES DEPLOYMENT

// Virtual Wan
resource virtualWan 'Microsoft.Network/virtualWans@2023-02-01' = if (virtualWanEnabled) {
  name: virtualWanName
  location: location
  tags: tags
  properties: {
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    disableVpnEncryption: disableVpnEncryption
    type: virtualWanType
  }
}

// Virtual Hub
resource virtualHub 'Microsoft.Network/virtualHubs@2023-02-01' = [for i in range(0, length(virtualWanHubs)): if (virtualWanHubs[i].virtualHubEnabled) {
  name: '${virtualWanHubName}${i == i ? '' : ''}'
  location: virtualWanHubs[i].location
  tags: tags
  properties: {
    addressPrefix: virtualWanHubs[i].virtualHubAddressPrefix
    sku: virtualWanHubs[i].virtualHubSku
    virtualRouterAutoScaleConfiguration: {
      minCapacity: virtualWanHubs[i].virtualRouterAutoScaleConfiguration
    }
    hubRoutingPreference: virtualWanHubs[i].hubRoutingPreference
    virtualWan: {
      id: virtualWan.id
    }
  }
}]

// Virtual Hub Route Table
resource virtualHubRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2023-02-01' = [for i in range(0, length(virtualWanHubs)): if (virtualWanHubs[i].virtualHubEnabled && empty(virtualWanHubs[i].virtualHubRoutingIntentDestinations)) {
  parent: virtualHub[i]
  name: 'defaultRouteTable'
  // default route table is used by default by routing intent and vnet connections route associations, so we are modifying the existing route table rather than creating a new one as there's no need for a new one.
  properties: {
    labels: [
      virtualHubRouteTableLabels
    ]
    routes: [
      {
        name: virtualWanHubs[i].virtualHubRouteTableRouteName
        destinationType: virtualWanHubs[i].virtualHubRouteTableDestinationType
        destinations: virtualWanHubs[i].virtualHubRouteTableRouteDestinations
        nextHop: virtualHubFirewall[i].id
        nextHopType: virtualWanHubs[i].virtualHubRouteTableRouteNextHopType
      }
    ]
  }
}]

// Routing intent can only be configured on hubs where there are no custom route tables and no static routes in the defaultRouteTable with next hop Virtual Network Connection. Also Routing intent with routing policies only works in secured virtual hub scenario - https://learn.microsoft.com/en-us/azure/virtual-wan/how-to-routing-policies.
resource virtualHubRoutingIntent 'Microsoft.Network/virtualHubs/routingIntent@2023-04-01' = [for i in range(0, length(virtualWanHubs)): if (virtualWanHubs[i].virtualHubEnabled && virtualWanHubs[i].azFirewallEnabled && !empty(virtualWanHubs[i].virtualHubRoutingIntentDestinations)) {
  parent: virtualHub[i]
  name: '${virtualHubRoutingIntentName}${i == i ? '' : ''}'
  properties: {
    routingPolicies: [for destination in virtualWanHubs[i].virtualHubRoutingIntentDestinations: {
      name: destination == 'Internet' ? 'PublicTraffic' : destination == 'PrivateTraffic' ? 'PrivateTraffic' : 'N/A'
      destinations: [
        destination
      ]
      nextHop: virtualHubFirewall[i].id
    }]
  }
}]

// Firewall policy
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-02-01' = [for i in range(0, length(virtualWanHubs)): if (virtualWanHubs[i].virtualHubEnabled && virtualWanHubs[i].azFirewallEnabled) {
  name: '${azFirewallPolicyName}${i == i ? '' : ''}'
  dependsOn: [
    virtualHub
  ]
  location: virtualWanHubs[i].location
  tags: tags
  identity: virtualWanHubs[i].enableTlsInspection == true ? tlsUserIdentity : null
  properties: (virtualWanHubs[i].azFirewallPolicySku == 'Basic') ? {
    sku: {
      tier: virtualWanHubs[i].azFirewallPolicySku
    }
  } : {
    transportSecurity: (virtualWanHubs[i].enableTlsInspection == true) && virtualWanHubs[i].azFirewallPolicySku == 'Premium' ? tlsConfig : null
    threatIntelMode: virtualWanHubs[i].threatIntelMode
    threatIntelWhitelist: (length(virtualWanHubs[i].firewallPolicyWhitelistFqdns.value) > 0 || length(virtualWanHubs[i].firewallPolicyWhitelistIpAddresses.value) > 0) ? {
      fqdns: (length(virtualWanHubs[i].firewallPolicyWhitelistFqdns.value) > 0) ? virtualWanHubs[i].firewallPolicyWhitelistFqdns.value : null
      ipAddresses: (length(virtualWanHubs[i].firewallPolicyWhitelistIpAddresses.value) > 0) ? virtualWanHubs[i].firewallPolicyWhitelistIpAddresses.value : null
    } : null
    intrusionDetection: (virtualWanHubs[i].enableFirewallIntrusionDetection) && contains(virtualWanHubs[i].firewallIntrusionDetection, 'intrusionDetection') ? virtualWanHubs[i].firewallIntrusionDetection.intrusionDetection : null
    dnsSettings: {
      enableProxy: virtualWanHubs[i].azFirewallDnsProxyEnabled ? virtualWanHubs[i].azFirewallDnsProxyEnabled : null
    }
    sku: {
      tier: virtualWanHubs[i].azFirewallPolicySku
    }
  }
}]

// Virtual Hub Firewall
resource virtualHubFirewall 'Microsoft.Network/azureFirewalls@2023-02-01' = [for i in range(0, length(virtualWanHubs)): if (virtualWanHubs[i].virtualHubEnabled && virtualWanHubs[i].azFirewallEnabled) {
  name: '${azFirewallName}${i == i ? '' : ''}'
  dependsOn: [
    virtualHub
    firewallPolicy
  ]
  location: virtualWanHubs[i].location
  tags: tags
  zones: (!empty(virtualWanHubs[i].azFirewallAvailabilityZones) ? virtualWanHubs[i].azFirewallAvailabilityZones : null)
  properties: {
    hubIPAddresses: {
      publicIPs: {
        count: 1 //Required value for vwan
      }
    }
    sku: {
      name: 'AZFW_Hub' //Hardcoded as this is the required SKU name for Vwan
      tier: virtualWanHubs[i].azFirewallTier
    }
    virtualHub: {
      id: virtualHub[i].id
    }
    firewallPolicy: {
      id: firewallPolicy[i].id
    }
  }
}]

// Virtual Hub ExpressRoute Gateway
resource virtualWanExpressRouteGateway 'Microsoft.Network/expressRouteGateways@2023-04-01' = [for i in range(0, length(virtualWanHubs)): if (virtualWanHubs[i].virtualHubEnabled && virtualWanHubs[i].expressRouteGatewayEnabled && virtualWanType == 'Standard') {
  name: '${virtualWanExpressRouteGatewayName}${i == i ? '' : ''}'
  dependsOn: [
    virtualHub
  ]
  location: virtualWanHubs[i].location
  tags: tags
  properties: {
    virtualHub: {
      id: virtualHub[i].id
    }
    autoScaleConfiguration: {
      bounds: {
        min: virtualWanHubs[i].expressRouteGatewayScaleUnit
      }
    }
  }
}]

// Virtual Hub VPN Gateway
resource virtualWanVpnGateway 'Microsoft.Network/vpnGateways@2023-04-01' = [for i in range(0, length(virtualWanHubs)): if (virtualWanHubs[i].virtualHubEnabled && virtualWanHubs[i].vpnGatewayEnabled) {
  name: '${virtualWanVpnGatewayName}${i == i ? '' : ''}'
  dependsOn: [
    virtualHub
  ]
  location: virtualWanHubs[i].location
  tags: tags
  properties: {
    bgpSettings: {
      asn: 65515 // default value, cannot be changed
      bgpPeeringAddress: virtualWanHubs[i].bgpPeeringAddress
      peerWeight: virtualWanHubs[i].peerWeight
    }
    virtualHub: {
      id: virtualHub[i].id
    }
    vpnGatewayScaleUnit: virtualWanHubs[i].VpnGatewayScaleUnit
  }
}]

// OUTPUTS

@description('The name of the Virtual Wan.')
output virtualWanName string = virtualWan.name
@description('The resource ID of the Virtual Wan.')
output virtualWanResourceId string = virtualWan.id

@description('The name of the Virtual Wan Hub.')
output virtualHubName array = [for i in range(0, length(virtualWanHubs)): {
  virtualhubname: virtualHub[i].name
}]
@description('The resource ID of the Virtual Wan Hub.')
output virtualHubId array = [for i in range(0, length(virtualWanHubs)): {
  virtualhubid: virtualHub[i].id
}]

@description('The resource ID of the Route Table.')
output routeTableResourceIds array = [for i in range(0, length(virtualWanHubs)): {
  routetableid: virtualHubRouteTable[i].id
}]
@description('The name of the Routing Intent.')
output virtualHubRoutingIntentName array = [for i in range(0, length(virtualWanHubs)): {
  HubRoutingIntentName: virtualHubRoutingIntent[i].name
}]

@description('The resource ID of the Routing Intent.')
output virtualHubRoutingIntentResourceId array = [for i in range(0, length(virtualWanHubs)): {
  HubRoutingIntentId: virtualHubRoutingIntent[i].id
}]
@description('The Firewall Policy name.')
output firewallPolicyName array = [for i in range(0, length(virtualWanHubs)): {
  firewallPoliciesName: firewallPolicy[i].name
}]
@description('The Firewall Policy Resource Id.')
output firewallPolicyId array = [for i in range(0, length(virtualWanHubs)): {
  firewallPoliciesId: firewallPolicy[i].id
}]
@description('The Hub Firewall name.')
output virtualHubFirewallName array = [for i in range(0, length(virtualWanHubs)): {
  virtualHubFirewallName: virtualHubFirewall[i].name
}]
@description('The Hub Firewall Resource Id.')
output virtualHubFirewallId array = [for i in range(0, length(virtualWanHubs)): {
  virtualHubFirewallId: virtualHubFirewall[i].id
}]
@description('The ER Gateway name.')
output virtualWanExpressRouteGatewayName array = [for i in range(0, length(virtualWanHubs)): {
  virtualWanExpressRouteGatewayName: virtualWanExpressRouteGateway[i].name
}]

@description('The ER Gateway Resource Id.')
output virtualWanExpressRouteGatewayResourceId array = [for i in range(0, length(virtualWanHubs)): {
  virtualWanExpressRouteGatewayResourceId: virtualWanExpressRouteGateway[i].id
}]
@description('The VPN Gateway name.')
output virtualWanVpnGatewayName array = [for i in range(0, length(virtualWanHubs)): {
  virtualWanVpnGatewayName: virtualWanVpnGateway[i].name
}]

@description('The VPN Gateway Resource Id.')
output virtualWanVpnGatewayResourceId array = [for i in range(0, length(virtualWanHubs)): {
  virtualWanVpnGatewayResourceId: virtualWanVpnGateway[i].id
}]
