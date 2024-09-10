##
## Eviden Landing Zones for Azure - Test if the required policies have EnableAutomaticUpgrade set to true(available in DCS 2.1)
##
 
Describe 'Core -  Check if Automatic Upgrade of Azure extensions is enabled' {

    BeforeAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
    }

    Context 'Check if Automatic Upgrade of Azure extensions is enabled' {
                                 
        It 'Check Guest Config Change Windows Policy' {
            
            $policy = Get-AzPolicyDefinition | Where-Object { ($_.Properties.policyType -eq 'Custom') -and ($_.Name -eq 'guestconfig-win-change-policy-def')}
            $checkExtension = $policy.properties.Policyrule.then.details.existenceCondition.allof.field.Contains('Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade')

            $becauseText = 'The field "Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade" must be set to "true" in the policy definition' + 'Checked at:' + $($dateTime)
            $checkExtension | Should -BeTrue -Because $becauseText
        }

        It 'Check Guest Config Change Linux Policy' {
            
            $policy = Get-AzPolicyDefinition | Where-Object { ($_.Properties.policyType -eq 'Custom') -and ($_.Name -eq 'guestconfig-linux-change-policy-def')}
            $checkExtension = $policy.properties.Policyrule.then.details.existenceCondition.allof.field.Contains('Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade')

            $becauseText = 'The field "Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade" must be set to "true" in the policy definition' + 'Checked at:' + $($dateTime)
            $checkExtension | Should -BeTrue -Because $becauseText
        }

        It 'Check Enable Dependency Agent Change Windows Policy' {
            
            $policy = Get-AzPolicyDefinition | Where-Object { ($_.Properties.policyType -eq 'Custom') -and ($_.Name -eq 'vm-enabledependencyagentwin-change-policy-def')}
            $checkExtension = $policy.properties.Policyrule.then.details.existenceCondition.allof.field.Contains('Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade')

            $becauseText = 'The field "Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade" must be set to "true" in the policy definition' + 'Checked at:' + $($dateTime)
            $checkExtension | Should -BeTrue -Because $becauseText
        }

        It 'Check Enable Dependency Agent Change Linux Policy' {
            
            $policy = Get-AzPolicyDefinition | Where-Object { ($_.Properties.policyType -eq 'Custom') -and ($_.Name -eq 'vm-enabledependencyagentlinux-change-policy-def')}
            $checkExtension = $policy.properties.Policyrule.then.details.existenceCondition.allof.field.Contains('Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade')

            $becauseText = 'The field "Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade" must be set to "true" in the policy definition' + 'Checked at:' + $($dateTime)
            $checkExtension | Should -BeTrue -Because $becauseText
        }

        It 'Check Enable LogAnalytics Agent Change Linux Policy' {
            
            $policy = Get-AzPolicyDefinition | Where-Object { ($_.Properties.policyType -eq 'Custom') -and ($_.Name -eq 'vm-enableloganalyticsagentlinux-change-policy-def')}
            $checkExtension = $policy.properties.Policyrule.then.details.existenceCondition.allof.field.Contains('Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade')

            $becauseText = 'The field "Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade" must be set to "true" in the policy definition' + 'Checked at:' + $($dateTime)
            $checkExtension | Should -BeTrue -Because $becauseText
        }

        It 'Check Enable Dependency Agent Change Windows Virtual Machine Scale Set Policy' {
            
            $policy = Get-AzPolicyDefinition | Where-Object { ($_.Properties.policyType -eq 'Custom') -and ($_.Name -eq 'vmss-enabledependencyagentwin-change-policy-def')}
            $checkExtension = $policy.properties.Policyrule.then.details.existenceCondition.allof.field.Contains('Microsoft.Compute/virtualMachineScaleSets/extensions/EnableAutomaticUpgrade')

            $becauseText = 'The field "Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade" must be set to "true" in the policy definition' + 'Checked at:' + $($dateTime)
            $checkExtension | Should -BeTrue -Because $becauseText
        }

        It 'Check Enable Dependency Agent Change Linux Virtual Machine Scale Set Policy' {
            
            $policy = Get-AzPolicyDefinition | Where-Object { ($_.Properties.policyType -eq 'Custom') -and ($_.Name -eq 'vmss-enabledependencyagentlinux-change-policy-def')}
            $checkExtension = $policy.properties.Policyrule.then.details.existenceCondition.allof.field.Contains('Microsoft.Compute/virtualMachineScaleSets/extensions/EnableAutomaticUpgrade')

            $becauseText = 'The field "Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade" must be set to "true" in the policy definition' + 'Checked at:' + $($dateTime)
            $checkExtension | Should -BeTrue -Because $becauseText
        }

        It 'Check Enable LogAnalytics Agent Change Linux Virtual Machine Scale Set Policy' {
            
            $policy = Get-AzPolicyDefinition | Where-Object { ($_.Properties.policyType -eq 'Custom') -and ($_.Name -eq 'vmss-enableloganalyticsagentlinux-change-policy-def')}
            $checkExtension = $policy.properties.Policyrule.then.details.existenceCondition.allof.field.Contains('Microsoft.Compute/virtualMachineScaleSets/extensions/EnableAutomaticUpgrade')

            $becauseText = 'The field "Microsoft.Compute/virtualMachines/extensions/EnableAutomaticUpgrade" must be set to "true" in the policy definition' + 'Checked at:' + $($dateTime)
            $checkExtension | Should -BeTrue -Because $becauseText
        }
    }
}
