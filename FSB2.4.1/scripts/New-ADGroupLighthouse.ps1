<#
.SYNOPSIS
    Generate Json parameter file for lighthouse delegation

.DESCRIPTION
    This script will create the required Azure AD Groups necessary for lighthouse delegation and will generate the Json parameter file.
    Parameter file will be used for bicep module 'azureLighthouse'

    Before running this script you need to connect on MSP subscription with Powershell and AzureCLI
    Connect-AzAccount
    az login
    Make sure for both you are connected on MSP Subscription

.PARAMETER $customerCode
    Specifies the Customer code which will be deployed (3 letter code)

.PARAMETER $environmentCode
    Specifies the Environment code (d,t,a,p)

.PARAMETER $approverGroupRequired
    Specifies if approval group is required for PIM delegation (true, false)

.PARAMETER $mspTenantId
    Specifies the MSP Tenand ID

.PARAMETER $justInTimeDuration
    Specifies the maximum duration allowed for PIM Request
    Default value is 8 hours (maximum). Not required if approval group is not required.

.PARAMETER $companyName
    Specifies the company name that will be used in the displaynames.

.PARAMETER $product
    Specifies the full poduct name that will be used in the MSP Offer descriptions.

.OUTPUTS
    Json file stored locally in the session location

.NOTES
    Version:        0.1
    Author:         bart.decker@eviden.com
    Creation Date:  20220811

.EXAMPLE
    .\New-ADGroupLighthouse.ps1 -companyName "Company" -product "Full product name" -customerCode 'abc' -environmentCode 'd' -approverGroupRequired 'true' -mspTenantId 'xxxxxx-xxxxx-xxxxxx-xxxxxx-xxxxx' -justInTimeDuration 'PT8H'

#>

param(
    [Parameter(Mandatory = $True)]
    [string]$customerCode,
    [Parameter(Mandatory = $True)]
    [string]$environmentCode,
    [Parameter(Mandatory = $True)]
    [ValidateSet("true","false")]
    [string]$approverGroupRequired,
    [Parameter(Mandatory = $True)]
    [string]$mspTenantId,
    [Parameter(Mandatory = $False)]
    [string]$justInTimeDuration = 'PT8H',
    [Parameter(Mandatory = $True)]
    [string]$companyName,
    [Parameter(Mandatory = $True)]
    [string]$product
)

$adminGroupName = 'delg-lighthouse-' + $customerCode + '-' + $environmentCode + '-Contributor'
$readerGroupName = 'delg-lighthouse-' + $customerCode + '-' + $environmentCode + '-Reader'
$approverGroupName = 'delg-lighthouse-' + $customerCode + '-' + $environmentCode + '-Approver'

$createdAdminGroup = az ad group list --display-name $adminGroupName | Out-String | ConvertFrom-Json
if (!$createdAdminGroup) {
    az ad group create --display-name $adminGroupName --mail-nickname $adminGroupName
    sleep 10
    $createdAdminGroup = az ad group list --display-name $adminGroupName | Out-String | ConvertFrom-Json
    sleep 5
    Write-Output 'Group '$createdAdminGroup.displayname' was created!'
}
else {
    Write-Output 'Group '$createdAdminGroup.displayname' already exists'
}


$createdReaderGroup = az ad group list --display-name $readerGroupName | Out-String | ConvertFrom-Json
if (!$createdReaderGroup) {
    az ad group create --display-name $readerGroupName --mail-nickname $readerGroupName 
    sleep 10
    $createdReaderGroup = az ad group list --display-name $readerGroupName | Out-String | ConvertFrom-Json
    sleep 5
    Write-Output 'Group '$createdAdminGroup.displayname' was created!'
}
else {
    Write-Output 'Group '$createdReaderGroup.displayname' already exists'
}

if ($approverGroupRequired -eq 'true') {
    $createdApproverGroup = az ad group list --display-name $approverGroupName | Out-String | ConvertFrom-Json
    if (!$createdApproverGroup) {
        az ad group create --display-name $approverGroupName --mail-nickname $approverGroupName 
        sleep 10
        $createdApproverGroup = az ad group list --display-name $approverGroupName | Out-String | ConvertFrom-Json
        sleep 5
        Write-Output 'Group '$createdApproverGroup.displayname' was created!'

    }
    else {
        Write-Output 'Group '$createdApproverGroup.displayname' already exists'
    }
    $approver_ouput = '
            {
            "principalId": "' + $createdApproverGroup.Id + '",
            "principalIdDisplayName": "' + $companyName + ' Approver Group"
            }
'
}
else {
    $approver_ouput = $null
}

$jsonOutput = '{
	"$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentParameters.json#",
	"contentVersion": "1.0.0.0",
	"parameters": {
		"mspOffer": {
			"value": "' + $product + ' - Managed Services"
		},
		"mspOfferDescription": {
			"value": "' + $product + ' - Managed Services Description"
		},
		"managedByTenantId": {
			"value": "'+ $mspTenantId + '"
		},
		"authorizations": {
			"value": [{
				"principalId": "'+ $createdReaderGroup.Id + '",
				"roleDefinitionId": "acdd72a7-3385-48ef-bd42-f606fba81ae7",
				"principalIdDisplayName": "' + $companyName + ' Readers ' + $customerCode + '"
			}]
		},'

$jsonOutput = $jsonOutput + '
"eligibleAuthorizations": {
    "value": [
        {
        "justInTimeAccessPolicy": {
            "multiFactorAuthProvider": "Azure",
            "maximumActivationDuration": "'+ $justInTimeDuration + '",
            "managedByTenantApprovers": ['+ $approver_ouput + ']
        },
        "principalId": "'+ $createdAdminGroup.Id + '",
        "principalIdDisplayName": "' + $companyName + ' Administrators ' + $customerCode + '",
        "roleDefinitionId": "b24988ac-6180-42a0-ab88-20f7382dd24c"
    },
    {
        "justInTimeAccessPolicy": {
            "multiFactorAuthProvider": "Azure",
            "maximumActivationDuration": "' + $justInTimeDuration + '",
            "managedByTenantApprovers": ['+ $approver_ouput + ']
        },
        "principalId": "' + $createdAdminGroup.Id + '",
        "principalIdDisplayName": "' + $companyName + ' Administrators ' + $customerCode + '",
        "roleDefinitionId": "36243c78-bf99-498c-9df9-86d9f8d28608"
    }]
}
}
}
'

$filename = 'lighthouse.params.json'
$jsonOutput | Out-File $filename
Write-Output 'File ' $filename ' was created'