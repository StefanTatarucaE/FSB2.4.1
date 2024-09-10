function Clear-AzEnvironment {
    <#
        .SYNOPSIS
            Removes a set of Azure resource types from selected subscription(s).

        .DESCRIPTION
            The function in this script file removes a set of Azure resource types from selected subscription(s).
            It can either do this for a set of subscriptions or for 1 subscription.
            The function can also process a specific json file with a set structure.

            The function removes a specific set of resource types to remove which are described in the 'resourceTypeToRemove' parameter section.

            Dot source this file before being able to use the function in this file. 
            To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
            . .\Clear-AzEnvironment.ps1

        .PARAMETER resourceTypeToRemove
            Specifies the resource types to remove.
            Resource types have been abbreviated.
            Abbreviations:
            pol  : policy definitions, set definitions & assignments
            pex  : policy exemptions
            ra   : role assignments
            lck  : resource locks
            evgs : event grid subscriptions
            rg   : resource groups
            kv   : keyvaults
            ws   : (log analytics) workspaces
            rsv  : recoveryservices vaults
            ds   : (azure) deployments
            des  : disk encryption sets
            diag : diagnostic settings
            all  : all resource types, except for role assignments.

        .PARAMETER devAzEnvironment
            Specifies the ELZ Azure DEV Customer code to use to determine which Azure environments (subscriptions) to clear out.

            Currently 'cu3', 'cu7' & 'cu8' are supported. These environments have the app registration which can be used for OIDC flow on the GitHub runner.
            However this function is a long running one and can not be run with the OIDC authentication flow :(

        .PARAMETER azSubscription
            Specifies the Azure subscription ID to clear out. It does not make sense to use this parameter in combination, 
            with the 'inputJson' & 'devAzEnvironment' parameters. It is either this one or the other two.

        .PARAMETER inputJson
            Specifies the json file which holds the parameter values to be used with this function.
            The json file should be created using the following structure:

            {
                "cu3": {
                    "subscriptions": [
                        "xxxxxxxx-zz01-9876-yyyy-xxxxxxxxxxxx",
                        "xxxxxxxx-zz02-9876-yyyy-xxxxxxxxxxxx",
                        "xxxxxxxx-zz03-9876-yyyy-xxxxxxxxxxxx",
                        "xxxxxxxx-zz04-9876-yyyy-xxxxxxxxxxxx",
                    ],
                },
                "cu7": {
                    "subscriptions": [
                        "xxxxxxxx-zz05-9876-yyyy-xxxxxxxxxxxx",
                        "xxxxxxxx-zz06-9876-yyyy-xxxxxxxxxxxx",
                    ],
                },
                "cu8": {
                    "subscriptions": [
                        "xxxxxxxx-zz07-9876-yyyy-xxxxxxxxxxxx",
                    ],
                }
            }

        .PARAMETER msSupportAccountId
            Specifies the objectId of the role assignment for the AdminAgents group. This role assignment
            needs to stay in place for the support teams to be able to log a MS Support ticket. The use of this parameter
            only works correctly from the workflow when the service principle used for the cleanup action has the following
            Graph API Permissions: Application (Read.All, ReadWrite.All), Directory (Read.All, ReadWrite.All), User (Read.All, ReadWrite.All)

        .INPUTS
            Can process json input files, see inputJson parameter.

        .OUTPUTS
            None

        .NOTES
            Version:                        0.8
            Author:                         bart.decker@eviden.com
            Creation/Modification Date:     20221019
            Purpose/Change:                 Added documentation to the function

        .EXAMPLE
            Clear-AzEnvironment -Verbose -resourceTypeToRemove kv -azSubscription 'xxxxyyyy-zzzz-1111-tttt-aaaabbbbcccc'

            $params = @{
                resourceTypeToRemove = 'all'
                devAzEnvironment     = 'cu8'
                inputJson            = '.\input\devSubscriptions.json'
                Verbose              = $true
            }
            Clear-AzEnvironment @params
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateSet('pol', 'pex', 'ra', 'lck', 'evgs', 'rg', 'kv', 'ws', 'rsv', 'ds', 'des', 'diag', 'all')]
        [string[]]$resourceTypeToRemove,
        [Parameter(Position = 1)]
        [ValidateSet('cu1', 'cu3', 'cu7', 'cu8')]
        [string]$devAzEnvironment,
        [Parameter(Position = 2)]
        [string[]]$azSubscription,
        [Parameter(Position = 3, ValueFromPipeline)]
        [string]$inputJson,
        [Parameter(Position = 4, ValueFromPipeline)]
        [string]$roleAssignmentObjectId = "23c26a67-6e2d-4b7c-86e8-00c53a88955e"
    )
    begin {
        Write-Verbose "🤓 Clear-AzEnvironment Function started..."

        if (-not ([string]::IsNullOrEmpty($inputJson))) {
            # If the $inputJson parameter is not empty use it to set the parameter values provided in the json file
            if (Test-Path -Path $inputJson) {
                $jsonObject = Get-Content -Path $inputJson -Raw | ConvertFrom-Json -AsHashtable

                if ($jsonObject) {
                    $azSubscriptions = foreach ($entry in $($jsonObject.$devAzEnvironment.subscriptions).GetEnumerator()) { 
                        $entry.Value
                    }
                }
                else {
                    Write-Error "Failed loading the json file..." -ErrorAction 'Stop'
                }

                Write-Verbose "The json file has been succesfully loaded."
                Write-Verbose "Load result: $azSubscriptions"
            }
        }
        else {
            Write-Verbose "No json file input detected, checking for a subscriptionId..."
            if ($azSubscription) {
                $azSubscriptions = $azSubscription
            }
            else {
                Write-Error "SubscriptionId was not provided. Function is not able to run, aborting..." -ErrorAction 'Stop'
            }

            Write-Verbose "SubscriptionId has been succesfully loaded."
            Write-Verbose "Load result: $azSubscriptions"
        }
    }

    process {
        foreach ($subscription in $azSubscriptions) {

            $azContext = Set-AzContext -SubscriptionId $subscription

            Write-Verbose "Az context set to subscription: $($azContext.Subscription.Name)"

            if ($resourceTypeToRemove -eq 'pol') {
                Clear-AzPolicyResources
            }
            elseif ($resourceTypeToRemove -eq 'ra') {
                if ($roleAssignmentObjectId) {
                    Clear-AzUnknownRoleAssignments -objectId $roleAssignmentObjectId
                }
                else {
                    Clear-AzUnknownRoleAssignments
                }
            }
            elseif ($resourceTypeToRemove -eq 'ws') {
                Clear-AzWorkspace
            }
            elseif ($resourceTypeToRemove -eq 'rsv') {
                Clear-AzRecoveryServicesVault
            }
            elseif ($resourceTypeToRemove -eq 'pex') {
                Clear-AzPolicyExemptions
            }
            elseif ($resourceTypeToRemove -eq 'lck') {
                Clear-AzLocks
            }
            elseif ($resourceTypeToRemove -eq 'evgs') {
                Clear-AzEventGridSubscriptions
            }
            elseif ($resourceTypeToRemove -eq 'kv') {
                Clear-AzKeyVault
            }
            elseif ($resourceTypeToRemove -eq 'rg') {
                Clear-AzResourceGroup
            }
            elseif ($resourceTypeToRemove -eq 'ds') {
                Clear-AzDeployments
            }
            elseif ($resourceTypeToRemove -eq 'des') {
                Clear-AzDiskEncryptionSet
            }
            elseif ($resourceTypeToRemove -eq 'diag') {
                Clear-AzSubscriptionDiagnosticSettings
            }
            elseif ($resourceTypeToRemove -eq 'all') {
                Write-Verbose "😎 Removing all the things... "

                Clear-AzLocks
                Clear-AzPolicyResources
                Clear-AzPolicyExemptions
                Clear-AzEventGridSubscriptions
                Clear-AzRecoveryServicesVault
                Clear-AzWorkspace
                Clear-AzKeyVault
                Clear-AzResourceGroup
                Clear-AzDeployments
                Clear-AzSubscriptionDiagnosticSettings
                Clear-AzDiskEncryptionSet
                Clear-AzUnknownRoleAssignments -objectId $roleAssignmentObjectId
                Clear-ResourceGroupsWithKeyvaults
            }
        }

    }

    end {
        Write-Verbose "✅ Clear-AzEnvironment Function end..."
    }
}

