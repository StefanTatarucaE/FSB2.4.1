# workBook/workBook.bicep
Bicep module to create Azure Reporting workbooks .

## Module Features
Module can deploy a workbook resource.

## Module Example Use
```hcl
module workbook '../childModules/workbook/workbook.bicep' = {
  name: 'workbookExample' 
  params: {
    workbookDisplayName: workbookDisplayName
    location: location
    tags:tags
    workbookContent: workbookContent
  }
}
```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `workbookDisplayName` | `string` | true | Specifies the name of the workbook. |
| `location` | `string` | false| Specifies the location where the resource will be deployed. |
| `tags` | `object` | false | A mapping of tags to assign to the resource. Additional Details [here](#object---tags). |
| `workBookContent` | `string` | true | Specifies the contents of the workbook resource. This is a string containing the json code of the workbook Gallery Template. |

### Object - tags
Below is an example of the tags object

`"key"`:`"value"`

**Example:**
```json
{
    "EvidenManaged": "true",
    "EvidenPurpose": "EvidenReporting"
}
```

## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `workbookResourceId` | The resource ID of the created workbook resource. | `workbook.id` |

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "workBookDisplayName": {
            "value": "--* BICEP-WORKBOOK *--"
        },
        "location": {
            "value": "westeurope"
        },
        "tags": {
            "value": {
                        "EvidenManaged": "true",
                        "EvidenPurpose": "EvidenReporting"
                    }
        },
        "workBookContent": {
            "value": {
                "version": "Notebook/1.0",
                "items": [
                    {
                        "type": 12,
                        "content": {
                            "version": "NotebookGroup/1.0",
                            "groupType": "editable",
                            "items": [
                                {
                                    "type": 9,
                                    "content": {
                                        "version": "KqlParameterItem/1.0",
                                        "crossComponentResources": [
                                            "{subscriptionPicker}"
                                        ],
                                        "parameters": [
                                            {
                                                "id": "f5f66862-c38c-4c25-98fa-ad1e7f463a0f",
                                                "version": "KqlParameterItem/1.0",
                                                "name": "subscriptionPicker",
                                                "label": "Subscription",
                                                "type": 6,
                                                "isRequired": true,
                                                "multiSelect": true,
                                                "quote": "'",
                                                "delimiter": ",",
                                                "value": [
                                                    "value::all"
                                                ],
                                                "typeSettings": {
                                                    "additionalResourceOptions": [
                                                        "value::all"
                                                    ],
                                                    "includeAll": false,
                                                    "showDefault": false
                                                },
                                                "timeContext": {
                                                    "durationMs": 86400000
                                                },
                                                "defaultValue": "value::all"
                                            },
                                            {
                                                "id": "b1ae8eeb-0570-482d-af41-aa81999ad44a",
                                                "version": "KqlParameterItem/1.0",
                                                "name": "resourceGroupPicker",
                                                "label": "Resource Group",
                                                "type": 2,
                                                "isRequired": true,
                                                "multiSelect": true,
                                                "quote": "'",
                                                "delimiter": ",",
                                                "query": "resources\r\n| where type == \"microsoft.storage/storageaccounts\"\r\n| project resourceGroup\r\n| distinct resourceGroup",
                                                "crossComponentResources": [
                                                    "{subscriptionPicker}"
                                                ],
                                                "value": [
                                                    "value::all"
                                                ],
                                                "typeSettings": {
                                                    "additionalResourceOptions": [
                                                        "value::all"
                                                    ],
                                                    "showDefault": false
                                                },
                                                "timeContext": {
                                                    "durationMs": 86400000
                                                },
                                                "defaultValue": "value::all",
                                                "queryType": 1,
                                                "resourceType": "microsoft.resourcegraph/resources"
                                            },
                                            {
                                                "id": "2a6e9715-65ac-4e99-8087-36d38c6df94b",
                                                "version": "KqlParameterItem/1.0",
                                                "name": "Kind",
                                                "type": 2,
                                                "isRequired": true,
                                                "multiSelect": true,
                                                "quote": "'",
                                                "delimiter": ",",
                                                "query": "resources\r\n| where type == \"microsoft.storage/storageaccounts\"\r\n| project kind\r\n| distinct kind",
                                                "crossComponentResources": [
                                                    "{subscriptionPicker}"
                                                ],
                                                "value": [
                                                    "value::all"
                                                ],
                                                "typeSettings": {
                                                    "additionalResourceOptions": [
                                                        "value::all"
                                                    ],
                                                    "showDefault": false
                                                },
                                                "timeContext": {
                                                    "durationMs": 86400000
                                                },
                                                "defaultValue": "value::all",
                                                "queryType": 1,
                                                "resourceType": "microsoft.resourcegraph/resources"
                                            },
                                            {
                                                "id": "666b1c22-c5a5-4363-aa7f-d23be60afd42",
                                                "version": "KqlParameterItem/1.0",
                                                "name": "EvidenManaged",
                                                "label": "Managed by Eviden",
                                                "type": 2,
                                                "isRequired": true,
                                                "multiSelect": true,
                                                "quote": "'",
                                                "delimiter": ",",
                                                "value": [
                                                    "value::all"
                                                ],
                                                "typeSettings": {
                                                    "additionalResourceOptions": [
                                                        "value::all"
                                                    ],
                                                    "showDefault": false
                                                },
                                                "jsonData": "[\"Yes\", \"No\"]",
                                                "timeContext": {
                                                    "durationMs": 86400000
                                                },
                                                "defaultValue": "value::all"
                                            }
                                        ],
                                        "style": "above",
                                        "queryType": 1,
                                        "resourceType": "microsoft.resourcegraph/resources"
                                    },
                                    "name": "parameters - 1"
                                },
                                {
                                    "type": 3,
                                    "content": {
                                        "version": "KqlItem/1.0",
                                        "query": "resources\r\n| where type == \"microsoft.storage/storageaccounts\"\r\n| extend SubscriptionId = split(id,\"/\")[2]\r\n| extend Name = tostring(split(id,\"/\")[8])\r\n| extend AccessTier=iif(notnull(properties.accessTier), properties.accessTier, \" \")\r\n| extend PublicAccess=iif(notnull(properties.allowBlobPublicAccess), properties.allowBlobPublicAccess, \" \")\r\n| extend EvidenManaged = iif((tostring(tags) has \"EvidenManaged\"), \"Yes\", \"No\")\r\n| extend Status=properties.status\r\n| where resourceGroup in ({resourceGroupPicker})\r\n| where EvidenManaged in ({EvidenManaged})\r\n| where kind in ({Kind})\r\n| project Name=id, Subscription=SubscriptionId, ResourceGroup=resourceGroup, Location=location, Kind=kind, ['Sku Name']=sku.name, ['Public Access']=PublicAccess, ['Access Tier']=AccessTier, EvidenManaged, Status=properties.statusOfPrimary\r\n",
                                        "size": 0,
                                        "queryType": 1,
                                        "resourceType": "microsoft.resourcegraph/resources",
                                        "crossComponentResources": [
                                            "{subscriptionPicker}"
                                        ],
                                        "gridSettings": {
                                            "formatters": [
                                                {
                                                    "columnMatch": "Subscription",
                                                    "formatter": 15,
                                                    "formatOptions": {
                                                        "linkTarget": null,
                                                        "showIcon": true
                                                    }
                                                },
                                                {
                                                    "columnMatch": "Status",
                                                    "formatter": 18,
                                                    "formatOptions": {
                                                        "thresholdsOptions": "icons",
                                                        "thresholdsGrid": [
                                                            {
                                                                "operator": "startsWith",
                                                                "thresholdValue": "available",
                                                                "representation": "success",
                                                                "text": "{0}{1}"
                                                            },
                                                            {
                                                                "operator": "Default",
                                                                "thresholdValue": null,
                                                                "representation": "2",
                                                                "text": "{0}{1}"
                                                            }
                                                        ]
                                                    }
                                                },
                                                {
                                                    "columnMatch": "SubscriptionId",
                                                    "formatter": 15,
                                                    "formatOptions": {
                                                        "linkTarget": null,
                                                        "showIcon": true
                                                    }
                                                }
                                            ]
                                        }
                                    },
                                    "conditionalVisibility": {
                                        "parameterName": "resourceGroupPicker",
                                        "comparison": "isNotEqualTo"
                                    },
                                    "name": "query - 2"
                                },
                                {
                                    "type": 1,
                                    "content": {
                                        "json": "#### No Azure Storage Accounts are deployed in this environment yet"
                                    },
                                    "conditionalVisibility": {
                                        "parameterName": "resourceGroupPicker",
                                        "comparison": "isEqualTo"
                                    },
                                    "name": "text - 2"
                                }
                            ]
                        },
                        "name": "group - 0"
                    }
                ],
                "isLocked": false
            }
        }
    }
}
```