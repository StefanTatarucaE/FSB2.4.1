<#
    .SYNOPSIS
        Creates a Microsoft Partner Admin Link to a target tenant
    .DESCRIPTION
        Partner Admin Link (PAL) is an additional method for Microsoft to identify and recognize those partners who are helping customers achieve business objectives and realize value in the cloud
        
        Dot source this file before being able to use the function in this file. 
        To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
        ..\New-CustomerPal.ps1

    .PARAMETER $PartnerId
        Specifies the PartnerID to be used for current Tenant
        Alowed values are stored in wiki: https://docs.cloud.eviden.com/02.%20Eviden%20Landing%20Zones/02.%20AZURE/02.-Release-2.3/01.-DevSecOps/02.-How-To-Guides/05.-Operate/002-Partner-Access-Link-%28PAL%29-activation/
        If '0' is provided it will delete current PAL configuration

    .NOTES
        Author:      John Gonzalez, Puian Alin
        Company:     Eviden
        Email:       bart.decker@eviden.com
        Updated:     23 June 2022
        Version:     0.1


    .EXAMPLE
        New-CustomerPal -PartnerId '2222222'

    #>
function New-CustomerPal {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string] $PartnerId
    )

    Begin {
        Install-Module -Name Az.ManagedServiceIdentity -Force -AllowClobber
        Install-Module -Name Az.ManagementPartner -Force -AllowClobber
    }

    # NOTE: The Get-AzManagementPartner exits with an error if the PAL is not
    # present causing the whole script to throw when running as an ARM resource
    # It is therefore not possible to implement any form of idempotency using
    # the traditional 'get, if not exists then create' method of idempotency
    Process {
        $ExistingPartner = Get-AzManagementPartner -ErrorAction SilentlyContinue
        $PartnerId = $PartnerId.Trim()

        if ($ExistingPartner -and $PartnerId -eq '0') {
            Write-Host 'Deleting existing PAL'
            Remove-AzManagementPartner -PartnerId $ExistingPartner.PartnerId -Verbose
            return
        }
        if (-not $ExistingPartner -and $PartnerId -eq '0') {
            Write-Host 'Request to delete PAL when no PAL exists. No change. Exiting'
            return
        }
        if ($ExistingPartner -and $PartnerId) {
            if ($ExistingPartner.PartnerId -eq $PartnerId) {
                Write-Host 'Supplied PartnerId is the same as the ExistingPartnerId. No change. Exiting'
                return
            }
            else {
                Write-Host 'Updating existing PAL'
                Remove-AzManagementPartner -PartnerId $ExistingPartner.PartnerId -Verbose
                New-AzManagementPartner -PartnerId $PartnerId -Verbose
            }
            return
        }
        if (-not $ExistingPartner -and $PartnerId) {
            Write-Host 'Creating new PAL'
            New-AzManagementPartner -PartnerId $PartnerId -Verbose
            return
        }
        if (-not $ExistingPartner -and -not $PartnerId) {
            Write-Host 'No PartnerId supplied and no existing PAL in tenant, no action taken. Exiting'
            return
        }
    }
    End{
        # intentionally empty 
    }
}
