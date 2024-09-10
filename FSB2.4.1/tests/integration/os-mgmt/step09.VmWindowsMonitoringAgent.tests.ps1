##
## Eviden Landing Zones for Azure - Feature test
##
 
Describe 'OS-MGMT - Validate VM Monitoring Agent' {

    BeforeAll {
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        $vmObject = Wait-UntilTestingResourceIsReady -Identifier "winvm01" -ResourceType "Microsoft.Compute/virtualMachines" -tagPrefix $tagPrefix
        $vmName = $vmObject.Name
        $vmResourceGroup = $vmObject.ResourceGroupName

        $LAWorkspace = Get-LogAnalyticsWorkspace -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
    }

    Context 'Check extension status' {
        
        It 'check if Managed tag is set' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $becauseText = 'provisioning of Monitoring Agent is triggered by setting tag ' + $($tagPrefix) + 'Managed=true' + ' Checked at: ' + $($dateTime)
            (Test-VmTags -virtualMachine $vmName -resourceGroup $vmResourceGroup -tagName "${tagPrefix}Managed" -tagValue "true") `
            | Should -BeTrue `
            -Because $becauseText
        }

        It 'check if the new Azure monitoring agent extension is successfully provisioned' {
          Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
          $vmOsType = (Get-AzVM -Name $vmName -ResourceGroupName $vmResourceGroup).StorageProfile.OsDisk.OsType
          $vmExtension = switch ($vmOsType) {
              { ($_ -eq "Windows") } { "AzureMonitorWindowsAgent" }
              { ($_ -eq "Linux") } { "AzureMonitorLinuxAgent" }
              Default { "UnknownExtension" }
          }

          # wait for VM extension provisioning (as it can take some minutes to complete)
          $params = @{
              virtualMachine = $vmName
              resourceGroup = $vmResourceGroup
              extension = $vmExtension
          }
          $becauseText = 'extension' + $($vmExtension) + 'must be provisioned for logging of VM metrics' + ' Checked at: ' + $($dateTime)
          $vmHasExtension = wait-loop -sleepTime 15 -numberOfRetries 100 -command "test-vmExtension" -params $params
          $vmHasExtension | Should -BeTrue `
          -Because $becauseText
          Write-Host "VM has extension $vmExtension provisioned"
      }

    }

    Context 'Look for heartbeat' {

        It 'check if VM is powered on' {
            $becauseText = 'heartbeat is generated only for VM that is powered on' + ' Checked at: ' + $($dateTime)
            Get-VmPowerState -virtualMachine $vmName -resourceGroup $vmResourceGroup | Should -Be 'running' `
            -Because $becauseText
        }

        It 'check LogAnalytics Heartbeat table' {
            $becauseText = 'heartbeat is logged when VM is running and Monitoring Agent extension is installed' + ' Checked at: ' + $($dateTime)
            # wait for heartbeat row to appear (It may take some minutes, to have the logs available)
            $params = @{
                virtualMachine = $vmName
                resourceGroup = $vmResourceGroup
                custMgmtSubscriptionId = $custMgmtSubscriptionId
                tenantId = $tenantId
                tagPrefix = $tagPrefix
                tagValuePrefix = $tagValuePrefix
            }
            $vmHeartbeat = wait-loop -sleepTime 30 -numberOfRetries 15 -command "test-vmHeartbeat" -params $params
            $vmHeartbeat | Should -BeTrue `
            -Because $becauseText
        }
    }
}