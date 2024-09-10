function Invoke-Module {
    <#
    .SYNOPSIS
        Imports module(s) into the current pwsh session.

    .DESCRIPTION
        The function in this script file uses the Import-Module cmdlet,
        to import a module or modules into the current pwsh session.
        If the module or modules are not installed, the Install-Module cmdlet is used to install the module(s).

        One module name with or without version variable or multiple module names without version variable can be provided to this function in an array.
		If not provided a json file in the scripts folder of the artifact container will be used as input.

        Dot source this file before being able to use the function in this file.
        To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
        . .\Invoke-Module.ps1

    .PARAMETER $moduleName
        Specifies the module(s) of to import.

    .PARAMETER $moduleVersion
        Optional specifies the module version to import. Works only with single module.

    .INPUTS
        $inputJsonFile. Indirect input via json file which is found in /scripts/modules.json folder in the artificat container.

    .OUTPUTS
        $installedModules. A PS custom object containg info about the imported module(s).

    .NOTES
        Version:        0.1
        Author:         bart.decker@eviden.com
        Creation Date:  20220707
        Purpose/Change: First version which is feature ready to use.

    .EXAMPLE
        Invoke-Module -moduleName 'Az.Resources', 'Az.MySql', 'Assert'

        Invoke-Module
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True)]
        [string[]]$moduleName,
		[Parameter(ValueFromPipeline = $True, Mandatory = $False)]
        [string]$moduleVersion
    )

    begin {
        if ($PSEdition -eq 'Core') {
            if (-not $moduleName) {
                # If no modules are provided in the parameter the defaults will be loaded via json
                [string]$inputJsonFile = "./input/modules.json"
                $jsonObject = Get-Content -Path $inputJsonFile -Raw | ConvertFrom-Json
                $moduleName = $jsonObject.modules.name
            }
        }
        else {
            Write-Warning "This script expects PowerShell core edition."
        }
    }

    process {
		if (-not $moduleVersion ) {
        try {
            $installedModules = foreach ($module in $moduleName) {
                $availableModule = Get-Module -ListAvailable -Name $module
                if (-not $availableModule ) {
                    Write-Verbose "Finding, Installing & Importing the Module $module"

                    Find-Module $module | Install-Module -Scope CurrentUser -AllowClobber -Force
                    Import-Module $module -Force
                }
                else {
                    Write-Verbose "Module $module is already installed."
                    Import-Module $module -Force
                }

                $installedModule = Get-Module -Name $module
                [pscustomobject]@{
                    ModuleName = $installedModule.Name
                    Version    = $installedModule.Version
                }
            }
            Write-Output $installedModules
        }
        catch {
            Write-Error "Failed to process the requested module(s). $($_.Exception.Message)" -ErrorAction 'Stop'
        }
		}
		else {
			if ($moduleVersion -and $moduleName.count -eq 1) {
			try {
				$availableModule = Get-InstalledModule -Name $moduleName -RequiredVersion $moduleVersion -ErrorAction SilentlyContinue
				if (-not $availableModule ) {
                    Write-Verbose "Finding, Installing & Importing the Module $moduleName with version $moduleVersion"

					Find-Module $moduleName -RequiredVersion $moduleVersion| Install-Module -Scope CurrentUser -AllowClobber -Force
                    Import-Module $moduleName -Force
				}
				else {
					Write-Verbose "Module $moduleName with version $moduleVersion already installed."
				}
			}
					 catch {
            Write-Error "Failed to process the requested module(s). $($_.Exception.Message)" -ErrorAction 'Stop'
					 }
		}
			else {
				Write-Error "Number of modules is greater then 1. Only one module is accepted with version parameter. Failed to process the requested " -ErrorAction 'Stop'
			}
		}
    }
    end {
        # intentionally empty
    }
}