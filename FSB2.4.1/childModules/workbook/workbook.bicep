/*
SUMMARY: Workbook child module.
DESCRIPTION: Deployment of Workbook for the ELZ solution.
AUTHOR/S: klaasjan.dejager@eviden.com
VERSION: 0.0.1
*/

//PARAMETERS
@description('Required. Specifies the name of the Workbook.')
param workbookDisplayName string

@description('Required. Code and configuration of this particular workbook. Configuration data is a string containing valid JSON.')
param workbookContent string

@description('Optional. Specifies the location of the Workbook.')
param location string = resourceGroup().location

@description('Optional. Specify mapping of tags attached to the Workbook')
param tags object

@description('Workbook schema version format, like \'Notebook/1.0\', which should match the workbook in serializedData.')
var workbookVersion = 'Notebook/1.0'

@description('The kind of workbook. Only valid value is shared.')
var workbookKind = 'Shared'

@description('Specify the category for the workbook as Workbook.')
var workbookCategory = 'Workbook'

@description('Specify the gallery for the workbook as Azure Monitor.')
var workbookSourceId = 'Azure Monitor'

//RESOURCE Deployment

//Create workbook
resource workbook 'Microsoft.Insights/workbooks@2021-08-01' = {
  name: guid(workbookDisplayName)
  location: location
  tags: tags
  kind: workbookKind
  properties: {
    category: workbookCategory
    displayName: workbookDisplayName
    serializedData: string(workbookContent)
    sourceId: workbookSourceId
    version: workbookVersion
  }
}

//OUTPUTS
@description('The resourceId of the created workbook')
output workbookResourceId string = workbook.id

