<#
.SYNOPSIS
This script is prerequisites for tag conversions process.

It perform below steps :

    1.Installs required PS module. -> Install-Module ImportExcel -AllowClobber -Force # Export excel file at last step.
    2.Get the naming module and downloads naming files.
    3.Remove 2 alerts.
    4.Remove 'Atos.RunbookAutomation' automation module.
    5.Disable 2 Logic Apps.
    6.Stop 2 function apps.
    7.Disable VM Encryption runbook webhook.
    8.Remove all diagnostic policy assignments for all subscriptions.

.DESCRIPTION

.PARAMETER $customerTenantId
    Specified the customer's tenant id

.PARAMETER $inputfilePath
    Specifies the input json file path '.\Tag-Conversion-Input.json'

.OUTPUTS
    Log file at same location 'PrerequisitesLogFile-$($tenantID).txt'

.NOTES
    Version:        0.1
    Author:         abhijit.kakade@eviden.com
    Creation Date:  2023/9/15

.EXAMPLE
$params = @{
	tenantID = 'bc57f51a-6d93-46ac-ae9c-c2a2840d090e'
    mgmtSubscriptionId = 'wqe23234-dc03-4329-bbfwre423wef2'
    inputfilePath = '.\Tag-Conversion-Input.json'
}

Prerequisites-Tag-Conversion.ps1 @params
#>

param (
    [Parameter(Mandatory = $True)]
    [string]$tenantID,

    [Parameter(Mandatory = $True)]
    [string]$mgmtSubscriptionId,

    [Parameter(Mandatory = $False)]
    [string]$inputfilePath
)

function WriteOutput {
    param (

        [Parameter(Mandatory = $True)]
        $outputText,

        [Parameter(Mandatory = $False)]
        [bool]
        $isObject = $False
    )
    $timestamp = Get-Date -Format "MM.dd.yyyy HH:mm"
    if ($isObject -eq $True) {
        Write-Output $outputText
        Add-Content -Path ".\PrerequisitesLogFile-$($tenantID).txt" -Value $outputText
    }
    else {
        Write-Output "$timestamp | $outputText"
        Add-Content -Path ".\PrerequisitesLogFile-$($tenantID).txt" -Value "$timestamp | $outputText"
    }
}

# Install Required modules
Install-Module ImportExcel -AllowClobber -Force # Export excel file at last step.

# Login into Azure tenant
$global:tenantID = $tenantID

#region AZ Login
try {
    $azConnect = Connect-AzAccount -tenantID $tenantID
    if (-not $azConnect) {
        WriteOutput "Login error: Logging into azure Failed..."
        Write-Error "Login error: Logging into azure Failed..." -ErrorAction 'Stop'
    }
    else {
        WriteOutput "Successfully logged into the Azure Platform."
    }
}
catch {
    throw $_.Exception
}
#endregion AZ Login

# Load JSON file
$inputJsonTagList = Get-Content -Path $inputfilePath -Raw | ConvertFrom-Json
WriteOutput "-------------------Input JSON File ----------------------------"
WriteOutput (ConvertTo-Json $inputJsonTagList ) -isobject $true
$Subscriptions = $inputJsonTagList.Subscriptions

WriteOutput $Subscriptions -isObject $true

Set-AzContext -SubscriptionId $mgmtSubscriptionId

# Generate Naming module
try {

    $tagPrefix = 'Atos'
    $tagValuePrefix = 'Atos'
    $subscriptionType = 'MGMT'
    $tagName = $tagPrefix + 'Purpose'
    $tagValue = $tagValuePrefix + 'Reporting'

    $spokeResourceGroup = Get-AzResourceGroup -Tag @{$($tagName) = $tagValue }
    $namingParams = $spokeResourceGroup.ResourceGroupName.Split("-")
    $organizationCode = $namingParams[0]
    $subscriptionCode = $namingParams[1]
    $environmentCode = $namingParams[2]
    $deploymentLocation = $spokeResourceGroup.Location

    $namingBicepTemplatePath = '..\..\helperModules\naming\'
    $namingOutputPath = '.\'
    $namingGenerationScript = '..\..\scripts\Publish-AzResourceNames.ps1'

    . $namingGenerationScript

    $params = @{
        bicepTemplatePath = $namingBicepTemplatePath
        outputPath        = $namingOutputPath
        azRegion          = $deploymentLocation
        organizationCode  = $organizationCode
        subscriptionCode  = $subscriptionCode
        environmentCode   = $environmentCode
        subscriptionType  = $subscriptionType
    }
    Publish-AzResourceNames @params
    $mgmtnamingfilelath = $namingOutputPath + 'mgmtNaming.json'
    $inputNamingModule = Get-Content -Path $mgmtnamingfilelath -Raw | ConvertFrom-Json

}
catch {

    WriteOutput "Error - Naming module | Download artifacts failed. Try again.."
    WriteOutput $_ -isObject $True
    exit
}


