<#
    .SYNOPSIS
        Part of the optional feature that enables the storage account key management by dedicated Key Vault resources (legacy solution). 

    .DESCRIPTION
        Enables Key Management for Storage Accounts resources tagged with EvidenManagement = True; EvidenStorageAccountKeyRotation = True tags
        from all subscriptions accessible by the Automation Account Managed Identity if the dedicated keyvault tagged with   
        EvidenPurpose = EvidenStorageAccountKeyManagement is found in the same subscription.
        More details can be found here: https://learn.microsoft.com/en-us/azure/key-vault/secrets/overview-storage-keys-powershell

    .OUTPUTS  
        Error messages if the prerequisites for storage account key management are not met.  
    .NOTES
        Author:     Catalin-Alexandru Gurgu
        Company:    Eviden
        Email:      bart.decker@eviden.com
        Created:    2022-09-16
        Updated:    2023-08-07
        Version:    0.2
#>
Param
(
    [Parameter (Mandatory = $false, HelpMessage = "The number of days afer which the storage account key rotation is done by the managing Key Vault")]
    [Int16] $keyRegenerationPeriodInDays = 30
)

#Login with the assigned managed identity

try {
    Write-Output "Logging into Azure with System-assigned Identity"
    $azConnect = Connect-AzAccount -Identity
    if (-not $azConnect) {
        Write-Error "Login error: Logging into azure Failed..." -ErrorAction "Stop"
    }
    else {
        Write-Output "Successfully logged into the Azure Platform."
    }
}
catch {
    throw $_.Exception
}

#VARIABLES

# Define branding variables needed for the Set-StorageAccountKeyVaultManagement runbook from the automation account variables
$tagPrefix = Get-AutomationVariable -Name 'tagPrefix'
$tagValuePrefix = Get-AutomationVariable -Name 'tagValuePrefix'

# Tags & Tag Values used in the Set-StorageAccountKeyVaultManagement runbook.
$tagName = "$($tagPrefix)Purpose"
$managedTagName = "$($tagPrefix)Managed"
$tagValue = "$($tagValuePrefix)StorageAccountKeyManagement"
$saKeyRotationTag = "$($tagPrefix)StorageAccountKeyRotation"

$storageAccountKey = "key1"
$keyRegenerationPeriod = [System.Timespan]::FromDays($keyRegenerationPeriodInDays)
##
try {
    $subscriptions = Get-AzSubscription

    $searchStorageAccounts = Search-AzGraph -Subscription $subscriptions -Query "resources| where (type == ""microsoft.storage/storageaccounts"" and tostring(tags) contains ""\""$($saKeyRotationTag)\"":\""True\"""" and tostring(tags) contains ""\""$($managedTagName)\"":\""True\"""")"
    $storageAccounts = $searchStorageAccounts | Select-Object -Property Name, ResourceId, SubscriptionId, resourceGroup

    $inScopeSubscriptions = $searchStorageAccounts | Select-Object SubscriptionId -Unique

    $keyVaultErrorMessages = $null

    foreach ($subscription in $inScopeSubscriptions.subscriptionId) {

        $subcontext = Get-AzContext -ListAvailable | Where-Object { $_.Subscription -like $subscription }

        $saKeyVault = Get-AzResource -DefaultProfile $subcontext -Tag @{"$($tagName)" = "$($tagValue)" } | Select-Object -First 1
        If (-not $saKeyVault) {
            $keyVaultErrorMessages += ("Cannot configure key management for storage accounts from subscription: " + $subscription.Tostring() + ", no dedicated Key Vault resource was found`n")
            Continue #stop processing this subscription because the required key vault is missing
        }
        $managedStorageAccounts = Get-AzKeyVaultManagedStorageAccount -DefaultProfile $subcontext -ResourceId $saKeyVault.ResourceId | Select-Object -Property Name
        $inScopeStorageAccounts = $storageAccounts | Where-Object SubscriptionId -eq $subscription
        write-output "The following storage accounts: $($managedStorageAccounts.name) are already managed by keyvault $($saKeyVault.name)"

        foreach ($storageAccount in $inScopeStorageAccounts) {
            if (-not ($managedStorageAccounts.Name -contains $storageAccount.name)) {
                $Error.Clear()
                Add-AzKeyVaultManagedStorageAccount -DefaultProfile $subcontext -VaultName $saKeyVault.Name -AccountName $storageAccount.name -AccountResourceId $storageAccount.ResourceId -ActiveKeyName $storageAccountKey -RegenerationPeriod $keyRegenerationPeriod | Out-Null
                If ($Error[0].InvocationInfo.MyCommand.Name -eq "Add-AzKeyVaultManagedStorageAccount") {
                    Write-Error ("KeyVault management configuration error for storage account " + $storageAccount.ResourceId.tostring() + ": " + $Error[0].Exception.Message.ToString())
                }
            }
        }
    }
    if ($KeyVaultErrorMessages) {
        Write-Error $keyVaultErrorMessages
    }
}
catch {
    throw $_.Exception
}