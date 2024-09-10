/*
SUMMARY: Security Benchmark Policy child module.
DESCRIPTION: Deployment of Security Benchmark Policy. Consists of assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription'

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param mcsbSettings object

@description('Specify name for assignment of security benchmark audit deny initiative.')
param securityBenchmarkAuditDenySetAssignmentName string

@description('Specify display name for assignment of security benchmark audit deny initiative.')
param securityBenchmarkAuditDenySetAssignmentDisplayName string

@description('Specify the policy definition id of the built-in MCSB Initiative.')
param mcsbPolicyDefinitionId string

// VARIABLES
//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Microsoft cloud security benchmark'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
  policyDefinitionId: mcsbPolicyDefinitionId
}

// RESOURCE DEPLOYMENTS
//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: securityBenchmarkAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: securityBenchmarkAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {

      'installLogAnalyticsAgentOnVmMonitoringEffect': {
        value: mcsbSettings.installLogAnalyticsAgentOnVmMonitoringEffect }
      'installLogAnalyticsAgentOnVmssMonitoringEffect': {
        value: mcsbSettings.installLogAnalyticsAgentOnVmssMonitoringEffect }
      'certificatesValidityPeriodMonitoringEffect': {
        value: mcsbSettings.certificatesValidityPeriodMonitoringEffect }
      'certificatesValidityPeriodInMonths': {
        value: mcsbSettings.certificatesValidityPeriodInMonths }
      'secretsExpirationSetEffect': {
        value: mcsbSettings.secretsExpirationSetEffect }
      'keysExpirationSetEffect': {
        value: mcsbSettings.keysExpirationSetEffect }
      'azurePolicyforWindowsMonitoringEffect': {
        value: mcsbSettings.azurePolicyforWindowsMonitoringEffect }
      'gcExtOnVMWithNoSAMIMonitoringEffect': {
        value: mcsbSettings.gcExtOnVmWithNoSamiMonitoringEffect }
      'windowsDefenderExploitGuardMonitoringEffect': {
        value: mcsbSettings.windowsDefenderExploitGuardMonitoringEffect }
      'windowsGuestConfigBaselinesMonitoringEffect': {
        value: mcsbSettings.windowsGuestConfigBaselinesMonitoringEffect }
      'linuxGuestConfigBaselinesMonitoringEffect': {
        value: mcsbSettings.linuxGuestConfigBaselinesMonitoringEffect }
      'vmssSystemUpdatesMonitoringEffect': {
        value: mcsbSettings.vmssSystemUpdatesMonitoringEffect }
      'vmssEndpointProtectionMonitoringEffect': {
        value: mcsbSettings.vmssEndpointProtectionMonitoringEffect }
      'vmssOsVulnerabilitiesMonitoringEffect': {
        value: mcsbSettings.vmssOsVulnerabilitiesMonitoringEffect }
      'systemUpdatesMonitoringEffect': {
        value: mcsbSettings.systemUpdatesMonitoringEffect }
      'systemUpdatesV2MonitoringEffect': {
        value: mcsbSettings.systemUpdatesV2MonitoringEffect }
      'systemUpdatesAutoAssessmentModeEffect': {
        value: mcsbSettings.systemUpdatesAutoAssessmentModeEffect }
      'systemConfigurationsMonitoringEffect': {
        value: mcsbSettings.systemConfigurationsMonitoringEffect }
      'endpointProtectionMonitoringEffect': {
        value: mcsbSettings.endpointProtectionMonitoringEffect }
      'diskEncryptionMonitoringEffect': {
        value: mcsbSettings.diskEncryptionMonitoringEffect }
      'gcLinuxDiskEncryptionMonitoringEffect': {
        value: mcsbSettings.gcLinuxDiskEncryptionMonitoringEffect }
      'gcWindowsDiskEncryptionMonitoringEffect': {
        value: mcsbSettings.gcWindowsDiskEncryptionMonitoringEffect }
      'networkSecurityGroupsOnSubnetsMonitoringEffect': {
        value: mcsbSettings.networkSecurityGroupsOnSubnetsMonitoringEffect }
      'networkSecurityGroupsOnVirtualMachinesMonitoringEffect': {
        value: mcsbSettings.networkSecurityGroupsOnVirtualMachinesMonitoringEffect }
      'networkSecurityGroupsOnInternalVirtualMachinesMonitoringEffect': {
        value: mcsbSettings.networkSecurityGroupsOnInternalVirtualMachinesMonitoringEffect }
      'nextGenerationFirewallMonitoringEffect': {
        value: mcsbSettings.nextGenerationFirewallMonitoringEffect }
      'serverVulnerabilityAssessmentEffect': {
        value: mcsbSettings.serverVulnerabilityAssessmentEffect }
      'jitNetworkAccessMonitoringEffect': {
        value: mcsbSettings.jitNetworkAccessMonitoringEffect }
      'adaptiveApplicationControlsMonitoringEffect': {
        value: mcsbSettings.adaptiveApplicationControlsMonitoringEffect }
      'adaptiveApplicationControlsUpdateMonitoringEffect': {
        value: mcsbSettings.adaptiveApplicationControlsUpdateMonitoringEffect }
      'sqlDbEncryptionMonitoringEffect': {
        value: mcsbSettings.sqlDbEncryptionMonitoringEffect }
      'sqlServerAuditingMonitoringEffect': {
        value: mcsbSettings.sqlServerAuditingMonitoringEffect }
      'encryptionOfAutomationAccountMonitoringEffect': {
        value: mcsbSettings.encryptionOfAutomationAccountMonitoringEffect }
      'diagnosticsLogsInBatchAccountMonitoringEffect': {
        value: mcsbSettings.diagnosticsLogsInBatchAccountMonitoringEffect }
      'diagnosticsLogsInBatchAccountRetentionDays': {
        value: mcsbSettings.diagnosticsLogsInBatchAccountRetentionDays }
      'classicComputeVMsMonitoringEffect': {
        value: mcsbSettings.classicComputeVmsMonitoringEffect }
      'classicStorageAccountsMonitoringEffect': {
        value: mcsbSettings.classicStorageAccountsMonitoringEffect }
      'diagnosticsLogsInDataLakeAnalyticsMonitoringEffect': {
        value: mcsbSettings.diagnosticsLogsInDataLakeAnalyticsMonitoringEffect }
      'diagnosticsLogsInDataLakeAnalyticsRetentionDays': {
        value: mcsbSettings.diagnosticsLogsInDataLakeAnalyticsRetentionDays }
      'diagnosticsLogsInDataLakeStoreMonitoringEffect': {
        value: mcsbSettings.diagnosticsLogsInDataLakeStoreMonitoringEffect }
      'diagnosticsLogsInDataLakeStoreRetentionDays': {
        value: mcsbSettings.diagnosticsLogsInDataLakeStoreRetentionDays }
      'diagnosticsLogsInEventHubMonitoringEffect': {
        value: mcsbSettings.diagnosticsLogsInEventHubMonitoringEffect }
      'diagnosticsLogsInEventHubRetentionDays': {
        value: mcsbSettings.diagnosticsLogsInEventHubRetentionDays }
      'diagnosticsLogsInKeyVaultMonitoringEffect': {
        value: mcsbSettings.diagnosticsLogsInKeyVaultMonitoringEffect }
      'diagnosticsLogsInKeyVaultRetentionDays': {
        value: mcsbSettings.diagnosticsLogsInKeyVaultRetentionDays }
      'diagnosticsLogsInKubernetesMonitoringEffect': {
        value: mcsbSettings.diagnosticsLogsInKubernetesMonitoringEffect }
      'diagnosticsLogsInKubernetesRetentionDays': {
        value: mcsbSettings.diagnosticsLogsInKubernetesRetentionDays }
      'diagnosticsLogsInLogicAppsMonitoringEffect': {
        value: mcsbSettings.diagnosticsLogsInLogicAppsMonitoringEffect }
      'diagnosticsLogsInLogicAppsRetentionDays': {
        value: mcsbSettings.diagnosticsLogsInLogicAppsRetentionDays }
      'diagnosticsLogsInRedisCacheMonitoringEffect': {
        value: mcsbSettings.diagnosticsLogsInRedisCacheMonitoringEffect }
      'diagnosticsLogsInSearchServiceMonitoringEffect': {
        value: mcsbSettings.diagnosticsLogsInSearchServiceMonitoringEffect }
      'diagnosticsLogsInSearchServiceRetentionDays': {
        value: mcsbSettings.diagnosticsLogsInSearchServiceRetentionDays }
      'aadAuthenticationInServiceFabricMonitoringEffect': {
        value: mcsbSettings.aadAuthenticationInServiceFabricMonitoringEffect }
      'clusterProtectionLevelInServiceFabricMonitoringEffect': {
        value: mcsbSettings.clusterProtectionLevelInServiceFabricMonitoringEffect }
      'diagnosticsLogsInServiceBusMonitoringEffect': {
        value: mcsbSettings.diagnosticsLogsInServiceBusMonitoringEffect }
      'diagnosticsLogsInServiceBusRetentionDays': {
        value: mcsbSettings.diagnosticsLogsInServiceBusRetentionDays }
      'aadAuthenticationInSqlServerMonitoringEffect': {
        value: mcsbSettings.aadAuthenticationInSqlServerMonitoringEffect }
      'secureTransferToStorageAccountMonitoringEffect': {
        value: mcsbSettings.secureTransferToStorageAccountMonitoringEffect }
      'diagnosticsLogsInStreamAnalyticsMonitoringEffect': {
        value: mcsbSettings.diagnosticsLogsInStreamAnalyticsMonitoringEffect }
      'diagnosticsLogsInStreamAnalyticsRetentionDays': {
        value: mcsbSettings.diagnosticsLogsInStreamAnalyticsRetentionDays }
      'useRbacRulesMonitoringEffect': {
        value: mcsbSettings.useRbacRulesMonitoringEffect }
      'disableUnrestrictedNetworkToStorageAccountMonitoringEffect': {
        value: mcsbSettings.disableUnrestrictedNetworkToStorageAccountMonitoringEffect }
      'sqlDbVulnerabilityAssesmentMonitoringEffect': {
        value: mcsbSettings.sqlDbVulnerabilityAssesmentMonitoringEffect }
      'serverSqlDbVulnerabilityAssesmentMonitoringEffect': {
        value: mcsbSettings.serverSqlDbVulnerabilityAssesmentMonitoringEffect }
      'identityDesignateLessThanOwnersMonitoringEffect': {
        value: mcsbSettings.identityDesignateLessThanOwnersMonitoringEffect }
      'identityDesignateMoreThanOneOwnerMonitoringEffect': {
        value: mcsbSettings.identityDesignateMoreThanOneOwnerMonitoringEffect }
      'identityEnableMFAForOwnerPermissionsMonitoringEffect': {
        value: mcsbSettings.identityEnableMfaForOwnerPermissionsMonitoringEffect }
      'identityEnableMFAForWritePermissionsMonitoringEffect': {
        value: mcsbSettings.identityEnableMfaForWritePermissionsMonitoringEffect }
      'identityEnableMFAForReadPermissionsMonitoringEffect': {
        value: mcsbSettings.identityEnableMfaForReadPermissionsMonitoringEffect }
      'identityRemoveExternalAccountWithOwnerPermissionsMonitoringEffect': {
        value: mcsbSettings.identityRemoveExternalAccountWithOwnerPermissionsMonitoringEffect }
      'identityRemoveExternalAccountWithWritePermissionsMonitoringEffect': {
        value: mcsbSettings.identityRemoveExternalAccountWithWritePermissionsMonitoringEffect }
      'identityRemoveExternalAccountWithReadPermissionsMonitoringEffect': {
        value: mcsbSettings.identityRemoveExternalAccountWithReadPermissionsMonitoringEffect }
      'functionAppDisableRemoteDebuggingMonitoringEffect': {
        value: mcsbSettings.functionAppDisableRemoteDebuggingMonitoringEffect }
      'webAppDisableRemoteDebuggingMonitoringEffect': {
        value: mcsbSettings.webAppDisableRemoteDebuggingMonitoringEffect }
      'functionAppEnforceHttpsMonitoringEffectV2': {
        value: mcsbSettings.functionAppEnforceHttpsMonitoringEffectV2 }
      'webAppEnforceHttpsMonitoringEffectV2': {
        value: mcsbSettings.webAppEnforceHttpsMonitoringEffectV2 }
      'functionAppRestrictCORSAccessMonitoringEffect': {
        value: mcsbSettings.functionAppRestrictCorsAccessMonitoringEffect }
      'webAppRestrictCORSAccessMonitoringEffect': {
        value: mcsbSettings.webAppRestrictCorsAccessMonitoringEffect }
      'vnetEnableDDoSProtectionMonitoringEffect': {
        value: mcsbSettings.vnetEnableDdoSProtectionMonitoringEffect }
      'diagnosticsLogsInIoTHubMonitoringEffect': {
        value: mcsbSettings.diagnosticsLogsInIotHubMonitoringEffect }
      'diagnosticsLogsInIoTHubRetentionDays': {
        value: mcsbSettings.diagnosticsLogsInIotHubRetentionDays }
      'sqlServerAdvancedDataSecurityMonitoringEffect': {
        value: mcsbSettings.sqlServerAdvancedDataSecurityMonitoringEffect }
      'arcEnabledSqlServerDefenderStatusEffect': {
        value: mcsbSettings.arcEnabledSqlServerDefenderStatusEffect }
      'sqlManagedInstanceAdvancedDataSecurityMonitoringEffect': {
        value: mcsbSettings.sqlManagedInstanceAdvancedDataSecurityMonitoringEffect }
      'kubernetesServiceRbacEnabledMonitoringEffect': {
        value: mcsbSettings.kubernetesServiceRbacEnabledMonitoringEffect }
      'kubernetesServiceAuthorizedIPRangesEnabledMonitoringEffect': {
        value: mcsbSettings.kubernetesServiceAuthorizedIpRangesEnabledMonitoringEffect }
      'vulnerabilityAssessmentOnManagedInstanceMonitoringEffect': {
        value: mcsbSettings.vulnerabilityAssessmentOnManagedInstanceMonitoringEffect }
      'vulnerabilityAssessmentOnServerMonitoringEffect': {
        value: mcsbSettings.vulnerabilityAssessmentOnServerMonitoringEffect }
      'adaptiveNetworkHardeningsMonitoringEffect': {
        value: mcsbSettings.adaptiveNetworkHardeningsMonitoringEffect }
      'restrictAccessToManagementPortsMonitoringEffect': {
        value: mcsbSettings.restrictAccessToManagementPortsMonitoringEffect }
      'disableIPForwardingMonitoringEffect': {
        value: mcsbSettings.disableIpForwardingMonitoringEffect }
      'ensureServerTDEIsEncryptedWithYourOwnKeyWithDenyMonitoringEffect': {
        value: mcsbSettings.ensureServerTdeIsEncryptedWithYourOwnKeyWithDenyMonitoringEffect }
      'ensureManagedInstanceTDEIsEncryptedWithYourOwnKeyWithDenyMonitoringEffect': {
        value: mcsbSettings.ensureManagedInstanceTdeIsEncryptedWithYourOwnKeyWithDenyMonitoringEffect }
      'containerBenchmarkMonitoringEffect': {
        value: mcsbSettings.containerBenchmarkMonitoringEffect }
      'ASCDependencyAgentAuditWindowsEffect': {
        value: mcsbSettings.ascDependencyAgentAuditWindowsEffect }
      'ASCDependencyAgentAuditLinuxEffect': {
        value: mcsbSettings.ascDependencyAgentAuditLinuxEffect }
      'AzureFirewallEffect': {
        value: mcsbSettings.azureFirewallEffect }
      'ArcWindowsMonitoringEffect': {
        value: mcsbSettings.arcWindowsMonitoringEffect }
      'ArcLinuxMonitoringEffect': {
        value: mcsbSettings.arcLinuxMonitoringEffect }
      'keyVaultsAdvancedDataSecurityMonitoringEffect': {
        value: mcsbSettings.keyVaultsAdvancedDataSecurityMonitoringEffect }
      'sqlServersAdvancedDataSecurityMonitoringEffect': {
        value: mcsbSettings.sqlServersAdvancedDataSecurityMonitoringEffect }
      'sqlServersVirtualMachinesAdvancedDataSecurityMonitoringEffect': {
        value: mcsbSettings.sqlServersVirtualMachinesAdvancedDataSecurityMonitoringEffect }
      'appServicesAdvancedThreatProtectionMonitoringEffect': {
        value: mcsbSettings.appServicesAdvancedThreatProtectionMonitoringEffect }
      'containersAdvancedThreatProtectionMonitoringEffect': {
        value: mcsbSettings.containersAdvancedThreatProtectionMonitoringEffect }
      'virtualMachinesAdvancedThreatProtectionMonitoringEffect': {
        value: mcsbSettings.virtualMachinesAdvancedThreatProtectionMonitoringEffect }
      'azurePolicyAddonStatusEffect': {
        value: mcsbSettings.azurePolicyAddonStatusEffect }
      'arcEnabledKubernetesClustersShouldHaveAzurePolicyExtensionInstalledEffect': {
        value: mcsbSettings.arcEnabledKubernetesClustersShouldHaveAzurePolicyExtensionInstalledEffect }
      'excludedImagesInKubernetesCluster': {
        value: mcsbSettings.excludedImagesInKubernetesCluster }
      'allowedContainerImagesInKubernetesClusterEffect': {
        value: mcsbSettings.allowedContainerImagesInKubernetesClusterEffect }
      'allowedContainerImagesInKubernetesClusterRegex': {
        value: mcsbSettings.allowedContainerImagesInKubernetesClusterRegex }
      'allowedContainerImagesNamespaceExclusion': {
        value: mcsbSettings.allowedContainerImagesNamespaceExclusion }
      'privilegedContainersShouldBeAvoidedEffect': {
        value: mcsbSettings.privilegedContainersShouldBeAvoidedEffect }
      'privilegedContainerNamespaceExclusion': {
        value: mcsbSettings.privilegedContainerNamespaceExclusion }
      'allowedServicePortsInKubernetesClusterEffect': {
        value: mcsbSettings.allowedServicePortsInKubernetesClusterEffect }
      'allowedservicePortsInKubernetesClusterPorts': {
        value: mcsbSettings.allowedservicePortsInKubernetesClusterPorts }
      'allowedServicePortsInKubernetesClusterNamespaceExclusion': {
        value: mcsbSettings.allowedServicePortsInKubernetesClusterNamespaceExclusion }
      'NoPrivilegeEscalationInKubernetesClusterEffect': {
        value: mcsbSettings.noPrivilegeEscalationInKubernetesClusterEffect }
      'NoPrivilegeEscalationInKubernetesClusterNamespaceExclusion': {
        value: mcsbSettings.noPrivilegeEscalationInKubernetesClusterNamespaceExclusion }
      'NoSharingSensitiveHostNamespacesInKubernetesEffect': {
        value: mcsbSettings.noSharingSensitiveHostNamespacesInKubernetesEffect }
      'NoSharingSensitiveHostNamespacesInKubernetesNamespaceExclusion': {
        value: mcsbSettings.noSharingSensitiveHostNamespacesInKubernetesNamespaceExclusion }
      'ReadOnlyRootFileSystemInKubernetesClusterEffect': {
        value: mcsbSettings.readOnlyRootFileSystemInKubernetesClusterEffect }
      'ReadOnlyRootFileSystemInKubernetesClusterNamespaceExclusion': {
        value: mcsbSettings.readOnlyRootFileSystemInKubernetesClusterNamespaceExclusion }
      'AllowedCapabilitiesInKubernetesClusterEffect': {
        value: mcsbSettings.allowedCapabilitiesInKubernetesClusterEffect }
      'AllowedCapabilitiesInKubernetesClusterNamespaceExclusion': {
        value: mcsbSettings.allowedCapabilitiesInKubernetesClusterNamespaceExclusion }
      'AllowedCapabilitiesInKubernetesClusterList': {
        value: mcsbSettings.allowedCapabilitiesInKubernetesClusterList }
      'DropCapabilitiesInKubernetesClusterList': {
        value: mcsbSettings.dropCapabilitiesInKubernetesClusterList }
      'AllowedAppArmorProfilesInKubernetesClusterEffect': {
        value: mcsbSettings.allowedAppArmorProfilesInKubernetesClusterEffect }
      'AllowedAppArmorProfilesInKubernetesClusterNamespaceExclusion': {
        value: mcsbSettings.allowedAppArmorProfilesInKubernetesClusterNamespaceExclusion }
      'AllowedAppArmorProfilesInKubernetesClusterList': {
        value: mcsbSettings.allowedAppArmorProfilesInKubernetesClusterList }
      'AllowedHostNetworkingAndPortsInKubernetesClusterEffect': {
        value: mcsbSettings.allowedHostNetworkingAndPortsInKubernetesClusterEffect }
      'AllowedHostNetworkingAndPortsInKubernetesClusterNamespaceExclusion': {
        value: mcsbSettings.allowedHostNetworkingAndPortsInKubernetesClusterNamespaceExclusion }
      'AllowHostNetworkingInKubernetesCluster': {
        value: mcsbSettings.allowHostNetworkingInKubernetesCluster }
      'AllowedHostMinPortInKubernetesCluster': {
        value: mcsbSettings.allowedHostMinPortInKubernetesCluster }
      'AllowedHostMaxPortInKubernetesCluster': {
        value: mcsbSettings.allowedHostMaxPortInKubernetesCluster }
      'AllowedHostPathVolumesInKubernetesClusterEffect': {
        value: mcsbSettings.allowedHostPathVolumesInKubernetesClusterEffect }
      'AllowedHostPathVolumesInKubernetesClusterNamespaceExclusion': {
        value: mcsbSettings.allowedHostPathVolumesInKubernetesClusterNamespaceExclusion }
      'AllowedHostPathVolumesInKubernetesClusterList': {
        value: mcsbSettings.allowedHostPathVolumesInKubernetesClusterList }
      'memoryAndCPULimitsInKubernetesClusterEffect': {
        value: mcsbSettings.memoryAndCpuLimitsInKubernetesClusterEffect }
      'memoryInKubernetesClusterLimit': {
        value: mcsbSettings.memoryInKubernetesClusterLimit }
      'CPUInKubernetesClusterLimit': {
        value: mcsbSettings.cpuInKubernetesClusterLimit }
      'memoryAndCPULimitsInKubernetesClusterNamespaceExclusion': {
        value: mcsbSettings.memoryAndCpuLimitsInKubernetesClusterNamespaceExclusion }
      'BlockVulnerableImagesInKubernetesClusterEffect': {
        value: mcsbSettings.blockVulnerableImagesInKubernetesClusterEffect }
      'BlockVulnerableImagesInKubernetesClusterNamespaceExclusion': {
        value: mcsbSettings.blockVulnerableImagesInKubernetesClusterNamespaceExclusion }
      'BlockVulnerableImagesExcludedImages': {
        value: mcsbSettings.blockVulnerableImagesExcludedImages }
      'BlockVulnerableImagesSeverityThresholdForExcludingNotPatchableFindings': {
        value: mcsbSettings.blockVulnerableImagesSeverityThresholdForExcludingNotPatchableFindings }
      'BlockVulnerableImagesExcludeFindingIDs': {
        value: mcsbSettings.blockVulnerableImagesExcludeFindingIDs }
      'severity': {
        value: mcsbSettings.severity }
      'MustRunAsNonRootNamespaceExclusion': {
        value: mcsbSettings.mustRunAsNonRootNamespaceExclusion }
      'MustRunAsNonRootNamespaceEffect': {
        value: mcsbSettings.mustRunAsNonRootNamespaceEffect }
      'arcEnabledKubernetesClustersShouldHaveAzureDefendersExtensionInstalled': {
        value: mcsbSettings.arcEnabledKubernetesClustersShouldHaveAzureDefendersExtensionInstalled }
      'azureKubernetesServiceClustersShouldHaveSecurityProfileEnabled': {
        value: mcsbSettings.azureKubernetesServiceClustersShouldHaveSecurityProfileEnabled }
      'containerRegistryVulnerabilityAssessmentEffect': {
        value: mcsbSettings.containerRegistryVulnerabilityAssessmentEffect }
      'kubernetesRunningImagesVulnerabilityAssessmentEffect': {
        value: mcsbSettings.kubernetesRunningImagesVulnerabilityAssessmentEffect }
      'disallowPublicBlobAccessEffect': {
        value: mcsbSettings.disallowPublicBlobAccessEffect }
      'azureBackupShouldBeEnabledForVirtualMachinesMonitoringEffect': {
        value: mcsbSettings.azureBackupShouldBeEnabledForVirtualMachinesMonitoringEffect }
      'managedIdentityShouldBeUsedInYourFunctionAppMonitoringEffect': {
        value: mcsbSettings.managedIdentityShouldBeUsedInYourFunctionAppMonitoringEffect }
      'georedundantBackupShouldBeEnabledForAzureDatabaseForMariadbMonitoringEffect': {
        value: mcsbSettings.georedundantBackupShouldBeEnabledForAzureDatabaseForMariadbMonitoringEffect }
      'managedIdentityShouldBeUsedInYourWebAppMonitoringEffect': {
        value: mcsbSettings.managedIdentityShouldBeUsedInYourWebAppMonitoringEffect }
      'georedundantBackupShouldBeEnabledForAzureDatabaseForPostgresqlMonitoringEffect': {
        value: mcsbSettings.georedundantBackupShouldBeEnabledForAzureDatabaseForPostgresqlMonitoringEffect }
      'ensureWEBAppHasClientCertificatesIncomingClientCertificatesSetToOnMonitoringEffect': {
        value: mcsbSettings.ensureWebAppHasClientCertificatesIncomingClientCertificatesSetToOnMonitoringEffect }
      'georedundantBackupShouldBeEnabledForAzureDatabaseForMysqlMonitoringEffect': {
        value: mcsbSettings.georedundantBackupShouldBeEnabledForAzureDatabaseForMysqlMonitoringEffect }
      'diagnosticLogsInAppServicesShouldBeEnabledMonitoringEffect': {
        value: mcsbSettings.diagnosticLogsInAppServicesShouldBeEnabledMonitoringEffect }
      'enforceSSLConnectionShouldBeEnabledForPostgresqlDatabaseServersMonitoringEffect': {
        value: mcsbSettings.enforceSslConnectionShouldBeEnabledForPostgresqlDatabaseServersMonitoringEffect }
      'enforceSSLConnectionShouldBeEnabledForMysqlDatabaseServersMonitoringEffect': {
        value: mcsbSettings.enforceSslConnectionShouldBeEnabledForMysqlDatabaseServersMonitoringEffect }
      'latestTLSVersionShouldBeUsedInYourWebAppMonitoringEffect': {
        value: mcsbSettings.latestTlsVersionShouldBeUsedInYourWebAppMonitoringEffect }
      'latestTLSVersionShouldBeUsedInYourFunctionAppMonitoringEffect': {
        value: mcsbSettings.latestTlsVersionShouldBeUsedInYourFunctionAppMonitoringEffect }
      'privateEndpointShouldBeEnabledForPostgresqlServersMonitoringEffect': {
        value: mcsbSettings.privateEndpointShouldBeEnabledForPostgresqlServersMonitoringEffect }
      'privateEndpointShouldBeEnabledForMariadbServersMonitoringEffect': {
        value: mcsbSettings.privateEndpointShouldBeEnabledForMariadbServersMonitoringEffect }
      'privateEndpointShouldBeEnabledForMysqlServersMonitoringEffect': {
        value: mcsbSettings.privateEndpointShouldBeEnabledForMysqlServersMonitoringEffect }
      'sQLServersShouldBeConfiguredWithAuditingRetentionDaysGreaterThan90DaysMonitoringEffect': {
        value: mcsbSettings.sqlServersShouldBeConfiguredWithAuditingRetentionDaysGreaterThan90DaysMonitoringEffect }
      'fTPSOnlyShouldBeRequiredInYourFunctionAppMonitoringEffect': {
        value: mcsbSettings.ftpsOnlyShouldBeRequiredInYourFunctionAppMonitoringEffect }
      'fTPSShouldBeRequiredInYourWebAppMonitoringEffect': {
        value: mcsbSettings.ftpsShouldBeRequiredInYourWebAppMonitoringEffect }
      'functionAppsShouldHaveClientCertificatesEnabledMonitoringEffect': {
        value: mcsbSettings.functionAppsShouldHaveClientCertificatesEnabledMonitoringEffect }
      'cognitiveServicesAccountsShouldEnableDataEncryptionWithACustomerManagedKeyMonitoringEffect': {
        value: mcsbSettings.cognitiveServicesAccountsShouldEnableDataEncryptionWithACustomerManagedKeyMonitoringEffect }
      'azureCosmosDbAccountsShouldUseCustomerManagedKeysToEncryptDataAtRestMonitoringEffect': {
        value: mcsbSettings.azureCosmosDbAccountsShouldUseCustomerManagedKeysToEncryptDataAtRestMonitoringEffect }
      'azureCosmosDbAccountsShouldHaveLocalAuthenticationMethodsDisabledMonitoringEffect': {
        value: mcsbSettings.azureCosmosDbAccountsShouldHaveLocalAuthenticationMethodsDisabledMonitoringEffect }
      'keyVaultsShouldHavePurgeProtectionEnabledMonitoringEffect': {
        value: mcsbSettings.keyVaultsShouldHavePurgeProtectionEnabledMonitoringEffect }
      'keyVaultsShouldHaveSoftDeleteEnabledMonitoringEffect': {
        value: mcsbSettings.keyVaultsShouldHaveSoftDeleteEnabledMonitoringEffect }
      'azureCacheForRedisShouldUsePrivateEndpointMonitoringEffect': {
        value: mcsbSettings.azureCacheForRedisShouldUsePrivateEndpointMonitoringEffect }
      'storageAccountsShouldUseCustomerManagedKeyForEncryptionMonitoringEffect': {
        value: mcsbSettings.storageAccountsShouldUseCustomerManagedKeyForEncryptionMonitoringEffect }
      'storageAccountsShouldRestrictNetworkAccessUsingVirtualNetworkRulesMonitoringEffect': {
        value: mcsbSettings.storageAccountsShouldRestrictNetworkAccessUsingVirtualNetworkRulesMonitoringEffect }
      'containerRegistriesShouldBeEncryptedWithACustomerManagedKeyMonitoringEffect': {
        value: mcsbSettings.containerRegistriesShouldBeEncryptedWithACustomerManagedKeyMonitoringEffect }
      'containerRegistriesShouldNotAllowUnrestrictedNetworkAccessMonitoringEffect': {
        value: mcsbSettings.containerRegistriesShouldNotAllowUnrestrictedNetworkAccessMonitoringEffect }
      'containerRegistriesShouldUsePrivateLinkMonitoringEffect': {
        value: mcsbSettings.containerRegistriesShouldUsePrivateLinkMonitoringEffect }
      'appConfigurationShouldUsePrivateLinkMonitoringEffect': {
        value: mcsbSettings.appConfigurationShouldUsePrivateLinkMonitoringEffect }
      'azureEventGridDomainsShouldUsePrivateLinkMonitoringEffect': {
        value: mcsbSettings.azureEventGridDomainsShouldUsePrivateLinkMonitoringEffect }
      'azureEventGridTopicsShouldUsePrivateLinkMonitoringEffect': {
        value: mcsbSettings.azureEventGridTopicsShouldUsePrivateLinkMonitoringEffect }
      'azureSignalRServiceShouldUsePrivateLinkMonitoringEffect': {
        value: mcsbSettings.azureSignalRServiceShouldUsePrivateLinkMonitoringEffect }
      'azureMachineLearningWorkspacesShouldBeEncryptedWithACustomerManagedKeyMonitoringEffect': {
        value: mcsbSettings.azureMachineLearningWorkspacesShouldBeEncryptedWithACustomerManagedKeyMonitoringEffect }
      'azureMachineLearningWorkspacesShouldUsePrivateLinkMonitoringEffect': {
        value: mcsbSettings.azureMachineLearningWorkspacesShouldUsePrivateLinkMonitoringEffect }
      'webApplicationFirewallShouldBeEnabledForAzureFrontDoorServiceServiceMonitoringEffect': {
        value: mcsbSettings.webApplicationFirewallShouldBeEnabledForAzureFrontDoorServiceServiceMonitoringEffect }
      'webApplicationFirewallShouldBeEnabledForApplicationGatewayMonitoringEffect': {
        value: mcsbSettings.webApplicationFirewallShouldBeEnabledForApplicationGatewayMonitoringEffect }
      'publicNetworkAccessShouldBeDisabledForMariaDbServersMonitoringEffect': {
        value: mcsbSettings.publicNetworkAccessShouldBeDisabledForMariaDbServersMonitoringEffect }
      'publicNetworkAccessShouldBeDisabledForMySqlServersMonitoringEffect': {
        value: mcsbSettings.publicNetworkAccessShouldBeDisabledForMySqlServersMonitoringEffect }
      'bringYourOwnKeyDataProtectionShouldBeEnabledForMySqlServersMonitoringEffect': {
        value: mcsbSettings.bringYourOwnKeyDataProtectionShouldBeEnabledForMySqlServersMonitoringEffect }
      'publicNetworkAccessShouldBeDisabledForPostgreSqlServersMonitoringEffect': {
        value: mcsbSettings.publicNetworkAccessShouldBeDisabledForPostgreSqlServersMonitoringEffect }
      'bringYourOwnKeyDataProtectionShouldBeEnabledForPostgreSqlServersMonitoringEffect': {
        value: mcsbSettings.bringYourOwnKeyDataProtectionShouldBeEnabledForPostgreSqlServersMonitoringEffect }
      'vmImageBuilderTemplatesShouldUsePrivateLinkMonitoringEffect': {
        value: mcsbSettings.vmImageBuilderTemplatesShouldUsePrivateLinkMonitoringEffect }
      'firewallShouldBeEnabledOnKeyVaultMonitoringEffect': {
        value: mcsbSettings.firewallShouldBeEnabledOnKeyVaultMonitoringEffect }
      'privateEndpointShouldBeConfiguredForKeyVaultMonitoringEffect': {
        value: mcsbSettings.privateEndpointShouldBeConfiguredForKeyVaultMonitoringEffect }
      'azureSpringCloudShouldUseNetworkInjectionMonitoringEffect': {
        value: mcsbSettings.azureSpringCloudShouldUseNetworkInjectionMonitoringEffect }
      'subscriptionsShouldHaveAContactEmailAddressForSecurityIssuesMonitoringEffect': {
        value: mcsbSettings.subscriptionsShouldHaveAContactEmailAddressForSecurityIssuesMonitoringEffect }
      'autoProvisioningOfTheLogAnalyticsAgentShouldBeEnabledOnYourSubscriptionMonitoringEffect': {
        value: mcsbSettings.autoProvisioningOfTheLogAnalyticsAgentShouldBeEnabledOnYourSubscriptionMonitoringEffect }
      'emailNotificationForHighSeverityAlertsShouldBeEnabledMonitoringEffect': {
        value: mcsbSettings.emailNotificationForHighSeverityAlertsShouldBeEnabledMonitoringEffect }
      'emailNotificationToSubscriptionOwnerForHighSeverityAlertsShouldBeEnabledMonitoringEffect': {
        value: mcsbSettings.emailNotificationToSubscriptionOwnerForHighSeverityAlertsShouldBeEnabledMonitoringEffect }
      'storageAccountShouldUseAPrivateLinkConnectionMonitoringEffect': {
        value: mcsbSettings.storageAccountShouldUseAPrivateLinkConnectionMonitoringEffect }
      'authenticationToLinuxMachinesShouldRequireSSHKeysMonitoringEffect': {
        value: mcsbSettings.authenticationToLinuxMachinesShouldRequireSshKeysMonitoringEffect }
      'privateEndpointConnectionsOnAzureSQLDatabaseShouldBeEnabledMonitoringEffect': {
        value: mcsbSettings.privateEndpointConnectionsOnAzureSQLDatabaseShouldBeEnabledMonitoringEffect }
      'publicNetworkAccessOnAzureSQLDatabaseShouldBeDisabledMonitoringEffect': {
        value: mcsbSettings.publicNetworkAccessOnAzureSQLDatabaseShouldBeDisabledMonitoringEffect }
      'kubernetesClustersShouldBeAccessibleOnlyOverHTTPSMonitoringEffect': {
        value: mcsbSettings.kubernetesClustersShouldBeAccessibleOnlyOverHttpsMonitoringEffect }
      'kubernetesClustersShouldBeAccessibleOnlyOverHTTPSExcludedNamespaces': {
        value: mcsbSettings.kubernetesClustersShouldBeAccessibleOnlyOverHttpsExcludedNamespaces }
      'kubernetesClustersShouldBeAccessibleOnlyOverHTTPSNamespaces': {
        value: mcsbSettings.kubernetesClustersShouldBeAccessibleOnlyOverHttpsNamespaces }
      'windowsWebServersShouldBeConfiguredToUseSecureCommunicationProtocolsMonitoringEffect': {
        value: mcsbSettings.windowsWebServersShouldBeConfiguredToUseSecureCommunicationProtocolsMonitoringEffect }
      'windowsWebServersShouldBeConfiguredToUseSecureCommunicationProtocolsIncludeArcMachines': {
        value: mcsbSettings.windowsWebServersShouldBeConfiguredToUseSecureCommunicationProtocolsIncludeArcMachines }
      'windowsWebServersShouldBeConfiguredToUseSecureCommunicationProtocolsMinimumTLSVersion': {
        value: mcsbSettings.windowsWebServersShouldBeConfiguredToUseSecureCommunicationProtocolsMinimumTLSVersion }
      'cognitiveServicesAccountsShouldRestrictNetworkAccessMonitoringEffect': {
        value: mcsbSettings.cognitiveServicesAccountsShouldRestrictNetworkAccessMonitoringEffect }
      'publicNetworkAccessShouldBeDisabledForCognitiveServicesAccountsMonitoringEffect': {
        value: mcsbSettings.publicNetworkAccessShouldBeDisabledForCognitiveServicesAccountsMonitoringEffect }
      'aPIManagementServicesShouldUseAVirtualNetworkMonitoringEffect': {
        value: mcsbSettings.apiManagementServicesShouldUseAVirtualNetworkMonitoringEffect }
      'aPIManagementServicesShouldUseAVirtualNetworkEvaluatedSkuNames': {
        value: mcsbSettings.apiManagementServicesShouldUseAVirtualNetworkEvaluatedSkuNames }
      'azureCosmosDBAccountsShouldHaveFirewallRulesMonitoringEffect': {
        value: mcsbSettings.azureCosmosDbaccountsShouldHaveFirewallRulesMonitoringEffect }
      'networkWatcherShouldBeEnabledMonitoringEffect': {
        value: mcsbSettings.networkWatcherShouldBeEnabledMonitoringEffect }
      'networkWatcherShouldBeEnabledResourceGroupName': {
        value: mcsbSettings.networkWatcherShouldBeEnabledResourceGroupName }
      'AzureDefenderForResourceManagerShouldBeEnabledMonitoringEffect': {
        value: mcsbSettings.azureDefenderForResourceManagerShouldBeEnabledMonitoringEffect }
      'AzureDefenderForDNSShouldBeEnabledMonitoringEffect': {
        value: mcsbSettings.azureDefenderForDnsShouldBeEnabledMonitoringEffect }
      'AzureDefenderForOpenSourceRelationalDatabasesShouldBeEnabledMonitoringEffect': {
        value: mcsbSettings.azureDefenderForOpenSourceRelationalDatabasesShouldBeEnabledMonitoringEffect }
      'MicrosoftDefenderCSPMShouldBeEnabledMonitoringEffect': {
        value: mcsbSettings.microsoftDefenderCspmShouldBeEnabledMonitoringEffect }
      'KubernetesClustersShouldNotUseTheDefaultNamespaceMonitoringEffect': {
        value: mcsbSettings.kubernetesClustersShouldNotUseTheDefaultNamespaceMonitoringEffect }
      'KubernetesClustersShouldDisableAutomountingAPICredentialsMonitoringEffect': {
        value: mcsbSettings.kubernetesClustersShouldDisableAutomountingApiCredentialsMonitoringEffect }
      'KubernetesClustersShouldDisableAutomountingAPICredentialsMonitoringNamespaceExclusion': {
        value: mcsbSettings.kubernetesClustersShouldDisableAutomountingApiCredentialsMonitoringNamespaceExclusion }
      'KubernetesClustersShouldNotGrantCAPSYSADMINSecurityCapabilitiesMonitoringEffect': {
        value: mcsbSettings.KubernetesClustersShouldNotGrantCapsysadminSecurityCapabilitiesMonitoringEffect }
      'KubernetesClustersShouldNotGrantCAPSYSADMINSecurityCapabilitiesMonitoringNamespaceExclusion': {
        value: mcsbSettings.kubernetesClustersShouldNotGrantCapsysadminSecurityCapabilitiesMonitoringNamespaceExclusion }
      'VtpmShouldBeEnabledOnSupportedVirtualMachinesMonitoringEffect': {
        value: mcsbSettings.vtpmShouldBeEnabledOnSupportedVirtualMachinesMonitoringEffect }
      'SecureBootShouldBeEnabledOnSupportedWindowsVirtualMachinesMonitoringEffect': {
        value: mcsbSettings.secureBootShouldBeEnabledOnSupportedWindowsVirtualMachinesMonitoringEffect }
      'GuestAttestationExtensionShouldBeInstalledOnSupportedLinuxVirtualMachinesMonitoringEffect': {
        value: mcsbSettings.GuestAttestationExtensionShouldBeInstalledOnSupportedLinuxVirtualMachinesMonitoringEffect }
      'GuestAttestationExtensionShouldBeInstalledOnSupportedLinuxVirtualMachinesScaleSetsMonitoringEffect': {
        value: mcsbSettings.guestAttestationExtensionShouldBeInstalledOnSupportedLinuxVirtualMachinesScaleSetsMonitoringEffect }
      'GuestAttestationExtensionShouldBeInstalledOnSupportedWindowsVirtualMachinesMonitoringEffect': {
        value: mcsbSettings.guestAttestationExtensionShouldBeInstalledOnSupportedWindowsVirtualMachinesMonitoringEffect }
      'GuestAttestationExtensionShouldBeInstalledOnSupportedWindowsVirtualMachinesScaleSetsMonitoringEffect': {
        value: mcsbSettings.guestAttestationExtensionShouldBeInstalledOnSupportedWindowsVirtualMachinesScaleSetsMonitoringEffect }
      'installEndpointProtectionMonitoringEffect': {
        value: mcsbSettings.installEndpointProtectionMonitoringEffect }
      'endpointProtectionHealthIssuesMonitoringEffect': {
        value: mcsbSettings.endpointProtectionHealthIssuesMonitoringEffect }
      'allowedContainerImagesLabelSelector': {
        value: mcsbSettings.allowedContainerImagesLabelSelector }
      'privilegedContainerLabelSelector': {
        value: mcsbSettings.privilegedContainerLabelSelector }
      'allowedServicePortsInKubernetesClusterLabelSelector': {
        value: mcsbSettings.allowedServicePortsInKubernetesClusterLabelSelector }
      'NoPrivilegeEscalationInKubernetesClusterLabelSelector': {
        value: mcsbSettings.noPrivilegeEscalationInKubernetesClusterLabelSelector }
      'NoSharingSensitiveHostNamespacesInKubernetesLabelSelector': {
        value: mcsbSettings.noSharingSensitiveHostNamespacesInKubernetesLabelSelector }
      'AllowedCapabilitiesInKubernetesClusterLabelSelector': {
        value: mcsbSettings.allowedCapabilitiesInKubernetesClusterLabelSelector }
      'AllowedAppArmorProfilesInKubernetesClusterLabelSelector': {
        value: mcsbSettings.allowedAppArmorProfilesInKubernetesClusterLabelSelector }
      'AllowedHostNetworkingAndPortsInKubernetesClusterLabelSelector': {
        value: mcsbSettings.allowedHostNetworkingAndPortsInKubernetesClusterLabelSelector }
      'AllowedHostPathVolumesInKubernetesClusterLabelSelector': {
        value: mcsbSettings.allowedHostPathVolumesInKubernetesClusterLabelSelector }
      'memoryAndCPULimitsInKubernetesClusterLabelSelector': {
        value: mcsbSettings.memoryAndCpuLimitsInKubernetesClusterLabelSelector }
      'MustRunAsNonRootLabelSelector': {
        value: mcsbSettings.mustRunAsNonRootLabelSelector }
      'azureContainerRegistryVulnerabilityAssessmentEffect': {
        value: mcsbSettings.azureContainerRegistryVulnerabilityAssessmentEffect }
      'kubernetesRunningImagesVulnerabilityMDVMAssessmentEffect': {
        value: mcsbSettings.kubernetesRunningImagesVulnerabilityMdvmAssessmentEffect }
      'KubernetesClustersShouldNotUseTheDefaultNamespaceMonitoringLabelSelector': {
        value: mcsbSettings.kubernetesClustersShouldNotUseTheDefaultNamespaceMonitoringLabelSelector }
      'KubernetesClustersShouldDisableAutomountingAPICredentialsMonitoringLabelSelector': {
        value: mcsbSettings.kubernetesClustersShouldDisableAutomountingApiCredentialsMonitoringLabelSelector }
      'KubernetesClustersShouldNotGrantCAPSYSADMINSecurityCapabilitiesMonitoringLabelSelector': {
        value: mcsbSettings.kubernetesClustersShouldNotGrantCapSysadminSecurityCapabilitiesMonitoringLabelSelector }
      'LinuxVirtualMachineShouldUseSignedAndTrustedBootComponentEffect': {
        value: mcsbSettings.LinuxVirtualMachineShouldUseSignedAndTrustedBootComponentEffect }
      'kubernetesClustersShouldBeAccessibleOnlyOverHTTPSLabelSelector': {
        value: mcsbSettings.kubernetesClustersShouldBeAccessibleOnlyOverHttpsLabelSelector }
      'ReadOnlyRootFileSystemInKubernetesClusterLabelSelector': {
        value: mcsbSettings.readOnlyRootFileSystemInKubernetesClusterLabelSelector }
    }
    policyDefinitionId: assignmentProperties.policyDefinitionId
  }
}
// OUTPUTS
