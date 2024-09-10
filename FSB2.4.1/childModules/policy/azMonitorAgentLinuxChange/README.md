# policy/azMonitorAgentLinuxChange/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys one Azure policy set definition which contains three custom policies, the policy assignment and one role assignment required for the effect of the policies. This module will
- Enable Azure Monitor Agent on Linux Virtual Machines
- Enable Azure Monitor Agent on Linux Virtual Machine Scale Sets
- Associate the Azure Monitor Agent with the specified Data Collection Rules resource
- Assign required roles role to system identity (https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-overview#permissions)

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyDefinitions) |

## Module Example Use
```bicep
module azMonitorAgentLinuxChange '../../childModules/policy/azureMonitorAgentLinuxChange/policy.bicep' = {
  name: '${uniqueDeployPrefix}-azureMonitorAgentLinux-deployment'
  params: {
        scopeToSupportedImages: false
        managementSubscriptionId: '80005cf6-dc03-4329-bbfe-bd61a19e6ef2'
        listOfLinuxImageIdToInclude: []
        dataCollectionRuleResourceId: '/subscriptions/80005cf6-dc03-4329-bbfe-bd61a19e6ef2/resourceGroups/dv2-mgmt-d-rsg-monitoring/providers/Microsoft.Insights/dataCollectionRules/my_default_dcr-linux'
        dataCollectionRulesResourceType: 'Microsoft.Insights/dataCollectionRules'
        enableAmAgentLinuxVmDefName: 'vm-enableamagentlnx-change-policy-def'
        enableAmAgentLinuxVmDefDisplayName: 'Enable Azure Monitor Agent for Linux Virtual Machines change policy definition'
        enableAmAgentLinuxVmDefEffect: 'DeployIfNotExists'
        enableAmAgentLinuxVmssDefName: 'vmss-enableamagentlnx-change-policy-def'
        enableAmAgentLinuxVmssDefDisplayName: 'Enable Azure Monitor Agent for Linux Virtual Machine Scale Sets change policy definition'
        enableAmAgentLinuxVmssDefEffect: 'DeployIfNotExists'
        dcrAssociationLinuxDefName: 'amagent-dcr-association-lnx-change-policy-def'
        dcrAssociationLinuxDefDisplayName: 'Azure Monitor Agent to DCR association linux change policy definition'
        dcrAssociationLinuxDefEffect: 'DeployIfNotExists'
        enableAmAgentLinuxSetName: 'amagent-linux-change-policy-set'
        enableAmAgentLinuxSetDisplayName: 'Azure Monitor Agent Linux change policy set'
        enableAmAgentLinuxSetAssignmentName: 'amagent-linux-change-policy-set-assignment'
        enableAmAgentLinuxSetAssignmentDisplayName: 'Azure Monitor Agent Linux change policy set assignment' 
        policyMetadata : 'EvidenELZ'
  }
}

```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `scopeToSupportedImages` | `bool` | true | Specify wether the policy will apply only to supported images or also to custom linux images |
| `managementSubscriptionId` | `string` | true | The Id of the management subscription. To be provided by the Monitoring parent module |
| `listOfLinuxImageIdToInclude` | `string` | false | List of virtual machine images that have supported Linux OS to add to scope. Example values: /subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage |
| `dataCollectionRuleResourceId` | `string` | true | Specify the resource ID of the Data Collection Rule for association |
| `dataCollectionRulesResourceType` | `string` | true | Specify the type of resource to wich to associate the Azure Monitor Agent |
| `enableAmAgentLinuxVmDefName` | `string` | true | Specify the name to be used for the Azure Monitor Agent for Linux Vm policy |
| `enableAmAgentLinuxVmDefDisplayName` | `string` | true | Specify the display name to be used for the Azure Monitor Agent for Linux Vm policy |
| `enableAmAgentLinuxVmDefEffect` | `string` | true | Desired effect for the Azure Monitor Agent on Linux Virtual Machines policy |
| `enableAmAgentLinuxVmssDefName` | `string` | true | Specify the name to be used for the Azure Monitor Agent for Linux Vmss policy |
| `enableAmAgentLinuxVmssDefDisplayName` | `string` | true | Specify the display name to be used for Azure Monitor Agent for Linux Vm policy |
| `enableAmAgentLinuxVmssDefEffect` | `string` | true | Desired effect for the Azure Monitor Agent on Linux Virtual Machine Scale Sets policy |
| `dcrAssociationLinuxDefName` | `string` | true | Specify te name for the Azure Monitor Agent - Data Collection Rule association for Linux policy |
| `dcrAssociationLinuxDefDisplayName` | `string` | true | Specify the display name for the Azure Monitor Agent - Data Collection Rule association for Linux policy |
| `dcrAssociationLinuxDefEffect` | `string` | true | Desired effect for the AMA to Data Collection Rule association policy. |
| `enableAmAgentLinuxSetName` | `string` | true | Specify policy set name for Linux Azure Monitor Agent initiative |
| `enableAmAgentLinuxSetDisplayName` | `string` | true | Specify policy set display name for Linux Azure Monitor Agent initiative |
| `enableAmAgentLinuxSetAssignmentName` | `string` | true | Specify policy asignment name for Linux Azure Monitor Agent initiative |
| `enableAmAgentLinuxSetAssignmentDisplayName` | `string` | true | Specify policy asignment display name for Linux Azure Monitor Agent initiative |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