WriteOutput "Removing Alerts."
# Remove Alerts
try {
    $alertList = $inputJsonTagList.Alerts
    $alertResourceGroup = $inputNamingModule.monitoringResourceGroup.name

    foreach ($alertRule in $alertList) {
        WriteOutput "Removing alert -> $alertRule"
        Remove-AzScheduledQueryRule -ResourceGroupName $alertResourceGroup -Name $alertRule
        WriteOutput "Alert Removed successfully : $alertRule"
    }
}
catch {
    WriteOutput "Error : Removing alert failed.."
    WriteOutput $_ -isObject $True
}

# Remove Atos.RunbookAutomationModule
WriteOutput "Removing Atos.RunbookAutomation Module."
try {
    $automationAccountResourceGroupName = $inputNamingModule.customerAutomationResourceGroup.name
    $automationAccountName = $inputNamingModule.customerAutomationAccount.name
    $automationModuleName = "Atos.RunbookAutomation"

    WriteOutput "Automation Account Resource Group -> $automationAccountResourceGroupName"
    WriteOutput "Automation Account Name -> $automationAccountName"

    $isAutomationModuleAvailable = Get-AzAutomationModule -Name $automationModuleName -ResourceGroupName $automationAccountResourceGroupName -AutomationAccountName $automationAccountName
    if ($null -ne $isAutomationModuleAvailable) {

        if (Remove-AzAutomationModule -Name $automationModuleName -ResourceGroupName $automationAccountResourceGroupName -AutomationAccountName $automationAccountName -Force) {
            WriteOutput "Automation Module $automationModuleName removed successfully"
        }
        else {
            WriteOutput "Error : Automation Module $automationModuleName not found. try again..."
        }
    }
    else {
        WriteOutput "'$automationModuleName' module not found in Automation account $automationAccountName"
    }
}
catch {
    WriteOutput "Error : Removing Atos.RunbookAutomation module failed"
    WriteOutput $_ -isObject $True
}


# Stop Logic Apps
WriteOutput "Disabling Logic apps.."
try {

    #CMDB Logic Apps
    $CMDBLogiAppName = $inputNamingModule.customerItsmLogicAppCmdb.name
    $CMDBLogiAppResoruceGroup = $inputNamingModule.managementItsmResourceGroup.name

    #Alert Logic Apps
    $AlertLogicAppName = $inputNamingModule.customerItsmLogicAppAlerts.name
    $AlertLogicAppResourceGroupName = $inputNamingModule.managementItsmResourceGroup.name

    try {
        WriteOutput "Disabling Logic app - $CMDBLogiAppName from Resource group - $CMDBLogiAppResoruceGroup"
        Set-AzLogicApp -ResourceGroupName $CMDBLogiAppResoruceGroup -Name $CMDBLogiAppName -State Disabled -Force
        WriteOutput "Sucessfully disabled Logic app - $CMDBLogiAppName"
    }
    catch {
        WriteOutput "Error : Disabling Logic app failed."
        WriteOutput $_ -isObject $True
    }

    try {
        WriteOutput "Disabling Logic app - $AlertLogicAppName from Resource group - $AlertLogicAppResourceGroupName"
        Set-AzLogicApp -ResourceGroupName $AlertLogicAppResourceGroupName -Name $AlertLogicAppName -State Disabled -Force
        WriteOutput "Sucessfully disabled Logic app - $AlertLogicAppResourceGroupName"
    }
    catch {
        WriteOutput "Error : Disabling Logic app failed - $AlertLogicAppName"
        WriteOutput $_ -isObject $True
    }

}
catch {
    WriteOutput "Error : Disabling Logic app failed."
    WriteOutput $_ -isObject $True
}

# Stop function Apps
WriteOutput "Stopping function apps.."
try {

    $ITSMFunctionAppName = $inputNamingModule.customerItsmPwshFunctionApp.Name
    $ITSMFunctionAppResourceGroup = $inputNamingModule.managementItsmResourceGroup.Name

    $OSTaggingFunctionAppName = $inputNamingModule.osTaggingFuncApp.name
    $OSTaggingFunctionAppResourceGroup = $inputNamingModule.osTaggingResourceGroup.name

    try {
        WriteOutput "Stoping Function app - $ITSMFunctionAppName from Resource group -> $ITSMFunctionAppResourceGroup"
        Stop-AzFunctionApp -ResourceGroupName $ITSMFunctionAppResourceGroup -Name $ITSMFunctionAppName -Force
        WriteOutput "Sucessfully Stopped function apps - $ITSMFunctionAppName"
    }
    catch {
        WriteOutput "Error : Disabling function app failed.. Try again"
        WriteOutput $_ -isObject $True
    }

    try {
        WriteOutput "Stoping Function app - $OSTaggingFunctionAppName from $OSTaggingFunctionAppResourceGroup"
        Stop-AzFunctionApp -ResourceGroupName $OSTaggingFunctionAppResourceGroup -Name $OSTaggingFunctionAppName -Force
        WriteOutput "Sucessfully Stopped function apps - $OSTaggingFunctionAppName"
    }
    catch {
        WriteOutput "Error : Stoping function app failed.. Try again"
        WriteOutput $_ -isObject $True
    }
}
catch {
    WriteOutput "Error : Stoping function app failed.. Try again"
    WriteOutput $_ -isObject $True
}

