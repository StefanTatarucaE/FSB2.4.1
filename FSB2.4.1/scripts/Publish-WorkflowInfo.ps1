function Publish-WorkflowInfo {
    <#
    .SYNOPSIS
        Publishes a json file to be used during a workflow run by a GitHub Runner.

    .DESCRIPTION
        The function in this script file loads a json file. 
        Using the values from the json file, pwsh variables are constructed, 
        which are then used to create a workflowInfo. json file to be used during a workflow run by a GitHub Runner.

        Dot source this file before being able to use the function in this file. 
        To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
        . .\Publish-WorkflowInfo.ps1

    .PARAMETER inputJson
        Specifies the path to the json file which contains the runtime values needed by the workflow run.

    .PARAMETER mgmtSubscriptionId
        Specifies the subcription id of the management subscription. 
        This parameter is only used when this function is not executed on a GitHub runner.
        To be used in the workflow by Bicep Parent modules.

    .PARAMETER cntySubscriptionId
        Specifies the subcription id of the connectivity subscription.
        This parameter is only used when this function is not executed on a GitHub runner.
        To be used in the workflow by Bicep Parent modules.

    .PARAMETER lndzSubscriptionId
        Specifies the subcription id of the landingzone subscription.
        This parameter is only used when this function is not executed on a GitHub runner.
        To be used in the workflow by Bicep Parent modules.

    .PARAMETER toolSubscriptionId
        Specifies the subcription id of the tooling subscription.
        This parameter is only used when this function is not executed on a GitHub runner.
        To be used in the workflow by Bicep Parent modules.

    .PARAMETER outputPath
        Specifies the path where the workflowInfo.json file will be saved on disk.

    .INPUTS
        Json file. Details described in the description section.

    .OUTPUTS
        workflowInfo.json file which contains the values used during a workflow run.

    .NOTES
        Version:        0.5
        Author:         frederic.trapet@eviden.com
        Creation Date:  20221027
        Purpose/Change: First version which is feature ready to use.
                        
    .EXAMPLE
        Publish-WorkflowInfo -inputJson './info.json' -mgmtSubscriptionId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -outputPath './'

    .EXAMPLE
        $params = @{
            inputJson          = './deployInfo.json'
            mgmtSubscriptionId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
            cntySubscriptionId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
            lndzSubscriptionId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
            toolSubscriptionId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
            outputPath         = 'c:\somefolder'
            Verbose            = $true
        }
        Publish-WorkflowInfo @params

    .EXAMPLE
        $params = @{
            inputJson          = './deployInfo.json'
            outputPath         = './'
            Verbose            = $true
        }
        Publish-WorkflowInfo @params
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$inputJson,
        [Parameter(Mandatory = $false)]
        [string]$mgmtSubscriptionId,
        [Parameter(Mandatory = $false)]
        [string]$cntySubscriptionId,
        [Parameter(Mandatory = $false)]
        [string]$lndzSubscriptionId,
        [Parameter(Mandatory = $false)]
        [string]$toolSubscriptionId,
        [Parameter(Mandatory = $true)]
        [string]$outputPath
    )
    
    begin {
        if (-not ([string]::IsNullOrEmpty($inputJson))) {

            # If the $inputJson parameter is not empty, load the json file in to an pwsh variable
            if (Test-Path -Path $inputJson) {
                $jsonObject = Get-Content -Path $inputJson -Raw | ConvertFrom-Json

                Write-Verbose "The json file has been succesfully loaded..."
            }
            else {
                Write-Error "The json file cannot be found at the designated path. $($_.Exception.Message)" -ErrorAction 'Stop'
            }
        }
    }
    
    process {
        if ($jsonObject) {
            Write-Verbose "The json file is processed successfully, now initializing variables..."

            # Loading in json values from the values in to pwsh variables
            [string]$organizationCode = $jsonObject.organizationCode
            [string]$githubEnvironmentCode = $jsonObject.githubEnvironmentCode

            [string]$mgmtSubscriptionCode = $jsonObject.mgmtSubscriptionCode
            [string]$cntySubscriptionCode = $jsonObject.cntySubscriptionCode
            [string]$lndzSubscriptionCode = $jsonObject.lndzSubscriptionCode
            [string]$toolSubscriptionCode = $jsonObject.toolSubscriptionCode

            [string]$mgmtEnvironmentCode = $jsonObject.mgmtEnvironmentCode
            [string]$cntyEnvironmentCode = $jsonObject.cntyEnvironmentCode
            [string]$lndzEnvironmentCode = $jsonObject.lndzEnvironmentCode
            [string]$toolEnvironmentCode = $jsonObject.toolEnvironmentCode

            # Constructing pwsh variables to be used by some of the parent modules,
            # the VMOSManagement, costManagement & Networking parent modules can deploy to different subscription types
            [string]$networkCntyTemplateParameterFile = -join ($githubEnvironmentCode, '.', $cntySubscriptionCode, '.networking.params.json')
            [string]$networkLndzTemplateParameterFile = -join ($githubEnvironmentCode, '.', $lndzSubscriptionCode, '.networking.params.json')
            [string]$networktoolTemplateParameterFile = -join ($githubEnvironmentCode, '.', $toolSubscriptionCode, '.networking.params.json')

            [string]$vWanNetworkCntyTemplateParameterFile = -join ($githubEnvironmentCode, '.', $cntySubscriptionCode, '.virtualwan.params.json')
            [string]$vWanNetworkLndzTemplateParameterFile = -join ($githubEnvironmentCode, '.', $lndzSubscriptionCode, '.virtualwan.params.json')
            [string]$vWanNetworktoolTemplateParameterFile = -join ($githubEnvironmentCode, '.', $toolSubscriptionCode, '.virtualwan.params.json')


            [string]$vmOsMgmtMgmtTemplateParameterFile = -join ($githubEnvironmentCode, '.', $mgmtSubscriptionCode, '.vmosmanagement.params.json')
            [string]$vmOsMgmtLndzTemplateParameterFile = -join ($githubEnvironmentCode, '.', $lndzSubscriptionCode, '.vmosmanagement.params.json')
            [string]$vmOsMgmtToolTemplateParameterFile = -join ($githubEnvironmentCode, '.', $toolSubscriptionCode, '.vmosmanagement.params.json')

            [string]$costManagementMgmtTemplateParameterFile = -join ($githubEnvironmentCode, '.', $mgmtSubscriptionCode, '.costmanagement.params.json')
            [string]$costManagementCntyTemplateParameterFile = -join ($githubEnvironmentCode, '.', $cntySubscriptionCode, '.costmanagement.params.json')
            [string]$costManagementLndzTemplateParameterFile = -join ($githubEnvironmentCode, '.', $lndzSubscriptionCode, '.costmanagement.params.json')

            # Setting values to an ordered hashtable to be saved as the workflowInfo.json file
            $workflowInfo = [ordered]@{}

            Write-Verbose "Setting values to the workflowInfo hashtable using input from the deployInfo file."

            # Set the value for the desired location to use for the subscription Bicep Parent deployments
            $workflowInfo.Add('subscriptionDeployLocation', $jsonObject.subscriptionDeployLocation)

            # Set the values used by the naming module to generate the correct naming convention
            $workflowInfo.Add('organizationCode', $organizationCode)
            $workflowInfo.Add('mgmtEnvironmentCode', $mgmtEnvironmentCode)
            $workflowInfo.Add('cntyEnvironmentCode', $cntyEnvironmentCode)
            $workflowInfo.Add('lndzEnvironmentCode', $lndzEnvironmentCode)
            $workflowInfo.Add('toolEnvironmentCode', $toolEnvironmentCode)

            $workflowInfo.Add('mgmtSubscriptionCode', $mgmtSubscriptionCode)
            $workflowInfo.Add('cntySubscriptionCode', $cntySubscriptionCode)
            $workflowInfo.Add('lndzSubscriptionCode', $lndzSubscriptionCode)
            $workflowInfo.Add('toolSubscriptionCode', $toolSubscriptionCode)

            # If this function is being executed on a GitHub runner use the environment variables to set the values
            # If not running on a GitHub runner set the values using the parameters.
            if ($Env:CI) {
                Write-Verbose "GitHub runner execution detected."
                $workflowInfo.Add('mgmtSubscriptionId', $Env:mgmtSubscriptionId)
                $workflowInfo.Add('cntySubscriptionId', $Env:cntySubscriptionId)
                $workflowInfo.Add('lndzSubscriptionId', $Env:lndzSubscriptionId)
                $workflowInfo.Add('toolSubscriptionId', $Env:toolSubscriptionId)
            }
            else {
                Write-Verbose "Function not being executed on GitHub runner."
                $workflowInfo.Add('mgmtSubscriptionId', $mgmtSubscriptionId)
                $workflowInfo.Add('cntySubscriptionId', $cntySubscriptionId)
                $workflowInfo.Add('lndzSubscriptionId', $lndzSubscriptionId)
                $workflowInfo.Add('toolSubscriptionId', $toolSubscriptionId)
            }

            # Set the values for the network & vmosmgmt Bicep parent modules
            $workflowInfo.Add('networkCntyTemplateParameterFile', $networkCntyTemplateParameterFile)
            $workflowInfo.Add('networkLndzTemplateParameterFile', $networkLndzTemplateParameterFile)
            $workflowInfo.Add('networkToolTemplateParameterFile', $networkToolTemplateParameterFile)
            $workflowInfo.Add('vWannetworkCntyTemplateParameterFile', $vWannetworkCntyTemplateParameterFile)
            $workflowInfo.Add('vWanNetworkLndzTemplateParameterFile', $vWannetworkLndzTemplateParameterFile)
            $workflowInfo.Add('vWannetworkToolTemplateParameterFile', $vWannetworkToolTemplateParameterFile)
            $workflowInfo.Add('vmOsMgmtMgmtTemplateParameterFile', $vmOsMgmtMgmtTemplateParameterFile)
            $workflowInfo.Add('vmOsMgmtLndzTemplateParameterFile', $vmOsMgmtLndzTemplateParameterFile)
            $workflowInfo.Add('vmOsMgmtToolTemplateParameterFile', $vmOsMgmtToolTemplateParameterFile)

            # Set the values for the costManagement Bicep parent modules
            $workflowInfo.Add('costManagementMgmtTemplateParameterFile', $costManagementMgmtTemplateParameterFile)
            $workflowInfo.Add('costManagementCntyTemplateParameterFile', $costManagementCntyTemplateParameterFile)
            $workflowInfo.Add('costManagementLndzTemplateParameterFile', $costManagementLndzTemplateParameterFile)

            Write-Verbose "Finished setting values to the workflowInfo hashtable."
        }
        else {
            Write-Error "The json file has not been loaded successfully. Exiting..." -ErrorAction 'Stop'
        }

        try {
            # If the $outputPath parameter is not empty, save the json file to a location on disk
            if (Test-Path -Path $outputPath) {
                $workflowInfoFilePath = Join-Path -Path $outputPath -ChildPath 'workflowInfo.json'
            }
            else {
                Write-Error "The designated outputPath: '$($outputPath)' does not exist. $($_.Exception.Message)" -ErrorAction 'Stop'
            }

            $workflowInfo | ConvertTo-Json | Out-File -FilePath $workflowInfoFilePath -Verbose
        }
        catch {
            Write-Error "Failed to save the workflowInfo file. $($_.Exception.Message)" -ErrorAction 'Stop'
        }
    }
    
    end {
        Write-Verbose "Finished processing workflowInfo successfully.."
        $workflowObject = New-Object PSObject -Property $workflowInfo
        Write-Output $workflowObject
    }
}