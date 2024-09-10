##
## Eviden Landing Zones for Azure - Check Tags for Automation Accounts in Azure MGMT Subscription
##
 
Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {

        $tagName1 = $tagPrefix + "Managed"
        $tagName2 = $tagPrefix + "Purpose"

        $tagValue1 = $tagValuePrefix + "RecoveryServicesVault"
        $tagValue2 = "True"

        $dateTime = (Get-Date).ToString()
    }

    Context 'Azure Recovery Service Vault Check' {

        It 'Step35-01. Check if the correct Tags/Values have been assigned to the Recovery Service Vault in LNDZ1' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Recovery Service Vault should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Recovery Service Vault should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'RecoveryServicesVault TAG assigned' + ' Checked at: ' + $($dateTime)

            $recoveryVaultTags = (Get-AzResource -ResourceType Microsoft.RecoveryServices/vaults -Name *recoveryvault).Tags

            $resourcetags = convert-hashToString($recoveryVaultTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue2`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step35-02. Check if the correct Tags/Values have been assigned to the Recovery Service Vault in LNDZ2' {
            Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Recovery Service Vault should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Recovery Service Vault should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'RecoveryServicesVault TAG assigned' + ' Checked at: ' + $($dateTime)

            $recoveryVaultTags = (Get-AzResource -ResourceType Microsoft.RecoveryServices/vaults -Name *recoveryvault).Tags

            $resourcetags = convert-hashToString($recoveryVaultTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue2`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step35-03. Check whether the Backup policies are present in the Recovery Service Vault for LNDZ1' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The required Backup policies should be pressent in the Recovery Service Vault' + ' Checked at: ' + $($dateTime)

            $getVault = Get-AzResource -ResourceType Microsoft.RecoveryServices/vaults -Name *recoveryvault

            $vault = Get-AzRecoveryServicesVault -ResourceGroupName $getVault.ResourceGroupName -Name $getVault.Name

            Set-AzRecoveryServicesVaultContext -Vault $vault

            $getPolicyList = (Get-AzRecoveryServicesBackupProtectionPolicy).Name
            
            $policyList = @(
                "HourlyLogBackup",
                "Gold-Enhanced",
                "Bronze-Enhanced",
                "DefaultPolicy",
                "Silver-Enhanced",
                "EnhancedPolicy"
            )
            foreach ($policy in $policyList) {
                $getPolicyList -contains $policy | Should -Be $true -Because $becauseText1
            }
        }

        It 'Step35-04. Check whether the Backup policies are present in the Recovery Service Vault for LNDZ2' {
            Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The required Backup policies should be pressent in the Recovery Service Vault' + ' Checked at: ' + $($dateTime)

            $getVault = Get-AzResource -ResourceType Microsoft.RecoveryServices/vaults -Name *recoveryvault

            $vault = Get-AzRecoveryServicesVault -ResourceGroupName $getVault.ResourceGroupName -Name $getVault.Name

            Set-AzRecoveryServicesVaultContext -Vault $vault

            $getPolicyList = (Get-AzRecoveryServicesBackupProtectionPolicy).Name
            
            $policyList = @(
                "HourlyLogBackup",
                "Gold-Enhanced",
                "Bronze-Enhanced",
                "DefaultPolicy",
                "Silver-Enhanced",
                "EnhancedPolicy"
            )
            foreach ($policy in $policyList) {
                $getPolicyList -contains $policy | Should -Be $true -Because $becauseText1
            }
        }
    }
}