function Clear-AzLocks {
    <#
        .SYNOPSIS
            Removes Azure locks.
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Get Locks to be deleted
        $locks = Get-AzResourceLock
    }

    process {
        if ($locks) {
            # Removing the found Locks
            Write-Verbose "❌ Removing Locks..."
            foreach ($lock in $locks) {
                Remove-AzResourceLock -LockId $lock.LockId -Force -Verbose
            }
        }
        else {
            Write-Verbose "No Locks found"
        }

    }

    end {
        # intentionally empty 
    }
}

function Clear-AzWorkspace {
    <#
        .SYNOPSIS
            Removes Azure (Log Analytics) Workspaces
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Get Log Analytics Workspaces to be deleted
        $workspaces = Get-AzOperationalInsightsWorkspace
    }

    process {
        # Removing the found workspaces
        if ($workspaces) {
            Write-Verbose  "'$($workspaces.Count)' Log Analytics Workspaces were found. "
            foreach ($workspace in $workspaces) {
                # Log Analytics Workspaces require special attention (cmdlets) when removing to prevent them from being kept in a 
                # trashbin where they can cause name clashes when new workspaces are created with the same name as the previously deleted ones.
                Write-Verbose "❌ Removing Log Analytics Workspace..."
                Remove-AzOperationalInsightsWorkspace -Name $($workspace.Name) -ResourceGroupName $($workspace.ResourceGroupName) -ForceDelete -Force | Out-Null
                Write-Verbose "OperationalInsightsWorkspace: '$($workspace.Name)' was removed with force"
            }
        }
        else {
            Write-Verbose "No Workspaces found"
        }
    }

    end {
        # intentionally empty
    }
}

