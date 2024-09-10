# Exemption Parent module
Azure Bicep parent module to create the ASB, ISO, CIS exemtpions for the Eviden Landingzones for Azure solution.

## Description
This parent module calls the exemption child module(s) for creating ASB, ISO, CIS exemptions for the ELZ resources.

The following resources are created:

 - Exemptions for the Bootstrap solution.
 - Exemptions for the Networking solution.
 - Exemptions for the Virtual Wan solution.
 - Exemptions for the Metering solution.
 - Exemptions for the Reporting solution.
 - Exemptions for the Itsm solution.
 - Exemptions for the Compute Gallery solution.
 - Exemptions for the Os Tagging solution.
 - Exemptions for the Management subscription.
 - Exemptions for the Connectivity subscription.

Note: Exemptions for specific solutions are driven by booleans.

## Parent module overview
The parent module has been configured as follows:
1. First the output of the naming module is loaded via variables.
2. The exemptions for each solution are loaded as a json next.
3. The exemptions for each solution are defined next.

### Parent module parameters

Required parameters

| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `subscriptionType` | `string` | Specify the type of subscription using abbreviation. Can be 'mgmt', 'cnty'. To be provided by the pipeline |
| `deployVwan` | `string` | Parameter to determine if vwan or usual hub spoke network is deployed. To be provided by the pipeline |

## ELZ Azure Configuration Values

The exemption parent module has no specific configuration values. The subscriptionType parameter should be provided by the pipeline and is not offered via the input parameters.

## Example parameters file

The parameters will be provided by the pipeline.

## Child modules parameters
For a full list of all available parameters and variables, please refer to the child module readme files and the bicep files.

# Exemptions

Important notes:

* Due to technical limitations the exemptions are set on the resourcegroup and not on the resource. The resourcename is still loaded from the naming file because it is used in the displayname and description of an exemption. This to make clear for which resource in the resourcegroup the exemption was created.
* A policy can only be exempted once on a resourcegroup. In the case of two resources with the same policies to exempt in the same resourcegroup we need to supply both resourcenames as a value. This is an edge case for ITSM where two functionapps and two storage accounts are created with the same exemptions/incompliancies. In effect the the first module call will create the exemptions on the resourcegroup, while the second call merely updates the exemption created in the first call. We add both blocks to keep an overview for which resource an exemption is being created on the resourcegroup.

Example resourceName: '${itsmFunctionApp} & ${itsmPwshFunctionApp}':

```
module cisItsmFunctionApp '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.itsmSolution.deployExemptionsForItsm ==  && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(itsmResourceGroup)
  name: 'cisExemptionDeploy-${itsmFunctionApp}'
  params: {
    exemptionCategory: exemptions.itsmSolution.cisItsmFunctionApp.category
    addTime: exemptions.itsmSolution.cisItsmFunctionApp.addTime
    resourceName: '${itsmFunctionApp} & ${itsmPwshFunctionApp}'
    policyAssignmentShortcode: exemptions.itsmSolution.cisItsmFunctionApp.shortCode
    policyAssignmentId: exemptions.itsmSolution.cisItsmFunctionApp.shortCode == 'asb' ? asbInitiative : exemptions.itsmSolution.cisItsmFunctionApp.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.itsmSolution.cisItsmFunctionApp.policyDefinitionReferenceIds
  }
}

module cisItsmPwshFunctionApp '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.itsmSolution.deployExemptionsForItsm == true && (subscriptionType == 'mgmt')) {
  scope: resourceGroup(itsmResourceGroup)
  name: 'cisExemptionDeploy-${itsmPwshFunctionApp}'
  params: {
    exemptionCategory: exemptions.itsmSolution.cisItsmPwshFunctionApp.category
    addTime: exemptions.itsmSolution.cisItsmPwshFunctionApp.addTime
    resourceName: '${itsmFunctionApp} & ${itsmPwshFunctionApp}'
    policyAssignmentShortcode: exemptions.itsmSolution.cisItsmPwshFunctionApp.shortCode
    policyAssignmentId: exemptions.itsmSolution.cisItsmPwshFunctionApp.shortCode == 'asb' ? asbInitiative : exemptions.itsmSolution.cisItsmPwshFunctionApp.shortCode == 'iso' ? isoInitiative : cisInitiative
    policyDefinitionReferenceIds: exemptions.itsmSolution.cisItsmPwshFunctionApp.policyDefinitionReferenceIds
  }
}
```

