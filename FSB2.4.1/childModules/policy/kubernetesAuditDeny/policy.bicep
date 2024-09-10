/*
SUMMARY: Kubernetes Audit/Deny Policy child module.
DESCRIPTION: Deployment of Kubernetes Audit/Deny Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: abhijit.kakade@eviden.com
VERSION: 0.0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. ELZ Azure dont target Management groups.

// PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param kubernetesSettings object

@description('Specify policy set name for audit/deny kubernetes services initiative')
param  kubernetesAuditDenySetName string

@description('Specify policy set display name for audit/deny kubernetes services initiative')
param kubernetesAuditDenySetDisplayName string

@description('Specify policy assignment name for audit/deny kubernetes services')
param kubernetesAuditDenySetAssignmentName string

@description('Specify policy assignment display name for audit/deny kubernetes services')
param kubernetesAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variable for allowedValues which is the same for all policy set definition parameters.
var allowedValues = [
  'Audit'
  'AuditIfNotExists'
  'Deny'
  'Disabled'
]

// Allowed values for List of Kubernetes namespaces to exclude from policy evaluation.
var excludeNamespaces = [
  'kube-system'
  'gatekeeper-system'
  'azure-arc'
]

// Allowed values for runAsUserRule that containers are allowed to run with
var runAsUserRule = [
  'MustRunAs'
  'MustRunAsNonRoot'
  'RunAsAny'
]

// Allowed values of runAsGroupRule that containers are allowed to run with
var runAsGroupRule = [
  'MustRunAs'
  'MayRunAs'
  'RunAsAny'
]

//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This initiative configures governance and security policies to azure kubernetes services (AKS)'
  metadata: {
    category: 'Monitoring'
    source: policyMetadata
    version: '0.0.1'
  }
}

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that Azure kubernetes has relevant governance and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

// RESOURCE DEPLOYMENTS
//Deploy the policy definition set.
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: kubernetesAuditDenySetName
  properties: {
    displayName: kubernetesAuditDenySetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      authorizedIpRangesEffect: {
        type: 'String'
        defaultValue: 'Audit'
        metadata: {
          description: 'Kubernetes service (AKS) should be installed and enabled on clusters.'
          displayName: 'authorizedIpRangesEffect'
        }
        allowedValues: allowedValues
      }
      disableLocalAuthenticationEffect: {
        type: 'String'
        defaultValue: 'Audit'
        metadata: {
          description: 'Clusters should have local authentication methods disabled.'
          displayName: 'disableLocalAuthenticationEffect'
        }
        allowedValues: allowedValues
      }
      clusterCpuMemoryLimitNotExceedEffect: {
        type: 'String'
        defaultValue: 'Audit'
        metadata: {
          description: 'Containers CPU and memory resource limits should not exceed the specified limits.'
          displayName: 'cluserCpuMemoryLimitNotExceedEffect'
        }
        allowedValues: allowedValues
      }
      excludedNamespaces: {
        type: 'Array'
        defaultValue: excludeNamespaces
        metadata: {
          description: 'List of Kubernetes namespaces to exclude from policy evaluation. System namespaces \'kube-system\', \'gatekeeper-system\' and \'azure-arc\' are always excluded by design.'
          displayName: 'excludedNamespaces'
        }
      }
      namespaces: {
        type: 'Array'
        defaultValue: []
        metadata: {
          description: 'List of Kubernetes namespaces to only include in policy evaluation. An empty list [] means the policy is applied to all resources in all namespaces.'
          displayName: 'namespaces'
        }
      }
      labelSelector: {
        type: 'Object'
        defaultValue: {}
        metadata: {
          description: 'Label query to select Kubernetes resources for policy evaluation. An empty label selector {} matches all Kubernetes resources.'
          displayName: 'labelSelector'
        }
      }
      cpuLimit: {
        type: 'String'
        defaultValue: '200m'
        metadata: {
          description: 'The maximum CPU units allowed for a container. E.g. 200m. For more information, please refer https://aka.ms/k8s-policy-pod-limits.'
          displayName: 'cpuLimit'
        }
      }
      memoryLimit: {
        type: 'String'
        defaultValue: '1Gi'
        metadata: {
          description: 'The maximum memory bytes allowed for a container. E.g. 1Gi. For more information, please refer https://aka.ms/k8s-policy-pod-limits.'
          displayName: 'memoryLimit'
        }
      }
      excludedContainers: {
        type: 'Array'
        defaultValue: []
        metadata: {
          description: 'The list of InitContainers and Containers to exclude from readonly evaluation. It will not exclude the disallowed host path. The identify is the name of container. Use an empty list [] to apply this policy to all containers in all namespaces.'
          displayName: 'excludedContainers'
        }
      }
      containerNotShareProcessidEffect: {
        type: 'String'
        defaultValue: 'Audit'
        metadata: {
          description: 'Kubernetes cluster containers should not share host process ID or host IPC namespace.'
          displayName: 'containerNotShareProcessidEffect'
        }
        allowedValues: allowedValues
      }
      containerAllowCapabilityEffect: {
        type: 'String'
        defaultValue: 'Audit'
        metadata: {
          description: 'Containers should only use allowed capabilities.'
          displayName: 'containerAllowCapabilityEffect'
        }
        allowedValues: allowedValues
      }
      allowedCapabilities: {
        type: 'Array'
        defaultValue: []
        metadata: {
          description: 'The list of capabilities that are allowed to be added to a container. Provide empty list [] as input to block everything.'
          displayName: 'allowedCapabilities'
        }
      }
      requiredDropCapabilities: {
        type: 'Array'
        defaultValue: []
        metadata: {
          description: 'The list of capabilities that must be dropped by a container. Provide empty list [] as input to drop nothing.'
          displayName: 'requiredDropCapabilities'
        }
        allowedValues: allowedValues
      }
      containerAllowImageEffect: {
        type: 'String'
        defaultValue: 'Audit'
        metadata: {
          description: 'Containers should only use allowed images.'
          displayName: 'ContainerAllowImageEffect'
        }
        allowedValues: allowedValues
      }
      allowedContainerImagesRegex: {
        type: 'String'
        defaultValue: 'Example: ^[^\\/]+\\.azurecr\\.io\\/.+$'
        metadata: {
          description: 'The RegEx rule used to match allowed container image field in a Kubernetes cluster. For example, to allow any Azure Container Registry image by matching partial path: ^[^\\/]+\\.azurecr\\.io\\/.+$ and for multiple registries: ^([^\\/]+\\.azurecr\\.io|registry\\.io)\\/.+$.'
          displayName: 'allowedContainerImagesRegex'
        }
      }
      containerRunReadOnlyRootFileEffect: {
        type: 'String'
        defaultValue: 'Audit'
        metadata: {
          description: 'Kubernetes cluster containers should run with a read only root file system.'
          displayName: 'containerRunReadOnlyRootFileEffect'
        }
        allowedValues: allowedValues
      }
      podRunApprovedUsergroupEffect: {
        type: 'String'
        defaultValue: 'Audit'
        metadata: {
          description: 'Kubernetes cluster containers should run with a read only root file system.'
          displayName: 'podRunApprovedUsergroupEffect'
        }
        allowedValues: allowedValues
      }
      runAsUserRule: {
        type: 'String'
        defaultValue: 'MustRunAsNonRoot'
        metadata: {
          description: 'The \'RunAsUser\' rule that containers are allowed to run with. MustRunAs requires at least one range to be specified. MustRunAsNonRoot requires the pod be submitted with non-zero runAsUser or have USER directive defined (using a numeric UID) in the image. RunAsAny allows any runAsUser to be specified.'
          displayName: 'runAsUserRule'
        }
        allowedValues: runAsUserRule
      }
      runAsUserRanges: {
        type: 'Object'
        metadata: {
          description: 'The user ID ranges that are allowed for containers to use. To disallow all user ID ranges, provide an empty list like this (incl. curly brackets): { \'ranges\': [] }.'
          displayName: 'runAsUserRanges'
        }
      }
      runAsGroupRule: {
        type: 'String'
        defaultValue: 'RunAsAny'
        metadata: {
          description: 'The \'RunAsGroup\' rule that containers are allowed to run with. MustRunAs requires at least one range to be specified. MayRunAs does not require that \'RunAsGroup\' be specified. RunAsAny allows any.'
          displayName: 'runAsGroupRule'
        }
        allowedValues: runAsGroupRule
      }
      runAsGroupRanges: {
        type: 'object'
        metadata: {
          description: 'Allowed group ID ranges.'
          displayName: 'runAsGroupRanges'
        }
      }
      supplementalGroupsRule: {
        type: 'String'
        defaultValue: 'RunAsAny'
        metadata: {
          description: 'The \'SupplementalGroups\' rule that containers are allowed to run with. MustRunAs requires at least one range to be specified. MayRunAs does not require that \'SupplementalGroups\' be specified. RunAsAny allows any.'
          displayName: 'supplementalGroupsRule'
        }
        allowedValues: runAsGroupRule
      }
      supplementalGroupsRanges: {
        type: 'Object'
        metadata: {
          description: 'The supplemental group ID ranges that are allowed for containers to use. To disallow all supplemental group ID ranges, provide an empty list like this (incl. curly brackets): { \'ranges\': [] }'
          displayName: 'supplementalGroupsRule'
        }
      }
      fsGroupRule: {
        type: 'String'
        defaultValue: 'RunAsAny'
        metadata: {
          description: 'The \'FSGroup\' rule that containers are allowed to run with. MustRunAs requires at least one range to be specified. MayRunAs does not require that \'FSGroup\' be specified. RunAsAny allows any.'
          displayName: 'fsGroupRule'
        }
        allowedValues: runAsGroupRule
      }
      fsGroupRanges: {
        type: 'Object'
        metadata: {
          description: 'The file system group ranges that are allowed for pods to use. To disallow all file system group ranges, provide an empty list like this (incl. the curly brackets): { \'ranges\': [] }'
          displayName: 'fsGroupRanges'
        }
      }
      podsUseApprovedHostNetworkPortRangeEffect: {
        type: 'string'
        defaultValue: 'Audit'
        metadata: {
          description: 'Kubernetes cluster pods should only use approved host network and port range'
          displayName: 'podsUseApprovedHostNetworkPortRangeEffect'
        }
        allowedValues: allowedValues
      }
      allowHostNetwork: {
        type: 'Boolean'
        defaultValue: false
        metadata: {
          description: 'Set this value to true if pod is allowed to use host network otherwise false.'
          displayName: 'allowHostNetwork'
        }
      }
      minPort: {
        type: 'Integer'
        defaultValue: 0
        metadata: {
          description: 'The minimum value in the allowable host port range that pods can use in the host network namespace.'
          displayName: 'minPort'
        }
      }
      maxPort: {
        type: 'Integer'
        defaultValue: 0
        metadata: {
          description: 'The maximum value in the allowable host port range that pods can use in the host network namespace.'
          displayName: 'maxPort'
        }
      }
      podsListenOnlyAllowedPortEffect: {
        type: 'string'
        defaultValue: 'Audit'
        metadata: {
          description: 'Kubernetes cluster services should listen only on allowed ports'
          displayName: 'podsListenOnlyAllowedPortEffect'
        }
        allowedValues: allowedValues
      }
      allowedServicePortsList: {
        type: 'Array'
        defaultValue: ['443' , '80']
        metadata: {
          description: 'The list of service ports allowed in a Kubernetes cluster. Array only accepts strings. Example: [\'443\', \'80\']'
          displayName: 'allowedServicePortsList'
        }
      }
      allowedExternalIpsEffect: {
        type: 'string'
        defaultValue: 'Audit'
        metadata: {
          description: 'Kubernetes cluster services should only use allowed external IPs'
          displayName: 'allowedExternalIpsEffect'
        }
        allowedValues: allowedValues
      }
      allowedExternalIps: {
        type: 'Array'
        defaultValue: []
        metadata: {
          description: 'List of External IPs that services are allowed to use. Empty array [] means all external IPs are disallowed.'
          displayName: 'allowedExternalIps'
        }
      }
      accessibleOnlyOverHttpsEffect: {
        type: 'string'
        defaultValue: 'Audit'
        metadata: {
          description: 'Kubernetes clusters should be accessible only over HTTPS'
          displayName: 'accessibleOnlyOverHttpsEffect'
        }
        allowedValues: allowedValues
      }
      upgradeNonVulnerableKubernetesVersionEffect: {
        type: 'string'
        defaultValue: 'Audit'
        metadata: {
          description: 'Kubernetes Services should be upgraded to a non-vulnerable Kubernetes version'
          displayName: 'upgradeNonVulnerableKubernetesVersionEffect'
        }
        allowedValues: allowedValues
      }
      resourceLogEnabledEffect: {
        type: 'string'
        defaultValue: 'AuditIfNotExists'
        metadata: {
          description: 'Resource logs in Azure Kubernetes Service should be enabled'
          displayName: 'resourceLogEnabledEffect'
        }
        allowedValues: allowedValues
      }
      requiredRetentionDays: {
        type: 'string'
        defaultValue: '365'
        metadata: {
          description: 'The required resource logs retention (in days)'
          displayName: 'requiredRetentionDays'
        }
      }
      rbacShouldUsedEffect: {
        type: 'string'
        defaultValue: 'Audit'
        metadata: {
          description: 'Role-Based Access Control (RBAC) should be used on Kubernetes Services'
          displayName: 'rbacShouldUsedEffect'
        }
        allowedValues: allowedValues
      }
      vulnerabilityFindingsResolvedEffect: {
        type: 'string'
        defaultValue: 'AuditIfNotExists'
        metadata: {
          description: 'Running container images should have vulnerability findings resolved'
          displayName: 'vulnerabilityFindingsResolvedEffect'
        }
        allowedValues: allowedValues
      }
      tempDiskAndCacheShouldEncryptedAtHostEffect: {
        type: 'string'
        defaultValue: 'Audit'
        metadata: {
          description: 'Temp disks and cache for agent node pools in Azure Kubernetes Service clusters should be encrypted at host'
          displayName: 'tempDiskAndCacheShouldEncryptedAtHostEffect'
        }
        allowedValues: allowedValues
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0e246bcf-5f6f-4f87-bc6f-775d4712c7ea'
        parameters: {
          effect: {
            value: '[parameters(\'authorizedIpRangesEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/993c2fcd-2b29-49d2-9eb0-df2c3a730c32'
        parameters: {
          effect: {
            value: '[parameters(\'disableLocalAuthenticationEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e345eecc-fa47-480f-9e88-67dcc122b164'
        parameters: {
          effect: {
            value: '[parameters(\'clusterCpuMemoryLimitNotExceedEffect\')]'
          }
          excludedNamespaces :{
            value: '[parameters(\'excludedNamespaces\')]'
          }
          namespaces :{
            value: '[parameters(\'namespaces\')]'
          }
          labelSelector :{
            value: '[parameters(\'labelSelector\')]'
          }
          cpuLimit :{
            value: '[parameters(\'cpuLimit\')]'
          }
          memoryLimit :{
            value: '[parameters(\'memoryLimit\')]'
          }
          excludedContainers :{
            value: '[parameters(\'excludedContainers\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/47a1ee2f-2a2a-4576-bf2a-e0e36709c2b8'
        parameters: {
          effect : {
            value: '[parameters(\'containerNotShareProcessIdEffect\')]'
          }
          excludedNamespaces : {
            value: '[parameters(\'excludedNamespaces\')]'
          }
          namespaces : {
            value: '[parameters(\'namespaces\')]'
          }
          labelSelector : {
            value: '[parameters(\'labelSelector\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/c26596ff-4d70-4e6a-9a30-c2506bd2f80c'
        parameters: {
          effect: {
            value: '[parameters(\'containerAllowCapabilityEffect\')]'
          }
          excludedNamespaces: {
            value: '[parameters(\'excludedNamespaces\')]'
          }
          namespaces: {
            value: '[parameters(\'namespaces\')]'
          }
          labelSelector: {
            value: '[parameters(\'labelSelector\')]'
          }
          allowedCapabilities: {
            value: '[parameters(\'allowedCapabilities\')]'
          }
          requiredDropCapabilities: {
            value: '[parameters(\'requiredDropCapabilities\')]'
          }
          excludedContainers :{
            value : '[parameters(\'excludedContainers\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/febd0533-8e55-448f-b837-bd0e06f16469'
        parameters: {
          effect: {
            value: '[parameters(\'containerAllowImageEffect\')]'
          }
          excludedNamespaces: {
            value: '[parameters(\'excludedNamespaces\')]'
          }
          namespaces: {
            value: '[parameters(\'namespaces\')]'
          }
          labelSelector: {
            value: '[parameters(\'labelSelector\')]'
          }
          allowedContainerImagesRegex: {
            value: '[parameters(\'allowedContainerImagesRegex\')]'
          }
          excludedContainers: {
            value: '[parameters(\'excludedContainers\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/df49d893-a74c-421d-bc95-c663042e5b80'
        parameters: {
          effect: {
            value: '[parameters(\'containerRunReadOnlyRootFileEffect\')]'
          }
          excludedNamespaces: {
            value: '[parameters(\'excludedNamespaces\')]'
          }
          namespaces: {
            value: '[parameters(\'namespaces\')]'
          }
          labelSelector: {
            value: '[parameters(\'labelSelector\')]'
          }
          excludedContainers: {
            value: '[parameters(\'excludedContainers\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/f06ddb64-5fa3-4b77-b166-acb36f7f6042'
        parameters: {
          effect: {
            value: '[parameters(\'podRunApprovedUserGroupEffect\')]'
          }
          excludedNamespaces: {
            value: '[parameters(\'excludedNamespaces\')]'
          }
          namespaces: {
            value: '[parameters(\'namespaces\')]'
          }
          labelSelector: {
            value: '[parameters(\'labelSelector\')]'
          }
          runAsUserRule: {
            value: '[parameters(\'runAsUserRule\')]'
          }
          runAsUserRanges: {
            value: '[parameters(\'runAsUserRanges\')]'
          }
          runAsGroupRule: {
            value: '[parameters(\'runAsGroupRule\')]'
          }
          runAsGroupRanges: {
            value: '[parameters(\'runAsGroupRanges\')]'
          }
          supplementalGroupsRule: {
            value: '[parameters(\'supplementalGroupsRule\')]'
          }
          supplementalGroupsRanges: {
            value: '[parameters(\'supplementalGroupsRanges\')]'
          }
          fsGroupRule: {
            value: '[parameters(\'fsGroupRule\')]'
          }
          fsGroupRanges: {
            value: '[parameters(\'fsGroupRanges\')]'
          }
          excludedContainers: {
            value: '[parameters(\'excludedContainers\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/82985f06-dc18-4a48-bc1c-b9f4f0098cfe'
        parameters: {
          effect: {
            value: '[parameters(\'podsUseApprovedHostNetworkPortRangeEffect\')]'
          }
          excludedNamespaces: {
            value: '[parameters(\'excludedNamespaces\')]'
          }
          namespaces: {
            value: '[parameters(\'namespaces\')]'
          }
          labelSelector: {
            value: '[parameters(\'labelSelector\')]'
          }
          allowHostNetwork: {
            value: '[parameters(\'allowHostNetwork\')]'
          }
          minPort: {
            value: '[parameters(\'minPort\')]'
          }
          maxPort: {
            value: '[parameters(\'maxPort\')]'
          }
          excludedContainers: {
            value: '[parameters(\'excludedContainers\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/233a2a17-77ca-4fb1-9b6b-69223d272a44'
        parameters: {
          effect: {
            value: '[parameters(\'podsListenOnlyAllowedPortEffect\')]'
          }
          excludedNamespaces: {
            value: '[parameters(\'excludedNamespaces\')]'
          }
          namespaces: {
            value: '[parameters(\'namespaces\')]'
          }
          labelSelector: {
            value: '[parameters(\'labelSelector\')]'
          }
          allowedServicePortsList: {
            value: '[parameters(\'allowedServicePortsList\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/d46c275d-1680-448d-b2ec-e495a3b6cc89'
        parameters: {
          effect: {
            value: '[parameters(\'allowedExternalIpsEffect\')]'
          }
          allowedExternalIps: {
            value: '[parameters(\'allowedExternalIps\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d'
        parameters: {
          effect: {
            value: '[parameters(\'accessibleOnlyOverHttpsEffect\')]'
          }
          excludedNamespaces: {
            value: '[parameters(\'excludedNamespaces\')]'
          }
          namespaces: {
            value: '[parameters(\'namespaces\')]'
          }
          labelSelector: {
            value: '[parameters(\'labelSelector\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/fb893a29-21bb-418c-a157-e99480ec364c'
        parameters: {
          effect: {
            value: '[parameters(\'upgradeNonVulnerableKubernetesVersionEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/245fc9df-fa96-4414-9a0b-3738c2f7341c'
        parameters: {
          effect: {
            value: '[parameters(\'resourceLogEnabledEffect\')]'
          }
          requiredRetentionDays: {
            value: '[parameters(\'requiredRetentionDays\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ac4a19c2-fa67-49b4-8ae5-0b2e78c49457'
        parameters: {
          effect: {
            value: '[parameters(\'rbacShouldUsedEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0fc39691-5a3f-4e3e-94ee-2e6447309ad9'
        parameters: {
          effect: {
            value: '[parameters(\'vulnerabilityFindingsResolvedEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/41425d9f-d1a5-499a-9932-f8ed8453932c'
        parameters: {
          effect: {
            value: '[parameters(\'tempDiskAndCacheShouldEncryptedAtHostEffect\')]'
          }
        }
      }
      
    ]
  }
}

//Deploy the policy assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: kubernetesAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties: {
    description: assignmentProperties.description
    displayName: kubernetesAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      authorizedIpRangesEffect: {
        value: kubernetesSettings.authorizedIpRangesEffect
      }
      disableLocalAuthenticationEffect: {
        value: kubernetesSettings.disableLocalAuthenticationEffect
      }
      clusterCpuMemoryLimitNotExceedEffect : {
        value: kubernetesSettings.clusterCpuMemoryLimitNotExceedEffect
      }
      excludedNamespaces: {
        value: kubernetesSettings.excludedNamespaces
      }
      namespaces: {
        value: kubernetesSettings.namespaces
      }
      labelSelector: {
        value: kubernetesSettings.labelSelector
      }
      cpuLimit: {
        value: kubernetesSettings.cpuLimit
      }
      memoryLimit: {
        value: kubernetesSettings.memoryLimit
      }
      excludedContainers: {
        value: kubernetesSettings.excludedContainers
      }
      containerNotShareProcessIdEffect: {
        value: kubernetesSettings.containerNotShareProcessIdEffect
      }
      containerAllowCapabilityEffect: {
        value: kubernetesSettings.containerAllowCapabilityEffect
      }
      allowedCapabilities: {
        value: kubernetesSettings.allowedCapabilities
      }
      requiredDropCapabilities: {
        value: kubernetesSettings.requiredDropCapabilities
      }
      containerAllowImageEffect: {
        value: kubernetesSettings.containerAllowImageEffect
      }
      allowedContainerImagesRegex: {
        value: kubernetesSettings.allowedContainerImagesRegex
      }
      containerRunReadOnlyRootFileEffect: {
        value: kubernetesSettings.containerRunReadOnlyRootFileEffect
      }
      podRunApprovedUserGroupEffect: {
        value: kubernetesSettings.podRunApprovedUserGroupEffect
      }
      runAsUserRule: {
        value: kubernetesSettings.runAsUserRule
      }
      runAsUserRanges: {
        value: kubernetesSettings.runAsUserRanges
      }
      runAsGroupRule: {
        value: kubernetesSettings.runAsGroupRule
      }
      runAsGroupRanges: {
        value: kubernetesSettings.runAsGroupRanges
      }
      supplementalGroupsRule: {
        value: kubernetesSettings.supplementalGroupsRule
      }
      supplementalGroupsRanges: {
        value: kubernetesSettings.supplementalGroupsRanges
      }
      fsGroupRule: {
        value: kubernetesSettings.fsGroupRule
      }
      fsGroupRanges: {
        value: kubernetesSettings.fsGroupRanges
      }
      podsUseApprovedHostNetworkPortRangeEffect: {
        value: kubernetesSettings.podsUseApprovedHostNetworkPortRangeEffect
      }
      minPort: {
        value: kubernetesSettings.minPort
      }
      maxPort: {
        value: kubernetesSettings.maxPort
      }
      podsListenOnlyAllowedPortEffect: {
        value: kubernetesSettings.podsListenOnlyAllowedPortEffect
      }
      allowedServicePortsList: {
        value: kubernetesSettings.allowedServicePortsList
      }
      allowedExternalIpsEffect: {
        value: kubernetesSettings.allowedExternalIpsEffect
      }
      allowedExternalIps: {
        value: kubernetesSettings.allowedExternalIps
      }
      accessibleOnlyOverHttpsEffect: {
        value: kubernetesSettings.accessibleOnlyOverHttpsEffect
      }
      upgradeNonVulnerableKubernetesVersionEffect: {
        value: kubernetesSettings.upgradeNonVulnerableKubernetesVersionEffect
      }
      resourceLogEnabledEffect: {
        value: kubernetesSettings.resourceLogEnabledEffect
      }
      requiredRetentionDays: {
        value: kubernetesSettings.requiredRetentionDays
      }
      rbacShouldUsedEffect: {
        value: kubernetesSettings.rbacShouldUsedEffect
      }
      vulnerabilityFindingsResolvedEffect: {
        value: kubernetesSettings.vulnerabilityFindingsResolvedEffect
      }
      tempDiskAndCacheShouldEncryptedAtHostEffect: {
        value: kubernetesSettings.tempDiskAndCacheShouldEncryptedAtHostEffect
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
}