function Clear-AzKeyVault {
    <#
        .SYNOPSIS
            Removes Azure Keyvaults with Purge Protection disabled.
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Check for Keyvaults as they require to be purged after delete when soft-delete is enabled on the keyvault
        # Get Keyvaults to be deleted
        $keyvaults = Get-AzKeyVault
    }

    process {
        # Removing the found keyvaults
        if ($keyvaults) {
            Write-Verbose  "'$($keyvaults.Count)' Keyvaults were found. "
            foreach ($keyvault in $keyvaults) {

                $kv = Get-AzKeyVault -VaultName $keyvault.VaultName
                if (($kv.EnablePurgeProtection) -eq $true) {
                    Write-Verbose "Keyvault: '$($keyvault.VaultName)' has Purge Protection Enabled. Skipping removal."
                }
                else {
                    Write-Verbose "❌ Removing Keyvault..."
                    Remove-AzKeyVault -VaultName $($keyvault.VaultName) -ResourceGroupName $($keyvault.ResourceGroupName) -Force -Verbose
                    Remove-AzKeyVault -VaultName $($keyvault.VaultName) -InRemovedState -Force -Location $($keyvault.Location) -Verbose
                    Write-Verbose "Keyvault: '$($keyvault.VaultName)' was removed and purged"
                }
            }
        }
        else {
            Write-Verbose "No Keyvaults found"
        }
    }

    end {
        # intentionally empty
    }
}

function Clear-AzDiskEncryptionSet {
    <#
        .SYNOPSIS
            Removes Azure Disk Encryption sets.
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Get Disk Encryption Sets to be deleted
        $diskEncryptionSets = Get-AzDiskEncryptionSet
    }

    process {
        # Removing the found Disk Encryption Sets
        if ($diskEncryptionSets) {
            Write-Verbose  "'$($diskEncryptionSets.Count)' Disk Encryption Sets were found. "
            foreach ($set in $diskEncryptionSets) {
                Write-Verbose "❌ Removing Disk Encryption Sets..."
                Remove-AzDiskEncryptionSet -Name $($set.Name) -ResourceGroupName $($set.ResourceGroupName) -Force -Verbose -ErrorAction 'SilentlyContinue'
                Write-Verbose "Disk Encryption Sets: '$($set.Name)' was removed"
            }
        }
        else {
            Write-Verbose "No Disk Encryption Sets found"
        }

    }

    end {
        # intentionally empty
    }
}

