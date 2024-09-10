/*
SUMMARY: dashboard child module.
DESCRIPTION: Deployment of dashboard for the ELZ solution.
AUTHOR/S: klaasjan.dejager@eviden.com
VERSION: 0.0.1
*/

//PARAMETERS
@description('Required. Specifies the name of the dashboard.')
param dashboardDisplayName string

@description('Required. Properties of this particular dashboard. Data is a string containing valid JSON.')
param dashboardLenses object

@description('Optional. Specifies the location of the dashboard.')
param location string = resourceGroup().location

@description('Optional. Specify mapping of tags attached to dashboard')
param tags object

@description('Defined metadata for all dashboards, so they can be changed globally.')
var metaData = {
  model: {
    timeRange: {
      value: {
        relative: {
          duration: 24
          timeUnit: 1
        }
      }
      type: 'MsPortalFx.Composition.Configuration.ValueTypes.TimeRange'
    }
    filterLocale: {
      value: 'en-us'
    }
    filters: {
      value: {
        MsPortalFx_TimeRange: {
          model: {
            format: 'utc'
            granularity: 'auto'
            relative: '24h'
          }
          displayCache: {
            name: 'UTC Time'
            value: 'Past 24 hours'
          }
          filteredPartIds: []
        }
      }
    }
  }
}

//RESOURCE Deployment

//Create workbook
resource dashboard 'Microsoft.Portal/dashboards@2019-01-01-preview' = {
  name: dashboardDisplayName
  location: location
  tags: tags
  properties: {
    lenses: dashboardLenses
    metadata: metaData
  }
}

//OUTPUTS
@description('The resourceId of the created dashboard')
output dashboardResourceId string = dashboard.id
