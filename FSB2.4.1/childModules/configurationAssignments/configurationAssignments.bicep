
/*
SUMMARY: Deployment of maintenance assignments.
DESCRIPTION: Deploy a mainteance assignment within the target subscription.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

// SCOPE

//PARAMETERS

@description('List of locations to scope the query to.')
param configurationAssignmentsLocations array = []

@description('List of OS types to scope the query to.')
param configurationAssignmentsOsTypes array = []

@description('List of resource groups to scope the query to.')
param configurationAssignmentsResourceGroups array = []

@description('List of resource types to scope the query to.')
param configurationAssignmentsResourceTypes array = []

@description('Filter operator to use for the tags.')
@allowed([
  'All'
  'Any'
])
param configurationAssignmentsTagFilter string = 'All'

@description('Object holding the tagfilter for the Configuration Assignment.')
param configurationAssignmentsTagObject object

@description('Subscription ID used to deploy the maintenance assignment.')
param subscriptionId string

@description('Maintenance configuration ID used to deploy the maintenance assignment.')
param maintenanceConfigurationId string

@description('Name of the maintenance configuration which is used for the configuration assignment name.')
param configurationAssignmentName string

// RESOURCES
// Create a maintenance assignment
resource configurationAssignments 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = {
  name: configurationAssignmentName
  properties: {
    filter: {
      locations: configurationAssignmentsLocations
      osTypes: configurationAssignmentsOsTypes
      resourceGroups: configurationAssignmentsResourceGroups
      resourceTypes: configurationAssignmentsResourceTypes
      tagSettings: {
        filterOperator: configurationAssignmentsTagFilter
        tags: configurationAssignmentsTagObject
      }
    }
    maintenanceConfigurationId: maintenanceConfigurationId
    resourceId: subscriptionId
  }
}
