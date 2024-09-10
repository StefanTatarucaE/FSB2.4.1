/*
SUMMARY: Firewall solution
DESCRIPTION: Parent module to deploy the Firewall components (Firewall Policy and Azure Firewall)           
AUTHOR/S: ELZ Azure Team
VERSION: 0.0.6
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

// PARAMETERS

@description('The Id of the management subscription. To be provided by the pipeline.')
param managementSubscriptionId string

@description('Specifies if Azure Firewall is to be deployed.')
param deployAzureFirewall bool = false

@description('Specifies if Azure Firewall Policy is to be deployed.')
param deployFirewallPolicy bool = false

@description('A mapping of additional tags to assign to the resource.')
param additionalNetworkingTags object = {}

@description('Specifies the location where the Azure Resource will be created')
param location string = deployment().location

@description('Specifies the tier of the Firewall Policy.')
@allowed([
  'Standard'
  'Premium'
])
param azureFirewallPolicySku string = 'Standard'

@description('Specifies the SKU of the Firewall Policy.')
@allowed([
  'Standard'
  'Premium'
])
param azureFirewallSku string = 'Standard'

@description('Object which holds the Premium Firewall elements')
param firewallIntrusionDetection object = {}

@description('Specifies if Firewall Intrusion detection is enabled. Goes together with parameter firewallIntrusionDetection ')
param enableFirewallIntrusionDetection bool = false

@description('Specifies if Firewall Firewall Policy Analytics should be enabled.')
param enableFirewallPolicyAnalytics bool = false

@description('Specifies whether to enable or disable DNS Proxy on Firewalls attached to the Firewall Policy.')
param firewallPolicyEnableProxy bool = false

@description('Specifies the operation mode for Firewall Policy Threat Intelligence. Default set to "Alert"')
@allowed([
  'Alert'
  'Deny'
  'Off'
  ''
])
param firewallThreatIntelMode string = 'Alert'

@description('Specifies an array of FQDNs for the ThreatIntel Allowlist. Default: []')
param firewallPolicyWhitelistFqdns array = []

@description('Specifies an array of IP addresses for the ThreatIntel Allowlist. Default: []')
param firewallPolicyWhitelistIpAddresses array = []

@description('Array of the rule collection groups containing all the Rule Collections and Rules.')
param firewallRuleCollectionGroups array

@description('Availability zone numbers, e.g. 1,2,3. Use empty array [] if no availability zones are required')
param firewallAvailabilityZones array = []

@description('Number of Public IP Addresses the Firewall will use. (min 1 and max 100)')
@minValue(1)
@maxValue(100)
param firewallNrOfPublicIps int = 1

@description('KeyVault Name for TLS Inspection')
param tlsKeyVaultName string = ''

@description('Secret ID of the Certificate for TLS Inspection')
param tlsKeyVaultCertId string = ''

@description('ID of the User Managed Identity for the TLS Inspection')
param firewallUserIdentity string = ''

@description('Specify if TLS inspection should be enabled')
param enableTlsInspection bool = false

@description('Specifies the DNS servers on Firewalls attached to the Firewall Policy.')
param firewallPolicyDnsServers array = []

// VARIABLES

var firewallPolicyResourceGroupName = namingData.firewallPolicyResourceGroup.name

var resourceGroupNameHub = namingData.hubResourceGroup.name

var virtualNetworkName = namingData.connectivityHubNetworkVnet.name

var namingJsonData = {
  cnty: {
    definition: json(loadTextContent('../../cntyNaming.json'))
  }
  mgmt: {
    definition: json(loadTextContent('../../mgmtNaming.json'))
  }
}

var namingData = namingJsonData.cnty.definition
var mgmtNamingData = namingJsonData.mgmt.definition

// Variable which contains a unique value based on subscriptionId & deployment location
// used to deploy the child modules on subscription level.
#disable-next-line no-loc-expr-outside-params
var uniqueDeployPrefix = take(uniqueString(subscription().subscriptionId, deployment().location), 6)

//Variables to load from the naming convention files for branding, tagging and resource naming.
var tagPrefix = namingData.tagPrefix.name
var tagValuePrefix = namingData.tagValuePrefix.name
var tags = union(additionalNetworkingTags, { '${tagPrefix}Purpose': '${tagValuePrefix}NetworkingHub' }, { '${tagPrefix}Managed': 'true' })

var firewallPolicyName = namingData.connectivityHubFirewallPolicy.name
var firewallPolicyNamePremium = namingData.connectivityHubFirewallPolicyPremium.name
var firewallName = namingData.connectivityHubFirewall.name
var firewallPublicIpAddressName = namingData.connectivityHubFirewallPip.name

// Name of the Loganalytics workspace
var workspaceName = mgmtNamingData.monitoringWorkspace.name

// RESOURCE DEPLOYMENTS

// This module is called to fetch the log analytics workspace ID present in mgmt subscription. The workspace ID is used in nistR2AuditDeny policy
module existingWorkspaceInMgmt '../../helperModules/getResourceId/getResourceId.bicep' =  {
  scope: subscription(managementSubscriptionId)
  name: '${uniqueDeployPrefix}-monitoringWorkspace-getResourceId'
  params: {
    resourceGroupName: mgmtNamingData.monitoringResourceGroup.name
    resourceName: workspaceName
    resourceType: 'monitoringWorkspace'
  }
}

// Create a resource group to hold the Firewall Policy.
resource firewallPolicyResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (deployFirewallPolicy) {
  name: firewallPolicyResourceGroupName
  location: location
  tags: tags
}

resource networkingResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupNameHub
}

// Deploy Azure Firewall Policy
module firewallPolicy '../../childModules/firewallPolicy/firewallPolicy.bicep' = if (deployFirewallPolicy) {
  scope: firewallPolicyResourceGroup
  name: '${uniqueDeployPrefix}-firewallPolicy-deployment'
  params: {
    name: (azureFirewallPolicySku == 'Premium') ? firewallPolicyNamePremium : firewallPolicyName
    firewallIntrusionDetection: (enableFirewallIntrusionDetection && azureFirewallSku == 'Premium' && azureFirewallPolicySku == 'Premium') ? firewallIntrusionDetection : {}
    location: location
    tags: tags
    azureFirewallPolicySku: azureFirewallPolicySku
    enableProxy: firewallPolicyEnableProxy
    dnsServers: firewallPolicyDnsServers
    fqdns: firewallPolicyWhitelistFqdns
    ipAddresses: firewallPolicyWhitelistIpAddresses
    workspace: existingWorkspaceInMgmt.outputs.resourceID
    firewallRuleCollectionGroups: firewallRuleCollectionGroups
    threatIntelMode: firewallThreatIntelMode
    enableTlsInspection: enableTlsInspection
    enableFirewallPolicyAnalytics:enableFirewallPolicyAnalytics
    tlsKeyVaultCertId: tlsKeyVaultCertId
    firewallUserIdentity: firewallUserIdentity
    tlsKeyVaultName: tlsKeyVaultName
  }
}

// Deploy Azure Firewall
module firewall '../../childModules/firewall/firewall.bicep' = if (deployAzureFirewall) {
  scope: networkingResourceGroup
  name: '${uniqueDeployPrefix}-azureFirewall-deployment'
  params: {
    firewallName: firewallName
    azureFirewallSku: azureFirewallSku
    tags: tags
    threatIntelMode: firewallThreatIntelMode
    firewallPublicIpAddressName: firewallPublicIpAddressName
    hubNetworkFirewallNumberOfPublicIPAddresses: firewallNrOfPublicIps
    hubNetworkAzureFirewallAvailabilityZones: firewallAvailabilityZones
    hubNetworkPublicIPAvailabilityZones: firewallAvailabilityZones
    hubNetworkVnetName: virtualNetworkName
    firewallPolicyName: (azureFirewallPolicySku == 'Premium') ? firewallPolicyNamePremium : firewallPolicyName
    firewallPolicyResourceGroup: firewallPolicyResourceGroupName
    location: location
  }
  dependsOn: [
    firewallPolicy
  ]
}
