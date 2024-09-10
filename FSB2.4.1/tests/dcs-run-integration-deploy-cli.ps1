<#
.SYNOPSIS
    This runbook is called durint the Automatic Testing pipeline and is responsible to deploy some resources before the tests

.DESCRIPTION
    This runbook will deply some resources needed for the tests.
    This part is SPECIFIC to AZ CLI deployments
#>

param(
    [Parameter(Mandatory = $True)]
    [string] $buildRepositoryLocalPath,

    [Parameter(Mandatory = $True)]
    [string] $customerCode,
   
    [Parameter(Mandatory = $True)]
    [string] $tenantId,

    [Parameter(Mandatory = $True)]
    [string] $custMgmtSubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $custLndzSubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $tagPrefix,

    [Parameter(Mandatory = $True)]
    [string] $tagValuePrefix,

    [Parameter(Mandatory = $True)]
    [string] $company,

    [Parameter(Mandatory = $True)]
    [string] $product,

    [Parameter(Mandatory = $True)]
    [string] $productCode
)

###
### INIT
###

$ProjectRoot = $buildRepositoryLocalPath
$BicepModulesRoot = $buildRepositoryLocalPath + "/childModules"
If ((-Not($tenantId)) -or (-Not($custMgmtSubscriptionId)) -or (-Not($custLndzSubscriptionId))) {
    Throw("Error missing variable parameter in pipeline !")
}

###
### SCRIPT
###

# Resource group name
$ResourceGroupName = ($customerCode.ToLower() + "-lndz-d-rsg-integration-testing")

# Default name prefix for resources
$textInfo = (Get-Culture).TextInfo
$namePrefix = $textInfo.ToTitleCase($customerCode.ToLower().SubString(0,3)) + "Test"

az account set --subscription $custLndzSubscriptionId

$aksname = $namePrefix + "aks01"
$tag1 = "${tagPrefix}Managed=true"
$tag2 = "${tagPrefix}Testing=akscluster01"
az aks create --resource-group $resourceGroupName --name $aksname `
--node-count 1 --enable-managed-identity --location "North Europe" --generate-ssh-keys --tags $tag1 $tag2