### Example Exemption json file

The exemptions (exemptions.json) are loaded via a json file.

For a full list of all available parameters and variables, please refer to the child module readme files and the bicep files. Only the item used for the parent module is described below.

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `deployExemptionsForBootstrap` | `boolean` | true | include or exclude exemptions for a certain solution |

The deployExemptionsFor... in the exemptions.json is used in combination with the subscriptionType parameter to conditionally deploy exemptions for a particular solution in a particular subscription.

```
module cisItsmPwshFunctionApp '../../childModules/rgPolicyExemption/rgPolicyExemption.bicep' = if (exemptions.itsmSolution.deployExemptionsForItsm == true && (subscriptionType == 'mgmt'))
```

Example exemptions.json file.

```
    {
        "bootstrapSolution": {
            "deployExemptionsForBootstrap": true,
            "cisArtifactStorageAccount": {
                "category": "Waiver",
                "exemptionDuration": "P180D",
                "shortCode": "cis",
                "policyDefinitionReferenceIds": [
                    "6fac406b-40ca-413b-bf8e-0bf964659c25",
                    "2a1a9cdf-e04d-429a-8416-3bfb72a1b26f",
                    "34c877ad-507e-4c82-993e-3452a6e0ad3c"
                ]
            },
            "isoArtifactStorageAccount": {
                "category": "Waiver",
                "exemptionDuration": "P180D",
                "shortCode": "iso",
                "policyDefinitionReferenceIds": [
                    "AuditUnrestrictedNetworkAccessToStorageAccounts"
                ]
            },
            "asbArtifactStorageAccount": {
                "category": "Waiver",
                "exemptionDuration": "P180D",
                "shortCode": "asb",
                "policyDefinitionReferenceIds": [
                    "storageAccountShouldUseAPrivateLinkConnectionMonitoringEffect",
                    "storageAccountsShouldRestrictNetworkAccessUsingVirtualNetworkRulesMonitoringEffect"
                ]
            }
        },
        "reportingSolution": {
            "deployExemptionsForReporting": true,
            "cisReportingStorageAccount": {
                "category": "Waiver",
                "exemptionDuration": "P180D",
                "shortCode": "cis",
                "policyDefinitionReferenceIds": [
                    "34c877ad-507e-4c82-993e-3452a6e0ad3c",
                    "2a1a9cdf-e04d-429a-8416-3bfb72a1b26f",
                    "6fac406b-40ca-413b-bf8e-0bf964659c25",
                    "4fa4b6c0-31ca-4c0d-b10d-24b96f62a751"
                ]
            },
            "isoReportingStorageAccount": {
                "category": "Waiver",
                "exemptionDuration": "P180D",
                "shortCode": "iso",
                "policyDefinitionReferenceIds": [
                    "AuditUnrestrictedNetworkAccessToStorageAccounts"
                ]
            },
            "asbReportingStorageAccount": {
                "category": "Waiver",
                "exemptionDuration": "P180D",
                "shortCode": "asb",
                "policyDefinitionReferenceIds": [
                    "storageAccountsShouldRestrictNetworkAccessUsingVirtualNetworkRulesMonitoringEffect",
                    "storageAccountShouldUseAPrivateLinkConnectionMonitoringEffect",
                    "StorageDisallowPublicAccess"
                ]
            }
        }
    }

```

## Current exemptions within ELZ.

### Exemptions in the bootstrap solution.

| Policy | Initiative | Resourcegroup | Resource |
| --- | --- | --- | --- |
| Storage accounts should restrict network access | CIS | artifactResourceGroup | artifactStorageAccount |
| Storage accounts should restrict network access using virtual network rules | CIS | artifactResourceGroup | artifactStorageAccount |
| Storage accounts should use customer-managed key for encryption | CIS | artifactResourceGroup | artifactStorageAccount |
|Storage accounts should restrict network access | ISO | artifactResourceGroup | artifactStorageAccount |
| Storage accounts should use private link | ASB | artifactResourceGroup | artifactStorageAccount |
| Storage accounts should restrict network access using virtual network rules | ASB | artifactResourceGroup | artifactStorageAccount |

