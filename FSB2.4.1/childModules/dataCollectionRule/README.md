# dataCollectionRule/dataCollectionRule.bicep
Bicep module to create a Data Collection Rule for Azure monitoring agent.

## Description
Azure Monitor data collection is configured using a data collection rule (DCR).

A DCR defines the details of a particular data collection scenario including what data should be collected, how to potentially transform that data, and where to send that data.

## Module example use
```hcl
module dataCollectionRules '../../childModules/dataCollectionRule/dataCollectionRule.bicep' = [ for (dataCollectionRule, index) in dataCollectionRuleList : if (subscriptionType == 'mgmt') {
scope: monitoringResourceGroup
name: '${dataCollectionRule.dataCollectionRuleName}-${index}-deployment'
params: {
  dataCollectionRuleName: 'dcrlinux001'
  dcrKind: 'Linux'
  location: location
  dataFlowsDestinations: [
    "dv5-mgmt-d-loganalytics"
    ]
  dataFlowStreams: {
              "streams" : [
                "Microsoft-Perf",
                "Microsoft-Syslog"
              ]
  dcrDataSource: {
              "performanceCounters" : [
                {
                  "name": "DS_LinuxPerformanceObject_1",
                  "streams": [
                    "Microsoft-Perf"
                  ],
                  "samplingFrequencyInSeconds" : 120,
                  "counterSpecifiers" : [
                    "\\Memory(*)\\Available MBytes Memory",
                    "\\Memory(*)\\% Used Memory",
                    "\\Memory(*)\\% Used Swap Space"
                  ],
                  "platformType" : "Linux"
                },
                {
                  "name" : "DS_LinuxPerformanceObject_2",
                  "streams" : [
                    "Microsoft-Perf"
                  ],
                  "samplingFrequencyInSeconds" : 120,
                  "counterSpecifiers" : [
                    "\\Network(*)\\Total Bytes Transmitted",
                    "\\Network(*)\\Total Bytes Received"
                  ],
                  "platformType" : "Linux"
                },
                {
                  "name" : "DS_LinuxPerformanceObject_3",
                  "streams" : [
                    "Microsoft-Perf"
                  ],
                  "samplingFrequencyInSeconds" : 10 ,
                  "counterSpecifiers" : [
                    "\\Processor(*)\\% Processor Time",
                    "\\Processor(*)\\% Privileged Time"
                  ],
                  "platformType": "Linux"
                },
                {
                  "name" : "DS_LinuxPerformanceObject_4",
                  "streams" : [
                    "Microsoft-Perf"
                  ],
                  "samplingFrequencyInSeconds" : 120,
                  "counterSpecifiers" : [
                    "\\Logical Disk(*)\\% Free Space",
                    "\\Logical Disk(*)\\% Used Inodes",
                    "\\Logical Disk(*)\\Free Megabytes",
                    "\\Logical Disk(*)\\% Used Space",
                    "\\Logical Disk(*)\\Disk Transfers/sec",
                    "\\Logical Disk(*)\\Disk Reads/sec",
                    "\\Logical Disk(*)\\Disk Writes/sec"
                  ],
                  "platformType" : "Linux"
                }
              ]
            }
  workspaceName: dv5-mgmt-d-loganalytics
  workspaceResourceId: existingWorkspaceInMgmt.outputs.resourceID
}
}]
```

