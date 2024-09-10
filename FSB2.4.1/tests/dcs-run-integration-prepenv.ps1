<#
.SYNOPSIS
    This runbook is called durint the Automatic Testing pipeline and is responsible to configure the environment before the tests

.DESCRIPTION
    This runbook is supposed to automate some manual configuration that needs to be done after the environment is deployed.
    Also, some specific configuration may be done here as a prerequisite for the tests.
#>

param(
    [Parameter(Mandatory = $True)]
    [string] $snowUsername,

    [Parameter(Mandatory = $True)]
    [string] $snowPassword,

    [Parameter(Mandatory = $True)]
    [string] $buildRepositoryLocalPath,

    [Parameter(Mandatory = $True)]
    [string] $customerCode,

    [Parameter(Mandatory = $True)]
    [string] $tenantId,

    [Parameter(Mandatory = $True)]
    [string] $custMgmtSubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $custCntySubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $custLndzSubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $custLndz2SubscriptionId,

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

$ProjectRoot = $buildRepositoryLocalPath # Check the correct path(could be "\dcs-azure-bicep\scripts\Test")
If ((-Not($tenantId)) -or (-Not($custMgmtSubscriptionId)) -or (-Not($custLndzSubscriptionId)) -or (-Not($custLndz2SubscriptionId))) {
    Throw("Error missing variable parameter in pipeline !")
}
Import-Module Pester
$modulePath = $ProjectRoot + '/tests/Eviden.AzureIntegrationTesting/Eviden.AzureIntegrationTesting.psm1'
Import-Module -Name $modulePath  -Force

###
### SCRIPT
###


# SET SNOW credentials in MGMT keyvault
Write-Host 'Check subs id value: ' + $custMgmtSubscriptionId
Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId

$mgmt_keyvault = Get-AzKeyVault -tag @{"${tagPrefix}Purpose" = "${tagValuePrefix}ITSM" } 
set-keyVaultAccessPolicyForPipelineAccount -KeyVaultName $mgmt_keyvault.Vaultname
Add-KeyvaultSecret -KeyVaultName $mgmt_keyvault.Vaultname -SecretName ("global-monitoring-snow-event-username-"+$snowEnv) -SecretValue $snowUsername
Add-KeyvaultSecret -KeyVaultName $mgmt_keyvault.Vaultname -SecretName ("global-monitoring-snow-event-password-"+$snowEnv) -SecretValue $snowPassword
Add-KeyvaultSecret -KeyVaultName $mgmt_keyvault.Vaultname -SecretName ("global-monitoring-snow-cmdb-username-"+$snowEnv) -SecretValue $snowUsername
Add-KeyvaultSecret -KeyVaultName $mgmt_keyvault.Vaultname -SecretName ("global-monitoring-snow-cmdb-password-"+$snowEnv) -SecretValue $snowPassword

# SET BILLING credentials in MGMT keyvault
Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
$mgmt_keyvault = Get-AzKeyVault -tag @{"${tagPrefix}Purpose" = "${tagValuePrefix}Billing"} 
$billing_name = "ELZ"+$customerCode+"TestCustomer"
$textInfo = (Get-Culture).TextInfo
$billing_name = $textInfo.ToTitleCase($billing_name)
set-keyVaultAccessPolicyForPipelineAccount -KeyVaultName $mgmt_keyvault.Vaultname
Add-KeyvaultSecret -KeyVaultName $mgmt_keyvault.Vaultname -SecretName "billing-customer-name" -SecretValue $billing_name
Remove-KeyvaultSecret -KeyVaultName $mgmt_keyvault.Vaultname -SecretName "billing-google-bucket-name"
Remove-KeyvaultSecret -KeyVaultName $mgmt_keyvault.Vaultname -SecretName "billing-google-bucket-key"

# Set SNOW ENV configuration on customer subscriptions
$tags  = @{
    "${tagPrefix}ITSMServiceNowEnvironment" = $snowEnv
    "${tagPrefix}ITSMServiceNowFO" = $snowFo
}
Update-AzTag -ResourceId ("/subscriptions/"+$custCntySubscriptionId) -Tag $tags -Operation merge | Out-Null
Update-AzTag -ResourceId ("/subscriptions/"+$custMgmtSubscriptionId) -Tag $tags -Operation merge | Out-Null
Update-AzTag -ResourceId ("/subscriptions/"+$custLndzSubscriptionId) -Tag $tags -Operation merge | Out-Null
Update-AzTag -ResourceId ("/subscriptions/"+$custLndz2SubscriptionId) -Tag $tags -Operation merge | Out-Null

# Modify the existing 'Windows-Dev' and 'Linux-Dev' update schedules to also install additonal updates.
# This ensures that at least some updates will be applied during the update-management tests.
$params = @{
  resourceType = "Microsoft.Automation/automationAccounts"
  tags         = @{"${tagPrefix}Purpose" = "${tagValuePrefix}VmOsManagementAutomation" }
}
$updateAutomationAccount = search-azureResourceByTag @params
$params = @{
  apiUrl      = $updateAutomationAccount.ResourceId + "/softwareUpdateConfigurations/Windows-Dev" + "?api-version=2019-06-01"
  apiMethod   = "GET"
}
$windowsSchedule = invoke-azureRestAPIDataRequest @params
$windowsSchedule.properties.updateConfiguration.windows.includedUpdateClassifications = 'Critical, Security, Updates, Definition, UpdateRollup, Tools, Unclassified'
$params = @{
  apiUrl      = $updateAutomationAccount.ResourceId + "/softwareUpdateConfigurations/Linux-Dev" + "?api-version=2019-06-01"
  apiMethod   = "GET"
}
$linuxSchedule = invoke-azureRestAPIDataRequest @params
$linuxSchedule.properties.updateConfiguration.linux.includedPackageClassifications = 'Critical, Security, Other, Unclassified'
$params = @{
  apiUrl      = $updateAutomationAccount.ResourceId + "/softwareUpdateConfigurations/Windows-Dev" + "?api-version=2019-06-01"
  apiMethod   = "PUT"
  bodyJson    = $windowsSchedule | ConvertTo-Json -depth 99
}
$data = invoke-azureRestAPIDataRequest @params
$params = @{
  apiUrl      = $updateAutomationAccount.ResourceId + "/softwareUpdateConfigurations/Linux-Dev" + "?api-version=2019-06-01"
  apiMethod   = "PUT"
  bodyJson    = $linuxSchedule | ConvertTo-Json -depth 99
}
$data = invoke-azureRestAPIDataRequest @params
