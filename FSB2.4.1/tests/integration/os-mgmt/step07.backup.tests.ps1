##
## Eviden Landing Zones for Azure - Feature test Recovery service vault policy status on VM's and Trigger a Backup.
##
 
Describe 'OS-MGMT - Validate VM Backup ' {

    BeforeAll {
        $policyName = "Bronze-Enhanced"

        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        $vmObject = wait-untilTestingResourceIsReady -identifier "winvm01" -resourceType "Microsoft.Compute/virtualMachines" -tagPrefix $tagPrefix
        $vmName = $vmObject.Name
        $vmResourceGroup = $vmObject.ResourceGroupName
    }

    Context 'Check the policy status if it is enabled or not and trigger a backup if policy is enabled' {

        It 'Check the VM if it is assigned to any backup policy' {
            $becauseText = 'The Vm has to have a Backup Policy assigned' + ' Checked at: ' + $($dateTime)
            $checkstatus = get-backupPolicyStatus -vmName $vmName -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $checkstatus | Should -Be $true -Because $becauseText
        }

        It 'Start a backup on specified VM'{
            $becauseText = 'The backup trigger was triggered once the function Get-BackupPolicyTrigger was called.' + ' Checked at: ' + $($dateTime)
            $params = @{
                vmName = $vmName
                resourceGroup = $vmResourceGroup
                policyName = $policyName
                tagPrefix = $tagPrefix
                tagValuePrefix = $tagValuePrefix
            }
            start-vmBackup @params
            $vaultProperties = search-azureResourceByTag -resourceType "Microsoft.RecoveryServices/vaults" -Tags @{"${tagPrefix}Purpose" = "${tagValuePrefix}RecoveryServicesVault"}
            $targetVault = get-AzRecoveryServicesVault -ResourceGroupName $VaultProperties.ResourceGroupName -Name $VaultProperties.Name
            $joblist = Get-AzRecoveryservicesBackupJob -Status "InProgress" -VaultId $targetVault.ID -WarningAction SilentlyContinue
            $joblist | Should -Not -BeNullOrEmpty -Because $becauseText
        }

    }
}
