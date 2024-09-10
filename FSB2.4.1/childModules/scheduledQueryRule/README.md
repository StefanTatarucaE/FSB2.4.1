# scheduledQueryRule/scheduledQueryRule.bicep
Bicep module to create a scheduledQueryRule (Log Analytics alert rule) using the new API where "monitoringSource" property is LOG ALERTS V2 

## Module Features
Module can deploy a scheduled query rule alert rule, to create the following alerts type :
- Log Analytics alert

## Folder Structure Example
```bicep
modules
├── scheduledQueryRule
|    ├── scheduledQueryRule.bicep
|    ├── preDeploy.tests.ps1
├── storageAccount
├── virtualNetwork
```

## Parent Module Example Use
```bicep
module logAlertRules '../../childModules/scheduledQueryRule/scheduledQueryRule.bicep' = {
  scope: monitoringResourceGroup
  name: 'monitoringScheduledQueryRule-deployment'
  params: {
    location: location
    resourceId: workspaceResourceID
    actionGroupId: actionGroupResourceID
    tags: tags
    alertSeverity: logAlert.alertSeverity
    isEnabled: contains(logAlert, 'enableAlert') ? logAlert.enableAlert : true
    isAutoMitigated: contains(logAlert, 'autoMitigate') ? logAlert.autoMitigate : false
    alertName: logAlert.alertName
    alertDescription: logAlert.alertDescription
    query: logAlert.query
    operator: logAlert.operator
    threshold: logAlert.threshold
    windowSize: logAlert.windowSize
    evaluationFrequency: logAlert.evaluationFrequency
    
    metricMeasureColumn: contains(logAlert, 'metricMeasureColumn') ? logAlert.metricMeasureColumn : ''
    dimensionsName: contains(logAlert, 'dimensionsName') ? split(logAlert.dimensionsName, ',') : []
    timeAggregation: logAlert.timeAggregation
    skipQueryValidation: contains(logAlert, 'skipQueryValidation') ? logAlert.skipQueryValidation : false
  }
}
```

## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `location` | `string` | false| Specifies the location where the resource will be deployed. Defaults to resource group location |
| `resourceId` | `string` | true | Full Resource ID of the resource emitting the metric |
| `actionGroupId` | `string` | true | Specifies the resourceID of the action group that will be triggered by the alert |
| `tags` | `object` | true | A mapping of tags to assign to the resource.  Additional Details [here](#object---tags).|
| `alertSeverity` | `string` | true | Specify the Severity number of the alert.<ul><li>0: Critical</li><li>1: Error</li><li>2: warning</li><li>3: Informational</li><li>4: verbose</li></ul>|
| `isEnabled` | `bool` | true | Specifies if the alert is enabled. |
| `isAutoMitigated` | `bool` | true | Specifies if the alert should be configured to resolve automatically by Azure Monitor|
| `alertName` | `string` | true | Specifies the name of the alert rule. |
| `alertDescription` | `string` | true | Specifies the description of the alert rule. |
| `query` | `string` | true| Log analytics query rule in Kusto language |
| `operator` | `string` | true | Operator comparing the current value with the threshold value.|
| `threshold` | `integer` | true | The threshold value at which the alert is activated.  |
| `windowSize` | `string` | true | Period of time used to monitor alert activity based on the threshold. Must be between one minute and one day. ISO 8601 duration format. Example value is `PT30M` |
| `evaluationFrequency` | `string` | true | how often the metric alert is evaluated represented in ISO 8601 duration format. Example value is `PT5M` |
| `metricMeasureColumn` | `string` | false | The name of the metric column for metric data alerts. Optional, can be empty string |
| `dimensionsName` | `array` | false | the columns to be used as dimensions for the alert, to enable more granular results (e.g. individual tables from a SQL Database) |
| `timeAggregation` | `string` | true | the type of aggregation to be done, value can be 'Average', 'Count', 'Maximum', 'Minimum', 'Total' |  
| `skipQueryValidation` | `bool` | false | instructs the deployment engine to skip the alert rule query validation process |

### Object - tags
Below is an example of the tags object

`"key"`:`"value"`

**Example:**
```json
{
    "EvidenManaged": "true",
    "Project": "Monitoring Parent Module",
    "ManagedBy": "AzureBicep"
}
```


For a complete list of all the possible parameters, see the parameters section in the `scheduledQueryRule.bicep` file in this modules folder.

## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `scheduledQueryRuleResourceID` | The resource ID of the created alert rule. | `scheduledQueryRule.id` |
| `scheduledQueryRuleName` | The name of the created alert rule. | `scheduledQueryRule.name` |

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "alertName": {
      "value": "Blob Storage - SuccessE2ELatency greater than thresholdV2"
    },
    "alertDescription": {
      "value": "Cloud.IaaS.DCS-Azure-Storage - Part of standard set of log alerts - Category AZURE RESOURCES"
    },
    "tags": {
      "value": {
        "EvidenManaged": "true",
        "Owner": "Fred",
        "Project": "Monitoring Parent Module",
        "ManagedBy": "AzureBicep"
      }
    },
    "alertSeverity": {
      "value": 1
    },
    "isEnabled": {
      "value": true
    },
    "resourceId": {
      "value": "/subscriptions/b0238bae-57cc-492c-984d-aa153693a06b/resourceGroups/dv2-mgmt-d-rsg-monitoring/providers/Microsoft.OperationalInsights/workspaces/dv2-mgmt-d-loganalytics"
    },
    "query": {
      "value": "AzureMetrics| where ResourceId contains \"/BLOBSERVICES/\" and MetricName == \"SuccessE2ELatency\"| summarize AggregatedValue = avg(Maximum) by _ResourceId, bin(TimeGenerated, 30m)| project TimeGenerated,Latency_ms=round(AggregatedValue, 1),AggregatedValue=round(AggregatedValue, 1),SubscriptionId=split(_ResourceId, \"/\", 2)[0],Resource_group=split(_ResourceId, \"/\", 4)[0],SA_name=tostring(split(_ResourceId, \"/\", 8)[0]),ResourceID = tostring(split(tolower(_ResourceId), \"/blobservices/\", 0)[0]),alerthash=hash_md5(strcat(\"blobE2Elatency\", _ResourceId))"
    },
    "operator": {
      "value": "GreaterThan"
    },
    "threshold": {
      "value": 500
    },
    "windowSize": {
      "value": "PT30M"
    },
    "evaluationFrequency": {
      "value": "PT30M"
    },
    "dimensionsName": {
      "value": "ResourceID"
    },
    "timeAggregation": {
      "value": "Average"
    },
    "metricMeasureColumn": {
      "value": "AggregatedValue"
    },
    "isAutoMitigated": {
      "value": false
    },
    "actionGroupId": {
      "value": "/subscriptions/b0238bae-57cc-492c-984d-aa153693a06b/resourceGroups/dv2-mgmt-d-rsg-monitoring/providers/Microsoft.Insights/actionGroups/dv2-mgmt-d-actiongroup-itsm"
    }
  }
}
```

