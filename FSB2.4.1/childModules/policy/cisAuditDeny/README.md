# policy/cis/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy assignment.

It deploys the CIS Azure Foundations Benchmark 2.0.0 policy definition set.



## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyAssignments@2021-06-01` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/cisAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    policyMetadata: 'EvidenELZ'
    cisPolicyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/06f19060-9e68-4070-92ca-f15cc126059e'
    cisAuditDenySetAssignmentDisplayName: 'Cis 2.0.0 auditdeny policy set assignment'
    cisAuditDenySetAssignmentName: 'mgmt-d-cis200-auditdeny-policy-set-assignment'
    cisSettings: cisAuditDenySettings
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `cisAuditDenySetAssignmentName` | `string` | true | Specify name for assignment of CIS audit deny initiative. |
| `cisAuditDenySetAssignmentDisplayName` | `string` | true | Specify display name for assignment of CIS audit deny initiative. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |
| `cisPolicyDefinitionId` | `string` | true | Specify the policy definition id of the built-in CIS Initiative. |

### Object - cisSettings
| Name | Type | Description |
| --- | --- | --- |
| `virtualMachineExtensionsAllowed` | `array` | The approved list of Virtual Machine extensions. |
| `effectVirtualMachineExtensionsAllowed` | `string` | Effect Only approved VM extensions should be installed. Allowed Values: Audit; Deny; Disabled. |
| `resourceLogsRequiredRetentionDays` | `string` | Required retention period (days) for resource logs.  |
| `defenderForServersEnabled` | `string` | Azure Defender for Servers should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `defenderForAppServiceEnabled` | `string` | Azure Defender for App Service should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `defenderForSqlDbEnabled` | `string` | Azure Defender for Sql Db should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `defenderForSqlServerEnabled` | `string` | Azure Defender for Sql Server should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `defenderForStorageEnabled` | `string` | Azure Defender for Containers should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `defenderForContainersEnabled` | `string` | Azure Defender for Containers should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `defenderForKeyvaultsEnabled` | `string` | Azure Defender for Keyvaults should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `autoProvisionLaAgentEnabled` | `string` | Auto provisioning of the Log Analytics agent should be enabled on your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `subscriptionSecurityContact` | `string` | Subscriptions should have a contact email address for security issues. Allowed Values: AuditIfNotExists; Disabled. |
| `emailHighSeverityAlert` | `string` | Email notification for high severity alerts should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `secureTransferStorageAccount` | `string` | Secure transfer to storage accounts should be enabled. Allowed Values: Audit; Deny; Disabled. |
| `storagePublicAccessDisallowed` | `string` | Storage account public access should be disallowed. Allowed Values: Audit; Deny; Disabled. |
| `storageAccountRestrictNetworkAccess` | `string` | Storage accounts should restrict network access. Allowed Values: Audit; Deny; Disabled. |
| `storageAccountRestrictNetworkAccessVirtualNetworkRules` | `string` | Storage accounts should restrict network access using virtual network rules. Allowed Values: Audit; Deny; Disabled. |
| `storageAccountAllowTrustedMsServices` | `string` | Storage accounts should allow access from trusted Microsoft services. Allowed Values: Audit; Deny; Disabled. |
| `storageAccountCmkForEncryption` | `string` | Storage accounts should use customer-managed key for encryption. Allowed Values: Audit; Disabled. |
| `auditSqlEnabled` | `string` | Auditing on SQL server should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `tdeOnSqlEnabled` | `string` | Transparent Data Encryption on SQL databases should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `sqlServerAuditLogRetention` | `string` | SQL servers with auditing to storage account destination should be configured with 90 days retention or higher. Allowed Values: AuditIfNotExists; Disabled. |
| `defenderForSqlOnUnprotectedSqlServersEnabled` | `string` | Azure Defender for SQL should be enabled for unprotected Azure SQL servers. Allowed Values: AuditIfNotExists; Disabled. |
| `defenderForSqlOnUnprotectedSqlMiEnabled` | `string` | Azure Defender for SQL should be enabled for unprotected SQL Managed Instances. Allowed Values: AuditIfNotExists; Disabled. |
| `vulnerabilityAssessmentEnabledOnSqlServers` | `string` | Vulnerability assessment should be enabled on your SQL servers. Allowed Values: AuditIfNotExists; Disabled. |
| `vulnerabilityAssessmentEnabledOnMiInstances` | `string` | Vulnerability assessment should be enabled on SQL Managed Instance. Allowed Values: AuditIfNotExists; Disabled. |
| `enforcedSslEnabledPostgresSql` | `string` | Enforce SSL connection should be enabled for PostgreSQL database servers. Allowed Values: Audit; Disabled. |
| `enabledLogCheckpointsPostgresSql` | `string` | Log checkpoints should be enabled for PostgreSQL database servers. Allowed Values: AuditIfNotExists; Disabled. |
| `enabledLogConnectionsPostgresSql` | `string` | Log connections should be enabled for PostgreSQL database servers. Allowed Values: AuditIfNotExists; Disabled. |
| `enabledLogDisconnectionsPostgresSql` | `string` | isconnections should be logged for PostgreSQL database servers. Allowed Values: AuditIfNotExists; Disabled. |
| `enabledConnectionThrottlingPostgresSql` | `string` | Connection throttling should be enabled for PostgreSQL database servers. Allowed Values: AuditIfNotExists; Disabled. |
| `azureAdAdminShouldbeProvisionForSqlServer` | `string` | Kubernetes service (AKS) should be installed and enabled on clusters. Allowed Values: Audit; Disabled. |
| `sqlServersShouldUseCmkAtRest` | `string` | SQL managed instances should use customer-managed keys to encrypt data at rest. Allowed Values: Audit; Deny; Disabled. |
| `sqlMiShouldUseCmkAtRest` | `string` | SQL managed instances should use customer-managed keys to encrypt data at rest. Allowed Values: Audit; Deny; Disabled. |
| `storageAccountWithActivityLogsShouldUseCmk` | `string` | Effect Storage account containing the container with activity logs must be encrypted with BYOK. Allowed Values: AuAuditIfNotExists; Disabled. |
| `resourceLogsInKeyvaultsEnabled` | `string` | Resource logs in Key Vault should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `activityLogAlertForPolicyWrite` | `string` | An activity log alert should exist for specific Policy operations. Allowed Values: AuditIfNotExists; Disabled. |
| `activityLogAlertForPolicyDelete` | `string` |  An activity log alert should exist for specific Policy operations. Allowed Values: AuditIfNotExists; Disabled. |
| `activityLogAlertForNsgWrite` | `string` | An activity log alert should exist for specific Administrative operations. Allowed Values: AuditIfNotExists; Disabled. |
| `activityLogAlertForNsgDelete` | `string` | An activity log alert should exist for specific Administrative operations. Allowed Values: AuditIfNotExists; Disabled. |
| `activityLogAlertForNsgRuleWrite` | `string` | An activity log alert should exist for specific Administrative operations. Allowed Values: AuditIfNotExists; Disabled. |
| `activityLogAlertForNsgRuleDelete` | `string` | An activity log alert should exist for specific Administrative operations. Allowed Values: AuditIfNotExists; Disabled. |
| `activityLogAlertForFirewallRulesWrite` | `string` | An activity log alert should exist for specific Administrative operations. Allowed Values: AuditIfNotExists; Disabled. |
| `activityLogAlertForFirewallRulesDelete` | `string` | An activity log alert should exist for specific Administrative operations. Allowed Values: AuditIfNotExists; Disabled. |
| `appServiceResourceLogsEnabled` | `string` | App Service apps should have resource logs enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `batchAccountsResourceLogsEnabled` | `string` | Resource logs in Azure Data Lake Store should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `azureDatalakeStoreResourceLogsEnabled` | `string` | Effect Resource logs in Azure Data Lake Store should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `dataLakeAnalyticsResourceLogsEnabled` | `string` | Resource logs in Data Lake Analytics should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `eventHubsResourceLogsEnabled` | `string` | Resource logs in Event Hubs should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `iotHubResourceLogsEnabled` | `string` | Resource logs in Iot Hub should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `logicAppResourceLogsEnabled` | `string` | Resource logs in Logic Apps should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `searchServicesResourceLogsEnabled` | `string` | Resource logs in Search Services should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `serviceBusResourceLogsEnabled` | `string` | Resource logs in Service Bus should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `streamAnalyticsResourceLogsEnabled` | `string` | Resource logs in Stream Analytics should be enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `encryptDataFlowsBetweenComputeAndStorage` | `string` | Virtual machines should encrypt temp disks, caches, and data flows between Compute and Storage resources. Allowed Values: AuditIfNotExists; Disabled. |
| `keyVaultKeysShouldHaveExpiration` | `string` | Kubernetes service (AKS) should be installed and enabled on clusters. Allowed Values: Audit; Disabled. |
| `keyVaultSecretsShouldHaveExpiration` | `string` | Key Vault keys should have an expiration date. Allowed Values: Audit; Deny; Disabled. |
| `keyvaultPurgeProtectionEnabled` | `string` | Key vaults should have purge protection enable. Allowed Values: Audit; Deny; Disabled. |
| `functionAppsAuthenticationEnabled` | `string` | Function apps should have authentication enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `appServicesAuthenticationEnabled` | `string` | App Services should have authentication enabled.. Allowed Values: AuditIfNotExists; Disabled. |
| `appServiceAccessibleOverHttps` | `string` | App Service apps should only be accessible over HTTPS. Allowed Values: Audit; Deny; Disabled. |
| `functionAppsLatestTlsVersion` | `string` | Function apps should use the latest TLS version. Allowed Values: AuditIfNotExists; Disabled. |
| `appServiceAppsLatestTlsVersion` | `string` | App Service apps should use the latest TLS version. Allowed Values: AuditIfNotExists; Disabled. |
| `functionAppsClientCertificatesEnabled` | `string` | Function apps should have "Client Certificates (Incoming client certificates)" enabled. Allowed Values: Audit; Disabled. |
| `appServiceAppsClientCertificatesEnabled` | `string` | App Service apps should use managed identity. Allowed Values: Audit; Disabled. |
| `functionAppShouldUseManagedIdentity` | `string` | Function apps should use managed identity. Allowed Values: AuditIfNotExists; Disabled. |
| `appServiceAppShouldUseManagedIdentity` | `string` | App Service apps should have "Client Certificates (Incoming client certificates)" enabled. Allowed Values: AuditIfNotExists; Disabled. |
| `functionAppShouldUseLatestHttpVersion` | `string` | Function apps should use latest HTTP Version. Allowed Values: AuditIfNotExists; Disabled. |
| `appServiceAppShouldUseLatestHttpVersion` | `string` | App Service apps should use latest HTTP Version. Allowed Values: AuditIfNotExists; Disabled. |
| `functionAppShouldRequireFtpsOnly` | `string` | Function apps should require FTPS only. Allowed Values: AuditIfNotExists; Disabled. |
| `appServiceAppShouldRequireFtpsOnly` | `string` | App Service apps should require FTPS only. Allowed Values: AuditIfNotExists; Disabled. |
| `networkWatcherShouldBeEnabled` | `string` | Network Watcher should be enabled. |
| `requiredAuditSettingsforSqlServers` | `string` | Required auditing setting for SQL servers. Allowed Values: enabled; disabled. |
| `guestOwnerPermissionRemoved` | `string` | Guest accounts with owner permissions should be removed from your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `guestWritePermissionRemoved` | `string` | Guest accounts with write permissions should be removed from your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `guestReadPermissionRemoved` | `string` | Guest accounts with read permissions should be removed from your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `mfaWithWritePermissionEnabled` | `string` | MFA should be enabled accounts with write permissions on your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `mfaWithOwnerPermissionEnabled` | `string` | MFA should be enabled on accounts with owner permissions on your subscription. Allowed Values: AuditIfNotExists; Disabled. |
| `maximumDaysToRotateKeys` | `string` | Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation. Allowed Values: Audit; Disabled. |
| `maximumDaysToRotate` | `int` | The maximum number of days after key creation until it must be rotated. Allowed Values: integer |
| `keyvaultSoftDeleteEnabled` | `string` | Key vaults should have soft delete enabled: Allowed Values. Audit; Deny; Disabled. |
| `cosmosDbShouldHaveFirewallRules` | `string` | Azure Cosmos DB accounts should have firewall rules. Allowed Values: Audit; Deny; Disabled. |
| `sqlPublicAccessShouldBeDisabled` | `string` | Public network access on Azure SQL Database should be disabled. Allowed Values: Audit; Deny; Disabled. |
| `postgresSqlInfraEncryptionShouldBeEnabled` | `string` | Infrastructure encryption should be enabled for Azure Database for PostgreSQL servers. Allowed Values: Audit; Deny; Disabled. |
| `storageAccountShouldHaveInfraEncryption` | `string` | Infrastructure encryption should be enabled for storage accounts. Allowed Values: Audit; Deny; Disabled. |
| `enforceSslMySqlEnabled` | `string` | Enforce SSL connection should be enabled for MySQL database servers. Allowed Values: Audit; Deny; Disabled. |
| `enforceSslMySqlEnabled` | `string` | Enforce SSL connection should be enabled for MySQL database servers. Allowed Values: Audit; Deny; Disabled. |
| `appServiceAppsPythonVersion` | `string` | App Service apps that use Python should use a specified 'Python version. Allowed Values: AuditIfNotExists, Disabled. |
| `managedDiskDoubleEncryptionEnabled` | `string` | Managed disks should be double encrypted with both platform-managed and customer-managed keys. Allowed Values: Audit; Deny; Disabled. |
| `appServiceSlotsPhpVersion` | `string` | App Service apps that use PHP should use a specified 'PHP version'. Allowed Values: AuditIfNotExists, Disabled. |
| `appServiceJavaVersion` | `string` | App Service apps that use JAVA should use a specified 'JAVA version'. Allowed Values: AuditIfNotExists, Disabled. |
| `auditCustomRbac"` | `string` | Audit usage of custom RBAC roles. Allowed Values: Audit, Disabled. |
| `vmManagementPortsShouldBeClosed` | `string` | Management ports should be closed on your virtual machines.  Allowed Values: Audit, Disabled. |
| `postgresSqlPublicAccessShouldBeDisabled` | `string` | Public network access should be disabled for PostgreSQL servers. Allowed Values: Audit, Deny, Disabled. |
| `postgresFlexSqlPublicAccessShouldBeDisabled` | `string` | Public network access should be disabled for PostgreSQL Flex servers. Allowed Values: Audit, Deny, Disabled. |
| `sqlVulnerabilityFindingsShouldBeResolved` | `string` | SQL databases should have vulnerability findings resolved. Allowed Values: AuditIfNotExists, Disabled. |
| `storageAccountsShouldUsePrivateLinks` | `string` | Storage Accounts should use private links. Allowed Values: AuditIfNotExists, Disabled. |
| `securityRulesDeleteAlertShouldExist` | `string` | An activity log alert should exist for specific Administrative operations. Allowed Values: AuditIfNotExists, Disabled. |
| `nsgDeleteAlertShouldExist` | `string` | An activity log alert should exist for specific Administrative operations. Allowed Values: AuditIfNotExists, Disabled. |
| `defenderForResourceManagerEnabled` | `string` | Azure Defender for Resource Manager should be enabled. Allowed Values: AuditIfNotExists, Disabled. |
| `securitySolutionsAlertShouldExist` | `string` | An activity log alert should exist for specific Administrative operations. Allowed Values: AuditIfNotExists, Disabled. |
| `azureKeyvaultShouldUsePrivateLink` | `string` | Azure Key Vaults should use private link. Allowed Values: Audit, Deny, Disabled. |
| `defenderForDnsEnabled` | `string` | Azure Defender for DNS should be enabled. Allowed Values: AuditIfNotExists, Disabled. |
| `defenderForRelationalDatabasesEnabled` | `string` | Azure Defender for relational databases should be enabled. Allowed Values: AuditIfNotExists, Disabled. |
| `endpointProtectionEnabled` | `string` | Endpoint protection should be installed on your machines. Allowed Values: AuditIfNotExists, Disabled. |
| `networkFlowLogsEnabled` | `string` | Flow logs should be configured for every virtual network. Allowed Values: AuditIf, Disabled. |
| `nsgFlowLogsEnabled` | `string` | Flow logs should be configured for every NSG. Allowed Values: AuditIf, Disabled. |
| `allFlowLogsEnabled` | `string` | All flow log resources should be in enabled state. Allowed Values: Audit, Disabled. |
| `periodicUpdateCheckConfigured` | `string` | Machines should be configured to periodically check for missing system updates. Allowed Values: Audit, Deny, Disabled. |
| `defenderForCosmosDbEnabled` | `string` | Azure Defender for CosmosDb should be enabled. Allowed Values: AuditIfNotExists, Disabled. |
| `functionAppsJavaVersion` | `string` | Function app slots that use Java should use a specified 'Java version'. Allowed Values: AuditIfNotExists, Disabled. |
| `appServiceSlotsPythonVersion` | `string` | Function app slots that use Python should use a specified 'Python version'. Allowed Values: AuditIfNotExists, Disabled. |
| `appServicePhpVersion` | `string` | Function apps that use PHP should use a specified 'PHP version'. Allowed Values: AuditIfNotExists, Disabled. |
| `cosmosDbLocalAuthDisabled` | `string` | Cosmos DB database accounts should have local authentication methods disabled. Allowed Values: Audit, Deny, Disabled. |
| `keyvaultShouldUseRbacModel` | `string` | Azure Key Vault should use RBAC permission model. Allowed Values: Audit, Deny, Disabled. |
| `securitySolutionsWriteAlertShouldExist` | `string` | An activity log alert should exist for specific Administrative operations. Allowed Values: AuditIfNotExist, Disabled. |
| `nsgWriteAlertShouldExist` | `string` | An activity log alert should exist for specific Administrative operations. Allowed Values: AuditIfNotExist, Disabled. |

## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "cisSettings": {
            "value": {
                "virtualMachineExtensionsAllowed": [
                    "AzureDiskEncryption"
                ],
                "effectVirtualMachineExtensionsAllowed": "Audit",
                "keyvaultSoftDeleteEnabled": "Audit",
                "securitySolutionsAlertShouldExist": "AuditIfNotExists",
                "securityRulesDeleteAlertShouldExist": "AuditIfNotExists",
                "defenderForResourceManagerEnabled": "AuditIfNotExists",
                "azureKeyvaultShouldUsePrivateLink": "Audit",
                "cosmosDbShouldUsePrivateLink": "Audit",
                "defenderForDnsEnabled": "AuditIfNotExists",
                "defenderForRelationalDatabasesEnabled": "AuditIfNotExists",
                "endpointProtectionEnabled": "AuditIfNotExists",
                "networkFlowLogsEnabled": "Audit",
                "nsgFlowLogsEnabled": "Audit",
                "allFlowLogsEnabled": "Audit",
                "periodicUpdateCheckConfigured": "Audit",
                "defenderForCosmosDbEnabled": "AuditIfNotExists",
                "functionAppsJavaVersion": "AuditIfNotExists",
                "appServiceSlotsPythonVersion": "AuditIfNotExists",
                "appServicePhpVersion": "AuditIfNotExists",
                "cosmosDbLocalAuthDisabled": "Audit",
                "keyvaultShouldUseRbacModel": "Audit",
                "securitySolutionsWriteAlertShouldExist": "AuditIfNotExists",
                "nsgWriteAlertShouldExist": "AuditIfNotExists",
                "nsgDeleteAlertShouldExist": "AuditIfNotExists",
                "storageAccountsShouldUsePrivateLinks": "AuditIfNotExists",
                "sqlVulnerabilityFindingsShouldBeResolved": "AuditIfNotExists",
                "securityRulesDeleteAlertShouldExist": "AuditIfNotExists",
                "vmManagementPortsShouldBeClosed": "AuditIfNotExists",
                "postgresFlexSqlPublicAccessShouldBeDisabled": "Audit",
                "postgresSqlPublicAccessShouldBeDisabled": "Audit",
                "auditCustomRbac": "Audit",
                "cosmosDbShouldHaveFirewallRules": "Audit",
                "storageAccountShouldHaveInfraEncryption": "Audit",
                "appServiceJavaVersion": "AuditIfNotExists",
                "resourceLogsRequiredRetentionDays": "160",
                "sqlPublicAccessShouldBeDisabled": "Audit",
                "appServiceAppsPythonVersion": "AuditIfNotExists",
                "appServiceSlotsPhpVersion": "AuditIfNotExists",
                "managedDiskDoubleEncryptionEnabled": "Audit",
                "enforceSslMySqlEnabled": "Audit",
                "postgresSqlInfraEncryptionShouldBeEnabled": "Audit",
                "defenderForServersEnabled": "AuditIfNotExists",
                "defenderForAppServiceEnabled": "AuditIfNotExists",
                "defenderForSqlDbEnabled": "AuditIfNotExists",
                "defenderForSqlServerEnabled": "AuditIfNotExists",
                "defenderForStorageEnabled": "AuditIfNotExists",
                "defenderForContainersEnabled": "AuditIfNotExists",
                "defenderForKeyvaultsEnabled": "AuditIfNotExists",
                "autoProvisionLaAgentEnabled": "AuditIfNotExists",
                "subscriptionSecurityContact": "AuditIfNotExists",
                "emailHighSeverityAlert": "AuditIfNotExists",
                "secureTransferStorageAccount": "Audit",
                "storagePublicAccessDisallowed": "Audit",
                "storageAccountRestrictNetworkAccess": "Audit",
                "storageAccountRestrictNetworkAccessVirtualNetworkRules": "Audit",
                "storageAccountAllowTrustedMsServices": "Audit",
                "storageAccountCmkForEncryption": "Audit",
                "auditSqlEnabled": "AuditIfNotExists",
                "tdeOnSqlEnabled": "AuditIfNotExists",
                "sqlServerAuditLogRetention": "AuditIfNotExists",
                "defenderForSqlOnUnprotectedSqlServersEnabled": "AuditIfNotExists",
                "defenderForSqlOnUnprotectedSqlMiEnabled": "AuditIfNotExists",
                "vulnerabilityAssessmentEnabledOnSqlServers": "AuditIfNotExists",
                "vulnerabilityAssessmentEnabledOnMiInstances": "AuditIfNotExists",
                "enforcedSslEnabledPostgresSql": "Audit",
                "enabledLogCheckpointsPostgresSql": "AuditIfNotExists",
                "enabledLogConnectionsPostgresSql": "AuditIfNotExists",
                "enabledLogDisconnectionsPostgresSql": "AuditIfNotExists",
                "enabledConnectionThrottlingPostgresSql": "AuditIfNotExists",
                "azureAdAdminShouldbeProvisionForSqlServer": "AuditIfNotExists",
                "sqlServersShouldUseCmkAtRest": "Audit",
                "sqlMiShouldUseCmkAtRest": "Audit",
                "storageAccountWithActivityLogsShouldUseCmk": "AuditIfNotExists",
                "resourceLogsInKeyvaultsEnabled": "AuditIfNotExists",
                "activityLogAlertForPolicyWrite": "AuditIfNotExists",
                "activityLogAlertForPolicyDelete": "AuditIfNotExists",
                "activityLogAlertForNsgWrite": "AuditIfNotExists",
                "activityLogAlertForNsgDelete": "AuditIfNotExists",
                "activityLogAlertForNsgRuleWrite": "AuditIfNotExists",
                "activityLogAlertForNsgRuleDelete": "AuditIfNotExists",
                "activityLogAlertForFirewallRulesWrite": "AuditIfNotExists",
                "activityLogAlertForFirewallRulesDelete": "AuditIfNotExists",
                "appServiceResourceLogsEnabled": "AuditIfNotExists",
                "batchAccountsResourceLogsEnabled": "AuditIfNotExists",
                "azureDatalakeStoreResourceLogsEnabled": "AuditIfNotExists",
                "dataLakeAnalyticsResourceLogsEnabled": "AuditIfNotExists",
                "eventHubsResourceLogsEnabled": "AuditIfNotExists",
                "iotHubResourceLogsEnabled": "AuditIfNotExists",
                "logicAppResourceLogsEnabled": "AuditIfNotExists",
                "searchServicesResourceLogsEnabled": "AuditIfNotExists",
                "serviceBusResourceLogsEnabled": "AuditIfNotExists",
                "streamAnalyticsResourceLogsEnabled": "AuditIfNotExists",
                "encryptDataFlowsBetweenComputeAndStorage": "AuditIfNotExists",
                "keyVaultKeysShouldHaveExpiration": "Audit",
                "keyVaultSecretsShouldHaveExpiration": "Audit",
                "keyvaultPurgeProtectionEnabled": "Audit",
                "functionAppsAuthenticationEnabled": "AuditIfNotExists",
                "appServicesAuthenticationEnabled": "AuditIfNotExists",
                "appServiceAccessibleOverHttps": "Audit",
                "functionAppsLatestTlsVersion": "AuditIfNotExists",
                "appServiceAppsLatestTlsVersion": "AuditIfNotExists",
                "functionAppsClientCertificatesEnabled": "Audit",
                "appServiceAppsClientCertificatesEnabled": "Audit",
                "functionAppShouldUseManagedIdentity": "AuditIfNotExists",
                "appServiceAppShouldUseManagedIdentity": "AuditIfNotExists",
                "functionAppShouldUseLatestHttpVersion": "AuditIfNotExists",
                "appServiceAppShouldUseLatestHttpVersion": "AuditIfNotExists",
                "functionAppShouldRequireFtpsOnly": "AuditIfNotExists",
                "appServiceAppShouldRequireFtpsOnly": "AuditIfNotExists",
                "networkWatcherShouldBeEnabled": "NetworkWatcherRG",
                "requiredAuditSettingsforSqlServers": "disabled",
                "guestOwnerPermissionRemoved": "AuditIfNotExists",
                "guestWritePermissionRemoved": "AuditIfNotExists",
                "guestReadPermissionRemoved": "AuditIfNotExists",
                "mfaWithWritePermissionEnabled": "AuditIfNotExists",
                "mfaWithOwnerPermissionEnabled": "AuditIfNotExists"

            }
        },
        "cisPolicyDefinitionId": {
            "value": "/providers/Microsoft.Authorization/policySetDefinitions/06f19060-9e68-4070-92ca-f15cc126059e"
        },
        "cisAuditDenySetAssignmentDisplayName": {
            "value": "Cis 2.0.0 auditdeny policy set assignment"
        },
        "cisAuditDenySetAssignmentName": {
            "value": "mgmt-d-cis200-auditdeny-policy-set-assignment"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```
