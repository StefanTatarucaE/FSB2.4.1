# budgetAlert/budgetAlert.bicep
Bicep module to create a Budget (cost) Alert on subscription.

## Description
Budget in Cost Management help you plan for Organizational accountability. With budgets, you can account for the Azure services you consume or subscribe during specific period. Notifications are triggered when the budget thresholds you have created are exceeded.

Note: It is recommended to add azure-noreply@microsoft.com to your email white list to ensure alert mails do not go to your spam folder.

## Module example use
```hcl
module budgetAlert '../../childModules/budgetAlert/budgetAlert.bicep' = {
  name: 'exampleBudgetAlert-deployment'
  params: {
    budgetName: 'budgetAlert-cu1-001'
    budgetStartDate: '2023-03-01'
    budgetEndDate: '2030-02-28'
    budgetPeriod: 'monthly'
    budgetAmount: 200
    budgetNotificationEnabled: true
    budgetNotificationOperator: 'GreaterThan'
    budgetNotificationThreshold: 100
    budgetNotificationThresholdType: 'actual'
    budgetNotificationContactEmails: 'abhijit.kakade@eviden.com'
    budgetNotificationContactRoles: 'admin'
    budgetNotificationContactGroups: 'itsmactiongroup'
    budgetFilters: {
      dimensions: {
        name: 'ResourceGroupName'
        operator: 'In'
        values: resourceGroupFilterValues
      }
    }
  }
}

```
## Module Arguments

| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `budgetName` | `string` | Budget Name should be unique with in resource group. |
| `budgetStartDate` | `string` | The start date must be first of the month in YYYY-MM-DD format. Future start date should not be more than three months. |
| `budgetEndDate` | `string` | The end date for the budget in YYYY-MM-DD format |
| `budgetPeriod` | `string` | budget Period ( monthly / quarterly / annually ) (This value should be in lower case) |
| `budgetAmount` | `int` | Total budget amount for selected period |
| `budgetNotificationEnabled` | `bool` | true / false |
| `budgetNotificationOperator` | `string` | To send notification add conditional operator on threshold value ('GreaterThan')  |
| `budgetNotificationThreshold` | `string` | Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000. |
| `budgetNotificationThresholdType` | `string` | Actual / Forecast. Its recommended to combine budgetNotificationThresholdType of actual and forecasted to have forecasted budget alerts that proactively warn you and actual budget alerts that inform you when the actual event happened. |
| `budgetNotificationContactEmails` | `array` | The list of email addresses to send the budget notification to when the threshold is exceeded. |
| `budgetNotificationContactRoles` | `array` | The list of contact roles to send the budget notification to when the threshold is exceeded. |
| `budgetNotificationContactGroups` | `array` | The list of action groups to send the budget notification to when the threshold is exceeded. It accepts array of strings. |
| `budgetFilters` | `object` | The set of values for the resource group filter. |

Few points need to consider while creating budget alert :

- Please note that we have been informed by Microsoft, that 'ContactRole' notificaion option is not available for all, it is still in development phase.
- For sending notification either ContactEmails or ContactRoles or ContacGroups (Action group) value should be provided. Passing atleast any one of this value is mandatory. All three values should not be blank / null.
- Budget automatically gets deleted when it expires.
- Budget End Date should be < Future 10 years.
- Budget Start Date should be  :

|If Budget Period | Greater than | Less than |
| :-- | :-- | :-- |
| monthly | past 1 month | future 1 year |
| quarterly | past 3 months | future 1 year |
| annually | past 1 year| future 1 year |


## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "budgetAlerts": {
      "value": [
        {
          "budgetName": "budgetAlert-cu1-001",
          "budgetAmount": 200,
          "budgetPeriod": "monthly",
          "startDate": "2023-03-01",
          "endDate": "2029-04-01",
          "filters": {},
          "notifications": {
            "notificationForExceededbudget": {
              "alertEnabled": true,
              "operator": "GreaterThan",
              "threshold": 50,
              "thresholdType": "actual",
              "contactEmails": [
                  "abhijit.kakade@eviden.com",
                  "robert.vanvugt@eviden.com",
                  "wojciech.brzezinski@eviden.com",
                  "surbhi.2.sharma@eviden.com",
                  "sakar.chatta@eviden.com",
                  "frederic.trapet@eviden.com"
              ],
              "contactRoles": [
                "Owner"
              ],
              "contactGroups": [
                "itsmactiongroup"
              ]
            }
          }
        },
        {
          "budgetName": "budgetAlert-cu1-002",
          "budgetAmount": 200,
          "budgetPeriod": "monthly",
          "startDate": "2023-03-01",
          "endDate": "2029-04-01",
          "filters": {},
          "notifications": {
            "notificationForExceededbudget": {
              "alertEnabled": true,
              "operator": "GreaterThan",
              "threshold": 50,
              "thresholdType": "forecasted",
              "contactEmails": [
                  "abhijit.kakade@eviden.com",
                  "robert.vanvugt@eviden.com",
                  "wojciech.brzezinski@eviden.com",
                  "surbhi.2.sharma@eviden.com",
                  "sakar.chatta@eviden.com",
                  "frederic.trapet@eviden.com"
              ],
              "contactRoles": [
                "Owner"
              ],
              "contactGroups": []
            }
          }
        }
      ]
    }
  }
}

```



