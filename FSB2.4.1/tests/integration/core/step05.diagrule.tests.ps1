##
## Eviden Landing Zones for Azure - Feature test
##
 
Describe 'Core -  DiagnosticRule Set & Check' {

    BeforeAll {
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        $resource = wait-untilTestingResourceIsReady -identifier "storageacc01" -resourceType "Microsoft.Storage/storageAccounts" -tagPrefix $tagPrefix
        $laWorkspace = get-logAnalyticsWorkspace -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
    }

    Context 'Set Managed tag to true to receive diagule on resource' {

        It 'Write Tag to resource & Start Policy Scan' {

            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            # Write tag to an existing resource
            $tags = @{"${tagPrefix}Managed" = "true"}
            Update-AzTag -ResourceId $resource.ResourceId -Tag $tags -Operation Merge

            #Trigger policy compliance scan for the diagnosticpolicy to turn incompliant
            $becauseText = 'The policscan should have the status completed' + 'Checked at:' + $($dateTime)
            $policyScan = start-policyScan -resourceGroupName $resource.ResourceGroupName
            $policyScan.state | Should -Be "Completed" -Because $becauseText
        }
    }

    Context 'Trigger Diagnosticsettings remediation runbook (Create-RemediationTaskDiagnosticSettings) in the MGMT' {

        It 'Trigger remediation runbook in the MGMT' {
            # Trigger remediation runbook
            $becauseText = 'The Runbook should have the status completed' + 'Checked at:' + $($dateTime)
            $runbookCompletedInCore = start-mgmtAutomationRunbook -runbookName "MONITORING-Create-RemediationTaskDiagnosticSettings" -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $runbookCompletedInCore | Should -Be $true -Because $becauseText
        }
    }

    Context 'Check if the diagnosticrule was set by the remediation runbook' {
        
        It 'Test if diagnosticrule equals EvidenDiagnosticRule-SendToLogAnalytics' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null           
            # Enter wait/retry loop to let remediation task do it's task. 
            $params = @{
                resourceid = $Resource.resourceid
                WarningAction = "SilentlyContinue"
            }            
            $diagSettings = wait-loop -sleepTime 30 -numberOfRetries 120 -command "Get-AzDiagnosticSetting" -params $Params
            
            # Empty object will come back in case no diagnosticrule exist for the resource
            $becauseText = 'there should be an diagnosticrule by now' + 'Checked at:' + $($dateTime)
            $becauseText2 = 'Checked at:' + $($dateTime)
            $diagrule = get-diagRule -resourceId $resource.resourceid
            $diagrule.StorageAccountdiagrule.Name | Should -Not -BeNullOrEmpty `
                -Because $becauseText
            
            $diagrule.StorageAccountdiagrule.Name | Should -BeLikeExactly "${tagPrefix}DiagnosticRule-SendToLogAnalytics" -Because $becauseText2
                      
        } 
    }
        
    Context 'Check if the diagnosticrule send information to the correct LA Workspace' {
        
        It 'Check if the diagnosticrule send information to the correct LA Workspace' {

            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            # Empty object will come back in case no diagnosticrule exist for the resource
            $diagrule = get-diagRule -resourceId $Resource.resourceid         
            $becauseText = 'there should be an diagnosticrule by now which is connected to the MGMT LA Workspace' + 'Checked at:' + $($dateTime)
            $becauseText2 = 'Checked at:' + $($dateTime)
            $diagrule.StorageAccountdiagrule | Should -Not -BeNullOrEmpty `
                -Because $becauseText

            $diagrule.StorageAccountdiagrule.WorkspaceId | Should -BeLike $laWorkspace.id -Because $becauseText2
                    
        } 
    }
} 




