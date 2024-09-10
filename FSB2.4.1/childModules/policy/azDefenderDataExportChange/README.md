# policy/azDefenderDataExportChange/policy.bicep
Bicep module to create Azure Defender data export rules to Log anaytics.

## Module Features
This module deploys the settings to enable the continuous export of Azure Defender (formerly called Security Center) alerts and/or recommendations to Log Analytics Workspace.

The module allows the export the following datatypes:

  - Security recommendations
  - Security alerts
  - Overall secure score
  - Secure score controls
  - Regulatory compliance
  - Overall secure score - snapshot
  - Secure score controls - snapshot
  - Regulatory compliance - snapshot
  - Security recommendations - snapshot
  - Security findings - snapshot

This child module is intended to be called by the parent Monitoring module.

*NOTE: This policy requires explicit "Log Analytics Contributor" permission on MGMT subscription where centralized log analytic workspace is present*

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policydefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |
| `Microsoft.Authorization/roleAssignments` (via roleAssignment module) | [2020-10-01-preview](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2020-10-01-preview/roleassignments) |


## Module Example Use
```bicep
module azDefenderDataExportPolicy '../../childModules/policy/azDefenderDataExportChange/policy.bicep'  {
  name: '${uniqueDeployPrefix}-monitoringAzDefenderDataExportPolicy-deployment'
  params: {
    createResourceGroup: true
    policyMetadata : 'EvidenELZ'
    exportedDatatypes: [
      'Security recommendations'
      'Security alerts'
    ]
    isSecurityFindingsEnabled: false
    recommendationNames: []
    regulatoryComplianceStandardsNames: []
    secureScoreControlsNames: []
    azDefenderDataExportDefName: azDefenderDataExportChangeDefName
    azDefenderDataExportDefAssignmentName: azDefenderDataExportChangeDefAssignmentName
    azDefenderDataExportDefAssignmentDisplayName: azDefenderDataExportChangeDefAssignmentDisplayName
    workspaceResourceID: workspaceResourceID
    resourceGroupName: monitoringResourceGroupName
    includeSecurityFindings: false
    managementSubscriptionId: managementSubscriptionId
    recommendationSeverities: [
      'High'
      'Medium'
      'Low'
    ]
    alertSeverities: [
      'High'
      'Medium'
      'Low'
    ]
  }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `workspaceResourceID` | `string` | true | The ResouredId of the log analytics workspace |
| `managementSubscriptionId` | `string` | true | The Id of the management subscription, to be provided by the Monitoring parent module. This is used to give permissions to the MGMT subscription for the policy assignment |
| `isSecurityFindingsEnabled` | `bool` | false | Security findings are results from vulnerability assessment solutions, and can be thought of as sub recommendations grouped into a parent recommendation. |
| `createResourceGroup` | `bool` | false | If a resource group does not exists in the scope, a new resource group will be created. If the resource group exists and this flag is set to true the policy will re-deploy the resource group. |
| `resourceGroupName` | `string` | true | Specifies the existing resource group where the resource will be deployed |
| `recommendationSeverities` | `string[]` | true | Allow filtering of the security recommendations, can be `High`, `Medium`, `Low`. If empty then recommandations will be skipped.|
| `alertSeverities` | `string[]` | true | Allow filtering of the security alerts, can be `High`, `Medium`, `Low`, `Informational`. If empty then alerts will be skipped.|
| `exportedDataTypes` | `string[]` | true | Allow to add exported Datatypes. See details in chapter below. |
| `recommendationNames` | `string[]` | false | Allow to add exported Datatypes. See details in chapter below. |
| `secureScoreControlsNames` | `string[]` | false | AApplicable only for export of secure score controls. See details in chapter below. |
| `regulatoryComplianceStandardsNames` | `string[]` | false | Applicable only for export of regulatory compliance. See details in chapter below. |
| `azDefenderDataExportDefName` | `string` | true | String which hold the value of the policy definition name for azure defender data export. |
| `azDefenderDataExportDefDisplayName` | `string` | true | String which hold the value of the policy definition display name for azure defender data export. |
| `azDefenderDataExportDefAssignmentName` | `string` | true | String which hold the value of the policy assignment name for azure defender data export. |
| `azDefenderDataExportDefAssignmentDisplayName` | `string` | true | String which hold the value of the policy assignment display name for azure defender data export. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

## Parameters Details

The following parameters require some more explanation:

- exportedDataTypes

The following exported dataTypes can be set: 'Security recommendations', 'Security alerts', 'Overall secure score', 'Secure score controls', 'Regulatory compliance', 'Overall secure score - snapshot', 'Secure score controls - snapshot', 'Regulatory compliance - snapshot', 'Security recommendations - snapshot', 'Security findings - snapshot'

For more information visit: https://learn.microsoft.com/en-us/azure/defender-for-cloud/continuous-export?tabs=azure-portal#what-data-types-can-be-exported

- recommendationNames

Applicable only for export of security recommendations. To export all recommendations, leave this empty. To export specific recommendations, enter a list of recommendation IDs separated by semicolons (';'). Recommendation IDs are available through the Assessments API (https://docs.microsoft.com/rest/api/securitycenter/assessments), or Azure Resource Graph Explorer, choose securityresources and microsoft.security/assessments.

- secureScoreControlsNames

Applicable only for export of secure score controls. To export all secure score controls, leave this empty. To export specific secure score controls, enter a list of secure score controls IDs separated by semicolons (';'). Secure score controls IDs are available through the Secure score controls API (https://docs.microsoft.com/rest/api/securitycenter/securescorecontrols), or Azure Resource Graph Explorer, choose securityresources and microsoft.security/securescores/securescorecontrols.

- regulatoryComplianceStandardsNames

Applicable only for export of regulatory compliance. To export all regulatory compliance, leave this empty. To export specific regulatory compliance standards, enter a list of these standards names separated by semicolons (';'). Regulatory compliance standards names are available through the regulatory compliance standards API (https://docs.microsoft.com/rest/api/securitycenter/regulatorycompliancestandards), or Azure Resource Graph Explorer, choose securityresources and microsoft.security/regulatorycompliancestandards.

- isSecurityFindingsEnabled

Security findings are results from vulnerability assessment solutions, and can be thought of as 'sub' recommendations grouped into a 'parent' recommendation.

- createResourceGroup

If a resource group does not exists in the scope, a new resource group will be created. If the resource group exists and this flag is set to true the policy will re-deploy the resource group. Use false if the resourcegroup is shared with other resources coming from other deployments.

## Module Outputs

| Name | Description | Value |
| --- | --- | --- |
| `roleAssignmentDeployName` | Object containing the Role Assigment Deployment Name. | `policySystemManagedIdentityRoleAssignment.name` |

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "workspaceResourceID": {
      "value": "/subscriptions/3e3ae977-9abe-4702-8132-b41d3107928b/resourcegroups/dv5-mgmt-d-rsg-monitoring/providers/microsoft.operationalinsights/workspaces/dv5-mgmt-d-loganalytics"
    },
    "managementSubscriptionId": {
      "value": "3e3ae977-9abe-4702-8132-b41d3107928b"
    },
    "resourceGroupName": {
      "value": "dv5-lnd2-d-rsg-monitoring"
    },
    "includeSecurityFindings": {
      "value": false
    },
    "createResourceGroup": {
      "value": true
    },
    "recommendationSeverities": {
      "value": [
        "High",
        "Medium",
        "Low"
      ]
    },
    "exportedDataTypes": {
      "value": [
        "Security recommendations",
        "Security alerts"
      ]
    },
    "recommendationNames": {
      "value": []
    },
    "secureScoreControlsNames": {
      "value": []
    },
    "regulatoryComplianceStandardsNames": {
      "value": []
    },
    "alertSeverities": {
      "value": [
        "High",
        "Medium",
        "Low"
      ]
    },
    "azDefenderDataExportDefName": {
      "value": "azdefenderexport.change.policy.def"
    },
    "azDefenderDataExportDefAssignmentName": {
      "value": "azdefenderexport.change.policy.def.assignment"
    },
    "azDefenderDataExportDefAssignmentDisplayName": {
      "value": "Azure defender export change policy definition assignment"
    },
    "policyMetadata": {
        "value": "EvidenELZ"
    }    
  }
}
```