### Exemptions in the networking solution.

| Policy | Initiative | Resourcegroup | Resource |
| --- | --- | --- | --- |
| Azure DDoS Protection Standard should be enabled | ASB | hubResourceGroup | connectivityHubNetworkVnet |
| Flow logs should be configured for every network security group | CIS | hubResourceGroup | connectivityHubVnetSubNetNsg - Bastion |
| Flow logs should be configured for every network security group | CIS | hubResourceGroup | connectivityHubVnetSubNetNsg - Hub Network |
| Flow logs should be configured for every virtual network | CIS | hubResourceGroup | connectivityHubNetworkVnet |
| Azure Key Vault should use RBAC permission model | CIS | hubResourceGroup | tlsKeyvault |

### Exemptions in the Virtual Wan solution.

| Policy | Initiative | Resourcegroup | Resource |
| --- | --- | --- | --- |
| Azure DDoS Protection Standard should be enabled | ASB | sharedConnectivityNetworkResourcesResourceGroup | sharedConnectivityHubNetworkVnet |
| Flow logs should be configured for every network security group | CIS | sharedConnectivityNetworkResourcesResourceGroup | connectivityHubVnetSubNetNsg - Bastion Subnet |
| Flow logs should be configured for every virtual network | CIS | sharedConnectivityNetworkResourcesResourceGroup | sharedConnectivityHubNetworkVnet |
| Azure Key Vault should use RBAC permission model | CIS | connectivityVirtualWanResourceGroup | tlsKeyvault |

### Exemptions in the reporting solution.

| Policy | Initiative | Resourcegroup | Resource |
| --- | --- | --- | --- |
| Storage accounts should restrict network access | CIS | reportResourceGroup | reportingStorageAccount |
| Storage accounts should restrict network access using virtual network rules | CIS | reportResourceGroup | reportingStorageAccount |
| Storage accounts should use customer-managed key for encryption | CIS | reportResourceGroup | reportingStorageAccount |
| Storage account public access should be disallowed | CIS | reportResourceGroup | reportingStorageAccount |
| Storage accounts should restrict network access using virtual network rules | ASB | reportResourceGroup | reportingStorageAccount |
| Storage accounts should use private link | ASB | reportResourceGroup | reportingStorageAccount |
| Storage account public access should be disallowed | ASB | reportResourceGroup | reportingStorageAccount |
| Storage accounts should restrict network access | ISO | reportResourceGroup | reportingStorageAccount |

### Exemptions in the metering solution.

| Policy | Initiative | Resourcegroup | Resource |
| --- | --- | --- | --- |
| Function apps should have authentication enabled | CIS | billingResourceGroup | billingAppService |
| Function apps should have 'Client Certificates (Incoming client certificates)' enabled | CIS | billingResourceGroup | billingAppService |
| Storage accounts should use customer-managed key for encryption | CIS | billingResourceGroup | billingStorageAccount |
| Storage accounts should restrict network access | CIS | billingResourceGroup | billingStorageAccount |
| Storage accounts should restrict network access using virtual network rules | CIS | billingResourceGroup | billingStorageAccount |
| Key Vault secrets should have an expiration date | CIS | billingResourceGroup | billingKeyVault |
| Azure Key Vault should use RBAC permission model | CIS | billingResourceGroup | billingKeyVault |
| Function apps that use Python should use the latest 'Python version' | ASB | billingResourceGroup | billingAppService |
| Function apps should have 'Client Certificates (Incoming client certificates)' enabled | ASB | billingResourceGroup | billingAppService |
| Storage accounts should restrict network access using virtual network rules | ASB | billingResourceGroup | billingStorageAccount |
| Storage accounts should use private link | ASB | billingResourceGroup | billingStorageAccount |
| Private endpoint should be configured for Key Vault | ASB | billingResourceGroup | billingStorageAccount |
| Azure Key Vault should have firewall enabled | ASB | billingResourceGroup | billingKeyVault |
| Storage accounts should restrict network access | ISO | billingResourceGroup | billingStorageAccount |

