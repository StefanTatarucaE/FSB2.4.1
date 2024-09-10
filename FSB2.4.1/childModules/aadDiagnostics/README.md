# aadDiagnostics/aadDiagnostics.bicep
Bicep module to create Azure Active Directory diagnostic settings that sends the AAD logs to a Log Analytics Workspace

## Module Features
This module deploys the diagnostic settings feature for Azure Active Airectory at tenant level.
Developed for deployments in the MSP tenant context, it can also be used for customer tenants if the account used to perform the deployment has global admin rights on the customer tenant.

## Folder Structure Example
```bicep
childModules
├── aadDiagnostics
|    ├── aadDiagnostics.bicep
├── actionGroup
├── virtualNetwork
```

## Parent Module Example Use
```bicep
module '../../childModules/aadDiagnostics/aadDiagnostics.bicep' = {
  scope: mspMonitoringResourceGroup //the tenant scope required to deploy Azure Active Directory resources is hardcoded in the child module - resource deployment.
  name: 'EvidenDiagnosticRule-azureActiveDirectory-deployment'
  params: {
    aadDiagnosticsRuleName: aadDiagnosticsRuleName
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    aadLogsProperties: aadLogsProperties
  }
}
```

## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `aadDiagnosticsRuleName` | `string` | true | Specifies the name that will be assigned to the diagnostic rule. |
| `logAnalyticsWorkspaceResourceId` | `string` | true | The resource id of the Log Analytics Workspace where the logs will be forwarded. |
| `aadLogsProperties` | `array` | true | Array of objects specifying the azure active directory categories to forward to the log analytics workspace and the retention policy. |


### Array - aadLogsProperties
| Name | Type | Description |
| --- | --- |--- |
| `logCategory` | `string`| The Azure Active Directory log category. The possible values for this field are (case-insensitive): 'AuditLogs', 'SignInLogs', 'NonInteractiveUserSignInLogs', 'ServicePrincipalSignInLogs', 'ManagedIdentitySignInLogs', 'ProvisioningLogs', 'ADFSSignInLogs', 'RiskyUsers', 'UserRiskEvents', 'NetworkAccessTrafficLogs', 'RiskyServicePrincipals', 'ServicePrincipalRiskEvents'. |
| `retentionDays`| `int` | the number of days to retain the logs in their specific log analytics table. 0 means indefinitelly (the retention specified for the whole log analytics workspace) |
| `enabled`| `bool` | indicates if the retention policy is enabled.|


## Module outputs
N/A

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "logAnalyticsWorkspaceResourceId": {
      "value": "/subscriptions/be09a3a8-0c4b-4643-910f-4506db3598b3/resourcegroups/cu6-cnty-d-rsg-hub/providers/microsoft.operationalinsights/workspaces/la-default"
    },
    "aadDiagnosticRuleName": {
      "value": "EvidenDiagnosticRule-SendToLogAnalytics"
    },
    "aadLogsProperties": {
      "value": [
        {
          "logCategory": "Auditlogs",
          "retentionDays": 0,
          "enabled": true
        },
        {
          "logCategory": "SignInLogs",
          "retentionDays": 0,
          "enabled": true
        },
        {
          "logCategory": "NonInteractiveUserSignInLogs",
          "retentionDays": 0,
          "enabled": true
        },
        {
          "logCategory": "ServicePrincipalSignInLogs",
          "retentionDays": 0,
          "enabled": true
        },
        {
          "logCategory": "ManagedIdentitySignInLogs",
          "retentionDays": 0,
          "enabled": true
        },
        {
          "logCategory": "ProvisioningLogs",
          "retentionDays": 0,
          "enabled": true
        },
        {
          "logCategory": "ADFSSignInLogs",
          "retentionDays": 0,
          "enabled": true
        },
        {
          "logCategory": "RiskyUsers",
          "retentionDays": 0,
          "enabled": true
        },
        {
          "logCategory": "UserRiskEvents",
          "retentionDays": 0,
          "enabled": true
        },
        {
          "logCategory": "NetworkAccessTrafficLogs",
          "retentionDays": 0,
          "enabled": true
        },
        {
          "logCategory": "RiskyServicePrincipals",
          "retentionDays": 0,
          "enabled": true
        },
        {
          "logCategory": "ServicePrincipalRiskEvents",
          "retentionDays": 0,
          "enabled": true
        }
      ]
    }
  }
}
```