# policy/storageAccountAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys one Azure policy set definition which contains one custom policy and several built-in policies.

This policy set configures audit policies for Storage Account resources.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyDefinitions) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/storageAccountAuditDeny/policy.bicep' = {
  name: 'deploystorageAccountAuditDenyPolicy'
  params: {
    listOfAllowedSkus: [
        'Standard_LRS'
    ]
    storageAccountSettings: [
            allowedStorageSkusAudit : 'Audit',
            auditForClassicStorage : 'Audit',
            geoRedundantStorageAccountsAudit : 'Audit',
            storageAccountAllowCrossTenantReplicationAudit : 'Audit',
            storageAccountAllowSharedKeyAccessAudit : 'Audit',
            storageAccountInfrastructureEncryptionEnabledAudit: 'Audit',
            storageAccountKeysExpiredRestrict : 'Audit',
            storageAccountPrivateEndpointEnabledAudit : 'AuditIfNotExists',
            storageAccountSasPolicyRestrict : 'Audit',
            storageEncryptionScopesShouldUseDoubleEncryptionAudit : 'Audit',
            storageQueueCustomerManagedKeyEnabledAudit: 'Audit',
            storageSyncIncomingTrafficPolicyAuditDeny: 'Audit',
            storageSyncPrivateDnsZoneAuditIfNotExists: 'Audit',
            storageSyncPrivateEndpointAuditIfNotExists: 'AuditIfNotExists',
            storageTableCustomerManagedKeyEnabledAudit: 'Audit',
            storageEncryptionScopesShouldUseCmkAudit: 'Audit',
            virtualNetworkServiceEndpointStorageAccountAudit: 'Audit'
        ]
    storageAccountAuditDenySetName : 'storageaccount.auditdeny.policy.set'
    storageAccountAuditDenySetDisplayName : 'Storage account auditdeny policy set'
    storageAccountAuditDenySetAssignmentName : 'storageaccount.auditdeny.policy.set.assignment'
    storageAccountAuditDenySetAssignmentDisplayName : 'storage account auditdeny policy set assignment'
    storageAccountFilesyncprivatednszoneDefName : 'storageaccount.filesyncprivatednszone.auditdeny.policy.def'
    storageAccountFilesyncprivatednszoneDefDisplayName : 'Storage account azure file sync auditdeny policy definition'
    policyMetadata : 'EvidenELZ'
    }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `storageAccountSettings`| `object` | true | values for the effect properties of the policies from the policy set. Additional Details [here](#object---storageaccountsettings). |
| `storageAccountAuditDenySetName` | `string` | true | set name for storage account audit deny initiative. |
| `storageAccountAuditDenySetDisplayName` | `string` | true | set displayname for storage account audit deny initiative. |
| `storageAccountAuditDenySetAssignmentName` | `string` | true | set assignment name for storage account audit deny initiative. |
| `storageAccountAuditDenySetAssignmentDisplayName` | `string` | true | set assignment displayname for storae account audit deny initiative. |
| `storageAccountFilesyncprivatednszoneDefName` | `string` | true | def name for the AccountFilesyncprivatednszone policy within the initiative. |
| `storageAccountFilesyncprivatednszoneDefDisplayName` | `string` | true |def displayname for AccountFilesyncprivatednszone within the initiative. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

### Object - storageAccountSettings

| Name | Type | Description |
| --- | --- | --- |
| `allowedStorageSkusAudit` | `string` | Effect value for 'Storage accounts should be limited by allowed SKUs' policy. Allowed values: Audit, Deny, Disabled |
| `auditForClassicStorage` | `string` |  Effect value for 'Storage accounts should be migrated to new Azure Resource Manager resources' policy. Allowed values: Audit, Deny, Disabled |
| `geoRedundantStorageAccountsAudit` | `string` |Effect value for 'Geo-redundant storage should be enabled for Storage Accounts' policy. Allowed values:  Audit, Deny, Disabled | 
| `storageAccountAllowCrossTenantReplicationAudit` | `string` |  Effect value for 'Storage accounts should prevent cross tenant object replication' policy. Allowed values: Audit, Deny, Disabled |
| `storageAccountAllowSharedKeyAccessAudit` | `string` |  Effect value for 'Storage accounts should prevent shared key access' policy. Allowed values: Audit, Deny, Disabled |
| `listOfAllowedSkus` | `string[]` | list of allowed SKUs |
| `storageAccountInfrastructureEncryptionEnabledAudit` | `string` |  Effect value for 'Storage accounts should have infrastructure encryption' policy. Allowed values: Audit, Deny, Disabled |
| `storageAccountKeysExpiredRestrict` | `string` |  Effect value for 'Storage account keys should not be expired' policy. Allowed values: Audit, Deny, Disabled |
| `storageAccountPrivateEndpointEnabledAudit` | `string` | Effect value for 'Storage accounts should use private link' policy. Allowed values: AuditIfNotExists, Disabled | 
| `storageAccountSasPolicyRestrict` | `string` |  Effect value for 'Storage accounts should have shared access signature (SAS) policies configured' policy. Allowed values: Audit, Deny, Disabled |
| `storageEncryptionScopesShouldUseDoubleEncryptionAudit` | `string` |  Effect value for 'Storage account encryption scopes should use double encryption for data at rest' policy. Allowed values: Audit, Deny, Disabled |
| `storageQueueCustomerManagedKeyEnabledAudit` | `string` |  Effect value for 'Storage account encryption scopes should use customer-managed keys to encrypt data at rest' policy. Allowed values: Audit, Deny, Disabled |
| `storageSyncIncomingTrafficPolicyAuditDeny` | `string` |  Effect value for 'Public network access should be disabled for Azure File Sync' policy. Allowed values: Audit, Deny, Disabled |
| `storageSyncPrivateDnsZoneAuditIfNotExists` | `string` |  Effect value for 'Configure Azure File Sync to use private DNS zones' policy. Allowed values: AuditIfNotExists, Disabled |
| `storageSyncPrivateEndpointAuditIfNotExists` | `string` |  Effect value for 'Azure File Sync should use private link' policy. Allowed values: AuditIfNotExists, Disabled |
| `storageTableCustomerManagedKeyEnabledAudit` | `string` |  Effect value for 'Table Storage should use customer-managed key for encryption' policy. Allowed values: Audit, Deny, Disabled |
| `storageEncryptionScopesShouldUseCmkAudit` | `string` |  Effect value for 'Storage account encryption scopes should use customer-managed keys to encrypt data at rest' policy. Allowed values: Audit, Deny, Disabled |
| `virtualNetworkServiceEndpointStorageAccountAudit` | `string` | Effect value for 'Storage Accounts should use a virtual network service endpoint' policy. Allowed values: Audit, Deny, Disabled | 


## Module Outputs
None.


## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storageAccountSettings": {
            "value": {
                "allowedStorageSkusAudit": "Audit",
                "auditForClassicStorage": "Audit",
                "geoRedundantStorageAccountsAudit": "Audit",
                "storageAccountAllowCrossTenantReplicationAudit": "Audit",
                "storageAccountAllowSharedKeyAccessAudit": "Audit",
                "storageAccountInfrastructureEncryptionEnabledAudit": "Audit",
                "storageAccountKeysExpiredRestrict": "Audit",
                "storageAccountPrivateEndpointEnabledAudit": "AuditIfNotExists",
                "storageAccountListOfAllowedSkus": [
                    "Standard_LRS"
                ],
                "storageAccountSasPolicyRestrict": "Audit",
                "storageEncryptionScopesShouldUseDoubleEncryptionAudit": "Audit",
                "storageQueueCustomerManagedKeyEnabledAudit": "Audit",
                "storageSyncIncomingTrafficPolicyAuditDeny": "Audit",
                "storageSyncPrivateDnsZoneAuditIfNotExists": "Audit",
                "storageSyncPrivateEndpointAuditIfNotExists": "AuditIfNotExists",
                "storageTableCustomerManagedKeyEnabledAudit": "Audit",
                "storageEncryptionScopesShouldUseCmkAudit": "Audit",
                "virtualNetworkServiceEndpointStorageAccountAudit": "Audit"
            }
        },
        "storageAccountAuditDenySetName": {
            "value": "storageaccount.auditdeny.policy.set"
        },
        "storageAccountAuditDenySetDisplayName": {
            "value": "Storage account auditdeny policy set"
        },
        "storageAccountAuditDenySetAssignmentName": {
            "value": "storageaccount.auditdeny.policy.set.assignment"
        },
        "storageAccountAuditDenySetAssignmentDisplayName": {
            "value": "storage account auditdeny policy set assignment"
        }
        ,
        "storageAccountFilesyncprivatednszoneDefName": {
            "value": "storageaccount.filesyncprivatednszone.auditdeny.policy.def"
        }
        ,
        "storageAccountFilesyncprivatednszoneDefDisplayName": {
            "value": "Storage account azure file sync auditdeny policy definition"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        }
    }
}
```