### Exemptions in the ITSM solution.

| Policy | Initiative | Resourcegroup | Resource |
| --- | --- | --- | --- |
| Storage accounts should restrict network access | CIS | itsmResourceGroup | ItsmPwshStorageAccount |
| Storage accounts should restrict network access using virtual network rules | CIS | itsmResourceGroup | ItsmPwshStorageAccount |
| Storage accounts should use customer-managed key for encryption | CIS | itsmResourceGroup | ItsmPwshStorageAccount |
| Function apps should have 'Client Certificates (Incoming client certificates)' enabled | CIS | itsmResourceGroup | ItsmPwshFunctionApp |
| Function apps should have authentication enabled | CIS | itsmResourceGroup | ItsmPwshFunctionApp |
| Key Vault secrets should have an expiration date | CIS | itsmResourceGroup | ItsmKeyVault |
| Azure Key Vault should use RBAC permission model | CIS | itsmResourceGroup | ItsmKeyVault |
| Storage accounts should restrict network access | ISO | itsmResourceGroup | ItsmPwshStorageAccount |
| Private endpoint should be configured for Key Vault | ASB | itsmResourceGroup | ItsmKeyVault |
| Azure Key Vault should have firewall enabled | ASB | itsmResourceGroup | ItsmKeyVault |
| Storage accounts should restrict network access using virtual network rules | ASB | itsmResourceGroup | ItsmPwshStorageAccount |
| Storage accounts should use private link | ASB | itsmResourceGroup | ItsmPwshStorageAccount |
| Function apps should have 'Client Certificates (Incoming client certificates)' enabled | ASB | itsmResourceGroup | ItsmPwshFunctionApp |
| Function apps that use Python should use the latest 'Python version' | ASB | itsmResourceGroup | ItsmPwshFunctionApp |

### Exemptions in the compute gallery solution.

| Policy | Initiative | Resourcegroup | Resource |
| --- | --- | --- | --- |
| Storage accounts should use customer-managed key for encryption | CIS | computeGalleryResourceGroup | computeGalleryStorageAccount |
| Storage accounts should restrict network access using virtual network rules | CIS | computeGalleryResourceGroup | computeGalleryStorageAccount |
| Storage accounts should restrict network access | CIS | computeGalleryResourceGroup | computeGalleryStorageAccount |
| Storage accounts should restrict network access using virtual network rules | ASB | computeGalleryResourceGroup | computeGalleryStorageAccount |
| Storage accounts should use private links | ASB | computeGalleryResourceGroup | computeGalleryStorageAccount |
| Storage accounts should restrict network access | ISO | computeGalleryResourceGroup | computeGalleryStorageAccount |

### Exemptions in the os tagging solution.

| Policy | Initiative | Resourcegroup | Resource |
| --- | --- | --- | --- |
| Storage accounts should use customer-managed key for encryption | CIS | osTaggingFunctionAppResourceGroup | osTaggingStorageAccount |
| Storage accounts should restrict network access using virtual network rules | CIS | osTaggingFunctionAppResourceGroup | osTaggingStorageAccount |
| Storage accounts should restrict network access | CIS | osTaggingFunctionAppResourceGroup | osTaggingStorageAccount |
| Function apps should have 'Client Certificates (Incoming client certificates)' enabled | CIS | osTaggingFunctionAppResourceGroup | osTaggingAppServicePlan |
| Function apps should have authentication enabled | CIS | osTaggingFunctionAppResourceGroup | osTaggingAppServicePlan |
| Storage accounts should use private link | ASB | osTaggingFunctionAppResourceGroup | osTaggingStorageAccount |
| Storage accounts should restrict network access using virtual network rules | ASB | osTaggingFunctionAppResourceGroup | osTaggingStorageAccount |
| Function apps should have 'Client Certificates (Incoming client certificates)' enabled | ASB | osTaggingFunctionAppResourceGroup | osTaggingAppServicePlan |
| Storage accounts should restrict network access | ISO | osTaggingFunctionAppResourceGroup | osTaggingStorageAccount |

### Exemptions for the management subscription.

