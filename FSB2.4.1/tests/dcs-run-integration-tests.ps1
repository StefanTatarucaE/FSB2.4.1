<#
.SYNOPSIS
    This runbook is called durint the Automatic Testing pipeline and is responsible to run the integration tests

.DESCRIPTION
    This runbook is called once per tests category, and will process all the tests under the folder "\tests\integration"
    The tests will be executed in the alphabetical order in the folder and the result file is generated 
    to be processed by the pipeline to display results.
#>

param(
    [Parameter(Mandatory = $True)]
    [ValidateSet('core', 'os-mgmt', 'paas-mgmt', 'smoke', 'regressionsuite', 'regressionsuite/TC#6-BillingSolution')]
    [string] $Target,

    [Parameter(Mandatory = $True)]
    $Tests,

    [Parameter(Mandatory = $True)]
    [string] $buildRepositoryLocalPath,

    [Parameter(Mandatory = $True)]
    [string] $custMgmtSubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $custCntySubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $custLndzSubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $custLndz2SubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $tenantId,

    [Parameter(Mandatory = $True)]
    [string] $organizationCode,

    [Parameter(Mandatory = $True)]
    [string] $mgmtEnvironmentCode,

    [Parameter(Mandatory = $True)]
    [string] $snowUsername,

    [Parameter(Mandatory = $True)]
    [string] $snowPassword,

    [Parameter(Mandatory = $True)]
    [string] $snowEnv,

    [Parameter(Mandatory = $True)]
    [string] $snowFo,

    [Parameter(Mandatory = $True)]
    [string] $company,

    [Parameter(Mandatory = $True)]
    [string] $product,

    [Parameter(Mandatory = $True)]
    [string] $productCode,

    [Parameter(Mandatory = $True)]
    [string] $tagPrefix,

    [Parameter(Mandatory = $True)]
    [string] $tagValuePrefix
)

###
### INIT
###

$ProjectRoot = $buildRepositoryLocalPath
$TestFolderPath = $ProjectRoot + '/tests/integration'
If ((-Not($tenantId)) -or (-Not($custMgmtSubscriptionId)) -or (-Not($custLndzSubscriptionId)) -or (-Not($custLndz2SubscriptionId))) {
    Throw("Error missing variable parameter in pipeline !")
}

# Install-Module -Name Az.Accounts -MinimumVersion 2.7.6 -Force -Scope AllUsers -AllowClobber

Import-Module Pester
$modulePath = $ProjectRoot + '/tests/Eviden.AzureIntegrationTesting/Eviden.AzureIntegrationTesting.psm1'
Import-Module -Name $modulePath  -Force

$requiredModules = @("Az.AlertsManagement")
$requiredModules += "Az.ResourceGraph"
foreach ($module in $requiredModules) {
    if (-not (Get-Module -Name $module)) {
        Install-Module -Name $module -Force
        Write-Host "Module $module Installed."
    }
}


###
### SCRIPT
###


# Init Pester config
$config = [PesterConfiguration]::Default
$config.TestResult.Enabled = $true
#$config.TestResult.OutputFormat = "NUnitXml"
$config.TestResult.OutputFormat = "JUnitXml"
#$testFolder = $TestFolderPath+"/"+$Target.ToLower()+"/"
$testFolder = $TestFolderPath+"/"+$Target+"/"
$config.TestResult.OutputPath = $TestFolderPath+"/ELZ-TESTS-Results-"+$Target+".xml"
Write-Output ("Test results output path is: ["+$config.TestResult.OutputPath+"]")
$config.Output.Verbosity = "Detailed"
$config.Run.Path = $testFolder
$config.Filter.FullName = $Tests

Write-Output ("##[command]Running Pester on path: ["+$testFolder+"]")
Invoke-Pester -Configuration $config
