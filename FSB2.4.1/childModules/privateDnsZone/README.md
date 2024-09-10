# childModules/privateDnsZone/privateDnsZone.bicep <!-- omit in toc -->

This Bicep module deploys a Private DNS Zone. It can also create all supported Azure Private DNS Zone records.

## Navigation <!-- omit in toc -->

- [Resource types](#resource-types)
- [Parameters](#parameters)
  - [Required parameters](#required-parameters)
    - [Parameter detail: `aRecordSet`](#parameter-detail-arecordset)
    - [Parameter detail: `cnameRecordSet`](#parameter-detail-cnamerecordset)
    - [Parameter detail: `mxRecordSet`](#parameter-detail-mxrecordset)
    - [Parameter detail: `ptrRecordSet`](#parameter-detail-ptrrecordset)
    - [Parameter detail: `srvRecordSet`](#parameter-detail-srvrecordset)
    - [Parameter detail: `txtRecordSet`](#parameter-detail-txtrecordset)
    - [Parameter detail: `aaaaRecordSet`](#parameter-detail-aaaarecordset)
  - [Optional parameters](#optional-parameters)
  - [Parameter usage: `aRecordSet`](#parameter-usage-arecordset)
  - [Parameter usage: `cnameRecordSet`](#parameter-usage-cnamerecordset)
  - [Parameter usage: `mxRecordSet`](#parameter-usage-mxrecordset)
  - [Parameter usage: `ptrRecordSet`](#parameter-usage-ptrrecordset)
  - [Parameter usage: `srvRecordSet`](#parameter-usage-srvrecordset)
  - [Parameter usage: `txtRecordSet`](#parameter-usage-txtrecordset)
  - [Parameter usage: `aaaaRecordSet`](#parameter-usage-aaaarecordset)
  - [Parameter usage: `tags`](#parameter-usage-tags)
- [Outputs](#outputs)
- [Deployment example](#deployment-example)
  
## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Network/privateDnsZones` | [2020-06-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2020-06-01/privatednszones/) |
| `Microsoft.Network/privateDnsZones/A` | [2020-06-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2020-06-01/privatednszones/a) |
| `Microsoft.Network/privateDnsZones/CNAME` | [2020-06-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2020-06-01/privatednszones/cname) |
| `Microsoft.Network/privateDnsZones/MX` | [2020-06-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2020-06-01/privatednszones/mx) |
| `Microsoft.Network/privateDnsZones/PTR` | [2020-06-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2020-06-01/privatednszones/ptr) |
| `Microsoft.Network/privateDnsZones/SRV` | [2020-06-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2020-06-01/privatednszones/srv) |
| `Microsoft.Network/privateDnsZones/TXT` | [2020-06-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2020-06-01/privatednszones/txt) |
| `Microsoft.Network/privateDnsZones/AAAA` | [2020-06-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2020-06-01/privatednszones/aaaa) |

## Parameters

### Required parameters

|  Name | Type | Description |
| :-- | :-- | :-- |
| `privateDNSZoneName` | `string` | Specifies the name of the Private DNS zone. For example, contoso.com. |
| [`aRecordSet`](#parameter-detail-arecordset) | `array` | Specifies the A record set to be created.|
| [`cnameRecordSet`](#parameter-detail-cnamerecordset) | `array` | Specifies the CNAME record set to be created.|
| [`mxRecordSet`](#parameter-detail-mxrecordset) | `array` | Specifies the  MX record set to be created.|
| [`ptrRecordSet`](#parameter-detail-ptrrecordset) | `array` | Specifies the PTR record set to be created.|
| [`srvRecordSet`](#parameter-detail-srvrecordset) | `array` | Specifies the SRV record set to be created.|
| [`txtRecordSet`](#parameter-detail-txtrecordset) | `array` | Specifies the TXT record set to be created.|
| [`aaaaRecordSet`](#parameter-detail-aaaarecordset) | `array` | Specifies the AAAA record set to be created.|

#### Parameter detail: `aRecordSet`

To create a Private DNS Zone A record resource, add the following 'key:value' pairs to the `aRecordSet` parameter.
Multiple records can be created by specifying multiple objects (with multiple sets of 'key:value' pairs for configuration).

| Name | Type | Description |
| :-- | :-- | :-- |
| `createRecordA` | `bool` | Do we want to create\edit this record set. |
| `name` | `string` | The name of the DNS A Record. |
| `ipv4Address` | `Array` | The IPv4 address of this A record. |
| `ttl` | `int` | The TTL (time-to-live) of the records in the record set. |

#### Parameter detail: `cnameRecordSet`

To create a Private DNS Zone CNAME record resource, add the following 'key:value' pairs to the `cnameRecordSet` parameter.
Multiple records can be created by specifying multiple objects (with multiple sets of 'key:value' pairs for configuration).

| Name | Type | Description |
| :-- | :-- | :-- |
| `createRecordCname` | `bool` | Do we want to create\edit this record set. |
| `name` | `string` | The name of the DNS CNAME Record. |
| `cname` | `string` | The canonical name for this CNAME record. |
| `ttl` | `int` | The TTL (time-to-live) of the records in the record set. |

#### Parameter detail: `mxRecordSet`

To create a Private DNS Zone MX record resource, add the following 'key:value' pairs to the `mxRecordSet` parameter.
Multiple records can be created by specifying multiple objects (with multiple sets of 'key:value' pairs for configuration).

| Name | Type | Description |
| :-- | :-- | :-- |
| `createRecordMx` | `bool` | Do we want to create\edit this record set. |
| `name` | `string` | The name of the DNS MX Record. |
| `exchange` | `string` | The domain name of the mail host for this MX record. |
| `preference` | `int` | The preference value for this MX record.. |
| `ttl` | `int` | The TTL (time-to-live) of the records in the record set. |

#### Parameter detail: `ptrRecordSet`

To create a Private DNS Zone PTR record resource, add the following 'key:value' pairs to the `ptrRecordSet` parameter.
Multiple records can be created by specifying multiple objects (with multiple sets of 'key:value' pairs for configuration).

| Name | Type | Description |
| :-- | :-- | :-- |
| `createRecordPtr` | `bool` | Do we want to create\edit this record set. |
| `name` | `string` | The name of the DNS PTR Record. |
| `ptrdname` | `string` | The PTR target domain name for this PTR record. |
| `ttl` | `int` | The TTL (time-to-live) of the records in the record set. |

#### Parameter detail: `srvRecordSet`

To create a Private DNS Zone SRV record resource, add the following 'key:value' pairs to the `srvRecordSet` parameter.
Multiple records can be created by specifying multiple objects (with multiple sets of 'key:value' pairs for configuration).

| Name | Type | Description |
| :-- | :-- | :-- |
| `createRecordSrv` | `bool` | Do we want to create\edit this record set. |
| `name` | `string` | The name of the DNS SRV Record. |
| `port` | `int` | The port value for this SRV record. |
| `priority` | `int` | The priority value for this SRV record. |
| `target` | `string` | The target domain name for this SRV record. |
| `weight` | `int` | The weight value for this SRV record. |
| `ttl` | `int` | The TTL (time-to-live) of the records in the record set. |

#### Parameter detail: `txtRecordSet`

To create a Private DNS Zone TXT record resource, add the following 'key:value' pairs to the `txtRecordSet` parameter.
Multiple records can be created by specifying multiple objects (with multiple sets of 'key:value' pairs for configuration).

| Name | Type | Description |
| :-- | :-- | :-- |
| `createRecordTxt` | `bool` | Do we want to create\edit this record set. |
| `name` | `string` | The name of the DNS TXT Record. |
| `value` | `string[]` | The text value of this TXT record. |
| `ttl` | `int` | The TTL (time-to-live) of the records in the record set. |

#### Parameter detail: `aaaaRecordSet`

To create a Private DNS Zone AAAA record resource, add the following 'key:value' pairs to the `aaaaRecordSet` parameter.
Multiple records can be created by specifying multiple objects (with multiple sets of 'key:value' pairs for configuration).

| Name | Type | Description |
| :-- | :-- | :-- |
| `createRecordAaaa` | `bool` | Do we want to create\edit this record set. |
| `name` | `string` | The name of the DNS AAAA (ipv6) Record. |
| `ipv6Address` | `string` | The IPv6 address of this AAAA record. |
| `ttl` | `int` | The TTL (time-to-live) of the records in the record set. |

### Optional parameters

| Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `tags` | object | `{}` |  | A mapping of tags to assign to the resource. |

### Parameter usage: `aRecordSet`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"aRecordSet" : {
    "value": [
        {
            "createRecordA": false,
            "name": "arecordname",
            "ipv4Address": [
                {
                    "ipv4Address": "10.10.10.10"
                }
            ],
            "ttl": 3600
        }
    ]
}
```

</details>
</p>

### Parameter usage: `cnameRecordSet`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"cnameRecordSet": {
    "value": [
        {
            "createRecordCname": false,
            "name": "cnamerecordname",
            "cname": "contoso.com",
            "ttl": 3600
        }
    ]
}
```

</details>
</p>

### Parameter usage: `mxRecordSet`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"mxRecordSet": {
    "value": [
        {
            "createRecordMx": false,
            "name": "mxrecord",
            "exchange":[
                {
                    "exchange": "mail.myexchangeserver.com",
                    "preference": 11
                }
            ],
            "ttl":3600
        }
    ]
}
```

</details>
</p>

### Parameter usage: `ptrRecordSet`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"ptrRecordSet": {
    "value": [
        {
            "createRecordPtr": false,
            "name": "@",
            "ttl": 3600,
            "ptrValue": [
                {
                    "ptrdname": "test.com"
                }
            ]
        }
    ]
}
```

</details>
</p>

### Parameter usage: `srvRecordSet`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"srvRecordSet": {
    "value": [
        {
            "createRecordSrv": false,
            "name": "@",
            "ttl": 3600,
            "srvValue": [
                {
                    "port": 8080,
                    "priority": 0,
                    "target": "sip.contoso.com",
                    "weight": 5
                }
            ]
        }
    ]
}
```

</details>
</p>

### Parameter usage: `txtRecordSet`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"txtRecordSet": {
    "value": [
        {
            "createRecordTxt": false,
            "name": "@",
            "ttl": 3600,
            "txtValue": [
                {
                    "value": ["Have a nice day."]
                }
            ]
        }
    ]
}
```

</details>
</p>

### Parameter usage: `aaaaRecordSet`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"aaaaRecordSet": {
    "value": [
        {
            "createRecordAaaa": false,
            "name": "aaaarecordname",
            "ipv6Address": [
                {
                    "ipv6Address": "2001:db8::1:0:0:1"
                }
            ],
            "ttl": 3600
        }
    ]
}
```

</details>
</p>

### Parameter usage: `tags`

Tag names and tag values can be provided as needed. A tag can be left without a value.

<p>
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
| `privateDNSZoneName` | string | The resource name of the deployed Private DNS Zone. |
| `privateDNSZoneResourceId` | string | The resource ID of the deployed Private DNS Zone. |

## Deployment example

<p>
<details>

<summary>via Bicep module</summary>

```bicep
module privateDnsZone '../../childModules/privateDnsZone/privateDnsZone.bicep' = { // Private DNS will be deployed only in Connectivity
  scope: exampleResourceGroup
  name: 'privateDnsZone-deployment'
  params: {
    name: 'dcsprivatednszone.com'
    tags: {
      Environment: 'Test'
      Contact: 'sample.user@custcompany.net'
      CostCenter: '8844'
      ServiceName: 'BackendServiceXYZ'
      Role: 'BackendXYZ'
    }
    aRecordSet: [
        createRecordA: true
        name: 'arecordname'
        ipv4Address: [
            ipv4Address: '10.10.10.10'
        ]
        ttl: 3600
    ]
    aaaaRecordSet: [
        createRecordAaaa: true
        name:
        ipv6Address: [
            ipv6Address: '2001:db8::1:0:0:1'
        ]
        ttl: 3600
    ]
    cnameRecordSet: [
        createRecordCname: false
        name: 'cnamerecordname'
        cname: 'contoso.com'
        ttl: 3600
    ]
    mxRecordSet: [
        createRecordMx: false
        name: 'mxrecord'
        exchange:[
            exchange: 'mail.myexchangeserver.com'
            preference: 11
        ]
        ttl:3600
    ]
    ptrRecordSet: [
        createRecordPtr: false
        name: '@'
        ttl: 3600
        ptrValue: [
            ptrdname: 'test.com'
        ]
    ]
    srvRecordSet: [
        createRecordSrv: false
        name: '@'
        ttl: 3600
        srvValue: [
            port: 8080
            priority: 0
            target: 'sip.contoso.com'
            weight: 5
        ]
    ]
    txtRecordSet: [
        createRecordTxt: false
        name: '@'
        ttl: 3600
        txtValue: [
            value: ['Have a nice day.']
        ]
    ]
  }
}
```

</details>
</p>