Note: added referenceid for mgmt subscription exemptions because the displaynames for different policy reference id's within the initiative are the same.

| Policy | Initiative | ReferenceID | Subscription |
| --- | --- | --- | --- |
| An activity log alert should exist for specific Policy operations | CIS | c5447c04-a4d7-4ba8-a263-c9ee321a6858-0 | mgmt |
| An activity log alert should exist for specific Policy operations | CIS | c5447c04-a4d7-4ba8-a263-c9ee321a6858-1 | mgmt |
| An activity log alert should exist for specific Administrative operations | CIS | b954148f-4c11-4c38-8221-be76711e194a-0 | mgmt |
| An activity log alert should exist for specific Administrative operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-1 | mgmt |
| An activity log alert should exist for specific Administrative operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-2 | mgmt |
| An activity log alert should exist for specific Administrative operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-3 | mgmt ||
| An activity log alert should exist for specific Administrative operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-4 | mgmt |
| An activity log alert should exist for specific Administrative operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-5 | mgmt |
| An activity log alert should exist for specific Security operations | CIS |3b980d31-7904-4bb7-8575-5665739a8052-0 | mgmt |
| An activity log alert should exist for specific Security operations | CIS |3b980d31-7904-4bb7-8575-5665739a8052-1 | mgmt |
| An activity log alert should exist for specific Security operations | CIS |3b980d31-7904-4bb7-8575-5665739a8052-2 | mgmt |
| An activity log alert should exist for specific Security operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-9 | mgmt |
| An activity log alert should exist for specific Security operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-8 | mgmt |
| An activity log alert should exist for specific Security operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-7 | mgmt |
| An activity log alert should exist for specific Security operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-6 | mgmt |
| Auto provisioning of the Log Analytics agent should be enabled on your subscription | CIS | 475aae12-b88a-4572-8b36-9b712b2b3a17 | mgmt |
| Auto provisioning of the Log Analytics agent should be enabled on your subscription | ASB | autoProvisioningOfTheLogAnalyticsAgentShouldBeEnabled | mgmt |

### Exemptions for the connectivity subscription.

| Policy | Initiative | Subscription |
| --- | --- | --- |
| Auto provisioning of the Log Analytics agent should be enabled on your subscription | ASB | cnty |
| An activity log alert should exist for specific Policy operations | CIS | c5447c04-a4d7-4ba8-a263-c9ee321a6858-0 | cnty |
| An activity log alert should exist for specific Policy operations | CIS | c5447c04-a4d7-4ba8-a263-c9ee321a6858-1 | cnty |
| An activity log alert should exist for specific Administrative operations | CIS | b954148f-4c11-4c38-8221-be76711e194a-0 | cnty |
| An activity log alert should exist for specific Administrative operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-1 | cnty |
| An activity log alert should exist for specific Administrative operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-2 | cnty |
| An activity log alert should exist for specific Administrative operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-3 | cnty ||
| An activity log alert should exist for specific Administrative operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-4 | cnty |
| An activity log alert should exist for specific Administrative operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-5 | cnty |
| An activity log alert should exist for specific Security operations | CIS |3b980d31-7904-4bb7-8575-5665739a8052-0 | cnty |
| An activity log alert should exist for specific Security operations | CIS |3b980d31-7904-4bb7-8575-5665739a8052-1 | cnty |
| An activity log alert should exist for specific Security operations | CIS |3b980d31-7904-4bb7-8575-5665739a8052-2 | mgmt |
| An activity log alert should exist for specific Security operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-9 | mgmt |
| An activity log alert should exist for specific Security operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-8 | mgmt |
| An activity log alert should exist for specific Security operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-7 | mgmt |
| An activity log alert should exist for specific Security operations | CIS |b954148f-4c11-4c38-8221-be76711e194a-6 | mgmt |
| Auto provisioning of the Log Analytics agent should be enabled on your subscription | CIS | 475aae12-b88a-4572-8b36-9b712b2b3a17 | cnty |
| Auto provisioning of the Log Analytics agent should be enabled on your subscription | ASB | autoProvisioningOfTheLogAnalyticsAgentShouldBeEnabled | cnty|


## Outputs
