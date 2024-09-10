/*
SUMMARY: aadDiagnostics settings child module.
DESCRIPTION: Deployment of diagnostic settings for Azure active directory to send specific logs to a Log Analytics workspace.
AUTHOR/S: frederic.trapet.eviden.com
VERSION: 0.1
*/

@description('Specifies the target Log Analytics workspace resource Id.')
param logAnalyticsWorkspaceResourceId string

@description('the logs to be sent to Log Analytics and the retention policy to be used')
param aadLogsProperties array

@description('the name for the diagnostic rule')
param aadDiagnosticsRuleName string

resource aadDiagnosticSetttings 'Microsoft.aadiam/diagnosticSettings@2017-04-01' = {
  scope: tenant()
  name: aadDiagnosticsRuleName
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: [for log in aadLogsProperties: {
      category: log.logCategory
      enabled: true
      retentionPolicy: {
        days: log.retentionDays
        enabled: log.enabled
      }
    }]
  }
}
