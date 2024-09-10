/*
SUMMARY: NIST R2 Policy child module.
DESCRIPTION: Deployment of NIST R2 Policy. Consists of assignment.
AUTHOR/S: klaasjan.dejager@eviden.com
VERSION: 0.0.2
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param nistSettings object

@description('Specify set assignment name for the Nist R2 audit deny initiative')
param nistR2AuditDenySetAssignmentName string

@description('Specify set assignment displayname for the Nist R2 audit deny initiative')
param nistR2AuditDenySetAssignmentDisplayName string

@description('Specify the policy definition id of the built-in NIST Initiative.')
param nistPolicyDefinitionId string

// VARIABLES
//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'NIST 800-171 R2 policy'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  policyDefinitionId: nistPolicyDefinitionId
}

// RESOURCE DEPLOYMENTS
//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: nistR2AuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: nistR2AuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      'IncludeArcMachines': {
        value: nistSettings.includeArcMachines
        }
        'membersToExcludeInLocalAdministratorsGroup': {
        value: nistSettings.membersToExcludeInLocalAdministratorsGroup
        }
        'membersToIncludeInLocalAdministratorsGroup': {
        value: nistSettings.membersToIncludeInLocalAdministratorsGroup
        }
        'NetworkWatcherResourceGroupName': {
        value: nistSettings.networkWatcherResourceGroupName
        }
        'logAnalyticsWorkspaceIDForVMAgents': {
        value: nistSettings.logAnalyticsWorkspaceIdForVmAgents
        }
        'minimumTLSVersionForWindowsServers': {
        value: nistSettings.minimumTlsVersionForWindowsServers
        }
        'effect-34c877ad-507e-4c82-993e-3452a6e0ad3c': {
        value: nistSettings.storageAccountRestrictNetworkAccess
        }
        'effect-2154edb9-244f-4741-9970-660785bccdaa': {
        value: nistSettings.vmImageBuilderPrivateLink
        }
        'effect-a6abeaec-4d90-4a02-805f-6b26c4d3fbe9': {
          value: nistSettings.keyVaultPrivateLink
          }
        'effect-45e05259-1eb5-4f70-9574-baf73e9d219b': {
        value: nistSettings.machineLearningWorkspacesPrivateLink
        }
        'effect-af35e2a4-ef96-44e7-a9ae-853dd97032c4': {
        value: nistSettings.springCloudNetworkInjection
        }
        'evaluatedSkuNames-af35e2a4-ef96-44e7-a9ae-853dd97032c4': {
        value: nistSettings.evaluatedSkuNamesSpringCloud
        }
        'effect-a049bf77-880b-470f-ba6d-9f21c530cf83': {
        value: nistSettings.cognitiveSearchPrivateLink
        }
        'effect-b54ed75b-3e1a-44ac-a333-05ba39b99ff0': {
        value: nistSettings.serviceFabricShouldUseAzureAd
        }
        'effect-71ef260a-8f18-47b7-abcb-62d0673d94dc': {
        value: nistSettings.cognitiveSearchLocalAuthenticationDisabled
        }
        'effect-1d84d5fb-01f6-4d12-ba4f-4a26081d403d': {
        value: nistSettings.vmMigratedToNewArm
        }
        'effect-37e0d2fe-28a5-43d6-a273-67d37d1f5606': {
        value: nistSettings.storaceAccountMigratedToNewArm
        }
        'evaluatedSkuNames-ef619a2c-cc4d-4d03-b2ba-8c94a834d85b': {
        value: nistSettings.evaluatedSkuNamesApiMgmt
        }
        'effect-862e97cf-49fc-4a5c-9de4-40d4e2e7c8eb': {
        value: nistSettings.cosmosDbFirewallRules
        }
        'effect-d0793b48-0edc-4296-a390-4c75d1bdfd71': {
        value: nistSettings.acrUnrestrictedNetworkAccess
        }
        'effect-2a1a9cdf-e04d-429a-8416-3bfb72a1b26f': {
        value: nistSettings.storageAccountShouldRestrictNetworkAccessVirtualRules
        }
        'effect-55615ac9-af46-4a59-874e-391cc3dfb490': {
        value: nistSettings.keyvaultsDisablePublicNetworkAccess
        }
        'effect-1b8ca024-1d5c-4dec-8995-b1a932b41780': {
        value: nistSettings.sqlDbShouldDisablePublicNetworkAccess
        }
        'effect-037eea7a-bd0a-46c5-9a66-03aea78705d3': {
        value: nistSettings.cognitiveSearchAccountsRestrictNetworkAccess
        }
        'effect-0725b4dd-7e76-479c-a735-68e7ee23d5ca': {
        value: nistSettings.cognitiveServiceAccountsDisablePublicNetworkAccess
        }
        'effect-4fa4b6c0-31ca-4c0d-b10d-24b96f62a751': {
        value: nistSettings.storageAccountPublicAccessDisallowed
        }
        'effect-ee980b6d-0eca-4501-8d54-f6290fd512c3': {
        value: nistSettings.cognitiveSearchDisablePublicNetworkAccess
        }
        'requiredRetentionDays': {
        value: nistSettings.requiredRetentionDays
        }
        'setting-a6fb4358-5bf4-4ad7-ba82-2cd2f41ce5e9': {
        value: nistSettings.requiredAuditSettingForSqlServer
        }
        'effect-febd0533-8e55-448f-b837-bd0e06f16469': {
        value: nistSettings.kubernetesOnlyAllowedImages
        }
        'excludedNamespaces': {
        value: nistSettings.kubernetesExcludedNamespaces
        }
        'namespaces': {
        value: nistSettings.kubernetesNamespaces
        }
        'labelSelector': {
        value: nistSettings.kubernetesLabelSelector
        }
        'allowedContainerImagesRegex-febd0533-8e55-448f-b837-bd0e06f16469': {
        value: nistSettings.allowedContainerImagesRegex
        }
        'excludedContainers': {
        value: nistSettings.kubernetesExcludedContainers
        }
        'effect-95edb821-ddaf-4404-9732-666045e056b4': {
        value: nistSettings.kubernetesDisallowPrivilegedContainers
        }
        'effect-233a2a17-77ca-4fb1-9b6b-69223d272a44': {
        value: nistSettings.kubernetesAllowedPorts
        }
        'allowedServicePortsList-233a2a17-77ca-4fb1-9b6b-69223d272a44': {
        value: nistSettings.kubernetesAllowedServicePortsList
        }
        'effect-e345eecc-fa47-480f-9e88-67dcc122b164': {
        value: nistSettings.kubernetesResourceLimitsExceeded
        }
        'cpuLimit-e345eecc-fa47-480f-9e88-67dcc122b164': {
        value: nistSettings.kubernetesCpuLimit
        }
        'memoryLimit-e345eecc-fa47-480f-9e88-67dcc122b164': {
        value: nistSettings.kubernetesMemoryLimit
        }
        'effect-f06ddb64-5fa3-4b77-b166-acb36f7f6042': {
        value: nistSettings.kubernetesApprovedUserAndGroupsId
        }
        'runAsUserRule-f06ddb64-5fa3-4b77-b166-acb36f7f6042': {
        value: nistSettings.kubernetesRunAsUserRule
        }
        'runAsUserRanges-f06ddb64-5fa3-4b77-b166-acb36f7f6042': {
        value: nistSettings.kubernetesRunAsUserRanges
        }
        'runAsGroupRule-f06ddb64-5fa3-4b77-b166-acb36f7f6042': {
        value: nistSettings.kubernetesRunAsGroupRule
        }
        'runAsGroupRanges-f06ddb64-5fa3-4b77-b166-acb36f7f6042': {
        value: nistSettings.kubernetesRunAsGroupRanges
        }
        'supplementalGroupsRule-f06ddb64-5fa3-4b77-b166-acb36f7f6042': {
        value: nistSettings.kubernetesSupplementalGroupsRule
        }
        'supplementalGroupsRanges-f06ddb64-5fa3-4b77-b166-acb36f7f6042': {
        value: nistSettings.kubernetesSupplementalGroupsRanges
        }
        'fsGroupRule-f06ddb64-5fa3-4b77-b166-acb36f7f6042': {
        value: nistSettings.kubernetesFsGroupRule
        }
        'fsGroupRanges-f06ddb64-5fa3-4b77-b166-acb36f7f6042': {
        value: nistSettings.kubernetesFsGroupRanges
        }
        'effect-1c6e92c9-99f0-4e55-9cf2-0c234dc48f99': {
        value: nistSettings.kubernetesContainerNotAllowPrivilegeEscalation
        }
        'effect-47a1ee2f-2a2a-4576-bf2a-e0e36709c2b8': {
        value: nistSettings.kubernetesNotShareHostProcesOrIpc
        }
        'effect-df49d893-a74c-421d-bc95-c663042e5b80': {
        value: nistSettings.kubernetesRunWithReadOnlyFs
        }
        'effect-c26596ff-4d70-4e6a-9a30-c2506bd2f80c': {
        value: nistSettings.kubernetesOnlyAllowedCapabilities
        }
        'allowedCapabilities-c26596ff-4d70-4e6a-9a30-c2506bd2f80c': {
        value: nistSettings.kubernetesAllowedCapabilities
        }
        'requiredDropCapabilities-c26596ff-4d70-4e6a-9a30-c2506bd2f80c': {
        value: nistSettings.kubernetesRequiredDropCapabilities
        }
        'effect-511f5417-5d12-434d-ab2e-816901e72a5e': {
        value: nistSettings.kubernetesOnlyAppArmorProfiles
        }
        'allowedProfiles-511f5417-5d12-434d-ab2e-816901e72a5e': {
        value: nistSettings.kubernetesAllowedAppArmorProfiles
        }
        'effect-82985f06-dc18-4a48-bc1c-b9f4f0098cfe': {
        value: nistSettings.kubernetesClusterPodsApprovedHostNetworkAndPortRanges
        }
        'allowHostNetwork-82985f06-dc18-4a48-bc1c-b9f4f0098cfe': {
        value: nistSettings.kubernetesAllowHostNetwork
        }
        'minPort-82985f06-dc18-4a48-bc1c-b9f4f0098cfe': {
        value: nistSettings.kubernetesMinPortRange
        }
        'maxPort-82985f06-dc18-4a48-bc1c-b9f4f0098cfe': {
        value: nistSettings.kubernetesMaxPortRange
        }
        'effect-098fc59e-46c7-4d99-9b16-64990e543d75': {
        value: nistSettings.kubernetesHostPadVolumes
        }
        'allowedHostPaths-098fc59e-46c7-4d99-9b16-64990e543d75': {
        value: nistSettings.kubernetesAllowedHostPaths
        }
        'maximumValidityInMonths-0a075868-4c26-42ef-914c-5bc007359560': {
        value: nistSettings.keyVaultMaximumValidityInMonths
        }
        'effect-0a075868-4c26-42ef-914c-5bc007359560': {
        value: nistSettings.maximumCertificateValidity
        }
        'effect-98728c90-32c7-4049-8429-847dc0f4fe37': {
        value: nistSettings.keyvaultSecretExpirationDate
        }
        'effect-152b15f7-8e1f-4c1f-ab71-8c010ba5dbc0': {
        value: nistSettings.keyvaultKeysExpirationDate
        }
        'effect-0b60c0b2-2dc2-4e1c-b5c9-abbed971de53': {
        value: nistSettings.keyvaultPurgeProtectionEnabled
        }
        'effect-1e66c121-a66a-4b1f-9b83-0fd99bf0fc2d': {
        value: nistSettings.keyvaultSoftDeleteEnabled
        }
        'effect-055aa869-bc98-4af8-bafc-23f1ab6ffe2c': {
        value: nistSettings.wafEnabledAzureFrontDoor
        }
        'effect-564feb30-bf6a-4854-b4bb-0d2d2d1e6c66': {
        value: nistSettings.wafEnabledAppGateway
        }
        'effect-1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d': {
        value: nistSettings.kubernetesAccessibleOverHttps
        }
        'effect-d9da03a1-f3c3-412a-9709-947156872263': {
        value: nistSettings.hdinsightUseEncryptionInTransit
        }
        'effect-22bee202-a82f-4305-9a2a-6d7f44d4dedb': {
        value: nistSettings.azureCacheForRedisSecureConnection
        }
        'effect-404c3081-a854-4457-ae30-26a93ef643f9': {
        value: nistSettings.secureTransferToStorageAccountEnabled
        }
        'effect-86efb160-8de7-451d-bc08-5d475b0aadae': {
        value: nistSettings.azureDataBoxJobsShouldUseCmk
        }
        'supportedSKUs-86efb160-8de7-451d-bc08-5d475b0aadae': {
        value: nistSettings.azureDataBoxCmkSupportedSku
        }
        'effect-4ec52d6d-beb7-40c4-9a9e-fe753254690e': {
        value: nistSettings.dataFactoryShouldUseCmk
        }
        'effect-64d314f6-6062-4780-a861-c23e8951bee5': {
        value: nistSettings.hdInsightShouldUseCmk
        }
        'effect-1fd32ebd-e4c3-4e13-a54a-d7422d4d95f6': {
        value: nistSettings.hdInsightEncryptionAtRest
        }
        'effect-fa298e57-9444-42ba-bf04-86e8470e32c7': {
        value: nistSettings.savedQueriesSavedInStorageAccount
        }
        'effect-67121cc7-ff39-4ab8-b7e3-95b84dab487d': {
        value: nistSettings.cognitiveSearchShouldUseCmk
        }
        'effect-1f905d99-2ab7-462c-a6b0-f709acca6c8f': {
        value: nistSettings.cosmosDbShouldUseCmk
        }
        'effect-5b9159ae-1701-4a6f-9a7a-aa9c8ddd0580': {
        value: nistSettings.acrShouldUseCmk
        }
        'effect-ba769a63-b8cc-4b2d-abf6-ac33c7204be8': {
        value: nistSettings.machineLearningWorkspacesShouldUseCmk
        }
        'effect-81e74cea-30fd-40d5-802f-d72103c2aaaa': {
        value: nistSettings.dataExplorerShouldUseCmk
        }
        'effect-0aa61e00-0a01-4a3c-9945-e93cffedf0e6': {
        value: nistSettings.containerInstanceContainerGroupShouldUseCmk
        }
        'effect-47031206-ce96-41f8-861b-6a915f3de284': {
        value: nistSettings.iotHubDeviceShouldUseCmk
        }
        'effect-87ba29ef-1ab3-4d82-b763-87fcd4f531f7': {
        value: nistSettings.streamAnalyticsJobsShouldUseCmk
        }
        'effect-51522a96-0869-4791-82f3-981000c2c67f': {
        value: nistSettings.botServiceShouldUseCmk
        }
        'effect-b5ec538c-daa0-4006-8596-35468b9148e8': {
        value: nistSettings.storageAccountEncryptionScopesShouldUseCmk
        }
        'effect-970f84d8-71b6-4091-9979-ace7e3fb6dbb': {
        value: nistSettings.hpcCacheAccountsShouldUseCmk
        }
        'effect-56a5ee18-2ae6-4810-86f7-18e39ce5629b': {
        value: nistSettings.automationAccountsShouldUseCmk
        }
        'effect-2e94d99a-8a36-4563-bc77-810d8893b671': {
        value: nistSettings.recoveryVaultShouldUseCmkForBackedUpData
        }
        'enableDoubleEncryption-2e94d99a-8a36-4563-bc77-810d8893b671': {
        value: nistSettings.recoveryVaultEnableDoubleEncryption
        }
        'effect-1fafeaf6-7927-4059-a50a-8eb2a7a6f2b5': {
        value: nistSettings.logicAppIntegrationShouldBeEncrypted
        }
        'effect-99e9ccd8-3db9-4592-b0d1-14b1715a4d8a': {
        value: nistSettings.azureBatchShouldUseCmk
        }
        'effect-1f68a601-6e6d-4e42-babf-3f643a047ea2': {
        value: nistSettings.azureMonitorLogClustersShouldUseCmk
        }
        'effect-f7d52b2d-e161-4dfa-a82b-55e564167385': {
        value: nistSettings.synapseWorkSpaceShouldUseCmk
        }
        'effect-7d7be79c-23ba-4033-84dd-45e2a5ccdd67': {
        value: nistSettings.kubernetesOsAndDataDiskShouldUseCmk
        }
        'effect-ca91455f-eace-4f96-be59-e6e2c35b4816': {
        value: nistSettings.managedDiskShouldUseCmkAndPmk
        }
        'effect-702dd420-7fcc-42c5-afe8-4026edd20fe0': {
        value: nistSettings.osAndDataDiskShouldUseCmk
        }
        'effect-617c02be-7f02-4efd-8836-3180d47b6c68': {
        value: nistSettings.serviceFabricClusterClusterProtectionLevelSet
        }
        'effect-ec068d99-e9c7-401f-8cef-5bdde4e6ccf1': {
        value: nistSettings.dataExplorerShouldEnableDoubleEncryption
        }
        'effect-c349d81b-9985-44ae-a8da-ff98d108ede8': {
        value: nistSettings.dataBoxJobsShouldEnableDoubleEncryption
        }
        'supportedSKUs-c349d81b-9985-44ae-a8da-ff98d108ede8': {
        value: nistSettings.dataBoxsupportedSku
        }
        'effect-3657f5a0-770e-44a3-b44e-9431ba1e9735': {
        value: nistSettings.automationAccountVariablesShouldBeEncrypted
        }
        'effect-b4ac1030-89c5-4697-8e00-28b5ba6a8811': {
        value: nistSettings.stackEdgeDevicesShouldUseDoubleEncryption
        }
        'effect-ea0dfaed-95fb-448c-934e-d6e713ce393d': {
        value: nistSettings.monitorClusterLogsShouldDoubleEncryption
        }
        'effect-3a58212a-c829-4f13-9872-6371df2fd0b4': {
        value: nistSettings.databaseForMySqlInfrastructureEncryption
        }
        'effect-24fba194-95d6-48c0-aea7-f65bf859c598': {
        value: nistSettings.postgresSqlInfrastructureEncryption
        }
        'effect-4733ea7b-a883-42fe-8cac-97454c2a9e4a': {
        value: nistSettings.storageAccountsInfrastructureEncryption
        }
        'effect-f4b53539-8df9-40e4-86c6-6b607703bd4e': {
        value: nistSettings.diskEncryptionEnabledOnDataExplorer
        }
        'effect-41425d9f-d1a5-499a-9932-f8ed8453932c': {
        value: nistSettings.kubernetesTempCacheDiskEncryptionAtHost
        }
        'effect-fc4d8e41-e223-45ea-9bf5-eada37891d87': {
        value: nistSettings.vmAndVmssEncryptionAtHost
        }
        'NotAvailableMachineState-bed48b13-6647-468e-aa2f-1af1d3f4dd40': {
        value: nistSettings.windowsDefenderNotAvailableMachineState
        }
        'NetworkSecurityConfigureEncryptionTypesAllowedForKerberos-1221c620-d201-468c-81e7-2817e6107e84': {
        value: nistSettings.networkSecurityConfigureEncryptionTypesAllowedForKerberos
        }
        'NetworkSecurityLANManagerAuthenticationLevel-1221c620-d201-468c-81e7-2817e6107e84': {
        value: nistSettings.networkSecurityLanManagerAuthenticationLevel
        }
        'NetworkSecurityLDAPClientSigningRequirements-1221c620-d201-468c-81e7-2817e6107e84': {
        value: nistSettings.networkSecurityLdapClientSigningRequirements
        }
        'NetworkSecurityMinimumSessionSecurityForNTLMSSPBasedIncludingSecureRPCClients-1221c620-d201-468c-81e7-2817e6107e84': {
        value: nistSettings.networkSecurityMinimumSessionSecurityForNtlmsSpBasedIncludingSecureRpcclients
        }
        'NetworkSecurityMinimumSessionSecurityForNTLMSSPBasedIncludingSecureRPCServers-1221c620-d201-468c-81e7-2817e6107e84': {
        value: nistSettings.networkSecurityMinimumSessionSecurityForNtlmsSpBasedIncludingSecureRpcServers
        }
    }
    policyDefinitionId: assignmentProperties.policyDefinitionId
  }
}

// OUTPUTS
