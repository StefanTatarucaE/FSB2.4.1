# artifacts/runbooks/
Folder which holds the runbooks for the Eviden Landingzones for Azure solution.

## Description
This folders holds the runbooks for the Eviden Landingzones for Azure solution in the form of powershell scripts. These scripts are deployed by automationAccountArtifacts module which also configures the correct schedule for each runbooks.

The runbooks are divided in categories indicating their place within the Eviden Landingzones for Azure solution and it's use within the automationAccountArtifacts module.

| category | used in |
| --- | --- |
| `Core` | childModules/automationAccountArtifacts/core.params.json |
| `OsMgmt` | childModules/automationAccountArtifacts/osMgmt.params.json |
| `Monitoring` | childModules/automationAccountArtifacts/monitoring.core.params.json |
| `Paas` | childModules/automationAccountArtifacts/monitoring.core.params.json |

## Runbooks

| Runbookname | Category | Description | schedule |
| --- | --- | --- | ---- |
| `Create-RemediationTaskSecurityCenterTier.ps1` | `core` | remediation for asc-pricing-change-policy-def | every 12 hours |
| `Get-AzureSubscriptionRolesForReporting.ps1` | `core` | creates report for subscription role assignments | every 12 hours |
| `Update-AutomationAzureModulesForAccount.ps1` | `core` | updates the modules for the automation account | trigger by other runbook  |
| `Create-OfflineReports` | `core` | creates offline reports for all EvidenManaged resources | 01:00 AM |
| `Update-AutomationAzureModulesForAccountWrapperAz.ps1` | `core` | updates the modules for the automation account | schedule, one-time |
| `Create-OfflineReports-OSmgmt.ps1` | `osmgmt` | creates offline reports for VM's | 01:00 AM |
| `Execute-VMEncryption.ps1` | `osmgmt` | encrypts VM with Evidenencryption tag | webhook |
| `Create-RemediationTaskAntiMalware` | `osmgmt` | remediation for antimalwarewin-change-policy-def | every 12 hours |
| `Create-RemediationTaskASCQualysAgent.ps1` | `osmgmt` | remediation for ascqualysagent-windows-change-policy-def & ascqualysagent-linux-change-policy-def| every 1 hours |
| `Create-RemediationTaskDependencyAgent-ScaleSet.ps1` | `osmgmt` | remediation for vmss-enabledependencyagentwin-change-policy-def and vmss-enabledependencyagentlin-change-policy-def | every 12 hours |
| `Create-RemediationTaskAzureMonitorAgent.ps1` | `osmgmt` | remediation for Azure Monitor Agent deployment policy sets for Windows and Linux | every 12 hours |
| `Create-RemediationTaskAntiMalware` | `osmgmt` | remediation for antimalwarewin-change-policy-def | every 12 hours |
| `Create-RemediationTaskASCQualysAgent.ps1` | `osmgmt` | remediation for ascqualysagent-windows-change-policy-def and ascqualysagent-linux-change-policy-def | every 12 hours |
| `Create-RemediationTaskBackupPolicy.ps1` | `osmgmt` | remediation for *backup-policy-assignment (Silver,Bronze,Gold) | every 12 hours |
| `Create-RemediationTaskDependencyAgent-ScaleSet.ps1` | `osmgmt` | remediation for dependency | every 12 hours |
| `Create-RemediationTaskGuestconfigAgent.ps1` | `osmgmt` | remediation for guestconfig-win-change-policy-def and guestconfig-lin-change-policy-def | every 12 hours |
| `Create-RemediationTaskDependencyAgent.ps1` | `osmgmt` | remediation for vm-enabledependencyagentwin-change-policy-def and vm-enabledependencyagentlin-change-policy-def | every 12 hours |
| `Remove-BackupForNonTaggedVMs.ps1` | `osmgmt` | Removes non-tagged VM's from Backup Vault  | every 24 hours |
| `Update-EventGridAutomationWebhook.ps1` | `osmgt` | Update Eventgrid Automation webhook endpoint | once a month |
| `Create-RemediationTaskDiagnosticSettings.ps1` | `monitoring` | remediation for *.diagrules.change.policy.set | every 6 hours |
| `Create-RemediationTaskSecurityCenterExport.ps1` | `monitoring` | remediation for azdefenderexport-change-policy-def | every 12 hour |
| `Get-ServiceLimitsAndSendToLogAnalytics.ps1` | `monitoring` | gets Azure service limits for customer and send to LA workspace | every 6 hour |
| `Monitor-CustomAlertsForLogAnalytics.ps1` | `monitoring` | peforms custom monitoring operation and send alerts in LA custom table | every 6 hour |
| `Create-RemediationTaskPaas_Acr.ps1` | `paas` | remediation for acr-change-policy-set | every 24 hour |
| `Create-RemediationTaskPaas_AppService.ps1` | `paas` | remediation for appservice-change-policy-set | every 24 hour |
| `Create-RemediationTaskPaas_CosmosDB.ps1` | `paas` | remediation for cosmosdb-change-policy-set | every 24 hour |
| `Create-RemediationTaskPaas_DF.ps1` | `paas` | remediation for datafactory-change-policy-set | every 24 hour |
| `Create-RemediationTaskPaas_Kubernetes.ps1` | `paas` | remediation for aks-change-policy-set | every 24 hour |
| `Create-OfflineReports-Paasmgmt.ps1` | `paas` | creates offline reports for EvidenManaged paas resources | 01:00 AM |


