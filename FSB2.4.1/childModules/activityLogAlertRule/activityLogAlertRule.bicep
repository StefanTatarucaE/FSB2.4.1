/*
SUMMARY: activity Log Rule child module
DESCRIPTION: Deployment of service health or resource health alert rule resource for the Eviden Landingzones for Azure solution.
AUTHOR/S: frederic.trapet@eviden.com
VERSION: 0.1
*/

//PARAMETERS
@description('Name of the alert')
@minLength(1)
param alertName string

@description('Optional. A mapping of tags to assign to the resource.')
param tags object

@description('Description of alert')
param alertDescription string

@description('The ID of the action group that is triggered when the alert is activated or deactivated')
param actionGroupId string

@description('Array of resources types condition to filter the resource health alert (see documentation for syntax : https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/activitylogalerts)')
param resourceTypesCondition array

@description('Type of the activity log alert, service or resource health')
@allowed([
  'ServiceHealth'
  'ResourceHealth'
])
param alertType string

//VARIABLES

// The location must be hardcoded as 'global' for service and resource health
var location = 'global'

// define the subscription ID that will be used in the alert scope
var scopeSubscriptionId = '/subscriptions/${subscription().subscriptionId}'

// define the condition filters that will be used for all alert types
var commonAlertConditions = [
  {
    field: 'category'
    equals: alertType
  }
  {
    anyOf: resourceTypesCondition
  }
]

// define the condition filters that will be used for resourceHealth alerts 
var resourceHealthConditions = [
  {
    anyOf: [
      {
        field: 'properties.currentHealthStatus'
        equals: 'Unavailable'
        containsAny: null
      }
      {
        field: 'properties.currentHealthStatus'
        equals: 'Degraded'
        containsAny: null
      }
    ]
  }
  {
    anyOf: [
      {
        field: 'properties.previousHealthStatus'
        equals: 'Available'
        containsAny: null
      }
      {
        field: 'properties.previousHealthStatus'
        equals: 'Degraded'
        containsAny: null
      }
      {
        field: 'properties.previousHealthStatus'
        equals: 'Unknown'
        containsAny: null
      }
      {
        field: 'properties.previousHealthStatus'
        equals: 'Unavailable'
        containsAny: null
      }
    ]
  }
  {
    anyOf: [
      {
        field: 'status'
        equals: 'Active'
      }
    ]
  }
  {
    anyOf: [
      {
        field: 'properties.cause'
        equals: 'PlatformInitiated'
        containsAny: null
      }
      {
        field: 'properties.cause'
        equals: 'Unknown'
        containsAny: null
      }
    ]
  }
]

// define the condition filters that will be used for resourceHealth alerts
var resourceVmHealthConditions = [
  {
    anyOf: [
      {
        field: 'properties.currentHealthStatus'
        equals: 'Unavailable'
        containsAny: null
      }
      {
        field: 'properties.currentHealthStatus'
        equals: 'Degraded'
        containsAny: null
      }
    ]
  }
  {
    anyOf: [
      {
        field: 'properties.previousHealthStatus'
        equals: 'Available'
        containsAny: null
      }
      {
        field: 'properties.previousHealthStatus'
        equals: 'Degraded'
        containsAny: null
      }
      {
        field: 'properties.previousHealthStatus'
        equals: 'Unknown'
        containsAny: null
      }
      {
        field: 'properties.previousHealthStatus'
        equals: 'Unavailable'
        containsAny: null
      }
    ]
  }
  {
    anyOf: [
      {
        field: 'status'
        equals: 'Updated'
      }
    ]
  }
  {
    anyOf: [
      {
        field: 'properties.cause'
        equals: 'PlatformInitiated'
        containsAny: null
      }
      {
        field: 'properties.cause'
        equals: 'Unknown'
        containsAny: null
      }
    ]
  }
]

// define the condition filters that will be used for resourceHealth alerts
var serviceHealthConditions = [
  {
    anyOf: [
      {
        field: 'properties.impactedServices[*].ImpactedRegions[*].RegionName'
        containsAny: [
          'Australia Central'
          'Australia Central 2'
          'Australia East'
          'Australia Southeast'
          'Brazil South'
          'Brazil Southeast'
          'Canada Central'
          'Canada East'
          'Central India'
          'Central US'
          'East Asia'
          'East US'
          'East US 2'
          'France Central'
          'France South'
          'Germany North'
          'Germany West Central'
          'Global'
          'Japan East'
          'Japan West'
          'Korea Central'
          'Korea South'
          'North Central US'
          'North Europe'
          'Norway East'
          'Norway West'
          'South Africa North'
          'South Africa West'
          'South Central US'
          'South India'
          'Southeast Asia'
          'Switzerland North'
          'Switzerland West'
          'UAE Central'
          'UAE North'
          'UK South'
          'UK West'
          'West Central US'
          'West Europe'
          'West India'
          'West US'
          'West US 2'
          'West US 3'
        ]
      }
    ]
  }
]

// join common conditions with the alert-specific condition
var joinedAlertConditions = (alertType == 'ServiceHealth') ? union(commonAlertConditions, serviceHealthConditions) : union(commonAlertConditions, resourceHealthConditions)
var joinedVmAlertConditions = (alertType == 'ServiceHealth') ? union(commonAlertConditions, serviceHealthConditions) : union(commonAlertConditions, resourceVmHealthConditions)

//RESOURCE Deployment

// create the serviceHealth alert rule (activity log type)
resource activityLogAlertRule 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: alertName
  location: location
  tags: tags
  properties: {
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroupId
        }
      ]
    }
    condition: {
      allOf: (alertName == 'Azure Resource Health alert rule - Virtual machines OS') ? joinedVmAlertConditions : joinedAlertConditions
    }
    description: alertDescription
    enabled: true
    scopes: [
      scopeSubscriptionId
    ]
  }
}

//OUTPUTS
output activityLogAlertRuleName string = activityLogAlertRule.name
output activityLogAlertRuleResourceID string = activityLogAlertRule.id
