<#
.SYNOPSIS
    Creates the Azure Lighthouse Delegations towards the MSP
.DESCRIPTION
    To managed the customer subscriptions it's needed to onboard the subscriptions using Azure Delegations.

    Dot source this file before being able to use the function in this file.
    To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
    ..\New-LighthouseDelegation.ps1

.PARAMETER $Subscriptions
    Specifies the to be delegated subscription ID('s).

.PARAMETER $azRegion

    Specifies the Azure region for the assignment.

.PARAMETER $templateFile

    Path to the bicep template for deploying the Lighthouse delegations.

.PARAMETER $templateParameterFile

    Path to the bicep template parameter file which holds the Lighthouse delegation details.

.NOTES
    Author:      Bart Decker
    Company:     Eviden
    Email:       bart.decker@eviden.com
    Updated:     4 July 2022
    Version:     0.1

.EXAMPLE
    New-LighthouseDelegation -subscriptions 9xxc363-b187-42af-axx-fc3f210d94a0,3bxxxxa6a-d129-47e1-bbe5-6dfxxxx7a2e1 -azregion westus -templatefile "<path to azureLighthouse.bicep>" -templateParameterFile "<path to parameter file>"

#>

function New-LighthouseDelegation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [String[]] $subscriptions,
        [Parameter(Mandatory = $True)]
        [string] $azRegion,
        [Parameter(Mandatory = $True)]
        [string] $templateFile,
        [Parameter(Mandatory = $True)]
        [string] $templateParameterFile
    )

    begin {}

    Process {

        # Loop over provided subscriptions and deploy the Lighthouse delegation. 
        try {
            foreach ($subscription in $subscriptions) {
                Write-Output "Setting context to subscription $subscription"
                Set-AzContext -SubscriptionId $subscription
                New-AzSubscriptionDeployment -Location $azRegion -TemplateFile $templateFile -TemplateParameterFile $templateParameterFile
            }
        }

        catch {

            Write-Error "Lighthouse delegation failed for subscription: $subscription"
        }
    }

    end {
        # intentionally empty
    }
}


