# policy/nistR2/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy assignment.

It deploys the NIST R2 policy definition set.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyAssignments@2021-06-01` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/nistR2AuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
        nistR2AuditDenySetAssignmentName: 'nistr2.auditdeny.policy.set'
        nistR2AuditDenySetAssignmentDisplayName: 'Nist 800-171 r2 auditdeny policy set'
        nistPolicyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/03055927-78bd-4236-86c0-f36125a10dc9'
        nistSettings: nistAuditDenySettings
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `nistR2AuditDenySetAssignmentName` | `string` | true | set assignment name for the Nist R2 audit/deny initiative. |
| `nistR2AuditDenySetAssignmentDisplayName` | `string` | true | set assignment displayname for the Nist R2 audit/deny initiative. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |
| `nistPolicyDefinitionId` | `string` | true | Specify the policy definition id of the built-in NIST Initiative. |

### Object - nistSettings
| Name | Type | Description |
| --- | --- | --- |
`includeArcMachines` | `String` | Include Arc-connected servers when evaluating guest configuration policies. Allowed Values: true; false. |
`membersToExcludeInLocalAdministratorsGroup` | `String` | List of users that should be excluded from Windows virtual machines' Administrators group.  |
`membersToIncludeInLocalAdministratorsGroup` | `String` | List of users that should be included in Windows virtual machines' Administrators group. |
`networkWatcherResourceGroupName` | `String` | Name of the resource group for Network Watcher.
`logAnalyticsWorkspaceIdForVmAgents` | `String` | Log Analytics workspace ID for virtual machine agent reporting. |
`javaLatestVersionForAppServices` | `String` | Latest Java version for App Services. |
`minimumTlsVersionForWindowsServers` | `String` | Minimum TLS version for Windows web servers. Allowed Values: 1.1 1.2. |
`storageAccountRestrictNetworkAccess` | `String` | Storage accounts should restrict network access. Allowed Values: Audit; Deny; Disabled. |
`machineLearningWorkspacesPrivateLink` | `String` | Azure Machine Learning workspaces should use private link. Allowed Values: Audit; Deny; Disabled. |
`vmImageBuilderPrivateLink` | `String` | VM Image Builder templates should use private link. Allowed Values: Audit; Disabled; Deny. |
`keyVaultPrivateLink` | `String` | Azure Key Vaults should use private link. Allowed Values: Audit Disabled. |
`springCloudNetworkInjection` | `String` | Azure Spring Cloud should use network injection. Allowed Values: Audit; Disabled; Deny. |
`evaluatedSkuNamesSpringCloud` | `Array` | Azure Spring Cloud SKUs that should use network injection. Allowed Values: Standard. |
`cognitiveSearchPrivateLink` | `String` | Azure Cognitive Search service should use a SKU that supports private link. Allowed Values: Audit; Deny; Disabled. |
`serviceFabricShouldUseAzureAd` | `String` | Service Fabric clusters should only use Azure Active Directory for client authentication. Allowed Values: Audit; Deny; Disabled. |
`cognitiveSearchLocalAuthenticationDisabled` | `String` | Cognitive Services accounts should have local authentication methods Disabled. | Allowed Values: Audit; Deny; Disabled. |
`vmMigratedToNewArm` | `String` | Virtual machines should be migrated to new Azure Resource Manager resources. Allowed Values: Audit; Deny; Disabled. |
`storaceAccountMigratedToNewArm` | `String` | Storage accounts should be migrated to new Azure Resource Manager resources. Allowed Values: Audit; Deny; Disabled. |
`evaluatedSkuNamesApiMgmt` | `Array` | API Management SKUs that should use a virtual network. Allowed Values: Developer Basic Standard Premium Consumption. |
`cosmosDbFirewallRules` | `String` | Azure Cosmos DB accounts should have firewall rules. Allowed Values: Audit; Deny; Disabled. |
`acrUnrestrictedNetworkAccess` | `String` | Container registries should not allow unrestricted network access. Allowed Values: Audit; Deny; Disabled. |
`storageAccountShouldRestrictNetworkAccessVirtualRules` | `String` | Storage accounts should restrict network access using virtual network rules. Allowed Values: Audit; Deny; Disabled. |
`keyvaultsDisablePublicNetworkAccess` | `String` | [Preview]: Azure Key Vault should disable public network access. Allowed Values: Audit; Deny; Disabled. |
`sqlDbShouldDisablePublicNetworkAccess` | `String` | Public network access on Azure SQL Database should be Disabled. | Allowed Values: Audit; Deny; Disabled. |
`cognitiveSearchAccountsRestrictNetworkAccess` | `String` | Cognitive Services accounts should restrict network access. Allowed Values: Audit; Deny; Disabled. |
`cognitiveServiceAccountsDisablePublicNetworkAccess` | `String` | Cognitive Services accounts should disable public network access. Allowed Values: Audit; Deny; Disabled. |
`storageAccountPublicAccessDisallowed` | `String` | [Preview]: Storage account public access should be disallowed. Allowed Values: Audit; Deny; Disabled. |
`cognitiveSearchDisablePublicNetworkAccess` | `String` | Azure Cognitive Search services should disable public network access. Allowed Values: Audit; Deny; Disabled. |
`requiredRetentionDays` | `String` | Required retention period (days) for resource logs. |
`requiredAuditSettingForSqlServer` | `String` | Required auditing setting for SQL servers. Allowed Values: enabled Disabled. |
`kubernetesOnlyAllowedImages` | `String` | Kubernetes cluster containers should only use allowed images. Allowed Values: Audit; Deny; Disabled. |
`kubernetesExcludedNamespaces` | `Array` | Kubernetes namespaces excluded from evaluation of Kubernetes cluster policies in this initiative. |
`kubernetesNamespaces` | `Array` | Kubernetes namespaces included for evaluation of Kubernetes cluster policies in this initiative. |
`kubernetesLabelSelector` | `Object` | Kubernetes label selector for resources included for evaluation of Kubernetes cluster policies in this initiative. |
`allowedContainerImagesRegex` | `String` | Allowed container images for Kubernetes clusters. |
`kubernetesExcludedContainers` | `Array` | Kubernetes containers excluded from evaluation of Kubernetes cluster policies in this initiative. |
`kubernetesDisallowPrivilegedContainers` | `String` | Kubernetes cluster should not allow privileged containers. Allowed Values: Audit; Deny; Disabled. |
`kubernetesAllowedPorts` | `String` | Kubernetes cluster services should listen only on allowed ports. Allowed Values: Audit; Deny; Disabled. |
`kubernetesAllowedServicePortsList` | `Array` | Allowed listener ports for Kubernetes cluster services.
`kubernetesResourceLimitsExceeded` | `String` | Kubernetes cluster containers CPU and memory resource limits should not exceed the specified limits. Allowed Values: Audit; Deny; Disabled. |
`kubernetesCpuLimit` | `String` | Maximum allowed CPU units for containers in Kubernetes clusters. |
`kubernetesMemoryLimit` | `String` | Maximum allowed memory (bytes) for a container in Kubernetes clusters. |
`kubernetesApprovedUserAndGroupsId` | `String` | Kubernetes cluster pods and containers should only run with approved user and group IDs. Allowed Values: Audit; Deny; Disabled. |
`kubernetesRunAsUserRule` | `String` | Run as user rule for Kubernetes containers. Allowed Values: MustRunAs MustRunAsNonRoot RunAsAny. |
`kubernetesRunAsUserRanges` | `Object` | Allowed user ID ranges for Kubernetes containers. |
`kubernetesRunAsGroupRule` | `String` | Run as group rule for Kubernetes containers. Allowed Values: MustRunAs MayRunAs RunAsAny. |
`kubernetesRunAsGroupRanges` | `Object` | Allowed group ID ranges for Kubernetes containers. |
`kubernetesSupplementalGroupsRule` | `String` | Supplemental group rule for Kubernetes containers. Allowed Values: MustRunAs MayRunAs RunAsAny. |
`kubernetesSupplementalGroupsRanges` | `Object` | Allowed supplemental group ID ranges for Kubernetes containers. |
`kubernetesFsGroupRule` | `String` | File system group rule for Kubernetes containers. Allowed Values: MustRunAs MayRunAs RunAsAny. |
`kubernetesFsGroupRanges` | `Object` | Allowed file system group ID ranges for Kubernetes cluster pods.
`kubernetesContainerNotAllowPrivilegeEscalation` | `String` | Kubernetes clusters should not allow container privilege escalation. Allowed Values: Audit; Deny; Disabled. |
`kubernetesNotShareHostProcesOrIpc` | `String` | Kubernetes cluster containers should not share host process ID or host IPC namespace. Allowed Values: Audit; Deny; Disabled. |
`kubernetesRunWithReadOnlyFs` | `String` | Kubernetes cluster containers should run with a read only root file system. Allowed Values: Audit; Deny; Disabled. |
`kubernetesOnlyAllowedCapabilities` | `String` | Kubernetes cluster containers should only use allowed capabilities. Allowed Values: Audit; Deny; Disabled. |
`kubernetesAllowedCapabilities` | `Array` | List of capabilities that are allowed to be added to a Kubernetes cluster container. |
`kubernetesRequiredDropCapabilities` | `Array` | The list of capabilities that must be dropped by a Kubernetes cluster container. |
`kubernetesOnlyAppArmorProfiles` | `String` | Kubernetes cluster containers should only use allowed AppArmor profiles. Allowed Values: Audit; Deny; Disabled. |
`kubernetesAllowedAppArmorProfiles` | `Array` | The list of AppArmor profiles that containers are allowed to use. |
`kubernetesClusterPodsApprovedHostNetworkAndPortRanges` | `String` | Kubernetes cluster pods should only use approved host network and port range. Allowed Values: Audit; Deny; Disabled. |
`kubernetesAllowHostNetwork` | `Boolean` | Allow host network usage for Kubernetes cluster pods.
`kubernetesMinPortRange` | `Integer` | Minimum value in the allowable host port range that Kubernetes cluster pods can use in the host network namespace. |
`kubernetesMaxPortRange` | `Integer` | Maximum value in the allowable host port range that Kubernetes cluster pods can use in the host network namespace. |
`kubernetesHostPadVolumes` | `String` | Kubernetes cluster pod hostPath volumes should only use allowed host paths. Allowed Values: Audit; Deny; Disabled. |
`kubernetesAllowedHostPaths` | `Object` | Allowed host paths for pod hostPath volumes to use. |
`keyVaultMaximumValidityInMonths` | `Integer` | Maximum validity (months) for Key Vault certificates. |
`maximumCertificateValidity` | `String` | [Preview]: Certificates should have the specified maximum validity period. Allowed Values: Audit; Deny; Disabled. |
`keyvaultSecretExpirationDate` | `String` | Key Vault secrets should have an expiration date. Allowed Values: Audit; Deny; Disabled. |
`keyvaultKeysExpirationDate` | `String` | Key Vault keys should have an expiration date. Allowed Values: Audit; Deny; Disabled. |
`keyvaultPurgeProtectionEnabled` | `String` | Key vaults should have purge protection enabled. Allowed Values: Audit; Deny; Disabled. |
`keyvaultSoftDeleteEnabled` | `String` | Key vaults should have soft delete enabled. Allowed Values: Audit; Deny; Disabled. |
`wafEnabledAzureFrontDoor` | `String` | Web Application Firewall (WAF) should be enabled for Azure Front Door Service service. Allowed Values: Audit; Deny; Disabled. |
`wafEnabledAppGateway` | `String` | Web Application Firewall (WAF) should be enabled for Application Gateway. Allowed Values: Audit; Deny; Disabled. |
`kubernetesAccessibleOverHttps` | `String` | Kubernetes clusters should be accessible only over HTTPS. Allowed Values: Audit; Deny; Disabled. |
`hdinsightUseEncryptionInTransit` | `String` | Azure HDInsight clusters should use encryption in transit to encrypt communication between Azure HDInsight cluster nodes. Allowed Values: Audit; Deny; Disabled. |
`azureCacheForRedisSecureConnection` | `String` | Only secure connections to your Azure Cache for Redis should be enabled. Allowed Values: Audit; Deny; Disabled. |
`secureTransferToStorageAccountEnabled` | `String` | Secure transfer to storage accounts should be enabled. Allowed Values: Audit; Deny; Disabled. |
`azureDataBoxJobsShouldUseCmk` | `String` | Azure Data Box jobs should use a customer-managed key to encrypt the device unlock password. Allowed Values: Audit; Deny; Disabled. |
`azureDataBoxCmkSupportedSku` | `Array` | Azure Data Box SKUs that support customer-managed key encryption key. Allowed Values: DataBox DataBoxHeavy. |
`dataFactoryShouldUseCmk` | `String` | Azure data factories should be encrypted with a customer-managed key. Allowed Values: Audit; Deny; Disabled. |
`hdInsightShouldUseCmk` | `String` | Azure HDInsight clusters should use customer-managed keys to encrypt data at rest. Allowed Values: Audit; Deny; Disabled. |
`hdInsightEncryptionAtRest` | `String` | Azure HDInsight clusters should use encryption at host to encrypt data at rest. Allowed Values: Audit; Deny; Disabled. |
`savedQueriesSavedInStorageAccount` | `String` | Saved-queries in Azure Monitor should be saved in customer storage account for logs encryption. Allowed Values: Audit; Deny; Disabled. |
`cognitiveSearchShouldUseCmk` | `String` | Cognitive Services accounts should enable data encryption with a customer-managed key. Allowed Values: Audit; Deny; Disabled. |
`cosmosDbShouldUseCmk` | `String` | Azure Cosmos DB accounts should use customer-managed keys to encrypt data at rest. Allowed Values: Audit; Deny; Disabled. |
`acrShouldUseCmk` | `String` | Container registries should be encrypted with a customer-managed key. Allowed Values: Audit; Deny; Disabled. |
`machineLearningWorkspacesShouldUseCmk` | `String` | Azure Machine Learning workspaces should be encrypted with a customer-managed key. Allowed Values: Audit; Deny; Disabled. |
`dataExplorerShouldUseCmk` | `String` | Azure Data Explorer encryption at rest should use a customer-managed key. Allowed Values: Audit; Deny; Disabled. |
`containerInstanceContainerGroupShouldUseCmk` | `String` | Azure Container Instance container group should use customer-managed key for encryption. Allowed Values: Audit; Disabled; Deny.
`iotHubDeviceShouldUseCmk` | `String` | [Preview]: IoT Hub device provisioning service data should be encrypted using customer-managed keys (CMK). Allowed Values: Audit; Deny; Disabled. |
`streamAnalyticsJobsShouldUseCmk` | `String` | Azure Stream Analytics jobs should use customer-managed keys to encrypt data. Allowed Values: Audit; Deny; Disabled. |
`botServiceShouldUseCmk` | `String` | Bot Service should be encrypted with a customer-managed key. Allowed Values: Audit; Deny; Disabled. |
`storageAccountEncryptionScopesShouldUseCmk` | `String` | Storage account encryption scopes should use customer-managed keys to encrypt data at rest. Allowed Values: Audit; Deny; Disabled. |
`hpcCacheAccountsShouldUseCmk` | `String` | HPC Cache accounts should use customer-managed key for encryption. Allowed Values: Audit; Disabled; Deny. |
`automationAccountsShouldUseCmk` | `String` | Azure Automation accounts should use customer-managed keys to encrypt data at rest. Allowed Values: Audit; Deny; Disabled. |
`recoveryVaultShouldUseCmkForBackedUpData` | `String` | [Preview]: Azure Recovery Services vaults should use customer-managed keys for encrypting backup data. Allowed Values: Audit; Deny; Disabled. |
`recoveryVaultEnableDoubleEncryption` | `Boolean` | Require that double encryption is enabled on Recovery Services vaults for Backup. Allowed Values: True False. |
`logicAppIntegrationShouldBeEncrypted` | `String` | Logic Apps Integration Service Environment should be encrypted with customer-managed keys. Allowed Values: Audit; Deny; Disabled. |
`azureBatchShouldUseCmk` | `String` | Azure Batch account should use customer-managed keys to encrypt data. Allowed Values: Audit; Deny; Disabled. |
`azureMonitorLogClustersShouldUseCmk` | `String` | Azure Monitor Logs clusters should be encrypted with customer-managed key. Allowed Values: Audit; Deny; Disabled. |
`synapseWorkSpaceShouldUseCmk` | `String` | Azure Synapse workspaces should use customer-managed keys to encrypt data at rest. Allowed Values: Audit; Deny; Disabled. |
`kubernetesOsAndDataDiskShouldUseCmk` | `String` | Both operating systems and data disks in Azure Kubernetes Service clusters should be encrypted by customer-managed keys. Allowed Values: Audit; Deny; Disabled. |
`managedDiskShouldUseCmkAndPmk` | `String` | Managed disks should be double encrypted with both platform-managed and customer-managed keys. Allowed Values: Audit; Deny; Disabled. |
`osAndDataDiskShouldUseCmk` | `String` | OS and data disks should be encrypted with a customer-managed key. Allowed Values: Audit; Deny; Disabled. |
`serviceFabricClusterClusterProtectionLevelSet` | `String` | Service Fabric clusters should have the ClusterProtectionLevel property set to EncryptAndSign. Allowed Values: Audit; Deny; Disabled. |
`dataExplorerShouldEnableDoubleEncryption` | `String` | Double encryption should be enabled on Azure Data Explorer. Allowed Values: Audit; Deny; Disabled. |
`dataBoxJobsShouldEnableDoubleEncryption` | `String` | Azure Data Box jobs should enable double encryption for data at rest on the device. Allowed Values: Audit; Deny; Disabled. |
`dataBoxsupportedSku` | `Array` | Azure Data Box SKUs that support software-based double encryption. Allowed Values: DataBox DataBoxHeavy. |
`automationAccountVariablesShouldBeEncrypted` | `String` | Automation account variables should be encrypted. Allowed Values: Audit; Deny; Disabled. |
`stackEdgeDevicesShouldUseDoubleEncryption` | `String` | Azure Stack Edge devices should use double-encryption. Allowed Values: Audit; Deny; Disabled. |
`monitorClusterLogsShouldDoubleEncryption` | `String` | Azure Monitor Logs clusters should be created with infrastructure-encryption enabled (double encryption). Allowed Values: Audit; Deny; Disabled. |
`databaseForMySqlInfrastructureEncryption` | `String` | Infrastructure encryption should be enabled for Azure Database for MySQL servers. Allowed Values: Audit; Deny; Disabled. |
`postgresSqlInfrastructureEncryption` | `String` | Infrastructure encryption should be enabled for Azure Database for PostgreSQL servers. Allowed Values: Audit; Deny; Disabled. |
`nistSettings.storageAccountsInfrastructureEncryption` | `String` | Storage accounts should have infrastructure encryption. Allowed Values: Audit; Deny; Disabled. |
`diskEncryptionEnabledOnDataExplorer` | `String` | Disk encryption should be enabled on Azure Data Explorer. Allowed Values: Audit; Deny; Disabled. |
`kubernetesTempCacheDiskEncryptionAtHost` | `String` | Temp disks and cache for agent node pools in Azure Kubernetes Service clusters should be encrypted at host. Allowed Values: Audit; Deny; Disabled. |
`vmAndVmssEncryptionAtHost` | `String` | Virtual machines and virtual machine scale sets should have encryption at host enabled. Allowed Values: Audit; Deny; Disabled. |
`windowsDefenderNotAvailableMachineState` | `String` | Status if Windows Defender is not available on machine. Allowed Values: Compliant Non-Compliant. |
`networkSecurityConfigureEncryptionTypesAllowedForKerberos` | `String` | Specified Group Policy setting for Security Options - Network Security: Configure encryption types allowed for Kerberos.
`networkSecurityLanManagerAuthenticationLevel` | `String` | Specified Group Policy setting for Security Options - Network Security: LAN Manager authentication level. |
`networkSecurityLdapClientSigningRequirements` | `String` | Specified Group Policy setting for Security Options - Network Security: LDAP client signing requirements. |
`networkSecurityMinimumSessionSecurityForNtlmsSpBasedIncludingSecureRpcclients` | `String` | Specified Group Policy setting for Security Options - Network Security: Minimum session security for NTLM SSP based (including secure RPC) clients. |
`networkSecurityMinimumSessionSecurityForNtlmsSpBasedIncludingSecureRpcServers` | `String` | Specified Group Policy setting for Security Options - Network Security: Minimum session security for NTLM SSP based (including secure RPC) servers. |


## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "nistSettings": {
            "value": {
                "includeArcMachines": "false",
                "membersToExcludeInLocalAdministratorsGroup": "",
                "membersToIncludeInLocalAdministratorsGroup": "",
                "networkWatcherResourceGroupName": "NetworkWatcherRG",
                "logAnalyticsWorkspaceIdForVmAgents": "",
                "minimumTlsVersionForWindowsServers": "1.2",
                "storageAccountRestrictNetworkAccess": "Audit",
                 "vmImageBuilderPrivateLink": "Audit",
                "keyVaultPrivateLink": "Audit",
                "springCloudNetworkInjection": "Audit",
                "evaluatedSkuNamesSpringCloud": [
                    "Standard"
                ],
                "cognitiveSearchPrivateLink": "Audit",
                "serviceFabricShouldUseAzureAd": "Audit",
                "cognitiveSearchLocalAuthenticationDisabled": "Audit",
                "vmMigratedToNewArm": "Audit",
                "storaceAccountMigratedToNewArm": "Audit",
                "evaluatedSkuNamesApiMgmt": [
                    "Developer",
                    "Premium"
                ],
                "cosmosDbFirewallRules": "Audit",
                "acrUnrestrictedNetworkAccess": "Audit",
                "storageAccountShouldRestrictNetworkAccessVirtualRules": "Audit",
                "keyvaultsDisablePublicNetworkAccess": "Audit",
                "sqlDbShouldDisablePublicNetworkAccess": "Audit",
                "cognitiveSearchAccountsRestrictNetworkAccess": "Audit",
                "cognitiveServiceAccountsDisablePublicNetworkAccess": "Audit",
                "storageAccountPublicAccessDisallowed": "audit",
                "cognitiveSearchDisablePublicNetworkAccess": "Audit",
                "requiredRetentionDays": "365",
                "requiredAuditSettingForSqlServer": "enabled",
                "kubernetesOnlyAllowedImages": "audit",
                "kubernetesExcludedNamespaces": [
                    "kube-system",
                    "gatekeeper-system",
                    "azure-arc"
                ],
                "kubernetesNamespaces": [],
                "kubernetesLabelSelector": {},
                "allowedContainerImagesRegex": "^(.+){0}$",
                "kubernetesExcludedContainers": [],
                "kubernetesDisallowPrivilegedContainers": "audit",
                "kubernetesAllowedPorts": "audit",
                "kubernetesAllowedServicePortsList": [],
                "kubernetesResourceLimitsExceeded": "audit",
                "kubernetesCpuLimit": "0",
                "kubernetesMemoryLimit": "0",
                "kubernetesApprovedUserAndGroupsId": "audit",
                "kubernetesRunAsUserRule": "MustRunAsNonRoot",
                "kubernetesRunAsUserRanges": {
                    "ranges": []
                },
                "kubernetesRunAsGroupRule": "RunAsAny",
                "kubernetesRunAsGroupRanges": {
                    "ranges": []
                },
                "kubernetesSupplementalGroupsRule": "RunAsAny",
                "kubernetesSupplementalGroupsRanges": {
                    "ranges": []
                },
                "kubernetesFsGroupRule": "RunAsAny",
                "kubernetesFsGroupRanges": {
                    "ranges": []
                },
                "kubernetesContainerNotAllowPrivilegeEscalation": "audit",
                "kubernetesNotShareHostProcesOrIpc": "audit",
                "kubernetesRunWithReadOnlyFs": "audit",
                "kubernetesOnlyAllowedCapabilities": "audit",
                "kubernetesAllowedCapabilities": [],
                "kubernetesRequiredDropCapabilities": [],
                "kubernetesOnlyAppArmorProfiles": "audit",
                "kubernetesAllowedAppArmorProfiles": [],
                "kubernetesClusterPodsApprovedHostNetworkAndPortRanges": "audit",
                "kubernetesAllowHostNetwork": false,
                "kubernetesMinPortRange": 0,
                "kubernetesMaxPortRange": 0,
                "kubernetesHostPadVolumes": "audit",
                "kubernetesAllowedHostPaths": {
                    "paths": []
                },
                "keyVaultMaximumValidityInMonths": 12,
                "maximumCertificateValidity": "audit",
                "keyvaultSecretExpirationDate": "Audit",
                "keyvaultKeysExpirationDate": "Audit",
                "keyvaultPurgeProtectionEnabled": "Audit",
                "keyvaultSoftDeleteEnabled": "Audit",
                "wafEnabledAzureFrontDoor": "Audit",
                "wafEnabledAppGateway": "Audit",
                "kubernetesAccessibleOverHttps": "audit",
                "hdinsightUseEncryptionInTransit": "Audit",
                "azureCacheForRedisSecureConnection": "Audit",
                "secureTransferToStorageAccountEnabled": "Audit",
                "azureDataBoxJobsShouldUseCmk": "Audit",
                "azureDataBoxCmkSupportedSku": [
                    "DataBox",
                    "DataBoxHeavy"
                ],
                "dataFactoryShouldUseCmk": "Audit",
                "hdInsightShouldUseCmk": "Audit",
                "hdInsightEncryptionAtRest": "Audit",
                "savedQueriesSavedInStorageAccount": "audit",
                "cognitiveSearchShouldUseCmk": "Audit",
                "cosmosDbShouldUseCmk": "audit",
                "acrShouldUseCmk": "Audit",
                "machineLearningWorkspacesShouldUseCmk": "Audit",
                "dataExplorerShouldUseCmk": "Audit",
                "containerInstanceContainerGroupShouldUseCmk": "Audit",
                "iotHubDeviceShouldUseCmk": "Audit",
                "streamAnalyticsJobsShouldUseCmk": "audit",
                "botServiceShouldUseCmk": "audit",
                "storageAccountEncryptionScopesShouldUseCmk": "Audit",
                "hpcCacheAccountsShouldUseCmk": "Audit",
                "automationAccountsShouldUseCmk": "Audit",
                "recoveryVaultShouldUseCmkForBackedUpData": "Audit",
                "recoveryVaultEnableDoubleEncryption": true,
                "logicAppIntegrationShouldBeEncrypted": "Audit",
                "azureBatchShouldUseCmk": "Audit",
                "azureMonitorLogClustersShouldUseCmk": "audit",
                "synapseWorkSpaceShouldUseCmk": "Audit",
                "kubernetesOsAndDataDiskShouldUseCmk": "Audit",
                "managedDiskShouldUseCmkAndPmk": "Audit",
                "osAndDataDiskShouldUseCmk": "Audit",
                "serviceFabricClusterClusterProtectionLevelSet": "Audit",
                "dataExplorerShouldEnableDoubleEncryption": "Audit",
                "dataBoxJobsShouldEnableDoubleEncryption": "Audit",
                "dataBoxsupportedSku": [
                    "DataBox",
                    "DataBoxHeavy"
                ],
                "automationAccountVariablesShouldBeEncrypted": "Audit",
                "stackEdgeDevicesShouldUseDoubleEncryption": "audit",
                "monitorClusterLogsShouldDoubleEncryption": "audit",
                "databaseForMySqlInfrastructureEncryption": "Audit",
                "postgresSqlInfrastructureEncryption": "Audit",
                "nistSettings.storageAccountsInfrastructureEncryption": "Audit",
                "diskEncryptionEnabledOnDataExplorer": "Audit",
                "kubernetesTempCacheDiskEncryptionAtHost": "Audit",
                "vmAndVmssEncryptionAtHost": "Audit",
                "windowsDefenderNotAvailableMachineState": "Compliant",
                "networkSecurityConfigureEncryptionTypesAllowedForKerberos": "2147483644",
                "networkSecurityLanManagerAuthenticationLevel": "5",
                "networkSecurityLdapClientSigningRequirements": "1",
                "networkSecurityMinimumSessionSecurityForNtlmsSpBasedIncludingSecureRpcclients": "537395200",
                "networkSecurityMinimumSessionSecurityForNtlmsSpBasedIncludingSecureRpcServers": "537395200"
            }
        },
        "nistR2AuditDenySetAssignmentName": {
            "value": "nistr2.auditdeny.policy.set"
        },
        "nistR2AuditDenySetAssignmentDisplayName": {
            "value": "Nist 800-171 r2 auditdeny policy set"
        },
        "nistPolicyDefinitionId": {
            "value": "/providers/Microsoft.Authorization/policySetDefinitions/03055927-78bd-4236-86c0-f36125a10dc9"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```
