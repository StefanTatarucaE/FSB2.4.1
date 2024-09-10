/*
SUMMARY: Budget alert solution
DESCRIPTION: Parent module to deploy the budget alert solution.
AUTHOR/S: abhijit.kakade@eviden.com, bart.decker@eviden.com
VERSION: 0.1
*/

// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

// PARAMETERS
@description('The Id of the management subscription. To be provided by the pipeline.')
param managementSubscriptionId string

@description('Required. Budget alert object with required budget , Notifications and filter details')
param budgetAlerts array


// Variable which holds a unique value for deployment, which is bound to the subscription id and deployment location.
#disable-next-line no-loc-expr-outside-params
var uniqueDeployPrefix = substring(uniqueString(subscription().subscriptionId, deployment().location), 0, 6)

var namingJsonData = {
  mgmt: {
    definition: json(loadTextContent('../../mgmtNaming.json'))
  }
}

// Name of the action group
var actionGroupName = namingJsonData.mgmt.definition.managementITSMActionGroupsIntegration.name
var actionGroupInternalName = 'itsmactiongroup' //action group internal short name is intentionally hardcoded as it's not used for any reference

// RESOURCE DEPLOYMENTS
module existingActionGroupInMgmt '../../helperModules/getResourceId/getResourceId.bicep' = {
  scope: subscription(managementSubscriptionId)
  name: '${uniqueDeployPrefix}-monitoringActionGroup-getResourceId'
  params: {
    resourceGroupName: namingJsonData.mgmt.definition.monitoringResourceGroup.name
    resourceName: actionGroupName
    resourceType: 'actionGroup'
  }
}

module budgetAlert '../../childModules/budgetAlert/budgetAlert.bicep' = [for budgetAlert in budgetAlerts: {
  name: '${budgetAlert.budgetName}-budgetAlert-deployment'
  dependsOn: [
    existingActionGroupInMgmt
  ]
  params: {
    budgetName: budgetAlert.budgetName
    budgetStartDate: budgetAlert.startDate
    budgetEndDate: budgetAlert.endDate
    budgetPeriod: budgetAlert.budgetPeriod
    budgetAmount: budgetAlert.budgetAmount
    budgetNotificationEnabled: budgetAlert.notifications.notificationForExceededbudget.alertEnabled
    budgetNotificationOperator: budgetAlert.notifications.notificationForExceededbudget.operator
    budgetNotificationThreshold: budgetAlert.notifications.notificationForExceededbudget.threshold
    budgetNotificationThresholdType: budgetAlert.notifications.notificationForExceededbudget.thresholdType
    budgetNotificationContactEmails: budgetAlert.notifications.notificationForExceededbudget.contactEmails
    budgetNotificationContactRoles: budgetAlert.notifications.notificationForExceededbudget.contactRoles
    budgetNotificationContactGroups: budgetAlert.notifications.notificationForExceededbudget.contactGroups == [actionGroupInternalName] ? [ existingActionGroupInMgmt.outputs.resourceID ] : budgetAlert.notifications.notificationForExceededbudget.contactGroups
    budgetFilters: budgetAlert.filters
  }
}]
