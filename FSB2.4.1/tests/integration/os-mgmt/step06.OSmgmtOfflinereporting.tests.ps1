##
## Eviden Landing Zones for Azure - Feature test runbook status for Core
##
 
Describe 'OS-MGMT - Offline reporting' {

    BeforeAll {
        $dateTime = (Get-Date).ToString()
        $startDateTime = (get-date -asutc).ToString("yyyy-MM-dd HH:mm") 
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $runbookAutomationAccount = get-runbookAutomationAccount -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        $automationAccount = $runbookAutomationAccount.Name
        $resourceGroup = $runbookAutomationAccount.ResourceGroupName
        $offlineRunbook = 'OSMGMT-Create-OfflineReports-OSmgmt'
        $offlineReport1 = '*_MANUAL__VM_Availability_Report'
        $offlineReport2 = '*_MANUAL__VM_tag_patching_Report'
        $dashboardName = "CloudCoreReportingDashboard"
        $searchStorageAccountReporting = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -tag @{"${tagPrefix}Purpose" = "${tagValuePrefix}Reporting" }
        $storageAccountReporting = get-azstorageaccount -ResourceGroupName $searchstorageAccountReporting.ResourceGroupName -StorageAccountName $searchstorageAccountReporting.Name
        $storageAccountContext = $storageAccountReporting.context
    }

    Context 'Check Offline reporting for VM OS Management' {
            
        It 'Check if runbook installed' {
            $runbook = get-AzAutomationRunbook -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccount | Where-Object { $_.Name -eq $offlineRunbook }
            $becauseText = 'runbook ' + $($offlineRunbook) + 'should be created' + ' Checked at: ' + $($dateTime)
            $runbook.Count | Should -Be "1" -Because $becauseText
        }   
                
        It 'Check if container in MGMT Storage acount created' {
            $result = (Get-AzStorageContainer -Name "offlinereports" -context $storageAccountContext.context -erroraction 'silentlycontinue').name
            $becauseText = 'Container offlinereports should be created in storage account ' + $($storageAccountReporting.StorageAccountName) + ' Checked at: ' + $($dateTime)
            $result  | Should -Be "offlinereports" -Because $becauseText
        }   
        It 'Check if runbook executes properly' {
            $params = @{
              runbookName             = $offlineRunbook
              runbookParameters       = @{"monthreportday" = """00""" }
              custMgmtSubscriptionId  = $custMgmtSubscriptionId
              tenantId                = $tenantId
              tagPrefix               = $tagPrefix
              tagValuePrefix          = $tagValuePrefix
            }
            $runbookCompletedWithoutErrors = start-mgmtAutomationRunbook @params
            $becauseText = ' Runbook job Status should be completed without errors.' + 'Checked at:' + $($dateTime)
            $runbookCompletedWithoutErrors | Should -BeLike $true -Because $becauseText
        }  
        It 'Check if CSV VM_Availability report is created' {
            $csvReport = Get-AzStorageBlob -Container "offlinereports" -Blob * -context $storageAccountContext.context | Where-Object { $_.Name -like $offlineReport1 + '.csv' }
            $result = $False
            If ($csvReport -ne $Null) {
                $csvDateTime = $csvReport.lastmodified.utcdatetime.ToString("yyyy-MM-dd HH:mm")
                $result = ($csvDateTime -ge $startDateTime)
            }
            $becauseText = ' CSV report [' + $($offlineReport1) + '.csv] should be created.' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Check if HTML VM_Availability report is created' {
            $htmlReport = Get-AzStorageBlob -Container "offlinereports" -Blob * -context $storageAccountContext.context | Where-Object { $_.Name -like $offlineReport1 + '.html' }
            $result = $False
            If ($htmlReport -ne $Null) {
                $htmlDateTime = $htmlReport.lastmodified.utcdatetime.ToString("yyyy-MM-dd HH:mm")
                $result = ($htmlDateTime -ge $startDateTime)
            }
            $becauseText = ' HTML report [' + $($offlineReport1) + '.csv] should be created.' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Check if CSV VM_tag_patching report is created' {
            $csvReport = Get-AzStorageBlob -Container "offlinereports" -Blob * -context $storageAccountContext.context | Where-Object { $_.Name -like $offlineReport2 + '.csv' }
            $result = $False
            If ($csvReport -ne $Null) {
                $csvDateTime = $csvReport.lastmodified.utcdatetime.ToString("yyyy-MM-dd HH:mm")
                $result = ($csvDateTime -ge $startDateTime)
            }
            $becauseText = ' CSV report [' + $($offlineReport2) + '.csv] should be created.' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Check if HTML VM_tag_patching report is created' {
            $htmlReport = Get-AzStorageBlob -Container "offlinereports" -Blob * -context $storageAccountContext.context | Where-Object { $_.Name -like $offlineReport2 + '.html' }
            $result = $False
            If ($htmlReport -ne $Null) {
                $htmlDateTime = $htmlReport.lastmodified.utcdatetime.ToString("yyyy-MM-dd HH:mm")
                $result = ($htmlDateTime -ge $startDateTime)
            }
            $becauseText = ' HTML report [' + $($offlineReport2) + '.csv] should be created.' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Check if CloudCoreReportingDashboard is created' {
            $result = get-sharedDashboard -dashboardName $dashboardName -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix

            $becauseText = ' CloudCoreReportingDashboard should be created with link to offlinereports container.' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Check if Offline reporting link is created in shared dashboard' {
            $linkPrefix = "https://portal.azure.com/#blade/Microsoft_Azure_Storage/ContainerMenuBlade/overview/storageAccountId/"
            $linkSuffix = "/path/offlinereports"
            $storageAccountId = $searchstorageAccountReporting.ResourceId -Replace "/", "%2F"
            $link = $linkPrefix + $storageAccountId + $linkSuffix
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to offlinereports container should be created in ' + $($dashboardName)+ '.' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
    }
}