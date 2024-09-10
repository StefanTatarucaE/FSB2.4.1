##
## Eviden Landing Zones for Azure - Feature test
##
 
Describe 'OS-MGMT - Validate OsVersion tag' {

    BeforeAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        # Get deployed functions for OS-tagging Function App
        $functionApp = search-azureResourceByTag -resourceType 'Microsoft.Web/sites' -tags @{"${tagPrefix}Purpose" = "FuncOsTagging"}
        $functions = get-functionAppFunctions -resourceId $functionApp.ResourceId
        $laWorkspace = get-logAnalyticsWorkspace -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        $osTaggingFunction = "checkForSupportingOsVm"

        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        # Get Event Grid Subscription for OS-tagging
        $eventGridSubscription = search-eventGridSub -keyword "evgs-func-ostagging"

        # Get VM info
        $vmObject = wait-untilTestingResourceIsReady -identifier "winvm01" -resourceType "Microsoft.Compute/virtualMachines" -tagPrefix $tagPrefix
        $vmName = $vmObject.Name
        $vmResourceGroup = $vmObject.ResourceGroupName

        ##Get the current date/time
        $dateTime = (Get-Date).ToString()
    }

    Context 'check required components for OS-Tagging' {

        It 'is OS-Tagging function deployed' {
            $becauseText = 'function checkForSupportingOsVm performs actual update of ' + $($tagPrefix) + 'OsVersion Tag to VM' + ' Checked at: ' + $($dateTime)
            $osTaggingFunction | Should -BeIn $functions.properties.name `
                -Because $becauseText
        }

        It 'is Event Grid Subscription endpoint linked to OS-Tagging function' {
            $becauseText1 = 'Event Grid Subscription is needed for triggering on VM event' + ' Checked at: ' + $($dateTime)
            $eventGridSubscription | Should -Not -BeNullOrEmpty `
                -Because $becauseText1
            
            $becauseText2 = 'Event Grid Subscription must trigger OS-Tagging function' + ' Checked at: ' + $($dateTime)
            $eventGridSubscription.Endpoint | Should -BeLike $functions.id `
                -Because $becauseText2
        }

        It 'Function App should forward FunctionAppLogs to Log Analytics workspace (MGMT subscription)' {

            $becauseText1 = 'Function App ostagging should have diagnostic settings' + ' Checked at: ' + $($dateTime)
            $functionAppDiagRules = get-diagRule -resourceId $functionApp.ResourceId
            $functionAppDiagRules | Should -Not -BeNullOrEmpty `
                -Because $becauseText1
            $becauseText2 = 'Function App Diagnostic settings should send to Log Analytics Workspace in MGMT subscription' + ' Checked at: ' + $($dateTime)
            $functionAppDiagRules.Name | Should -Contain "${tagPrefix}DiagnosticRule-SendToLogAnalytics" `

            foreach ($diagRule in $functionAppDiagRules) {
                
                if ($diagRule.Name -eq "${tagPrefix}DiagnosticRule-SendToLogAnalytics") {

                    # Are diagnostic settings linked to the right Log Analytics Workspace?
                    $diagRule.WorkspaceId | Should -Be $laWorkspace.ResourceId `
                        -Because $becauseText2
        
                    # Is logging of FunctionAppLogs enabled?
                    $becauseText = 'Function App Diagnostic settings should be enabled for FunctionAppLogs' + ' Checked at: ' + $($dateTime)
                    $diagRule.Log | Should -Not -BeNullOrEmpty -Because $becauseText
                    $diagRule.Log.Category | Should -Be "FunctionAppLogs" -Because $becauseText
                    $diagRule.Log.Enabled | Should -BeTrue -Because $becauseText
                }
            }
        }
    }

    Context 'check VM OsVersion tag' {
        
        It 'is VM running' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $becauseText = 'only for running VM the correct tag value can be retrieved' + ' Checked at: ' + $($dateTime)
            test-vmIsStarted -virtualMachine $vmName -resourceGroup $vmResourceGroup | Should -BeTrue `
                -Because $becauseText
        }
        
        It 'is execution of OS-Tagging function for VM successful' {
            $becauseText = 'OS-Tagging function for VM should report that execution succeeded in FunctionAppLogs' + ' Checked at: ' + $($dateTime)
            $params = @{
                resourceId = $functionApp.ResourceId
                functionname = $osTaggingFunction
                logAnalyticsWorkspace = $laWorkspace
                searchText = $vmObject.Id
                tenantId = $tenantId
                # timeRange = '1h'
            }
            # wait some minutes, as it takes time for logging to appear in Log Analytics FunctionAppLogs
            $qOut = wait-loop -numberOfRetries 20 -sleepTime 60 -command get-functionAppLogsResult -params $params

            $qOut.Result | Should -Be 'Succeeded' `
                -Because $becauseText
        }
        
        It 'is OsVersion tag set with correct value' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $vmOsVersion = (get-vmOsVersion -virtualMachine $vmName -resourceGroup $vmResourceGroup)
            if ($null -eq $vmOsVersion) {
                $vmOsVersion = "unknown"
            }

            $params = @{
                virtualMachine = $vmName
                resourceGroup = $vmResourceGroup
                tagName = "${tagPrefix}OsVersion"
                tagValue = "$vmOsVersion"
            }
            # allow some minutes, as it can take time for tag to show up with correct value
            $becauseText = $($tagPrefix) + 'OsVersion Tag value should match actual OsName/OsVersion status properties for running VM' + ' Checked at: ' + $($dateTime)
            $vmOsVersionTagSet = wait-loop -numberOfRetries 20 -sleepTime 30 -command test-vmTags -params $params
            $vmOsVersionTagSet | Should -BeTrue `
                -Because $becauseText
        }        
    }
}