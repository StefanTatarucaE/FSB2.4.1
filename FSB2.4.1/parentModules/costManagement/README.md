# Cost Management Parent module
Azure Bicep parent module to create the Cost Management resources for the Eviden Landingzones for Azure solution.

## Description
This parent module calls budgetAlert child modules in the child modules folder and deploys resources required for the cost management solution in the customer subscriptions.

The following resources are created:

1. One / multiple Budget alerts on subscription level or selected filter resource group level.

## Parent module overview
The parent module has been configured as follows:
1. First get the existing action group resource Id from MGMT subscription.
2. Deploy budget on subscription or with defined filters.

### Parent module parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `managementSubscriptionId` | `string` | The Id of the management subscription. To be provided by the pipeline. |
| `budgetAlerts` | `array` | Array of budget alert object. This array is list of budget object. Each budget will have list of notifications and filters |


| budgetAlert Object Property | Type | Description |
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
| `budgetNotificationContactRoles` | `array` | The list of contact roles to send the budget notification to when the threshold is exceeded. <b> This functionality is still in development and not available for all to use </b>  |
| `budgetNotificationContactGroups` | `array` | The list of action groups to send the budget notification to when the threshold is exceeded. It accepts array of strings. Provide resource Id's of Action group/'s. Or Special value 'dcsActiongroup' in case of mgmt action group|
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


**Optional parameters**

 --

## Example parameters file

The required values for parameters are described in the following example of a parameters file. The values mentioned in this example are not default and must be defined for the parent module to run successfully.

Note : 'dcsActiongroup' value in contactGroup is special value. This will get replace with Action group resource ID of mgmt subscription. if you have any other action group you can pass resource Id of that action group here.

```
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
                "dcsActiongroup"
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