<#
.SYNOPSIS
    Calls the parent module that deploys the resources needed in the MSP subscription. 
.DESCRIPTION
    This script calls the MSP parent module to deploy the resources needed for the optional MSP subscription.
    Developed as powershell script because the Azure Active Directory diagnostic settings deployment requires Global Administrator role credentials.

    Forwarding the Azure Active Directory logs to a Log Analytics Workspace with a greater retention period than what the activity log provides is important in an MSP
    and Azure Lighthouse context, the information may be required by customers for compliancy reasons, often with specific retention periods mandated by law.
    
    Automation of this deployment ensures that the Azure Active Directory log forwarding is always enabled.

.PARAMETER $mspTenantId
    Specified the tenant id of the MSP subscription

.PARAMETER $mspSubscriptionId
    Specifies the MSP subscription id

.PARAMETER $organizationCode
    Specifies the organization code used in resource naming template
    
.PARAMETER $subscriptionCode
    Specifies the code for the subscription

.PARAMETER $environmentCode
    Specifies the environment code used in resource naming template
    t=test, d=development, a=acceptance, p=production

.PARAMETER $deploymentLocation
    Specifies the location for deployment

.OUTPUTS
    N/A (the actual json file for naming is an output of Publish-AzResourceNames script.)

.NOTES
    Version:        0.1
    Author:         bart.decker@eviden.com
    Creation Date:  2022/10/5

.EXAMPLE

$params = @{
	mspTenantId = 'f7eb6e46-ed51-419d-9755-00b5a0fb5de4'
	mspSubscriptionId = '826ba1a1-f36d-415b-a9a4-42eb4299f3f0'
	organizationCode = 'ats'
	subscriptionCode = 'msp3'
	environmentCode = 'd'
	deploymentLocation = 'westus'
}

Deploy-MspSubscriptionComponents @params

#>

param(
    [Parameter(Mandatory = $True)]
    [ValidateNotNullorEmpty()]
    [string]$mspTenantId,
    
    [Parameter(Mandatory = $True)]
    [ValidateNotNullorEmpty()]
    [string]$mspSubscriptionId,
    
    [Parameter(Mandatory = $True)]
    [ValidateNotNullorEmpty()]
    [string]$organizationCode,

    [Parameter(Mandatory = $True)]
    [ValidateNotNullorEmpty()]
    [string]$subscriptionCode,

    [Parameter(Mandatory = $True)]
    [ValidateNotNullorEmpty()]
    [string]$environmentCode,
    
    [Parameter(Mandatory = $True)]
    [ValidateNotNullorEmpty()]
    [string]$deploymentLocation
 )

$context = Get-Azcontext
if (-not $context) {
    Write-Error -Message "Not connected to Azure!" -ErrorAction Stop
} 
if ($context.Tenant.Id -ne $mspTenantId) {
    Write-Error -Message "Connected to a different tenant!" -ErrorAction Stop
}
if ($context.Subscription.id -ne $mspSubscriptionId) {
    Set-AzContext -Subscriptionid $mspSubscriptionId -Verbose -ErrorAction Stop
}

#The following variables are valid if this script is run in "<Repository root>\Scripts" folder.

[string]$namingBicepTemplatePath = '..\helperModules\naming\'
[string]$namingOutputPath = '..\'
[string]$namingGenerationScript = '.\Publish-AzResourceNames.ps1'
[string]$templateFile = '..\parentModules\msp\msp.bicep'
[string]$templateParameterFile = '..\parentModules\msp\msp.parameters.json' #to be moved to input folder?
[string]$subscriptionType = 'msp' #should not be changed, required for validation in Publish-AzResourceNames.ps1 script

if (-not(Test-Path -Path $namingBicepTemplatePath)) {
    Write-Error "Naming generation template path is incorrect." -ErrorAction Stop
}

if (-not(Test-Path -Path $namingOutputPath)) {
    Write-Error "Output path for naming generation is incorrect." -ErrorAction Stop
}

if (-not(Test-Path -Path $namingGenerationScript)) {
    Write-Error "Naming generation script path incorrect." -ErrorAction Stop
}

if (-not(Test-Path -Path $templateFile)) {
    Write-Error "Parent module template file not found in the specified location." -ErrorAction Stop
}

if (-not(Test-Path -Path $templateParameterFile)) {
    Write-Error "Parent module parameters file not found in the specified location." -ErrorAction Stop
}

. $namingGenerationScript

$params = @{
    bicepTemplatePath   = $namingBicepTemplatePath
    outputPath          = $namingOutputPath
    azRegion            = $deploymentLocation
    organizationCode    = $organizationCode
    subscriptionCode    = $subscriptionCode
    environmentCode     = $environmentCode
    subscriptionType    = $subscriptionType
}
Publish-AzResourceNames @params

try {
    Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like '*tmp-naming-rsg-deleteme'} | Remove-AzResourceGroup -Verbose -Force -ErrorAction SilentlyContinue #cleanup temporary naming resource group

    $deploymentName = -join ('msp-',(new-guid).Guid.Substring(0, 5),'-deployment')

    New-AzDeployment -Location $deploymentLocation -Name $deploymentName -TemplateFile $templateFile -TemplateParameterFile $templateParameterFile -Verbose
}
catch {
    Write-Error "MSP deployment failed. $($_.Exception.Message)" -ErrorAction Stop
}