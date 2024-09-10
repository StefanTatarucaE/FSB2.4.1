# childModules/firewall/firewall.bicep
Bicep module to deploy an Azure Firewall

## Description
This module deploys an Azure Firewall resource which uses an already existing Azure Firewall Policy as default, the policy needs to be deployed first (see childModules/firewallPolicy/firewallPolicy.bicep module).

## Prerequisites 
This module needs an Azure Firewall Policy and a Virtual Network resource with the dedicated subnet "AzureFirewallSubnet" already created. Without these prerequisites the deployment will fail.

## Module example use, conditionally deployed. 
```bicep
module firewall 'childModules/firewall/firewall.bicep' = if (azureFirewallEnabled) {
  name: 'AzureFirewall-deployment'
  params: {
    firewallName: connectivityHubFirewall
    tags: tags
    threatIntelMode: threatIntelMode
    firewallPublicIpAddressName: connectivityHubFirewallPip
    hubNetworkFirewallNumberOfPublicIPAddresses: hubNetworkFirewallNumberOfPublicIPAddresses
    hubNetworkAzureFirewallAvailabilityZones: hubNetworkAzureFirewallAvailabilityZones
    hubNetworkPublicIPAvailabilityZones: hubNetworkPublicIPAvailabilityZones
    hubNetworkVnetName: connectivityHubNetworkVnet
    firewallPolicyName: azureFirewallPolicyName
    firewallPolicyResourceGroup: resourceGroupName
    location: location
  }
}
```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- | 
| `firewallName` | `string` | true | Specifies the name of the Azure Firewall. |
| `tags` | `object` | true | A mapping of tags to assign to the resource. Can be empty object {}, in this case only the default tag {EvidenManaged: true} is deployed.  Additional Details [here](#object---tags).|
| `threatIntelMode` | `string` | true | Specifies the way of working for threat intelligence feature, can take the values 'Alert', 'Deny', 'Off'. |
| `azureFirewallSku` | `string` | true | The Azure Firewall SKU associated with the Firewall to deploy , can take the values 'Standard', 'Premium'. |
| `firewallPublicIpAddressName` | `string` | true | Specifies the name to be used for the public IP address(es). The actual resource names will be composed from this variable and the index from a 0-based array. E.g. for a deployment with three public IP addresses the names will be <firewallPublicIpAddressName>0, <firewallPublicIpAddressName>1, <firewallPublicIpAddressName>2. |
| `hubNetworkFirewallNumberOfPublicIPAddresses` | int | true | Specifies the number of Public IP Addresses the Firewall will use. (min 1 and max 100). |
| `hubNetworkAzureFirewallAvailabilityZones` | `string[]` | true | Zone numbers e.g. 1,2,3., Use empty array [] if no availability zones are required. |
| `hubNetworkPublicIPAvailabilityZones` | `string[]` | true | Zone numbers e.g. 1,2,3., Use empty array [] if no availability zones are required. |
| `hubNetworkVnetName` | `string` | true | Specifies the existing hub Virtual Network Name containing an AzureFirewallSubnet subnet. |
| `firewallPolicyName` | `string` | true | Specifies the name of the existing Azure Firewall policy resource. |
| `firewallPolicyResourceGroup` | `string` | true | Specifies the resource group where the Azure Firewall policy resource is deployed. |
| `location` | `string` | true | The location to be used for deployment. |


### Object - tags
Below is an example of the tags object

`"key"`:`"value"`

**Example:**
```json
{
    "EvidenManaged": "true",
    "Project": "Monitoring Parent Module",
    "ManagedBy": "AzureBicep"
}
```

## Module outputs

| Name | Description | Value |
| --- | --- | --- |
| `azureFirewallObject` | Object containing the Azure Firewall information. | `reference(firewall.name, '2021-08-01')` |
| `azureFirewallResourceId` | The Resource Id of the Firewall Policy  | `firewall.id` |

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "tags" : {
      "value": {
        "EvidenManaged": "true"
      }
    },
    "firewallName": {
      "value": "cu6-cnty-d-euwe-fw-hub"
    },
    "threatIntelMode": {
      "value": "Alert"
    },
    "firewallPublicIpAddressName": {
      "value": "cu6-cnty-d-euwe-pip-fw-hub"
    },
    "hubNetworkFirewallNumberOfPublicIPAddresses": {
      "value": 1
    },
    "hubNetworkPublicIPAvailabilityZones": {
      "value": []
    },
    "hubNetworkAzureFirewallAvailabilityZones": {
      "value": []
    },
    "hubNetworkVnetName": {
      "value": "cu6-cnty-d-euwe-vnet-hub"
    },
    "firewallPolicyName": {
      "value": "cu6-cnty-d-euwe-policy-fw-hub"
    },
    "firewallPolicyResourceGroup": {
      "value": "cu6-cnty-d-rsg-hub"
    },
    "location": {
      "value": "westeurope"
    }
  }
}
```