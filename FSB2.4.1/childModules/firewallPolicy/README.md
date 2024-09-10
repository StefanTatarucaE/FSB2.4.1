# childModules/firewallPolicy/firewallPolicy.bicep <!-- omit in toc -->

This Bicep module deploys a Firewall Policy & a default set of Rule Collection Groups.

## Navigation <!-- omit in toc -->

- [Resource types](#resource-types)
- [Parameters](#parameters)
  - [Required parameters](#required-parameters)
    - [Parameter detail: `firewallRuleCollectionGroups`](#parameter-detail-firewallrulecollectiongroups)
- [Optional parameters](#optional-parameters)
- [Parameter usage: `dnatRuleCollection`](#parameter-usage-dnatrulecollection)
- [Parameter usage: `networkRuleCollection`](#parameter-usage-networkrulecollection)
- [Parameter usage: `applicationRuleCollection`](#parameter-usage-applicationrulecollection)
- [Parameter detail: `firewallIntrusionDetection`](#parameter-usage-firewallintrusiondetection)
- [Parameter usage: `tags`](#parameter-usage-tags)
- [Outputs](#outputs)
- [Deployment example](#deployment-example)
  
## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Network/firewallPolicies` | [2021-08-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-08-01/firewallPolicies) |
| `Microsoft.Network/firewallPolicies/ruleCollectionGroups` | [2021-08-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-08-01/firewallPolicies/ruleCollectionGroups) |

## Parameters

### Required parameters

|  Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `name` | string |  | Specifies the resource name of the Firewall Policy.|
| `location` | string |  | Specifies the location where the Azure Resource will be created. |
| `azureFirewallPolicySku` | string | `Standard` | The Azure Firewall SKU associated with the Firewall to deploy , can take the values 'Standard', 'Premium'. |
| `enableProxy` | bool | `[true, false]` | Specifies to enable or disable DNS Proxy on Firewalls attached to the Firewall Policy. |
| `dnsServers` | array | `["Ip addresses"]` | A DNS server maintains and resolves domain names to IP addresses. This parameter allows you to specifies the DNS servers for the firewall policy.By default it is empty. |
| `threatIntelMode` | string | `[Alert, Deny, Off]` | Specifies the operation mode for Threat Intelligence. |
| `fqdns` | array |  | Specifies a list of FQDNs for the ThreatIntel Allowlist. |
| `enableTlsInspection` | bool |  | Specifies if TLS inspection should be enabled for Firewall Policy. If set to true, at the time of the deployment, a Certificate inside a KeyVault should exist before running this module. |
| `tlsKeyVaultName` | string |  | Name of the KeyVault used by TLS inspection. |
| `tlsKeyVaultCertId` | string |  | Specifies Secret ID of the Certificate stored in the KeyVault required by TLS inspection |
| `firewallUserIdentity` | string |  | Specifies the resource ID of the Managed Identity required by the TLS inspection |
| `ipAddresses` | array |  | Specifies a list of IP addresses for the ThreatIntel Allowlist. |
| [`firewallRuleCollectionGroups`](#parameter-detail-firewallrulecollectiongroups) | array |  | Specifies the rule collection groups to be deployed with the firewall policy. |
| [`firewallIntrusionDetection`](#parameter-detail-firewallintrusiondetection) | object |  | An object which holds the intrusion detection protection system (IDPS) configuration. |
| `enableFirewallPolicyAnalytics` | bool |  | Specifies if Firewall Policy Analytics should be enabled for Firewall Policy.  |

#### Parameter detail: `firewallRuleCollectionGroups`

| Name | Type | Description |
| :-- | :-- | :-- |
| `name` | `string`| The name of the rule collection group.|
| `properties` | `object`| The properties of the firewall policy rule collection group. FOr more details [click here](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2021-08-01/firewallpolicies/rulecollectiongroups?pivots=deployment-language-bicep#firewallpoliciesrulecollectiongroups).|

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

| Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `tags` | object | `{}` |  | A mapping of tags to assign to the resource. |

### Parameter usage 

The below rule collections are per rule type in the firewall policy. These rule collections are placed under a rule collection group. We have introduced a new logic to make setting up rules easier. For this we will use an excel file in a particular format which can be filled by the application team with rules. This will then be converted into a format understood by the firewall policy bicep module by simply running a python script developed for this specific purpose.

### Parameter usage: `dnatRuleCollection`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"dnatRuleCollection": {
    "value": [
        {
            "name": "Eviden-Network-Allow-RC",
            "ruleCollectionType": "FirewallPolicyNatRuleCollection",
            "priority": 1000,
            "action": {
                "type": "Allow"
            },
            "rules": [
                {
                    "name": "EvidenAllowTCP",
                    "ruleType": "NatRule",
                    "destinationAddresses": [
                        "*"
                    ],
                    "destinationPorts": [
                        "*"
                    ],
                    "ipProtocols": [
                        "TCP"
                    ],  
                    "sourceAddresses": [
                        "*"
                    ],
                    "sourceIpGroups": [],
                    "translatedAddress": "",
                    "translatedFqdn": "",
                    "translatedPort": ""
                }
            ]
        }
    ]
}
```

</details>
</p>

### Parameter usage: `networkRuleCollection`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"networkRuleCollection": {
    "value": [
        {
            "name": "Eviden-Network-Allow-RC",
            "ruleCollectionType": "FirewallPolicyFilterRuleCollection",
            "priority": 1500,
            "action": {
                "type": "Allow"
            },
            "rules": [
                {
                    "ruleType": "NetworkRule",
                    "name": "EvidenAllowTCP",
                    "ipProtocols": [
                        "TCP"
                    ],
                    "destinationPorts": [
                        "*"
                    ],
                    "sourceAddresses": [
                        "*"
                    ],
                    "sourceIpGroups": [],
                    "destinationIpGroups": [],
                    "destinationAddresses": [
                        "*"
                    ],
                    "destinationFqdns": []
                }
            ]
        },
        {
            "name": "Cu6-Network-Deny-RC",
            "priority": 100,
            "action": {
                "type": "Deny"
            },
            "rules": []
        }
    ]
}
```

</details>
</p>

### Parameter usage: `applicationRuleCollection`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"applicationRuleCollection": {
    "value": [
        {
            "name": "Eviden-Application-Allow-RC",
            "ruleCollectionType": "FirewallPolicyFilterRuleCollection",
            "priority": 1500,
            "action": {
                "type": "Allow"
            },
            "rules": [
                {
                    "ruleType": "ApplicationRule",
                    "name": "EvidenAllowMicrosoft",
                    "protocols": [
                        {
                            "protocolType": "Https",
                            "port": 443
                        }
                    ],
                    "fqdnTags": [],
                    "webCategories": [],
                    "targetFqdns": [
                        "*.microsoft.com"
                    ],
                    "targetUrls": [],
                    "terminateTLS": false,
                    "sourceAddresses": [
                        "*"
                    ],
                    "destinationAddresses": [],
                    "sourceIpGroups": []
                }
            ]
        },
        {
            "name": "Eviden-Application-Deny-RC",
            "priority": 500,
            "action": {
                "type": "Deny"
            },
            "rules": []
        }
    ]
}
```

</details>
</p>

### Parameter usage: `firewallIntrusionDetection`

<p>
<details>

<summary>Parameter JSON format</summary>

```json
"firewallIntrusionDetection": {
            "value": {
                "intrusionDetection": {
                    "configuration": {
                        "bypassTrafficSettings": [
                            {
                                "description": "test",
                                "destinationAddresses": [
                                    "10.4.5.6"
                                ],
                                "destinationIpGroups": [],
                                "destinationPorts": [
                                    "80"
                                ],
                                "name": "test",
                                "protocol": "tcp",
                                "sourceAddresses": [
                                    "10.1.3.4"
                                ],
                                "sourceIpGroups": []
                            }
                        ],
                        "privateRanges": [
                            "10.0.0.0/8",
                            "172.16.0.0/12",
                            "192.168.0.0/16",
                            "100.64.0.0/10"
                        ],
                        "signatureOverrides": [
                            {
                            "id": "2000015",
                            "mode": "Alert"
                            }
                        ]
                    },
                    "mode": "alert"
                }
            }
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
| `azureFirewallPolicyResourceId` | string | The resource id of the deployed Firewall Policy. |

## Deployment example

<p>
<details>

<summary>via Bicep module</summary>

```bicep
module firewallPolicy '../../childModules/firewallPolicy/firewallPolicy.bicep' = {
  scope: exampleResourceGroup
  name: 'firewallPolicy-deployment'
  params: {
    name: 'aaa-cnty-d-eune-policy-fw-hub'
    location: 'northeurope'
    tags: {
      Environment: 'Test'
      Contact: 'sample.user@custcompany.net'
      CostCenter: '8844'
      ServiceName: 'BackendServiceXYZ'
      Role: 'BackendXYZ'
    }
    azureFirewallPolicySku: 'Standard'
    enableProxy: false
    dnsServers : dnsServers
    fqdns: []
    ipAddresses: []
    threatIntelMode: 'Alert'
    enableTlsInspection: 'false'
    enableFirewallPolicyAnalytics: 'false'
    tlsKeyVaultCertId: ''
    firewallUserIdentity: ''
    tlsKeyVaultName: ''
    firewallIntrusionDetection: {
      configuration: {
        bypassTrafficSettings: [
          {
            description: 'string'
            destinationAddresses: [
              'string'
            ]
            destinationIpGroups: [
              'string'
            ]
            destinationPorts: [
              'string'
            ]
            name: 'string'
            protocol: 'string'
            sourceAddresses: [
              'string'
            ]
            sourceIpGroups: [
              'string'
            ]
          }
        ]
        privateRanges: [
          'string'
        ]
        signatureOverrides: [
          {
            id: 'string'
            mode: 'string'
          }
        ]
      }
      mode: 'string'
    },
    firewallRuleCollectionGroups: [
                {
                    "name": "DefaultApplicationRuleCollectionGroup",
                    "properties": {
                        "priority": 1500,
                        "ruleCollections": [
                            {
                                "name": "Eviden-Application-Allow-RC",
                                "ruleCollectionType": "FirewallPolicyFilterRuleCollection",
                                "priority": 1500,
                                "action": {
                                    "type": "Allow"
                                },
                                "rules": [
                                    {
                                        "ruleType": "ApplicationRule",
                                        "name": "EvidenAllowMicrosoft",
                                        "protocols": [
                                            {
                                                "protocolType": "Https",
                                                "port": 443
                                            }
                                        ],
                                        "fqdnTags": [],
                                        "webCategories": [],
                                        "targetFqdns": [
                                            "*.microsoft.com"
                                        ],
                                        "targetUrls": [],
                                        "terminateTLS": false,
                                        "sourceAddresses": [
                                            "*"
                                        ],
                                        "destinationAddresses": [],
                                        "sourceIpGroups": []
                                    }
                                ]
                            }
                        ]
                    }
                },
                {
                    "name": "DefaultNetworkRuleCollectionGroup",
                    "properties": {
                        "priority": 100,
                        "ruleCollections": [
                            {
                                "name": "Eviden-Network-Allow-RC",
                                "ruleCollectionType": "FirewallPolicyFilterRuleCollection",
                                "priority": 1500,
                                "action": {
                                    "type": "Allow"
                                },
                                "rules": [
                                    {
                                        "ruleType": "NetworkRule",
                                        "name": "EvidenAllowTCP",
                                        "ipProtocols": [
                                            "TCP"
                                        ],
                                        "destinationPorts": [
                                            "*"
                                        ],
                                        "sourceAddresses": [
                                            "*"
                                        ],
                                        "sourceIpGroups": [],
                                        "destinationIpGroups": [],
                                        "destinationAddresses": [
                                            "*"
                                        ],
                                        "destinationFqdns": []
                                    }
                                ]
                            }
                        ]
                    }
                },
                {
                    "name": "DefaultDnatRuleCollectionGroup",
                    "properties": {
                        "priority": 700,
                        "ruleCollections": [
                            {
                                "ruleCollectionType": "FirewallPolicyNatRuleCollection",
                                "action": {
                                    "type": "Dnat"
                                },
                                "rules": [
                                    {
                                        "ruleType": "NatRule",
                                        "name": "AllowRDP",
                                        "translatedAddress": "192.168.0.1",
                                        "translatedPort": "3389",
                                        "ipProtocols": [
                                            "TCP",
                                            "UDP"
                                        ],
                                        "sourceAddresses": [
                                            "192.168.0.1"
                                        ],
                                        "sourceIpGroups": [],
                                        "destinationAddresses": [
                                            "20.166.1.109"
                                        ],
                                        "destinationPorts": [
                                            "3389"
                                        ]
                                    }
                                ],
                                "name": "AllowRDP",
                                "priority": 700
                            }
                        ]
                    }
                }
            ]
    
}
```

</details>
</p>