function Clear-AzRecoveryServicesVault {
    <#
        .SYNOPSIS
            Removes Azure Recovery Services Vaults.
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Clean up any VM backup items from the found recovery vaults to enable removal of these vaults
        $containerType = 'AzureVM'

        # Get Recovery Services Vaults to be deleted
        $recoveryServicesVaults = Get-AzRecoveryServicesVault
    }

    process {

        if ($recoveryServicesVaults) {
            # Removing the found EventGrid Subscriptions
            Write-Verbose  "'$($recoveryServicesVaults.Count)' Recovery Service Vaults were found. "

            foreach ($recoveryServicesVault in $recoveryServicesVaults) {
                $vaultName = $recoveryServicesVault.Name
                $vaultResourceGroupName = $recoveryServicesVault.ResourceGroupName
                $vaultSubscriptionId = $recoveryServicesVault.SubscriptionId
                $vault = $null
                $vault = Get-AzRecoveryServicesVault -ResourceGroupName $vaultResourceGroupName -Name $vaultName 

                Set-AzRecoveryServicesAsrVaultContext -Vault $vault
                #To enable the upcoming delete of the recovery services vault, disable soft delete for the upcoming removal of VM backups
                Set-AzRecoveryServicesVaultProperty -VaultId $vault.Id -SoftDeleteFeatureState Disable

                $containers = $null
                Write-Verbose "Attempting to retrieve Recovery Services Backup Containers."
                $containers = Get-AzRecoveryServicesBackupContainer -ContainerType $containerType -VaultId $vault.ID

                if ($containers) {
                    Write-Verbose "'$($containers.Count)' Backup Containers were found."
                    foreach ($container in $containers) {
                        Write-Verbose "Disabling protection for $($container.ResourceGroupName)\$($container.FriendlyName)."
                        $backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType $containerType -VaultId $vault.ID
                        Disable-AzRecoveryServicesBackupProtection -VaultId $vault.ID -Item $backupItem -RemoveRecoveryPoints -Confirm:$false -Force | Out-Null
                    }
                }
                else {
                    Write-Verbose "No Backup Containers to remove. "
                }

                $accessToken = Get-AzAccessToken
                $token = $accessToken.Token
                $authHeader = @{
                    'Content-Type'  = 'application/json'
                    'Authorization' = 'Bearer ' + $token
                }
                $restUri = "https://management.azure.com/subscriptions/" + $vaultSubscriptionId + '/resourcegroups/' + $vaultResourceGroupName + '/providers/Microsoft.RecoveryServices/vaults/' + $vaultName + '?api-version=2021-06-01&operation=DeleteVaultUsingPS'

                Write-Verbose "❌ Removing Recovery Services Vault..."
                Invoke-RestMethod -Uri $restUri -Headers $authHeader -Method DELETE

                $vaultDeleted = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue | Out-Null
                if (-not $vaultDeleted) {
                    Write-Verbose "Recovery Services Vault $vaultName successfully deleted"
                }
            }
        }
        else {
            Write-Verbose "No Recovery Services Vaults to remove."
        }
    }

    end {
        # intentionally empty 
    }
}

