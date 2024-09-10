# policy/securityBenchmark/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 role assignment.

This policy will deploy the Microsoft cloud security benchmarkpolicy definition set.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/mcsbAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    securityBenchmarkAuditDenySetAssignmentName: 'securitybenchmark.auditdeny.policy.def.assignment'
    securityBenchmarkAuditDenySetAssignmentDisplayName: 'Microsoft cloud security benchmark auditdeny policy definition set'
    mcsbPolicyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"'
    policyMetadata : 'EvidenELZ'
    mcsbSettings: mcsbAuditDenySettings
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `securityBenchmarkAuditDenySetAssignmentName` | `string` | true | Specify name for assignment of security benchmark audit deny initiative. |
| `securityBenchmarkAuditDenySetAssignmentDisplayName` | `string` | true | Specify display name for assignment of security benchmark audit deny initiative. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |
| `mcsbPolicyDefinitionId` | `string` | true | Specify the policy definition id of the built-in MCSB Initiative. |

### Object - mcsbSettings
| Name | Type | Description |
| --- | --- | --- |
| `installLogAnalyticsAgentOnVmMonitoringEffect` | `String` | Log Analytics agent should be installed on your virtual machine for Microsoft Defender for Cloud monitoring. Allowed Values: AuditIfNotExists; Disabled. |
| `installLogAnalyticsAgentOnVmssMonitoringEffect` | `String` | Log Analytics agent should be installed on your virtual machine scale sets for Microsoft Defender for Cloud monitoring. Allowed Values: AuditIfNotExists; Disabled. |
| `certificatesValidityPeriodMonitoringEffect` | `String` | Manage certificate validity period. Allowed Values: audit; deny; Disabled. |
| `certificatesValidityPeriodInMonths` | `Integer` | The maximum validity period in months of managed certificate. |
| `secretsExpirationSetEffect` | `String` | Key Vault secrets should have expiration dates set. Allowed Values: Audit; Deny; Disabled. |
| `keysExpirationSetEffect` | `String` | Key Vault keys should have expiration dates set. Allowed Values: Audit; Deny; Disabled. |
| `azurePolicyforWindowsMonitoringEffect` | `String` | Guest Configuration extension should be installed on virtual machines. Allowed Values: AuditIfNotExists; Disabled. | |
| `gcExtOnVmWithNoSamiMonitoringEffect` | `String` | Virtual machines' Guest Configuration extension should be deployed with system-assigned managed identity. Allowed Values: AuditIfNotExists;Disabled. |
| `windowsDefenderExploitGuardMonitoringEffect` | `String` | Windows Defender Exploit Guard should be enabled on your Windows virtual machines. Allowed Values: AuditIfNotExists; Disabled. |
| `windowsGuestConfigBaselinesMonitoringEffect` | `String` | Vulnerabilities in security configuration on your Windows machines should be remediated (powered by Guest Config). Allowed Values: AuditIfNotExists; Disabled. | |
| `linuxGuestConfigBaselinesMonitoringEffect` | `String` | Vulnerabilities in security configuration on your Linux machines should be remediated (powered by Guest Config). Allowed Values: AuditIfNotExists; Disabled. |
| `vmssSystemUpdatesMonitoringEffect` | `String` | System updates on virtual machine scale sets should be installed. Allowed Values: AuditIfNotExists; Disabled. |
| `vmssEndpointProtectionMonitoringEffect` | `String` | Endpoint protection solution should be installed on virtual machine scale sets. Allowed Values: AuditIfNotExists; Disabled. |
| `vmssOsVulnerabilitiesMonitoringEffect` | `String` | Vulnerabilities in security configuration on your virtual machine scale sets should be remediated. Allowed Values: AuditIfNotExists; Disabled. |
| `systemUpdatesMonitoringEffect` | `String` | System updates should be installed on your machines. Allowed Values: AuditIfNotExists; Disabled. |
| `systemUpdatesV2MonitoringEffect` | `String` | System updates should be installed on your machines (powered by Update Center). Allowed Values: AuditIfNotExists; Disabled. |
| `systemUpdatesAutoAssessmentModeEffect` | `String` | Machines should be configured to periodically check for missing system updates. Allowed Values: Audit; Disabled. |
| `systemConfigurationsMonitoringEffect` | `String` | Vulnerabilities in security configuration on your machines should be remediated. Allowed Values: AuditIfNotExists; Disabled. |
| `endpointProtectionMonitoringEffect` | `String` | Monitor missing Endpoint Protection in Microsoft Defender for Cloud. Allowed Values: AuditIfNotExists; Disabled. |
| `diskEncryptionMonitoringEffect` | `String` | Virtual machines should encrypt temp disks, caches, and data flows between Compute and Storage resources. Allowed Values: AuditIfNotExists; Disabled. |
| `gcLinuxDiskEncryptionMonitoringEffect` | `String` | Linux machines should encrypt temp disks, caches, and data flows between Compute and Storage resources. Allowed Values: AuditIfNotExists; Disabled. |
| `gcWindowsDiskEncryptionMonitoringEffect` | `String` | Windows machines should encrypt temp disks, caches, and data flows between Compute and Storage resources. Allowed Values: AuditIfNotExists; Disabled. |
| `networkSecurityGroupsOnSubnetsMonitoringEffect` | `String` | Network Security Groups on the subnet level should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `networkSecurityGroupsOnVirtualMachinesMonitoringEffect` | `String` | Internet-facing virtual machines should be protected with network security groups. Allowed Values: AuditIfNotExists; Disabled. |
| `networkSecurityGroupsOnInternalVirtualMachinesMonitoringEffect` | `String` | Non-internet-facing virtual machines should be protected with network security groups. Allowed Values: AuditIfNotExists; Disabled. |
| `nextGenerationFirewallMonitoringEffect` | `String` | All network ports should be restricted on network security groups associated to your virtual machine. Allowed Values: AuditIfNotExists; Disabled. |
| `serverVulnerabilityAssessmentEffect` | `String` | A vulnerability assessment solution should be enabled on your virtual machines. Allowed Values: AuditIfNotExists; Disabled. |
| `jitNetworkAccessMonitoringEffect` | `String` | Management ports of virtual machines should be protected with just-in-time network access control. Allowed Values: AuditIfNotExists; Disabled. |
| `adaptiveApplicationControlsMonitoringEffect` | `String` | Adaptive application controls for defining safe applications should be enabled on your machines. Allowed Values: AuditIfNotExists; Disabled. |
| `adaptiveApplicationControlsUpdateMonitoringEffect` | `String` | Allowlist rules in your adaptive application control policy should be updated. Allowed Values: AuditIfNotExists; Disabled. |
| `sqlDbEncryptionMonitoringEffect` | `String` | Transparent Data Encryption on SQL databases should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `sqlServerAuditingMonitoringEffect` | `String` | Auditing should be enabled on advanced data security settings on SQL Server. Allowed Values: AuditIfNotExists; Disabled. |
| `encryptionOfAutomationAccountMonitoringEffect` | `String` | Automation account variables should be encrypted. Allowed Values: Audit; Deny; Disabled. |
| `diagnosticsLogsInBatchAccountMonitoringEffect` | `String` | Resource logs in Batch accounts should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `diagnosticsLogsInBatchAccountRetentionDays` | `String` | Required retention (in days) for logs in Batch accounts. |
| `classicComputeVmsMonitoringEffect` | `String` | Virtual machines should be migrated to new Azure Resource Manager resources. Allowed Values: Audit; Deny; Disabled. |
| `classicStorageAccountsMonitoringEffect` | `String` | Storage accounts should be migrated to new Azure Resource Manager resources. Allowed Values: Audit; Deny; Disabled. |
| `diagnosticsLogsInDataLakeAnalyticsMonitoringEffect` | `String` | Resource logs in Data Lake Analytics should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `diagnosticsLogsInDataLakeAnalyticsRetentionDays` | `String` | Required retention (in days) of logs in Data Lake Analytics accounts. |
| `diagnosticsLogsInDataLakeStoreMonitoringEffect` | `String` | Resource logs in Azure Data Lake Store should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `diagnosticsLogsInDataLakeStoreRetentionDays` | `String` | Required retention (in days) of logs in Data Lake Store accounts. |
| `diagnosticsLogsInEventHubMonitoringEffect` | `String` | Resource logs in Event Hub should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `diagnosticsLogsInEventHubRetentionDays` | `String` | Required retention (in days) of logs in Event Hub accounts. |
| `diagnosticsLogsInKeyVaultMonitoringEffect` | `String` | Resource logs in Key Vault should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `diagnosticsLogsInKeyVaultRetentionDays` | `String` | Required retention (in days) of logs in Key Vault vaults. |
| `diagnosticsLogsInKubernetesMonitoringEffect` | `String` | Resource logs in Azure Kubernetes Service should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `diagnosticsLogsInKubernetesRetentionDays` | `String` | Required retention (in days) of logs in Kubernetes managed clusters.
| `diagnosticsLogsInLogicAppsMonitoringEffect` | `String` | Resource logs in Logic Apps should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `diagnosticsLogsInLogicAppsRetentionDays` | `String` | Required retention (in days) of logs in Logic Apps workflows. |
| `diagnosticsLogsInRedisCacheMonitoringEffect` | `String` | Only secure connections to your Redis Cache should be enabled. Allowed Values: Audit; Deny; Disabled. |
| `diagnosticsLogsInSearchServiceMonitoringEffect` | `String` | Resource logs in Search services should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `diagnosticsLogsInSearchServiceRetentionDays` | `String` | Required retention (in days) of logs in Azure Search service. |
| `aadAuthenticationInServiceFabricMonitoringEffect` | `String` | Service Fabric clusters should only use Azure Active Directory for client authentication. Allowed Values: Audit; Deny; Disabled. |
| `clusterProtectionLevelInServiceFabricMonitoringEffect` | `String` | Service Fabric clusters should have the ClusterProtectionLevel property set to EncryptAndSign. Allowed Values: Audit; Deny; Disabled. |
| `diagnosticsLogsInServiceBusMonitoringEffect` | `String` | Resource logs in Service Bus should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `diagnosticsLogsInServiceBusRetentionDays` | `String` | Required retention (in days) of logs in Service Bus. |
| `aadAuthenticationInSqlServerMonitoringEffect` | `String` | An Azure Active Directory administrator should be provisioned for SQL servers. Allowed Values: AuditIfNotExists; Disabled. |
| `secureTransferToStorageAccountMonitoringEffect` | `String` | Secure transfer to storage accounts should be enabled. Allowed Values: Audit; Deny; Disabled. |
| `diagnosticsLogsInStreamAnalyticsMonitoringEffect` | `String` | Resource logs in Azure Stream Analytics should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `diagnosticsLogsInStreamAnalyticsRetentionDays` | `String` | Required retention (in days) of logs in Stream Analytics. |
| `useRbacRulesMonitoringEffect` | `String` | Audit usage of custom RBAC rules. Allowed Values: Audit; Disabled. |
| `disableUnrestrictedNetworkToStorageAccountMonitoringEffect` | `String` | Audit unrestricted network access to storage accounts. Allowed Values: Audit; Deny; Disabled. |
| `sqlDbVulnerabilityAssesmentMonitoringEffect` | `String` | SQL databases should have vulnerability findings resolved. Allowed Values: AuditIfNotExists; Disabled. |
| `serverSqlDbVulnerabilityAssesmentMonitoringEffect` | `String` | SQL servers on machines should have vulnerability findings resolved. Allowed Values: AuditIfNotExists; Disabled. |
| `identityDesignateLessThanOwnersMonitoringEffect` | `String` | A maximum of 3 owners should be designated for your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `identityDesignateMoreThanOneOwnerMonitoringEffect` | `String` | There should be more than one owner assigned to your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `identityEnableMfaForOwnerPermissionsMonitoringEffect` | `String` | MFA should be enabled on accounts with owner permissions on your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `identityEnableMfaForWritePermissionsMonitoringEffect` | `String` | MFA should be enabled accounts with write permissions on your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `identityEnableMfaForReadPermissionsMonitoringEffect` | `String` | MFA should be enabled on accounts with read permissions on your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `identityRemoveExternalAccountWithOwnerPermissionsMonitoringEffect` | `String` | External accounts with owner permissions should be removed from your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `identityRemoveExternalAccountWithWritePermissionsMonitoringEffect` | `String` | External accounts with write permissions should be removed from your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `identityRemoveExternalAccountWithReadPermissionsMonitoringEffect` | `String` | External accounts with read permissions should be removed from your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `functionAppDisableRemoteDebuggingMonitoringEffect` | `String` | Remote debugging should be turned off for Function App. Allowed Values: AuditIfNotExists; Disabled. |
| `webAppDisableRemoteDebuggingMonitoringEffect` | `String` | Remote debugging should be turned off for Web Application. Allowed Values: AuditIfNotExists; Disabled. |
| `functionAppEnforceHttpsMonitoringEffectV2` | `String` | Function App should only be accessible over HTTPS V2. Allowed Values: Audit; Disabled. |
|`webAppEnforceHttpsMonitoringEffectV2` | `String` | Web Application should only be accessible over HTTPS V2. Allowed Values: Audit; Disabled. |
| `functionAppRestrictCorsAccessMonitoringEffect` | `String` | CORS should not allow every resource to access your Function App. Allowed Values: AuditIfNotExists; Disabled. |
| `webAppRestrictCorsAccessMonitoringEffect` | `String` | CORS should not allow every resource to access your Web Application. Allowed Values: AuditIfNotExists; Disabled. |
| `vnetEnableDdoSProtectionMonitoringEffect` | `String` | Azure DDoS Protection Standard should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `diagnosticsLogsInIotHubMonitoringEffect` | `String` | Resource logs in IoT Hub should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `diagnosticsLogsInIotHubRetentionDays` | `String` | Required retention (in days) of logs in IoT Hub accounts. |
| `sqlServerAdvancedDataSecurityMonitoringEffect` | `String` | Azure Defender for SQL should be enabled for unprotected Azure SQL servers. Allowed Values: AuditIfNotExists; Disabled. |
| `arcEnabledSqlServerDefenderStatusEffect` | `String` | Microsoft Defender for SQL status should be protected for Arc-enabled SQL Servers. Allowed Values: Audit; Disabled. |
| `sqlManagedInstanceAdvancedDataSecurityMonitoringEffect` | `String` | Azure Defender for SQL should be enabled for unprotected SQL Managed Instances. Allowed Values: AuditIfNotExists; Disabled. |
| `kubernetesServiceRbacEnabledMonitoringEffect` | `String` | Role-Based Access Control (RBAC) should be used on Kubernetes Services. Allowed Values: Audit; Disabled. |
| `kubernetesServiceAuthorizedIpRangesEnabledMonitoringEffect` | `String` | Authorized IP ranges should be defined on Kubernetes Services. Allowed Values: Audit; Disabled. |
| `vulnerabilityAssessmentOnManagedInstanceMonitoringEffect` | `String` | Vulnerability assessment should be enabled on SQL Managed Instance. Allowed Values: AuditIfNotExists; Disabled. |
| `vulnerabilityAssessmentOnServerMonitoringEffect` | `String` | Vulnerability assessment should be enabled on your SQL servers. Allowed Values: AuditIfNotExists; Disabled. |
| `adaptiveNetworkHardeningsMonitoringEffect` | `String` | Adaptive network hardening recommendations should be applied on internet facing virtual machines. Allowed Values: AuditIfNotExists; Disabled. |
| `restrictAccessToManagementPortsMonitoringEffect` | `String` | Management ports should be closed on your virtual machines. Allowed Values: AuditIfNotExists; Disabled. |
| `disableIpForwardingMonitoringEffect` | `String` | IP Forwarding on your virtual machine should be Disabled. | Allowed Values: AuditIfNotExists; Disabled. |
| `ensureServerTdeisEncryptedWithYourOwnKeyWithDenyMonitoringEffect` | `String` | SQL server TDE protector should be encrypted with your own key. Allowed Values: Audit; Deny; Disabled. |
| `ensureManagedInstanceTdeisEncryptedWithYourOwnKeyWithDenyMonitoringEffect` | `String` | SQL Managed Instance TDE protector should be encrypted with your own key. Allowed Values: Audit; Deny; Disabled. |
| `containerBenchmarkMonitoringEffect` | `String` | Vulnerabilities in container security configurations should be remediated. Allowed Values: AuditIfNotExists; Disabled. |
| `ascDependencyAgentAuditWindowsEffect` | `String` | Audit Dependency Agent for Windows VMs monitoring. Allowed Values: AuditIfNotExists; Disabled. |
| `ascDependencyAgentAuditLinuxEffect` | `String` | Audit Dependency Agent for Linux VMs monitoring. Allowed Values: AuditIfNotExists; Disabled. |
| `azureFirewallEffect` | `String` | All Internet traffic should be routed via your deployed Azure Firewall. Allowed Values: AuditIfNotExists; Disabled. |
| `arcWindowsMonitoringEffect` | `String` | Log Analytics agent should be installed on your  Windows Azure Arc machines. Allowed Values: AuditIfNotExists; Disabled. |
| `arcLinuxMonitoringEffect` | `String` | Log Analytics agent should be installed on your Linux Azure Arc machines. Allowed Values: AuditIfNotExists; Disabled. |
| `keyVaultsAdvancedDataSecurityMonitoringEffect` | `String` | Azure Defender for Key Vault should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `sqlServersAdvancedDataSecurityMonitoringEffect` | `String` | Azure Defender for Azure SQL Database servers should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `sqlServersVirtualMachinesAdvancedDataSecurityMonitoringEffect` | `String` | Azure Defender for SQL servers on machines should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `appServicesAdvancedThreatProtectionMonitoringEffect` | `String` | Azure Defender for App Services should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `containersAdvancedThreatProtectionMonitoringEffect` | `String` | Microsoft Defender for Containers should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `virtualMachinesAdvancedThreatProtectionMonitoringEffect` | `String` | Azure Defender for servers should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `azurePolicyAddonStatusEffect` | `String` | Azure Policy Add-on for Kubernetes should be installed and enabled on Azure Kubernetes Service (AKS) clusters. Allowed Values: Audit; Disabled. |
| `arcEnabledKubernetesClustersShouldHaveAzurePolicyExtensionInstalledEffect` | `String` | Azure Arc enabled Kubernetes clusters should have Azure Policy's extension installed. Allowed Values: AuditIfNotExists; Disabled. |
| `excludedImagesInKubernetesCluster` | `Array` | Kubernetes image to exclude from monitoring of all container related polices. |
| `allowedContainerImagesInKubernetesClusterEffect` | `String` | Container images should be deployed from trusted registries only. Allowed Values: Audit; Deny; Disabled. |
| `allowedContainerImagesInKubernetesClusterRegex` | `String` | Allowed registry or registries regex. |
| `allowedContainerImagesNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of allowed container images.
| `privilegedContainersShouldBeAvoidedEffect` | `String` | Privileged containers should be avoided. Allowed Values: Audit; Deny; Disabled. |
| `privilegedContainerNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of privileged containers.
| `allowedServicePortsInKubernetesClusterEffect` | `String` | Services should listen on allowed ports only. Allowed Values: Audit; Deny; Disabled. |
|`allowedservicePortsInKubernetesClusterPorts` | `Array` | Allowed service ports list in Kubernetes cluster. |
| `allowedServicePortsInKubernetesClusterNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of allowed service ports.
| `noPrivilegeEscalationInKubernetesClusterEffect` | `String` | Container with privileged escalation should be avoided. Allowed Values: Audit; Deny; Disabled. |
| `noPrivilegeEscalationInKubernetesClusterNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of privileged escalation containers.
| `noSharingSensitiveHostNamespacesInKubernetesEffect` | `String` | Containers sharing sensitive host namespaces should be avoided. Allowed Values: Audit; Deny; Disabled. |
| `noSharingSensitiveHostNamespacesInKubernetesNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of sharing sensitive host namespaces in Kubernetes clusters.
| `readOnlyRootFileSystemInKubernetesClusterEffect` | `String` | Immutable (read-only) root filesystem should be enforced for containers. Allowed Values: Audit; Deny; Disabled. |
| `readOnlyRootFileSystemInKubernetesClusterNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of containers running with a read only root file system.
| `allowedCapabilitiesInKubernetesClusterEffect` | `String` | Least privileged Linux capabilities should be enforced for containers. Allowed Values: Audit; Deny; Disabled. |
| `allowedCapabilitiesInKubernetesClusterNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of containers use only allowed capabilities.
| `allowedCapabilitiesInKubernetesClusterList` | `Array` | Allowed capabilities.
| `dropCapabilitiesInKubernetesClusterList` | `Array` | Required drop capabilities.
| `allowedAppArmorProfilesInKubernetesClusterEffect` | `String` | Containers should only use allowed AppArmor profiles. Allowed Values: Audit; Deny; Disabled. |
| `allowedAppArmorProfilesInKubernetesClusterNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of containers modification of AppArmor profile.
| `allowedAppArmorProfilesInKubernetesClusterList` | `Array` | Allowed AppArmor profiles.
| `allowedHostNetworkingAndPortsInKubernetesClusterEffect` | `String` | Usage of host networking and ports should be restricted. Allowed Values: Audit; Deny; Disabled. |
| `allowedHostNetworkingAndPortsInKubernetesClusterNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of containers host networking and ports.
| `allowHostNetworkingInKubernetesCluster` | `Boolean` | Allow host network usage. Allowed Values: true; false. |
| `allowedHostMinPortInKubernetesCluster` | `Integer` | Min host port for pod in Kubernetes cluster. |
| `allowedHostMaxPortInKubernetesCluster` | `Integer` | Max host port for pod in Kubernetes cluster. |
| `allowedHostPathVolumesInKubernetesClusterEffect` | `String` | Usage of pod HostPath volume mounts should be restricted to a known list to restrict node access from compromised containers. Allowed Values: Audit; Deny; Disabled. |
| `allowedHostPathVolumesInKubernetesClusterNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of pod HostPath volume mounts.
| `allowedHostPathVolumesInKubernetesClusterList` | `Object` | Allowed host paths for pod in Kubernetes cluster. |
| `memoryAndCpuLimitsInKubernetesClusterEffect` | `String` | Containers' CPU and memory limits should be enforced. Allowed Values: Audit; Deny; Disabled. |
| `memoryInKubernetesClusterLimit` | `String` | Max allowed memory bytes in Kubernetes cluster. |
| `cpuInKubernetesClusterLimit` | `String` | Max allowed CPU units in Kubernetes cluster. |
| `memoryAndCpuLimitsInKubernetesClusterNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of memory and CPU limits. |
| `blockVulnerableImagesInKubernetesClusterEffect` | `String` | Kubernetes clusters should gate deployment of vulnerable images. Allowed Values: Audit; Deny; Disabled. |
| `blockVulnerableImagesInKubernetesClusterNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of containers with vulnerable images. |
| `blockVulnerableImagesExcludedImages` | `Array` | Excluded images regex for gating vulnerable images in Kubernetes cluster. |
| `blockVulnerableImagesSeverityThresholdForExcludingNotPatchableFindings` | `String` | Severity threshold for excluding gating of image vulnerabilities without a patch in Kubernetes cluster. Allowed Values: None; Low; Medium; High. |
| `blockVulnerableImagesExcludeFindingIds` | `Array` | Exclude finding IDs for gating vulnerable images scan results in Kubernetes cluster. |
| `severity` | `Object` | Severity threshold for excluding gating of image vulnerabilities in Kubernetes cluster. |
| `mustRunAsNonRootNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from monitoring of containers running as root user.
| `mustRunAsNonRootNamespaceEffect` | `String` | Kubernetes containers should not be run as root user. Allowed Values: Audit; Deny; Disabled. |
| `arcEnabledKubernetesClustersShouldHaveAzureDefendersExtensionInstalled` | `String` | Azure Arc enabled Kubernetes clusters should have Azure Defender's extension installed. Allowed Values: AuditIfNotExists; Disabled. |
| `azureKubernetesServiceClustersShouldHaveSecurityProfileEnabled` | `String` | Azure Kubernetes Service clusters should have Azure Defender profile enabled. Allowed Values: Audit; Disabled. |
| `containerRegistryVulnerabilityAssessmentEffect` | `String` | Vulnerabilities in Azure Container Registry images should be remediated. Allowed Values: AuditIfNotExists; Disabled. |
| `kubernetesRunningImagesVulnerabilityAssessmentEffect` | `String` | Vulnerabilities in running images should be remediated. Allowed Values: AuditIfNotExists; Disabled. |
| `disallowPublicBlobAccessEffect` | `String` | Storage account public access should be disallowed. Allowed Values: Audit; Deny; Disabled. |
|`azureBackupShouldBeEnabledForVirtualMachinesMonitoringEffect` | `String` | Azure Backup should be enabled for Virtual Machines. Allowed Values: AuditIfNotExists; Disabled. |
| `managedIdentityShouldBeUsedInYourFunctionAppMonitoringEffect` | `String` | Managed identity should be used in your Function App. Allowed Values: AuditIfNotExists; Disabled. |
| `geoRedundantBackupShouldBeEnabledForAzureDatabaseForMariadbMonitoringEffect` | `String` | Georedundant backup should be enabled for Azure Database for MariaDB. Allowed Values: Audit; Disabled. |
| `managedIdentityShouldBeUsedInYourWebAppMonitoringEffect` | `String` | Managed identity should be used in your Web App. Allowed Values: AuditIfNotExists; Disabled. |
| `geoRedundantBackupShouldBeEnabledForAzureDatabaseForPostgresqlMonitoringEffect` | `String` | Georedundant backup should be enabled for Azure Database for PostgreSQL. Allowed Values: Audit; Disabled. |
| `ensureWebAppHasClientCertificatesIncomingClientCertificatesSetToOnMonitoringEffect` | `String` | Ensure WEB app has Client Certificates Incoming client certificates set to On. Allowed Values: Audit; Disabled. |
| `geoRedundantBackupShouldBeEnabledForAzureDatabaseForMysqlMonitoringEffect` | `String` | Georedundant backup should be enabled for Azure Database for MySQL. Allowed Values: Audit; Disabled. |
| `diagnosticLogsInAppServicesShouldBeEnabledMonitoringEffect` | `String` | Resource logs in App Services should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `enforceSslConnectionShouldBeEnabledForPostgresqlDatabaseServersMonitoringEffect` | `String` | Enforce SSL connection should be enabled for PostgreSQL database servers. Allowed Values: Audit; Disabled. |
| `enforceSslConnectionShouldBeEnabledForMysqlDatabaseServersMonitoringEffect` | `String` | Enforce SSL connection should be enabled for MySQL database servers. Allowed Values: Audit; Disabled. |
`| latestTlsVersionShouldBeUsedInYourWebAppMonitoringEffect` | `String` | Latest TLS version should be used in your Web App. Allowed Values: AuditIfNotExists; Disabled. |
`latestTlsVersionShouldBeUsedInYourFunctionAppMonitoringEffect` | `String` | Latest TLS version should be used in your Function App. Allowed Values: AuditIfNotExists; Disabled. |
| `privateEndpointShouldBeEnabledForPostgresqlServersMonitoringEffect` | `String` | Private endpoint should be enabled for PostgreSQL servers. Allowed Values: AuditIfNotExists; Disabled. |
| `privateEndpointShouldBeEnabledForMariadbServersMonitoringEffect` | `String` | Private endpoint should be enabled for MariaDB servers. Allowed Values: AuditIfNotExists; Disabled. |
| `privateEndpointShouldBeEnabledForMysqlServersMonitoringEffect` | `String` | Private endpoint should be enabled for MySQL servers. Allowed Values: AuditIfNotExists; Disabled. |
|`sqlServersShouldBeConfiguredWithAuditingRetentionDaysGreaterThan90DaysMonitoringEffect` | `String` | SQL servers should be configured with auditing retention days greater than 90 days. Allowed Values: AuditIfNotExists; Disabled. |
| `fpsOnlyShouldBeRequiredInYourFunctionAppMonitoringEffect` | `String` | FTPS only should be required in your Function App. Allowed Values: AuditIfNotExists; Disabled. |
| `ftpsShouldBeRequiredInYourWebAppMonitoringEffect` | `String` | FTPS should be required in your Web App. Allowed Values: AuditIfNotExists; Disabled. |
| `functionAppsShouldHaveClientCertificatesEnabledMonitoringEffect` | `String` | Function apps should have 'Client Certificates (Incoming client certificates)' enabled. Allowed Values: Audit; Disabled. |
| `cognitiveServicesAccountsShouldEnableDataEncryptionWithACustomerManagedKeyMonitoringEffect` | `String` | Cognitive Services accounts should enable data encryption with a customer-managed key. Allowed Values: Audit; Deny; Disabled. |
| `azureCosmosDbAccountsShouldUseCustomerManagedKeysToEncryptDataAtRestMonitoringEffect` | `String` | Azure Cosmos DB accounts should use customer-managed keys to encrypt data at rest. Allowed Values: Audit; Deny; Disabled. |
| `azureCosmosDbAccountsShouldHaveLocalAuthenticationMethodsDisabledMonitoringEffect` | `String` | Cosmos DB database accounts should have local authentication methods Disabled. | Allowed Values: Audit; Deny; Disabled. |
| `keyVaultsShouldHavePurgeProtectionEnabledMonitoringEffect` | `String` | Key vaults should have purge protection enabled. Allowed Values: Audit; Deny; Disabled. |
| `keyVaultsShouldHaveSoftDeleteEnabledMonitoringEffect` | `String` | Key vaults should have soft delete enabled. Allowed Values: Audit; Deny; Disabled. |
| `azureCacheForRedisShouldUsePrivateEndpointMonitoringEffect` | `String` | Azure Cache for Redis should use private link. Allowed Values: AuditIfNotExists; Disabled. |
| `storageAccountsShouldUseCustomerManagedKeyForEncryptionMonitoringEffect` | `String` | Storage accounts should use customer-managed key for encryption. Allowed Values: Audit; Disabled. |
| `storageAccountsShouldRestrictNetworkAccessUsingVirtualNetworkRulesMonitoringEffect` | `String` | Storage accounts should restrict network access using virtual network rules. Allowed Values: Audit; Deny; Disabled. |
| `containerRegistriesShouldBeEncryptedWithACustomerManagedKeyMonitoringEffect` | `String` | Container registries should be encrypted with a customer-managed key. Allowed Values: Audit; Deny; Disabled. |
| `containerRegistriesShouldNotAllowUnrestrictedNetworkAccessMonitoringEffect` | `String` | Container registries should not allow unrestricted network access. Allowed Values: Audit; Disabled. |
| `containerRegistriesShouldUsePrivateLinkMonitoringEffect` | `String` | Container registries should use private link. Allowed Values: Audit; Disabled. |
| `appConfigurationShouldUsePrivateLinkMonitoringEffect` | `String` | App Configuration should use private link. Allowed Values: AuditIfNotExists; Disabled. |
| `azureEventGridDomainsShouldUsePrivateLinkMonitoringEffect` | `String` | Azure Event Grid domains should use private link. Allowed Values: Audit; Disabled. |
| `azureEventGridTopicsShouldUsePrivateLinkMonitoringEffect` | `String` | Azure Event Grid topics should use private link. Allowed Values: Audit; Disabled. |
| `azureSignalRServiceShouldUsePrivateLinkMonitoringEffect` | `String` | Azure SignalR Service should use private link. Allowed Values: Audit; Disabled. |
| `azureMachineLearningWorkspacesShouldBeEncryptedWithACustomerManagedKeyMonitoringEffect` | `String` | Azure Machine Learning workspaces should be encrypted with a customer-managed key. Allowed Values: Audit; Deny; Disabled. |
| `azureMachineLearningWorkspacesShouldUsePrivateLinkMonitoringEffect` | `String` | Azure Machine Learning workspaces should use private link. Allowed Values: Audit; Disabled. |
| `webApplicationFirewallShouldBeEnabledForAzureFrontDoorServiceServiceMonitoringEffect` | `String` | Azure Web Application Firewall should be enabled for Azure Front Door entry-points. Allowed Values: Audit; Deny; Disabled. |
| `webApplicationFirewallShouldBeEnabledForApplicationGatewayMonitoringEffect` | `String` | Web Application Firewall (WAF) should be enabled for Application Gateway. Allowed Values: Audit; Deny; Disabled. |
| `publicNetworkAccessShouldBeDisabledForMariaDbServersMonitoringEffect` | `String` | Public network access should be disabled for MariaDB servers. Allowed Values: Audit; Disabled. |
| `publicNetworkAccessShouldBeDisabledForMySqlServersMonitoringEffect` | `String` | Public network access should be disabled for MySQL servers. Allowed Values: Audit; Disabled. |
| `bringYourOwnKeyDataProtectionShouldBeEnabledForMySqlServersMonitoringEffect` | `String` | MySQL servers should use customer-managed keys to encrypt data at rest. Allowed Values: AuditIfNotExists; Disabled. |
| `publicNetworkAccessShouldBeDisabledForPostgreSqlServersMonitoringEffect` | `String` | Public network access should be disabled for PostgreSQL servers. Allowed Values: Audit; Disabled. |
| `bringYourOwnKeyDataProtectionShouldBeEnabledForPostgreSqlServersMonitoringEffect` | `String` | PostgreSQL servers should use customer-managed keys to encrypt data at rest. Allowed Values: AuditIfNotExists; Disabled. |
| `vmImageBuilderTemplatesShouldUsePrivateLinkMonitoringEffect` | `String` | VM Image Builder templates should use private link. Allowed Values: Audit; Disabled. |
| `firewallShouldBeEnabledOnKeyVaultMonitoringEffect` | `String` | Firewall should be enabled on Key Vault. Allowed Values: Audit; Disabled. |
| `privateEndpointShouldBeConfiguredForKeyVaultMonitoringEffect` | `String` | Private endpoint should be configured for Key Vault. Allowed Values: Audit; Disabled. |
| `azureSpringCloudShouldUseNetworkInjectionMonitoringEffect` | `String` | Azure Spring Cloud should use network injection. Allowed Values: Audit; Deny; Disabled. |
| `subscriptionsShouldHaveAContactEmailAddressForSecurityIssuesMonitoringEffect` | `String` | Subscriptions should have a contact email address for security issues. Allowed Values: AuditIfNotExists; Disabled. |
| `autoProvisioningOfTheLogAnalyticsAgentShouldBeEnabledOnYourSubscriptionMonitoringEffect` | `String` | Auto provisioning of the Log Analytics agent should be enabled on your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `emailNotificationForHighSeverityAlertsShouldBeEnabledMonitoringEffect` | `String` | Email notification for high severity alerts should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `emailNotificationToSubscriptionOwnerForHighSeverityAlertsShouldBeEnabledMonitoringEffect` | `String` | Email notification to subscription owner for high severity alerts should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `storageAccountShouldUseAPrivateLinkConnectionMonitoringEffect` | `String` | Storage account should use a private link connection. Allowed Values: AuditIfNotExists; Disabled. |
| `authenticationToLinuxMachinesShouldRequireSSHKeysMonitoringEffect` | `String` | Authentication to Linux machines should require SSH keys. Allowed Values: AuditIfNotExists; Disabled. |
| `privateEndpointConnectionsOnAzureSQLDatabaseShouldBeEnabledMonitoringEffect` | `String` | Private endpoint connections on Azure SQL Database should be enabled. Allowed Values: Audit; Disabled. |
| `publicNetworkAccessOnAzureSQLDatabaseShouldBeDisabledMonitoringEffect` | `String` | Public network access on Azure SQL Database should be Disabled. | Allowed Values: Audit; Deny; Disabled. |
| `kubernetesClustersShouldBeAccessibleOnlyOverHttpsMonitoringEffect` | `String` | Kubernetes clusters should be accessible only over HTTPS. Allowed Values: Audit; Deny; Disabled. |
| `kubernetesClustersShouldBeAccessibleOnlyOverHttpsExcludedNamespaces` | `Array` | Kubernetes namespaces to exclude from evaluation of HTTPS only access. |
| `windowsWebServersShouldBeConfiguredToUseSecureCommunicationProtocolsMonitoringEffect` | `String` | Windows web servers should be configured to use secure communication protocols. Allowed Values: AuditIfNotExists; Disabled. |
| `windowsWebServersShouldBeConfiguredToUseSecureCommunicationProtocolsIncludeArcMachines` | `String` | Include Arc connected servers. Allowed Values: true false. |
| `windowsWebServersShouldBeConfiguredToUseSecureCommunicationProtocolsMinimumTlsVersion` | `String` | Minimum TLS version. Allowed Values: 1.1 1.2. |
| `cognitiveServicesAccountsShouldRestrictNetworkAccessMonitoringEffect` | `String` | Cognitive Services accounts should restrict network access. Allowed Values: Audit; Deny; Disabled. |
| `publicNetworkAccessShouldBeDisabledForCognitiveServicesAccountsMonitoringEffect` | `String` | Public network access should be disabled for Cognitive Services accounts. Allowed Values: Audit; Deny; Disabled. |
| `apiManagementServicesShouldUseAVirtualNetworkMonitoringEffect` | `String` | API Management services should use a virtual network. Allowed Values: Audit; Disabled. |
| `apiManagementServicesShouldUseAVirtualNetworkEvaluatedSkuNames` | `Array` | API Management SKU Names. Allowed Values: Developer Basic Standard Premium Consumption.
| `azureCosmosDbAccountsShouldHaveFirewallRulesMonitoringEffect` | `String` | Azure Cosmos DB accounts should have firewall rules. Allowed Values: Audit; Deny; Disabled. |
| `networkWatcherShouldBeEnabledMonitoringEffect` | `String` | Network Watcher should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `networkWatcherShouldBeEnabledResourceGroupName` | `String` | Name of the resource group for Network Watcher. |
| `azureDefenderForResourceManagerShouldBeEnabledMonitoringEffect` | `String` | Azure Defender for Resource Manager should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `azureDefenderForDnsShouldBeEnabledMonitoringEffect` | `String` | Azure Defender for DNS should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `azureDefenderForOpenSourceRelationalDatabasesShouldBeEnabledMonitoringEffect` | `String` | Azure Defender for open-source relational databases should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `microsoftDefenderCspmShouldBeEnabledMonitoringEffect` | `String` | Microsoft Defender CSPM should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `kubernetesClustersShouldNotUseTheDefaultNamespaceMonitoringEffect` | `String` | Kubernetes clusters should not use the default namespace. Allowed Values: Audit; Deny; Disabled. |
| `kubernetesClustersShouldDisableAutomountingAPICredentialsMonitoringEffect` | `String` | Kubernetes clusters should disable automounting API credentials. Allowed Values: Audit; Deny; Disabled. |
| `kubernetesClustersShouldDisableAutomountingApiCredentialsMonitoringNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from restricting automounting API credentials.
| `kubernetesClustersShouldNotGrantCapsysadminSecurityCapabilitiesMonitoringEffect` | `String` | Kubernetes clusters should not grant CAPSYSADMIN security capabilities. Allowed Values: Audit; Deny; Disabled. |
| `kubernetesClustersShouldNotGrantCapsysadminSecurityCapabilitiesMonitoringNamespaceExclusion` | `Array` | Kubernetes namespaces to exclude from restricting CAP_SYS_ADMIN Linux capabilities.
| `vtpmShouldBeEnabledOnSupportedVirtualMachinesMonitoringEffect` | `String` | vTPM should be enabled on supported virtual machines. Allowed Values: Audit; Disabled. |
| `secureBootShouldBeEnabledOnSupportedWindowsVirtualMachinesMonitoringEffect` | `String` | Secure Boot should be enabled on supported Windows virtual machines. Allowed Values: Audit; Disabled. |
| `guestAttestationExtensionShouldBeInstalledOnSupportedLinuxVirtualMachinesMonitoringEffect` | `String` | Guest Attestation extension should be installed on supported Linux virtual machines. Allowed Values: AuditIfNotExists; Disabled. |
| `guestAttestationExtensionShouldBeInstalledOnSupportedLinuxVirtualMachinesScaleSetsMonitoringEffect` | `String` | Guest Attestation extension should be installed on supported Linux virtual machines scale sets. Allowed Values: AuditIfNotExists; Disabled. |
| `guestAttestationExtensionShouldBeInstalledOnSupportedWindowsVirtualMachinesMonitoringEffect` | `String` | Guest Attestation extension should be installed on supported Windows virtual machines. Allowed Values: AuditIfNotExists; Disabled. |
|`guestAttestationExtensionShouldBeInstalledOnSupportedWindowsVirtualMachinesScaleSetsMonitoringEffect` | `String` | Guest Attestation extension should be installed on supported Windows virtual machines scale sets. Allowed Values: AuditIfNotExists; Disabled. |
| `installEndpointProtectionMonitoringEffect` | `String` | Endpoint protection should be installed on your machines. Allowed Values: AuditIfNotExists; Disabled. |
| `endpointProtectionHealthIssuesMonitoringEffect` | `String` | Endpoint protection health issues should be resolved on your machines. Allowed Values: AuditIfNotExists; Disabled. |
| `allowedContainerImagesLabelSelector` | `Object` | Label query to select Kubernetes resources for policy evaluation. An empty label selector matches all Kubernetes resources. |
| `privilegedContainerLabelSelector` | `Object` | Label query to select Kubernetes resources for policy evaluation. An empty label selector matches all Kubernetes resources. |
| `allowedServicePortsInKubernetesClusterLabelSelector` | `Object` | Label query to select Kubernetes resources for policy evaluation. An empty label selector matches all Kubernetes resources |
| `noPrivilegeEscalationInKubernetesClusterLabelSelector` | `Object` | Label query to select Kubernetes resources for policy evaluation. An empty label selector matches all Kubernetes resources. |
| `NoSharingSensitiveHostNamespacesInKubernetesLabelSelector` | `Object` | Kubernetes label selector to select monitoring of sharing sensitive host namespaces in Kubernetes clusters. |
| `readOnlyRootFileSystemInKubernetesClusterLabelSelector` | `Object` | Kubernetes label selector to select monitoring of containers running with a read only root file system. |
| `allowedCapabilitiesInKubernetesClusterLabelSelector` | `Object` | Kubernetes label selector to select monitoring of containers use only allowed capabilities. |
| `allowedAppArmorProfilesInKubernetesClusterLabelSelector` | `Object` | Kubernetes label selector to select monitoring of containers modification of AppArmor profile. |
| `allowedHostNetworkingAndPortsInKubernetesClusterLabelSelector` | `Object` | Kubernetes label selector to select monitoring of containers host networking and ports. |
| `allowedHostPathVolumesInKubernetesClusterLabelSelector` | `Object` | Kubernetes label selector to select monitoring of pod HostPath volume mounts. |
| `memoryAndCpuLimitsInKubernetesClusterLabelSelector` | `Object` | Kubernetes label selector to select monitoring of memory and CPU limits. |
| `mustRunAsNonRootLabelSelector` | `Object` | Kubernetes label selector to select monitoring of containers running as root users. |
| `azureContainerRegistryVulnerabilityAssessmentEffect` | `String` | Vulnerabilities in Azure Container Registry images should be remediated. Allowed Values: AuditIfNotExist; Disabled. |
| `kubernetesRunningImagesVulnerabilityMdvmAssessmentEffect` | `String` | Vulnerabilities in running images should be remediated. Allowed Values: AuditIfNotExist; Disabled. |
| `kubernetesClustersShouldNotUseTheDefaultNamespaceMonitoringLabelSelector` | `Object` | Kubernetes label selector to select monitoring of block default namespace. |
| `KubernetesClustersShouldDisableAutomountingApiCredentialsMonitoringLabelSelector` | `Object` | Kubernetes label selector to select monitoring of automounting API credentials. |
| `KubernetesClustersShouldNotGrantCapSysadminSecurityCapabilitiesMonitoringLabelSelector` | `Object` | Kubernetes label selector to select monitoring of CAP_SYS_ADMIN Linux capabilities. |
| `linuxVirtualMachineShouldUseSignedAndTrustedBootComponentEffect` | `String` | Linux virtual machines should use only signed and trusted boot components.  Allowed Values: AuditIfNotExist; Disabled. |
| `readOnlyRootFileSystemInKubernetesClusterLabelSelector` | `Object` | Kubernetes label selector to select monitoring of containers running with a read only root file system. |

## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
            "mcsbAuditDenySettings": {
      "value": {
        "allowedContainerImagesLabelSelector":{},
        "privilegedContainerLabelSelector":{},
        "allowedServicePortsInKubernetesClusterLabelSelector":{},
        "kubernetesClustersShouldBeAccessibleOnlyOverHttpsLabelSelector":{},
        "noPrivilegeEscalationInKubernetesClusterLabelSelector":{},
        "noSharingSensitiveHostNamespacesInKubernetesLabelSelector":{},
        "readOnlyRootFileSystemInKubernetesClusterLabelSelector":{},
        "allowedCapabilitiesInKubernetesClusterLabelSelector":{},
        "allowedAppArmorProfilesInKubernetesClusterLabelSelector":{},
        "allowedHostNetworkingAndPortsInKubernetesClusterLabelSelector":{},
        "allowedHostPathVolumesInKubernetesClusterLabelSelector":{},
        "memoryAndCpuLimitsInKubernetesClusterLabelSelector":{},
        "mustRunAsNonRootLabelSelector":{},
        "azureContainerRegistryVulnerabilityAssessmentEffect": "AuditIfNotExists",
        "kubernetesRunningImagesVulnerabilityMdvmAssessmentEffect": "AuditIfNotExists",
        "KubernetesClustersShouldNotUseTheDefaultNamespaceMonitoringLabelSelector":{},
        "kubernetesClustersShouldDisableAutomountingApiCredentialsMonitoringLabelSelector":{},
        "kubernetesClustersShouldNotGrantCapSysadminSecurityCapabilitiesMonitoringLabelSelector":{},
        "LinuxVirtualMachineShouldUseSignedAndTrustedBootComponentEffect": "AuditIfNotExists",
        "installLogAnalyticsAgentOnVmMonitoringEffect": "AuditIfNotExists",
        "installLogAnalyticsAgentOnVmssMonitoringEffect": "AuditIfNotExists",
        "certificatesValidityPeriodMonitoringEffect": "disabled",
        "certificatesValidityPeriodInMonths": 12,
        "secretsExpirationSetEffect": "Disabled",
        "keysExpirationSetEffect": "Disabled",
        "azurePolicyforWindowsMonitoringEffect": "AuditIfNotExists",
        "gcExtOnVmWithNoSamiMonitoringEffect": "AuditIfNotExists",
        "windowsDefenderExploitGuardMonitoringEffect": "AuditIfNotExists",
        "windowsGuestConfigBaselinesMonitoringEffect": "AuditIfNotExists",
        "linuxGuestConfigBaselinesMonitoringEffect": "AuditIfNotExists",
        "vmssSystemUpdatesMonitoringEffect": "AuditIfNotExists",
        "vmssEndpointProtectionMonitoringEffect": "AuditIfNotExists",
        "vmssOsVulnerabilitiesMonitoringEffect": "AuditIfNotExists",
        "systemUpdatesMonitoringEffect": "AuditIfNotExists",
        "systemUpdatesV2MonitoringEffect": "AuditIfNotExists",
        "systemUpdatesAutoAssessmentModeEffect": "Audit",
        "systemConfigurationsMonitoringEffect": "AuditIfNotExists",
        "endpointProtectionMonitoringEffect": "AuditIfNotExists",
        "diskEncryptionMonitoringEffect": "AuditIfNotExists",
        "gcLinuxDiskEncryptionMonitoringEffect": "AuditIfNotExists",
        "gcWindowsDiskEncryptionMonitoringEffect": "AuditIfNotExists",
        "networkSecurityGroupsOnSubnetsMonitoringEffect": "Disabled",
        "networkSecurityGroupsOnVirtualMachinesMonitoringEffect": "AuditIfNotExists",
        "networkSecurityGroupsOnInternalVirtualMachinesMonitoringEffect": "AuditIfNotExists",
        "nextGenerationFirewallMonitoringEffect": "AuditIfNotExists",
        "serverVulnerabilityAssessmentEffect": "AuditIfNotExists",
        "jitNetworkAccessMonitoringEffect": "AuditIfNotExists",
        "adaptiveApplicationControlsMonitoringEffect": "AuditIfNotExists",
        "adaptiveApplicationControlsUpdateMonitoringEffect": "AuditIfNotExists",
        "sqlDbEncryptionMonitoringEffect": "AuditIfNotExists",
        "sqlServerAuditingMonitoringEffect": "AuditIfNotExists",
        "encryptionOfAutomationAccountMonitoringEffect": "Audit",
        "diagnosticsLogsInBatchAccountMonitoringEffect": "AuditIfNotExists",
        "diagnosticsLogsInBatchAccountRetentionDays": "1",
        "classicComputeVmsMonitoringEffect": "Audit",
        "classicStorageAccountsMonitoringEffect": "Audit",
        "diagnosticsLogsInDataLakeAnalyticsMonitoringEffect": "AuditIfNotExists",
        "diagnosticsLogsInDataLakeAnalyticsRetentionDays": "1",
        "diagnosticsLogsInDataLakeStoreMonitoringEffect": "AuditIfNotExists",
        "diagnosticsLogsInDataLakeStoreRetentionDays": "1",
        "diagnosticsLogsInEventHubMonitoringEffect": "AuditIfNotExists",
        "diagnosticsLogsInEventHubRetentionDays": "1",
        "diagnosticsLogsInKeyVaultMonitoringEffect": "AuditIfNotExists",
        "diagnosticsLogsInKeyVaultRetentionDays": "1",
        "diagnosticsLogsInKubernetesMonitoringEffect": "AuditIfNotExists",
        "diagnosticsLogsInKubernetesRetentionDays": "1",
        "diagnosticsLogsInLogicAppsMonitoringEffect": "AuditIfNotExists",
        "diagnosticsLogsInLogicAppsRetentionDays": "1",
        "diagnosticsLogsInRedisCacheMonitoringEffect": "Audit",
        "diagnosticsLogsInSearchServiceMonitoringEffect": "AuditIfNotExists",
        "diagnosticsLogsInSearchServiceRetentionDays": "1",
        "aadAuthenticationInServiceFabricMonitoringEffect": "Audit",
        "clusterProtectionLevelInServiceFabricMonitoringEffect": "Audit",
        "diagnosticsLogsInServiceBusMonitoringEffect": "AuditIfNotExists",
        "diagnosticsLogsInServiceBusRetentionDays": "1",
        "aadAuthenticationInSqlServerMonitoringEffect": "AuditIfNotExists",
        "secureTransferToStorageAccountMonitoringEffect": "Audit",
        "diagnosticsLogsInStreamAnalyticsMonitoringEffect": "AuditIfNotExists",
        "diagnosticsLogsInStreamAnalyticsRetentionDays": "1",
        "useRbacRulesMonitoringEffect": "Audit",
        "disableUnrestrictedNetworkToStorageAccountMonitoringEffect": "Disabled",
        "sqlDbVulnerabilityAssesmentMonitoringEffect": "AuditIfNotExists",
        "serverSqlDbVulnerabilityAssesmentMonitoringEffect": "AuditIfNotExists",
        "identityDesignateLessThanOwnersMonitoringEffect": "AuditIfNotExists",
        "identityDesignateMoreThanOneOwnerMonitoringEffect": "AuditIfNotExists",
        "identityEnableMfaForOwnerPermissionsMonitoringEffect": "AuditIfNotExists",
        "identityEnableMfaForWritePermissionsMonitoringEffect": "AuditIfNotExists",
        "identityEnableMfaForReadPermissionsMonitoringEffect": "AuditIfNotExists",
        "identityRemoveExternalAccountWithOwnerPermissionsMonitoringEffect": "AuditIfNotExists",
        "identityRemoveExternalAccountWithWritePermissionsMonitoringEffect": "AuditIfNotExists",
        "identityRemoveExternalAccountWithReadPermissionsMonitoringEffect": "AuditIfNotExists",
        "functionAppDisableRemoteDebuggingMonitoringEffect": "AuditIfNotExists",
        "webAppDisableRemoteDebuggingMonitoringEffect": "AuditIfNotExists",
        "functionAppEnforceHttpsMonitoringEffectV2": "Audit",
        "webAppEnforceHttpsMonitoringEffectV2": "Audit",
        "functionAppRestrictCorsAccessMonitoringEffect": "AuditIfNotExists",
        "webAppRestrictCorsAccessMonitoringEffect": "AuditIfNotExists",
        "vnetEnableDdoSProtectionMonitoringEffect": "AuditIfNotExists",
        "diagnosticsLogsInIotHubMonitoringEffect": "AuditIfNotExists",
        "diagnosticsLogsInIotHubRetentionDays": "1",
        "sqlServerAdvancedDataSecurityMonitoringEffect": "AuditIfNotExists",
        "arcEnabledSqlServerDefenderStatusEffect": "Audit",
        "sqlManagedInstanceAdvancedDataSecurityMonitoringEffect": "AuditIfNotExists",
        "kubernetesServiceRbacEnabledMonitoringEffect": "Audit",
        "kubernetesServiceAuthorizedIpRangesEnabledMonitoringEffect": "Audit",
        "vulnerabilityAssessmentOnManagedInstanceMonitoringEffect": "AuditIfNotExists",
        "vulnerabilityAssessmentOnServerMonitoringEffect": "AuditIfNotExists",
        "adaptiveNetworkHardeningsMonitoringEffect": "AuditIfNotExists",
        "restrictAccessToManagementPortsMonitoringEffect": "AuditIfNotExists",
        "disableIpForwardingMonitoringEffect": "AuditIfNotExists",
        "ensureServerTdeIsEncryptedWithYourOwnKeyWithDenyMonitoringEffect": "Disabled",
        "ensureManagedInstanceTdeIsEncryptedWithYourOwnKeyWithDenyMonitoringEffect": "Disabled",
        "containerBenchmarkMonitoringEffect": "AuditIfNotExists",
        "ascDependencyAgentAuditWindowsEffect": "AuditIfNotExists",
        "ascDependencyAgentAuditLinuxEffect": "AuditIfNotExists",
        "azureFirewallEffect": "AuditIfNotExists",
        "arcWindowsMonitoringEffect": "AuditIfNotExists",
        "arcLinuxMonitoringEffect": "AuditIfNotExists",
        "keyVaultsAdvancedDataSecurityMonitoringEffect": "AuditIfNotExists",
        "sqlServersAdvancedDataSecurityMonitoringEffect": "AuditIfNotExists",
        "sqlServersVirtualMachinesAdvancedDataSecurityMonitoringEffect": "AuditIfNotExists",
        "appServicesAdvancedThreatProtectionMonitoringEffect": "AuditIfNotExists",
        "containersAdvancedThreatProtectionMonitoringEffect": "AuditIfNotExists",
        "virtualMachinesAdvancedThreatProtectionMonitoringEffect": "AuditIfNotExists",
        "azurePolicyAddonStatusEffect": "Audit",
        "arcEnabledKubernetesClustersShouldHaveAzurePolicyExtensionInstalledEffect": "AuditIfNotExists",
        "excludedImagesInKubernetesCluster": [],
        "allowedContainerImagesInKubernetesClusterEffect": "Audit",
        "allowedContainerImagesInKubernetesClusterRegex": "^(.+){0}$",
        "allowedContainerImagesNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc",
          "azuredefender",
          "mdc"
        ],
        "privilegedContainersShouldBeAvoidedEffect": "Audit",
        "privilegedContainerNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc",
          "azuredefender",
          "mdc"
        ],
        "allowedServicePortsInKubernetesClusterEffect": "Audit",
        "allowedservicePortsInKubernetesClusterPorts": [],
        "allowedServicePortsInKubernetesClusterNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc"
        ],
        "noPrivilegeEscalationInKubernetesClusterEffect": "Audit",
        "noPrivilegeEscalationInKubernetesClusterNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc"
        ],
        "noSharingSensitiveHostNamespacesInKubernetesEffect": "Audit",
        "noSharingSensitiveHostNamespacesInKubernetesNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc"
        ],
        "readOnlyRootFileSystemInKubernetesClusterEffect": "Audit",
        "readOnlyRootFileSystemInKubernetesClusterNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc",
          "azuredefender",
          "mdc"
        ],
        "allowedCapabilitiesInKubernetesClusterEffect": "Audit",
        "allowedCapabilitiesInKubernetesClusterNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc",
          "azuredefender",
          "mdc"
        ],
        "allowedCapabilitiesInKubernetesClusterList": [],
        "dropCapabilitiesInKubernetesClusterList": [],
        "allowedAppArmorProfilesInKubernetesClusterEffect": "Audit",
        "allowedAppArmorProfilesInKubernetesClusterNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc",
          "azuredefender",
          "mdc"
        ],
        "allowedAppArmorProfilesInKubernetesClusterList": [
          "runtime/default"
        ],
        "allowedHostNetworkingAndPortsInKubernetesClusterEffect": "Audit",
        "allowedHostNetworkingAndPortsInKubernetesClusterNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc"
        ],
        "allowHostNetworkingInKubernetesCluster": false,
        "allowedHostMinPortInKubernetesCluster": 0,
        "allowedHostMaxPortInKubernetesCluster": 0,
        "allowedHostPathVolumesInKubernetesClusterEffect": "Audit",
        "allowedHostPathVolumesInKubernetesClusterNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc",
          "azuredefender",
          "mdc"
        ],
        "allowedHostPathVolumesInKubernetesClusterList": {
          "paths": []
        },
        "memoryAndCpuLimitsInKubernetesClusterEffect": "Audit",
        "memoryInKubernetesClusterLimit": "64Gi",
        "cpuInKubernetesClusterLimit": "32",
        "memoryAndCpuLimitsInKubernetesClusterNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc",
          "azuredefender",
          "mdc"
        ],
        "blockVulnerableImagesInKubernetesClusterEffect": "Disabled",
        "blockVulnerableImagesInKubernetesClusterNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc"
        ],
        "blockVulnerableImagesExcludedImages": [],
        "blockVulnerableImagesSeverityThresholdForExcludingNotPatchableFindings": "None",
        "blockVulnerableImagesExcludeFindingIDs": [],
        "severity": {
          "High": 0,
          "Medium": 0,
          "Low": 0
        },
        "mustRunAsNonRootNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc",
          "azuredefender",
          "mdc"
        ],
        "mustRunAsNonRootNamespaceEffect": "Audit",
        "arcEnabledKubernetesClustersShouldHaveAzureDefendersExtensionInstalled": "AuditIfNotExists",
        "azureKubernetesServiceClustersShouldHaveSecurityProfileEnabled": "Audit",
        "containerRegistryVulnerabilityAssessmentEffect": "AuditIfNotExists",
        "kubernetesRunningImagesVulnerabilityAssessmentEffect": "AuditIfNotExists",
        "disallowPublicBlobAccessEffect": "audit",
        "azureBackupShouldBeEnabledForVirtualMachinesMonitoringEffect": "AuditIfNotExists",
        "managedIdentityShouldBeUsedInYourFunctionAppMonitoringEffect": "AuditIfNotExists",
        "georedundantBackupShouldBeEnabledForAzureDatabaseForMariadbMonitoringEffect": "Audit",
        "managedIdentityShouldBeUsedInYourWebAppMonitoringEffect": "AuditIfNotExists",
        "geoRedundantBackupShouldBeEnabledForAzureDatabaseForPostgresqlMonitoringEffect": "Audit",
        "ensureWebAppHasClientCertificatesIncomingClientCertificatesSetToOnMonitoringEffect": "Audit",
        "geoRedundantBackupShouldBeEnabledForAzureDatabaseForMysqlMonitoringEffect": "Audit",
        "diagnosticLogsInAppServicesShouldBeEnabledMonitoringEffect": "AuditIfNotExists",
        "enforceSslConnectionShouldBeEnabledForPostgresqlDatabaseServersMonitoringEffect": "Audit",
        "enforceSslConnectionShouldBeEnabledForMysqlDatabaseServersMonitoringEffect": "Audit",
        "latestTlsVersionShouldBeUsedInYourWebAppMonitoringEffect": "AuditIfNotExists",
        "latestTlsVersionShouldBeUsedInYourFunctionAppMonitoringEffect": "AuditIfNotExists",
        "privateEndpointShouldBeEnabledForPostgresqlServersMonitoringEffect": "AuditIfNotExists",
        "privateEndpointShouldBeEnabledForMariadbServersMonitoringEffect": "AuditIfNotExists",
        "privateEndpointShouldBeEnabledForMysqlServersMonitoringEffect": "AuditIfNotExists",
        "sqlServersShouldBeConfiguredWithAuditingRetentionDaysGreaterThan90DaysMonitoringEffect": "AuditIfNotExists",
        "ftpsOnlyShouldBeRequiredInYourFunctionAppMonitoringEffect": "AuditIfNotExists",
        "ftpsShouldBeRequiredInYourWebAppMonitoringEffect": "AuditIfNotExists",
        "functionAppsShouldHaveClientCertificatesEnabledMonitoringEffect": "Audit",
        "cognitiveServicesAccountsShouldEnableDataEncryptionWithACustomerManagedKeyMonitoringEffect": "Disabled",
        "azureCosmosDbAccountsShouldUseCustomerManagedKeysToEncryptDataAtRestMonitoringEffect": "disabled",
        "azureCosmosDbAccountsShouldHaveLocalAuthenticationMethodsDisabledMonitoringEffect": "Audit",
        "keyVaultsShouldHavePurgeProtectionEnabledMonitoringEffect": "Audit",
        "keyVaultsShouldHaveSoftDeleteEnabledMonitoringEffect": "Audit",
        "azureCacheForRedisShouldUsePrivateEndpointMonitoringEffect": "AuditIfNotExists",
        "storageAccountsShouldUseCustomerManagedKeyForEncryptionMonitoringEffect": "Disabled",
        "storageAccountsShouldRestrictNetworkAccessUsingVirtualNetworkRulesMonitoringEffect": "Audit",
        "containerRegistriesShouldBeEncryptedWithACustomerManagedKeyMonitoringEffect": "Disabled",
        "containerRegistriesShouldNotAllowUnrestrictedNetworkAccessMonitoringEffect": "Audit",
        "containerRegistriesShouldUsePrivateLinkMonitoringEffect": "Audit",
        "appConfigurationShouldUsePrivateLinkMonitoringEffect": "AuditIfNotExists",
        "azureEventGridDomainsShouldUsePrivateLinkMonitoringEffect": "Audit",
        "azureEventGridTopicsShouldUsePrivateLinkMonitoringEffect": "Audit",
        "azureSignalRServiceShouldUsePrivateLinkMonitoringEffect": "Audit",
        "azureMachineLearningWorkspacesShouldBeEncryptedWithACustomerManagedKeyMonitoringEffect": "Disabled",
        "azureMachineLearningWorkspacesShouldUsePrivateLinkMonitoringEffect": "Audit",
        "webApplicationFirewallShouldBeEnabledForAzureFrontDoorServiceServiceMonitoringEffect": "Audit",
        "webApplicationFirewallShouldBeEnabledForApplicationGatewayMonitoringEffect": "Audit",
        "publicNetworkAccessShouldBeDisabledForMariaDbServersMonitoringEffect": "Audit",
        "publicNetworkAccessShouldBeDisabledForMySqlServersMonitoringEffect": "Audit",
        "bringYourOwnKeyDataProtectionShouldBeEnabledForMySqlServersMonitoringEffect": "Disabled",
        "publicNetworkAccessShouldBeDisabledForPostgreSqlServersMonitoringEffect": "Audit",
        "bringYourOwnKeyDataProtectionShouldBeEnabledForPostgreSqlServersMonitoringEffect": "Disabled",
        "vmImageBuilderTemplatesShouldUsePrivateLinkMonitoringEffect": "Audit",
        "firewallShouldBeEnabledOnKeyVaultMonitoringEffect": "Audit",
        "privateEndpointShouldBeConfiguredForKeyVaultMonitoringEffect": "Audit",
        "azureSpringCloudShouldUseNetworkInjectionMonitoringEffect": "Audit",
        "subscriptionsShouldHaveAContactEmailAddressForSecurityIssuesMonitoringEffect": "AuditIfNotExists",
        "autoProvisioningOfTheLogAnalyticsAgentShouldBeEnabledOnYourSubscriptionMonitoringEffect": "AuditIfNotExists",
        "emailNotificationForHighSeverityAlertsShouldBeEnabledMonitoringEffect": "AuditIfNotExists",
        "emailNotificationToSubscriptionOwnerForHighSeverityAlertsShouldBeEnabledMonitoringEffect": "AuditIfNotExists",
        "storageAccountShouldUseAPrivateLinkConnectionMonitoringEffect": "AuditIfNotExists",
        "authenticationToLinuxMachinesShouldRequireSshKeysMonitoringEffect": "AuditIfNotExists",
        "privateEndpointConnectionsOnAzureSqlDatabaseShouldBeEnabledMonitoringEffect": "Audit",
        "publicNetworkAccessOnAzureSqlDatabaseShouldBeDisabledMonitoringEffect": "Audit",
        "kubernetesClustersShouldBeAccessibleOnlyOverHttpsMonitoringEffect": "Audit",
        "kubernetesClustersShouldBeAccessibleOnlyOverHttpsExcludedNamespaces": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc"
        ],
        "kubernetesClustersShouldBeAccessibleOnlyOverHttpsNamespaces": [],
        "windowsWebServersShouldBeConfiguredToUseSecureCommunicationProtocolsMonitoringEffect": "AuditIfNotExists",
        "windowsWebServersShouldBeConfiguredToUseSecureCommunicationProtocolsIncludeArcMachines": "true",
        "windowsWebServersShouldBeConfiguredToUseSecureCommunicationProtocolsMinimumTLSVersion": "1.2",
        "cognitiveServicesAccountsShouldRestrictNetworkAccessMonitoringEffect": "Audit",
        "publicNetworkAccessShouldBeDisabledForCognitiveServicesAccountsMonitoringEffect": "Audit",
        "apiManagementServicesShouldUseAVirtualNetworkMonitoringEffect": "Audit",
        "apiManagementServicesShouldUseAVirtualNetworkEvaluatedSkuNames": [
          "Developer",
          "Premium"
        ],
        "azureCosmosDbaccountsShouldHaveFirewallRulesMonitoringEffect": "Audit",
        "networkWatcherShouldBeEnabledMonitoringEffect": "AuditIfNotExists",
        "networkWatcherShouldBeEnabledResourceGroupName": "NetworkWatcherRG",
        "azureDefenderForResourceManagerShouldBeEnabledMonitoringEffect": "AuditIfNotExists",
        "azureDefenderForDnsShouldBeEnabledMonitoringEffect": "AuditIfNotExists",
        "azureDefenderForOpenSourceRelationalDatabasesShouldBeEnabledMonitoringEffect": "AuditIfNotExists",
        "microsoftDefenderCspmShouldBeEnabledMonitoringEffect": "Disabled",
        "KubernetesClustersShouldNotUseTheDefaultNamespaceMonitoringEffect": "Audit",
        "KubernetesClustersShouldDisableAutomountingApiCredentialsMonitoringEffect": "Audit",
        "KubernetesClustersShouldDisableAutomountingApiCredentialsMonitoringNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc",
          "azuredefender",
          "mdc"
        ],
        "KubernetesClustersShouldNotGrantCapsysadminSecurityCapabilitiesMonitoringEffect": "Audit",
        "KubernetesClustersShouldNotGrantCapsysadminSecurityCapabilitiesMonitoringNamespaceExclusion": [
          "kube-system",
          "gatekeeper-system",
          "azure-arc",
          "azuredefender",
          "mdc"
        ],
        "vtpmShouldBeEnabledOnSupportedVirtualMachinesMonitoringEffect": "Audit",
        "secureBootShouldBeEnabledOnSupportedWindowsVirtualMachinesMonitoringEffect": "Audit",
        "guestAttestationExtensionShouldBeInstalledOnSupportedLinuxVirtualMachinesMonitoringEffect": "AuditIfNotExists",
        "guestAttestationExtensionShouldBeInstalledOnSupportedLinuxVirtualMachinesScaleSetsMonitoringEffect": "AuditIfNotExists",
        "guestAttestationExtensionShouldBeInstalledOnSupportedWindowsVirtualMachinesMonitoringEffect": "AuditIfNotExists",
        "guestAttestationExtensionShouldBeInstalledOnSupportedWindowsVirtualMachinesScaleSetsMonitoringEffect": "AuditIfNotExists",
        "installEndpointProtectionMonitoringEffect": "AuditIfNotExists",
        "endpointProtectionHealthIssuesMonitoringEffect": "AuditIfNotExists"
      }
    }
```