/*
SUMMARY: Deploy Azure Firewall Policy.
DESCRIPTION: Deploy Azure Firewall Policy.
AUTHOR/S: surbhi.2.sharma@eviden.com
VERSION: 0.0.6
*/

//PARAMETERS
@description('Specifies the resource name for the Firewall Policy.')
param name string

@description('Specifies the tier of the Firewall Policy.')
@allowed([
  'Standard'
  'Premium'
])
param azureFirewallPolicySku string

@description('Specifies the location that will be used for deployment')
param location string

@description('Object which holds the Premium Firewall elements')
param firewallIntrusionDetection object

@description('Tag/s to assign to this resource.')
param tags object

@description('Specifies whether to enable or disable DNS Proxy on Firewalls attached to the Firewall Policy.')
param enableProxy bool

@description('resourceId of the Log Analytics workspace in the management subscription used with Firewall Policy Analytics.')
param workspace string

@description('Specifies the operation mode for Threat Intelligence.')
@allowed([
  'Alert'
  'Deny'
  'Off'
  ''
])
param threatIntelMode string

@description('Specifies an array of FQDNs for the ThreatIntel Allowlist.')
param fqdns array

@description('Specifies an array of IP addresses for the ThreatIntel Allowlist.')
param ipAddresses array

@description('All of the rule collection groups.')
param firewallRuleCollectionGroups array

@description('KeyVault Name for TLS Inspection')
param tlsKeyVaultName string

@description('Secret ID of the Certificate for TLS Inspection')
param tlsKeyVaultCertId string

@description('ID of the User Managed Identity for the TLS Inspection')
param firewallUserIdentity string

@description('Specify if TLS inspection should be enabled')
param enableTlsInspection bool

@description('Specifies if Firewall Firewall Policy Analytics should be enabled.')
param enableFirewallPolicyAnalytics bool

@description('Specify the DNS servers, by default it will be empty')
param dnsServers array = []

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

var policyInsightsConfig = {
  isEnabled: true
  logAnalyticsResources: {
    defaultWorkspaceId: {
      id: workspace
    }
  }
}

// RESOURCES
resource azureFirewallPolicy 'Microsoft.Network/firewallPolicies@2021-08-01' = {
  name: name
  location: location
  tags: tags
  identity: enableTlsInspection == true ? tlsUserIdentity : null
  properties: {
    sku: {
      tier: azureFirewallPolicySku
    }
    transportSecurity: enableTlsInspection == true ? tlsConfig : null
    insights: enableFirewallPolicyAnalytics == true ? policyInsightsConfig : null
    dnsSettings: enableProxy && dnsServers != null && length(dnsServers) > 0 ? {
      enableProxy: enableProxy
      servers: dnsServers
    } : dnsServers != null && length(dnsServers) > 0 ? {
      servers: dnsServers
    } : enableProxy && dnsServers != null && length(dnsServers) == 0 ? {
      enableProxy: enableProxy
    } : null
    threatIntelMode: threatIntelMode
    threatIntelWhitelist: {
      fqdns: fqdns
      ipAddresses: ipAddresses
    }
    intrusionDetection: contains(firewallIntrusionDetection, 'intrusionDetection') ? firewallIntrusionDetection.intrusionDetection : null
  }

}

@batchSize(1)
resource firewallPolicyRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = [for ruleGroups in firewallRuleCollectionGroups: {
  parent: azureFirewallPolicy
  name: ruleGroups.name
  properties: ruleGroups.properties
}]

// OUTPUTS
@description('The resource name of the deployed Firewall Policy.')
output firewallPolicyName string = azureFirewallPolicy.name

@description('The resource id of the deployed Firewall Policy.')
output azureFirewallPolicyResourceId string = azureFirewallPolicy.id
