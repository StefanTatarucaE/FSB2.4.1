# Tag Conversion Process

Tag conversion is the process of updating tags name with same value.

This scripts will perform following actions :

 1. Replace tag name with same value. Its two step process. First add new tag with existing value and at the end remove existing tags.

 2. Remove 3 alerts which has 'Atos'/'DCS' value in name.

   ```json
   "Alerts" : [
      "Delete Atos Disk Encryption KeyVault",
      "Delete Atos Disk Encryption Set",
      "New DCS Azure custom alert"
   ]
   ``````

 3. Remove all blobs from  reporting 'artifact' container which don't start with name 'Eviden'.

 4. Update diagnostic rule name. Existing diagnostics rule names has 'Atos' value. This script will first remove existing rule and then it will add new rule with the same configuration.

 5. Remove 'Atos.RunbookAutomation' Module from Automation account.

 6. Remove Diagnostic setting policy assignments (Network, Core, OSMGMT , PaaS) for all subscriptions.

As a Prerequisites it performs below steps :

1. Disable VM Encryption Runbook webhook before starting updating tags (Prerequisite.ps).

2. Disable Logic Apps and Function Apps before updating tags. This will avoid triggering unnecessary automation. Function apps will get started / enabled once removed old tag.

Note : Upgradation process will start this disabled logic apps , function apps and webhook.

All scripts accepts same single input json file.

## Input Parameters

|  Name | Type | Description | Required |
| :-- | :-- | :-- | :-- |
| tenantID | string | Provide correct tenant ID | Yes |
| mgmtSubscriptionId | string | Management subscription Id | Yes |
| inputfilePath | string | Path of input json file. (.\Tag-Conversion-Input.json') | Yes |

## Steps to convert the tags

### 1. Execute 'Prerequisites-Tag-Conversion.ps1' script

.\Prerequisites-Tag-Conversion.ps1 -tenantID "{tenant Id}" -mgmtSubscriptionId "{management subscription Id}" -inputfilePath ".\Tag-Conversion-Input.json"

This script performs below steps :

- Remove existing 3 alerts.

- Remove automation module - Atos.RunbookAutomationModule

- Stop Logic and Function apps.

- Disable Webhook of VMEncryption runbook.

- Remove all Assignment of Diagnostic policies.

### 2. Execute 'Add-NewTags.ps1' script

.\Add-NewTags.ps1 -tenantID '{tenant Id}' -inputfilePath '.\Tag-Conversion-Input.json'

This script add all new tags on Subscriptions, Resource groups and Resources. It looks for all the resources which has tag marked as "ReplaceTagName": true in input json file. Tag value will copied from existing tag. No any changes on tag value.

### 3. Execute 'Remove-OldTags.ps1' script

.\Remove-OldTags.ps1 -tenantID '{tenant Id}' -mgmtSubscriptionId "{management subscription Id}" -inputfilePath '.\Tag-Conversion-Input.json'

This script removes old tag form Subscriptions, Resource groups and Resources where new tag is added or marked as 'RemoveExistingTag' = 'True' also start function apps which get disabled in Prerequisites-Tag-Conversion.ps1 script.

### 4. Deploy latest release

This is manual step. Deploy latest 2.3 code as guided.

### 5. Update Diagnostic rules (Update-DiagnosticsRules.ps1)

.\Update-DiagnosticsRules.ps1 -tenantID "{tenant Id}" -inputfilePath ".\Tag-Conversion-Input.json"

This script updates all diagnostic name with same configuration as existing. At the end this script will create excel file to track changes and logs with name 'diagnosticsRuleUpdationStatus$< timestamp >.xlsx'. Sheet will have below details :

 - Resource ID
 - Resource Name
 - hasExistingDiagnosticRuleConfigured (True / False)
 - hasAtosDignosticsRuleConfigured
 - ExistingDiagnosticsRuleName
 - RemovedExistingDiagnosticsRule
 - AddedNewDiagnosticsRule
 - StatusMessage

- Only updating diagnostic rule name is not possible as its ReadOnly property. First need to delete existing diagnostic rule and then add new diagnostics rule with same configuration.

- Diagnostic setting on AAD level need to be updated manually.

Note :

- The steps in Prerequisites.ps1 file has scope on MGMT subscription only.(Webhook , Logic Apps, Function Apps, Alerts). It don't check if 'Include' flag is true in input file or not.

- if 'RemoveExistingTag' is set to True in Input Json it means that tag will just get removed. No replacement tag will be added.

- Kindly remove 'AtosPurpose' and 'AtosLogicAppScope' both the tags. New tags will get added by updated solution. Keep "RemoveExistingTag" : true in input file as below.

```json
      {
         "ExistingTagName": "AtosPurpose",
         "NewTagName": "EvidenPurpose",
         "ReplaceTagName": false,
         "RemoveExistingTag" : true
      },
      {
         "ExistingTagName": "AtosLogicAppScope",
         "NewTagName": "EvidenLogicAppScope",
         "ReplaceTagName": false,
         "RemoveExistingTag" : true
      }
