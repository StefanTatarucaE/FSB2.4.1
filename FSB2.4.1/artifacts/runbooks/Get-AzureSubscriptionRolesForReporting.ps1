<#
.SYNOPSIS
    This runbook will create CSV files that contains Subscription Role information.
    For every subscription it will create a folder in the "iamsubscriptionreport" container in the customers storage account.

.DESCRIPTION
    This runbook will create CSV files that contains Subscription Role information.
    For every subscription it will create a folder in the "iamsubscriptionreport" container in the customers storage account.

.PARAMETER ResourceGroupName
    Optional. The name of the Azure Resource Group containing the Automation account to update all modules for.
    If a resource group is not specified, then it will use the current one for the automation account
    if it is run from the automation service

.PARAMETER AutomationAccountName
    Optional. The name of the Automation account to update all modules for.
    If an automation account is not specified, then it will use the current one for the automation account
    if it is run from the automation service

.EXAMPLE
    N/A

.NOTES
    AUTHOR: Peter Lemmen / Joost Oskam
    LASTEDIT: 25-08-2020
#>
# Get connected
try {


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


    $subscriptions = Get-AzSubscription
    Write-Output $subscriptions

    # Define branding variables needed for the Get-AzureSubscriptionRolesForReporting runbook from the automation account variables
    $company = Get-AutomationVariable -Name 'company'
    $tagPrefix = Get-AutomationVariable -Name 'tagPrefix'
    $tagValuePrefix = Get-AutomationVariable -Name 'tagValuePrefix'

    # Tags & Tag Values used in the Get-AzureSubscriptionRolesForReporting Runbook
    $tagName = "$($tagPrefix)Purpose"
    $tagValue = "$($tagValuePrefix)Reporting"

    foreach ($subscription in $subscriptions) {
        $Subcontext = Get-AzContext -ListAvailable | Where-Object { $_.Subscription -like $subscription.Id }
        $storageAccounts = Get-AzStorageAccount -DefaultProfile $Subcontext
        foreach ($storageAccount in $storageAccounts) {
            $keys = $storageAccount.Tags.Keys
            foreach ($key in $keys) {
                if ($key -eq $tagName) {
                    if ($storageAccount.Tags[$key] -eq $tagValue) {
                        # Get the <company>Purpose container context
                        $ctx = $storageaccount.context 
                        Write-Output $("SubscriptionId      :" + $subscription.id)
                        Write-Output $("Resource groupname  :" + $storageAccount.ResourceGroupName)
                        Write-Output $("Storage accountname :" + $storageAccount.StorageAccountName)
                        Write-Output $("Storage account ctx :" + $ctx)
                    }
                }
            }
        }
    }
    $date = Get-Date -Format "yyyy/MM/dd"
    foreach ($subscription in $subscriptions) {
        $tempfile = New-TemporaryFile 
        #Select-AzSubscription -SubscriptionId $subscription.Id | Out-Null
        $Subcontext = Get-AzContext -ListAvailable | Where-Object { $_.Subscription -like $subscription.Id }
        # Get the subscription role information per subscription
        Get-AzRoleAssignment -DefaultProfile $Subcontext | Export-csv $tempfile.FullName 
        $name = $subscription.Name + "-" + $date + "_iamsubscription.csv"
        # Put the CSV in the right container.
        Set-AzStorageBlobContent -File $tempfile.FullName -Container 'iamsubscriptionreport' -Blob $name -Context $ctx -Force -DefaultProfile $Subcontext
    }
}
catch { 
    throw $_.Exception
}

