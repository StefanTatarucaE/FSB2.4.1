<#
.SYNOPSIS
   Script to deallocate Azure Firewall for HUB & Spoke and Virtual WAN Firewall

.DESCRIPTION
    This script will deallocate Azure Firewall for HUB & Spoke and Virtual WAN Firewall except the firewalls which are tagged with the value dontDeallocate
    The script is schedule to run in our dev environments every day at 17:00 PM UTC byt the deallocation workflow.

    One can also run the script manually to deallocate specific firewalls or one can manually trigger the workflow using the input parameter for the workflow.

    Dot source this file before being able to use the function in this file.
    To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
    . .\Deallocate-Firewall.ps1

.PARAMETER $workflowFwInput
    The firewall name which needs to be deallocated. If this parameter is not specified, all the firewalls except the firewalls which are tagged with the value dontDeallocate will be deallocated.

.PARAMETER $azSubscription
    Specifies the Azure Subscription ID

.NOTES
    Version:        0.1
    Author:         bart.decker@eviden.com
    Creation Date:  20231212

.EXAMPLE

Deallocate-Firewall -workflowFwInput 'fw-qa-01' -azSubscription '00000000-0000-0000-0000-000000000000'

#>
function Deallocate-Firewall {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $False)]
        [String]$workflowFwInput,
        [Parameter(Mandatory = $true)]
        [String]$azSubscription
    )

    Set-AzContext -SubscriptionId $azSubscription

    Write-Verbose $workflowFwInput

    # Deallocate Firewall except if tag EvidenPurpose is set to dontDeallocate

    if (!$workflowFwInput) {
        Write-Verbose "🤓 No Firewall specified, deallocating all Firewalls"
        $azfw = Get-AzFirewall | where-object { $_.tag['EvidenPurpose'] -ne 'dontDeallocate' }
    }

    # Only Deallocate Firewall specified in workflow

    else {
        Write-Verbose "🤓 Manual trigger for Firewall: $($workflowFwInput)"
        $azfw = Get-AzFirewall -name $workflowFwInput
    }
    forEach ($azfws in $azfw) {
        Write-Verbose "🤓 Deallocating Firewall: $($azfws.Name)"
        $azfws.Deallocate()
        Set-AzFirewall -AzureFirewall $azfws | Out-Null
        Write-Verbose "✅ Firewall: $($azfws.Name) deallocated"
    }
}