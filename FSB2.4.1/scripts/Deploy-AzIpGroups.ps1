function Deploy-AzIpGroups {
    <#
    .SYNOPSIS
        Deploy-AzIpGroups deploys the ipGroups to the correct subscription and resource group.

    .DESCRIPTION
        Using the provided ipGroup json file, Deploy-AzIpGroups deploys the ipGroups to the correct subscription and resource group.

        Dot source this file before being able to use the function in this file. 
        To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
        . .\Deploy-AzIpGroups.ps1

    .PARAMETER ipGroupTemplateFile
        Specifies the path to the template file to be used for the deployment.

    .PARAMETER outputPath
        Specifies the path where the generated json file(s) (with ipGroup resourceId) is to be saved.

    .PARAMETER ipGroupJsonFile
        Specifies the file containing the ipGroup json object.

    .PARAMETER whatIfBool
        Specifies if the deployment should be executed or not. If set to $true, the deployment will be executed in whatif mode.

    .INPUTS
        Parameters value coming from the pipeline

    .OUTPUTS
        Json file stored in the chosen/inputted output path ($outputPath).

    .NOTES
        Version:        0.1
        Author:         bart.decker@eviden.com
        Creation Date:  20240115
        Purpose/Change: First version which is feature ready to use.

    .EXAMPLE
        $params = @{
            ipGroupTemplateFile     = 'C:\Repos\dcs-azure-bicep\childModules\ipGroup\'
            outputPath            = '/home/runner/work/elz-azure-bicep/elz-azure-bicep/output/'
            ipGroupJsonFile     = 'C:\Repos\dcs-azure-bicep\input\dv3\dev3\parentModules\'
            whatIfBool            = $true
        }
        Deploy-AzIpGroups @params
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullorEmpty()]
        [string]$ipGroupTemplateFile,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullorEmpty()]
        [string]$outputPath,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullorEmpty()]
        [string]$ipGroupJsonPath,
        [Parameter(Mandatory = $false)]
        [switch]$whatIfBool = $false
    )

    begin {

        [string]$ipGroupJsonFile = Join-Path -Path $ipGroupJsonPath -ChildPath "customerIpGroups.json"

        # Create a hashtable to store the deployed ipGroups
        $deployedIpGroupsTable = @{}

        # Determine if we are running in whatif mode or not
        if ($whatIfBool) {
            Write-Verbose "Running in WhatIf mode"
            $WhatIfPreference = $true
        }
        else {
            Write-Verbose "Running in Deploy mode"
            $WhatIfPreference = $false
        }

        # Load the to be deployed ipGroups json file
        $ipGroupsObject = Get-Content $ipGroupJsonFile -raw | ConvertFrom-Json -AsHashtable

        foreach ($ipGroup in $ipGroupsObject.ipGroups) {

            try {
                # Switch to the correct subscription with whatif disabled
                set-azcontext -Subscription "$($ipGroup.subscriptionId)" -WhatIf:$false

                # Construct the deployment parameters
                $DeploymentParameters = @{
                    Location         = $ipGroup.location
                    Name             = $ipGroup.name

                    ipAddressesArray = $ipGroup.ipAddresses
                }

                $Parameters = @{
                    ResourceGroupName       = $ipGroup.resourceGroupName
                    tags                    = $ipGroup.tags
                    TemplateFile            = $ipGroupTemplateFile
                    TemplateParameterObject = $DeploymentParameters
                    WhatIf                  = $whatIfBool
                }
                write-verbose $ipGroupTemplateFile

                $existingRg = get-azresourcegroup -name "$($ipGroup.resourceGroupName)" -location "$($ipGroup.location)" -erroraction silentlycontinue
                # Check if resourceGroup exists, if not create it
                if (!$existingRg) {
                    write-verbose "Creating resource group $($ipGroup.resourceGroupName)"
                    New-AzResourceGroup -Name $ipGroup.resourceGroupName -Location $ipGroup.location -force
                }
                else {
                    write-verbose "resourceGroup $($ipGroup.resourceGroupName) already exists"
                }
                write-verbose "Creating ipGroup with name $($ipGroup.name)"

                # Define the deployment name using the ipGroup name and resourceGroup name
                $deploymentName = "ipGroup-$($ipGroup.name)-rg-$($ipGroup.resourceGroupName)"

                if (($whatIfBool) -and (!$existingRg)) {
                    write-verbose "The resourceGroup with name: $($ipGroup.resourceGroupName) does not exist so what-if scenario is not possible. Expect $($ipGroup.name) to be deployed in $($ipGroup.resourceGroupName) when whatIf would be set to false"
                }
                else {
                     # Deploy the customer ipGroup
                     $deployedIpGroup = New-AzResourceGroupDeployment -DeploymentName $deploymentName  @Parameters -verbose
                }

                # If not in whatif mode, add the ipGroup to the table
                if (!$whatIfBool) {
                    $deployedIpGroupsTable.add($deployedIpGroup.Outputs.ipGroupResourceId.value, $deployedIpGroup.Outputs.ipGroupName.value)
                }
            }
            catch {
                Write-Error "Error while deploying ipGroup $($ipGroup.name) to resourceGroup $($ipGroup.resourceGroupName)"
                Write-Error $_.Exception.Message
            }
        }
    }
    process {
        # If not in whatif mode, save the output object to a json file
        if (!$whatIfBool) {
            #Save the output object to a json file.
            [string]$jsonFileName = 'IpGroups.json'
            [string]$OutputJsonFile = Join-Path -Path $outputPath -ChildPath $jsonFileName
            $deployedIpGroupsTable | ConvertTo-Json -Depth 100 | Out-File $OutputJsonFile -Force -Verbose

            Write-Verbose "Generated file at: $($OutputJsonFile)"
        }
    }
    end {
        # intentionally left blank
    }
}