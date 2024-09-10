# Virtual Wan Parent module

This bicep parent module deploys the `network solution` in a `Virtual Wan` topology.

## Table of Content

- [Virtual Wan Parent module](#virtual-wan-parent-module)
  - [Table of Content](#table-of-content)
  - [Description](#description)
    - [Resources deployed in the connectivity subscription (Secured Hub)](#resources-deployed-in-the-connectivity-subscription-secured-hub)
    - [Resources deployed in the landing zone subscription (Spoke)](#resources-deployed-in-the-landing-zone-subscription-spoke)
    - [Naming convention module](#naming-convention-module)
  - [Parent module parameters](#parent-module-parameters)
    - [Required parameters](#required-parameters)
      - [Parameter detail: `virtualWanHubs`](#parameter-detail-virtualwanhubs)
      - [Parameter detail: `virtualHubRoutingIntentDestinations`](#parameter-detail-virtualhubroutingintentdestinations)
      - [Parameter detail: `firewallIntrusionDetection`](#parameter-detail-firewallintrusiondetection)
      - [Parameter detail: `subnets`](#parameter-detail-subnets)
        - [Parameter detail: `securityRules`](#parameter-detail-securityrules)
          - [Parameter detail: `securityRules-properties`](#parameter-detail-securityrules-properties)
        - [Parameter detail: `serviceEndpoints`](#parameter-detail-serviceendpoints)
        - [Parameter detail: `serviceEndpointPolicies`](#parameter-detail-serviceendpointpolicies)
          - [Parameter detail: `ServiceEndpointPolicyPropertiesFormat`](#parameter-detail-serviceendpointpolicypropertiesformat)
          - [Parameter detail: `serviceEndpointPolicyDefinitions`](#parameter-detail-serviceendpointpolicydefinitions)
          - [Parameter detail: `ServiceEndpointPolicyDefinitionPropertiesFormat`](#parameter-detail-serviceendpointpolicydefinitionpropertiesformat)
        - [Parameter detail: `privateEndpointNetworkPolicies`](#parameter-detail-privateendpointnetworkpolicies)
        - [Parameter detail: `privateLinkServiceNetworkPolicies`](#parameter-detail-privatelinkservicenetworkpolicies)
        - [Parameter detail: `ipAllocations`](#parameter-detail-ipallocations)
        - [Parameter detail: `delegations`](#parameter-detail-delegations)
    - [Optional parameters](#optional-parameters)
      - [Parameter detail: `routes`](#parameter-detail-routes)
      - [Parameter detail: `bastionHostIpConfig`](#parameter-detail-bastionhostipconfig)
      - [Parameter detail: `bastionHostConfig`](#parameter-detail-bastionhostconfig)
  - [ELZ Azure Configuration Values](#elz-azure-configuration-values)
    - [Resource names](#resource-names)
  - [Parameter usage examples](#parameter-usage-examples)
    - [Parameter usage: `routes`](#parameter-usage-routes)
    - [Parameter usage: `subnets`](#parameter-usage-subnets)
    - [Parameter usage: `bastionHostIpConfig`](#parameter-usage-bastionhostipconfig)
    - [Parameter usage: `bastionHostConfig`](#parameter-usage-bastionhostconfig)
  - [Parameter File Examples](#parameter-file-examples)
  - [Outputs](#outputs)

## Description

The virtual Wan parent module deploys resources in the following subscriptions:

- Connectivity Subscription (Secured Hub)
- Landing Zone Subscription (Spoke)
- Tooling Enclave Subscription (Spoke)

It calls several child modules in the `childModules` folder to deploy the solution, like:
> ../../childModules/virtualNetwork/virtualNetwork.bicep
> ../../childModules/routeTable/routeTable.bicep
> ../../childModules/ddosProtectionPlan/ddosProtectionPlan.bicep
> ../../childModules/privateDnsZone/privateDnsZone.bicep
> ../../childModules/privateDnsZoneVirtualNetworkLink/privateDnsZoneVirtualNetworkLink.bicep
> ../../childModules/publicIp/publicIp.bicep
> ../../childModules/bastionHost/bastionHost.bicep
> ../../childModules/managedIdentity/managedIdentity.bicep
> ../../childModules/keyVault/keyVault.bicep
> ../../childModules/keyVaultAccessPolicy/keyVaultAccessPolicy.bicep
> ../../childModules/virtualWan/virtualWan.bicep
> ../../childModules/virtualWanHubNetworkConnection/virtualWanHubNetworkConnection.bicep

### Resources deployed in the connectivity subscription (Secured Hub)

- A resource group to hold all virtualwan related resources:
  - virtual wan
  - virtual hub
  - virtual hub route table or routing intent
  - virtual hub firewall policy
  - virtual hub firewall rules (rule collection groups)
  - virtual hub firewall
  - virtual hub Express Route gateway (optional)
  - virtual hub Vpn gateway (optional)

- A resource group to hold all other network related resources:
  - A virtual network that holds:
    - Address space
    - Subnets (1 default subnet & AzureBastionSubnet)
    - network security group for the default subnet
    - IP group for every subnet and its corresponding subnet address range
    - route table
    - Virtual Network Connection (from virtual Hub to this virtual network)
  - DDOS protection plan (optional)
  - private DNS zone with desired record sets (optional)
  - bastion host (optional)

### Resources deployed in the landing zone subscription (Spoke)

- A resource group to hold all networking related resources:
  - A virtual network that holds:
    - Address space
    - Subnet (single default subnet)
    - Virtual Network Connection (from virtual Hub to this virtual network)
    - Network security group
    - IP group for the subnet and its corresponding subnet address range
    - A private DNS zone virtual network link (optional)
    - A route table that is associated with the subnet

### Naming convention module

To ensure & enforce the required naming convention, a naming helper module is used by all other parent modules.
The names being generated by the naming module are the actual resource names which are used on the Azure platform.

The naming helper module is run in `prepare` job of the workflow which is used to deploy ELZ Azure. The output from the module is saved to a file and published as a workflow artifact. In subsequent jobs the artifact is downloaded and used by Bicep parent modules.

The downloaded artifact is referenced by parent modules by declaring a '*Naming' variable. For example: `var mgmtNaming = json(loadTextContent('../../mgmtNaming.json'))`

## Parent module parameters

Inputs are provided using the following parameter files, depending upon where you need the virtualwan related resources deployed:

- cu7.cnty.virtualwan.params.json
- cu7.lnd1.virtualwan.params.json
- cu7.tool.virtualwan.params.json

### Required parameters

| Parameter Name | Type | Description |  |
| :-- | :-- | :-- |:-- |
| `subscriptionType` | `string` |  Specifies which network configuration to deploy using the subscription type abbreviation. Allowed values (mgmt, cnty, lndz, tool) |
| `vnetAddressPrefixes` | `array` |  Specifies the IPv4 addresses in cidr notation (example: `172.16.0.0/16`), for the virtual network. |
| [`subnets`](#parameter-detail-subnets) | `array` |   Specifies an array of subnet objects to be deployed. |
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
| `virtualWanExpressRouteGatewayName` | string | Name for the Virtual Hub ExpressRoute Gateway. The value doesn't matter as it's passed as a variable into the parent module, which generates a name based on the helper (naming) module. |
| `virtualWanVpnGatewayName` | string | Name for the Virtual Hub VPN Gateway. The value doesn't matter as it's passed as a variable into the parent module, which generates a name based on the helper (naming) module.|

#### Parameter detail: `virtualWanHubs`

Array which contains  properties for the virtual hubs.

| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `virtualHubEnabled` | bool | `true` | `[true, false]` | A boolean switch to determine if the Virtual Hub deployment is enabled. |
| `vpnGatewayEnabled` | bool | `false` | `[true, false]` | A boolean switch to determine if VPN Gateway deployment is enabled on the Virtual WAN Hub. |
| `bgpPeeringAddress` | string | | | BGP peering address and identifier for the VPN Gateway. |
| `peerWeight` | int | `5` |  | The weight added to routes learned from this BGP speaker. |
| `VpnGatewayScaleUnit` | int | `1` |  |  Scale unit for the VPN gateway. |
`expressRouteGatewayEnabled` | bool | `false` | `[true, false]` | A boolean switch for deploying ExpressRoute Gateway on the Virtual WAN Hub. Note: if Virtual WAN Hub type is `Basic` - controlled using virtualHubSku variable, Express Route Gateway won't be deployed as Express Route Gateway is not supported in Basic Virtual WAN Hub type |
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
| [`virtualHubRoutingIntentDestinations`](#parameter-detail-virtualhubroutingintentdestinations) | array | `[]` | `[Internet, PrivateTraffic]` | The Virtual WAN Hub routing intent destinations. Leave an empty array [] if not wanting to enable routing intent, and doing so will deploy and use the virtual hub route table instead. More details on how this works can be found below on a separate section for this parameter. |
| `virtualHubRouteTableRouteName` | string | `default-to-azfw` | | The name of the route table route. |
| `virtualHubRouteTableDestinationType` | string | `CIDR` | `[CIDR, ResourceId, Service]` | The type of destinations for the hub route table route (eg: CIDR, ResourceId, Service). "CIDR" is default. |
| `virtualHubRouteTableRouteDestinations` | array | `[]` | | The list of destinations/address spaces. Example: [ "10.0.0.0/8", "192.168.0.0/16" ]; using forced tunneling (0.0.0.0/0) is not supported anymore. |
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
| `description` | string | `` | Description of the bypass traffic rule. |
| `destinationAddresses` | string[] | `[]` | List of destination IP addresses or ranges for this rule. destinationIpGroups and destinationAddresses are mutually exclusive.|
| `destinationIpGroups` | string[] | `[]` | List of destination IpGroups for this rule. destinationIpGroups and destinationAddresses are mutually exclusive. |
| `destinationPorts` | string[] | `[]` | List of destination ports or ranges.  |
| `name` | string | `` | Name of the bypass traffic rule.  |
| `protocol` | string | `` | The rule bypass protocol. Possible options are ANY, ICMP, TCP, UDP |
| `sourceAddresses` | string[] | `[]` | List of source IP addresses or ranges for this rule. sourceIpGroups and sourceAddresses are mutually exclusive |
| `sourceIpGroups` | string[] | `[]` | List of source IpGroups for this rule. sourceIpGroups and sourceAddresses are mutually exclusive |
| `privateRanges` | string[] | `[]` | IDPS Private IP address ranges are used to identify traffic direction (i.e. inbound, outbound, etc.). By default, only ranges defined by IANA RFC 1918 are considered private IP addresses. To modify default ranges, specify your Private IP address ranges with this property. |
| `id` | string | `` | Signature id of the signature to override.|
| `mode` | string | `` | mode as part of signatureOverrides. The signature state. Possible options are Alert, Deny, Off |
| `mode` | string | `` | mode as part of intrusionDetection. Intrusion detection general state. Possible options are Alert, Deny, Off |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/firewallpolicies?pivots=deployment-language-bicep).

#### Parameter detail: `subnets`

An array of subnet objects to be deployed to the virtual network.

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `name` | `string` |  | The last part of a subnet name, that will be appended to the subnet name coming from naming convention. |
| `addressPrefix` | `array`|  | The subnet IPv4 address range in CIDR notation for a subnet. |
| `useNamingConventionModule` | `bool` | `true` | Explanation provided in [Resource names](#resource-names) section. |
| [`securityRules`](#parameter-detail-securityrules) | `array` | `[]` | Specifies an array of network security rule objects for the network security group that will be deployed per subnet. |
| [`serviceEndpoints`](#parameter-detail-serviceendpoints) | `array` | `[]` | Specifies an array of service endpoints. |
| [`serviceEndpointPolicies`](#parameter-detail-serviceendpointpolicies) | `array`  | `[]` | Specifies an array of service endpoint policies. Note that right now, Microsoft.Storage is the only service that is available for endpoint policies. |
| [`privateEndpointNetworkPolicies`](#parameter-detail-privateendpointnetworkpolicies) | `string`  | `Disabled` | Enable or Disable apply network policies on private end point in the subnet. Possible values are `Enabled` or `Disabled`. |
| [`privateLinkServiceNetworkPolicies`](#parameter-detail-privatelinkservicenetworkpolicies) | `string`  | `Disabled` | Enable or Disable apply network policies on private link service in the subnet. Possible values are `Enabled` or `Disabled`. |
| [`ipAllocations`](#parameter-detail-ipallocations) | `array`  | `[]` | Array of IpAllocation which reference this subnet. |
| [`delegations`](#parameter-detail-delegations) | `array`  | `[]` | An array of delegations which reference this subnet. For easy identification of the structure, the Export template can be used from the Azure Portal |

##### Parameter detail: `securityRules`

An array of Security Rules to deploy to the Network Security Group (NSG) as part of the `subnets` object. When not provided, no NSG will be deployed.

> **NOTE**
> If you choose to use an `NSG with your Azure Bastion` resource, you must create all of the ingress and egress traffic rules detailed in the Microsoft [document](https://learn.microsoft.com/en-us/azure/bastion/bastion-nsg). Omitting any of these rules will block your Azure Bastion resource from receiving necessary updates in the future and therefore open up your resource to future security vulnerabilities.
> Examples provided in the input parameter file for connectivity subscription and in this readme.

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `name` | `string` |  | The name of the security rule. |
| [`properties`](#parameter-detail-securityrules-properties) | `object` | `{}` | Properties of the security rule.. |

###### Parameter detail: `securityRules-properties`

Overview of the `properties` object within the `securityRules` parameter.

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `protocol` | `string` | | Network protocol this rule applies to. |
| `sourcePortRange` | `string` | | The source port or range. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports. |
| `sourcePortRanges` | `string[]` | `[]` | The source port ranges. |
| `destinationPortRange` | `string` | | The destination port or range. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports. |
| `destinationPortRanges` | `string[]` | `[]`| The destination port ranges. |
| `sourceAddressPrefix` | `string` | | The CIDR or source IP range. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used. If this is an ingress rule, specifies where network traffic originates from. |
| `sourceAddressPrefixes` | `string[]` | `[]`| The CIDR or source IP ranges. |
| `destinationAddressPrefix` | `string` | | The destination address prefix. CIDR or destination IP range. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used. |
| `destinationAddressPrefixes` | `string[]` | `[]`| The destination address prefixes. CIDR or destination IP ranges. |
| `access` | `string` | | Whether network traffic is allowed or denied. |
| `priority` | `int` |  | The priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule. |
| `direction` | `string` | | The direction of the rule (inbound\outbound). The direction specifies if rule will be evaluated on incoming or outgoing traffic. |

##### Parameter detail: `serviceEndpoints`

An array of Service Endpoints to deploy to the virtual network's subnet as part of the `subnets` object. When not provided, no service endpoints will be deployed. Not provinding service endpoints for a vnet that has service endpoints configured will result in removing the policies for the subnet.

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `location` | `string[]` | `[]` | A list of locations. |
| `service` | `string` |  | The type of the endpoint service. |

##### Parameter detail: `serviceEndpointPolicies`

An array of Service Endpoints Policies to deploy to the virtual network's subnet as part of the `subnets` object. When not provided, no service endpoint policies will be deployed. Not provinding service endpoint policies for a subnet that has service endpoint policies configured will result in removing the service endpoints for the subnet.

> NOTE:
> Right now, Microsoft.Storage is the only service that is available for endpoint policies.
> By default, if no policies are attached to a subnet with storage endpoint, you can access all storage accounts in the service.
> Once a policy is configured, only the resources specified in the policy can be accessed from compute instances in that subnet. Access to all other storage accounts will be denied.

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `id` | `string` |  | Resource ID of service endpoint policy.|
| `location` | `string` |  | Resource location. |
| `tags` | `object` | `{}` | Resource tags. |
| [`properties`](#parameter-detail-serviceendpointpolicypropertiesformat) | `object`  | `{}` | Properties of the service end point policy. (`ServiceEndpointPolicyPropertiesFormat`) |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#serviceendpointpolicy).
For additional information on service endpoint policies you may refer this Microsoft [documentation](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoint-policies-overview)

###### Parameter detail: `ServiceEndpointPolicyPropertiesFormat`

Overview of the `properties` object within the `serviceEndpointPolicies` parameter.

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `contextualServiceEndpointPolicies` | `string[]` | `[]` | A collection of contextual service endpoint policy. |
| `serviceAlias` | `string` |  | The alias indicating if the policy belongs to a service. Support for aliases on service endpoint policies to allow whitelisting of resources required for certain P/SaaS offerings. |
| [`serviceEndpointPolicyDefinitions`](#parameter-detail-serviceendpointpolicydefinitions) | `array`  | `[]` | A collection of service endpoint policy definitions of the service endpoint policy. (`serviceEndpointPolicyDefinitions`) |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#serviceendpointpolicypropertiesformat).

###### Parameter detail: `serviceEndpointPolicyDefinitions`

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `id` | `string` |  | Resource ID of the policy definition. |
| `name` | `string` |  | The name of the resource that is unique within a resource group. This name can be used to access the resource. |
| [`properties`](#parameter-detail-serviceendpointpolicydefinitionpropertiesformat) | `object`  | `{}` | Properties of the service end point policy. (`ServiceEndpointPolicyDefinitionPropertiesFormat`) |
| `type` | `string` |  | The type of the resource. |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#serviceendpointpolicydefinition).

###### Parameter detail: `ServiceEndpointPolicyDefinitionPropertiesFormat`

Overview of the `properties` object within the `ServiceEndpointPolicyDefinition` parameter.

| Parameter Name | Type | Default Values | Description |
| :-- | :-- | :-- | :-- |
| `description` | `string` |  | A description for this rule. Restricted to 140 chars. |
| `service` | `string` |  | Service endpoint name. |
| `serviceResources` | `string[]` | `[]` | A list of service resources. |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#serviceendpointpolicydefinitionpropertiesformat).

##### Parameter detail: `privateEndpointNetworkPolicies`

| Parameter Name | Type | Default Values | Description |
| :-- | :-- | :-- | :-- |
| `privateEndpointNetworkPolicies` | `string`  | `Disabled` | Enable or Disable apply network policies on private end point in the subnet. Possible values are `Enabled` or `Disabled`.

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#subnetpropertiesformat).

##### Parameter detail: `privateLinkServiceNetworkPolicies`

| Parameter Name | Type | Default Values | Description |
| :-- | :-- | :-- | :-- |
| `privateLinkServiceNetworkPolicies`| `string`  | `Disabled` | Enable or Disable apply network policies on private link service in the subnet. Possible values are `Enabled` or `Disabled`. |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#subnetpropertiesformat).

##### Parameter detail: `ipAllocations`

| Parameter Name | Type | Default Values | Description |
| :-- | :-- | :-- | :-- |
| `id` | `string`  |  | Resource ID. |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#subresource).

##### Parameter detail: `delegations`

An array of delegations for the particular subnet.

| Parameter Name | Type | Default Values | Description |
| :-- | :-- | :-- | :-- |
| `name` | `string` |  | Name of the delegated service (i.e. Microsoft.DBforMySQL.flexibleServers) |
| `id` | `string` |  | Resource ID of the subnet that contains the delegated service (i.e. /subscriptions/subscriptionId/resourceGroups/resourceGroupName/providers/Microsoft.Network/virtualNetworks/vNetName/subnets/snetName/delegations/Microsoft.DBforMySQL.felxibleServers) |
| `properties` | `string` |  | The properties contains usually just the serviceName (i.e. "serviceName" : "Microsoft.DBforMySQL/flexibleServers" ). For more detailed info use the Export Template of the virtual network from the Azure Portal |
| `type` | `string` |  | Resource type (i.e. Microsoft.Network/virtualNetwork/subnets/delegations) |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#subresource).

### Optional parameters

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `privateDnsZoneName` | `string` |  | Specifies the private DNS zone name to be deployed. There must be between 2 and 34 labels. For example, "elzprivatedns.com" has 2 labels.| >> WIP
| `deployDdos` | `bool` | `false` | Indicates if DDoS protection is enabled for all the protected resources in the virtual network. It requires a DDoS protection plan associated with the resource.|
| `deployFirewallTlsPrerequisites` | `bool` | `false`| Specifies if the prerequisites for Azure Firewall TLS inspection feature need to be deployed (Managed Identity and Keyvault). Set this to true if you want to deploy these resources. Note that after deployment, you have to manually generate and upload the certificate into the KeyVault. This will not enable TLS inspection, this is only to satisfy the prerequisites for enabling TLS inspection for Azure Firewall  |
| `additionalNetworkingTags` | `object` | `{}` | A mapping of tags to assign to networking related resource group(s) and resource(s). |
| `legacyNaming` | `bool` | `false` | Specify to enable or disable support for legacy names. Set to `true if the environment was\is upgraded to 2.x from a version that was deployed using 1.x version`. Explanation provided in [Resource names](#resource-names) section. |
| `enableVmProtection` | `bool` | `false` | Indicates if VM protection is enabled for all the subnets in the virtual network. |
| `dnsServers` | `array` | `[]` | Specifies the DNS address(es) of the DNS Server(s) used by the virtual network. Use an empty array [] if the default Azure provided DNS should be used. |
| [`routes`](#parameter-detail-routes) | `array` | `[]` | Collection of routes contained within a route table. |
| `disableBgpRoutePropagation` | `bool` | `true` | Whether to disable the routes learned by BGP on that route table. True means disable. This needs to be false if you are using BGP. |
| [`bastionHostIpConfig`](#parameter-detail-bastionhostipconfig) | `object` | `{}` | Specifies the configuration values for the Bastion host Public IP. |
| [`bastionHostConfig`](#parameter-detail-bastionhostconfig) | `object` | `{}` | Specifies the configuration values for the Bastion host. |
| `cntySubscriptionId` | `string` |  | Specify the Connectivity Subscription ID. |
| `deployPrivateDnsZone` | `bool` | `false` | Specifies to enable or disable Private DNS Zone deployment. |
`deploySpokePrivateDnsVirtualNetworkLink` | `bool` | `false` | Specifies to enable or disable linking Landingzone virtual network to Private DNS Zone. |
`enableSpokePrivateDnsZoneAutoRegistration` | `bool` | `false` | Specifies to enable or disable auto registration to Private DNS zone for the Landingzone virtual network. |
| `privateDnsARecordSet` | `array` | `[]` | Specifies the A record set to be deployed.|
| `privateDnsCnameRecordSet` | `array` | `[]` | Specifies the CNAME record set to be deployed.|
| `privateDnsMxRecordSet` | `array` | `[]` | Specifies the MX record set to be deployed.|
| `privateDnsPtrRecordSet` | `array` | `[]` | Specifies the PTR record set to be deployed.|
| `privateDnsSrvRecordSet` | `array` | `[]` | Specifies the SRV record set to be deployed.|
| `privateDnsTxtRecordSet` | `array` | `[]` | Specifies the TXT record set to be deployed.|
| `privateDnsAaaaRecordSet` | `array` | `[]` | Specifies the AAAA record set to be deployed.|

#### Parameter detail: `routes`

An array of route objects to be deployed.

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `name` | string | `DCSDefaultRoute` | The name of the route in the route table. |
| `addressPrefix` | array| `0.0.0.0/0` | The destination IPv4 address in CIDR notation, to which the route applies. |
| `nextHopIpAddress` | array| `<Hub Azure Firewall IPv4 address>` | The IPv4 address, network traffic should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance. |
| `nextHopType` | string | `VirtualAppliance` | The next hop type to where network traffic is forwarded to. Allowed values: `Internet`,`None`,`VirtualAppliance`,`VirtualNetworkGateway`,`VnetLocal`. |

#### Parameter detail: `bastionHostIpConfig`

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `skuName` | `string` | `Standard` | Specifies the SKU type of the Public IP address. Allowed values: `Basic`,`Standard`. |
| `skuTier` | `string` | `Regional` | Specifies the tier of the Public IP address. Allowed values: `Global`,`Regional`. |
| `zones` | `array` | `[]` | Specifies an array with the availability zones for the Public IP address. |
| `idleTimeoutInMinutes` | `int` | `4` | Specifies the idle timeout of the Public IP address. |
| `publicIpAddressVersion` | `string` | `Ipv4` | Specifies the Public IP address version. Allowed values: `IPv4`,`IPv6`. |
| `publicIpAllocationMethod` | `string` | `Static` | Specifies the Public IP address allocation method. Allowed values: `Dynamic`,`Static`. |
| `privateIPAllocationMethod` | `string` | `Dynamic` | Specifies the private IP address allocation method for the Bastion Host. Allowed values: `Dynamic`,`Static`. |

#### Parameter detail: `bastionHostConfig`

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `sku` | `string` | `Basic` | Specifies the sku of the Bastion host. Allowed values: `Basic`,`Standard`. |
| `enableFileCopy` | `bool` | `true` | Enable/Disable File Copy feature of the Bastion Host resource. To enable filecopy, upgrade to Bastion Standard. |
| `scaleUnits` | `int` | 2 | For Basic sku scale units (instance count) is fixed to 2. Bastion scalable host is available with Standard SKU. To add additional VM instances, upgrade to Standard and select the desired instance count. |
| `enableShareableLink` | `bool` | `true` | Shareable Link is not available for the Bastion Basic SKU. To enable the feature, upgrade to Bastion Standard. |
| `disableCopyPaste` | `bool` | `false` | Copy and paste is enabled by default for Bastion Basic sku. To disable copy and paste, upgrade to Bastion Standard. |
| `enableIpConnect` | `bool` | `true` | IP-based connection is not available for the Bastion Basic SKU. To enable the feature, upgrade to Bastion Standard. |
| `enableTunneling` | `bool` | `true` | Enable/Disable Tunneling feature of the Bastion Host resource. To enable the feature, upgrade to Bastion Standard. |

## ELZ Azure Configuration Values

The parentModule folder (where the virtualwan.bicep file resides) contains a `parentModuleConfig.json` file. This json file holds the default configuration for the vwan solution deployment.

The default configuration in virtualwan solution is used for setting up prerequisites for TLS inspection, if this option is enabled.

The `parentModuleConfig.json` file is referenced by the virtualwan parent module by declaring a 'parentModuleConfig' variable; `var parentModuleConfig = loadJsonContent('parentModuleConfig.json')`.

In the following table the configuration defaults are described.

| Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `tlsKeyVaultConfig` | `object` | Please refer `parentModuleConfig.json` file. | Configuration for the Key Vault where your certificate is stored. |
| `tlsKeyVaultFeatures` | `object` | Please refer `parentModuleConfig.json` file. | Key Vault properties. |
| `tlsAccessPolicies` | `object` | Please refer `parentModuleConfig.json` file. | Key Vault access policies. |

> **Note**
>
> It is recommended to only change these values after consulting the ELZ Azure engineering team, if required.

### Resource names

To make sure network resources do not get re-deployed during the upgrade, the resource names should remain the same.

Please note there are some additional parameters that you need to pay attention to, these are explained in details below:

1. legacyNaming
2. useNamingConventionModule (pay attention to the name property in the subnets object)
3. nsgName

An important parameter to configure during upgrades from 1.x to 2.x and higher versions is `legacyNaming` for the ELZ virtual network peering and private zones virtual links. Set this to `true` _when performing upgrade of envrionments which are on a release version prior to 2.x_.

Another parameter to carefully configure during upgrade _(for envrionments which are on a release version prior to 2.x)_ is the `useNamingConventionModule` as part of the `subnets` object parameter. Points to keep in mind for this parameter are:

- When set to `true`, the ELZ Naming module will be used for generating subnet names, which means that the subnet name will be constructed out of 2 strings.
_First string_ will come from the ELZ standard naming convention (example: `cu1-sub1-d-euwe-snet-hub-`) and it will append a _second string_ (i.e. add a suffix), that will come from the `name` property inside the `subnets` object parameter (example: `network`). The examples used above will result in a name like: `cu1-sub1-d-euwe-snet-hub-network`.

- When set to `false`, the name of subnet will be exactly the same as the name passed in the `name` property inside the `subnets` object parameter.
This is required when ELZ naming convention is NOT used for subnets including subnets created automatically by Azure when additional resources were deployed.

- When performing upgrade from 1.x to 2.x and later release, this needs to be set to `false`, as there are changes introduced in naming convention for Hub subnet (in connectivity subscription) 2.x release onwards.

```json
{
    "subnets": {
        "value": [
            {
                "name": "non-standard-naming-snet-example",
                "useNamingConventionModule": false
            }
        ]
    }
}
```

- A subnet which does not follow ELZ naming convention, might also have a NSG, which does not follow ELZ naming convention, associated with it.
So, when setting `useNamingConventionModule` to `false` and if `securityRules` exist, a new property for Network Security Group name needs to be filled in, within the `subnets` object parameter.
The property is called `nsgName` and it will reflect the name of the existing Network Security Group, that does not follow the ELZ naming convention.

You will have to add it in the `subnets` object.

```json
{
    "subnets": {
        "value": [
            {
                "name": "non-standard-naming-snet-example",
                "nsgName": "non-standard-nsg-name",
                "useNamingConventionModule": false,
                "securityRules": []
            }
        ]
    }
}
```

When performing upgrade from 1.x to 2.x and later, for the hub subnets and NSGs (located in connectivity subscription), make sure to match the exact subnet and NSG names, there are changes introduced in naming convention in hub for them from 2.x release onwards.


## Parameter usage examples

The following examples show how to use the more abstract parameters (objects & array of objects) in the virtualwan parent module.

### Parameter usage: `routes`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"routes": {
    "value": [
        {
            "name": "EvidenDefaultRoute",
            "properties": {
                "addressPrefix": "0.0.0.0/0",
                "nextHopIpAddress": "x.x.x.x", //The IPv4 address, network traffic should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance.
                "nextHopType": "VirtualAppliance"
            }
        }
    ]
}
```

</details>
</p>

### Parameter usage: `subnets`

For guidance on how secruity rules should be written please refer `AzureBastionSubnet` section from the example provided below.
NOTE: For `AzureBastionSubnet` subnet itself, if deployed with NSG, do not onmit any of the rules provided below. For addition delatils please reffer [Parameter detail: `securityRules`](#parameter-detail-securityrules)

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"subnets": {
  "value": [
    {
      "name": "network",
      "addressPrefix": "x.x.x.x/24",
      "useNamingConventionModule": true,
      "securityRules": [],
      "serviceEndpoints": [
                        {
                            "locations": [
                                "westeurope"
                            ],
                            "service": "Microsoft.Storage"
                        },
                        {
                            "locations": [
                                "westeurope"
                            ],
                            "service": "Microsoft.Sql"
                        }
                    ],
                    "serviceEndpointPolicies": [
                        {
                            "id": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/serviceEndpointPolicies/{serviceEndpointPolicyName}",
                            "location": "westeurope",
                            "properties": {
                                        "serviceEndpointPolicyDefinitions": [
                                    {
                                        "id": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/serviceEndpointPolicies/serviceEndpointPolicyDefinitions/{serviceEndpointPolicyName}_Microsoft.Storage",
                                        "name": "{serviceEndpointPolicyName}_Microsoft.Storage",
                                        "properties": {
                                            "description": "The Service Endpoint Policies for Storage account",
                                            "service": "Microsoft.Storage",
                                            "serviceResources": [
                                                "/subscriptions/{subscriptionId}",
                                                "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}",
                                                "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Storage/storageAccounts/{storageAccountName}"
                                                
                                            ]
                                        },
                                        "type": "Microsoft.Network/serviceEndpointPolicies/serviceEndpointPolicyDefinitions"
                                    },
                                    {
                                        "id": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/serviceEndpointPolicies/serviceEndpointPolicyDefinitions/{serviceEndpointPolicyName}_Global",
                                        "name": "{serviceEndpointPolicyName}_Global",
                                        "properties": {
                                            "description": "The Service Endpoint Policies for Global Alias",
                                            "service": "Global",
                                            "serviceResources": [
                                                "/services/Azure/Batch",
                                                "/services/Azure/MachineLearning"
                                            ]
                                        },
                                        "type": "Microsoft.Network/serviceEndpointPolicies/serviceEndpointPolicyDefinitions"
                                    }
                                ]
                            },
                            "tags": {}
                        },
                        {
                            "id": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/serviceEndpointPolicies/{anotherServiceEndpointPolicyName}",
                            "location": "westeurope",
                            "properties": {
                                        "serviceEndpointPolicyDefinitions": [
                                    {
                                        "id": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/serviceEndpointPolicies/serviceEndpointPolicyDefinitions/{anotherServiceEndpointPolicyName}_Microsoft.Storage",
                                        "name": "{anotherServiceEndpointPolicyName}_Microsoft.Storage",
                                        "properties": {
                                            "description": "The Service Endpoint Policies for Storage account",
                                            "service": "Microsoft.Storage",
                                            "serviceResources": [
                                                "/subscriptions/{subscriptionId}"
                                            ]
                                        },
                                        "type": "Microsoft.Network/serviceEndpointPolicies/serviceEndpointPolicyDefinitions"
                                    }
                                ]
                            },
                            "tags": {}
                        }
                    ],
      "privateEndpointNetworkPolicies": "Enabled",
      "privateLinkServiceNetworkPolicies": "Enabled",
      "ipAllocations": [
        {
          "id": "string"
        }
      ]
    },
    {
      "name": "AzureFirewallSubnet",
      "addressPrefix": "x.x.x.x/26",
      "useNamingConventionModule": true
    },
    {
      "name": "GatewaySubnet",
      "addressPrefix": "x.x.x.x/26",
      "useNamingConventionModule": true
    },
    {
      "name": "AzureBastionSubnet",
      "addressPrefix": "x.x.x.x/26",
      "useNamingConventionModule": true,
      "securityRules": [
                        {
                            "name": "Allow_HTTPS_Inbound",
                            "properties": {
                                "protocol": "TCP",
                                "sourcePortRange": "*",
                                "destinationPortRange": "443",
                                "sourceAddressPrefix": "Internet",
                                "destinationAddressPrefix": "*",
                                "access": "Allow",
                                "priority": 110,
                                "direction": "Inbound",
                                "sourcePortRanges": [],
                                "destinationPortRanges": [],
                                "sourceAddressPrefixes": [],
                                "destinationAddressPrefixes": []
                            }
                        },
                        {
                            "name": "Allow_GatewayManager_Inbound",
                            "properties": {
                                "protocol": "TCP",
                                "sourcePortRange": "*",
                                "destinationPortRange": "443",
                                "sourceAddressPrefix": "GatewayManager",
                                "destinationAddressPrefix": "*",
                                "access": "Allow",
                                "priority": 120,
                                "direction": "Inbound",
                                "sourcePortRanges": [],
                                "destinationPortRanges": [],
                                "sourceAddressPrefixes": [],
                                "destinationAddressPrefixes": []
                            }
                        },
                        {
                            "name": "Allow_AzureLoadBalancer_Inbound",
                            "properties": {
                                "protocol": "TCP",
                                "sourcePortRange": "*",
                                "destinationPortRange": "443",
                                "sourceAddressPrefix": "AzureLoadBalancer",
                                "destinationAddressPrefix": "*",
                                "access": "Allow",
                                "priority": 130,
                                "direction": "Inbound",
                                "sourcePortRanges": [],
                                "destinationPortRanges": [],
                                "sourceAddressPrefixes": [],
                                "destinationAddressPrefixes": []
                            }
                        },
                        {
                            "name": "Allow_BastionHost_Communication_inside_vNet",
                            "properties": {
                                "protocol": "*",
                                "sourcePortRange": "*",
                                "sourceAddressPrefix": "VirtualNetwork",
                                "destinationAddressPrefix": "VirtualNetwork",
                                "access": "Allow",
                                "priority": 140,
                                "direction": "Inbound",
                                "sourcePortRanges": [],
                                "destinationPortRanges": [
                                    "8080",
                                    "5701"
                                ],
                                "sourceAddressPrefixes": [],
                                "destinationAddressPrefixes": []
                            }
                        },
                        {
                            "name": "Allow_SSH_and_RDP_Outbound",
                            "properties": {
                                "protocol": "*",
                                "sourcePortRange": "*",
                                "sourceAddressPrefix": "*",
                                "destinationAddressPrefix": "VirtualNetwork",
                                "access": "Allow",
                                "priority": 110,
                                "direction": "Outbound",
                                "sourcePortRanges": [],
                                "destinationPortRanges": [
                                    "22",
                                    "3389"
                                ],
                                "sourceAddressPrefixes": [],
                                "destinationAddressPrefixes": []
                            }
                        },
                        {
                            "name": "Allow_443_to_AzureCloud_Outbound",
                            "properties": {
                                "protocol": "TCP",
                                "sourcePortRange": "*",
                                "destinationPortRange": "443",
                                "sourceAddressPrefix": "*",
                                "destinationAddressPrefix": "AzureCloud",
                                "access": "Allow",
                                "priority": 120,
                                "direction": "Outbound",
                                "sourcePortRanges": [],
                                "destinationPortRanges": [],
                                "sourceAddressPrefixes": [],
                                "destinationAddressPrefixes": []
                            }
                        },
                        {
                            "name": "AllowBastion_DataPlane_Outbound",
                            "properties": {
                                "protocol": "*",
                                "sourcePortRange": "*",
                                "sourceAddressPrefix": "VirtualNetwork",
                                "destinationAddressPrefix": "VirtualNetwork",
                                "access": "Allow",
                                "priority": 130,
                                "direction": "Outbound",
                                "sourcePortRanges": [],
                                "destinationPortRanges": [
                                    "5701",
                                    "8080"
                                ],
                                "sourceAddressPrefixes": [],
                                "destinationAddressPrefixes": []
                            }
                        },
                        {
                            "name": "Allow_Session_and_Certificate_Validation",
                            "properties": {
                                "protocol": "*",
                                "sourcePortRange": "*",
                                "destinationPortRange": "80",
                                "sourceAddressPrefix": "*",
                                "destinationAddressPrefix": "Internet",
                                "access": "Allow",
                                "priority": 140,
                                "direction": "Outbound",
                                "sourcePortRanges": [],
                                "destinationPortRanges": [],
                                "sourceAddressPrefixes": [],
                                "destinationAddressPrefixes": []
                            }
                        }
                    ]
    }
  ]
}
```

</details>
</p>

### Parameter usage: `bastionHostIpConfig`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"bastionHostIpConfig": {
    "value": {
        "skuName": "Standard",
        "skuTier": "Regional",
        "zones": [],
        "idleTimeoutInMinutes": 4,
        "publicIpAddressVersion": "IPv4",
        "publicIpAllocationMethod": "Static",
        "privateIPAllocationMethod": "Dynamic"
    }
}
```

</details>
</p>

### Parameter usage: `bastionHostConfig`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"bastionHostConfig": {
    "value": {
        "sku": "Basic",
        "enableFileCopy": true,
        "scaleUnits": 2,
        "enableShareableLink": true,
        "disableCopyPaste": false,
        "enableIpConnect": true,
        "enableTunneling": true
    }
}
```

</details>
</p>

## Parameter File Examples

Please refer the parameter files provided for virtualwan solution in the input folder of the repository.

**NOTE:** The parameter files in the input folder serve as an example only. They may not consist of every parameter that can be supplied to deploy the solution. Please read this readme file for details on every parameter that can be used. Update the parameter file as per the environment. Do not run the deployment, using these files as is (exception - dev\test environments).

In the input folder you should find three parameter files that you can refer to:

- example-environment-name.cnty.virtualwan.params.json
- example-environment-name.lnd1.virtualwan.params.json
- example-environment-name.tool.virtualwan.params.json

## Outputs

None.
