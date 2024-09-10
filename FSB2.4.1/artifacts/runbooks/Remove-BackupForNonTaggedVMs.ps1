<#
    .SYNOPSIS
        Create Remediation task for removing the VMs that are not EvidenBackup tagged from Backup Vault.

    .DESCRIPTION
        This runbook loops through all subscriptions in the Customer tenant and on each subscription, 
        and it will check for the EvidenManaged Recovery Services Vault. For the VMs within the Vault, it will search for the VMs that are backed up but don't have the EvidenBackup tag and it will remove them from the vault.

    .OUTPUTS
        N/A

    .NOTES
        Author:     Dan Popescu
        Company:    Eviden
        Email:      bart.decker@eviden.com
        Created:    2021-05-11
        Updated:    2023-08-07
        Version:    0.1
#>

# Get connected
try {

    #Disable the Context inheritance from a previous session
    Disable-AzContextAutosave -Scope Process

    Write-Output "Logging into Azure with System-assigned Identity"
    $azConnect = Connect-AzAccount -Identity    

    if (-not $azConnect) {
        Write-Error "Login error: Logging into azure Failed..." -ErrorAction 'Stop' 
    }
    else {
        Write-Output "Successfully logged into the Azure Platform."
    }
}
catch {
    throw $_.Exception
}

# Define branding variables needed for the Remove-BackupForNonTaggedVMs runbook from the automation account variables

$tagPrefix = Get-AutomationVariable -Name 'tagPrefix'
$tagValuePrefix = Get-AutomationVariable -Name 'tagValuePrefix'

# Tags & Tag Values used in the Remove-BackupForNonTaggedVMs runbook.
$tagName = "$($tagPrefix)Purpose"
$tagValue = "$($tagValuePrefix)RecoveryServicesVault"
$vmBackupTag = "$($tagPrefix)Backup"

$subscriptions = Get-AzSubscription

Write-Output "Subscriptions where non-compliant policies will be remediated are" $subscriptions.name

foreach ($subscription in $subscriptions) {

    $Subcontext = Get-AzContext -ListAvailable | Where-Object { $_.Subscription.Id -like $subscription.Id }

    Write-Output ("Selected Subscription is " + $subscription.Name)

    $Rsvault = Get-AzRecoveryServicesVault -TagName $tagName -TagValue $tagValue -DefaultProfile $Subcontext

    if ($Rsvault) {
        Set-AzRecoveryServicesVaultContext -Vault $Rsvault -DefaultProfile $Subcontext
        $vms = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -VaultId $Rsvault.ID -DefaultProfile $Subcontext

        foreach ($vm in $vms) {

            $virtualmachine = get-azvm -Name $vm.FriendlyName -DefaultProfile $Subcontext | Where-Object { $_.tags.keys -notcontains $vmBackupTag -or $_.Tags[$vmBackupTag] -eq "" }
            $backupItem = Get-AzRecoveryServicesBackupItem -Container $vm -WorkloadType "AzureVM" -VaultId $Rsvault.ID -DefaultProfile $Subcontext 

            if ($virtualmachine) {
                if ($backupItem.ProtectionState -ne 'ProtectionStopped') {
                Write-Output $virtualmachine
                $Container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -FriendlyName $virtualmachine.Name -VaultId $Rsvault.ID -DefaultProfile $Subcontext
                $BackupItem = Get-AzRecoveryServicesBackupItem -Container $Container -WorkloadType AzureVM -VaultId $Rsvault.ID -DefaultProfile $Subcontext
                Disable-AzRecoveryServicesBackupProtection -Item $BackupItem -VaultId $Rsvault.ID -Force -DefaultProfile $Subcontext
                # "-RemoveRecoveryPoints" is required to be able to completely remove the VM from the RSV, otherwise a soft delete window of 14 days is applied.
                # "-Force" is optional. If you don't include this, you will be prompted YES/NO to continue.
    
                Write-Output "Backup will be disabled for $($vm.FriendlyName) "
                }
                else {
                    Write-Output "Backup is already disabled for $($vm.FriendlyName). No action required."
                }
            }
            else {
                Write-Output "$($vm.FriendlyName) contains $($vmBackupTag) tag and value. No action done."
            }
        }
    }
}