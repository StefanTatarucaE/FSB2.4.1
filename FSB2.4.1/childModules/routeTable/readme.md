# childModules/routeTable/routeTable.bicep <!-- omit in toc -->

This Bicep module deploys a user defined route table.

## Navigation <!-- omit in toc -->

- [Resource types](#resource-types)
- [Parameters](#parameters)
  - [Required parameters](#required-parameters)
    - [Parameter detail: `routes`](#parameter-detail-routes)
  - [Optional parameters](#optional-parameters)
  - [Parameter usage: `routes`](#parameter-usage-routes)
  - [Parameter usage: `tags`](#parameter-usage-tags)
- [Outputs](#outputs)
- [Deployment example](#deployment-example)
  
## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Network/routeTables` | [2021-08-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-08-01/routeTables) |

## Parameters

### Required parameters

|  Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string |  The resource name of the route table.|
| `location` | string |  Specify the location where the route table is to be created |
| `disableBgpRoutePropagation` | `bool` | Whether to disable the routes learned by BGP on that route table. |
| [`routes`](#parameter-detail-routes) | `array` | Collection of routes contained within a route table. |

#### Parameter detail: `routes`

| Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `name` | `string` | | The name of a route within the route table. |
| `addressPrefix` | `string` | | The destination CIDR to which the route applies. |
| `nextHopType` | `string` | 'Internet', 'None', 'VirtualAppliance', 'VirtualNetworkGateway', 'VnetLocal' | The type of Azure hop the packet should be sent to. |
| `nextHopIpAddress` | `string` | | The IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance. |

### Optional parameters

| Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `tags` | object | `{}` |  | A mapping of tags to assign to the resource. |

### Parameter usage: `routes`
<p>
<details>

<summary>Parameter JSON format</summary>

```json
"routes": {
  "value": [
    {
      "name": "DCSDefaultRoute",
      "properties": {
        "addressPrefix": "0.0.0.0/0",
        "nextHopIpAddress" : "10.10.3.4",
        "nextHopType": "VirtualAppliance"
      }
    }
  ]
}
```

</details>
</p>

<p>

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
</p>

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `routeTableResourceId` | string | The resource ID of the route table. |

## Deployment example

<p>
<details>

<summary>via Bicep module</summary>

```bicep
module networkingRouteTable './childModules/routeTable/routeTable.bicep' = {
  name: 'routeTable-deployment'
  params: {
    name: 'xxx-cnty-x-eune-rt-spoke'
    location: 'northeurope'
    tags: {
      Environment: 'Test'
      Contact: 'sample.user@custcompany.net'
      CostCenter: '8844'
      ServiceName: 'BackendServiceXYZ'
      Role: 'BackendXYZ'
    }
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: '172.16.0.20'
          nextHopType: 'VirtualAppliance'
        }
      }
    ]
  }
}
```

</details>
</p>