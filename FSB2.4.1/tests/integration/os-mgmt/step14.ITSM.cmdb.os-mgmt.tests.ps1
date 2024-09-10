##
## Eviden Landing Zones for Azure - Feature test
##

Describe 'OS-MGMT - ITSM CMDB feature' {

    BeforeAll {
        $DateTime = (Get-Date).ToString()
        $becauseText4 = 'There should be one incident created in Snow' + ' Checked at: ' + $($dateTime)
        $becauseText5 = 'The incident should be attached to the right CMDB CI' + ' Checked at: ' + $($dateTime)

        # Get resource data
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $azResource = wait-untilTestingResourceIsReady -identifier "winvm01" -resourceType "Microsoft.Compute/virtualMachines" -tagPrefix $tagPrefix
        $vmWindows = Get-AzVM -Name $azResource.Name -ResourceGroupName $azResource.ResourceGroupName
        $vmWindows_monitoringID = "azure://VM-" + $vmWindows.VmId + "/" + $vmWindows.Name
        $azResource = wait-untilTestingResourceIsReady -identifier "linvm01" -resourceType "Microsoft.Compute/virtualMachines" -tagPrefix $tagPrefix
        $vmLinux = Get-AzVM -Name $azResource.Name -ResourceGroupName $azResource.ResourceGroupName
        $vmLinux_monitoringID = "azure://VM-" + $vmLinux.VmId + "/" + $vmLinux.Name
        $storageAccount = wait-untilTestingResourceIsReady -identifier "storageacc01" -resourceType "Microsoft.Storage/storageAccounts" -tagPrefix $tagPrefix
        
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $laWorkspace = Get-LogAnalyticsWorkspace -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        $alert_logicapp = search-azureResourceByTag -resourceType "Microsoft.Logic/workflows" -Tags @{"${tagPrefix}Purpose" = "${tagValuePrefix}ItsmAlerts"}
        $logicapp_timewindow = 240

        # Create test alerts
        write-host "Creating test alerts for OS-Mgmt resources ..."
        $testAlert_VMWin_alertName = "Example test alert - VMWindows - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_VMWin = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "VMWindows" -resourceID $vmWindows.Id -alertName $testAlert_VMWin_alertName
        $testAlert_VMLin_alertName = "Example test alert - VMLinux - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_VMLin = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "VMLinux" -resourceID $vmLinux.Id -alertName $testAlert_VMLin_alertName
        $testAlert_StorageAcc_alertName = "Example test alert - StorageAcc - " + (Get-Date $Datetime -Format "HHmmMMddyyyy")
        $testAlert_StorageAcc = add-monitoringTestAlertRule -laWorkspace $laWorkspace -resourceTypeName "StorageAcc" -resourceID $storageAccount.ResourceId -alertName $testAlert_StorageAcc_alertName
    }

    Context 'Verify MGMT ITSM OS-MGMT alert flow' {
        It 'Check if Alert logic-app is trigerred for Windows VM' -Tag "itsm-flow-logic-app" {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_VMWin_alertName
            }
            $becauseText1 = 'the Alert Logic-app should be triggered in the last' + $($logicapp_timewindow) + 'minutes' + ' Checked at: ' + $($DateTime)
            $becauseText2 = 'the Alert Logic-app status should success' + ' Checked at: ' + $($DateTime)
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $Params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred for Linux VM' -Tag "itsm-flow-logic-app" {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_VMLin_alertName
            }
            $becauseText1 = 'the Alert Logic-app should be triggered in the last' + $($logicapp_timewindow) + 'minutes' + ' Checked at: ' + $($DateTime)
            $becauseText2 = 'the Alert Logic-app status should success' + ' Checked at: ' + $($DateTime)
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $Params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
        It 'Check if Alert logic-app is trigerred for Storage Account' -Tag "itsm-flow-logic-app" {
            $params = @{
                logicApp = $alert_logicapp
                historyInMinutes = $logicapp_timewindow
                outputVariable = "OUTPUT_SENTALERT"
                outputValue = $testAlert_StorageAcc_alertName
            }
            $becauseText1 = 'the Alert Logic-app should be triggered in the last' + $($logicapp_timewindow) + 'minutes' + ' Checked at: ' + $($DateTime)
            $becauseText2 = 'the Alert Logic-app status should success' + ' Checked at: ' + $($DateTime)
            $logicAppRunHistory = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-logicAppHistoryInTimeRange" -params $Params
            $logicAppRunHistory | Should -Not -BeNullOrEmpty -Because $becauseText1
            $logicAppRunHistory[0].Status | Should -Be "Succeeded" -Because $becauseText2
        }
    }

    Context 'Verify SNOW ITSM OS-MGMT CMDB flow' {
        It 'Check if Windows VM CI is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                monitoringId    = $vmWindows_monitoringID
            }
            $becauseText1 = 'There should be one CI for the windows VM in Snow' + ' Checked at: ' + $($DateTime)
            $becauseText2 = 'The CI properties should be valid'  + ' Checked at: ' + $($DateTime)
            $vmWindowsCI = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $vmWindowsCI.count | Should -Be 1 -Because $becauseText1
            $vmWindowsCI.sys_class_name | Should -Be "cmdb_ci_vm_instance" -Because $becauseText2
        }
        It 'Check if Linux VM CI is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                monitoringId    = $vmLinux_monitoringID
            }
            $becauseText1 = 'There should be one CI for the linux VM in Snow' + ' Checked at: ' + $($DateTime)
            $becauseText2 = 'The CI properties should be valid'  + ' Checked at: ' + $($DateTime)
            $vmWindowsCI = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $vmWindowsCI.count | Should -Be 1 -Because $becauseText1
            $vmWindowsCI.sys_class_name | Should -Be "cmdb_ci_vm_instance" -Because $becauseText2
        }
        It 'Check if Storage Account CI is created' {
           $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                monitoringId    = Get-MonitoringIdFromResourceId -resourceId $storageAccount.ResourceId -ResourceName $storageAccount.Name
            }
            $becauseText1 = 'There should be one CI for the Storage Account CI in Snow' + ' Checked at: ' + $($DateTime)
            $becauseText2 = 'The CI properties should be valid'  + ' Checked at: ' + $($DateTime)
            $storageAccCI = wait-loop -numberofRetries 15 -sleepTime 30 -command get-serviceNowCiByMonitoringId -params $params
            $storageAccCI.count | Should -Be 1 -Because $becauseText1
            $storageAccCI.sys_class_name | Should -Be "cmdb_ci_container_object" -Because $becauseText2
        }
    }

    Context 'Verify SNOW ITSM OS-MGMT CMDB Alert flow' {
        It 'Check if Windows VM Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_VMWin_alertName
                descriptionTag  = $testAlert_VMWin.descriptionTag
            }
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText4
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $vmWindows_monitoringID -Because $becauseText5
        }
        It 'Check if Linux VM Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_VMLin_alertName
                descriptionTag  = $testAlert_VMLin.descriptionTag
            }
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText4
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $vmLinux_monitoringID -Because $becauseText5
        }
        It 'Check if StorageAcc Test incident is created' {
            $params = @{
                snowEnv         = $snowEnv
                functionalOrg   = $snowFo
                basicUsername   = $snowUsername
                basicPassw      = $snowPassword
                alertName       = $testAlert_StorageAcc_alertName
                descriptionTag  = $testAlert_StorageAcc.descriptionTag
            }
            $MonId = Get-MonitoringIdFromResourceId -resourceId $storageAccount.ResourceId -ResourceName $storageAccount.Name
            $snowIncident = wait-loop -numberofRetries 25 -sleepTime 30 -command get-serviceNowIncidentForSpecificAlert -params $params
            $snowIncident.count | Should -Be 1 -Because $becauseText4
            $snowIncident.cmdb_ci.monitoring_object_id | Should -Be $monId -Because $becauseText5
        }
    }

    AfterAll {
        write-host "Delete test alerts for OS-Mgmt resources ..."
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        remove-monitoringAlertRule -laWorkspace $laWorkspace -AlertRuleName $testAlert_VMWin_alertName
        remove-monitoringAlertRule -laWorkspace $laWorkspace -AlertRuleName $testAlert_VMLin_alertName
        remove-monitoringAlertRule -laWorkspace $laWorkspace -AlertRuleName $testAlert_StorageAcc_alertName
    }
}