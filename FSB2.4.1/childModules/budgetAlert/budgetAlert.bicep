/*
SUMMARY: Budget and cost alert configuration
DESCRIPTION: Module utilised for deployment of budget and cost alert.
AUTHOR/S: abhijit.kakade@eviden.com
VERSION: 0.0.1
*/

// PARAMETERS
targetScope = 'subscription'

// It should be unique within a resource group.
@description('Name of the Budget')
@maxLength(63)
param budgetName string

// The start date must be first of the month in YYYY-MM-DD format. Future start date should not be more than three months. Past start date should be selected within the timegrain preiod.
@description('The starting date of budget (YYYY-MM-DD)')
param budgetStartDate string

//The end date must be in YYYY-MM-DD format
@description('The end date of the budget (YYYY-MM-DD)')
param budgetEndDate string

@description('The time covered by a budget. Tracking of the amount will be reset based on the time grain.')
@allowed([
  'monthly'
  'quarterly'
  'annually'
])
param budgetPeriod string

@description('The total amount of cost or usage to track with the budget')
@minValue(1)
param budgetAmount int

@description('Status of budget notification enable (True / False) ')
param budgetNotificationEnabled bool

@description('Its notification condition operator to compare threshold')
param budgetNotificationOperator string

// Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. 
// Allowed value is between 0.01 and 1000.
@description('Budget threshold value in % to send notification')
@maxValue(1000)
@minValue(1)
param budgetNotificationThreshold int

@description('Budget alert condition on actual or forecasted')
@allowed([
  'actual'
  'forecasted'
])
param budgetNotificationThresholdType string

@description('The list of email addresses to send the budget notification to when the threshold is exceeded.')
param budgetNotificationContactEmails array

param budgetNotificationContactRoles array

// The list of action groups to send the budget notification to when the threshold is exceeded. It accepts array of strings.
@description('List of action group')
param budgetNotificationContactGroups array

@description('Filters contains specific resoruce group or tags condition to create budget on')
param budgetFilters object

// VARIABLES
// The category of the budget, whether the budget tracks cost or usage.
// This budget module is used to track cost.
var budgetCategory = 'Cost'

// Deployment
resource budgetconfig 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: budgetName
  properties: {
    timePeriod: {
      startDate: budgetStartDate
      endDate: budgetEndDate
    }
    timeGrain: budgetPeriod
    amount: budgetAmount
    category: budgetCategory
    notifications: {
      notificationForExceededbudget: {
        enabled: budgetNotificationEnabled
        operator: budgetNotificationOperator
        threshold: budgetNotificationThreshold
        thresholdType: budgetNotificationThresholdType
        contactEmails: budgetNotificationContactEmails
        contactRoles: budgetNotificationContactRoles
        contactGroups: budgetNotificationContactGroups
      }
    }
    filter: budgetFilters
  }
}
