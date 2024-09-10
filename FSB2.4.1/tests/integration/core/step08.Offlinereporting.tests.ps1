##
## Eviden Landing Zones for Azure - Feature test runbook status for Core
##
 
Describe 'Core - Offline reporting' {

    BeforeAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
        $dateTime = (Get-Date).ToString()
        $startDateTime = (get-date -asutc).ToString("yyyy-MM-dd HH:mm") 
        $runbookAutomationAccount = get-runbookAutomationAccount -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        $automationAccount = $runbookAutomationAccount.Name
        $resourceGroup = $runbookAutomationAccount.ResourceGroupName
        $offlineRunbook = 'Create-OfflineReports'
        $offlineReport = '*_MANUAL__Resources_' + ${tagPrefix} + 'Managed_tag_Report'
        $dashboardName = "CloudCoreReportingDashboard"
        $searchStorageAccountReporting = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -tag @{"${tagPrefix}Purpose" = "${tagValuePrefix}Reporting" }
        $storageAccountReporting = get-azstorageaccount -ResourceGroupName $searchStorageAccountReporting.ResourceGroupName -StorageAccountName $searchStorageAccountReporting.Name
        $storageAccountContext = $storageAccountReporting.context
    }

    Context ' Check Offline reporting for Core Cloud' {
            
        It ' Check if runbook installed' {
            $Runbook = get-AzAutomationRunbook -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccount | Where-Object { $_.Name -eq $offlineRunbook }
            $becauseText = 'Runbook' + $($offlineRunbook) + 'should be created' + 'Checked at:' + $($dateTime)
            $Runbook.Count | Should -Be "1" -Because $becauseText
        }   
                
        It ' Check if container in MGMT Storage account created' {
            $result = (Get-AzStorageContainer -Name "offlinereports" -context $storageAccountContext.context -erroraction 'silentlycontinue').name
            $becauseText = 'Container offlinereports should be created in storage account' + $($storageAccountReporting.StorageAccountName) + 'Checked at:' + $($dateTime)
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
        It ' Check if CSV Resources_<tagprefix>Managed_tag report is created' {
            $csvReport = Get-AzStorageBlob -Container "offlinereports" -Blob * -context $storageAccountContext.context | Where-Object { $_.Name -like $offlineReport + '.csv' }
            $result = $False
            If ($csvReport -ne $Null) {
                $csvDateTime = $csvReport.lastmodified.utcdatetime.ToString("yyyy-MM-dd HH:mm")
                $result = ($csvDateTime -ge $startDateTime)
            }
            $becauseText = 'CSV report [' + $($offlineReport) + '.csv] should be created.' + 'Checked at:' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if HTML Resources_<tagprefix>Managed_tag report is created' {
            $htmlReport = Get-AzStorageBlob -Container "offlinereports" -Blob * -context $storageAccountContext.context | Where-Object { $_.Name -like $offlineReport + '.html' }
            $result = $False
            If ($htmlReport -ne $Null) {
                $htmlDateTime = $htmlReport.lastmodified.utcdatetime.ToString("yyyy-MM-dd HH:mm")
                $result = ($htmlDateTime -ge $startDateTime)
            }
            $becauseText = 'HTML report [' + $($offlineReport) + '.html] should be created.' + 'Checked at:' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if CloudCoreReportingDashboard is created' {
            $result = get-sharedDashboard -dashboardName $dashboardName -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = 'CloudCoreReportingDashboard should be created.' + 'Checked at:' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Offline reporting link is created in shared dashboard' {
            $linkPrefix = "https://portal.azure.com/#blade/Microsoft_Azure_Storage/ContainerMenuBlade/overview/storageAccountId/"
            $linkSuffix = "/path/offlinereports"
            $storageAccountId = $searchStorageAccountReporting.ResourceId -Replace "/", "%2F"
            $link = $linkPrefix + $storageAccountId + $linkSuffix
            $result = get-sharedDashboardLink -dashboardName $dashboardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = 'link to offlinereports container should be created in' + $($dashboardName)+ '.' + 'Checked at:' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
    }
}