## Module Arguments
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `location` | `string` | DCR deployment location  |
| `dataCollectionRuleName` | `string` | DCR name , this should be unique in resource grpup |
| `dcrKind` | `string` | Kind of DCR  (Windows \ Linux) |
| `workspaceResourceId` | `string` | Azure Resource ID of Log analyatics workspace to store logs. |
| `workspaceName` | `string` | Name of log analyatics workspace to store logs. |
| `dcrDataSource` | `object` |  DCR Data source Object |
| `dataFlowStreams` | `array` | DCR Dataflow streams Object  |
| `dataFlowsDestinations` | `array` | DCR Dataflow destinations object array |

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "dataCollectionRules": {
        "value": [
          {
            "dataCollectionRuleName": "dcrlinux001",
            "kind": "Linux",
            "dataSource": {
              "performanceCounters" : [
                {
                  "name": "DS_LinuxPerformanceObject_1",
                  "streams": [
                    "Microsoft-Perf"
                  ],
                  "samplingFrequencyInSeconds" : 120,
                  "counterSpecifiers" : [
                    "\\Memory(*)\\Available MBytes Memory",
                    "\\Memory(*)\\% Used Memory",
                    "\\Memory(*)\\% Used Swap Space"
                  ],
                  "platformType" : "Linux"
                },
                {
                  "name" : "DS_LinuxPerformanceObject_2",
                  "streams" : [
                    "Microsoft-Perf"
                  ],
                  "samplingFrequencyInSeconds" : 120,
                  "counterSpecifiers" : [
                    "\\Network(*)\\Total Bytes Transmitted",
                    "\\Network(*)\\Total Bytes Received"
                  ],
                  "platformType" : "Linux"
                },
                {
                  "name" : "DS_LinuxPerformanceObject_3",
                  "streams" : [
                    "Microsoft-Perf"
                  ],
                  "samplingFrequencyInSeconds" : 10 ,
                  "counterSpecifiers" : [
                    "\\Processor(*)\\% Processor Time",
                    "\\Processor(*)\\% Privileged Time"
                  ],
                  "platformType": "Linux"
                },
                {
                  "name" : "DS_LinuxPerformanceObject_4",
                  "streams" : [
                    "Microsoft-Perf"
                  ],
                  "samplingFrequencyInSeconds" : 120,
                  "counterSpecifiers" : [
                    "\\Logical Disk(*)\\% Free Space",
                    "\\Logical Disk(*)\\% Used Inodes",
                    "\\Logical Disk(*)\\Free Megabytes",
                    "\\Logical Disk(*)\\% Used Space",
                    "\\Logical Disk(*)\\Disk Transfers/sec",
                    "\\Logical Disk(*)\\Disk Reads/sec",
                    "\\Logical Disk(*)\\Disk Writes/sec"
                  ],
                  "platformType" : "Linux"
                }
              ]
            },
            "dataFlows" : {
              "streams" : [
                "Microsoft-Perf",
                "Microsoft-Syslog"
              ],
              "destinations": [
                "dv5-mgmt-d-loganalytics"
              ]
            }
          },
          {
            "dataCollectionRuleName": "dcrwindows001",
            "kind": "Windows",
            "dataSource": {
              "windowsEventLogs": [
              {
                "name": "DS_WindowsEventLogs",
                "streams": [
                    "Microsoft-Event"
                ],
                "xPathQueries" :[
                    "Microsoft-Windows-Security-Audit-Configuration-Client/Diagnostic!*[System[(Level=1 or Level=2 or Level=3)]]",
                    "Microsoft-Windows-Security-Audit-Configuration-Client/Operational!*[System[(Level=1 or Level=2 or Level=3)]]",
                    "Microsoft-Windows-Security-Configuration-Wizard/Diagnostic!*[System[(Level=1 or Level=2 or Level=3)]]",
                    "Microsoft-Windows-Security-Netlogon/Operational!*[System[(Level=1 or Level=2 or Level=3)]]",
                    "Microsoft-Windows-Security-Configuration-Wizard/Operational!*[System[(Level=1 or Level=2 or Level=3)]]",
                    "System!*[System[(Level=1 or Level=2 or Level=3)]]"
                ]
              }
            ],
              "performanceCounters":[
              {
                  "name": "DS_WindowsPerformanceCounter_1",
                  "streams" : [
                    "Microsoft-Perf"
                  ],
                  "samplingFrequencyInSeconds" : 120,
                  "counterSpecifiers" : [
                    "\\LogicalDisk(*)\\Avg. Disk sec/Read",
                    "\\LogicalDisk(*)\\Avg. Disk sec/Write",
                    "\\LogicalDisk(*)\\Current Disk Queue Length",
                    "\\LogicalDisk(*)\\Disk Reads/sec",
                    "\\LogicalDisk(*)\\Disk Transfers/sec",
                    "\\LogicalDisk(*)\\Disk Writes/sec",
                    "\\LogicalDisk(*)\\Free Megabytes",
                    "\\LogicalDisk(*)\\% Free Space",
                    "\\Memory\\% Committed Bytes In Use",
                    "\\Memory\\Available mbytes",
                    "\\Network Adapter(*)\\Bytes Received/sec",
                    "\\Network Adapter(*)\\Bytes Sent/sec",
                    "\\Network Adapter(*)\\Bytes Total/sec",
                    "\\Processor(*)\\% Processor Time",
                    "\\System(*)\\Processor Queue Length"
                  ],
                  "platformType" : "Windows"
              }]
            },
            "dataFlows" : {
              "streams" : [
                "Microsoft-Perf",
                "Microsoft-Event"
              ],
              "destinations": [
                "dv5-mgmt-d-loganalytics"
              ]
            }
          }
        ]
      }
    }
  }
  ```