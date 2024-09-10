##
## Eviden Landing Zones for Azure - Feature test
##

Describe 'CORE - ITSM ALERTS feature' {

    BeforeAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        $laWorkspace = get-logAnalyticsWorkspace -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        $dcsRuleName = "${tagPrefix}DiagnosticRule-SendToLogAnalytics"
        $diagRules_CNTY = get-diagRule -resourceId ("/subscriptions/"+$custCntySubscriptionId)
        $diagRules_MGMT = get-diagRule -resourceId ("/subscriptions/"+$custMgmtSubscriptionId)
        $diagRules_LNDZ = get-diagRule -resourceId ("/subscriptions/"+$custLndzSubscriptionId)

        # Create test alert
        $testAlertName = "Example test alert - Generic - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "Generic" -alertName $testAlertName
    }

    Context 'Verify activity diag rules' {
        It 'Check if diagrule is present on all customer subcriptions' {
            If (($diagRules_CNTY -eq $null) -or ($diagRules_MGMT -eq $null) -or ($diagRules_LNDZ -eq $null)) {
                # We need to run a compliance scan, and then run the remediation runbook
                write-host "Diag rules missing on one of the customer subscription, forcing policy to apply"
                $policyScan = start-policyScan
                $policyScan.state | Should -Be "Completed" -Because $becauseText
                write-host "Forcing remediation runbook"
                Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
                $becauseText = 'The Runbook should have the status completed' + 'Checked at:' + $($dateTime)
                $runbookCompletedInCore = start-mgmtAutomationRunbook -runbookName "MONITORING-Create-RemediationTaskDiagnosticSettings" -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
                $runbookCompletedInCore | Should -Be $true -Because $becauseText

                # Enter wait/retry loop to let remediation task do it's task for each subscription
                $params = @{
                    resourceid = ("/subscriptions/"+$custCntySubscriptionId)
                    WarningAction = "SilentlyContinue"
                }            
                $diagSettings = wait-loop -sleepTime 5 -numberOfRetries 60 -command "Get-AzDiagnosticSetting" -params $Params                
                $params = @{
                    resourceid = ("/subscriptions/"+$custMgmtSubscriptionId)
                    WarningAction = "SilentlyContinue"
                }            
                $diagSettings = wait-loop -sleepTime 5 -NumberOfRetries 60 -command "Get-AzDiagnosticSetting" -params $Params  
                $params = @{
                    resourceid = ("/subscriptions/"+$custLndzSubscriptionId)
                    WarningAction = "SilentlyContinue"
                }            
                $diagSettings = wait-loop -sleepTime 5 -NumberOfRetries 60 -command "Get-AzDiagnosticSetting" -params $Params 

                # Get applied diag rules for proper testing
                $diagRules_CNTY = get-diagRule -resourceId ("/subscriptions/"+$custCntySubscriptionId)
                $diagRules_MGMT = get-diagRule -resourceId ("/subscriptions/"+$custMgmtSubscriptionId)
                $diagRules_LNDZ = get-diagRule -resourceId ("/subscriptions/"+$custLndzSubscriptionId)                                
            }

            #CNTY
            $becauseText = 'a diagnostic rule need to be set on CNTY subscription' + 'Checked at:' + $($dateTime)
            $diagRules_CNTY | Should -Not -Be $null -Because $becauseText
            $diagRules_CNTY.name | Should -BeLikeExactly $DCSRuleName -Because $becauseText

            $becauseText = 'the LA workspace needs to be configured in the diagnostic rule on CNTY subscription' + 'Checked at:' + $($dateTime)
            $diagRules_CNTY.WorkspaceId | Should -BeLike $laWorkspace.Id -Because $becauseText

            #MGMT
            $becauseText = 'a diagnostic rule need to be set on MGMT subscription' + 'Checked at:' + $($dateTime)
            $diagRules_MGMT | Should -Not -Be $null -Because $becauseText
            $diagRules_MGMT.name | Should -BeLikeExactly $DCSRuleName -Because $becauseText

            $becauseText = 'the LA workspace needs to be configured in the diagnostic rule on MGMT subscription' + 'Checked at:' + $($dateTime)
            $diagRules_MGMT.WorkspaceId | Should -BeLike $laWorkspace.Id -Because $becauseText
            
            #LNDZ
            $becauseText = 'a diagnostic rule need to be set on LNDZ subscription' + 'Checked at:' + $($dateTime)
            $diagRules_LNDZ | Should -Not -Be $null -Because $becauseText
            $diagRules_LNDZ.name | Should -BeLikeExactly $DCSRuleName -Because $becauseText

            $becauseText = 'the LA workspace needs to be configure in the diagnostic rule on LNDZ subscription' + 'Checked at:' + $($dateTime)
            $diagRules_LNDZ.WorkspaceId | Should -BeLike $laWorkspace.Id -Because $becauseText
        }
        It 'Check if activity table exists in the LA workspace' {
            $params = @{
                logAnalyticsWorkspace = $laWorkspace
                logAnalyticsQuery = "AzureActivity|top 1 by TimeGenerated desc"
                tenantId = $tenantId
            }
            $becauseText = 'the LA workspace activity table should contain one entry at least' + 'Checked at:' + $($dateTime)
            $queryOutput = wait-loop -sleepTime 30 -numberOfRetries 25 -command "Invoke-LogAnalyticsQuery" -params $Params
            ($queryOutput | Measure-Object).Count | Should -Be 1 -Because $becauseText
        }
    }
    Context 'Verify Mgmt ITSM flow' {
        It 'Check if test alert is fired in azure monitor' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $params = @{
                AlertRuleId = $testAlert.alertID
                HistoryInMinutes = 10
            }
            $alertHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-alertHistoryInTimeRange" -params $Params

            $becauseText = 'the test alert should be fired in Azure Monitor in the last 10 minutes' + 'Checked at:' + $($dateTime)
            $alertHistory | Should -Not -BeNullOrEmpty -Because $becauseText

            disable-monitoringAlertRule -laWorkspace $laWorkspace -alertRuleName $testAlertName
        }      
        It 'Check if Alert logic-app is trigerred in Mgmt' -Tag "itsm-flow-logic-app" {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $alert_logicapp = search-azureResourceByTag -resourceType "Microsoft.Logic/workflows" -tags @{"${tagPrefix}Purpose" = "${tagValuePrefix}ItsmAlerts"}
            $params = @{
                LogicApp = $alert_logicapp
                HistoryInMinutes = 10
                OutputVariable = "OUTPUT_SENTALERT"
                OutputValue = $testAlertName
            }
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $params
            $becauseText = 'the Alert Logic-app should be triggered in the last 10 minutes' + 'Checked at:' + $($dateTime)
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText

            $becauseText = 'the Alert Logic-app status should be success' + 'Checked at:' + $($dateTime)
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText
        } 
        It 'Check if Alert function is trigerred in Mgmt' -Tag "itsm-flow-function-itsm" {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $laWorkspace = get-logAnalyticsWorkspace -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $alertFunctionApp = search-azureResourceByTag -resourceType Microsoft.Web/sites -tags @{"${tagPrefix}Purpose" = "${tagValuePrefix}ItsmListener"}
            $alertFunctions = get-functionAppFunctions -resourceId $alertFunctionApp.ResourceId
            $alertFunction = "itsm-al-listener-atf2"
            # Ensure that function exists in functionapp
            $becauseText = 'ITSM alert function should be present in the ITSM function app' + 'Checked at:' + $($dateTime)
            $alertFunction | Should -BeIn $alertFunctions.properties.name `
            -Because $becauseText
            # Ensure that function is run successfully
            $params = @{
                resourceId = $alertFunctionApp.ResourceId
                functionName = $alertFunction
                logAnalyticsWorkspace = $laWorkspace
                searchText = $testAlertName
                timeRange = '1h'
                tenantId = $tenantId
            }
            $qOut = wait-loop -numberOfRetries 20 -sleepTime 30 -command get-functionAppLogsResult -params $params
            $becauseText = 'ITSM Alert function for this test alert should report that execution succeeded in FunctionAppLogs' + 'Checked at:' + $($dateTime)
            $qOut.Result | Should -Be 'Succeeded' `
                -Because $becauseText
        }         
    }
    Context 'Verify SNOW ITSM flow' {
        It 'Check if Incident is created in Snow for the test alert' -Tag "itsm-flow-snow" {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlertName
                descriptionTag  = $testAlert.descriptionTag
            }
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $snowIncident = wait-loop -numberOfRetries 20 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $becauseText = 'There should be one opened incident for this test alert in SNOW' + 'Checked at:' + $($dateTime)
            $snowIncident.count | Should -Be 1 -Because $becauseText

            $becauseText = 'The incident properties should be valid' + 'Checked at:' + $($dateTime)
            $snowIncident.u_event_type | Should -Be "AVAILABILITY" -Because $becauseText
            $snowIncident.priority | Should -Be 3 -Because $becauseText
            $snowIncident.u_atos_primary_category | Should -Be "Cloud" -Because $becauseText
            $snowIncident.u_atos_subcategory_1 | Should -Be "PaaS" -Because $becauseText
            $snowIncident.u_atos_subcategory_2 | Should -Be "DCS-Azure-Management" -Because $becauseText

            $becauseText = 'The incident should contain an affected CI' + 'Checked at:' + $($dateTime)
            $snowIncident.cmdb_ci.name | Should -Not -BeNullOrEmpty -Because $becauseText
            $snowIncident.cmdb_ci.class | Should -Not -BeNullOrEmpty -Because $becauseText
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Not -BeNullOrEmpty -Because $becauseText            
        } 
    }

    AfterAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        write-host ("Deleting test alert ["+$testAlertName+"]")
        remove-monitoringAlertRule -laWorkspace $laWorkspace -AlertRuleName $testAlertName
    }    
}