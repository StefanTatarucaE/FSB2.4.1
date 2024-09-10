# policy/azMonitorAgentWindowsChange/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys one Azure policy set definition which contains three custom policies, the policy assignment and one role assignment required for the effect of the policies. This module will
- Enable Azure Monitor Agent on Windows Virtual Machines
- Enable Azure Monitor Agent on Windows Virtual Machine Scale Sets
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
module azMonitorAgentWindowsChange '../../childModules/policy/azMonitorAgentWindowsChange/policy.bicep' = {
  name: '${uniqueDeployPrefix}-azureMonitorAgentWindows-deployment'
  params: {
        scopeToSupportedImages: false
        managementSubscriptionId: '80005cf6-dc03-4329-bbfe-bd61a19e6ef2'
        listOfWindowsImageIdToInclude: []
        dataCollectionRuleResourceId: '/subscriptions/80005cf6-dc03-4329-bbfe-bd61a19e6ef2/resourceGroups/dv2-mgmt-d-rsg-monitoring/providers/Microsoft.Insights/dataCollectionRules/my_default_dcr-windows'
        dataCollectionRulesResourceType: 'Microsoft.Insights/dataCollectionRules'
        enableAmAgentWindowsVmDefName: 'vm-enableamagentwin-change-policy-def'
        enableAmAgentWindowsVmDefDisplayName: 'Enable Azure Monitor Agent for Windows Virtual Machines change policy definition'
        enableAmAgentWindowsVmDefEffect: 'DeployIfNotExists'
        enableAmAgentWindowsVmssDefName: 'vmss-enableamagentwin-change-policy-def'
        enableAmAgentWindowsVmssDefDisplayName: 'Enable Azure Monitor Agent for Windows Virtual Machine Scale Sets change policy definition'
        enableAmAgentWindowsVmssDefEffect: 'DeployIfNotExists'
        dcrAssociationWindowsDefName: 'amagent-dcr-association-win-change-policy-def'
        dcrAssociationWindowsDefDisplayName: 'Azure Monitor Agent to DCR association Windows change policy definition'
        dcrAssociationWindowsDefEffect: 'DeployIfNotExists'
        enableAmAgentWindowsSetName: 'amagent-windows-change-policy-set'
        enableAmAgentWindowsSetDisplayName: 'Azure Monitor Agent Windows change policy initiative'
        enableAmAgentWindowsSetAssignmentName: 'amagent-windows-change-policy-set-assignment'
        enableAmAgentWindowsSetAssignmentDisplayName: 'Azure Monitor Agent Windows change policy initiative assignment' 
        policyMetadata : 'EvidenELZ'
  }
}

```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `scopeToSupportedImages` | `bool` | true | Specify wether the policy will apply only to supported images or also to custom Windows images |
| `managementSubscriptionId` | `string` | true | The Id of the management subscription. To be provided by the Monitoring parent module |
| `listOfWindowsImageIdToInclude` | `string` | false | List of virtual machine images that have supported Windows OS to add to scope. Example values: /subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage |
| `dataCollectionRuleResourceId` | `string` | true | Specify the resource ID of the Data Collection Rule for association |
| `dataCollectionRulesResourceType` | `string` | true | Specify the type of resource to wich to associate the Azure Monitor Agent |
| `enableAmAgentWindowsVmDefName` | `string` | true | Specify the name to be used for the Azure Monitor Agent for Windows Vm policy |
| `enableAmAgentWindowsVmDefDisplayName` | `string` | true | Specify the display name to be used for the Azure Monitor Agent for Windows Vm policy |
| `enableAmAgentWindowsVmDefEffect` | `string` | true | Desired effect for the Azure Monitor Agent on Windows Virtual Machines policy |
| `enableAmAgentWindowsVmssDefName` | `string` | true | Specify the name to be used for the Azure Monitor Agent for Windows Vmss policy |
| `enableAmAgentWindowsVmssDefDisplayName` | `string` | true | Specify the display name to be used for Azure Monitor Agent for Windows Vm policy |
| `enableAmAgentWindowsVmssDefEffect` | `string` | true | Desired effect for the Azure Monitor Agent on Windows Virtual Machine Scale Sets policy |
| `dcrAssociationWindowsDefName` | `string` | true | Specify te name for the Azure Monitor Agent - Data Collection Rule association for Windows policy |
| `dcrAssociationWindowsDefDisplayName` | `string` | true | Specify the display name for the Azure Monitor Agent - Data Collection Rule association for Windows policy |
| `dcrAssociationWindowsDefEffect` | `string` | true | Desired effect for the AMA to Data Collection Rule association policy. |
| `enableAmAgentWindowsSetName` | `string` | true | Specify policy set name for Windows Azure Monitor Agent initiative |
| `enableAmAgentWindowsSetDisplayName` | `string` | true | Specify policy set display name for Windows Azure Monitor Agent initiative |
| `enableAmAgentWindowsSetAssignmentName` | `string` | true | Specify policy asignment name for Windows Azure Monitor Agent initiative |
| `enableAmAgentWindowsSetAssignmentDisplayName` | `string` | true | Specify policy asignment display name for Windows Azure Monitor Agent initiative |
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
            "value": "/subscriptions/80005cf6-dc03-4329-bbfe-bd61a19e6ef2/resourceGroups/dv2-mgmt-d-rsg-monitoring/providers/Microsoft.Insights/dataCollectionRules/my_default_dcr-windows"
        },
        "dataCollectionRulesResourceType": {
            "value": "Microsoft.Insights/dataCollectionRules"
        },
        "managementSubscriptionId": {
            "value": "b7f5875a-30de-479b-8e62-ea74a9a92f50"
        },
        "policyMetadata": {
            "value": "EvidenELZ"
        },
        "enableAmAgentWindowsVmDefName": {
            "value": "vm-enableamagentlnx-change-policy-def"
        },
        "enableAmAgentWindowsVmDefDisplayName": {
            "value": "Enable Azure Monitor Agent for Windows Virtual Machines change policy definition"
        },
        "enableAmAgentWindowsVmDefEffect": {
            "value": "DeployIfNotExists"
        },
        "enableAmAgentWindowsVmssDefName": {
            "value": "vmss-enableamagentlnx-change-policy-def"
        },
        "enableAmAgentWindowsVmssDefDisplayName": {
            "value": "Enable Azure Monitor Agent for Windows Virtual Machine Scale Sets change policy definition"
        },
        "enableAmAgentWindowsVmssDefEffect": {
            "value": "DeployIfNotExists"
        },
        "dcrAssociationWindowsDefName": {
            "value": "amagent-dcr-association-lnx-change-policy-def"
        },
        "dcrAssociationWindowsDefDisplayName": {
            "value": "Azure Monitor Agent to DCR association Windows change policy definition"
        },
        "dcrAssociationWindowsDefEffect": {
            "value": "DeployIfNotExists"
        },
        "enableAmAgentWindowsSetName": {
            "value": "amagent-windows-change-policy-set"
        },
        "enableAmAgentWindowsSetDisplayName": {
            "value": "Azure Monitor Agent Windows change policy initiative"
        },
        "enableAmAgentWindowsSetAssignmentName": {
            "value": "amagent-windows-change-policy-set-assignment"
        },
        "enableAmAgentWindowsSetAssignmentDisplayName": {
            "value": "Azure Monitor Agent Windows change policy initiative assignment"
        }
    }
}

```