## Module Outputs

| Name | Description | Value |
| --- | --- | --- |
| `roleAssignmentDeployName` | Object containing the Role Assigment Deployment Name. | `policySystemManagedIdentityRoleAssignment.name` |

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "scopeToSupportedImages": {
            "value": false
        },
        "dataCollectionRuleResourceId": {
            "value": "/subscriptions/80005cf6-dc03-4329-bbfe-bd61a19e6ef2/resourceGroups/dv2-mgmt-d-rsg-monitoring/providers/Microsoft.Insights/dataCollectionRules/dcrlinux001"
        },
        "dataCollectionRulesResourceType": {
            "value": "Microsoft.Insights/dataCollectionRules"
        },
        "managementSubscriptionId": {
            "value": "80005cf6-dc03-4329-bbfe-bd61a19e6ef2"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        },
        "enableAmAgentLinuxVmDefName": {
            "value": "vm-enableamagentlnx-change-policy-def"
        },
        "enableAmAgentLinuxVmDefDisplayName": {
            "value": "Enable Azure Monitor Agent for Linux Virtual Machines change policy definition"
        },
        "enableAmAgentLinuxVmDefEffect": {
            "value": "DeployIfNotExists"
        },
        "enableAmAgentLinuxVmssDefName": {
            "value": "vmss-enableamagentlnx-change-policy-def"
        },
        "enableAmAgentLinuxVmssDefDisplayName": {
            "value": "Enable Azure Monitor Agent for Linux Virtual Machine Scale Sets change policy definition"
        },
        "enableAmAgentLinuxVmssDefEffect": {
            "value": "DeployIfNotExists"
        },
        "dcrAssociationLinuxDefName": {
            "value": "amagent-dcr-association-lnx-change-policy-def"
        },
        "dcrAssociationLinuxDefDisplayName": {
            "value": "Azure Monitor Agent to DCR association linux change policy definition"
        },
        "dcrAssociationLinuxDefEffect": {
            "value": "DeployIfNotExists"
        },
        "enableAmAgentLinuxSetName": {
            "value": "amagent-linux-change-policy-set"
        },
        "enableAmAgentLinuxSetDisplayName": {
            "value": "Azure Monitor Agent Linux change policy set"
        },
        "enableAmAgentLinuxSetAssignmentName": {
            "value": "amagent-linux-change-policy-set-assignment"
        },
        "enableAmAgentLinuxSetAssignmentDisplayName": {
            "value": "Azure Monitor Agent Linux change policy set assignment"
        }
    }
}

```