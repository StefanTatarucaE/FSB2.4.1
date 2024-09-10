##
## Eviden Landing Zones for Azure - Feature test
##
 
Describe 'OS-MGMT - Validate VM Disk Encryption' {

    BeforeAll {
        $dateTime = (Get-Date).ToString()
        # Get VM info
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $vmObject = wait-untilTestingResourceIsReady -identifier "winvm01" -resourceType "Microsoft.Compute/virtualMachines" -tagPrefix $tagPrefix
        $vmName = $vmObject.Name
        $vmResourceGroup = $vmObject.ResourceGroupName
        
        # set the encryption tag on the VM
        $tags  = @{"${tagPrefix}Encryption" = "true"}
        Update-AzTag -ResourceId $vmObject.ResourceId -Tag $tags -Operation merge | Out-Null
    }

    Context 'check VM Disk Encryption requirements' {
        
        It 'has VM all tags set' {
            $becauseText = 'Disk Encryption happens only if VM has all required tags set correctly' + ' Checked at: ' + $($dateTime)
            ((test-vmTags -virtualMachine $vmName -resourceGroup $vmResourceGroup -tagName "${tagPrefix}Managed" -tagValue "true") `
             -And `
             (test-vmTags -virtualMachine $vmName -resourceGroup $vmResourceGroup -tagName "${tagPrefix}Encryption" -tagValue "true")) `
            | Should -BeTrue `
            -Because $becauseText
        }

        It 'is encryption runbook completed' {
            # Get MGMT automation account
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $params = @{
                ResourceType      = "Microsoft.Automation/automationAccounts"
                Tags              = @{"${tagPrefix}Purpose" = "${tagValuePrefix}Automation"}
                #ResourceGroupName = $env:MGMT_CUST_RESOURCE_GROUP
            }
            $mgmt_aa = search-azureResourceByTag @params

            # wait for the runbook to complete (event-grid triggered)
            $params = @{
                automationAccount = $mgmt_aa
                runbookName = "OSMGMT-Execute-VMEncryption"
                lastMinutes = 15
                vmName = $vmName
            }
            $becauseText = 'the VM encryption runbook should be completed in the last 15 minutes' + ' Checked at: ' + $($dateTime)
            $runbookJob = wait-loop -sleepTime 30 -numberOfRetries 30 -command "get-mgmtAutomationRunbookCompleted" -params $Params
            $runbookJob | Should -Not -BeNullOrEmpty -Because $becauseText
            write-host "Event-grid runbook is completed for the VM"

            # wait for the VM to be started completly (as the runbook restarts it)
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $params = @{
                virtualMachine = $vmName
                resourceGroup = $vmResourceGroup
            }
            $becauseText = 'the VM should be restarted by the encryption runbook' + ' Checked at: ' + $($dateTime)
            $vmStarted = wait-loop -sleepTime 15 -numberOfRetries 25 -command "test-vmIsStarted" -params $Params
            $vmStarted | Should -BeTrue -Because $becauseText
            write-host "VM is started successfully"
        }        
        
        It 'is encryption at host enabled for VM' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null            

            # wait for the VM to be encrypted (status can take a little before being updated)
            $params = @{
                virtualMachine = $vmName
                resourceGroup = $vmResourceGroup
            }
            $becauseText = 'encryption at host is required' + ' Checked at: ' + $($dateTime)
            $vmEncrypted = wait-loop -sleepTime 15 -numberOfRetries 25 -command "test-vmEncryption" -params $Params
            $vmEncrypted | Should -BeTrue -Because $becauseText
        }
        
        It 'is disk encryption set available at VM location' {
            $becauseText = 'Disk Encryption Set is needed for enabling SSE with CMK' + ' Checked at: ' + $($dateTime)
            get-diskEncryptionSet -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix -location $vmObject.Location | Should -Not -BeNullOrEmpty `
            -Because $becauseText
        }
    }
        
    Context 'check VM OsDisk Encryption state' {
        
        It 'is VM OsDisk correctly encrypted' {

            # wait for the VM disk to be encrypted (status can take a little before being updated)
            $params = @{
                virtualMachine = $vmName
                resourceGroup = $vmResourceGroup
                expectedEncryption = "SSE with CMK"
            }
            $becauseText = 'nothing less than SSE with CMK is acceptable for VM with ' + $($tagPrefix) + 'Encryption set' + ' Checked at: ' + $($dateTime)
            $vmDiskEncrypted = wait-loop -sleepTime 15 -numberOfRetries 25 -command "get-vmOsDiskEncryptionType" -params $Params
            $vmDiskEncrypted | Should -BeTrue -Because $becauseText
        }
    }
}