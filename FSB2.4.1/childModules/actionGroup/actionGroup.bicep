/*
SUMMARY: actionGroup child module.
DESCRIPTION: Deployment of actionGroup resource for the Eviden Landingzones for Azure solution.
AUTHOR/S: frederic.trapet@eviden.com
VERSION: 0.1
*/

//PARAMETERS
@description('Specifies the name of the ActionGroup.')
param actionGroupName string

@description('Specifies the short internal name of the ActionGroup.')
param actionGroupShortName string

@description('Optional. Logic-app receivers for this action group')
@metadata({
  name: 'Name of the logic app action'
  callbackUrl: 'The callback Url of the logic app'
  resourceId: 'ResourceID of the logicapp'
  useCommonAlertSchema: 'use the common alert schema or not'
})
param logicAppReceivers array =[]

@description('A mapping of tags to assign to the resource.')
param tags object

//VARIABLES

// The location must be hardcoded as 'global' for action groups
var location = 'global'

//RESOURCE Deployment

// create Action Group

resource actionGroup 'Microsoft.Insights/actionGroups@2022-06-01' = {
  name: actionGroupName
  location: location
  tags: tags
  properties: {
    enabled: true
    groupShortName: actionGroupShortName
    logicAppReceivers: logicAppReceivers
  }
}

//OUTPUTS
output actionGroupName string = actionGroup.name
output actionGroupResourceID string = actionGroup.id

