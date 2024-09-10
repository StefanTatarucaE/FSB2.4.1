function Publish-GithubEnvironmentVariables {
    <#
    .SYNOPSIS
        Publishes values from a json file to a GitHub Runner's environment variables.

    .DESCRIPTION
        The function in this script file loads a json file. 
        Using the values from the json file, pwsh variables are constructed, 
        which are then pushed into a GitHub Runner's environment variables.

        The GitHub Runner's environment variables are used throughout the workflow execution for deployments and conditions.

        The json file contains the following keys (with values);
        {
            "subscriptionDeployLocation": "",
            "githubEnvironmentCode": "",
            "organizationCode": "",
            "environmentCode": "",
            "mgmtSubscriptionCode":"",
            "runMgmtCore": "",
            "runMgmtNetwork": "",
            "runMgmtOsMgmt": "",
            "runMgmtPaas": "",
            "runIpGroupsPreReq": "",
            "runMgmtFinish": "",
            "deployVwan": "",
            "cntySubscriptionCode":"",
            "runCntyCore": "",
            "runCntyNetwork": "",
            "runCntyOsMgmt": "",
            "runCntyPaas": "",
            "runCntyFinish": "",
            "lndzSubscriptionCode":"",
            "runLndzCore": "",
            "runLndzNetwork": "",
            "runLndzOsMgmt": "",
            "runLndzPaas": "",
            "runLndzFinish": "",
            "toolSubscriptionCode":"",
            "runToolCore": "",
            "runToolNetwork": "",
            "runToolOsMgmt": "",
            "runToolPaas": "",
            "runToolFinish": ""
        }

        The "githubEnvironmentCode" and "xxxSubcriptionCode" keys are used to create environment variables which reference GitHub Secrets.
        GitHub Secret values are used to logon to the Azure Portal.

        The rest of the keys are used to determine if a specific workflow job should run or not during workflow execution.
        The following keys are used for the mgmt workflow jobs:
            "runMgmtCore" - corresponds to the core job. Value can be <'yes' or 'no'>
            "runMgmtNetwork" - corresponds to the network job. Value can be <'yes' or 'no'>
            "runMgmtOsMgmt"- corresponds to the osmgmt job. Value can be <'yes' or 'no'>
            "runMgmtPaas" - corresponds to the paas job. Value can be <'yes' or 'no'>
            "runMgmtFinish" - corresponds to the finish job. Value can be <'yes' or 'no'>
        
        The following keys are used for the cnty workflow jobs:
            "runCntyCore" - corresponds to the core job. Value can be <'yes' or 'no'>
            "runCntyNetwork" - corresponds to the network job. Value can be <'yes' or 'no'>
            "runCntyOsMgmt"- corresponds to the osmgmt job. Value can be <'yes' or 'no'>
            "runCntyPaas" - corresponds to the paas job. Value can be <'yes' or 'no'>
            "runCntyFinish" - corresponds to the finish job. Value can be <'yes' or 'no'>

        The following keys are used for the lndz workflow jobs:
            "runLndzCore" - corresponds to the core job. Value can be <'yes' or 'no'>
            "runLndzNetwork" - corresponds to the network job. Value can be <'yes' or 'no'>
            "runLndzOsMgmt"- corresponds to the osmgmt job. Value can be <'yes' or 'no'>
            "runLndzPaas" - corresponds to the paas job. Value can be <'yes' or 'no'>
            "runLndzFinish" - corresponds to the finish job. Value can be <'yes' or 'no'>

        The following keys are used for the tool workflow jobs:
            "runToolCore" - corresponds to the core job. Value can be <'yes' or 'no'>
            "runToolNetwork" - corresponds to the network job. Value can be <'yes' or 'no'>
            "runToolOsMgmt"- corresponds to the osmgmt job. Value can be <'yes' or 'no'>
            "runToolPaas" - corresponds to the paas job. Value can be <'yes' or 'no'>
            "runToolFinish" - corresponds to the finish job. Value can be <'yes' or 'no'>

        The following keys are NOT used in this pwsh function:
            "subscriptionDeployLocation"
            "organizationCode"
            "environmentCode"
            "mgmtSubscriptionCode" and/or "cntySubscriptionCode" and/or "lndzSubscriptionCode" and/or "toolSubscriptionCode"

        Dot source this file before being able to use the function in this file. 
        To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
        . .\Publish-GithubEnvironmentVariables.ps1

    .PARAMETER inputJson
        Specifies the path to the json file to be used for publishing of the GitHub Runner environment variables.

    .PARAMETER scope
        Specifies the scope of the GitHub Runner environment variables to publish. 
        Either publish just the Azure login related environment variables or all available ones.

    .PARAMETER subscriptionType
        Specifies which subscription type of the GitHub Runner environment variables to publish.

    .INPUTS
        Json file. Details described in the description section.

    .OUTPUTS
        None.

    .NOTES
        Version:        0.5
        Author:         frederic.trapet@eviden.com
        Creation Date:  20221001
        Purpose/Change: First version which is feature ready to use.
                        
    .EXAMPLE
        Publish-GithubEnvironmentVariables -inputJson './info.json' -scope 'login' -subscriptionType 'lndz'

        $params = @{
            inputJson        = './deployInfo.json'
            scope            = 'all'
            subscriptionType = 'mgmt'
            Verbose          = $true
        }
        Publish-GithubEnvironmentVariables @params
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'login',
            'all'
        )]
        [string]$scope,
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'mgmt',
            'cnty',
            'lndz',
            'tool'
        )]
        [string]$subscriptionType,
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$inputJson
    )
    
    begin {
        if (-not ([string]::IsNullOrEmpty($inputJson))) {

            # If the $inputJson parameter is not empty, load the json file in to an pwsh variable
            if (Test-Path -Path $inputJson) {
                $jsonObject = Get-Content -Path $inputJson -Raw | ConvertFrom-Json

                Write-Verbose "The json file has been succesfully loaded..."
                Write-Verbose "Load result: $jsonObject"
            }
            else {
                Write-Error "The json file cannot be found at the designated path. $($_.Exception.Message)" -ErrorAction 'Stop'
            }
        }
    }
    
    process {
        if ($jsonObject) {
            Write-Verbose "The json file is processed successfully, now initializing generic variables..."

            # Loading in json values from the values in to pwsh variables
            $githubEnvironmentCode = $jsonObject.githubEnvironmentCode

            $mgmtSubscriptionCode = $jsonObject.mgmtSubscriptionCode
            $cntySubscriptionCode = $jsonObject.cntySubscriptionCode
            $lndzSubscriptionCode = $jsonObject.lndzSubscriptionCode
            $toolSubscriptionCode = $jsonObject.toolSubscriptionCode

            # Constructing pwsh variables related to GitHub Secrets, 
            # which can be referenced to perform login actions on the Azure platform
            $clientSecret = -join ($githubEnvironmentCode, '_clientid')
            $tenantSecret = -join ($githubEnvironmentCode, '_tenantid')
            $mgmtSubscriptionSecret = -join ($githubEnvironmentCode, '_', $mgmtSubscriptionCode, '_subid')
            $cntySubscriptionSecret = -join ($githubEnvironmentCode, '_', $cntySubscriptionCode, '_subid')
            $lndzSubscriptionSecret = -join ($githubEnvironmentCode, '_', $lndzSubscriptionCode, '_subid')
            $toolSubscriptionSecret = -join ($githubEnvironmentCode, '_', $toolSubscriptionCode, '_subid')

            # Loading in json values from the values in to pwsh variables related to Workflow Jobs executions (if: <condition>)
            if ($subscriptionType -eq 'mgmt') {
                Write-Verbose "Initializing 'mgmt' job outputs variables..."
                $runCore = $jsonObject.runMgmtCore
                $runNetwork = $jsonObject.runMgmtNetwork
                $runOsMgmt = $jsonObject.runMgmtOsMgmt
                $runPaas = $jsonObject.runMgmtPaas
                $runFinish = $jsonObject.runMgmtFinish
                $deployVwan = $jsonObject.deployVwan
                $runIpGroupsPreReq = $jsonObject.runIpGroupsPreReq

            }
            elseif ($subscriptionType -eq 'cnty') {
                Write-Verbose "Initializing 'cnty' job outputs variables...."
                $runCore = $jsonObject.runCntyCore
                $runNetwork = $jsonObject.runCntyNetwork
                $runOsMgmt = $jsonObject.runCntyOsMgmt
                $runPaas = $jsonObject.runCntyPaas
                $runFinish = $jsonObject.runCntyFinish
                $deployVwan = $jsonObject.deployVwan
            }
            elseif ($subscriptionType -eq 'tool') {
                Write-Verbose "Initializing 'tool' job outputs variables...."
                $runCore = $jsonObject.runToolCore
                $runNetwork = $jsonObject.runToolNetwork
                $runOsMgmt = $jsonObject.runToolOsMgmt
                $runPaas = $jsonObject.runToolPaas
                $runFinish = $jsonObject.runToolFinish
                $deployVwan = $jsonObject.deployVwan
            }
            else {
                Write-Verbose "Initializing 'lndz' job outputs variables...."
                $runCore = $jsonObject.runLndzCore
                $runNetwork = $jsonObject.runLndzNetwork
                $runOsMgmt = $jsonObject.runLndzOsMgmt
                $runPaas = $jsonObject.runLndzPaas
                $runFinish = $jsonObject.runLndzFinish
                $deployVwan = $jsonObject.deployVwan
            }
        }
        else {
            Write-Error "The json file has not been loaded successfully. Exiting..." -ErrorAction 'Stop'
        }

        try {
            if ($scope -eq 'login') {
                # Publishing environment variables for login to the Azure platform
                # The "xxxxxSecret" variables contain values used to reference GitHub Secret
                Write-Verbose "Publishing general login environment variables.."
                "clientSecret=$clientSecret" >> $env:GITHUB_ENV
                "tenantSecret=$tenantSecret" >> $env:GITHUB_ENV

                if ($subscriptionType -eq 'mgmt') {
                    Write-Verbose "Publishing mgmt login environment variable.."
                    "subscriptionSecret=$mgmtSubscriptionSecret" >> $env:GITHUB_ENV
                }
                elseif ($subscriptionType -eq 'cnty') {
                    Write-Verbose "Publishing cnty login environment variable.."
                    "subscriptionSecret=$cntySubscriptionSecret" >> $env:GITHUB_ENV
                }
                elseif ($subscriptionType -eq 'lndz') {
                    Write-Verbose "Publishing lndz login environment variable.."
                    "subscriptionSecret=$lndzSubscriptionSecret" >> $env:GITHUB_ENV
                }
                elseif ($subscriptionType -eq 'tool') {
                    Write-Verbose "Publishing tool login environment variable.."
                    "subscriptionSecret=$toolSubscriptionSecret" >> $env:GITHUB_ENV
                }
                else {
                    Write-Error "No subscriptionType has been set, azlogin action will fail!"
                }
            }
            elseif ($scope -eq 'all') {
                Write-Verbose "Publishing general GitHub Runner environment variables.."

                # Publishing environment variables which determine if a specific workflow job will run or not
                # These Variables are then used as job outputs
                # The job output is what all of the rest of the workflow jobs use as conditions (to run or not)
                "runCore=$runCore" >> $env:GITHUB_OUTPUT
                "runNetwork=$runNetwork" >> $env:GITHUB_OUTPUT
                "runOsMgmt=$runOsMgmt" >> $env:GITHUB_OUTPUT
                "runPaas=$runPaas" >> $env:GITHUB_OUTPUT
                "runFinish=$runFinish" >> $env:GITHUB_OUTPUT
                "deployVwan=$deployVwan" >> $env:GITHUB_OUTPUT
                "runIpGroupsPreReq=$runIpGroupsPreReq" >> $env:GITHUB_OUTPUT

                # Publishing environment variables which contain the names of the GitHub Secrets for a specific environment
                "clientSecret=$clientSecret" >> $env:GITHUB_ENV
                "tenantSecret=$tenantSecret" >> $env:GITHUB_ENV

                # Publishing environment variables related to specific subscription types
                if ($subscriptionType -eq 'mgmt') {
                    Write-Verbose "Publishing 'mgmt' specific GitHub Runner environment variables.."
                    "subscriptionSecret=$mgmtSubscriptionSecret" >> $env:GITHUB_ENV
                    "mgmtSubscriptionSecret=$mgmtSubscriptionSecret" >> $env:GITHUB_ENV
                }
                elseif ($subscriptionType -eq 'cnty') {
                    Write-Verbose "Publishing 'cnty' specific GitHub Runner environment variables.."
                    "subscriptionSecret=$cntySubscriptionSecret" >> $env:GITHUB_ENV
                    "mgmtSubscriptionSecret=$mgmtSubscriptionSecret" >> $env:GITHUB_ENV
                    "cntySubscriptionSecret=$cntySubscriptionSecret" >> $env:GITHUB_ENV
                }
                elseif ($subscriptionType -eq 'lndz') {
                    Write-Verbose "Publishing 'lndz' specific GitHub Runner environment variables.."
                    "subscriptionSecret=$lndzSubscriptionSecret" >> $env:GITHUB_ENV
                    "mgmtSubscriptionSecret=$mgmtSubscriptionSecret" >> $env:GITHUB_ENV
                    "cntySubscriptionSecret=$cntySubscriptionSecret" >> $env:GITHUB_ENV
                    "lndzSubscriptionSecret=$lndzSubscriptionSecret" >> $env:GITHUB_ENV
                }
                elseif ($subscriptionType -eq 'tool') {
                    Write-Verbose "Publishing 'tool' specific GitHub Runner environment variables.."
                    "subscriptionSecret=$toolSubscriptionSecret" >> $env:GITHUB_ENV
                    "mgmtSubscriptionSecret=$mgmtSubscriptionSecret" >> $env:GITHUB_ENV
                    "cntySubscriptionSecret=$cntySubscriptionSecret" >> $env:GITHUB_ENV
                    "toolSubscriptionSecret=$toolSubscriptionSecret" >> $env:GITHUB_ENV
                }
                else {
                    Write-Error "No subscriptionType has been set, emvironment variables have not been set!"
                }
            }
            else {
                Write-Verbose "No scope selected, environment variables are not set.."
            }
        }
        catch {
            Write-Error "Failed to set the environment variables. $($_.Exception.Message)" -ErrorAction 'Stop'
        }
    }

    end {
        Write-Verbose "All GitHub Runner Environment variables, successfully pushed.."
    }
}