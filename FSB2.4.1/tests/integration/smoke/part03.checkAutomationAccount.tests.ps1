##
## Eviden Landingzones for Azure  - Check Tags for Automation Accounts in Azure MGMT Subscription
##
 
Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
        $tagName1 = $tagPrefix + "Managed"
        $tagName2 = $tagPrefix + "Purpose"

        $tagValue1 = $tagValuePrefix + "Automation"
        $tagValue3 = "True"

        $dateTime = (Get-Date).ToString()
    }

    Context 'Automation Account Tag Check' {

        It 'Step07-01. Check if the correct Tags/Values have been assigned to the Runbooks Automation Account' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Runbooks Automation Account should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Runbooks Automation Account should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Automation TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-automation
            $automationAccountRunbooks = Get-AzAutomationAccount -ResourceGroupName $resourceGroup.ResourceGroupName
            $resourcetags = convert-hashToString($automationAccountRunbooks.tags)
            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue3`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step07-04. Verify in runbooks Automation Account whether all the runbooks are present and also scheduled:' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText = 'The required Runbooks should be available and scheduled' + ' Checked at: ' + $($dateTime)
            
            $resourceGroup = Get-AzResourceGroup -Name *-rsg-automation
            $automationAccountRunbooks = Get-AzAutomationAccount -ResourceGroupName $resourceGroup.ResourceGroupName
            
            $automationAccountRunbooksList = (Get-AzAutomationScheduledRunbook -AutomationAccountName $automationAccountRunbooks.AutomationAccountName -ResourceGroupName $resourceGroup.ResourceGroupName).RunbookName
            
            $runbookList = @(
            "Create-OfflineReports",
            "Create-RemediationTaskSecurityCenterTier",
            "Get-AzureSubscriptionRolesForReporting",
            "MONITORING-Create-RemediationTaskDiagnosticSettings",
            "MONITORING-Create-RemediationTaskSecurityCenterExport",
            "MONITORING-CustomAlertsForLogAnalytics",
            "MONITORING-Get-ServiceLimitsAndSendToLogAnalytics",
            "OSMGMT-Create-OfflineReports-OSmgmt",
            "OSMGMT-Create-RemediationTaskAntiMalware",
            "OSMGMT-Create-RemediationTaskASCQualysAgent",
            "OSMGMT-Create-RemediationTaskBackupPolicy",
            "OSMGMT-Create-RemediationTaskDependencyAgent",
            "OSMGMT-Create-RemediationTaskDependencyAgent-ScaleSet",
            "OSMGMT-Create-RemediationTaskGuestConfigAgent",
            #"OSMGMT-Execute-VMEncryption",
            "OSMGMT-Remove-BackupForNonTaggedVMs",
            "OSMGMT-Create-RemediationTaskUpdateManager",
            "OSMGMT-Update-EventGridAutomationWebhook",
            "PAASMGMT-Create-OfflineReports-PAASmgmt",
            "PAASMGMT-Create-RemediationTaskACR",
            "PAASMGMT-Create-RemediationTaskAppService",
            "PAASMGMT-Create-RemediationTaskCosmosDB",
            "PAASMGMT-Create-RemediationTaskDF",
            "PAASMGMT-Create-RemediationTaskKubernetes",
            #"Update-AutomationAzureModulesForAccount",
            "Update-AutomationAzureModulesForAccountWrapperAz"
            )
            foreach ($runbook in $runbookList) {
                $automationAccountRunbooksList -contains $runbook | Should -Be $true -Because $becauseTxt
            }
        }
    }
}