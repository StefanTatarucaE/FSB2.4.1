##
## Eviden Landing Zones for Azure - Feature test runbook status for Core
##
 
Describe 'Smoke and Sanity Testing for Eviden Landing Zones for Azure Solution' {

    BeforeAll {
        $startDateTime = (get-date -asutc).ToString("yyyy-MM-dd HH:mm") 
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        $runbookAutomationAccount = get-runbookAutomationAccount -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        $automationAccount = $runbookAutomationAccount.Name
        $resourceGroup = $runbookAutomationAccount.ResourceGroupName
        $offlineRunbook = 'PAASMGMT-Create-OfflineReports-PAASmgmt'
        $offlineReport1 = '*_MANUAL__Paas_Services_' + ${tagPrefix} + 'Managed_tag_Report'
        $dashboardName = "CloudCoreReportingDashboard"
        $searchStorageAccountReporting = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -tag @{"${tagPrefix}Purpose" = "${tagValuePrefix}Reporting" }
        $storageAccountReporting = get-azstorageaccount -ResourceGroupName $searchstorageAccountReporting.ResourceGroupName -StorageAccountName $searchstorageAccountReporting.Name
        $storageAccountContext = $storageAccountReporting.context
    }

    Context ' Check Offline reporting for PAAS Services' {
            
        It ' Check if runbook installed' {
            $runbook = get-AzAutomationRunbook -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccount | Where-Object { $_.Name -eq $offlineRunbook }
            $becauseText = 'runbook ' + $($offlineRunbook) + 'should be created' + ' Checked at: ' + $($dateTime)
            $runbook.Count | Should -Be "1" -Because $becauseText
        }   
                
        It ' Check if container in MGMT Storage acount created' {
            $result = (Get-AzStorageContainer -Name "offlinereports" -context $storageAccountContext -erroraction 'silentlycontinue').name
            $becauseText = 'Container offlinereports should be created in storage account ' + $($storageAccountReporting.StorageAccountName) + ' Checked at: ' + $($dateTime)
            $result  | Should -Be "offlinereports" -Because $becauseText
        }   
        It ' Check if runbook executes properly' {
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
        It 'Step19. Check if CSV Paas_Services_<tagPrefix>Managed_tag report is created' {
            $CSVReport = Get-AzStorageBlob -Container "offlinereports" -Blob * -context $storageAccountContext.context | Where-Object { $_.Name -like $offlineReport1 + '.csv' }
            $result = $False
            If ($CSVReport -ne $Null) {
                $CSVDateTime = $CSVReport.lastmodified.utcdatetime.ToString("yyyy-MM-dd HH:mm")
                $result = ($CSVDateTime -ge $startDateTime)
            }
            $becauseText = ' CSV report [' + $($offlineReport1) + '.csv] should be created.' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step19. Check if HTML Paas_Services_<tagPrefix>Managed_tag report is created' {
            $HTMLReport = Get-AzStorageBlob -Container "offlinereports" -Blob * -context $storageAccountContext.context | Where-Object { $_.Name -like $offlineReport1 + '.html' }
            $result = $False
            If ($HTMLReport -ne $Null) {
                $HTMLDateTime = $HTMLReport.lastmodified.utcdatetime.ToString("yyyy-MM-dd HH:mm")
                $result = ($HTMLDateTime -ge $startDateTime)
            }
            $becauseText = ' HTML report [' + $($offlineReport1) + '.csv] should be created.' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if CloudCoreReportingDashboard is created' {
            $result = get-sharedDashboard -dashboardName $dashboardName -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix

            $becauseText = ' CloudCoreReportingDashboard should be created with link to offlinereports container.' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step20. Check if Offline reporting link is created in shared dashboard' {
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