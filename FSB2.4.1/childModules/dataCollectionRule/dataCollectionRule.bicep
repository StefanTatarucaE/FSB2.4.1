/*
SUMMARY: Data Collection Rule (DCR) for Azure Monitoring Agent
DESCRIPTION: Module utilised for deployment of DCR.
AUTHOR/S: abhijit.kakade@eviden.com
VERSION: 0.0.1
*/

// PARAMETERS

@description('The total amount of cost or usage to track with the budget')
param location string

@description('Data Collection Rule Name ')
@maxLength(62)
param dataCollectionRuleName string

@description('Kind of DCR - Windows / Linux')
@maxLength(10)
param dcrKind string

@description('Log analytics workspace resource ID')
param workspaceResourceId string

@description('Log analyatics workspace name')
@maxLength(62)
param workspaceName string

@description('Source details for data collection rules')
param dcrDataSource object

@description('Stream details for data collection rules')
param dataFlowStreams array

@description('Destination details of data collection rules')
param dataFlowsDestinations array

@description('A mapping of tags to assign to the resource.')
param tags object

resource dataCollectionRules 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: dataCollectionRuleName
  location: location
  tags: tags
  kind: dcrKind
  properties: {
    dataSources: dcrDataSource
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: dataFlowStreams
        destinations: dataFlowsDestinations
      }
    ]
  }
}
