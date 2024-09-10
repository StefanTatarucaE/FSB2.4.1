<#
.SYNOPSIS
   Script to allocate Azure Firewall for HUB & Spoke and Virtual WAN Firewall

.DESCRIPTION
    This script will allocate Azure Firewall for HUB & Spoke and Virtual WAN Firewall.

    One can also run the script manually to allocate specific firewalls or one can manually trigger the workflow using the input parameter for the workflow.

    Dot source this file before being able to use the function in this file.
    To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
    . .\Allocate-Firewall.ps1

.PARAMETER $workflowFwInput
    The firewall name which needs to be allocated. If this parameter is not specified, all the firewalls will be allocated.

.PARAMETER $virtualWanFirewall
    Indicates if the firewall is a vWan firewall or not. True or False

.PARAMETER $azSubscription
    Specifies the Azure Subscription ID

.PARAMETER $firewallVnetTagValue
    Specifies the tag value of the vnet where the firewall is located.

.PARAMETER $firewallPipName
    Specifies the name of the public ip of the firewall.

.NOTES
    Version:        0.1
    Author:         bart.decker@eviden.com
    Creation Date:  20231212

.EXAMPLE

Allocate-firewall -virtualWanFirewall 'False' -workflowFwInput 'fw-qa-01' -firewallPipName 'pip-name' -firewallVnetTagValue 'vnetorhubtag' -azSubscription '00000000-0000-0000-0000-000000000000'

#>
function Allocate-Firewall {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $False)]
        [String]$virtualWanFirewall,
        [Parameter(Mandatory = $False)]
        [String]$firewallPipName,
        [Parameter(Mandatory = $False)]
        [String]$firewallVnetTagValue,
        [Parameter(Mandatory = $False)]
        [String]$workflowFwInput,
        [Parameter(Mandatory = $true)]
        [String]$azSubscription

    )

    Set-AzContext -SubscriptionId $azSubscription

    # Check for non-vWan related firewall

    # Allocate the ELZ Hub & Spoke firewall.

    if (!$workflowFwInput -and $virtualWanFirewall -eq 'False') {
        Write-Verbose "🤓 No Firewall specified, allocating ELZ Hub & Spoke Firewall"
        $azfw = Get-AzFirewall | Where-Object { $_.Tag['EvidenPurpose'] -eq "EvidenNetworkingHub" }
        if ($azfw) {
            $vnet = Get-AzVirtualNetwork -ResourceGroupName $azfw.ResourceGroupName | where-object { $_.tag['EvidenPurpose'] -eq "EvidenNetworkingHub" }
            $publicip = Get-AzPublicIpAddress -ResourceGroupName $azfw.ResourceGroupName | Where-Object { $_.Name -match "pip-fw" }
            if ($azfw.IpConfigurations.Count -eq 0) {
                $azfw.Allocate($vnet, $publicip)
                Write-Verbose "🤓 Allocating Firewall $($azfw.name)"
                Set-AzFirewall -AzureFirewall $azfw | Out-Null
                Write-Verbose "✅ Firewall $($azfw.name) allocated"
            }
            else {
                Write-Verbose "✅ Firewall $($azfw.name) is already allocated"
            }
        }
        else {
            Write-Verbose "✅ No Firewall deployed in the subscription"
        }
    }

    # Allocate the manually inserted Hub & Spoke firewall.

    elseif ($workflowFwInput -and $virtualWanFirewall -eq 'False') {
        Write-Verbose "🤓 Manual trigger for vWan Firewall: $($workflowFwInput)"
        $azfw = Get-AzFirewall -name $workflowFwInput
        $vnet = Get-AzVirtualNetwork -ResourceGroupName $azfw.ResourceGroupName | where-object { $_.tag['EvidenPurpose'] -eq $firewallVnetTagValue }
        $publicip = Get-AzPublicIpAddress -ResourceGroupName $azfw.ResourceGroupName | Where-Object { $_.Name -match $firewallPipName }
        if ($azfw.IpConfigurations.Count -eq 0) {
            $azfw.Allocate($vnet, $publicip)
            Write-Verbose "🤓 Allocating Firewall $($azfw.name)"
            Set-AzFirewall -AzureFirewall $azfw | Out-Null
            Write-Verbose "✅ Firewall $($azfw.name) allocated"
        }
        else {
            Write-Verbose "✅ Firewall $($azfw.name) is already allocated"
        }
    }

    # Check for Vwan related firewall

    # Allocate the ELZ vWan related firewall.

    if (!$workflowFwInput -and ($virtualWanFirewall -eq 'False')) {
        Write-Verbose "🤓 No Firewall specified, allocating ELZ Vwan Firewall"
        $azFwVwan = Get-AzFirewall | Where-Object { $_.Tag['EvidenPurpose'] -eq "EvidenVirtualwanHub" }
        if ($azFwVwan) {
            if ($azFwVwan.hubIPAddresses.privateIPAddress -eq 0 -or $azFwVwan.hubIPAddresses.privateIPAddress -eq $null) {
                $Hub = Get-AzVirtualHub -ResourceGroupName  $azFwVwan.resourceGroupName | where-object { $_.tag['EvidenPurpose'] -eq "EvidenVirtualwanHub" }
                Write-Verbose "🤓 Allocating Firewall ${$azFwVwan.name}"
                $azFwVwan.Allocate($Hub.Id)
                $azFwVwan | Set-AzFirewall | Out-Null
                Write-Verbose "✅ Firewall ${$azFwVwan.name} allocated"
            }
            else {
                Write-Verbose "✅ Firewall $($azFwVwan.name) is already allocated"
            }
        }
        else {
            Write-Verbose "✅ No Firewall deployed in the subscription"
        }
    }

    # Allocate the manual inputed vWan related firewall.

    if ($workflowFwInput -and $virtualWanFirewall -eq 'true') {
        $azFwVwan = Get-AzFirewall -name $workflowFwInput
        if ($azFwVwan.hubIPAddresses.privateIPAddress -eq 0 -or $azFwVwan.hubIPAddresses.privateIPAddress -eq $null ) {
            $Hub = Get-AzVirtualHub -ResourceGroupName  $azFwVwan.resourceGroupName | where-object { $_.tag['EvidenPurpose'] -eq $firewallVnetTagValue }
            Write-Verbose "🤓 Allocating vWan Firewall ${$azFwVwan.name}"
            $azFwVwan.Allocate($Hub.Id)
            $azFwVwan | Set-AzFirewall | Out-Null
            Write-Verbose "✅ Firewall $($azFwVwan.name) allocated"
        }
        else {
            Write-Verbose "✅ Firewall $($azFwVwan.name) is already allocated"
        }
    }
}