function Clear-AzPolicyResources {
    <#
        .SYNOPSIS
            Removes Azure Policy Definitions, Set Definitions & Assignments.
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Get Policy resources to be deleted
        $policyAssignments = Get-AzPolicyAssignment
        $policySetDefinitions = Get-AzPolicySetDefinition -Custom
        $policyDefinitions = Get-AzPolicyDefinition -Custom
    }

    process {
        # Removing the found Policy resources
        Write-Verbose "❌ Removing Policy Assignments..."
        if ($policyAssignments) {
            foreach ($policyAssignment in $policyAssignments) {
                Remove-AzPolicyAssignment -Name $policyAssignment.Name -Scope $policyAssignment.Properties.scope -Verbose
            }
        }
        else {
            Write-Verbose "No Policy Assignments found"
        }

        if ($policySetDefinitions) {
            Write-Verbose "❌ Removing Policy Set Definitions..."
            $policySetDefinitions | Remove-AzPolicySetDefinition -Verbose -Force
        }
        else {
            Write-Verbose "No Policy Set Definitions found"
        }

        if ($policyDefinitions) {
            Write-Verbose "❌ Removing Policy Definitions..."
            $policyDefinitions | Remove-AzPolicyDefinition -Verbose -Force
        }
        else {
            Write-Verbose "No Policy Definitions found"
        }
    }

    end {
        # intentionally empty
    }
}

function Clear-AzPolicyExemptions {
    <#
        .SYNOPSIS
            Removes Azure Policy Exemptions.
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Get Subscription Exemptions to be deleted.
        $resourceGroups = Get-AzResourceGroup
        $subscriptionExemptions = Get-AzPolicyExemption
    }

    process {

        # Removing the found Subscription Exemptions.
        Write-Verbose "❌ Removing Subscription Exemptions..."
        if ($subscriptionExemptions) {
            $subscriptionExemptions | Remove-AzPolicyExemption -Force -Verbose
        }
        else {
            Write-Verbose "No Subscription Exemptions found"
        }

        # Get Resourcegroup Exemptions to be deleted.
        Write-Verbose "❌ Removing Resourcegroup Exemptions..."
        foreach ($resourceGroup in $resourceGroups) {

            $resourceGroupExemptions = Get-AzPolicyExemption -Scope $resourceGroup.Resourceid

            # Removing the found Resourcegroup Exemptions.
            if ($resourceGroupExemptions) {
                $resourceGroupExemptions | Remove-AzPolicyExemption -Force -Verbose
            }
        }
    }

    end {
        # intentionally empty
    }
}

function Clear-AzUnknownRoleAssignments {
    <#
        .SYNOPSIS
            Removes Azure Role Assignments which do not have a value or empty value for 'DisplayName'.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$objectId
    )

    begin {
        # Get unknown Role Assignments to be deleted
        if ([string]::IsNullOrEmpty($objectId)) {
            Write-Verbose "Querying all unknown role assignments, no objectId '$objectId' detected."
            $roleAssignments = Get-AzRoleAssignment | Where-Object { $_.ObjectType -eq 'unknown' } 
        }
        else {
            Write-Verbose "Querying all unknown role assignments , but skipping objectId '$objectId'."
            $roleAssignments = Get-AzRoleAssignment | Where-Object { $_.ObjectType -eq 'unknown' -and $_.ObjectId -ne $objectId }
        }
    }

    process {
        Write-Verbose "❌ Removing Unknown Role Assignments..."

        $removalResults = foreach ($assignment in $roleAssignments) {
            if ([string]::IsNullOrEmpty($assignment.DisplayName)) {
                $assignment | Remove-AzRoleAssignment -Verbose

                [pscustomobject]@{
                    RoleDefinitionName = $assignment.RoleDefinitionName
                    AssignmentName     = $assignment.RoleAssignmentName
                    Removed            = "✅"
                }
            }
        }

        if ($removalResults) {
            Write-Output $removalResults
        }
        else {
            Write-Verbose "No Unknown Role Assignments found"
        }
    }

    end {
        # intentionally empty
    }
}