## Runbooks details

The policy remediation runbooks speak for themselves. These runbooks remediate incompliancies related to the policy (set or definition) mentioned in the table above.

For the other runbooks a more detailed description can be found below.

### Create-OfflineReports

Creates offline reports for all EvidenManaged tagged resources in the form of csv & html files which are placed in a container named offlinereports in the reporting storage account located in the reporting resourcegroup. (EvidenPurpose:EvidenReporting)

Schedule: Daily 01:00AM, reports only generated on the 1st of the month.

Note: reports are generated on the 1st of the month. On request offline reports can be generated by running the runbook manually from the poral using 00 as an input value.

### Create-OfflineReports-OSmgmt

Creates offline reports for all VM's in the form of csv & html files which are placed in a container named offlinereports in the reporting storage account located in the reporting resourcegroup. (EvidenPurpose:EvidenReporting). The reports shows which VM's have an Eviden related tag on it. Furthermore it includes a report related to VM availability.

Schedule: Daily 01:00AM, reports only generated on the 1st of the month.

Note: reports are generated on the 1st of the month. On request offline reports can be generated by running the runbook manually from the poral using 00 as an input value.

### Create-OfflineReports-Paasmgmt

Creates offline reports for all EvidenManaged tagged paas resources in the form of csv & html files which are placed in a container named offlinereports in the reporting storage account located in the reporting resourcegroup. (EvidenPurpose:EvidenReporting)

Schedule: Daily 01:00AM, reports only generated on the 1st of the month.

Note: reports are generated on the 1st of the month. On request offline reports can be generated by running the runbook manually from the poral using 00 as an input value.

### Get-AzureSubscriptionRolesForReporting

Creates a csv report twice a day showing role assingments for the subscription. The reports are placed in a container named iamsubscriptionreport in the reporting storage account located in the reporting resourcegroup. (EvidenPurpose:EvidenReporting)

Schedule: twice daily.

### Update-AutomationAzureModulesForAccount & Update-AutomationAzureModulesForAccountWrapperAz

The Update-AutomationAzureModulesForAccountWrapperAZ runs only one time after the deployment and it finished by starting the Update-AutomationAzureModulesForAccount runbook. These runbooks make sure that the modules for the respective automation account is updated. These runbooks are scheduled to run one time only after deployment.

Schedule: one-time.

### Execute-VMEncryption

The Execute-VMEncryption runbook is triggered whenever a resource write happens on a virtual machine (Eventgrid Subscription). The runbooks checks if the EvidenManaged tag is set and if the EvidenEncryption tag was added. In that case the runbook validates some settings and tries to encrypt the OS Disk of the VM. Failures during these steps are logged into log analytics using a custom alert.

Schedule: no schedule, runbook trigger by webhook.

### Remove-BackupForNonTaggedVMs

The Remove-BackupForNonTaggedVMs runbook removes all VM's from the Recovery Service Vault which don't have the EvidenBackup tag set.

Schedule: daily.

### Update-EventGridAutomationWebhook

The Update-EventGridAutomationWebhook runbook recreates the webhook for the sepcified runbooks and reconfigures, in each subscription, the event subscription endpoint for that runbook. This action is needed because the webhook has an expiry date which needs to be refreshed.
The newly created webhook has an expiry date of 1 month.

Schedule: once a month. With intial start 1 month after runbook deployment.

### Execute-VMEncryption

The Execute-VMEncryption runbook is triggered by tag writes on virtual machines within the environment.The runbooks validates if the disk encryption tag was set on the virtual machine and if so encrypt the OS disk of that virtual machine. The runbook also checks if other instances of the runbook are running for the same machine and if so aborts itself. It's adviced to set the EvidenEncryption tag on a virtual machine in isolation to avoid multiple runbooks from starting at the same time. Setting multple tags within the same time window can lead to the runbook aborting the right instance, meaning the trigger that actually holds the EvidenEncryption tag write, because another instance of the runbook is already running.