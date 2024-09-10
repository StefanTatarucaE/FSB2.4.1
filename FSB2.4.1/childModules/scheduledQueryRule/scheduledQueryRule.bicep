/*
SUMMARY: scheduledQueryRule child module.
DESCRIPTION: Deployment of scheduledQueryRule (Log alert rule) resource for the Eviden Landingzones for Azure solution.
AUTHOR/S: frederic.trapet@eviden.com
VERSION: 0.1
*/

//PARAMETERS
@description('Name of the alert')
@minLength(1)
param alertName string

@description('Specifies the location of the alert rule.')
param location string = resourceGroup().location

@description('Optional. A mapping of tags to assign to the resource.')
param tags object

@description('Description of alert')
param alertDescription string

@description('Severity of alert {0,1,2,3,4}')
@allowed([
  0
  1
  2
  3
  4
])
param alertSeverity int

@description('Specifies whether the alert is enabled')
param isEnabled bool

@description('Specifies whether the alert should be automatically resolved by Azure Monitor')
param isAutoMitigated bool

@description('Specifies whether the alert should needs a User Assigned Identity.')
param monitoringUserAssignedIdentity string

@description('Full Resource ID of the resource emitting the metric that will be used for the comparison. For example /subscriptions/00000000-0000-0000-0000-0000-00000000/resourceGroups/ResourceGroupName/providers/Microsoft.compute/virtualMachines/VM_xyz')
@minLength(1)
param resourceId string

@description('Log analytics query rule in Kusto language')
@minLength(1)
param query string

@description('Operator comparing the current value with the threshold value.')
@allowed([
  'Equal'
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
])
param operator string

@description('The name of the metric column for metric data alerts. Optional, can be empty string.')
param dimensionsName array

@description('The name of the threshold trigger type for metric data alerts. Optional, can be empty string.')
param timeAggregation string

@description('The threshold value at which the alert is activated.')
param threshold int

@description('Period of time used to monitor alert activity based on the threshold. Must be between one minute and one day.')
param windowSize string

@description('how often the metric alert is evaluated in minutes')
param evaluationFrequency string

@description('The ID of the action group that is triggered when the alert is activated or deactivated')
param actionGroupId string

param metricMeasureColumn string

param skipQueryValidation bool

@description('Specifies whether the alert is a Azure Resource Graph Alert.')
param isArgAlert bool

var queryString = replace(query, '{SUBSCRIPTIONID}', subscription().subscriptionId)

var userAssignedIdentity = {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '${monitoringUserAssignedIdentity}': {}
  }
}

//RESOURCE Deployment

// create Schedule query rule
resource scheduledQueryRule 'microsoft.insights/scheduledqueryrules@2023-03-15-preview' = {
  name: alertName
  location: location
  identity: isArgAlert == true ? userAssignedIdentity : null
  tags: tags
  properties: {
    description: alertDescription
    severity: alertSeverity
    enabled: isEnabled ? true : false
    evaluationFrequency: evaluationFrequency
    scopes: [
      resourceId
    ]
    windowSize: windowSize
    criteria: {
      allOf: [
        {
          query: queryString
          timeAggregation: timeAggregation
          metricMeasureColumn: (metricMeasureColumn == '') ? null : metricMeasureColumn
          dimensions: [ for dimension in dimensionsName: {
            name: dimension
            operator: 'Include'
            values: [
              '*'
            ]
        }]
          operator: operator
          threshold: (threshold == '') ? null : threshold
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    autoMitigate: isAutoMitigated ? true : false
    skipQueryValidation: (startsWith(query, 'AzureQuota_CL') || skipQueryValidation == true ) ? true : false
    actions: {
      actionGroups: [
        actionGroupId
      ]
    }
  }
}

//OUTPUTS
output scheduledQueryRuleName string = scheduledQueryRule.name
output scheduledQueryRuleResourceID string = scheduledQueryRule.id
