# policy/kubernetesChange/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys and assigns Azure policy initiative along with role assignments. The policy initiative is a set that includes the following policies:
- change policy that integrates AAD administrator group with Azure Kubernetes Service clusters
- change policy that enables Monitoring addon (Container Insights) connected to Log Analytics workspace in MGMT subscription for AKS cluster

*NOTE: This policy initiative requires explicit "Log Analytics Contributor" permission on MGMT subscription where centralized log analytic workspace is present*

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyAssignments` | [2020-09-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyDefinitions) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/kubernetesChange/policy.bicep' = {
  name: 'deployAKSGovernancePolicy'
  params: {
    managementSubscriptionId: managementSubscriptionId
    policyRuleTag:managedPolicyRuleTag
    aksAadAdminEffect: 'DeployIfNotExists'
    aksAdminGroupIds: 'd389b421-001c-42dd-b019-cf5c579c254c'
    aksMonitoringAddonEffect: 'DeployIfNotExists'
    logAnalyticsWorkspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/xxx-xxxx-x-rsg-monitoring/providers/Microsoft.OperationalInsights/workspaces/xxx-xxxx-x-loganalytics'
    deployAksAadAdminPolicyDefName: 'aks-aadconfig-change-policy-def'
    deployAksAadAdminPolicyDefDisplayName: 'Azure kubernetes services aad config change policy definition'
    aksMonitoringAddonPolicyDefName: 'aks-monitoringaddon-change-policy-def'
    aksMonitoringAddonPolicyDefDisplayName: 'Azure Kubernetes Service Monitoring Addon change policy definition'
    kubernetesChangeSetName: 'kubernetes-change-policy-set'
    kubernetesChangeSetDisplayName: 'Kubernetes change policy set'
    kubernetesChangeSetAssignmentName: 'kubernetes-change-policy-set-assignment'
    kubernetesChangeSetAssignmentDisplayName: 'Kubernetes change policy set assignment'
    policyMetadata : 'EvidenELZ'
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `aksAadAdminEffect` | `string` | true | set Policy Effect to Disabled or DeployIfNotExists |
| `managementSubscriptionId` | `string` | true | The Id of the management subscription, to be provided by the Monitoring parent module. This is used to give permissions to the MGMT subscription for the policy assignment|
| `aksAdminGroupIds` | `string` | true | Specify object ID of AAD group |
| `aksMonitoringAddonEffect` | `string` | true | set Policy Effect to Disabled or DeployIfNotExists |
| `logAnalyticsWorkspaceResourceId` | `string` | true | Specify resource ID of Log Analytics workspace in MGMT subscription |
| `deployLocation` | `string` | true | Parameter used to return the current location of the deployment. The parameter is specifically used for naming the deployment |
| `deployAksAadAdminPolicyDefName` | `string` | true | Value of the policy name for Azure Kubernetes Service AAD integration. |
| `deployAksAadAdminPolicyDefDisplayName` | `string` | true | Value of the policy display name for Azure Kubernetes Service AAD integration. |
| `aksMonitoringAddonPolicyDefName` | `string` | true | Value of the policy name for azure kubernetes services monitoring addon. |
| `aksMonitoringAddonPolicyDefDisplayName` | `string` | true | Value of the policy display name for azure kubernetes service monitoring addon. |
| `kubernetesChangeSetName` | `string` | true | Value of the policy initiative name for 'Change' azure kubernetes service. |
| `kubernetesChangeSetDisplayName` | `string` | true | Value of the policy initiative display name for 'Change' azure kubernetes service. |
| `kubernetesChangeSetAssignmentName` | `string` | true | Value of the policy assignment name for 'Change' initiative azure kubernetes service. |
| `kubernetesChangeSetAssignmentDisplayName` | `string` | true | Value of the policy assignment display name for 'Change' initiative azure kubernetes service. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |
| `policyRuleTag` | `string` | true | Tag used for the policy rule. |

## Module Outputs

| Name | Description | Value |
| --- | --- | --- |
| `roleAssignmentDeployName` | Object containing the Role Assigment Deployment Name. | `policySystemManagedIdentityRoleAssignment.name` |
| `roleAssignmentMgmtDeployName` | Object containing the Role Assigment Deployment Name in MGMT subscription. | `policySystemManagedIdentityRoleAssignmentMgmt.name` |


## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "aksAadAdminEffect": {
      "value": "DeployIfNotExists"
    },
    "aksAdminGroupIds": {
      "value": [
        "d389b421-001c-42dd-b019-cf5c579c254c"
      ]
    },
    "managementSubscriptionId": {
      "value": "3e3ae977-9abe-4702-8132-b41d3107928b"
    },
    "kubernetesChangeAadAdminPolicyDefName": {
      "value": "aks.aadconfig.change.policy.def"
    },
    "kubernetesChangeAadAdminPolicyDefDisplayName": {
      "value": "Azure kubernetes services aad config change policy definition"
    },
    "kubernetesChangeDefAssignmentName": {
      "value": "aks.change.policy.def.assignment"
    },
    "kubernetesChangeDefAssignmentDisplayName": {
      "value": "Azure kubernetes change policy definition"
    },
    "policyMetadata": {
      "value": "EvidenELZ"
    },
    "policyRuleTag": {
      "value": "EvidenManaged"
    }
  }
}

```