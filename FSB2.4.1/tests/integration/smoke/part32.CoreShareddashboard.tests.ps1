##
## Eviden Landing Zones for Azure - Feature test shared dashboard for Core
##
 
Describe 'Smoke and Sanity Testing for Eviden Landing Zones for Azure Product' {

    BeforeAll {
        $dashBoardName = "CloudCoreReportingDashboard"
        $manual = $company  + "-Cloud-Core-Reporting-Dashboard-Manual.pdf"
        
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        $searchStorageAccountReporting = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -tag @{"${tagPrefix}Purpose" = "${tagValuePrefix}Reporting" }
        $storageAccountReporting = get-azstorageaccount -ResourceGroupName $searchStorageAccountReporting.ResourceGroupName -StorageAccountName $searchStorageAccountReporting.name
        $storageAccountContext = $storageAccountReporting.context
        $Global:artifactFolder = ""
    }

    Context ' Check shared dashboard Core' {
            
        It 'Step21. Check if CloudCoreReportingDashboard is created' {
            $result = get-sharedDashboard -dashboardName $dashBoardName -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' CloudCoreReportingDashboard should be created' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Artifactfolder is created' {
            $checkFolder = get-dashboardArtifacts -dashboardName $dashBoardName -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $result = $checkFolder.result 
            If ($result -eq $true) {
                $Global:ArtifactFolder = $checkFolder.Name
            }
            $becauseText = ' Artifactfolder should be created' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 

        It 'Step21. Check if Getting started tile is created in shared dashboard' {
            $link = $artifactFolder + $manual
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Getting started manual should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $link = $artifactFolder + $manual
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' Getting Started manual should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It 'Step21. Check if product company logo is created in shared dashboard' {
            $Imagelink = $artifactFolder + $company + "-" + "main-logo.jpg"
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink.tostring() -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Company Logo should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Company Logo should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if Tenant Users link is created in shared dashboard' {
            $link = "https://portal.azure.com/#blade/Microsoft_AAD_IAM/UsersManagementMenuBlade/MsGraphUsers"
            $Imagelink = $artifactFolder + $company + "-" + 'Tenant-users.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Tenant Users blade should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to Tenant Users blade should be available' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Tenant Users tile should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Tenant Users tile should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if Tenant Groups link is created in shared dashboard' {
            $link = "https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupsManagementMenuBlade/AllGroups"
            $Imagelink = $artifactFolder + $company + "-" + 'Tenant-groups.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Tenant Groups blade should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to Tenant Groups blade should be available' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Tenant Groups tile should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Tenant Groups tile should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if Roles and Administrators link is created in shared dashboard' {
            $link = "https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RolesAndAdministrators"
            $Imagelink = $artifactFolder + $company + "-" + 'Roles-and-admins.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Roles and Administrators blade should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to Roles and Administrators blade should be available' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Roles and Administrators tile should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Roles and Administrators tile should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if App registrations link is created in shared dashboard' {
            $link = "https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps"
            $Imagelink = $artifactFolder + $company + "-" + 'App-registrations.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to App registrations blade should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to  App registrations blade should be available' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for App registrations tile should be created in ' + $($dashBoardName)  + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for App registrations tile should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if Subscription Roles link is created in shared dashboard' {
            $linkPrefix = "https://portal.azure.com/#blade/Microsoft_Azure_Storage/ContainerMenuBlade/overview/storageAccountId/"
            $Imagelink = $artifactFolder + $company + "-" + 'IAM.svg'
            $linkSuffix = "/path/iamsubscriptionreport"
            $storageAccountId = $searchStorageAccountReporting.ResourceId -Replace "/", "%2F"
            $link = $linkPrefix + $storageAccountId + $linkSuffix
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to iamsubscriptionreport container should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to iamsubscriptionreport container should be available' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Subscription Roles tile should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Subscription Roles tile should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Offline reporting link is created in shared dashboard' {
            $linkPrefix = "https://portal.azure.com/#blade/Microsoft_Azure_Storage/ContainerMenuBlade/overview/storageAccountId/"
            $linkSuffix = "/path/offlinereports"
            $storageAccountId = $searchStorageAccountReporting.ResourceId -Replace "/", "%2F"
            $link = $linkPrefix + $storageAccountId + $linkSuffix
            $Imagelink = $artifactFolder + $company + "-" + 'Document-Multiple.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to offlinereports container should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to offlinereports container should be available' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Offline Reports tile should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Offline Reports tile should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if Incident and change Report link is created in shared dashboard' {
            $linkPrefix = "https://portal.azure.com/#blade/Microsoft_Azure_Storage/ContainerMenuBlade/overview/storageAccountId/"
            $linkSuffix = "/path/incidentchangereport"
            $storageAccountId = $searchStorageAccountReporting.ResourceId -Replace "/", "%2F"
            $link = $linkPrefix + $storageAccountId + $linkSuffix
            $Imagelink = $artifactFolder + $company + "-" + 'PDF.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to incidentchangereport container should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to incidentchangereport container should be available' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Incident and change Report tiles should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Incident and change Report tiles should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if Azure Consumption Report workbook is created and added to the shared dashboard' {
            $workbook = "Azure Consumption"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Azure Consumption Report workbook should be created and added to shared dashboard ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if PIM Role Assignments Report workbook is created and added to the shared dashboard' {
            $workbook = "PIM Role Assignments"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' PIM Role Assignments Report workbook should be created and added to shared dashboard ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if Pol. Assignments link is created in shared dashboard' {
            $link = "https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Assignments"
            $Imagelink = $artifactFolder + $company + "-" + 'Policy.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Pol. Assignments blade should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to Pol. Assignments blade should be available' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Pol. Assignments tile should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Pol. Assignments tile should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if Pol. Compliance link is created in shared dashboard' {
            $link = "https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Compliance"
            $Imagelink = $artifactFolder + $company + "-" + 'Compliant.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Pol. Compliance blade should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to Pol. Compliance blade should be available' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Pol. Compliance tile should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Pol. Compliance tile should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if Security Log Except. Report workbook is created and added to the shared dashboard' {
            $workbook = "Security Log Except."
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Security Log Except. Report workbook should be created and added to shared dashboard ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It 'Step21. Check if Log Analytics Workspace Report workbook is created and added to the shared dashboard' {
            $workbook = "Log Analytics Workspace"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Log Analytics Workspace Report workbook should be created and added to shared dashboard ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if Orphan resources Report workbook is created and added to the shared dashboard' {
            $workbook = "Orphan resources"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Orphan Resources Report workbook should be created and added to shared dashboard ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It 'Step21. Check if Maintenance Report workbook is created and added to the shared dashboard' {
            $workbook = "Maintenance Report"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Maintenance Report workbook should be created and added to shared dashboard ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It 'Step21. Check if Virtual WAN Report workbook is created and added to the shared dashboard' {
            $workbook = "Virtual WAN"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Virtual WAN Report workbook should be created and added to shared dashboard ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Ticketing (placeholder) link is created in shared dashboard' {
            #   Placeholder: only image, no link
            $Imagelink = $artifactFolder + $company + "-" + 'Support.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Ticketing tile should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Ticketing tile should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if Cost Management link is created in shared dashboard' {
            $link = "https://portal.azure.com/#blade/Microsoft_Azure_CostManagement/Menu/costanalysis"
            $Imagelink = $artifactFolder + $company + "-" + 'Cost-overview.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Cost Management blade should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to Cost Management blade should be available' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Cost Management tile should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Cost Management tile should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Step21. Check if Cost Advisor link is created in shared dashboard' {
            $link = "https://portal.azure.com/#blade/Microsoft_Azure_CostManagement/Menu/costrecommendations"
            $Imagelink = $artifactFolder + $company + "-" + 'Cost-efficiency.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Cost Advisor blade should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to Cost Advisor blade should be available' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Cost Advisor tile should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Cost Advisor tile should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Regulatory Compl. link is created in shared dashboard' {
            $link = "https://portal.azure.com/#blade/Microsoft_Azure_Security/SecurityMenuBlade/0"
            $Imagelink = $artifactFolder + $company + "-" + 'Security-Shield.svg'
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Regulatory Compl. blade should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' link to Regulatory Compl. blade should be available' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $Imagelink -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to image for Regulatory Compl. tile should be created in ' + $($dashBoardName) + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Regulatory Compl. tile should be available in Artifactfolder' + ' Checked at: ' + $($DateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
    }
}