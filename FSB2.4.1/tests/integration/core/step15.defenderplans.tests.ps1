##
## Eviden Landing Zones for Azure - Feature test
##
 
Describe 'Core -  Test Cloud Defender plans in the MSP & MGMT Sub' {

    BeforeAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
        $dateTime = (Get-Date).ToString()
        $mgmt_pricingplans = get-pricingPlans
        $vmTier = "Standard"
        $sqlTier = "Standard"
        $appServices = "Standard"
        $storageAccounts = "Standard"
        $sqlServerVirtualMachines = "Standard"
        $keyVaults = "Standard"
        $dns = "Standard"
        $arm = "Standard"
        $openSourceRelationalDatabases = "Standard"
        $cosmosDbs = "Standard"
        $containers = "Standard"
    }

    Context 'Test if Defender Plans are set correctly in the MGMT Subscription' {
        
        # Test if Defender Plans are set correctly in the MGMT Subscription
        
        It 'Test MGMT Subscription Vm Tier' {
            $mgmt_pricingplans.VirtualMachines.pricingtier | Should -Be $vmTier -Because $becauseText
            $becauseText = 'we expect the ' + $($vmTier) + ' pricing tier to be set.' + ' Checked at: ' + $($dateTime)
        }
            $pricingplans.VirtualMachines.pricingtier | Should -Be $vmTier -Because $becauseText
        It 'Test MGMT Subscription Sql Tier' {  
            $becauseText = 'we expect the ' + $($sqlTier) + ' pricing tier to be set.' + ' Checked at: ' + $($dateTime)
            $mgmt_pricingplans.SqlServers.pricingtier | Should -Be $sqlTier -Because $becauseText
        }
        It 'Test MGMT Subscription appServices Tier' { 
            $becauseText = 'we expect the ' + $($appServices) + ' pricing tier to be set.' + ' Checked at: ' + $($dateTime)
            $mgmt_pricingplans.appServices.pricingtier | Should -Be $appServices -Because $becauseText
        }
        It 'Test MGMT Subscription storageAccounts Tier' { 
            $becauseText = 'we expect the ' + $($storageAccounts) + ' pricing tier to be set.' + ' Checked at: ' + $($dateTime)
            $mgmt_pricingplans.storageaccounts.pricingtier | Should -Be $storageAccounts -Because $becauseText
        }
        It 'Test MGMT Subscription sqlServerVirtualMachines Tier' { 
            $becauseText = 'we expect the ' + $($sqlServerVirtualMachines) + ' pricing tier to be set.' + ' Checked at: ' + $($dateTime)
            $mgmt_pricingplans.sqlServerVirtualMachines.pricingtier | Should -Be $sqlServerVirtualMachines -Because $becauseText
            
        }
        It 'Test MGMT Subscription keyvaults Tier' { 
            $becauseText = 'we expect the ' + $($keyVaults) + ' pricing tier to be set.' + ' Checked at: ' + $($dateTime)
            $mgmt_pricingplans.keyVaults.pricingtier | Should -Be $keyVaults -Because $becauseText
        }
        It 'Test MGMT Subscription dns Tier' { 
            $becauseText = 'we expect the ' + $($dns) + ' pricing tier to be set.' + ' Checked at: ' + $($dateTime)
            $mgmt_pricingplans.dns.pricingtier | Should -Be $dns -Because $becauseText
        }
        It 'Test MGMT Subscription arm Tier' { 
            $becauseText = 'we expect the ' + $($arm) + ' pricing tier to be set.' + ' Checked at: ' + $($dateTime)
            $mgmt_pricingplans.arm.pricingtier | Should -Be $arm  -Because $becauseText
        }
        It 'Test MGMT Subscription openSourceRelationalDatabases Tier' { 
            $becauseText = 'we expect the ' + $($openSourceRelationalDatabases) + ' pricing tier to be set.' + ' Checked at: ' + $($dateTime)
            $mgmt_pricingplans.openSourceRelationalDatabases.pricingtier | Should -Be $openSourceRelationalDatabases  -Because $becauseText
        }
        It 'Test MGMT Subscription cosmosDbs Tier' { 
            $becauseText = 'we expect the ' + $($cosmosDbs) + ' pricing tier to be set.' + ' Checked at: ' + $($dateTime)
            $mgmt_pricingplans.cosmosDbs.pricingtier | Should -Be $cosmosDbs  -Because $becauseText
        }
        It 'Test MGMT Subscription containers Tier' { 
            $becauseText = 'we expect the ' + $($containers) + ' pricing tier to be set.' + ' Checked at: ' + $($dateTime)
            $mgmt_pricingplans.containers.pricingtier | Should -Be $containers  -Because $becauseText
        }
    }
} 
