##
## Eviden Landing Zones for Azure - Feature test Validate if VM deployment in Management and Connectivity subscriptions is restricted (VM OS - Policy preventing this).
##

Describe 'Core - Validate VMs deployments in MGMT, CNTY and LNDZ' {

    BeforeAll {
        $dateTime = (Get-Date).ToString()
        $becauseText = ' Checked at: ' + $($dateTime)
        $resourceGroupName = 'test-VMOsPolicy-testing'
        $resourceGroupTag =    
        @{ 
            "${tagPrefix}Testing" = 'test-VMOsPolicy-testing'
         }
         $vmMgmtSize = 'Standard_DS1_v2' #SKU not allowed in MGMT policy
         $vmCntySize = 'Standard_DS1_v2' #SKU not allowed in CNTY policy
         $vmLndzSize = 'Standard_D2s_v3' #SKU not allowed in LNDZ policy  
         
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
        New-AzResourceGroup -ResourceGroupName $resourceGroupName -Location "West Europe" -Tag $resourceGroupTag
        Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        New-AzResourceGroup -ResourceGroupName $resourceGroupName -Location "West Europe" -Tag $resourceGroupTag
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
        New-AzResourceGroup -ResourceGroupName $resourceGroupName -Location "West Europe" -Tag $resourceGroupTag
    }

    Context 'Check VMs deployments in MGMT, CNTY and LNDZ according to policies assigned on them' {
            
        It 'Check if VMs can be deployed in MGMT subscription' {
            #Used an SKU that is not included in the policy. The test should fail if the creation of the VM succeed.

            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
            try{  

                $user = "admintest1"
                $password = ConvertTo-SecureString -String "AdminTest!555@!" -AsPlainText -Force
                $credential = New-Object -TypeName System.Management.Automation.PScredential -ArgumentList $user, $password
                
                $params = @{
                    ResourceGroupName = $resourceGroupName 
                    Name = 'testVM-MGMT' 
                    Location = 'West Europe' 
                    VirtualNetworkName = 'testVM-MGMT-vnet' 
                    SubnetName = 'testVM-MGMT-subnet' 
                    SecurityGroupName = 'testVM-MGMT-nsg' 
                    PublicIpAddressName ='testVM-MGMT-publicIP' 
                    OpenPorts = 3389 
                    Size = $vmMgmtSize 
                    Credential = $credential 
                }
                $vmCreateInMgmt = New-AzVm @params -ErrorAction Stop 
                if($vmCreateInMgmt.Name -ne $null) {
                    Throw ("The VM has been created but this type of SKU should not be allowed by SKU MGMT policy.") 
                }
            }
            catch{ 
                $_.Exception.Message | Should -Match -RegularExpression 'was disallowed by policy. Policy identifiers:' -Because $becauseText
            }

            
        }
        
        It 'Check if VMs can be deployed in CNTY subscription' {
            #Used an SKU that is not included in the policy. The test should fail if the creation of the VM succeed.

            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            try{  
                $user = "admintest1"
                $password = ConvertTo-SecureString -String "AdminTest!555@!" -AsPlainText -Force
                $credential = New-Object -TypeName System.Management.Automation.PScredential -ArgumentList $user, $password

                $params = @{
                    ResourceGroupName = $resourceGroupName 
                    Name = 'testVM-CNTY' 
                    Location = 'West Europe' 
                    VirtualNetworkName = 'testVM-CNTY-vnet' 
                    SubnetName = 'testVM-CNTY-subnet' 
                    SecurityGroupName = 'testVM-CNTY-nsg' 
                    PublicIpAddressName = 'testVM-CNTY-publicIP' 
                    OpenPorts = 3389 
                    Size = $vmCntySize 
                    Credential = $credential 
                }
                $vmCreateInCnty = New-AzVm @params -ErrorAction Stop                
                if($vmCreateInCnty.Name -ne $null) {
                    Throw ("The VM has been created but this type of SKU should not be allowed by SKU CNTY policy.") 
                }
            }
            catch{
                 $_.Exception.Message | Should -Match -RegularExpression 'was disallowed by policy. Policy identifiers:' -Because $becauseText
            }
            
            
        }

        It 'Check if VMs can be deployed in LNDZ subscription' {
             #Used an SKU that is not included in the policy. The test should fail if the creation of the VM succeed.

            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
            try{  
                $user = "admintest1"
                $password = ConvertTo-SecureString -String "AdminTest!555@!" -AsPlainText -Force
                $credential = New-Object -TypeName System.Management.Automation.PScredential -ArgumentList $user, $password
                
                $params = @{
                    ResourceGroupName = $resourceGroupName
                    Name = 'testVM-LNDZ'
                    Location = 'West Europe'
                    VirtualNetworkName = 'testVM-LNDZ-vnet' 
                    SubnetName = 'testVM-LNDZ-subnet' 
                    SecurityGroupName = 'testVM-LNDZ-nsg' 
                    PublicIpAddressName ='testVM-LNDZ-publicIP' 
                    OpenPorts = 3389 
                    Size = $vmLndzSize 
                    Credential = $credential 
                }
                $vmCreateInLndz =  New-AzVm @params -ErrorAction Stop         
                if($vmCreateInLndz.Name -ne $null) {
                    Throw ("The VM has been created but this type of SKU should not be allowed by SKU LNDZ policy.") 
                }
            }
            catch{ 
                $_.Exception.Message | Should -Match -RegularExpression 'was disallowed by policy. Policy identifiers:' -Because $becauseText
            } 
        }            
    }
    
    AfterAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
        Remove-AzResourceGroup -Name $resourceGroupName -Force
        Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        Remove-AzResourceGroup -Name $resourceGroupName -Force 
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
        Remove-AzResourceGroup -Name $resourceGroupName -Force
    }
   
}


