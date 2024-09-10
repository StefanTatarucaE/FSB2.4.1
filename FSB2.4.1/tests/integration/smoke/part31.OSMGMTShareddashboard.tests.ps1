##
## Eviden Landing Zones for Azure - Feature test shared dashboard for OS MGMT
##
 
Describe 'Smoke and Sanity Testing for Eviden Landing Zones for Azure Product' {

    BeforeAll {
        $dashboardName = "VMOSManagementReportingDashboard"
        $manual = $company + "-VM-OS-Management-Reporting-Dashboard-Manual.pdf"
        
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        $searchStorageAccountReporting = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -tag @{"${tagPrefix}Purpose" = "${tagValuePrefix}Reporting" }
        $storageAccountReporting = get-azstorageaccount -ResourceGroupName $searchStorageAccountReporting.ResourceGroupName -StorageAccountName $searchStorageAccountReporting.name
        $storageAccountContext = $storageAccountReporting.context
        $Global:artifactFolder = ""
    }

    Context ' Check shared dashboard OSMGMT' {
            
        It 'Step22. Check if VMOSManagementReportingDashboard is created' {
            $result = get-sharedDashboard -dashboardName $dashboardName -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = 'VMOSManagementReportingDashboard should be created' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if artifactfolder is created' {
            $checkFolder = get-dashboardArtifacts -dashboardName $dashBoardName -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $result = $checkFolder.result 
            If ($result -eq $true) {
                $Global:artifactFolder = $checkFolder.name
            }
            $becauseText = " artifactfolder $($artifactFolder) should be created" + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 

        It 'Step22. Check if Getting started tile is created in shared dashboard' {
            $link = $artifactFolder + $manual
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Getting started manual should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $link = $artifactFolder + $manual
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' Getting Started manual should be available in artifactfolder' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It 'Step22. Check if product company logo is created in shared dashboard' {
            $imageLink = $artifactFolder + $company + "-" + "main-logo.jpg"
            $result = get-sharedDashboardLink -dashboardName $dashboardName -dashboardLink $imageLink.tostring() -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Company Logo should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $imageLink
            $becauseText = ' Image for Company Logo should be available in artifactfolder' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if VM Tagging manual link is created in shared dashboard' {
            $linkPrefix = "https://portal.azure.com/#blade/Microsoft_Azure_Storage/ContainerMenuBlade/overview/storageAccountId/"
            $linkSuffix = "/path/customerdoc"
            $storageAccountId = $searchstorageAccountReporting.ResourceId -Replace "/", "%2F"
            $link = $linkPrefix + $storageAccountId + $linkSuffix
            $imageLink = $artifactFolder + $company + "-" + 'PDF.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to VM Tagging manual container should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to customerdoc container should be available' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for VM Tagging manual tile should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $imageLink
            $becauseText = ' Image for VM Tagging manual tile should be available in artifactfolder' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText

        } 
        It 'Step22. Check if Deploy VM UI link is created in shared dashboard' {
            $link = "https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FGLB-CES-PublicCloudAzure%2FELZ-azure-public%2Fmain%2FVM_templates%2Fdeploytemplate.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FGLB-CES-PublicCloudAzure%2FELZ-azure-public%2Fmain%2FVM_templates%2FcreateUIDefinition.json"
            $imageLink = $artifactFolder + $company + "-" + 'Monitor.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Custom deployment blade should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to Custom deployment blade should be available' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Deploy VM ui tile should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $imageLink
            $becauseText = ' Image for Deploy VM ui tile should be available in artifactfolder' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Deploy VM Templates link is created in shared dashboard' {
            $link = "https://github.com/GLB-CES-PublicCloudAzure/ELZ-azure-public/tree/main/VM_templates"
            $imageLink = $artifactFolder + $company + "-" + 'Navigation.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to VM Templates should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to VM Templates should be available' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for VM Templates ui tile should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $imageLink
            $becauseText = ' Image for VM Templates tile should be available in artifactfolder' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step22. Check if Available Virtual Machines overview is created in shared dashboard' {
            $name = 'Available Virtual Machines'
            $queryPart = 'resources\r\n| where type == \"microsoft.compute/virtualmachines\"\r\n|'
            $result = get-sharedDashboardLink -dashboardName $dashboardName -dashboardLink $name -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Available Virtual Machines overview should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashboardName -dashboardLink $queryPart -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Query for Available Virtual Machines overview should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step22. Check if Self Service Restore link is created in shared dashboard' {
            $link = "https://docs.microsoft.com/en-us/azure/backup/about-azure-vm-restore"
            $imageLink = $artifactFolder + $company + "-" + 'Backup.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Self Service Restore should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to Self Service Restore should be available' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Self Service Restore tile should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $imageLink
            $becauseText = ' Image for Self Service Restore tile should be available in artifactfolder' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if How to take app-consistent backup (Linux) link is created in shared dashboard' {
            $link = "https://docs.microsoft.com/en-us/azure/backup/backup-azure-linux-app-consistent"
            $imageLink = $artifactFolder + $company + "-" + 'Stopwatch.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to How to take app-consistent backup (Linux) should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to How to take app-consistent backup (Linux) should be available' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for How to take app-consistent backup (Linux) tile should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $imageLink
            $becauseText = ' Image for How to take app-consistent backup (Linux) tile should be available in artifactfolder' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step22. Check if Backup Center link is created in shared dashboard' {
            $link = "https://portal.azure.com/#blade/Microsoft_Azure_DataProtection/BackupCenterMenuBlade/backupReportsConfigure"
            $imageLink = $artifactFolder + $company + "-" + 'Backup.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Backup Center should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to Backup Center should be available' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Backup Center tile should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $imageLink
            $becauseText = ' Image for Backup Center tile should be available in artifactfolder' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step22. Check if Availability Report workbook is created and added to the shared dashboard' {
            $workbook = "Availability"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Availability Report workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step22. Check if Performance workbook is created in shared dashboard' {
            $link = "community-Workbooks/Virtual Machines - Performance Analysis/Performance Analysis for a Group of VMs"
            $link2 = "https://portal.azure.com/#blade/AppInsightsExtension/UsageNotebookBlade/ComponentId/Azure%20Monitor/ConfigurationId/community-Workbooks%2FVirtual%20Machines%20-%20Performance%20Analysis%2FPerformance%20Analysis%20for%20a%20Group%20of%20VMs/Type/workbook/ResourceIds/%5B%22Azure%20Monitor%22%5D/ViewerMode//GalleryResourceType/Azure%20Monitor/Source/Pinned/WorkbookTemplateName/Performance"
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Performance Report should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link2
            $becauseText = ' link to Performance Report should be available' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Security Posture link is created in shared dashboard' {
            $link = "https://portal.azure.com/#blade/Microsoft_Azure_Security/SecurityMenuBlade/26"
            $imageLink = $artifactFolder + $company + "-" + 'Defender.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Security Posture should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to Security Posture should be available' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $imageLink
            $becauseText = ' Image for Security Posture tile should be available in artifactfolder' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step22. Check if VM OS Image Gallery Report workbook is created and added to the shared dashboard' {
            $workbook = "VM OS Image Gallery"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' VM OS Image Gallery Report workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step22. Check if Backup Report workbook is created and added to the shared dashboard' {
            $workbook = "Backup"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Backup Report workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step22. Check if VM Tagging Report workbook is created and added to the shared dashboard' {
            $workbook = "VM Tagging"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' VM Tagging Report workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step22. Check if Antimalware Report workbook is created and added to the shared dashboard' {
            $workbook = "Antimalware"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Antimalware Report workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step22. Check if Availability Sets Report workbook is created and added to the shared dashboard' {
            $workbook = "Availability Sets"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Availability Sets Report workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }  
        It 'Step22. Check if Scale Sets Report workbook is created and added to the shared dashboard' {
            $workbook = "Scale Sets"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Scale Sets Report workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step22. Check if Disk Encryption Report workbook is created and added to the shared dashboard' {
            $workbook = "Disk Encryption"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Disk Encryption Report workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step22. Check if Storage Accounts Report workbook is created and added to the shared dashboard' {
            $workbook = "Storage Accounts"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Storage Accounts workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
    }
}