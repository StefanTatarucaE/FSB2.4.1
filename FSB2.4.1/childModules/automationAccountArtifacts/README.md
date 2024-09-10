# automationAccountArtifacts/automationAccountArtifacts.bicep
Bicep module to upload runbooks to automation account

## Description
Process automation in Azure Automation allows you to create and manage PowerShell, PowerShell Workflow, and graphical runbooks.
Starting a runbook in Azure Automation creates a job, which is a single execution instance of the runbook. Each job accesses Azure resources by making a connection to your Azure subscription. The job can only access resources in your datacenter if those resources are accessible from the public cloud.

Azure Automation assigns a worker to run each job during runbook execution. While workers are shared by many Automation accounts, jobs from different Automation accounts are isolated from one another. You can't control which worker services your job requests.

PowerShell runbooks are based on Windows PowerShell. You directly edit the code of the runbook using the text editor in the Azure portal. You can also use any offline text editor and import the runbook into Azure Automation.

The PowerShell version is determined by the Runtime version specified (that is version 7.1 preview or 5.1). The Azure Automation service supports the latest PowerShell runtime.

The same Azure sandbox and Hybrid Runbook Worker can execute PowerShell 5.1 and PowerShell 7.1 runbooks side by side.

## Known Issue

Schedule Jobs needs to be deleted before re applying the Bicep Module as it conflicts with an already existing schedule
Error: "A job schedule for the specified runbook and schedule already exists"
https://github.com/Azure/azure-resource-manager-schemas/issues/313 - issue reported to Microsoft


## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `automationAccountName` | `string` | true | Specifies the name of the Automation Account. |
| `location` | `string` | true | Specifies the location of the Automation Account. |
| `runbooks` | `array` | true | List of runbooks needed to be uploaded in automation account. Additional Details [here](#array---runbooks). |
| `artifactStorageAccount` | `string` | true | Specifies the name of the Artifact Storage Account. |
| `artifactStorageAccountRG` | `string` | true | Specifies the name of the Resource Group where Artifact Storage Account resides. |
| `urlRunbookArtifacts` | `string` | true | Specifies the url of the Artifacts in Storage Account |
| `modules` | `array` | true | Specifies the Modules that needs to be updated or uploaded to Automation Account. Additional Details [here](#array---modules). |
| `timeZone` | `string` | true | Specifies the Timezone where runbook schedules are displayed. Note: This doesn't affect the time when runbook is execulted. Timezone database reference: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones  |
| `productCode` | `string` | true | productCode naming for mgmt subscription as loaded in parentmodule. Used for branding variables. |
| `company` | `string` | true | company naming for mgmt subscription as loaded in parentmodule. Used for branding variables. |

### Array - runbooks
| Name | Type  | Description |
| --- | --- | --- |
| `name`| `string`| The name of the runbook. |
| `filename` | `string`| The filename of the powershell script file|
| `version` | `string`| The version to be used for the runbook|
| `type`| `string` | The type of language used Powershell or Python|
| `description`| `string` | The description for the runbook|
| `scheduleName`| `string` | The name of the schedule associated with this runbook|
| `startTime`| `string` | The start time of the runbook. Time is specified in UTC only. Can be defined as 23:59 format and will specify the exact time when runbook will start. Or PTxH or PTxM and will define the amount of time in hours or minutes after deployment of runbook is completed |
| `interval`| `string` | The interval used in the schedule|
| `frequency`| `string` | The frequency used in the schedule values are 'Day','Hour','Minute','Month','OneTime','Week'|

### Array - modules
| Name | Type  | Description |
| --- | --- | --- |
| `name`| `string`| The name of the module|
| `url` | `string`| The url of the module to be used.|

## Module outputs

| Name | Description | Value |
| --- | --- | --- |
| `automationAccountName` | Name of automation account where runbooks and modules were uploaded | `automationAccount.name` |



## Parameters file example
Note: Existing properties should exist in parameters to prevent them from being overwritten..

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "automationAccountName": {
            "value": "cu6-lan1-t-aa-testing"
        },
        "artifactStorageAccount": {
            "value": "alnaqvnftrhyqzes"
        },
        "artifactStorageAccountResourceGroup": {
            "value": "aln-msdn-t-rsg-artifact-repository"
        },
        "productCode": {
            "value": "ELZ"
        },
        "company": {
            "value": "Eviden"
        },
        "urlRunbookArtifacts": {
            "value": "https://alnaqvnftrhyqzes.blob.core.windows.net/eviden-elz-artifacts/2021-09-01-09-27-25/eviden_automation_account_bp"
        },
        "location": {
            "value": "westeurope"
        },
        "timeZone": {
            "value": "Europe/Amsterdam"
        },
        "runbooks": {
            "value": [
                {
                    "name": "PAASMGMT-Create-OfflineReports-PAASmgmt",
                    "filename": "Create-OfflineReports-PAASmgmt.ps1",
                    "version": "1.0.0.0",
                    "type": "PowerShell",
                    "description": "Runbook - Create offline PAAS reports, timerbased",
                    "scheduleName": "PAASMGMT-Create-OfflineReports-PAASmgmt",
                    "startTime" : "23:59",
                    "interval": "24",
                    "frequency": "Hour"
                }
            ]
        },
        "modules": {
            "value": [
                {
                    "name": "Az.Automation",
                    "url": "https://devopsgallerystorage.blob.core.windows.net/packages/az.automation.1.8.0.nupkg"
                },
                {
                    "name": "Az.Network",
                    "url": "https://devopsgallerystorage.blob.core.windows.net/packages/az.network.4.20.1.nupkg"
                },
                {
                    "name": "Az.Compute",
                    "url": "https://devopsgallerystorage.blob.core.windows.net/packages/az.compute.4.31.0.nupkg"
                },
                {
                    "name": "moduleNamePlaceHolder",
                    "url": ""
                }
            ]
        }
    }
}

```