function Clear-AzResourceGroup {
    <#
        .SYNOPSIS
            Removes Azure Resource groups (except for rgs with 'disk-encryption' as part of their name).
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Get Resource Groups to be deleted
        $resourceGroups = Get-AzResourceGroup
        $filteredRGs = $resourceGroups | Where-Object { $_.ResourceGroupName -notlike '*disk-encryption*' -and $_.ResourceGroupName -notlike '*-metering*' -and $_.ResourceGroupName -notlike '*-itsm*' -and $_.ResourceGroupName -notlike '*-firewallPolicy*' }
    }

    process {
        # Removing the found resource groups

        Write-Verbose "❌ Removing Resource Groups..."
        $filteredRGs | Remove-AzResourceGroup -Force -Verbose -AsJob
    }

    end {
        # intentionally empty
    }
}

function Clear-AzSubscriptionDiagnosticSettings {
    <#
        .SYNOPSIS
            Removes Azure Diagnostic Settings.
    #>
    [CmdletBinding()]
    param ()

    begin {
        $subscriptionDiagSettings = Get-AzSubscriptionDiagnosticSetting -SubscriptionId (Get-AzContext).Subscription.Id
    }

    process {

        if ($subscriptionDiagSettings) {
            # Delete existing diag rule on subscription (activity log)
            Write-Verbose "❌ Removing Az Subscription DiagnosticSettings..."
            foreach ($setting in $subscriptionDiagSettings) {
                Remove-AzSubscriptionDiagnosticSetting -Name $setting.Name -Verbose
            }
        }
        else {
            Write-Verbose "No Az Subscription DiagnosticSettings found"
        }
    }

    end {
        # intentionally empty 
    }
}

function Clear-AzEventGridSubscriptions {
    <#
        .SYNOPSIS
            Removes Azure EventGrid Subscriptions.
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Get EventGrid Subscriptions to be deleted
        $eventGridSubscriptions = Get-AzEventGridSubscription
    }

    process {
        # Removing the found EventGrid Subscriptions
        Write-Verbose "❌ Removing Eventgrid Subscriptions..."
        if ($eventGridSubscriptions) {
            foreach ($subscription in $eventGridSubscriptions.PsEventSubscriptionsList) {
                Remove-AzEventGridSubscription $subscription.eventSubscriptionName -Verbose
            }
        }
        else {
            Write-Verbose "No EventGrid Subscriptions found"
        }
    }

    end {
        # intentionally empty
    }
}
function Clear-AzDeployments {
    <#
        .SYNOPSIS
            Removes Azure Deployments.
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Get Azure Deployments to be deleted
        $azDeployments = Get-AzDeployment
    }

    process {
        # Removing the found Azure Deployments
        if ($azDeployments) {
            Write-Verbose "❌ Removing Azure Deployments..."
            $azDeployments | Remove-AzDeployment -Verbose -AsJob
        }
        else {
            Write-Verbose "No Azure Deployments found"
        }
    }

    end {
        # intentionally empty
    }
}

function Clear-ResourceGroupsWithKeyvaults {
    <#
        .SYNOPSIS
            Cleans out resources from Resource Groups which are skipped for removal due to purge protected keyvaults
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Get resourcesgroups in which resources need to be removed.
        Write-Verbose "❌ Removing resources from resourcegroups with purge protected keyvaults.."
        $resourceGroups = Get-AzResourceGroup | where-object { $_.ResourceGroupName -like '*disk-encryption*' -or $_.ResourceGroupName -like '*-metering*' -or $_.ResourceGroupName -like '*-itsm*' -or $_.ResourceGroupName -like '*-firewallPolicy*' }
    }

    process {
        if ($resourceGroups) {
            # Removing resources within these resourcegroups
            foreach ($resourceGroup in $ResourceGroups) {
                $resources = Get-AzResource -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue | Where-Object { $_.ResourceType -ne 'Microsoft.KeyVault/vaults' }

                # Make sure hostingplan is removed after function or logicapp
                $sortedResources = $resources | Sort-Object -property ResourceType -descending

                foreach ($resource in $sortedResources) {
                    Remove-AzResource -ResourceName $resource.name -ResourceGroupName $resourceGroup.ResourceGroupName -ResourceType $resource.ResourceType -Force -verbose -ErrorAction SilentlyContinue
                }
            }
        }
        else {
            Write-Verbose "No resources found to remove"
        }
    }
    end {
        # intentionally empty
    }
}