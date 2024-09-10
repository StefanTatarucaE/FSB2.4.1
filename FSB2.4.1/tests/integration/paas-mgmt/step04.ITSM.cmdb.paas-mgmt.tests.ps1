##
## Eviden Landing Zones for Azure - Feature test
##

Describe 'PAAS - ITSM CMDB feature' {

    BeforeAll {

        $dateTime = (Get-Date).ToString()
        $becauseText1 = 'the CMDB Logic-app should be triggered in the last ' + $logicapp_timewindow + ' minutes' + ' Checked at: ' + $($dateTime)
        $becauseText2 = 'the Alert Logic-app status should success' + ' Checked at: ' + $($dateTime)
        $becauseText3 = 'The CI properties should be valid' + ' Checked at: ' + $($dateTime)
        $becauseText4 = 'The incident should be attached to the right CMDB CI' + ' Checked at: ' + $($dateTime)
        $becauseText5 = 'There should be one incident created in Snow' + ' Checked at: ' + $($dateTime)

        # Get resource data
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $appService     = wait-untilTestingResourceIsReady -identifier "appsvc01" -resourceType "Microsoft.Web/sites" -tagPrefix $tagPrefix
        $appServicePlan = wait-untilTestingResourceIsReady -identifier "appsvcplan01" -resourceType "Microsoft.Web/serverFarms" -tagPrefix $tagPrefix
        $appGateway     = wait-untilTestingResourceIsReady -identifier "appgateway01" -resourceType "Microsoft.Network/applicationGateways" -tagPrefix $tagPrefix
        $loadBalancer   = wait-untilTestingResourceIsReady -identifier "loadbalancer01" -resourceType "Microsoft.Network/loadBalancers" -tagPrefix $tagPrefix
        $redisCache     = wait-untilTestingResourceIsReady -identifier "rediscache01" -resourceType "Microsoft.Cache/Redis" -tagPrefix $tagPrefix
        $cosmosDB       = wait-untilTestingResourceIsReady -identifier "cosmosdb01" -resourceType "Microsoft.DocumentDB/databaseAccounts" -tagPrefix $tagPrefix
        $mariaDB        = wait-untilTestingResourceIsReady -identifier "mariadb01" -resourceType "Microsoft.DBforMariaDB/servers" -tagPrefix $tagPrefix
        $mySQL          = wait-untilTestingResourceIsReady -identifier "mysqldb01" -resourceType "Microsoft.DBforMySQL/servers" -tagPrefix $tagPrefix
        $postgreSQL     = wait-untilTestingResourceIsReady -identifier "postgredb01" -resourceType "Microsoft.DBforPostgreSQL/servers" -tagPrefix $tagPrefix
        $SQLServer      = wait-untilTestingResourceIsReady -identifier "sqlsrv01" -resourceType "Microsoft.Sql/servers" -tagPrefix $tagPrefix
        $SQLDB          = wait-untilTestingResourceIsReady -identifier "sqldb01" -tagPrefix $tagPrefix
        $aksService     = wait-untilTestingResourceIsReady -identifier "akscluster01" -resourceType "Microsoft.ContainerService/managedClusters" -tagPrefix $tagPrefix

        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $laWorkspace    = get-logAnalyticsWorkspace -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        $alert_logicapp = search-azureResourceByTag -resourceType "Microsoft.Logic/workflows" -Tags @{"${tagPrefix}Purpose" = "${tagValuePrefix}ItsmAlerts"}
        $logicapp_timewindow = 240

        # Create test alerts
        write-host "Creating test alerts for PaaS resources ..."
        $testAlert_appService_alertName = "Example test alert - appService - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_appService  = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "appSvc" -resourceId $appService.Id -alertName $testAlert_appService_alertName
        $testAlert_appServicePlan_alertName = "Example test alert - appServicePlan - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_appServicePlan = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "appSvcPlan" -resourceId $appServicePlan.Id -alertName $testAlert_appServicePlan_alertName
        $testAlert_appGateway_alertName = "Example test alert - appGateway - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_appGateway = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "appGateway" -resourceId $appGateway.Id -alertName $testAlert_appGateway_alertName
        $testAlert_redisCache_alertName = "Example test alert - redisCache - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_redisCache = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "redisCache" -resourceId $redisCache.Id -alertName $testAlert_redisCache_alertName
        $testAlert_cosmosDB_alertName = "Example test alert - cosmosDB - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_cosmosDB  = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "cosmosDB" -resourceId $cosmosDB.Id -alertName $testAlert_cosmosDB_alertName
        $testAlert_loadBalancer_alertName = "Example test alert - loadBalancer - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_loadBalancer = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "loadBalancer" -resourceId $loadBalancer.Id -alertName $testAlert_loadBalancer_alertName
        $testAlert_mariaDB_alertName = "Example test alert - mariaDB - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_mariaDB = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "mariaDB" -resourceId $mariaDB.Id -alertName $testAlert_mariaDB_alertName
        $testAlert_mySQL_alertName = "Example test alert - mySQL - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_mySQL = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "mySQL" -resourceId $mySQL.Id -alertName $testAlert_mySQL_alertName
        $testAlert_postgreSQL_alertName = "Example test alert - postgreSQL - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_postgreSQL = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "postgreSQL" -resourceId $postgreSQL.Id -alertName $testAlert_postgreSQL_alertName
        $testAlert_SQLServer_alertName = "Example test alert - SQLServer - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_SQLServer = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "SQLServer" -resourceId $SQLServer.Id -alertName $testAlert_SQLServer_alertName
        $testAlert_SQLDB_alertName = "Example test alert - SQLDB - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_SQLDB = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "SQLDB" -resourceId $SQLDB.Id -alertName $testAlert_SQLDB_alertName
        $testAlert_aksService_alertName = "Example test alert - aksService - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_aksService = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "aksService" -resourceId $aksService.Id -alertName $testAlert_aksService_alertName
    }

    Context 'Verify MGMT ITSM PAAS alert flow' {

        It 'Check if Alert logic-app is trigerred in MGMT for appService' {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_appService_alertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred in MGMT for appServicePlan' {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_appServicePlan_alertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred in MGMT for appGateway' {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_appGateway_alertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred in MGMT for loadBalancer' {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_loadBalancer_alertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred in MGMT for redisCache' {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_redisCache_alertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred in MGMT for cosmosDB' {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                 outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_cosmosDB_alertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred in MGMT for mariaDB' {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                 outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_mariaDB_alertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred in MGMT for mySQL' {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_mySQL_alertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred in MGMT for postgreSQL' {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_postgreSQL_alertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred in MGMT for SQLServer' {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_SQLServer_alertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred in MGMT for SQLDB' {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_SQLDB_alertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred in MGMT for aksService' {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_aksService_alertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
    }

    Context 'Verify SNOW ITSM PAAS CMDB flow' {
        It 'Check if appSvc CI is created' {
            $params = @{
                 snowEnv         = $snowEnv
                 functionalOrg   = $snowFo
                 basicUsername   = $snowUsername
                 basicPassw      = $snowPassword
                 monitoringId    = get-monitoringIdFromResourceId -resourceId $appService.ResourceId -resourceName $appService.Name
            }
            $snowCi = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $becauseText = 'There should be one CI for the appService CI in Snow' + ' Checked at: ' + $($dateTime)
            $snowCi.count | Should -Be 1 -Because $becauseText
            $snowCi.sys_class_name | Should -Be "cmdb_ci_appl" -Because $becauseText3
        }
        It 'Check if appServicePlan CI is created' {
            $params = @{
                 snowEnv         = $snowEnv
                 functionalOrg   = $snowFo
                 basicUsername   = $snowUsername
                 basicPassw      = $snowPassword
                 monitoringId    = get-monitoringIdFromResourceId -resourceId $appServicePlan.ResourceId -resourceName $appServicePlan.Name
            }
            $snowCi = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $becauseText = 'There should be one CI for the appServicePlan CI in Snow' + ' Checked at: ' + $($dateTime)
            $snowCi.count | Should -Be 1 -Because $becauseText
            $snowCi.sys_class_name | Should -Be "cmdb_ci_appl" -Because $becauseText3
        }
        It 'Check if appGateway CI is created' {
            $params = @{
                 snowEnv         = $snowEnv
                 functionalOrg   = $snowFo
                 basicUsername   = $snowUsername
                 basicPassw      = $snowPassword
                 monitoringId    = get-monitoringIdFromResourceId -resourceId $appGateway.ResourceId -resourceName $appGateway.Name
            }
            $snowCi = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $becauseText = 'There should be one CI for the appGateway CI in Snow' + ' Checked at: ' + $($dateTime)
            $snowCi.count | Should -Be 1 -Because $becauseText
            $snowCi.sys_class_name | Should -Be "cmdb_ci_lb_appl" -Because $becauseText3
        }
        It 'Check if loadBalancer CI is created' {
            $params = @{
                 snowEnv         = $snowEnv
                 functionalOrg   = $snowFo
                 basicUsername   = $snowUsername
                 basicPassw      = $snowPassword
                 monitoringId    = get-monitoringIdFromResourceId -resourceId $loadBalancer.ResourceId -resourceName $loadBalancer.Name
            }
            $snowCi = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $becauseText = 'There should be one CI for the loadBalancer CI in Snow' + ' Checked at: ' + $($dateTime)
            $snowCi.count | Should -Be 1 -Because $becauseText
            $snowCi.sys_class_name | Should -Be "cmdb_ci_lb_appl" -Because $becauseText3
        }
        It 'Check if redisCache CI is created' {
            $params = @{
                 snowEnv         = $snowEnv
                 functionalOrg   = $snowFo
                 basicUsername   = $snowUsername
                 basicPassw      = $snowPassword
                 monitoringId    = get-monitoringIdFromResourceId -resourceId $redisCache.ResourceId -resourceName $redisCache.Name
            }
            $snowCi = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $becauseText = 'There should be one CI for the redisCache CI in Snow' + ' Checked at: ' + $($dateTime)
            $snowCi.count | Should -Be 1 -Because $becauseText
            $snowCi.sys_class_name | Should -Be "cmdb_ci_database" -Because $becauseText3
        }
        It 'Check if cosmosDB CI is created' {
            $params = @{
                 snowEnv         = $snowEnv
                 functionalOrg   = $snowFo
                 basicUsername   = $snowUsername
                 basicPassw      = $snowPassword
                 monitoringId    = get-monitoringIdFromResourceId -resourceId $cosmosDB.ResourceId -resourceName $cosmosDB.Name
            }
            $snowCi = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $becauseText = 'There should be one CI for the cosmosDB CI in Snow' + ' Checked at: ' + $($dateTime)
            $snowCi.count | Should -Be 1 -Because $becauseText
            $snowCi.sys_class_name | Should -Be "cmdb_ci_database" -Because $becauseText3
        }
        It 'Check if mariaDB CI is created' {
            $params = @{
                 snowEnv         = $snowEnv
                 functionalOrg   = $snowFo
                 basicUsername   = $snowUsername
                 basicPassw      = $snowPassword
                 monitoringId    = get-monitoringIdFromResourceId -resourceId $mariaDB.ResourceId -resourceName $mariaDB.Name
            }
            $snowCi = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $becauseText = 'There should be one CI for the mariaDB CI in Snow' + ' Checked at: ' + $($dateTime)
            $snowCi.count | Should -Be 1 -Because $becauseText
            $snowCi.sys_class_name | Should -Be "cmdb_ci_database" -Because $becauseText3
        }
        It 'Check if mySQL CI is created' {
            $params = @{
                 snowEnv         = $snowEnv
                 functionalOrg   = $snowFo
                 basicUsername   = $snowUsername
                 basicPassw      = $snowPassword
                 monitoringId    = get-monitoringIdFromResourceId -resourceId $mySQL.ResourceId -resourceName $mySQL.Name
            }
            $snowCi = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $becauseText = 'There should be one CI for the mySQL CI in Snow' + ' Checked at: ' + $($dateTime)
            $snowCi.count | Should -Be 1 -Because $becauseText
            $snowCi.sys_class_name | Should -Be "cmdb_ci_database" -Because $becauseText3
        }
        It 'Check if postgreSQL CI is created' {
            $params = @{
                 snowEnv         = $snowEnv
                 functionalOrg   = $snowFo
                 basicUsername   = $snowUsername
                 basicPassw      = $snowPassword
                 monitoringId    = get-monitoringIdFromResourceId -resourceId $postgreSQL.ResourceId -resourceName $postgreSQL.Name
            }
            $snowCi = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $becauseText = 'There should be one CI for the postgreSQL CI in Snow' + ' Checked at: ' + $($dateTime)
            $snowCi.count | Should -Be 1 -Because $becauseText
            $snowCi.sys_class_name | Should -Be "cmdb_ci_database" -Because $becauseText3
        }
        It 'Check if SQLServer CI is created' {
            $params = @{
                 snowEnv         = $snowEnv
                 functionalOrg   = $snowFo
                 basicUsername   = $snowUsername
                 basicPassw      = $snowPassword
                 monitoringId    = get-monitoringIdFromResourceId -resourceId $SQLServer.ResourceId -resourceName $SQLServer.Name
            }
            $snowCi = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $becauseText = 'There should be one CI for the SQLServer CI in Snow' + ' Checked at: ' + $($dateTime)
            $snowCi.count | Should -Be 1 -Because $becauseText
            $snowCi.sys_class_name | Should -Be "cmdb_ci_db_instance" -Because $becauseText3
        }
        It 'Check if SQLDB CI is created' {
            $params = @{
                 snowEnv         = $snowEnv
                 functionalOrg   = $snowFo
                 basicUsername   = $snowUsername
                 basicPassw      = $snowPassword
                 monitoringId    = get-monitoringIdFromResourceId -resourceId $SQLDB.ResourceId -resourceName $SQLDB.Name.split('/')[1]
            }
            $snowCi = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $becauseText = 'There should be one CI for the SQLDB CI in Snow' + ' Checked at: ' + $($dateTime)
            $snowCi.count | Should -Be 1 -Because $becauseText
            $snowCi.sys_class_name | Should -Be "cmdb_ci_database" -Because $becauseText3
        }
        It 'Check if aksService CI is created' {
            $params = @{
                 snowEnv         = $snowEnv
                 functionalOrg   = $snowFo
                 basicUsername   = $snowUsername
                 basicPassw      = $snowPassword
                 monitoringId    = get-monitoringIdFromResourceId -resourceId $aksService.ResourceId -resourceName $aksService.Name
            }
            $snowCi = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $becauseText = 'There should be one CI for the aksService CI in Snow' + ' Checked at: ' + $($dateTime)
            $snowCi.count | Should -Be 1 -Because $becauseText
            $snowCi.sys_class_name | Should -Be "cmdb_ci_kubernetes_cluster" -Because $becauseText3
        }
    }

    Context 'Verify SNOW ITSM PAAS CMDB Alert flow' {
        It 'Check if appSvc Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_appService_alertName
                descriptionTag  = $testAlert_appService.descriptionTag
            }
            $monId = get-monitoringIdFromResourceId -resourceId $appService.ResourceId -resourceName $appService.Name
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText5
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText4
            remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_appService_alertName
        }
        It 'Check if appServicePlan Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_appServicePlan_alertName
                descriptionTag  = $testAlert_appServicePlan.descriptionTag
            }
            $monId = get-monitoringIdFromResourceId -resourceId $appServicePlan.ResourceId -resourceName $appServicePlan.Name
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText5
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText4
            remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_appServicePlan_alertName
        }
         It 'Check if appGateway Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_appGateway_alertName
                descriptionTag  = $testAlert_appGateway.descriptionTag
            }
            $monId = get-monitoringIdFromResourceId -resourceId $appGateway.ResourceId -resourceName $appGateway.Name
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText5
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText4
            remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_appGateway_alertName
        }
        It 'Check if redisCache Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_redisCache_alertName
                descriptionTag  = $testAlert_redisCache.descriptionTag
            }
            $monId = get-monitoringIdFromResourceId -resourceId $redisCache.ResourceId -resourceName $redisCache.Name
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText5
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText4
            remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_redisCache_alertName
        }
        It 'Check if cosmosDB Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_cosmosDB_alertName
                descriptionTag  = $testAlert_cosmosDB.descriptionTag
            }
            $monId = get-monitoringIdFromResourceId -resourceId $cosmosDB.ResourceId -resourceName $cosmosDB.Name
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText5
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText4
            remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_cosmosDB_alertName
        }
        It 'Check if loadBalancer Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_loadBalancer_alertName
                descriptionTag  = $testAlert_loadBalancer.descriptionTag
            }
            $monId = get-monitoringIdFromResourceId -resourceId $loadBalancer.ResourceId -resourceName $loadBalancer.Name
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText5
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText4
            remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_loadBalancer_alertName
        }
        It 'Check if mariaDB Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_mariaDB_alertName
                descriptionTag  = $testAlert_mariaDB.descriptionTag
            }
            $monId = get-monitoringIdFromResourceId -resourceId $mariaDB.ResourceId -resourceName $mariaDB.Name
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText5
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText4
            remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_mariaDB_alertName
        }
        It 'Check if mySQL Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_mySQL_alertName
                descriptionTag  = $testAlert_mySQL.descriptionTag
            }
            $monId = get-monitoringIdFromResourceId -resourceId $mySQL.ResourceId -resourceName $mySQL.Name
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText5
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText4
            remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_mySQL_alertName
        }
        It 'Check if postgreSQL Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_postgreSQL_alertName
                descriptionTag  = $testAlert_postgreSQL.descriptionTag
            }
            $monId = get-monitoringIdFromResourceId -resourceId $postgreSQL.ResourceId -resourceName $postgreSQL.Name
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText5
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText4
            remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_postgreSQL_alertName
        }
        It 'Check if SQLServer Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_SQLServer_alertName
                descriptionTag  = $testAlert_SQLServer.descriptionTag
            }
            $monId = get-monitoringIdFromResourceId -resourceId $SQLServer.ResourceId -resourceName $SQLServer.Name
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText5
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText4
            remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_SQLServer_alertName
        }
        It 'Check if SQLDB Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_SQLDB_alertName
                descriptionTag  = $testAlert_SQLDB.descriptionTag
            }
            $monId = get-monitoringIdFromResourceId -resourceId $SQLDB.ResourceId -resourceName $SQLDB.Name.split('/')[1]
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText5
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText4
            remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_SQLDB_alertName
        }
        It 'Check if aksService Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_aksService_alertName
                descriptionTag  = $testAlert_aksService.descriptionTag
            }
            $monId = get-monitoringIdFromResourceId -resourceId $aksService.ResourceId -resourceName $aksService.Name
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText5
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText4
            remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_aksService_alertName
        }
    }

    AfterAll {
      write-host "Delete test alerts for PaaS resources ..."
      Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
      remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_appService_alertName
      remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_appServicePlan_alertName
      remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_appGateway_alertName
      remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_redisCache_alertName
      remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_cosmosDB_alertName
      remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_loadBalancer_alertName
      remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_mariaDB_alertName
      remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_mySQL_alertName
      remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_postgreSQL_alertName
      remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_SQLServer_alertName
      remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_SQLDB_alertName
      remove-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlert_aksService_alertName
    }
}