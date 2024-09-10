/*
SUMMARY: CIS Policy child module.
DESCRIPTION: Deployment of CIS Policy. Consists of assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scop for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Specify name for assignment of CIS audit deny initiative.')
param cisAuditDenySetAssignmentName string

@description('Specify the policy definition id of the built-in CIS Initiative.')
param cisPolicyDefinitionId string

@description('Specify display name for assignment of CIS audit deny initiative.')
param cisAuditDenySetAssignmentDisplayName string

@description('Object which sets the values of the policy set definition parameters.')
param cisSettings object

// VARIABLES
//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'None' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'CIS Azure Foundations Benchmark'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  policyDefinitionId: cisPolicyDefinitionId
}

// RESOURCE DEPLOYMENTS
//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: cisAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: cisAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {

      'requiredRetentionDays': {
        value: cisSettings.resourceLogsRequiredRetentionDays
      }
      'setting-a6fb4358-5bf4-4ad7-ba82-2cd2f41ce5e9': {
        value: cisSettings.requiredAuditSettingsforSqlServers
      }
      'effect-4da35fc9-c9e7-4960-aec9-797fe7d9051d': {
        value: cisSettings.defenderForServersEnabled
      }
      'effect-339353f6-2387-4a45-abe4-7f529d121046': {
        value: cisSettings.guestOwnerPermissionRemoved
      }
      'effect-94e1c2ac-cbbe-4cac-a2b5-389c812dee87': {
        value: cisSettings.guestWritePermissionRemoved
      }
      'effect-e9ac8f8e-ce22-4355-8f04-99b911d6be52': {
        value: cisSettings.guestReadPermissionRemoved
      }
      'effect-931e118d-50a1-4457-a5e4-78550e086c52': {
        value: cisSettings.mfaWithWritePermissionEnabled
      }
      'effect-e3e008c3-56b9-4133-8fd7-d3347377402a': {
        value: cisSettings.mfaWithOwnerPermissionEnabled
      }
      'effect-2913021d-f2fd-4f3d-b958-22354e2bdbcb': {
        value: cisSettings.defenderForAppServiceEnabled
      }
      'effect-d8cf8476-a2ec-4916-896e-992351803c44': {
        value: cisSettings.maximumDaysToRotateKeys
      }
      'maximumDaysToRotate-d8cf8476-a2ec-4916-896e-992351803c44': {
        value: cisSettings.maximumDaysToRotate
      }
      'effect-7fe3b40f-802b-4cdd-8bd4-fd799c948cc2': {
        value: cisSettings.defenderForSqlDbEnabled
      }
      'effect-6581d072-105e-4418-827f-bd446d56421b': {
        value: cisSettings.defenderForSqlServerEnabled
      }
      'effect-308fbb08-4ab8-4e67-9b29-592e93fb94fa': {
        value: cisSettings.defenderForStorageEnabled
      }
      'effect-1c988dd6-ade4-430f-a608-2a3e5b0a6d38': {
        value: cisSettings.defenderForContainersEnabled
      }
      'effect-0e6763cc-5078-4e64-889d-ff4d9a839047': {
        value: cisSettings.defenderForKeyvaultsEnabled
      }
      'effect-475aae12-b88a-4572-8b36-9b712b2b3a17': {
        value: cisSettings.autoProvisionLaAgentEnabled
      }
      'effect-4f4f78b8-e367-4b10-a341-d9a4ad5cf1c7': {
        value: cisSettings.subscriptionSecurityContact
      }
      'effect-6e2593d9-add6-4083-9c9b-4b7d2188c899': {
        value: cisSettings.emailHighSeverityAlert
      }
      'effect-404c3081-a854-4457-ae30-26a93ef643f9': {
        value: cisSettings.secureTransferStorageAccount
      }
      'effect-4fa4b6c0-31ca-4c0d-b10d-24b96f62a751': {
        value: cisSettings.storagePublicAccessDisallowed
      }
      'effect-34c877ad-507e-4c82-993e-3452a6e0ad3c': {
        value: cisSettings.storageAccountRestrictNetworkAccess
      }
      'effect-2a1a9cdf-e04d-429a-8416-3bfb72a1b26f': {
        value: cisSettings.storageAccountRestrictNetworkAccessVirtualNetworkRules
      }
      'effect-c9d007d0-c057-4772-b18c-01e546713bcd': {
        value: cisSettings.storageAccountAllowTrustedMsServices
      }
      'effect-6fac406b-40ca-413b-bf8e-0bf964659c25': {
        value: cisSettings.storageAccountCmkForEncryption
      }
      'effect-a6fb4358-5bf4-4ad7-ba82-2cd2f41ce5e9': {
        value: cisSettings.auditSqlEnabled
      }
      'effect-17k78e20-9358-41c9-923c-fb736d382a12': {
        value: cisSettings.tdeOnSqlEnabled
      }
      'effect-89099bee-89e0-4b26-a5f4-165451757743': {
        value: cisSettings.sqlServerAuditLogRetention
      }
      'effect-abfb4388-5bf4-4ad7-ba82-2cd2f41ceae9': {
        value: cisSettings.defenderForSqlOnUnprotectedSqlServersEnabled
      }
      'effect-abfb7388-5bf4-4ad7-ba99-2cd2f41cebb9': {
        value: cisSettings.defenderForSqlOnUnprotectedSqlMiEnabled
      }
      'effect-ef2a8f2a-b3d9-49cd-a8a8-9a3aaaf647d9': {
        value: cisSettings.vulnerabilityAssessmentEnabledOnSqlServers
      }
      'effect-1b7aa243-30e4-4c9e-bca8-d0d3022b634a': {
        value: cisSettings.vulnerabilityAssessmentEnabledOnMiInstances
      }
      'effect-d158790f-bfb0-486c-8631-2dc6b4e8e6af': {
        value: cisSettings.enforcedSslEnabledPostgresSql
      }
      'effect-eb6f77b9-bd53-4e35-a23d-7f65d5f0e43d': {
        value: cisSettings.enabledLogCheckpointsPostgresSql
      }
      'effect-eb6f77b9-bd53-4e35-a23d-7f65d5f0e442': {
        value: cisSettings.enabledLogConnectionsPostgresSql
      }
      'effect-eb6f77b9-bd53-4e35-a23d-7f65d5f0e446': {
        value: cisSettings.enabledLogDisconnectionsPostgresSql
      }
      'effect-5345bb39-67dc-4960-a1bf-427e16b9a0bd': {
        value: cisSettings.enabledConnectionThrottlingPostgresSql
      }
      'effect-1f314764-cb73-4fc9-b863-8eca98ac36e9': {
        value: cisSettings.azureAdAdminShouldbeProvisionForSqlServer
      }
      'effect-0a370ff3-6cab-4e85-8995-295fd854c5b8': {
        value: cisSettings.sqlServersShouldUseCmkAtRest
      }
      'effect-ac01ad65-10e5-46df-bdd9-6b0cad13e1d2': {
        value: cisSettings.sqlMiShouldUseCmkAtRest
      }
      'effect-fbb99e8e-e444-4da0-9ff1-75c92f5a85b2': {
        value: cisSettings.storageAccountWithActivityLogsShouldUseCmk
      }
      'effect-cf820ca0-f99e-4f3e-84fb-66e913812d21': {
        value: cisSettings.resourceLogsInKeyvaultsEnabled
      }
      'effect-c5447c04-a4d7-4ba8-a263-c9ee321a6858-MicrosoftAuthorization-policyAssignments-write': {
        value: cisSettings.activityLogAlertForPolicyWrite
      }
      'effect-c5447c04-a4d7-4ba8-a263-c9ee321a6858-MicrosoftAuthorization-policyAssignments-delete': {
        value: cisSettings.activityLogAlertForPolicyDelete
      }
      'effect-b954148f-4c11-4c38-8221-be76711e194a-MicrosoftNetwork-networkSecurityGroups-write': {
        value: cisSettings.activityLogAlertForNsgWrite
      }
      'effect-b954148f-4c11-4c38-8221-be76711e194a-MicrosoftNetwork-networkSecurityGroups-delete': {
        value: cisSettings.activityLogAlertForNsgDelete
      }
      'effect-b954148f-4c11-4c38-8221-be76711e194a-MicrosoftNetwork-networkSecurityGroups-securityRules-write': {
        value: cisSettings.activityLogAlertForNsgRuleWrite
      }
      'effect-b954148f-4c11-4c38-8221-be76711e194a-MicrosoftNetwork-networkSecurityGroups-securityRules-delete': {
        value: cisSettings.activityLogAlertForNsgRuleDelete
      }
      'effect-b954148f-4c11-4c38-8221-be76711e194a-MicrosoftSql-servers-firewallRules-write': {
        value: cisSettings.activityLogAlertForFirewallRulesWrite
      }
      'effect-b954148f-4c11-4c38-8221-be76711e194a-MicrosoftSql-servers-firewallRules-delete': {
        value: cisSettings.activityLogAlertForFirewallRulesDelete
      }
      'effect-91a78b24-f231-4a8a-8da9-02c35b2b6510': {
        value: cisSettings.appServiceResourceLogsEnabled
      }
      'effect-428256e6-1fac-4f48-a757-df34c2b3336d': {
        value: cisSettings.batchAccountsResourceLogsEnabled
      }
      'effect-057ef27e-665e-4328-8ea3-04b3122bd9fb': {
        value: cisSettings.azureDatalakeStoreResourceLogsEnabled
      }
      'effect-c95c74d9-38fe-4f0d-af86-0c7d626a315c': {
        value: cisSettings.dataLakeAnalyticsResourceLogsEnabled
      }
      'effect-83a214f7-d01a-484b-91a9-ed54470c9a6a': {
        value: cisSettings.eventHubsResourceLogsEnabled
      }
      'effect-383856f8-de7f-44a2-81fc-e5135b5c2aa4': {
        value: cisSettings.iotHubResourceLogsEnabled
      }
      'effect-34f95f76-5386-4de7-b824-0d8478470c9d': {
        value: cisSettings.logicAppResourceLogsEnabled
      }
      'effect-b4330a05-a843-4bc8-bf9a-cacce50c67f4': {
        value: cisSettings.searchServicesResourceLogsEnabled
      }
      'effect-f8d36e2f-389b-4ee4-898d-21aeb69a0f45': {
        value: cisSettings.serviceBusResourceLogsEnabled
      }
      'effect-f9be5368-9bf5-4b84-9e0a-7850da98bb46': {
        value: cisSettings.streamAnalyticsResourceLogsEnabled
      }
      'effect-0961003e-5a0a-4549-abde-af6a37f2724d': {
        value: cisSettings.encryptDataFlowsBetweenComputeAndStorage
      }
      'effect-c0e996f8-39cf-4af9-9f45-83fbde810432': {
        value: cisSettings.effectVirtualMachineExtensionsAllowed
      }
      'approvedExtensions-c0e996f8-39cf-4af9-9f45-83fbde810432': {
        value: cisSettings.virtualMachineExtensionsAllowed
      }
      'effect-152b15f7-8e1f-4c1f-ab71-8c010ba5dbc0': {
        value: cisSettings.keyVaultKeysShouldHaveExpiration
      }
      'effect-98728c90-32c7-4049-8429-847dc0f4fe37': {
        value: cisSettings.keyVaultSecretsShouldHaveExpiration
      }
      'effect-0b60c0b2-2dc2-4e1c-b5c9-abbed971de53': {
        value: cisSettings.keyvaultPurgeProtectionEnabled
      }
      'effect-c75248c1-ea1d-4a9c-8fc9-29a6aabd5da8': {
        value: cisSettings.functionAppsAuthenticationEnabled
      }
      'effect-95bccee9-a7f8-4bec-9ee9-62c3473701fc': {
        value: cisSettings.appServicesAuthenticationEnabled
      }
      'effect-a4af4a39-4135-47fb-b175-47fbdf85311d': {
        value: cisSettings.appServiceAccessibleOverHttps
      }
      'effect-f9d614c5-c173-4d56-95a7-b4437057d193': {
        value: cisSettings.functionAppsLatestTlsVersion
      }
      'effect-f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b': {
        value: cisSettings.appServiceAppsLatestTlsVersion
      }
      'effect-eaebaea7-8013-4ceb-9d14-7eb32271373c': {
        value: cisSettings.functionAppsClientCertificatesEnabled
      }
      'effect-5bb220d9-2698-4ee4-8404-b9c30c9df609': {
        value: cisSettings.appServiceAppsClientCertificatesEnabled
      }
      'effect-0da106f2-4ca3-48e8-bc85-c638fe6aea8f': {
        value: cisSettings.functionAppShouldUseManagedIdentity
      }
      'effect-2b9ad585-36bc-4615-b300-fd4435808332': {
        value: cisSettings.appServiceAppShouldUseManagedIdentity
      }
      'effect-e2c1c086-2d84-4019-bff3-c44ccd95113c': {
        value: cisSettings.functionAppShouldUseLatestHttpVersion
      }
      'effect-8c122334-9d20-4eb8-89ea-ac9a705b74ae': {
        value: cisSettings.appServiceAppShouldUseLatestHttpVersion
      }
      'effect-399b2637-a50f-4f95-96f8-3a145476eb15': {
        value: cisSettings.functionAppShouldRequireFtpsOnly
      }
      'effect-4d24b6d4-5e53-4a4f-a7f4-618fa573ee4b': {
        value: cisSettings.appServiceAppShouldRequireFtpsOnly
      }
      'effect-1e66c121-a66a-4b1f-9b83-0fd99bf0fc2d': {
        value: cisSettings.keyvaultSoftDeleteEnabled
      }
      'effect-862e97cf-49fc-4a5c-9de4-40d4e2e7c8eb': {
        value: cisSettings.cosmosDbShouldHaveFirewallRules
      }
      'effect-1b8ca024-1d5c-4dec-8995-b1a932b41780': {
        value: cisSettings.sqlPublicAccessShouldBeDisabled
      }
      'effect-24fba194-95d6-48c0-aea7-f65bf859c598': {
        value: cisSettings.postgresSqlInfraEncryptionShouldBeEnabled
      }
      'effect-4733ea7b-a883-42fe-8cac-97454c2a9e4a': {
        value: cisSettings.storageAccountShouldHaveInfraEncryption
      }
      'effect-e802a67a-daf5-4436-9ea6-f6d821dd0c5d': {
        value: cisSettings.enforceSslMySqlEnabled
      }
      'effect-7008174a-fd10-4ef0-817e-fc820a951d73': {
        value: cisSettings.appServiceAppsPythonVersion
      }
      'effect-ca91455f-eace-4f96-be59-e6e2c35b4816': {
        value: cisSettings.managedDiskDoubleEncryptionEnabled
      }
      'effect-7261b898-8a84-4db8-9e04-18527132abb3': {
        value: cisSettings.appServicePhpVersion
      }
      'effect-9d0b6ea4-93e2-4578-bf2f-6bb17d22b4bc': {
        value: cisSettings.appServiceJavaVersion
      }
      'effect-a451c1ef-c6ca-483d-87ed-f49761e3ffb5': {
        value: cisSettings.auditCustomRbac
      }
      'effect-22730e10-96f6-4aac-ad84-9383d35b5917': {
        value: cisSettings.vmManagementPortsShouldBeClosed
      }
      'effect-b52376f7-9612-48a1-81cd-1ffe4b61032c': {
        value: cisSettings.postgresSqlPublicAccessShouldBeDisabled
      }
      'effect-5e1de0e3-42cb-4ebc-a86d-61d0c619ca48': {
        value: cisSettings.postgresFlexSqlPublicAccessShouldBeDisabled
      }
      'effect-feedbf84-6b99-488c-acc2-71c829aa5ffc': {
        value: cisSettings.sqlVulnerabilityFindingsShouldBeResolved
      }
      'effect-6edd7eda-6dd8-40f7-810d-67160c639cd9': {
        value: cisSettings.storageAccountsShouldUsePrivateLinks
      }
      'effect-b954148f-4c11-4c38-8221-be76711e194a-MicrosoftClassicNetwork-networkSecurityGroups-securityRules-delete': {
        value: cisSettings.securityRulesDeleteAlertShouldExist
      }
      'effect-b954148f-4c11-4c38-8221-be76711e194a-MicrosoftClassicNetwork-networkSecurityGroups-delete': {
        value: cisSettings.nsgDeleteAlertShouldExist
      }
      'effect-c3d20c29-b36d-48fe-808b-99a87530ad99': {
        value: cisSettings.defenderForResourceManagerEnabled
      }
      'effect-3b980d31-7904-4bb7-8575-5665739a8052': {
        value: cisSettings.securitySolutionsAlertShouldExist
      }
      'audit_effect-a6abeaec-4d90-4a02-805f-6b26c4d3fbe9': {
        value: cisSettings.azureKeyvaultShouldUsePrivateLink
      }
      'effect-58440f8a-10c5-4151-bdce-dfbaad4a20b7': {
        value: cisSettings.cosmosDbShouldUsePrivateLink
      }
      'effect-bdc59948-5574-49b3-bb91-76b7c986428d': {
        value: cisSettings.defenderForDnsEnabled
      }
      'effect-1f7c564c-0a90-4d44-b7e1-9d456cffaee8': {
        value: cisSettings.endpointProtectionEnabled
      }
      'effect-0a9fbe0d-c5c4-4da8-87d8-f4fd77338835': {
        value: cisSettings.defenderForRelationalDatabasesEnabled
      }
      'effect-4c3c6c5f-0d47-4402-99b8-aa543dd8bcee': {
        value: cisSettings.networkFlowLogsEnabled
      }
      'effect-c251913d-7d24-4958-af87-478ed3b9ba41': {
        value: cisSettings.nsgFlowLogsEnabled
      }
      'effect-27960feb-a23c-4577-8d36-ef8b5f35e0be': {
        value: cisSettings.allFlowLogsEnabled
      }
      'effect-fe83a0eb-a853-422d-aac2-1bffd182c5d0': {
        value: cisSettings.storageAccountsMinimalTlsVersion
      }
      'effect-adbe85b5-83e6-4350-ab58-bf3a4f736e5e': {
        value: cisSettings.defenderForCosmosDbEnabled
      }
      'effect-e1d1b522-02b0-4d18-a04f-5ab62d20445f': {
        value: cisSettings.functionAppsJavaVersion
      }
      'effect-f466b2a6-823d-470d-8ea5-b031e72d79ae': {
        value: cisSettings.appServiceSlotsPhpVersion
      }
      'effect-5450f5bd-9c72-4390-a9c4-a7aba4edfdd2': {
        value: cisSettings.cosmosDbLocalAuthDisabled
      }
      'effect-12d4fa5e-1f9f-4c21-97a9-b99b3c6611b5': {
        value: cisSettings.keyvaultShouldUseRbacModel
      }
      'effect-b954148f-4c11-4c38-8221-be76711e194a-MicrosoftClassicNetwork-networkSecurityGroups-securityRules-write': {
        value: cisSettings.securitySolutionsWriteAlertShouldExist
      }
      'effect-b954148f-4c11-4c38-8221-be76711e194a-MicrosoftClassicNetwork-networkSecurityGroups-write': {
        value: cisSettings.nsgWriteAlertShouldExist
      }
      'LinuxPythonVersion': {
        value: cisSettings.linuxPythonVersion
      }
      'LinuxJavaVersion': {
        value: cisSettings.linuxJavaVersion
      }
      'LinuxPHPVersion': {
        value: cisSettings.linuxPhpVersion
      }
      'effect-9c014953-ef68-4a98-82af-fd0f6b2306c8': {
        value: cisSettings.appServiceSlotsPythonVersion
      }
      'effect-bd876905-5b84-4f73-ab2d-2e7a7c4568d9': {
        value: cisSettings.periodicUpdateCheckConfigured
      }
      'resourceGroupName-b6e2945c-0b7b-40f5-9233-7a5323b5cdc6': {
        value: cisSettings.networkWatcherResourceGroup
      }
    }
    policyDefinitionId: assignmentProperties.policyDefinitionId
  }
}
// OUTPUTS
