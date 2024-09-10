function Publish-AzResourceNames {
    <#
    .SYNOPSIS
        Publishes Resource Names in json format, using outputs from a Bicep template deployment.

    .DESCRIPTION
        Using the provided paths for the naming Bicep template, a deployment to a temporary resource groups is executed.
        The outputs from the deployments are used to create json files which are published to the chosen/inputted output path.

        Dot source this file before being able to use the function in this file. 
        To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
        . .\Publish-AzResourceNames.ps1

    .PARAMETER bicepTemplatePath
        Specifies the path to the naming bicep template folder.

    .PARAMETER outputPath
        Specifies the path where the generated json file(s) (with resource names) is to be saved.

    .PARAMETER azRegion
        Specifies the Azure Region where the temporary resource group should be created.

    .PARAMETER organizationCode
        Specifies the organization code used in resource naming template

    .PARAMETER environmentCode
        Specifies the environment code used in resource naming template
        t=test, d=development, a=acceptance, p=production

    .PARAMETER subscriptionCode
        Specifies the code for the subscription

    .PARAMETER subscriptionType
        Specifies the type of subscription (mgmt, cnty, lndz, tool), used by the Bicep parent modules to load in the json output.

    .INPUTS
        Parameters value coming from the pipeline

    .OUTPUTS
        Json file(s) stored in the chosen/inputted output path ($outputPath).

    .NOTES
        Version:        0.3
        Author:         frederic.trapet@eviden.com
        Creation Date:  20220623
        Purpose/Change: First version which is feature ready to use.

    .EXAMPLE
        $params = @{
            bicepTemplatePath     = '/home/runner/work/elz-azure-bicep/elz-azure-bicep/helperModules/naming/'
            outputPath            = '/home/runner/work/elz-azure-bicep/elz-azure-bicep/output/'
            azRegion              = 'northeurope'
            organizationCode      = 'xyz'
            environmentCode       = 'd'
            subscriptionCode      = 'mgmt'
        }
        Publish-AzResourceNames @params

    .EXAMPLE
        $params = @{
            bicepTemplatePath     = '/home/runner/work/elz-azure-bicep/elz-azure-bicep/helperModules/naming/'
            outputPath            = '/home/runner/work/elz-azure-bicep/elz-azure-bicep/output/'
            azRegion              = 'northeurope'
            organizationCode      = 'abc'
            environmentCode       = 'a'
            subscriptionCode      = 'lnd5'          
        }
        Publish-AzResourceNames @params
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullorEmpty()]
        [string]$bicepTemplatePath,

        [Parameter(Mandatory = $True)]
        [ValidateNotNullorEmpty()]
        [string]$outputPath,

        [Parameter(Mandatory = $True)]
        [ValidateNotNullorEmpty()]
        [string]$azRegion,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName)]
        [ValidateNotNullorEmpty()]
        [string]$organizationCode,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName)]
        [ValidateNotNullorEmpty()]
        [ValidateSet('d', 't', 'a', 'p')]
        [string]$environmentCode,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName)]
        [ValidateNotNullorEmpty()]
        [string]$subscriptionCode,

        [Parameter(Mandatory = $True)]
        [ValidateNotNullorEmpty()]
        [ValidateSet('mgmt', 'cnty', 'lndz', 'msp', 'tool')]
        [string]$subscriptionType
    )

    begin {
        # Construct the necessary paths to be able to deploy the naming Bicep template
        [string]$bicepTemplateFile = Join-Path -Path $bicepTemplatePath -ChildPath "naming.bicep"
        [string]$bicepTemplateParameterFile = Join-Path -Path $bicepTemplatePath -ChildPath "naming.params.json"

        # Create a temporary resource group to deploy the naming Bicep template to
        $shortGUID = ([system.guid]::newguid().guid).Substring(0, 5) 
        $tmpResourceGroupName = "$shortGUID-tmp-naming-rsg-deleteme"
        $tmpResourceGroup = New-AzResourceGroup -Name $tmpResourceGroupName -Location $azRegion -Verbose

        # Create a deploymentname for deploying the naming template
        $deploymentName = -join ($shortGUID, "-Naming-", $subscriptionCode)

        # Check if the temporary resource group has been created, if yes, set the parameters to deploy the naming Bicep template
        if ($tmpResourceGroup) {
            $rgParams = @{
                Name                  = $deploymentName
                ResourceGroupName     = $tmpResourceGroupName
                TemplateFile          = $bicepTemplateFile
                TemplateParameterFile = $bicepTemplateParameterFile
                azureLocation         = $azRegion
                organizationCode      = $organizationCode
                environmentCode       = $environmentCode
                subscriptionCode      = $subscriptionCode
                Verbose               = $true
            }
        }
        else {
            Write-Error "Failed to detect the temporary resourcegroup." -ErrorAction 'stop'
        }
    }
    process {
        try {
            # Create naming JSON file
            if (-not ([string]::IsNullOrEmpty($subscriptionCode))) {
                # Deploy the naming template
                $deploy = New-AzResourceGroupDeployment @rgParams
        
                #Using the outputs from the deployment(s), create an object
                [psobject]$naming = $deploy.Outputs.item("naming").value.ToString() | ConvertFrom-Json
            }
            else {
                #Subscription code is not provided for this subscription type,create an empty object
                [psobject]$naming = "{}" | ConvertFrom-Json
            }
            #Save the object to a json file.
            [string]$jsonFileName = -join ($subscriptionType, 'Naming.json')
            [string]$namingJsonFile = Join-Path -Path $outputPath -ChildPath $jsonFileName
            $naming | ConvertTo-Json -Depth 100 | Out-File $namingJsonFile -Force -Verbose

            Write-Verbose "Generated file at: '$($namingJsonFile)'"
        }
        catch {
            Write-Error "Failed to deploy naming module and/or generate the resource name json files. $($_.Exception.Message)" -ErrorAction 'Stop'
        }

    }
    end {
        # intentionally empty
    }
}
