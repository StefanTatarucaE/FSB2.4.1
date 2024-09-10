
function Register-EnterpriseResourceProvider {
    <#
    .SYNOPSIS
        Registers 1 or multiple Azure Resource Providers.

    .DESCRIPTION
        The function in this script file uses the Register-AzResourceProvider cmdlet to register Azure Resource Providers.
        Optional features can also be registered for each resource provider.

        Dot source this file before being able to use the function in this file. 
        To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
        . .\Register-EnterpriseResourceProvider.ps1

    .PARAMETER $providerNameSpace
        Specifies an array of object containing each provider, with the namespaces to register.
        You can also specify an array of optional features for a provider like in the example below :
        
        "providers": [
            {
                "namespace": "Microsoft.Automation"
            },            
            {
                "namespace": "Microsoft.Compute",
                "optionalFeatures" : [
                    "EncryptionAtHost"
                ]
            }
        ]

    .INPUTS
        None.

    .OUTPUTS
        $registeredProviders. A PS custom object containg info about the registered providers.

    .NOTES
        Version:        0.2
        Author:         frederic.trapet@eviden.com
        Creation Date:  20220625
        Purpose/Change: Added support for optional provider features registration
                        
    .EXAMPLE
        $inputJson = Get-Content -Path 'resourceProviders.json' -Raw | ConvertFrom-Json
        $inputJson.resourceProvider.core | Register-EnterpriseResourceProvider        

    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullorEmpty()]
        [alias("namespace")]
        [array]$providerNamespace
    )
    
    begin {
        # Get the current Azure Context
        $azContext = Get-AzContext
    }
    
    process {
        # Check to see if there is an Azure Context present.
        if ($azContext) {
            try {
                # Process every provided namespace to register.
                $registeredProviderNamespace = foreach ($namespace in $providerNamespace) {
                    $params = @{
                        ProviderNamespace = $namespace.namespace
                    }
                    $registerProvider = Register-AzResourceProvider @params

                    [pscustomobject]@{
                        ProviderNamespace   = $registerProvider.ProviderNamespace
                        FeatureName         = "(Provider)" 
                        RegistrationState   = $registerProvider.RegistrationState
                    }

                    # If optional features exist for that provider, register them too
                    If ($null -ne $namespace.optionalFeatures) {
                        foreach ($feature in $namespace.optionalFeatures) {
                            $params = @{
                                ProviderNamespace   = $namespace.namespace
                                FeatureName         = $feature
                            }
                            $registerFeature = Register-AzProviderFeature @params

                            [pscustomobject]@{
                                ProviderNamespace   = $registerFeature.ProviderName
                                FeatureName         = $registerFeature.FeatureName
                                RegistrationState   = $registerFeature.RegistrationState
                            }
                        }                        
                    }
                }
                # Output a custom pwsh object
                Write-Output $registeredProviderNamespace
            }
            catch {
                Write-Error "Provider namespace $namespace has failed to register. $($_.Exception.Message)"
            }
        }
        else {
            Write-Error 'No Azure context found in this powershell session. Login using Connect-AzAccount and try again.' -ErrorAction 'stop'
        }
    }
    
    end {
        # intentionally empty 
    }
}