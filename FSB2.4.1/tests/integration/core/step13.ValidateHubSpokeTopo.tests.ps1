##
## Eviden Landing Zones for Azure - Validate Hub and Spoke Topology
##

Describe 'Core - Validate Hub and Spoke Topology' {

    BeforeAll {
        
        $DateTime = (Get-Date).ToString()
        $ProjectRoot = $buildRepositoryLocalPath
        $ScriptFolderPath = $ProjectRoot + '/tests/HelperScripts'
        $becauseText1 = 'The Allow ICMP rule has to be deployed' + ' Checked at: ' + $($DateTime)
        $becauseText2 = 'The VMs need to be reachable' + ' Checked at: ' + $($DateTime)
        $becauseText3 = 'The traffic should flow through the HUB Firewall' + ' Checked at: ' + $($DateTime)
        #$nextHop = "10.4.5.7" #value for testing meant to fail the test
        $nextHop = "10.4.3.4"

        
        #Search for the Win VMs that are created for the Test
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $vmquery1 = wait-untilTestingResourceIsReady -identifier "winvm01" -resourceType "Microsoft.Compute/virtualMachines" -tagPrefix $tagPrefix
        Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $vmquery2 = wait-untilTestingResourceIsReady -identifier "winvm02" -resourceType "Microsoft.Compute/virtualMachines" -tagPrefix $tagPrefix

        #Get the name of the Win VMs
        $vmWinName = $vmquery1.Name
        $vmWinName2 = $vmquery2.Name

        #Get the resource group of the Win VMs
        $vmWinResourceGroup = $vmquery1.ResourceGroupName
        $vmWin2ResourceGroup = $vmquery2.ResourceGroupName
        
        #Add firewall rule to WinVM in LNDZ1
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        Invoke-AzVMRunCommand -ResourceGroupName $vmWinResourceGroup -VMName  $vmWinName -CommandId 'RunPowerShellScript' -ScriptPath "$ScriptFolderPath/add-FW-rule.ps1"
        
        #Add firewall rule to WinVM in LNDZ2
        Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        Invoke-AzVMRunCommand -ResourceGroupName $vmWin2ResourceGroup -VMName $vmWinName2 -CommandId 'RunPowerShellScript' -ScriptPath "$ScriptFolderPath/add-FW-rule.ps1"

    }

    Context 'Validate Hub and Spoke Topology - Check if VMs from different landing zones can communicate with each other via the HUB Network  ' {

        It 'Test if the VM from LNDZ1 can "Ping" a VM from LNDZ2  '{
            Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $VM2 = Get-AzVM -ResourceGroupName $vmWin2ResourceGroup -Name $vmWinName2
            $Nics2 = Get-AzNetworkInterface | Where {$_.Id -eq $vm2.NetworkProfile.NetworkInterfaces.Id.ForEach({$_})}
            $PrivateIP2 = $Nics2[0].IpConfigurations[0].PrivateIpAddress
            #$PrivateIP2 = "192.168.1.1" #value for testing meant to fail the test

            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $output2 = Invoke-AzVMRunCommand -ResourceGroupName $vmWinResourceGroup -VMName $vmWinName -CommandId 'RunPowerShellScript' -ScriptPath "$ScriptFolderPath/test_conn_script1.ps1" -Parameter @{vm1_name = "$PrivateIP2"}

            $output2.Value[0].Message | Should -Be True -Because $becauseText2
        }

        It 'Check if traffic between landingzones in flowing via the HUB network(Check if next hop is 10.4.3.4) '{
            #Get Source VM Info
            Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $VM2 = Get-AzVM -ResourceGroupName $vmWin2ResourceGroup -Name $vmWinName2
            $Nics2 = Get-AzNetworkInterface | Where {$_.Id -eq $vm2.NetworkProfile.NetworkInterfaces.Id.ForEach({$_})}
            $PrivateIP2 = $Nics2[0].IpConfigurations[0].PrivateIpAddress

            #Get Destination VM Info
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $VM = Get-AzVM -ResourceGroupName $vmWinResourceGroup -Name $vmWinName
            $Nics = Get-AzNetworkInterface | Where {$_.Id -eq $vm.NetworkProfile.NetworkInterfaces.Id.ForEach({$_})}
            $PrivateIP1 = $Nics[0].IpConfigurations[0].PrivateIpAddress

            #Get Network Watcher Info
            Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $nw = Get-AzResource | Where {$_.ResourceType -eq "Microsoft.Network/networkWatchers" -and $_.Location -eq $VM.Location }
            $networkWatcher = Get-AzNetworkWatcher -Name $nw.Name -ResourceGroupName $nw.ResourceGroupName
            
            #Check Network Watcher Next Hop
            $output3 = Get-AzNetworkWatcherNextHop -NetworkWatcher $networkWatcher -TargetVirtualMachineId $VM2.Id -SourceIPAddress $PrivateIP2  -DestinationIPAddress $PrivateIP1
            $output3.NextHopIpAddress | Should -Be $nextHop -Because $becauseText3

        }
    }
}