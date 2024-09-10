# childModules/virtualWan/virtualWan.bicep <!-- omit in toc -->

This Bicep module deploys a Virtual WAN, Virtual Hub and child resources associated to the Virtual Hub.

## Navigation <!-- omit in toc -->

- [Parameters](#parameters)

  - [Required parameters](#required-parameters)
    - [Parameter detail: `virtualWanHubs`](#parameter-detail-virtualwanhubs)
    - [Parameter detail: `virtualHubRoutingIntentDestinations`](#parameter-detail-virtualhubroutingintentdestinations)
    - [Parameter detail: `firewallIntrusionDetection`](#parameter-detail-firewallintrusiondetection)

  - [Optional parameters](#optional-parameters)

  - [Parameter usage: `tags`](#parameter-usage-tags)

- [Outputs](#outputs)

- [Deployment example](#deployment-example)

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Network/virtualWans` | [2023-02-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualwans?pivots=deployment-language-bicep) |
| `Microsoft.Network/virtualHubs` | [2023-02-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualhubs?pivots=deployment-language-bicep) |
| `Microsoft.Network/virtualHubs/hubRouteTables` | [2023-02-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualhubs/hubroutetables?pivots=deployment-language-bicep) |
| `Microsoft.Network/virtualHubs/routingIntent` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualhubs/routingintent?pivots=deployment-language-bicep) |
| `Microsoft.Network/firewallPolicies` | [2023-02-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/firewallpolicies?pivots=deployment-language-bicep) |
| `Microsoft.Network/azureFirewalls` | [2023-02-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/azurefirewalls?pivots=deployment-language-bicep) |
| `Microsoft.Network/expressRouteGateways` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/expressroutegateways?pivots=deployment-language-bicep) |
| `Microsoft.Network/vpnGateways` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2023-04-01/vpngateways?pivots=deployment-language-bicep) |

## Parameters

### Required parameters

|  Name | Type | Description |
| :-- | :-- | :-- |
| `location` | string | Azure Region to which resources will be deployed.|
| `allowBranchToBranchTraffic` | bool | Specifies if branch to branch traffic is allowed on the Virtual Wan. |
| `allowVnetToVnetTraffic` | bool | Specifies if Vnet to Vnet traffic is allowed on the Virtual Wan. |
| `disableVpnEncryption` | bool | Specifies whether Vpn encryption should be disabled for the Virtual Wan or not. |
| `virtualWanType` | string | Specifies the type of the VirtualWAN which can be either "Standard" or "Basic".|
| `virtualWanName` | string | Specifies Virtual Wan Name.|
| `virtualWanEnabled` | bool | Specifies whether Virtual Wan is enabled or disabled.|
| `tags` | object | Specifies mapping of tags.|
| `virtualWanHubName` | string | Specifies name used for Virtual WAN Hub.|
| [`virtualWanHubs`](#parameter-detail-virtualwanhubs) | array | The array is designed to manage the deployment of multiple Virtual WAN Hubs in Azure. Each object within this array is a representation of an individual Virtual WAN Hub configuration. By adding or removing objects, you can control the number of Virtual WAN Hubs you intend to deploy.|
| `virtualHubRouteTableLabels` | string | List of labels associated with the route table. Default label is "default". |
| `virtualHubRoutingIntentName` | string | Name for the virtual Hub Routing Intent. The value doesn't matter as it's passed as a variable into the parent module, which generates a name based on the helper (naming) module. |
| `azFirewallName` | string | Name for the Virtual Hub Azure Firewall. The value doesn't matter as it's passed as a variable into the parent module, which generates a name based on the helper (naming) module. |
| `virtualWanExpressRouteGatewayName` | string | Name for the Virtual Hub ExpressRoute Gateway. The value doesn't matter as it's passed as a variable into the parent module, which generates a name based on the helper (naming) module. |
| `virtualWanVpnGatewayName` | string | Name for the Virtual Hub VPN Gateway. The value doesn't matter as it's passed as a variable into the parent module, which generates a name based on the helper (naming) module.|
| `azFirewallPolicyName` | string | Name for the Azure Firewall Policy. he value doesn't matter as it's passed as a variable into the parent module, which generates a name based on the helper (naming) module. |

#### Parameter detail: `virtualWanHubs`

Array which contains  properties for the virtual hubs.

| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `virtualHubEnabled` | bool | `true` | `[true, false]` | A boolean switch to determine if the Virtual Hub deployment is enabled. |
| `vpnGatewayEnabled` | bool | `false` | `[true, false]` | A boolean switch to determine if VPN Gateway deployment is enabled on the Virtual WAN Hub. |
| `bgpPeeringAddress` | string | | | BGP peering address and identifier for the VPN Gateway. |
| `peerWeight` | int | `5` |  | The weight added to routes learned from this BGP speaker. |
| `VpnGatewayScaleUnit` | int | `1` |  |  Scale unit for the VPN gateway. |
| `expressRouteGatewayEnabled` | bool | `false` | `[true, false]` | A boolean switch for deploying ExpressRoute Gateway on the Virtual WAN Hub. |
| `expressRouteGatewayScaleUnit` | int | `1` | | Minimum number of scale units deployed for ExpressRoute gateway. |
| `azFirewallEnabled` | bool | `true` | [`true, false`] | Switch to enable/disable Azure Firewall deployment on the respective Virtual WAN Hub. |
| `azFirewallTier` | string | `Standard` | [`Basic, Standard, Premium`] | Azure Firewall Tier associated with the Firewall to deploy. |
| `azFirewallAvailabilityZones` | array | [] |  | Availability Zones to deploy the Azure Firewall across. Region must support Availability Zones to use. |
| `azFirewallPolicySku` | string | `Standard` | [`Basic, Standard, Premium`] | Specifies the tier of the Firewall Policy. |
| `azFirewallDnsProxyEnabled` | bool | `true` | [`true, false`] | Enable DNS Proxy on Firewalls attached to the Firewall Policy. |
| `enableFirewallIntrusionDetection` | bool | `false` | [`true, false`] | Specifies if Firewall Intrusion detection is enabled. Goes together with parameter firewallIntrusionDetection. |
| `enableTlsInspection` | bool | `false` | [`true, false`] | Specify if TLS inspection should be enabled. |
| [`firewallIntrusionDetection`](#parameter-detail-firewallintrusiondetection) | object | |  | An object which holds the intrusion detection protection system (IDPS) configuration. |
| `threatIntelMode` | string | `Alert` | [`Alert, Deny, Off`] | Specifies the operation mode for Threat Intelligence. |
| `firewallPolicyWhitelistFqdns` | array | `[]` |  | Specifies an array of FQDNs for the ThreatIntel Allowlist. |
| `firewallPolicyWhitelistIpAddresses` | array | `[]` |  | Specifies an array of IP addresses for the ThreatIntel Allowlist. |
| `virtualHubAddressPrefix` | string | `""` |  | The IP address range in CIDR notation for the vWAN virtual Hub to use. |
| `virtualHubSku` | string | `Standard` | [`Standard, Basic`] | The SKU for the vWAN virtual Hub. |
| `location` | string | `""` | | The Virtual WAN Hub location. |
| `hubRoutingPreference` | string | `ASPath` | `[ASPath, VpnGateway, ExpressRoute]` | The Virtual WAN Hub routing preference. |
| `virtualRouterAutoScaleConfiguration` | int | `2` | `[2, 3, 4, (...), 50]` | The Virtual WAN Hub capacity. |
| [`virtualHubRoutingIntentDestinations`](#parameter-detail-virtualhubroutingintentdestinations)| array | `[]` | `[Internet, PrivateTraffic]` | The Virtual WAN Hub routing intent destinations. Leave an empty array [] if not wanting to enable routing intent, and doing so will deploy and use the virtual hub route table instead. |
| `virtualHubRouteTableRouteName` | string | `default-to-azfw` | | The name of the route table route. |
| `virtualHubRouteTableDestinationType` | string | `CIDR` | `[CIDR, ResourceId, Service]` | The type of destinations for the hub route table route (eg: CIDR, ResourceId, Service). "CIDR" is default. |
| `virtualHubRouteTableRouteDestinations` | array | `[]` | | The list of destinations/address spaces. Example: [ "10.0.0.0/8", "192.168.0.0/16" ]; using  forced tunneling (0.0.0.0/0) is not supported anymore. |
| `virtualHubRouteTableRouteNextHopType` | string | `ResourceId`  | [`ResourceId`] | The next hop type for the route (ResourceId). |

#### Parameter detail: `virtualHubRoutingIntentDestinations`

This property from the virtualWanHubs array is responsible for deciding how routing will be deployed in a virtual hub. Based on the value of this parameter, you will deploy one of the two options below:

A virtual hub route table:

> - Will be deployed if you leave an empty array `[]` as a value for the `virtualHubRoutingIntentDestinations` property. This means that you will not enable routing intent, but instead you will deploy and use the virtual hub route table.

OR

Routing Intent with routing policies:

>- Will be deployed if you populate the value of `virtualHubRoutingIntentDestinations` with either one or both of these options `[Internet, PrivateTraffic]`, it means that you will skip deploying routes into the hub route table, and you will deploy a routing intent instead.

Implications when:

- using a hub route table:
  - This approach gives you granular control over routing as you're defining specific routes (can't use forced tunnelling `0.0.0.0/0` as it's not supported anymore)
  - The defaultRouteTable is the default route table used by Virtual Hub. By using this, we're modifying it, so that any VNets or other connections associated with this hub will use these routes.

- using routing intent with routing policies:
  - This approach lets Azure handle the routing details based on the intent you've defined. Routing Intent simplifies routing by managing route table associations and propagations for all connections (Virtual Network, Site-to-site VPN, Point-to-site VPN and ExpressRoute).
  - The `virtualHubRoutingIntentDestinations` parameter dictates the routing intent and policies. Based on the destinations you define, Azure will automatically route traffic to those destinations using the defined next hop (virtual hub firewall in our case).
  - You can't have custom route tables with routes having the next hop set to Virtual Network Connection when using Routing Intent.

For more information on virtaul hub routing check [MS docs](https://learn.microsoft.com/en-us/azure/virtual-wan/about-virtual-hub-routing).

#### Parameter detail: `firewallIntrusionDetection`

An object which holds the intrusion detection protection system (IDPS) configuration.

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `description` | string | ` ` | Description of the bypass traffic rule. |
| `destinationAddresses` | string[] | `[]` | List of destination IP addresses or ranges for this rule. destinationIpGroups and destinationAddresses are mutually exclusive.|
| `destinationIpGroups` | string[] | `[]` | List of destination IpGroups for this rule. destinationIpGroups and destinationAddresses are mutually exclusive. |
| `destinationPorts` | string[] | `[]` | List of destination ports or ranges.  |
| `name` | string | ` ` | Name of the bypass traffic rule.  |
| `protocol` | string | ` ` | The rule bypass protocol. Possible options are ANY, ICMP, TCP, UDP |
| `sourceAddresses` | string[] | `[]` | List of source IP addresses or ranges for this rule. sourceIpGroups and sourceAddresses are mutually exclusive |
| `sourceIpGroups` | string[] | `[]` | List of source IpGroups for this rule. sourceIpGroups and sourceAddresses are mutually exclusive |
| `privateRanges` | string[] | `[]` | IDPS Private IP address ranges are used to identify traffic direction (i.e. inbound, outbound, etc.). By default, only ranges defined by IANA RFC 1918 are considered private IP addresses. To modify default ranges, specify your Private IP address ranges with this property. |
| `id` | string | ` ` | Signature id of the signature to override.|
| `mode` | string | ` ` | mode as part of signatureOverrides. The signature state. Possible options are Alert, Deny, Off |
| `mode` | string | ` ` | mode as part of intrusionDetection. Intrusion detection general state. Possible options are Alert, Deny, Off |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/firewallpolicies?pivots=deployment-language-bicep).

### Optional parameters

| Name | Type | | | Description |
| :-- | :-- | :-- | :-- | :-- |
| `firewallUserIdentity` | string | | |ID of the User Managed Identity for the TLS Inspection.|
| `tlsKeyVaultName` | string | | | KeyVault Name for TLS Inspection. |
| `tlsKeyVaultCertId` | string | | |Secret ID of the Certificate for TLS Inspection. |

### Parameter usage: `tags`

Tag names and tag values can be provided as needed. A tag can be left without a value.

<details>

<summary>Parameter JSON format</summary>

```json
"tags": {
    "value": {
        "Environment": "Test",
        "Contact": "sample.user@custcompany.net",
        "CostCenter": "8844",
        "ServiceName": "BackendServiceXYZ",
        "Role": "BackendXYZ"
    }
}
```

</details>

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `virtualWanName` | string | The name of the Virtual Wan.|
| `virtualWanResourceId` | string | The resource ID of the Virtual Wan. |
| `virtualHubName` | array | The name of the Virtual Wan Hub. |
| `virtualHubId` | array | The resource ID of the Virtual Wan Hub. |
| `routeTableResourceIds` | array | The resource ID of the Route Table. |
| `virtualHubRoutingIntentName` | array | The name of the Routing Intent. |
| `virtualHubRoutingIntentResourceId` | array | The resource ID of the Routing Intent. |
| `firewallPolicyName` | array | The Firewall Policy name. |
| `firewallPolicyId` | array | The Firewall Policy Resource Id. |
| `virtualHubFirewallName` | array | The Hub Firewall name. |
| `virtualHubFirewallId` | array | The Hub Firewall Resource Id. |
| `virtualWanExpressRouteGatewayName` | array | The ER Gateway name. |
| `virtualWanExpressRouteGatewayResourceId` | array | The ER Gateway Resource Id. |
| `virtualWanVpnGatewayName` | array | The VPN Gateway name. |
| `virtualWanVpnGatewayResourceId` | array | The VPN Gateway Resource Id. |

## Deployment example

<p>
<details>
<summary>via Bicep module</summary>

```bicep
module virtualWan '../../childModules/virtualWan/virtualWan.bicep' = {
  scope: exampleResourceGroup
  name: 'virtualWan-deployment'
  params: {
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
    azFirewallName: 'firewall-wan'
    azFirewallPolicyName: 'firewall-policy'
    disableVpnEncryption: true
    location: 'uksouth'
    tags: {
      Environment: 'Test'
      Contact: 'sample.user@custcompany.net'
      CostCenter: '8844'
      ServiceName: 'BackendServiceXYZ'
      Role: 'BackendXYZ'
    }
    virtualHubRoutingIntentName: 'vhubRoutingIntent'
    virtualWanEnabled: true
    virtualWanExpressRouteGatewayName: 'virtualWanErGateway'
    virtualWanHubName: 'vhub'
    virtualWanHubs: virtualWanHubs
    virtualWanName: 'vwan'
    virtualWanType: 'Standard'
    virtualWanVpnGatewayName: 'virtualWanVpnGateway'
    virtualHubRouteTableLabels: 'default'
    tlsKeyVaultCertId: ''
    tlsKeyVaultName: ''
    firewallUserIdentity: ''
  }
}
```

</details>
</p>