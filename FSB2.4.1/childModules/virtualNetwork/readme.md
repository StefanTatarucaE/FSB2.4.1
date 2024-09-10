# childModules/virtualNetwork/virtualNetwork.bicep<!-- omit in toc -->

This Bicep module deploys an Azure Virtual Network with a dynamic number of subnets.
This module can deploy both the Hub and Spoke networking components, depending on the value passed for the `subscriptionType` parameter.

## Navigation <!-- omit in toc -->

- [Resource types](#resource-types)
- [Parameters](#parameters)
  - [Required parameters](#required-parameters)
    - [Parameter detail: `subnets`](#parameter-detail-subnets)
    - [Optional Subnet Property: `serviceEndpoints`](#parameter-detail-serviceendpoints)
    - [Optional Subnet Property: `serviceEndpointPolicies`](#parameter-detail-serviceendpointpolicies)
    - [Optional Subnet Property: `serviceEndpointPolicyDefinitions`](#parameter-detail-serviceEndpointPolicyDefinitions)
    - [Optional Subnet Property: `privateEndpointNetworkPolicies`](#parameter-detail-privateendpointnetworkpolicies)
    - [Optional Subnet Property: `privateLinkServiceNetworkPolicies`](#parameter-detail-privatelinkservicenetworkpolicies)
    - [Optional Subnet Property: `ipAllocations`](#parameter-detail-ipallocations)
    - [Optional Subnet Property: `delegations`](#parameter-detail-delegations)
    - [Optional Subnet Property: `securityRules`](#parameter-detail-securityrules)
  - [Optional parameters](#optional-parameters)
  - [Parameter usage: `subnets`](#parameter-usage-subnets)
  - [Parameter usage: `securityRules`](#parameter-usage-securityrules)
  - [Parameter usage: `tags`](#parameter-usage-tags)
- [Outputs](#outputs)
- [Deployment example](#deployment-example)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Network/networkSecurityGroups` | [2021-08-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2021-08-01/networkSecurityGroups) |
| `Microsoft.Network/virtualNetworks` | [2021-08-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2021-08-01/virtualnetworks) |

## Parameters

### Required parameters

|  Name | Type | Description |
| :-- | :-- | :-- |
| `networkSecurityGroupName` | string | Specifies the name of the Network Security Group (NSG).|
| `location` | string | Specifies the location where the Azure Resource will be created. |
| `virtualNetworkName` | string | Specifies the resource name of the Virtual Network.|
| `virtualNetworkAddressPrefixes` | array | Specifies the array of 1 or more IP Address Prefixes for the Virtual Network.|
| `dnsServers` | array | Specifies the DNS Servers to be associated to the Virtual Network.|
| `enableVmProtection` | bool | Specifies the value to enable or disable VM protection in subnets.|
| [`subnets`](#parameter-detail-subnets) | array | Specifies the array of **objects** for the subnets that should be created. The subnet object also contains information about which network security groups to create. The [`securityRules`](#parameter-detail-securityrules) key within the subnet object holds this information.|
| `subnetNamePrefix` | array | Specifies the Subnet name prefix. This will pre-pend any subnet name. Together with the 'subnet.name' value coming from the parameters file the full subnet name is formed.|

#### Parameter detail: `subnets`

Array of subnet objects to deploy to the subnet & subnet properties.

| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `name` | string |  |  | The name of subnet. |
| `useNamingConventionModule` | bool | `false` | `[true, false]` | Specifies the value to enable or disable logic necessary to support non standard names for subnets and NSGs. Please make sure to read the documentation for additional information. |
| `nsgName` | string |  |  | Optional. Use only when setting `useNamingConventionModule` to `false` and when a NSG for that particular subnet needs to be attached. |
| `addressPrefix` | string |  |  | The address prefix for the subnet.|
| `addressPrefixes` | array | `[]`|  |List of address prefixes for the subnet. |
| [`ipAllocations`](#parameter-detail-ipallocations) | array | `[]` |  | An array of IpAllocation which reference this subnet.|
| [`delegations`](#parameter-detail-delegations) | array | `[]` |  | An array of delegations which reference this subnet. For easy identification of the structure, the Export template can be used from the Azure Portal |
| [`serviceEndpoints`](#parameter-detail-serviceendpoints) | array | `[]` |  | An array of service endpoints. See this [page](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#serviceendpointpropertiesformat) for more information. |
| [`serviceEndpointsPolicies`](#parameter-detail-serviceendpointpolicies) | array | `[]`| | An array of service endpoint policies. See this [page](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#serviceendpointpolicy) for more information.|
| `applicationGatewayIpConfigurations` | array | `[]` |  | Application gateway IP configurations of virtual network resource. See this [page](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#applicationgatewayipconfiguration) for more information. |
| `networkSecurityGroup` | string | `null` |  | The reference to the Network Security Group resource.|
| `routeTable` | string | `null` |  | Specifies the resource ID of the route table to assign to the subnet. If empty, no routing table is attached to the subnet. |
| [`privateEndpointNetworkPolicies`](#parameter-detail-privateendpointnetworkpolicies) | string | `null` | `[Disabled, Enabled]` | Enable or Disable apply network policies on private end point in the subnet. |
| [`privateLinkServiceNetworkPolicies`](#parameter-detail-privatelinkservicenetworkpolicies) | array| `null` | `[Disabled, Enabled]` | Enable or Disable apply network policies on private link service in the subnet. |

#### Parameter detail: `serviceEndpoints`

| Parameter Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `locations` | `string[]` | `[]` | A list of locations.|
| `service` | `string` | ` ` | The type of the endpoint service.|

#### Parameter detail: `serviceEndpointPolicies`

| Parameter Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `id` | `array` | | Resource ID of service endpoint policy.|
| `location` | `string` | | Resource location. |
| `tags` | `object` | | Resource tags. |
| [`properties`](#parameter-detail-ServiceEndpointPolicyPropertiesFormat) | `object`  | | Properties of the service end point policy. |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#serviceendpointpolicy).

#### Parameter detail: `ServiceEndpointPolicyPropertiesFormat`

| Parameter Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `contextualServiceEndpointPolicies` | `string[]` | | A collection of contextual service endpoint policy. |
| `serviceAlias` | `object` | | The alias indicating if the policy belongs to a service. |
| [`serviceEndpointPolicyDefinitions`](#parameter-detail-serviceEndpointPolicyDefinitions) | `array`  | | A collection of service endpoint policy definitions of the service endpoint policy. |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#serviceendpointpolicypropertiesformat).

#### Parameter detail: `serviceEndpointPolicyDefinitions`

| Parameter Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `id` | `string` | | Resource ID of the policy definition. |
| `name` | `string` | | The name of the resource that is unique within a resource group. This name can be used to access the resource. |
| [`properties`](#parameter-detail-ServiceEndpointPolicyDefinitionPropertiesFormat) | `object`  | | Properties of the service end point policy. |
| `type` | `string` | | The type of the resource. |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#serviceendpointpolicydefinition).

#### Parameter detail: `ServiceEndpointPolicyDefinitionPropertiesFormat`

| Parameter Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `description` | `string` | | A description for this rule. Restricted to 140 chars. |
| `service` | `string` | | Service endpoint name.. |
| `serviceResources` | `string` | | A list of service resources. |

Check the source information on Microsoft [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep#serviceendpointpolicydefinitionpropertiesformat).


#### Parameter detail: `privateEndpointNetworkPolicies`

| Parameter Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `privateEndpointNetworkPolicies` | `string` |  ` ` | Enable or Disable apply network policies on private end point in the subnet. Allowed values: 'Disabled' 'Enabled'|

#### Parameter detail: `privateLinkServiceNetworkPolicies`

| Parameter Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `privateLinkServiceNetworkPolicies` | `string` |  ` ` | Enable or Disable apply network policies on private link service in the subnet. Allowed values: 'Disabled' 'Enabled'|

#### Parameter detail: `ipAllocations`

| Parameter Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `id` | `array` |  `[]` | Array of IpAllocation which reference the virtual network.|

#### Parameter detail: `delegations`

An array of delegations for the particular subnet

| Parameter Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `name` | `string` |  `string` | Name of the delegated service (i.e. Microsoft.DBforMySQL.flexibleServers) |
| `id` | `string` |  `string` | Resource ID of the subnet that contains the delegated service (i.e. /subscriptions/subscriptionId/resourceGroups/resourceGroupName/providers/Microsoft.Network/virtualNetworks/vNetName/subnets/snetName/delegations/Microsoft.DBforMySQL.felxibleServers) |
| `properties` | `string` |  `string` | The properties contains usually just the serviceName (i.e. "serviceName" : "Microsoft.DBforMySQL/flexibleServers" ). For more detailed info use the Export Template of the virtual network from the Azure Portal |
| `type` | `string` |  `string` | Resource type (i.e. Microsoft.Network/virtualNetwork/subnets/delegations) |

#### Parameter detail: `securityRules`

An array of Security Rules to deploy to the Network Security Group (NSG) as part of the `subnets` object. When not provided, no NSG will be deployed.

| Parameter Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `name` | string |  | The name of the security rule. |
| `protocol` | string | `[*, Ah, Esp, Icmp, Tcp, Udp]` | Network protocol this rule applies to. |
| `sourcePortRange` | string | | The source port or range. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports. |
| `destinationPortRange` | string | | The destination port or range. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports. |
| `sourceAddressPrefix` | string | | The CIDR or source IP range. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used. If this is an ingress rule, specifies where network traffic originates from. |
| `destinationAddressPrefix` | string | | The destination address prefix. CIDR or destination IP range. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used. |
| `access` | string | `[Allow, Deny]` | Whether network traffic is allowed or denied. |
| `priority` | int |  | The priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule. |
| `direction` | string | `[Inbound, Outbound]` | The direction of the rule. The direction specifies if rule will be evaluated on incoming or outgoing traffic. |

### Optional parameters

| Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `tags` | object | `{}` |  | Specifies a mapping of tags to assign to the resource.|
| `ddosProtectionPlanId` | string | ` ` |  | Specifies the Resource ID of the DDoS protection plan. If empty, DDoS will not be enabled.|

### Parameter usage: `subnets`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"subnets": {
  "value": [
    {
      "name": "network",
      "addressPrefix": "172.16.0.0/24",
      "useNamingConventionModule": true,
      "securityRules": [...],
      "serviceEndpoints": [
          {
            "locations": [
              "westus",
              "westeurope"
            ],
            "service": "Microsoft.Storage"
          }
      ],
      "serviceEndpointPolicies": [
      {
        "id": "string",
        "location": "string",
        "properties": {
          "contextualServiceEndpointPolicies": [ "string" ],
          "serviceAlias": "string",
          "serviceEndpointPolicyDefinitions": [
            {
              "id": "string",
              "name": "string",
              "properties": {
                "description": "string",
                "service": "string",
                "serviceResources": [ "string" ]
              },
              "type": "string"
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
      "addressPrefix": "172.16.3.0/26"
    },
    {
      "name": "GatewaySubnet",
      "addressPrefix": "172.16.4.0/26"
    }
  ]
}
```

</details>
</p>

### Parameter usage: `securityRules`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"subnets": {
  "value": [
    {
      "name": "front",
      "addressPrefix": "20.10.1.0/24",
      "securityRules": [
        {
          "name": "DCSA-Allow-Own-Subnet-Inbound",
          "properties": {
            "protocol": "*",
            "sourcePortRange": "*",
            "destinationPortRange": "*",
            "sourceAddressPrefix": "20.10.1.0/24",
            "destinationAddressPrefix": "20.10.1.0/24",
            "access": "Allow",
            "priority": 4000,
            "direction": "Inbound",
            "sourcePortRanges": [],
            "destinationPortRanges": [],
            "sourceAddressPrefixes": [],
            "destinationAddressPrefixes": []
          }
        },
        {
          "name": "DCSA-Allow-Own-Subnet-Outbound",
          "properties": {
            "protocol": "*",
            "sourcePortRange": "*",
            "destinationPortRange": "*",
            "sourceAddressPrefix": "20.10.1.0/24",
            "destinationAddressPrefix": "20.10.1.0/24",
            "access": "Allow",
            "priority": 4000,
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
| `virtualNetworkName` | string | The resource name of the deployed virtual network. |
| `virtualNetworkResourceId` | string | The resource ID of the deployed virtual network. |

## Deployment example

<p>
<details>

<summary>via Bicep module</summary>

```bicep
module virtualNetwork '../../childModules/virtualNetwork/virtualNetwork.bicep' = {
  scope: exampleResourceGroup
  name: 'virtualNetwork-deployment'
  params: {
    virtualNetworkName: 'aaa-lnd2-d-eune-vnet-spoke'
    virtualNetworkAddressPrefixes: [
      '20.10.0.0/16'
    ]
    location: 'northeurope'
    tags: {
      Environment: 'Test'
      Contact: 'sample.user@custcompany.net'
      CostCenter: '8844'
      ServiceName: 'BackendServiceXYZ'
      Role: 'BackendXYZ'
    }
    ddosProtectionPlanId: ''
    dnsServers: [
      '8.8.8.8'
    ]
    enableVmProtection: false
    networkSecurityGroupName: 'aaa-lnd2-d-eune-nsg'
    routeTableResourceId: ''
    subnetNamePrefix: 'aaa-lnd1-d-eune-snet'
    legacyNaming: false
    subnets: [
      {
        name: 'front',
        useNamingConventionModule: true
        addressPrefix: '20.10.1.0/24'
        addressPrefixes: []
        ipAllocations: []
        serviceEndPoints: []
        serviceEndpointPolicies: []
        applicationGatewayIpConfigurations: []
        securityRules: [
          {
            name: 'DCSA-Allow-Own-Subnet-Inbound'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '20.10.1.0/24'
              destinationAddressPrefix: '20.10.1.0/24'
              access: 'Allow'
              priority: 4000
              direction: 'Inbound'
              sourcePortRanges: []
              destinationPortRanges: []
              sourceAddressPrefixes: []
              destinationAddressPrefixes: []
            }
          }
        ]
        routeTable: ''
        privateEndpointNetworkPolicies: []
        privateLinkServiceNetworkPolicies: []
      }
    ]
  }
}
```

</details>
</p>
