# dashboard/dashboard.bicep
Bicep module to create Azure Shared Dashboards .

## Module Features
Module can deploy a shared Dashboard.

## Module Example Use
```hcl
module coreDashboard './dashboard.bicep' = {
  name: guid(dashboardDisplayName)
  params: {
    dashboardDisplayName: dashboardDisplayName
    location: location
    tags:{   
    }
    dashBoardLenses: coreDBLenses 
  }
}
```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `dashboardDisplayName` | `string` | true | Specifies the name of the dashboard. Valid characters: Alphanumerics and hyphens, no spaces. |
| `location` | `string` | false| Specifies the location where the resource will be deployed. |
| `tags` | `object` | false | A mapping of tags to assign to the resource. Additional Details [here](#object---tags).|
| `dashboardLenses:` | `object` | true | Specifies the parts of the dashboard resource like workbook and link tiles with their configuration. This is an object containing the json code of the lenses for the dashBoard. For details check the [parameter example](#parameters-file-example)|

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
| `dashboardResourceId` | The resource ID of the created dashboard resource. | `dashboard.id` |


## Parameters file example
```json
{
    "$schema" : "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
"contentVersion": "1.0.0.0",
"parameters": {
  "dashboardDisplayName": {
    "value": "BICEPCOREDASHBOARD"
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
  "dashboardLenses": {
    "value": {
      "0": {
        "order": 0,
        "parts": {
          "0": {
            "position": {
              "x": 2,
              "y": 0,
              "colSpan": 2,
              "rowSpan": 11
            },
            "metadata": {
              "inputs": [],
              "type": "Extension/HubsExtension/PartType/MarkdownPart",
              "settings": {
                "content": {
                  "settings": {
                    "content": "\tTenant Users\t\n[<img width=\"80\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-Tenant-users.svg\"/>](https://portal.azure.com/#blade/Microsoft_AAD_IAM/UsersManagementMenuBlade/MsGraphUsers)\n\n\tTenant Groups\n[<img width=\"80\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-Tenant-groups.svg\"/>](https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupsManagementMenuBlade/AllGroups)\n\n\tRoles and Admins\n[<img width=\"80\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-Roles-and-admins.svg\"/>](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RolesAndAdministrators)\n\n\tApp Registrations\n[<img width=\"80\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-App-registrations.svg\" />](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps)\n\n\tSubscription Roles\n[<img width=\"80\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-IAM.svg\"/>](https://portal.azure.com/#blade/Microsoft_Azure_Storage/ContainerMenuBlade/overview/storageAccountId/%2Fsubscriptions%2F759b3d1a-ba3b-46d7-a33c-76c0c6c75932%2FresourceGroups%2Fdv4-mgmt-t-rsg-reporting%2Fproviders%2FMicrosoft.Storage%2FstorageAccounts%2Fdv4treportingdj3ot7y5rw/path/iamsubscriptionreport)",
                    "title": "IAM Reports",
                    "subtitle": "",
                    "markdownSource": 1
                  }
                }
              }
            }
          },
          "1": {
            "position": {
              "x": 4,
              "y": 0,
              "colSpan": 6,
              "rowSpan": 3
            },
            "metadata": {
              "inputs": [],
              "type": "Extension/HubsExtension/PartType/MarkdownPart",
              "settings": {
                "content": {
                  "settings": {
                    "content": "<img width=\"450\" style=\"float: center;margin-left: 20px;margin-top:8px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-main-logo.jpg\"/>\n\n<div style=\"padding-left:4.00em;\">Eviden Landing Zones for Azure - Cloud Core Reporting dashboard </div><div style=\"padding-left:4.00em;\">Release 2.3 <a href=\"https://docs.cloud.eviden.com/02.%20Eviden%20Landing%20Zones/02.%20AZURE/01.-Release-Notes/000-Overview/\" target=\"\">(Release Notes) </div>",
                    "title": "",
                    "subtitle": "",
                    "markdownSource": 1,
                    "markdownUri": "https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-main-logo.jpg"
                  }
                }
              }
            }
          },
          "2": {
            "position": {
              "x": 4,
              "y": 3,
              "colSpan": 4,
              "rowSpan": 3
            },
            "metadata": {
              "inputs": [],
              "type": "Extension/HubsExtension/PartType/MarkdownPart",
              "settings": {
                "content": {
                  "settings": {
                    "content": "\tFirst time using this dashboard? \n\tClick the image below to get started.\n[<img width=\"80\" style=\"float: center;margin-left: 120px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-Cloud.svg\"/>](https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-Cloud-Core-Reporting-Dashboard-Manual.pdf)",
                    "title": "Getting Started with Cloud Core Reporting",
                    "subtitle": "",
                    "markdownSource": 1
                  }
                }
              }
            }
          },
          "3": {
            "position": {
              "x": 8,
              "y": 3,
              "colSpan": 2,
              "rowSpan": 3
            },
            "metadata": {
              "inputs": [],
              "type": "Extension/HubsExtension/PartType/MarkdownPart",
              "settings": {
                "content": {
                  "settings": {
                    "content": "\tTicketing\t\n[<img width=\"80\" style=\"float: center;margin-left: 30px;margin-top:20px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-Support.svg\"/>]()",
                    "title": "Help + Support",
                    "subtitle": "Placeholder",
                    "markdownSource": 1
                  }
                }
              }
            }
          },
          "4": {
            "position": {
              "x": 4,
              "y": 6,
              "colSpan": 2,
              "rowSpan": 5
            },
            "metadata": {
              "inputs": [],
              "type": "Extension/HubsExtension/PartType/MarkdownPart",
              "settings": {
                "content": {
                  "settings": {
                    "content": "\tIncident Report\n[<img width=\"80\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-PDF.svg\"/>](https://portal.azure.com/#blade/Microsoft_Azure_Storage/ContainerMenuBlade/overview/storageAccountId/%2Fsubscriptions%2F759b3d1a-ba3b-46d7-a33c-76c0c6c75932%2FresourceGroups%2Fdv4-mgmt-t-rsg-reporting%2Fproviders%2FMicrosoft.Storage%2FstorageAccounts%2Fdv4treportingdj3ot7y5rw/path/incidentchangereport)\n\n\tChange Report\n[<img width=\"80\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-PDF.svg\"/>](https://portal.azure.com/#blade/Microsoft_Azure_Storage/ContainerMenuBlade/overview/storageAccountId/%2Fsubscriptions%2F759b3d1a-ba3b-46d7-a33c-76c0c6c75932%2FresourceGroups%2Fdv4-mgmt-t-rsg-reporting%2Fproviders%2FMicrosoft.Storage%2FstorageAccounts%2Fdv4treportingdj3ot7y5rw/path/incidentchangereport)\n",
                    "title": "Operational Reports",
                    "subtitle": "",
                    "markdownSource": 1
                  }
                }
              }
            }
          },
          "5": {
            "position": {
              "x": 6,
              "y": 6,
              "colSpan": 2,
              "rowSpan": 5
            },
            "metadata": {
              "inputs": [],
              "type": "Extension/HubsExtension/PartType/MarkdownPart",
              "settings": {
                "content": {
                  "settings": {
                    "content": "\tPol. Assignments\n[<img width=\"80\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-Policy.svg\"/>](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Assignments)\n\n\tPol. Compliance\n[<img width=\"80\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-Compliant.svg\"/>](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Compliance)\n",
                    "title": "Policy Reports",
                    "subtitle": "",
                    "markdownSource": 1
                  }
                }
              }
            }
          },
          "6": {
            "position": {
              "x": 8,
              "y": 6,
              "colSpan": 2,
              "rowSpan": 5
            },
            "metadata": {
              "inputs": [],
              "type": "Extension/HubsExtension/PartType/MarkdownPart",
              "settings": {
                "content": {
                  "settings": {
                    "content": "\tCost Management\n[<img width=\"80\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-Cost-overview.svg\"/>](https://portal.azure.com/#blade/Microsoft_Azure_CostManagement/Menu/costanalysis)\n\n\tCost Advisor\n[<img width=\"80\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-Cost-efficiency.svg\"/>](https://portal.azure.com/#blade/Microsoft_Azure_CostManagement/Menu/costrecommendations)\n\n\n",
                    "title": "Financial Reports",
                    "subtitle": "",
                    "markdownSource": 1
                  }
                }
              }
            }
          },
          "7": {
            "position": {
              "x": 4,
              "y": 11,
              "colSpan": 2,
              "rowSpan": 2
            },
            "metadata": {
              "inputs": [
                {
                  "name": "ComponentId",
                  "value": {
                    "Name": "Azure Monitor",
                    "ResourceId": "Azure Monitor",
                    "LinkedApplicationType": -2
                  }
                },
                {
                  "name": "ResourceIds",
                  "value": [
                    "Azure Monitor"
                  ],
                  "isOptional": true
                },
                {
                  "name": "Type",
                  "value": "workbook",
                  "isOptional": true
                },
                {
                  "name": "TimeContext",
                  "isOptional": true
                },
                {
                  "name": "ConfigurationId",
                  "value": "/subscriptions/759b3d1a-ba3b-46d7-a33c-76c0c6c75932/resourceGroups/dv4-mgmt-t-rsg-reporting/providers/Microsoft.Insights/workbooks/0c60cb2f-f15e-5e70-94f4-14e02079e21b",
                  "isOptional": true
                },
                {
                  "name": "ViewerMode",
                  "value": false,
                  "isOptional": true
                },
                {
                  "name": "GalleryResourceType",
                  "value": "Azure Monitor",
                  "isOptional": true
                },
                {
                  "name": "NotebookParams",
                  "isOptional": true
                },
                {
                  "name": "Location",
                  "value": "UK South",
                  "isOptional": true
                },
                {
                  "name": "Version",
                  "value": "1.0",
                  "isOptional": true
                }
              ],
              "type": "Extension/AppInsightsExtension/PartType/NotebookPinnedPart",
              "viewState": {
                "content": {
                  "configurationId": "/subscriptions/759b3d1a-ba3b-46d7-a33c-76c0c6c75932/resourceGroups/dv4-mgmt-t-rsg-reporting/providers/Microsoft.Insights/workbooks/0c60cb2f-f15e-5e70-94f4-14e02079e21b"
                }
              }
            }
          },
          "8": {
            "position": {
              "x": 6,
              "y": 11,
              "colSpan": 2,
              "rowSpan": 2
            },
            "metadata": {
              "inputs": [
                {
                  "name": "ComponentId",
                  "value": {
                    "Name": "Azure Monitor",
                    "ResourceId": "Azure Monitor",
                    "LinkedApplicationType": -2
                  }
                },
                {
                  "name": "ResourceIds",
                  "value": [
                    "Azure Monitor"
                  ],
                  "isOptional": true
                },
                {
                  "name": "Type",
                  "value": "workbook",
                  "isOptional": true
                },
                {
                  "name": "TimeContext",
                  "isOptional": true
                },
                {
                  "name": "ConfigurationId",
                  "value": "/subscriptions/759b3d1a-ba3b-46d7-a33c-76c0c6c75932/resourceGroups/dv4-mgmt-t-rsg-reporting/providers/Microsoft.Insights/workbooks/5935553c-3279-57d8-8d2c-8d2ef020ae9c",
                  "isOptional": true
                },
                {
                  "name": "ViewerMode",
                  "value": false,
                  "isOptional": true
                },
                {
                  "name": "GalleryResourceType",
                  "value": "Azure Monitor",
                  "isOptional": true
                },
                {
                  "name": "NotebookParams",
                  "isOptional": true
                },
                {
                  "name": "Location",
                  "value": "UK South",
                  "isOptional": true
                },
                {
                  "name": "Version",
                  "value": "1.0",
                  "isOptional": true
                }
              ],
              "type": "Extension/AppInsightsExtension/PartType/NotebookPinnedPart",
              "viewState": {
                "content": {
                  "configurationId": "/subscriptions/759b3d1a-ba3b-46d7-a33c-76c0c6c75932/resourceGroups/dv4-mgmt-t-rsg-reporting/providers/Microsoft.Insights/workbooks/5935553c-3279-57d8-8d2c-8d2ef020ae9c"
                }
              }
            }
          },
          "9": {
            "position": {
              "x": 8,
              "y": 11,
              "colSpan": 2,
              "rowSpan": 2
            },
            "metadata": {
              "inputs": [],
              "type": "Extension/HubsExtension/PartType/MarkdownPart",
              "settings": {
                "content": {
                  "settings": {
                    "content": "[<img width=\"75\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-Security-Shield.svg\"/>](https://portal.azure.com/#blade/Microsoft_Azure_Security/SecurityMenuBlade/0\n)",
                    "title": "Compliance Report",
                    "subtitle": "",
                    "markdownSource": 1
                  }
                }
              }
            }
          },
          "10": {
            "position": {
              "x": 4,
              "y": 13,
              "colSpan": 2,
              "rowSpan": 2
            },
            "metadata": {
              "inputs": [
                {
                  "name": "ComponentId",
                  "value": {
                    "Name": "Azure Monitor",
                    "ResourceId": "Azure Monitor",
                    "LinkedApplicationType": -2
                  }
                },
                {
                  "name": "ResourceIds",
                  "value": [
                    "Azure Monitor"
                  ],
                  "isOptional": true
                },
                {
                  "name": "Type",
                  "value": "workbook",
                  "isOptional": true
                },
                {
                  "name": "TimeContext",
                  "isOptional": true
                },
                {
                  "name": "ConfigurationId",
                  "value": "/subscriptions/759b3d1a-ba3b-46d7-a33c-76c0c6c75932/resourceGroups/dv4-mgmt-t-rsg-reporting/providers/Microsoft.Insights/workbooks/7c4a98e9-d92f-5453-960f-b32ede31320b",
                  "isOptional": true
                },
                {
                  "name": "ViewerMode",
                  "value": false,
                  "isOptional": true
                },
                {
                  "name": "GalleryResourceType",
                  "value": "Azure Monitor",
                  "isOptional": true
                },
                {
                  "name": "NotebookParams",
                  "isOptional": true
                },
                {
                  "name": "Location",
                  "value": "UK South",
                  "isOptional": true
                },
                {
                  "name": "Version",
                  "value": "1.0",
                  "isOptional": true
                }
              ],
              "type": "Extension/AppInsightsExtension/PartType/NotebookPinnedPart",
              "viewState": {
                "content": {
                  "configurationId": "/subscriptions/759b3d1a-ba3b-46d7-a33c-76c0c6c75932/resourceGroups/dv4-mgmt-t-rsg-reporting/providers/Microsoft.Insights/workbooks/7c4a98e9-d92f-5453-960f-b32ede31320b"
                }
              }
            }
          },
          "11": {
            "position": {
              "x": 2,
              "y": 11,
              "colSpan": 2,
              "rowSpan": 2
            },
            "metadata": {
              "inputs": [],
              "type": "Extension/HubsExtension/PartType/MarkdownPart",
              "settings": {
                "content": {
                  "settings": {
                    "content": "[<img width=\"75\" style=\"float: center;margin-left: 30px;margin-top:3px;margin-bottom:14px\" position=\"center\" src=\"https://dv4treportingdj3ot7y5rw.blob.core.windows.net/artifacts/Eviden-Document-Multiple.svg\"/>](https://portal.azure.com/#blade/Microsoft_Azure_Storage/ContainerMenuBlade/overview/storageAccountId/%2Fsubscriptions%2F759b3d1a-ba3b-46d7-a33c-76c0c6c75932%2FresourceGroups%2Fdv4-mgmt-t-rsg-reporting%2Fproviders%2FMicrosoft.Storage%2FstorageAccounts%2Fdv4treportingdj3ot7y5rw/path/offlinereports)",
                    "title": "Offline Reports",
                    "subtitle": "",
                    "markdownSource": 1
                  }
                }
              }
            }
          },
          "12": {
            "position": {
              "x": 6,
              "y": 13,
              "colSpan": 2,
              "rowSpan": 2
            },
            "metadata": {
              "inputs": [
                {
                  "name": "ComponentId",
                  "value": {
                    "Name": "Azure Monitor",
                    "ResourceId": "Azure Monitor",
                    "LinkedApplicationType": -2
                  }
                },
                {
                  "name": "ResourceIds",
                  "value": [
                    "Azure Monitor"
                  ],
                  "isOptional": true
                },
                {
                  "name": "Type",
                  "value": "workbook",
                  "isOptional": true
                },
                {
                  "name": "TimeContext",
                  "isOptional": true
                },
                {
                  "name": "ConfigurationId",
                  "value": "/subscriptions/759b3d1a-ba3b-46d7-a33c-76c0c6c75932/resourceGroups/dv4-mgmt-t-rsg-reporting/providers/Microsoft.Insights/workbooks/35cf9b8c-0d28-5ebd-99a6-1c436bd16ba8",
                  "isOptional": true
                },
                {
                  "name": "ViewerMode",
                  "value": false,
                  "isOptional": true
                },
                {
                  "name": "GalleryResourceType",
                  "value": "Azure Monitor",
                  "isOptional": true
                },
                {
                  "name": "NotebookParams",
                  "isOptional": true
                },
                {
                  "name": "Location",
                  "value": "UK South",
                  "isOptional": true
                },
                {
                  "name": "Version",
                  "value": "1.0",
                  "isOptional": true
                }
              ],
              "type": "Extension/AppInsightsExtension/PartType/NotebookPinnedPart",
              "viewState": {
                "content": {
                  "configurationId": "/subscriptions/759b3d1a-ba3b-46d7-a33c-76c0c6c75932/resourceGroups/dv4-mgmt-t-rsg-reporting/providers/Microsoft.Insights/workbooks/35cf9b8c-0d28-5ebd-99a6-1c436bd16ba8"
                }
              }
            }
          },
          "13": {
            "position": {
              "x": 2,
              "y": 13,
              "colSpan": 2,
              "rowSpan": 2
            },
            "metadata": {
              "inputs": [
                {
                  "name": "ComponentId",
                  "value": {
                    "Name": "Azure Monitor",
                    "ResourceId": "Azure Monitor",
                    "LinkedApplicationType": -2
                  }
                },
                {
                  "name": "ResourceIds",
                  "value": [
                    "Azure Monitor"
                  ],
                  "isOptional": true
                },
                {
                  "name": "Type",
                  "value": "workbook",
                  "isOptional": true
                },
                {
                  "name": "TimeContext",
                  "isOptional": true
                },
                {
                  "name": "ConfigurationId",
                  "value": "/subscriptions/759b3d1a-ba3b-46d7-a33c-76c0c6c75932/resourceGroups/dv4-mgmt-t-rsg-reporting/providers/Microsoft.Insights/workbooks/9039b0db-3c3a-516d-a0df-c52bc3e54b80",
                  "isOptional": true
                },
                {
                  "name": "ViewerMode",
                  "value": false,
                  "isOptional": true
                },
                {
                  "name": "GalleryResourceType",
                  "value": "Azure Monitor",
                  "isOptional": true
                },
                {
                  "name": "NotebookParams",
                  "isOptional": true
                },
                {
                  "name": "Location",
                  "value": "UK South",
                  "isOptional": true
                },
                {
                  "name": "Version",
                  "value": "1.0",
                  "isOptional": true
                }
              ],
              "type": "Extension/AppInsightsExtension/PartType/NotebookPinnedPart",
              "viewState": {
                "content": {
                  "configurationId": "/subscriptions/759b3d1a-ba3b-46d7-a33c-76c0c6c75932/resourceGroups/dv4-mgmt-t-rsg-reporting/providers/Microsoft.Insights/workbooks/9039b0db-3c3a-516d-a0df-c52bc3e54b80"
                }
              }
            }
          },
          "14": {
            "position": {
              "x": 8,
              "y": 13,
              "colSpan": 2,
              "rowSpan": 2
            },
            "metadata": {
              "inputs": [
                {
                  "name": "ComponentId",
                  "value": {
                    "Name": "Azure Monitor",
                    "ResourceId": "Azure Monitor",
                    "LinkedApplicationType": -2
                  }
                },
                {
                  "name": "ResourceIds",
                  "value": [
                    "Azure Monitor"
                  ],
                  "isOptional": true
                },
                {
                  "name": "Type",
                  "value": "workbook",
                  "isOptional": true
                },
                {
                  "name": "TimeContext",
                  "isOptional": true
                },
                {
                  "name": "ConfigurationId",
                  "value": "/subscriptions/759b3d1a-ba3b-46d7-a33c-76c0c6c75932/resourceGroups/dv4-mgmt-t-rsg-reporting/providers/Microsoft.Insights/workbooks/c450fbdc-b2a7-5491-ac14-4add40349cbf",
                  "isOptional": true
                },
                {
                  "name": "ViewerMode",
                  "value": false,
                  "isOptional": true
                },
                {
                  "name": "GalleryResourceType",
                  "value": "Azure Monitor",
                  "isOptional": true
                },
                {
                  "name": "NotebookParams",
                  "isOptional": true
                },
                {
                  "name": "Location",
                  "value": "UK South",
                  "isOptional": true
                },
                {
                  "name": "Version",
                  "value": "1.0",
                  "isOptional": true
                }
              ],
              "type": "Extension/AppInsightsExtension/PartType/NotebookPinnedPart",
              "viewState": {
                "content": {
                  "configurationId": "/subscriptions/759b3d1a-ba3b-46d7-a33c-76c0c6c75932/resourceGroups/dv4-mgmt-t-rsg-reporting/providers/Microsoft.Insights/workbooks/c450fbdc-b2a7-5491-ac14-4add40349cbf"
                }
              }
            }
          }
        }
      }
    },
    "metadata": {
      "model": {
        "timeRange": {
          "value": {
            "relative": {
              "duration": 24,
              "timeUnit": 1
            }
          },
          "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        },
        "filterLocale": {
          "value": "en-us"
        },
        "filters": {
          "value": {
            "MsPortalFx_TimeRange": {
              "model": {
                "format": "utc",
                "granularity": "auto",
                "relative": "24h"
              },
              "displayCache": {
                "name": "UTC Time",
                "value": "Past 24 hours"
              },
              "filteredPartIds": []
            }
          }
        }
      }
    }
  },
  "name": "CloudCoreReportingDashboard",
  "type": "Microsoft.Portal/dashboards",
  "location": "INSERT LOCATION",
  "tags": {
    "hidden-title": "CloudCoreReportingDashboard"
  },
  "apiVersion": "2015-08-01-preview"
}
}
```