```

## Example parameters file

The required values for parameters are described in the following example of a parameters file.

```json
{
   "Subscriptions": [
      {
         "SubscriptionID": "23423dfgrer-u6876qwe-98we7tywb25587e",
         "SubscriptionName": "SUBSCRIPTION TEST CNTY",
         "Include": true
      },
      {
         "SubscriptionID": "345evcvxdfe4-u6876qwe-98we7tywb25587e",
         "SubscriptionName": "SUBSCRIPTION TEST LND1",
          "Include": true
      },
      {
         "SubscriptionID": "df345ertter-u6876qwe-98we7tywb25587e",
         "SubscriptionName": "SUBSCRIPTION TEST LND2",
         "Include": true
      },
      {
         "SubscriptionID": "tyuty56745g5-u6876qwe-98we7tywb25587e",
         "SubscriptionName": "SUBSCRIPTION TEST LND3",
         "Include": true
      },
      {
         "SubscriptionID": "tyuty5345asd-u6y5yqwe-98we7wer3a733d2",
         "SubscriptionName": "SUBSCRIPTION TEST MGMT",
         "Include": true
      }
   ],
   "ResourceTags": [
      {
         "ExistingTagName": "AtosManaged",
         "NewTagName": "EvidenManaged",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      },
      {
         "ExistingTagName": "AtosPurpose",
         "NewTagName": "EvidenPurpose",
         "ReplaceTagName": false,
         "RemoveExistingTag": true
      },
      {
         "ExistingTagName": "AtosLogicAppScope",
         "NewTagName": "EvidenLogicAppScope",
         "ReplaceTagName": false,
         "RemoveExistingTag": true
      },
      {
         "ExistingTagName": "AtosStorageAccountKeyRotation",
         "NewTagName": "EvidenStorageAccountKeyRotation",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      },
      {
         "ExistingTagName": "AtosBackup",
         "NewTagName": "EvidenBackup",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      },
      {
         "ExistingTagName": "AtosOsVersion",
         "NewTagName": "EvidenOsVersion",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      },
      {
         "ExistingTagName": "AtosPatching",
         "NewTagName": "EvidenPatching",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      },
      {
         "ExistingTagName": "AtosAntimalware",
         "NewTagName": "EvidenAntimalware",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      },
      {
         "ExistingTagName": "AtosEncryption",
         "NewTagName": "EvidenEncryption",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      },
      {
         "ExistingTagName": "AtosMaintenance",
         "NewTagName": "EvidenMaintenance",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      },
      {
         "ExistingTagName": "AtosITSMServiceNowEnvironment",
         "NewTagName": "EvidenITSMServiceNowEnvironment",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      },
      {
         "ExistingTagName": "AtosITSMServiceNowCICriticality",
         "NewTagName": "EvidenITSMServiceNowCICriticality",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      },
      {
         "ExistingTagName": "AtosCompliance",
         "NewTagName": "EvidenCompliance",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      }
   ],
   "SubscriptionsTags": [
      {
         "ExistingTagName": "AtosITSMServiceNowEnvironment",
         "NewTagName": "EvidenITSMServiceNowEnvironment",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      },
      {
         "ExistingTagName": "AtosITSMServiceNowFO",
         "NewTagName": "EvidenITSMServiceNowFO",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      },
      {
         "ExistingTagName": "AtosCompliance",
         "NewTagName": "EvidenCompliance",
         "ReplaceTagName": true,
         "RemoveExistingTag": false
      }
   ],
   "DiagnosticsConfigResourceType" : [
         "Microsoft.Storage/storageAccounts",
         "Microsoft.AAD/domainServices",
         "Microsoft.Resources/subscriptions",
         "Microsoft.KeyVault/vaults",
         "Microsoft.Automation/automationAccounts",
         "Microsoft.EventGrid/topics",
         "Microsoft.EventGrid/eventSubscriptions",
         "Microsoft.Network/networkInterfaces",
         "Microsoft.Network/networkSecurityGroups",
         "Microsoft.Network/publicIPAddresses",
         "Microsoft.Network/bastionHosts",
         "Microsoft.Network/loadBalancers",
         "Microsoft.Cdn/profiles/endpoints",
         "Microsoft.Network/applicationGateways",
         "Microsoft.Network/azureFirewalls",
         "Microsoft.Network/expressRouteCircuits",
         "Microsoft.Network/virtualNetworks",
         "Microsoft.Network/virtualNetworkGateways",
         "Microsoft.Network/trafficManagerProfiles",
         "Microsoft.Compute/virtualMachines",
         "Microsoft.Compute/virtualMachineScaleSets",
         "Microsoft.RecoveryServices/vaults",
         "Microsoft.Synapse/workspaces/sqlPools",
         "Microsoft.Synapse/workspaces",
         "Microsoft.Synapse/workspaces/bigDataPools",
         "Microsoft.CognitiveServices/accounts",
         "Microsoft.DataLakeAnalytics/accounts",
         "Microsoft.DataLakeStore/accounts",
         "Microsoft.EventHub/namespaces",
         "Microsoft.Devices/IotHubs",
         "Microsoft.Logic/workflows",
         "Microsoft.Logic/integrationAccounts",
         "Microsoft.Search/searchServices",
         "Microsoft.ServiceBus/namespaces",
         "Microsoft.Sql/servers/databases",
         "Microsoft.Sql/servers/databases",
         "Microsoft.Sql/servers/elasticPools",
         "Microsoft.ApiManagement/service",
         "Microsoft.Batch/batchAccounts",
         "Microsoft.DBforMySQL/servers",
         "Microsoft.DBforMySQL/flexibleServers",
         "Microsoft.DBforPostgreSQL/servers",
         "Microsoft.DBforPostgreSQL/flexibleServers",
         "Microsoft.DocumentDB/databaseAccounts",
         "Microsoft.DataFactory/factories",
         "Microsoft.PowerBIDedicated/capacities",
         "Microsoft.StreamAnalytics/streamingjobs",
         "Microsoft.ContainerInstance/containerGroups",
         "Microsoft.ContainerRegistry/registries",
         "Microsoft.ContainerService/managedClusters",
         "Microsoft.Web/sites",
         "Microsoft.AnalysisServices/servers",
         "Microsoft.HDInsight/clusters",
         "Microsoft.Cache/redis",
         "Microsoft.Cache/redisEnterprise",
         "Microsoft.Relay/namespaces",
         "Microsoft.SignalRService/SignalR",
         "Microsoft.Web/serverfarms",
         "Microsoft.Sql/managedInstances",
         "Microsoft.TimeSeriesInsights/environments",
         "Microsoft.DBforMariaDB/servers",
         "Microsoft.Sql/servers",
         "Microsoft.Databricks/workspaces"
   ],
   "Alerts" : [
      "Delete Atos Disk Encryption KeyVault",
      "Delete Atos Disk Encryption Set",
      "New DCS Azure custom alert"
   ],
}

```

**Input parameters**

| Parameter Name  | Description |
| :-- |  :-- |
| `Subscriptions` | Provide list of all  subscriptions (ID and Name) in tenant. Subscription will get exclude form execution if set 'Include' : false. |
| `ResourceTags` | Provide list of all tags which get applied on resource group or resources. Set flag "ReplaceTagname" : True if want to get replace with new tag name. Set flag "RemoveExistingTag" : true if just want to get it removed.
| `SubscriptionTags` | Provide list of all tags which get applied on Subscriptions. Set flag "ReplaceTagname" : True if want to get replace with new tag name. Set flag "RemoveExistingTag" : true if just want to get it removed.
| `DiagnosticsConfigResourceType` | This is default list of resource types which are configured with diagnostic rule with LAW
| `Alerts` | This is default list of Alerts which needs to get deleted from tenant.