# Remove blobs
try {

    $reportingStorageAccountResourceGroup = $inputNamingModule.mgmtReportingResourceGroup.name
    $reportingStorageAccountName = $inputNamingModule.managementReportingStorageAccount.name
    $StorageContainerName = "artifacts"

    WriteOutput "Storage Account Resource Group - $reportingStorageAccountResourceGroup"
    WriteOutput "Storage Account Name - $reportingStorageAccountName"
    WriteOutput "Removing Blobs from reporting artifacts"
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $reportingStorageAccountResourceGroup -Name $reportingStorageAccountName
    $storageContext = $storageAccount.Context
    $listOfBlobs = Get-AzStorageBlob -Container $StorageContainerName -Context $storageContext

    foreach ($blob In $listOfBlobs) {

        if ($blob.Name.StartsWith('Eviden') -eq $False ) {
            Get-AzStorageBlob -Blob $blob.name  -Container 'artifacts' -Context $storageContext | Remove-AzStorageBlob
            WriteOutput "Removed Blob - $($blob.name) as Name dont contains / start with 'Eviden'."
        }
    }
}
catch {
    WriteOutput "Error : Removing blob failed.. Try again"
    WriteOutput $_ -isObject $True
}

# Disable webhook of Encryption
try {

    $automationAccountResourceGroupName = $inputNamingModule.customerAutomationResourceGroup.name
    $automationAccountName = $inputNamingModule.customerAutomationAccount.name

    WriteOutput "Automation Account Resource Group Name -> $automationAccountResourceGroupName"
    WriteOutput "Automation Account Name -> $automationAccountName"

    $rbunbooks = Get-AzAutomationRunbook -AutomationAccountName $automationAccountName -ResourceGroupName $automationAccountResourceGroupName
    $encryptionRunbook = $rbunbooks | Where-Object { $_.Name -match 'encryption' }
    WriteOutput "Encryption Runbook Name -> $($encryptionRunbook.Name)"
    $webhooks = Get-AzAutomationWebhook -RunbookName $encryptionRunbook.Name -ResourceGroupName $encryptionRunbook.ResourceGroupName -AutomationAccountName $encryptionRunbook.AutomationAccountName

    # Disable webhook
    foreach ($webhook in $webhooks) {
        WriteOutput "Webhook Name - $($webhook.Name)"
        Set-AzAutomationWebhook -Name $webhook.Name -IsEnabled $false -ResourceGroupName $webhook.ResourceGroupName -AutomationAccountName $webhook.AutomationAccountName
        WriteOutput "Disabled webhook - $($webhook.Name) of Runbook $($webhook.AutomationAccountName)"
    }
}
catch {
    WriteOutput "Error : Disabling webhook failed.. Try again"
    WriteOutput $_ -isObject $True
}

# Remove all 4 Diagnostic policy assignments for all subscriptions
try {
    #Looping through each and every subscription
    foreach ($sub in $Subscriptions) {

        WriteOutput "Looking policy assignment at Subscription - $($sub.SubscriptionName)"
        # Set Context for selected subscription
        $null = Get-AzSubscription -SubscriptionName $sub.SubscriptionName -TenantId $tenantID | Set-AzContext
        $policyAssignmentList = Get-AzPolicyAssignment | Select-Object ResourceId -ExpandProperty properties | Select-Object -Property Scope, PolicyDefinitionID, DisplayName, ResourceID | Where-Object { $_.DisplayName -match 'Diagnostic settings change' }

        foreach ($PolicyAssignment in $policyAssignmentList) {
            try {
                WriteOutput "Policy Assignment ID - $($PolicyAssignment.DisplayName)."
                Remove-AzPolicyAssignment -Id $PolicyAssignment.ResourceId -Confirm:$false
                WriteOutput "Successfully removed policy assignment."
            }
            catch {
                WriteOutput "Error - Failed to Remove Diagnostic policy assignment $($PolicyAssignment.DisplayName)"
                WriteOutput $_ -isObject $True
            }
        }
    }
}
catch {
    WriteOutput "Error - Fetching diagnostic policy assignment failed.."
    WriteOutput $_ -isObject $True
}
