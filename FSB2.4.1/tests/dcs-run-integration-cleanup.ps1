<#
.SYNOPSIS
    This runbook is called during the Automatic Testing pipeline and is responsible to delete the resources deployed by looking at the specific tag.

.DESCRIPTION
    This runbook is called once per tests category, and will process all the tests under the folder "\tests\integration"
    The tests will be executed in the alphabetical order in the folder and the result file is generated 
    to be processed by the pipeline to display results.
#>


###
### INIT
###

$ProjectRoot = $env:BUILD_REPOSITORY_LOCALPATH 
If ((-Not($env:TENANT_ID)) -or (-Not($env:MGMT_SUBSCRIPTION_ID)) -or (-Not($env:CUST_LNDZ_SUBSCRIPTION_ID)) -or (-Not($env:CUST_LNDZ2_SUBSCRIPTION_ID))) {
    Throw("Error missing variable parameter in pipeline !")
}

Import-Module Pester
Import-Module -Name .\Eviden.AzureIntegrationTesting -Force
if (-not (Get-Module -Name Az.AlertsManagement)) {
    Install-Module -Name Az.AlertsManagement -Force
    Write-Host "Module Az.AlertsManagement Installed."
}
if (-not (Get-Module -Name Az.ResourceGraph)) {
    Install-Module -Name Az.ResourceGraph -Force
    Write-Host "Module Az.ResourceGraph Installed."
}

###
### SCRIPT
###

##  Delete resources on CNTY  


Select-CNTYSubscription
$resourcesCNTY = Get-AzResourceGroup  -Tag @{"${tagPrefix}Testing" = "true"}
$rsAzBackupCNTY = Get-AzResource -ResourceType "Microsoft.Compute/restorePointCollections" -Name "AzureBackup_Dev*TestVM*"
$RGPtColCNTY = $rsAzBackupCNTY.ResourceGroupName | Select-Object -First 1                           #Get the resource group of restorepointcollections


if($resourcesCNTY.ResourceGroupName -ne $null){
Remove-AzResourceGroup -Name $resourcesCNTY.ResourceGroupName -Force
Write-Host "Resource group with ${tagPrefix}Testing tag set to true has been deleted with all his related resources."
}else{
    Write-Host "There are no resource groups created with ${tagPrefix}Testing tag in CNTY Subscription."
}

if($RGPtColCNTY -ne $null){
    Remove-AzResourceGroup -Name $RGPtColCNTY -Force
    Write-Host "Restore point collection for related resources of CNTY has been deleted"
    }else{
        Write-Host "There are no restore point collections on resources that has been deployed on CNTY. No cleanup needed for Restore point collections on CNTY"
    }


##  Delete resources on MGMT  


Select-MGMTSubscription
$resourcesMGMT = Get-AzResourceGroup  -Tag @{"${tagPrefix}Testing" = "true"}
$rsAzBackupMGMT = Get-AzResource -ResourceType "Microsoft.Compute/restorePointCollections" -Name "AzureBackup_Dev*TestVM*"
$RGPtColMGMT = $rsAzBackupMGMT.ResourceGroupName | Select-Object -First 1                           #Get the resource group of restorepointcollections

if($resourcesMGMT.ResourceGroupName -ne $null){
Remove-AzResourceGroup -Name $resourcesMGMT.ResourceGroupName -Force
Remove-AzResourceGroup -Name $RGPtColMGMT -Force
Write-Host "Resource group with ${tagPrefix}Testing tag set to true has been deleted with all his related resources."
}else{
    Write-Host "There are no resource groups created with ${tagPrefix}Testing tag in MGMT Subscription."
}

if($RGPtColMGMT -ne $null){
    Remove-AzResourceGroup -Name $RGPtColMGMT -Force
    Write-Host "Restore point collection for related resources of MGMT has been deleted"
    }else{
        Write-Host "There are no restore point collections on resources that has been deployed on MGMT. No cleanup needed for Restore point collections on MGMT"
    }



##  Delete resources on LNDZ  


Select-LNDZSubscription
$resourcesLNDZ = Get-AzResourceGroup  -Tag @{"${tagPrefix}Testing" = "true"}
$rsAzBackupLNDZ = Get-AzResource -ResourceType "Microsoft.Compute/restorePointCollections" -Name "AzureBackup_Dev*TestVM*"
$RGPtColLNDZ = $rsAzBackupLNDZ.ResourceGroupName | Select-Object -First 1                           #Get the resource group of restorepointcollections


if($resourcesLNDZ.ResourceGroupName -ne $null){
Remove-AzResourceGroup -Name $resourcesLNDZ.ResourceGroupName -Force
Write-Host "Resource group with ${tagPrefix}Testing tag set to true has been deleted with all his related resources."
}else{
    Write-Host "There are no resource groups created with ${tagPrefix}Testing tag in LNDZ Subscription."
}

if($RGPtColLNDZ -ne $null){
    Remove-AzResourceGroup -Name $RGPtColLNDZ -Force
    Write-Host "Restore point collection for related resources of LNDZ has been deleted"
    }else{
        Write-Host "There are no restore point collections on resources that has been deployed on LNDZ. No cleanup needed for Restore point collections on LNDZ"
    }


##  Delete resources on LNDZ2  


Select-LNDZ2Subscription
$resourcesLNDZ2 = Get-AzResourceGroup  -Tag @{"${tagPrefix}Testing" = "true"}
$rsAzBackupLNDZ2 = Get-AzResource -ResourceType "Microsoft.Compute/restorePointCollections" -Name "AzureBackup_Dev*TestVM*"
$RGPtColLNDZ2 = $rsAzBackupLNDZ2.ResourceGroupName | Select-Object -First 1                          #Get the resource group of restorepointcollections



if($resourcesLNDZ2.ResourceGroupName -ne $null){
Remove-AzResourceGroup -Name $resourcesLNDZ2.ResourceGroupName -Force
Write-Host "Resource group with ${tagPrefix}Testing tag set to true has been deleted with all his related resources."
}else{
    Write-Host "There are no resource groups created with ${tagPrefix}Testing tag in LNDZ2 Subscription."
}

if($RGPtColLNDZ2 -ne $null){
    Remove-AzResourceGroup -Name $RGPtColLNDZ2 -Force
    Write-Host "Restore point collection for related resources of LNDZ2 has been deleted"
    }else{
        Write-Host "There are no restore point collections on resources that has been deployed on LNDZ2. No cleanup needed for Restore point collections on LNDZ2"
    }
