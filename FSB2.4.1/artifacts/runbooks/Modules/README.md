# artifacts/runbooks/Modules
Folder which holds the Eviden powershell module.

## Description
This folder holds the powershell module which is imported in the automation account and provides functions used in the Eviden runbooks.

| function | used in | Description |
| --- | --- | --- |
| `New-RunbookOutput` | Get-ServiceLimitsAndSendToLogAnalytics | Creates Runbook PS Object
| `Search-customerManagementLogAnalyticsWorkspace` | Execute-VMEncryption | Get LA workspace to send custom alert
| `Search-customerManagementLogAnalyticsWorkspace` | Monitor-CustomAlertsForLogAnalytics | Get LA workspace to send custom alert
| `Invoke-AzureRestAPIDataRequest` | Execute-VMEncryption | Invoke API request to collect data from Graph API
| `Invoke-AzureRestAPIDataRequest` | ITSM Listener Function | Invoke API request to collect data from Graph API
| `Invoke-AzureRestAPIDataRequest` | Monitor-CustomAlertsForLogAnalytics | Invoke API request to collect data from Graph API
| `Add-OutputError` | Get-ServiceLimitsAndSendToLogAnalytics |  Output top level of information from the error object |
| `Send-CustomAlertToLogAnalytics` |  Execute-VMEncryption , Monitor-CustomAlertForLogAnalytics | Send custom alert to the log analytics workspace custom table