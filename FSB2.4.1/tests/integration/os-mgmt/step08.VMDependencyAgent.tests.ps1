##
## Eviden Landing Zones for Azure - Dependency Agent test
##
 
Describe 'OS-MGMT - Dependency Agent Check' {

    BeforeAll {
        
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        #Search for the Win/Linux VMs that are created for the Test
        $vmquery1 = Wait-UntilTestingResourceIsReady -Identifier "winvm01" -ResourceType "Microsoft.Compute/virtualMachines" -tagPrefix $tagPrefix
        $vmquery2 = Wait-UntilTestingResourceIsReady -Identifier "linvm01" -ResourceType "Microsoft.Compute/virtualMachines" -tagPrefix $tagPrefix

        #Get the name of the Win/Linux VMs
        $vmWinName = $vmquery1.Name
        $vmLinName = $vmquery2.Name

        #Get the resource group of the Win/Linux VMs
        $vmWinResourceGroup = $vmquery1.ResourceGroupName
        $vmLinResourceGroup = $vmquery2.ResourceGroupName

    }

    Context 'Check extension status' {

        It 'Check if Managed tag is set for Windows VM' {
            
            Write-Host "1. Checked if the " + $($tagPrefix) + " Managed tag is set to true for Windows VMs."
            $becauseText = 'provisioning of the Dependency Agent is triggered by setting tag  ' + $($tagPrefix) + 'Managed=true' + ' Checked at: ' + $($dateTime)
            (test-vmTags -virtualMachine $vmWinName -resourceGroup $vmWinResourceGroup -tagName "${tagPrefix}Managed" -tagValue "true") `
            | Should -BeTrue `
            -Because $becauseText
        }

        It 'Check if Managed tag is set for Linux VM' {

            Write-Host "2. Checked if the " + $($tagPrefix) + " Managed tag is set to true for Linux VMs."
            $becauseText = 'provisioning of the Dependency Agent is triggered by setting tag  ' + $($tagPrefix) + 'Managed=true' + ' Checked at: ' + $($dateTime)
            (test-vmTags -virtualMachine $vmLinName -resourceGroup $vmLinResourceGroup -tagName "${tagPrefix}Managed" -tagValue "true") `
            | Should -BeTrue `
            -Because $becauseText
        }

        It 'Check if AntiMalware extension is successfully provisioned on the Windows VMs' {

            Write-Host "3. Checked if the Dependency Agent is successfully provisioned on the Windows VMs."
            $becauseText = 'extension' + $($vmExtensionWin) + 'must be provisioned for the Dependency Agent' + ' Checked at: ' + $($dateTime)
            $vmExtensionWin = "DependencyAgentWindows"
            
            $params = @{
                virtualMachine = $vmWinName
                resourceGroup = $vmWinResourceGroup
                extension = $vmExtensionWin
            }

            #Wait until the extension is available
            $vmDepAgentWin= wait-loop -sleepTime 30 -numberOfRetries 25 -command "test-vmExtension" -params $Params
            $vmDepAgentWin | Should -BeTrue -Because $becauseText
        }

        It 'Check if AntiMalware extension is successfully provisioned on the Linux VMs' {

            Write-Host "4. Checked if the Dependency Agent is successfully provisioned on the Linux VMs."
            $becauseText = 'extension' + $($vmExtensionLin) + 'must be provisioned for the Dependency Agent' + ' Checked at: ' + $($dateTime)
            $vmExtensionLin = "DependencyAgentLinux"
            
            $params = @{
                virtualMachine = $vmLinName
                resourceGroup = $vmLinResourceGroup
                extension = $vmExtensionLin
            }

            #Wait until the extension is available
            $vmDepAgentLin= wait-loop -sleepTime 30 -numberOfRetries 25 -command "test-vmExtension" -params $Params
            $vmDepAgentLin | Should -BeTrue -Because $becauseText
        }
    }


}