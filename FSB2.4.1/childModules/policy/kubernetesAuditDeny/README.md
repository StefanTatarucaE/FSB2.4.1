# policy/kubernetesAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy set definition grouping 17 built-in policy definitions & 1 policy assignment.
This policy configures governance and security policies for the Azure Kubernetes. Azure policy set has below built-in policies :

- Authorized IP ranges should be defined on Kubernetes Services.
- Azure Kubernetes Service Clusters should have local authentication methods disabled.
- Kubernetes cluster containers CPU and memory resource limits should not exceed the specified limits.
- Kubernetes cluster containers should not share host process ID or host IPC namespace.
- Kubernetes cluster containers should only use allowed capabilities.
- Kubernetes cluster containers should only use allowed images.
- Kubernetes cluster containers should run with a read only root file system.
- Kubernetes cluster pods and containers should only run with approved user and group IDs.
- Kubernetes cluster pods should only use approved host network and port range.
- Kubernetes cluster services should listen only on allowed ports.
- Kubernetes cluster services should only use allowed external IPs.
- Kubernetes clusters should be accessible only over HTTPS.
- Kubernetes Services should be upgraded to a non-vulnerable Kubernetes version.
- Resource logs in Azure Kubernetes Service should be enabled.
- Role-Based Access Control (RBAC) should be used on Kubernetes Services.
- Running container images should have vulnerability findings resolved.
- Temp disks and cache for agent node pools in Azure Kubernetes Service clusters should be encrypted at host.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/kubernetesAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
        kubernetesSettings : [
            authorizedIpRangesEffect : 'Audit'
            disableLocalAuthenticationEffect : 'Audit'
            clusterCpuMemoryLimitNotExceedEffect : 'Audit'
            excludedNamespaces : [
                'kube-system'
                'gatekeeper-system'
                'azure-arc'
            ]
            namespaces: []
            labelSelector: []
            cpuLimit: '200m'
            memoryLimit: '1Gi'
            excludedContainers: []
            containerNotShareProcessIdEffect: 'Audit'
            containerAllowCapabilityEffect: 'Audit'
            allowedCapabilities: []
            requiredDropCapabilities: []
            containerAllowImageEffect: 'Audit'
            allowedContainerImagesRegex: 'Audit'
            containerRunReadOnlyRootFileEffect: 'Audit'
            podRunApprovedUserGroupEffect: 'Audit'
            runAsUserRule: 'MustRunAsNonRoot'
            runAsUserRanges:  [ 
                ranges: [] 
            ]
            runAsGroupRule: 'RunAsAny'
            runAsGroupRanges: [
                  ranges: [] 
            ]
            supplementalGroupsRule: 'RunAsAny'
            supplementalGroupsRanges: [
                  ranges: [] 
            ]
            fsGroupRule: 'RunAsAny'
            fsGroupRanges: [
                  ranges: [] 
            ]
            podsUseApprovedHostNetworkPortRangeEffect: 'Audit'
            allowHostNetwork: false
            minPort: 0
            maxPort: 0
            podsListenOnlyAllowedPortEffect: 'Audit'
            allowedServicePortsList: [
                    '443'
                    '80'
                ]
            allowedExternalIpsEffect: 'Audit'
            allowedExternalIps: {
                value: []
            }
            accessibleOnlyOverHttpsEffect: 'Audit'
            clusterShouldNotGrantCapSysAdminEffect: 'Audit'
            upgradeNonVulnerableKubernetesVersionEffect: 'Audit'
            resourceLogEnabledEffect: 'AuditIfNotExists'
            requiredRetentionDays: '365'
            rbacShouldUsedEffect: 'Audit'
            vulnerabilityFindingsResolvedEffect: 'AuditIfNotExists'
            tempDiskAndCacheShouldEncryptedAtHostEffect: 'Audit'
        ]
        kubernetesAuditDenySetName: 'kubernetes.auditdeny.policy.set'
        kubernetesAuditDenySetDisplayName: 'Kubernetes auditdeny policy set'
        kubernetesAuditDenySetAssignmentName: 'kubernetes.auditdeny.policy.set.assignment'
        kubernetesAuditDenySetAssignmentDisplayName: 'Kubernetes auditdeny policy set assignment'
        policyMetadata : 'EvidenELZ'
    }
  } 
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `kubernetesSettings` | `object` | true | Object which sets the values of the policy set definition parameters. The specific parameters & what they are for, are described in the `policySetDefinition` resource block. Additional Details [here](#object---kubernetessettings).|
| `kubernetesAuditDenySetName` | `string` | true | String which hold the value of the policy set name for audit/deny kubernetes services initiative. |
| `kubernetesAuditDenySetDisplayName` | `string` | true | String which hold the value of the policy set display name for audit/deny kubernetes services initiative. |
| `kubernetesAuditDenySetAssignmentName` | `string` | true | String which hold the value of the policy assignment name for audit/deny kubernetes services. |
| `kubernetesAuditDenySetAssignmentDisplayName` | `string` | true | String which hold the value of the policy assignment display name for audit/deny kubernetes services. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

### Object - kubernetesSettings
| Name | Type | Description |
| --- | --- | --- |
| `authorizedIpRangesEffect` | `string` | Kubernetes service (AKS) should be installed and enabled on clusters. Allowed Values: Audit; Disabled. |
| `disableLocalAuthenticationEffect` | `string` | Disabling local authentication methods improves security by ensuring that Azure Kubernetes Service Clusters should exclusively require Azure Active Directory identities for authentication. Allowed Values: Audit, Deny, Disabled. |
| `clusterCpuMemoryLimitNotExceedEffect` | `string` | Enforce container CPU and memory resource limits to prevent resource exhaustion attacks in a Kubernetes cluster. This policy is generally available for Kubernetes Service (AKS), and preview for AKS Engine and Azure Arc enabled Kubernetes. For more information, see https://aka.ms/kubepolicydoc. Allowed Values:  Audit, Deny, Disabled. |
| `namespaces` | `string` | Namespaces to be excluded. Default Value kube-system; gatekeeper-system; azure-arc  |
| `labelSelector` | `Object` | Label query to select Kubernetes resources for policy evaluation. An empty label selector matches all Kubernetes resources. |
| `cpuLimit` | `string` | Max allowed CPU units. |
| `memoryLimit` | `string` | Max allowed memory bytes. |
| `excludedContainers` | `array` | Containers exclusions. |
| `containerNotShareProcessIdEffect` | `string` | Kubernetes cluster containers should not share host process ID or host IPC namespace. Allowed Values: Audit, Deny, Disabled. |
| `containerAllowCapabilityEffect` | `string` | Containers should only use allowed capabilities. Allowed Values: Audit, Deny, Disabled. |
| `allowedCapabilities` | `array` | The list of capabilities that are allowed to be added to a container. Provide empty list as input to block everything.|
| `requiredDropCapabilities` | `array` | The list of capabilities that must be dropped by a container. |
| `containerAllowImageEffect` | `string` | Containers should only use allowed images. Allowed Values: Audit, Deny, Disabled. |
| `allowedContainerImagesRegex` | `string` | The RegEx rule used to match allowed container image field in a Kubernetes cluster. For example, to allow any Azure Container Registry image by matching partial path: ^[^\\/]+\\.azurecr\\.io\\/.+$ and for multiple registries: ^([^\\/]+\\.azurecr\\.io|registry\\.io)\\/.+$. |
| `containerRunReadOnlyRootFileEffect` | `string` | Kubernetes cluster containers should run with a read only root file system. Allowed Values: Audit, Deny, Disabled. |
| `podRunApprovedUserGroupEffect` | `string` | Kubernetes cluster containers should run with a read only root file system. Allowed Values: Audit, Deny, Disabled. |
| `runAsUserRule` | `string` | The \'RunAsUser\' rule that containers are allowed to run with. MustRunAs requires at least one range to be specified. MustRunAsNonRoot requires the pod be submitted with non-zero runAsUser or have USER directive defined (using a numeric UID) in the image. RunAsAny allows any runAsUser to be specified. DefaultValue: 'MustRunAsNonRoot'|
| `runAsUserRanges` | `object` | The user ID ranges that are allowed for containers to use. To disallow all user ID ranges, provide an empty list like this (incl. curly brackets): { \'ranges\': [] }.|
| `runAsGroupRule` | `string` | The \'RunAsGroup\' rule that containers are allowed to run with. MustRunAs requires at least one range to be specified. MayRunAs does not require that \'RunAsGroup\' be specified. RunAsAny allows any. DefaultValue: 'RunAsAny'|
| `runAsGroupRanges` | `object` | The group ID ranges that are allowed for containers to use. Set 'max' as '-1' to skip max limit evaluation. Empty array blocks every defined value for 'MustRunAs' and 'MayRunAs'.".|
| `supplementalGroupsRule` | `string` | The \'SupplementalGroups\' rule that containers are allowed to run with. MustRunAs requires at least one range to be specified. MayRunAs does not require that \'SupplementalGroups\' be specified. RunAsAny allows any. DefaultValue: 'RunAsAny'|
| `supplementalGroupsRanges` | `object` | The supplemental group ID ranges that are allowed for containers to use. To disallow all supplemental group ID ranges, provide an empty list like this (incl. curly brackets): { \'ranges\': [] }|
| `fsGroupRule` | `string` | The \'FSGroup\' rule that containers are allowed to run with. MustRunAs requires at least one range to be specified. MayRunAs does not require that \'FSGroup\' be specified. RunAsAny allows any. DefaultValue: 'RunAsAny'|
| `fsGroupRanges` | `object` | The file system group ranges that are allowed for pods to use. To disallow all file system group ranges, provide an empty list like this (incl. the curly brackets): { \'ranges\': [] } |
| `podsUseApprovedHostNetworkPortRangeEffect` | `string` | Kubernetes cluster services should listen only on allowed ports. Allowed Values: Audit, Deny, Disabled. |
| `allowHostNetwork` | `bool` | Set this value to true if pod is allowed to use host network otherwise false. |
| `minPort` | `int` | The minimum value in the allowable host port range that pods can use in the host network namespace. |
| `maxPort` | `int` | The maximum value in the allowable host port range that pods can use in the host network namespace. |
| `podsListenOnlyAllowedPortEffect` | `string` | Container registries should have local authentication methods disabled. Allowed Values: Audit, Deny, Disabled. |
| `allowedServicePortsList` | `string[]` | The list of service ports allowed in a Kubernetes cluster. Array only accepts strings. Example: [\'443\', \'80\']. DefaultValue: ['443' , '80'].|
| `allowedExternalIpsEffect` | `string` | Kubernetes cluster services should only use allowed external IPs. Allowed Values: Audit, Deny, Disabled. |
| `allowedExternalIps` | `string[]` | List of External IPs that services are allowed to use. Empty array [] means all external IPs are disallowed. |
| `accessibleOnlyOverHttpsEffect` | `string` | Kubernetes clusters should be accessible only over HTTPS. Allowed Values: Audit, Deny, Disabled. |
| `upgradeNonVulnerableKubernetesVersionEffect` | `string` | Kubernetes Services should be upgraded to a non-vulnerable Kubernetes version. Allowed Values: Audit,  Disabled. |
| `resourceLogEnabledEffect` | `string` | Resource logs in Azure Kubernetes Service should be enabled Allowed Values: AuditIfNotExists, Disabled. |
| `requiredRetentionDays` | `string` | The required resource logs retention (in days). |
| `rbacShouldUsedEffect` | `string` | Role-Based Access Control (RBAC) should be used on Kubernetes Services. Allowed Values: Audit, Disabled. |
| `vulnerabilityFindingsResolvedEffect` | `string` | Running container images should have vulnerability findings resolved. Allowed Values: AuditIfNotExists, Disabled. |
| `tempDiskAndCacheShouldEncryptedAtHostEffect` | `string` | Temp disks and cache for agent node pools in Azure Kubernetes Service clusters should be encrypted at host. Allowed Values: Audit, Deny, Disabled. |

## Module Outputs
None.

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "kubernetesSettings": {
            "value": {
                "authorizedIpRangesEffect": "Audit",
                "disableLocalAuthenticationEffect": "Audit",
                "clusterCpuMemoryLimitNotExceedEffect": "Audit",
                "excludedNamespaces": [
                    "kube-system",
                    "gatekeeper-system",
                    "azure-arc"
                ],
                "namespaces": [],
                "labelSelector": {},
                "cpuLimit": "200m",
                "memoryLimit": "1Gi",
                "excludedContainers": [],
                "containerNotShareProcessIdEffect": "Audit",
                "containerAllowCapabilityEffect": "Audit",
                "allowedCapabilities": [],
                "requiredDropCapabilities": [],
                "containerAllowImageEffect": "Audit",
                "allowedContainerImagesRegex": "Audit",
                "containerRunReadOnlyRootFileEffect": "Audit",
                "podRunApprovedUserGroupEffect": "Audit",
                "runAsUserRule": "MustRunAsNonRoot",
                "runAsUserRanges": {
                    "ranges": []
                },
                "runAsGroupRule": "RunAsAny",
                "runAsGroupRanges": {
                    "ranges": []
                },
                "supplementalGroupsRule": "RunAsAny",
                "supplementalGroupsRanges": {
                    "ranges": []
                },
                "fsGroupRule": "RunAsAny",
                "fsGroupRanges": {
                    "ranges": []
                },
                "podsUseApprovedHostNetworkPortRangeEffect": "Audit",
                "allowHostNetwork": false,
                "minPort": 0,
                "maxPort": 0,
                "podsListenOnlyAllowedPortEffect": "Audit",
                "allowedServicePortsList": [
                    "443",
                    "80"
                ],
                "allowedExternalIpsEffect": "Audit",
                "allowedExternalIps": [],
                "accessibleOnlyOverHttpsEffect": "Audit",
                "clusterShouldNotGrantCapSysAdminEffect": "Audit",
                "upgradeNonVulnerableKubernetesVersionEffect": "Audit",
                "resourceLogEnabledEffect": "AuditIfNotExists",
                "requiredRetentionDays": "365",
                "rbacShouldUsedEffect": "Audit",
                "vulnerabilityFindingsResolvedEffect": "AuditIfNotExists",
                "tempDiskAndCacheShouldEncryptedAtHostEffect": "Audit"
            }
        },
        "kubernetesAuditDenySetName": {
            "value": "kubernetes.auditdeny.policy.set"
        },
        "kubernetesAuditDenySetDisplayName": {
            "value": "Kubernetes auditdeny policy set"
        },
        "kubernetesAuditDenySetAssignmentName": {
            "value": "kubernetes.auditdeny.policy.set.assignment"
        },
        "kubernetesAuditDenySetAssignmentDisplayName": {
            "value": "Kubernetes auditdeny policy set assignment"
        }
    }
}
```