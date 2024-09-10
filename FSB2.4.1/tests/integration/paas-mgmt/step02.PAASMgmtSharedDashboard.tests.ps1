##
## Eviden Landing Zones for Azure - Feature test shared dashboard for PAAS MGMT
##
 
Describe 'PAAS-MGMT - Shared dashboard PaaSServicesReportingDashboard' {

    BeforeAll {
        $dashboardName = "PaaSServicesReportingDashboard"
        $manual = $company + "-PaaS-Services-Reporting-Dashboard-Manual.pdf"
        
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        $searchStorageAccountReporting = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -tag @{"${tagPrefix}Purpose" = "${tagValuePrefix}Reporting" }
        $storageAccountReporting = get-azstorageaccount -ResourceGroupName $searchStorageAccountReporting.ResourceGroupName -StorageAccountName $searchStorageAccountReporting.name
        $storageAccountContext = $storageAccountReporting.context
        $Global:artifactFolder = ""
    }

    Context 'Check shared dashboard PaaSServicesReportingDashboard' {
            
        It 'Check if PaaSServicesReportingDashboard is created' {
            
            $result = get-sharedDashboard -dashboardName $dashboardName -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' PaaSServicesReportingDashboard should be created' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It 'Check if artifactfolder is created' {
            $checkFolder = get-dashboardArtifacts -dashboardName $dashBoardName -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $result = $checkfolder.result 
            If ($result -eq $true) {
                $Global:artifactFolder = $checkFolder.name
            }
            $becauseText = ' artifactfolder should be created' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 

        It 'Check if Getting started tile is created in shared dashboard' {
            $link = $artifactFolder + $manual
            $result = get-sharedDashboardLink -dashboardName $dashBoardName -dashboardLink $link -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Getting started manual should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $link = $artifactFolder + $manual
            $result = get-webRequestSucceeded -webLink $link
            $becauseText = ' Getting Started manual should be available in artifactfolder' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if product company Logo is created in shared dashboard' {
            $Imagelink = $artifactFolder + $company + "-" + "main-logo.jpg"
            $result = get-sharedDashboardLink -dashboardName $dashboardName -dashboardLink $Imagelink.tostring() -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' link to Company Logo should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-webRequestSucceeded -webLink $Imagelink
            $becauseText = ' Image for Company Logo should be available in artifactfolder' + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if last version of Deployed PaaS services overview is created in shared dashboard' {
            $name = 'Deployed PaaS services'
            $queryPart = 'microsoft.azurearcdata/postgresinstances'
            $result = get-sharedDashboardLink -dashboardName $dashboardName -dashboardLink $name -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Deployed PaaS services overview should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
            $result = get-sharedDashboardLink -dashboardName $dashboardName -dashboardLink $queryPart -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Query for Deployed PaaS services overview should be created in ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if SQL Database Report workbook is created and added to the shared dashboard' {
            $workBook = "SQL Database"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' SQL Database Report workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Data Factory Report workbook is created and added to the shared dashboard' {
            $workBook = "Data Factory"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Data Factory workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Analysis Service Report workbook is created and added to the shared dashboard' {
            $workBook = "Analysis Service"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Analysis Service workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if App Service Report workbook is created and added to the shared dashboard' {
            $workBook = "App Service"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' App Service workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if SQL Man. Instance Report workbook is created and added to the shared dashboard' {
            $workBook = "SQL Man Instance"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' SQL Man. Instance workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Cosmos DB Report workbook is created and added to the shared dashboard' {
            $workBook = "Cosmos DB"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Cosmos DB workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Cache for Redis Report workbook is created and added to the shared dashboard' {
            $workBook = "Cache for Redis"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Cache for Redis workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Cache for Redis Ent. Report workbook is created and added to the shared dashboard' {
            $workBook = "Cache for Redis Ent"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Cache for Redis Ent. workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if Application Gateway Report workbook is created and added to the shared dashboard' {
            $workBook = "Application Gateway"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Application Gateway workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if MySQL Server Report workbook is created and added to the shared dashboard' {
            $workBook = "MySQL Server"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' MySQL Server workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        } 
        It ' Check if MySQL Flex. Server Report workbook is created and added to the shared dashboard' {
            $workBook = "MySQL Flex Server"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' MySQL Flex. Server workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if PostgreSQL Server Report workbook is created and added to the shared dashboard' {
            $workBook = "PostgreSQL Server"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' PostgreSQL Server workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if PostgreSQL Flex. Svr Report workbook is created and added to the shared dashboard' {
            $workBook = "PostgreSQL Flex Svr"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' PostgreSQL Flex. Svr workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if MariaDB Report workbook is created and added to the shared dashboard' {
            $workBook = "MariaDB"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' MariaDB workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if Databricks Report workbook is created and added to the shared dashboard' {
            $workBook = "Databricks"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Databricks workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if Synapse Analytics Report workbook is created and added to the shared dashboard' {
            $workBook = "Synapse Analytics"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Synapse Analytics workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if SQL Svr Stretch DB Report workbook is created and added to the shared dashboard' {
            $workBook = "SQL Svr Stretch DB"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' SQL Svr Stretch DB workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if Dedicated SQL pools Report workbook is created and added to the shared dashboard' {
            $workBook = "Dedicated SQL pools"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Dedicated SQL pools workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if Cosmos DB for PostgreSQL clusters Report workbook is created and added to the shared dashboard' {
            $workBook = "Cosmos DB PostgreSQL"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Cosmos DB PostgreSQL workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if Data explorer cluster Report workbook is created and added to the shared dashboard' {
            $workBook = "Data explorer cluster"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Data explorer cluster workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if Container Registry Report workbook is created and added to the shared dashboard' {
            $workBook = "Container Registry"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Container Registry workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if Azure Kubernet Services Overview Report workbook is created and added to the shared dashboard' {
            $workBook = "AKS-Overview"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Azure Kubernet Services Overview workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if Azure Kubernet Services Workloads Report workbook is created and added to the shared dashboard' {
            $workBook = "AKS-Workload"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' AKS-Workloads workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
        It ' Check if Azure Function Workloads Report workbook is created and added to the shared dashboard' {
            $workBook = "Azure Function"
            $result = get-sharedDashboardReport -dashboardName $dashBoardName -workbookName $workbook -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = ' Azure Function workbook should be created and added to shared dashboard ' + $($dashboardName) + ' Checked at: ' + $($dateTime)
            $result | Should -BeLike $true -Because $becauseText
        }
    }
}

