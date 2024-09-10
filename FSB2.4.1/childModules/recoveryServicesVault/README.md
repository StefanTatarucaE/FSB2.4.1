# recoveryServicesVault/recoveryServicesVault
Bicep module to create an Azure Recovery Services Vault and the backup policies.

## Description
The module will create a recovery services vault with below pre-defined Eviden Backup policies for IaaS VM:
- Bronze
- Silver
- Gold


## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `recoveryServicesVaultName` | `string` | true | Name of the Recovery Services Vault. |
| `location` | `string` | true| Specify the location where logic app is to be created |
| `backupStorageType` | `string` | true| Storage tier. Allowed values: GeoRedundant, LocallyRedundant. |
| `storageTypeState` | `string` | true| Locked or Unlocked. Once a machine is registered against a resource, the storageTypeState is always Locked. Allowed values are,Invalid','Locked','Unlocked'|
| `backupPolicyConfigurations` | `object` | true| A JSON structure used to specify the backup policy configuration. For predefined ELZ backup policies (Bronze, Silver, Gold) use EvidenELZ as input parameter in an array. For custom backup policies, input the JSON structure. For more information about JSON structure, visit https://docs.cloud.eviden.com/02.%20Eviden%20Landing%20Zones/02.%20AZURE/02.-Release-2.3/02.-Solutions/09.-VM-OS-Management/01.-Low-Level-Design/01.-Design-Decisions/001-Recovery-Services-Vault/. Additional Details [here](#object---backuppolicyconfigurations).|
| `tags` | `object` | true| A mapping of tags to assign to the resource. Additional Details [here](#object---tags).|
| `utcShort` | `object` | false| Returns the current (UTC) datetime value in the RFC1123 pattern format. 2009-06-15T13:45:30 -> Mon, 15 Jun 2009 20:45:30 GMT.|


### Object - backupPolicyConfigurations
| Name | Type  | Description |
| --- | --- | --- | 
| `list` | `array`  | List of objects of type backupPolicyConfigurations.  Additional Details [here](#array---list)|


#### Array - list
| Name | Type  | Description |
| --- | --- | --- | 
| `backupTagNamePrefix` | `string`  | Pre-defined EvidenBackup policies prefix for IaaS VM. Allowed values "Gold", "Silver", "Bronze"  |
| `scheduleStartTime` | `string`  | Scheduled time for the policies to start the backup.  Currently this is same for all, daily weekly monthly and yearly as this is the defaults behaviour.|
| `properties` | `string`  | ProtectionPolicyResource properties. See details [here](https://docs.microsoft.com/azure/templates/microsoft.recoveryservices/vaults/backuppolicies?pivots=deployment-language-bicep#protectionpolicy). |

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


## Parameters file example
Below is the sample parameter file with one backup policy (bronze) and other configuration.
Please refer to the TEMPLATE.params.json file as initial parameter settings in the module directory.
```json

{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "recoveryServicesVaultName": {
            "value": "mibtestbackupvault"
        },
        "storageTypeState": {
            "value": "Unlocked"
        },
        "backupPolicyConfigurations": {
            "value": {
                "list": [
                    {
                        "backupTagNamePrefix": "Bronze",
                        "scheduleStartTime":"09:00",
                        "properties": {
                            "backupManagementType": "AzureIaasVM",
                            "instantRpRetentionRangeInDays": "5",
                            "schedulePolicy": {
                                "scheduleRunFrequency": "Daily",
                                "scheduleRunDays": null,
                                "schedulePolicyType": "SimpleSchedulePolicy"
                            },
                            "retentionPolicy": {
                                "dailySchedule": {
                                    "retentionDuration": {
                                        "count": "15",
                                        "durationType": "Days"
                                    }
                                },
                                "weeklySchedule": {
                                    "daysOfTheWeek": [
                                        "Sunday",
                                        "Tuesday",
                                        "Thursday"
                                    ],
                                    "retentionDuration": {
                                        "count": "8",
                                        "durationType": "Weeks"
                                    }
                                },
                                "monthlySchedule": {
                                    "retentionScheduleFormatType": "Daily",
                                    "retentionScheduleDaily": {
                                        "daysOfTheMonth": [
                                            {
                                                "date": 1,
                                                "isLast": false
                                            }
                                        ]
                                    },
                                    "retentionScheduleWeekly": null,
                                    "retentionDuration": {
                                        "count": "6",
                                        "durationType": "Months"
                                    }
                                },
                                "yearlySchedule": {
                                    "retentionScheduleFormatType": "Daily",
                                    "monthsOfYear": [
                                        "January",
                                        "March",
                                        "August"
                                    ],
                                    "retentionScheduleDaily": {
                                        "daysOfTheMonth": [
                                            {
                                                "date": 1,
                                                "isLast": false
                                            }
                                        ]
                                    },
                                    "retentionScheduleWeekly": null,
                                    "retentionDuration": {
                                        "count": "2",
                                        "durationType": "Years"
                                    }
                                },
                                "retentionPolicyType": "LongTermRetentionPolicy"
                            },
                            "timeZone": "UTC"
                        }
                    },
                    {
                        "backupTagNamePrefix": "Silver",
                        "scheduleStartTime":"09:00",
                        "properties": {
                            "backupManagementType": "AzureIaasVM",
                            "instantRpRetentionRangeInDays": "5",
                            "schedulePolicy": {
                                "scheduleRunFrequency": "Weekly",
                                "scheduleRunDays": [
                                    "Sunday",
                                    "Tuesday",
                                    "Thursday"
                                ],
                                "schedulePolicyType": "SimpleSchedulePolicy",
                                "scheduleWeeklyFrequency": 0
                            },
                            "retentionPolicy": {
                                "weeklySchedule": {
                                    "daysOfTheWeek": [
                                        "Sunday",
                                        "Tuesday",
                                        "Thursday"
                                    ],
                                    "retentionDuration": {
                                        "count": "8",
                                        "durationType": "Weeks"
                                    }
                                },
                                "monthlySchedule": {
                                    "retentionScheduleFormatType": "Weekly",
                                    "retentionScheduleDaily": null,
                                    "retentionScheduleWeekly": {
                                        "daysOfTheWeek": [
                                            "Sunday"
                                        ],
                                        "weeksOfTheMonth": [
                                            "First"
                                        ]
                                    },
                                    "retentionDuration": {
                                        "count": "6",
                                        "durationType": "Months"
                                    }
                                },
                                "yearlySchedule": {
                                    "retentionScheduleFormatType": "Weekly",
                                    "monthsOfYear": [
                                        "January",
                                        "March",
                                        "August"
                                    ],
                                    "retentionScheduleDaily": null,
                                    "retentionScheduleWeekly": {
                                        "daysOfTheWeek": [
                                            "Sunday"
                                        ],
                                        "weeksOfTheMonth": [
                                            "First"
                                        ]
                                    },
                                    "retentionDuration": {
                                        "count": "2",
                                        "durationType": "Years"
                                    }
                                },
                                "retentionPolicyType": "LongTermRetentionPolicy"
                            },
                            "timeZone": "UTC"
                        }
                    },
                    {
                        "backupTagNamePrefix": "Gold",
                        "scheduleStartTime":"09:00",
                        "properties": {
                            "backupManagementType": "AzureIaasVM",
                            "instantRpRetentionRangeInDays": "5",
                            "schedulePolicy": {
                                "scheduleRunFrequency": "Daily",
                                "scheduleRunDays": null,
                                "schedulePolicyType": "SimpleSchedulePolicy"
                            },
                            "retentionPolicy": {
                                "dailySchedule": {
                                    "retentionDuration": {
                                        "count": "15",
                                        "durationType": "Days"
                                    }
                                },
                                "weeklySchedule": {
                                    "daysOfTheWeek": [
                                        "Sunday",
                                        "Tuesday",
                                        "Thursday"
                                    ],
                                    "retentionDuration": {
                                        "count": "8",
                                        "durationType": "Weeks"
                                    }
                                },
                                "monthlySchedule": {
                                    "retentionScheduleFormatType": "Daily",
                                    "retentionScheduleDaily": {
                                        "daysOfTheMonth": [
                                            {
                                                "date": 1,
                                                "isLast": false
                                            }
                                        ]
                                    },
                                    "retentionScheduleWeekly": null,
                                    "retentionDuration": {
                                        "count": "6",
                                        "durationType": "Months"
                                    }
                                },
                                "yearlySchedule": {
                                    "retentionScheduleFormatType": "Daily",
                                    "monthsOfYear": [
                                        "January",
                                        "March",
                                        "August"
                                    ],
                                    "retentionScheduleDaily": {
                                        "daysOfTheMonth": [
                                            {
                                                "date": 1,
                                                "isLast": false
                                            }
                                        ]
                                    },
                                    "retentionScheduleWeekly": null,
                                    "retentionDuration": {
                                        "count": "2",
                                        "durationType": "Years"
                                    }
                                },
                                "retentionPolicyType": "LongTermRetentionPolicy"
                            },
                            "timeZone": "UTC"
                        }
                    }
                ]
            }
        },
        "backupStorageType": {
            "value": "GeoRedundant"
        },
        "tags": {
            "value": {
                "Owner": "Muhammad Ibrahim",
                "Project": "Test Bicep",
                "UserStory": "DCSAZ-xxx",
                "EvidenManaged": "true"
            }
        }
    }
}
```
