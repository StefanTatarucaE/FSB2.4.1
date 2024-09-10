<#
.SYNOPSIS
    Deploys the required components for storage accounts key management with key vaults.
    Prerequisites:
    - Eviden Langingzones for Azure solution 2.1 or later deployed
    - Landing zone subscription with the ELZ core part deployed.
    - Local up to date repository

    The script will first check the management subscription for:
    - existence of the runbook that does the keyvault management configuration and the runbook schedule
    - existence of the remediation runbook for the storage accounts role assignment policy and its schedule
    If not found the runbooks will be uploaded and published to the management automation account

    The specified landing zone subscription will be checked for the virtual network resource group. If found, the parameters for the naming module will be extracted from the resource group name using the standard ELZ naming convention split.
    If the customer uses his own naming convention the part of the script that retrieves the parameters for the naming module must be adapted.

    The landing zone deployment part creates a key vault resource in a new resource group and a DINE policy that assigns the Storage account key management role to the microsoft key vault enterprise application defined at tenant level.

.DESCRIPTION

.PARAMETER $customerTenantId
    Specified the customer's tenant id

.PARAMETER $managementSubscriptionId
    Specifies the Management subscription id

.PARAMETER $deploymentSubscriptionId
    Specifies the id for the subscription where the key vault key management solution will be deployed.

.PARAMETER $tagPrefix
    Specifies the prefix for the company name that will be used in the tag name part

.PARAMETER $tagValuePrefix
    Specifies the prefix for the company name that will be used in the tag value part


.OUTPUTS
    N/A (the actual json file for naming is an output of Publish-AzResourceNames script.)

.NOTES
    Version:        0.1
    Author:         bart.decker@eviden.com
    Creation Date:  2023/2/28

.EXAMPLE

$params = @{
	customerTenantId = 'bc57f51a-6d93-46ac-ae9c-c2a2840d090e'
    tagPrefix = 'Eviden'
    tagValuePrefix = 'Eviden'
    managementSubscriptionId = '3e3ae977-9abe-4702-8132-b41d3107928b'
	deploymentSubscriptionId = '5e694f2a-d353-4bad-abe7-2ed4ee34bbb6'
	keyRotationInterval = 90
	scheduleTimeZone = 'W. Europe Standard Time'
	scheduleTime = '15:00'
}

Deploy-StorageAccountKeyManagement.ps1 @params

#>

param(
    [Parameter(Mandatory = $True)]
    [ValidateNotNullorEmpty()]
    [string]$customerTenantId,

    [Parameter(Mandatory = $True)]
    [ValidateNotNullorEmpty()]
    [string]$managementSubscriptionId,

    [Parameter(Mandatory = $True)]
    [ValidateNotNullorEmpty()]
    [string]$deploymentSubscriptionId,

    [Parameter(Mandatory = $False)]
    [ValidateNotNullorEmpty()]
    [string]$scheduleTimeZone,

    [Parameter(Mandatory = $False)]
    [ValidateNotNullorEmpty()]
    [string]$scheduleTime,

    [Parameter(Mandatory = $False)]
    [ValidateNotNullorEmpty()]
    [ValidateRange(15, 365)]
    [System.Int16]$keyRotationInterval,

    [Parameter(Mandatory = $False)]
    [ValidateNotNullorEmpty()]
    [string]$keyVaultAppObjectId,

    [Parameter(Mandatory = $True)]
    [string]$tagPrefix,

    [Parameter(Mandatory = $True)]
    [string]$tagValuePrefix
)

$VerbosePreference = 'Continue'

$context = Get-Azcontext
if (-not $context) {
    Write-Error -Message "Not connected to Azure!" -ErrorAction Stop
} 
if ($context.Tenant.Id -ne $customerTenantId) {
    Write-Error -Message "Connected to a different tenant!" -ErrorAction Stop
}

if (-not $keyVaultAppObjectId) {
    $keyVaultAppObjectId = (Get-AzADServicePrincipal -ApplicationId "cfa8b339-82a2-471a-a3c9-0fc0be7a4093").id
}

if (-not $keyVaultAppObjectId) {
    Write-Error -Message "Cannot retrieve the Object Id of the Key Vault App! Please provide it as parameter." -ErrorAction Stop
}
else {
    Write-Verbose "Key Vault Application Object Id for tenant $customerTenantId is $keyVaultAppObjectId"
}

#The following variables are valid if this script is run in "<Repository root>\Scripts" folder.

$namingBicepTemplatePath = '..\helperModules\naming\'
$namingOutputPath = '..\'
$namingGenerationScript = '.\Publish-AzResourceNames.ps1'
$templateFile = '..\childModules\storagekeymanagement\storageAccountKeyManagement.bicep'
$runbooksPath = '..\artifacts\runbooks\'

#Runbook names
$keyManagementRunbookName = 'Set-StorageAccountKeyVaultManagement'
$policyRemediationRunbookName = 'Create-RemediationTaskStorageAccountRoleAssignment'

#Tags used in this script:

$tagName  = $tagPrefix + 'Purpose'
$tagValue = $tagValuePrefix + 'Automation'
$networkTagValue = $tagValuePrefix + 'NetworkingSpoke'

# Rubook schedule configuration options
if ($scheduleTimeZone) {
    $timeZones = Get-TimeZone -ListAvailable
    if ($scheduleTimeZone -notin $timeZones.id) {
        Write-Error "Provided time zone is incorrect, check available options with Get-TimeZone -ListAvailable." -ErrorAction Stop
    }
}
else {
    $scheduleTimeZone = 'W. Europe Standard Time'
}

if ($scheduleTime) {
    $date = Get-Date $scheduleTime
    if (-not $date) {
        Write-Error "Incorrect string provided for scheduleTime parameter, should be in the form 00:00" -ErrorAction Stop
    }
    $scheduleStartTime = ($date).AddDays(1) 
}
else {
    $scheduleStartTime = (Get-Date '18:00').AddDays(1)
}
$scheduleExpiryTime = $scheduleStartTime.AddYears(99)

if ($keyRotationInterval) {
    $keyRotationIntervalScheduleParameter = @{"KEYREGENERATIONPERIODINDAYS" = """$keyRotationInterval""" }
}
else {
    $keyRotationIntervalScheduleParameter = @{"KEYREGENERATIONPERIODINDAYS" = "90" }
}

$subscriptionType = 'lndz'

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

if (-not(Test-Path -Path "$runbooksPath$keyManagementRunbookName.ps1")) {
    Write-Error "Key Management Runbook not found in Artifacts\Runbooks folder." -ErrorAction Stop
}

if (-not(Test-Path -Path "$runbooksPath$policyRemediationRunbookName.ps1")) {
    Write-Error "Key Management Runbook not found in Artifacts\Runbooks folder." -ErrorAction Stop
}

try {
    # management subscription processing
    Set-AzContext -SubscriptionId $managementSubscriptionId -ErrorAction Stop
    $automationAccount = Get-AzAutomationAccount | Where-Object { $_.Tags[$tagName] -eq $tagValue }

    if (-not $automationAccount) {
        Write-error "ELZ Management Automation Account was not found" -ErrorAction Stop
    }
    else {
        Write-Verbose ("ELZ Automation account found: " + $automationAccount.AutomationAccountName)
    }
 
    $automationAccountIdentity = $automationAccount.Identity.PrincipalId

    $keyManagementRunbook = Get-AzAutomationRunbook -Name $keyManagementRunbookName -AutomationAccountName $automationAccount.AutomationAccountName -ResourceGroupName $automationAccount.ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $keyManagementRunbook) {
        Import-AzAutomationRunbook -Path "$runbooksPath$keyManagementRunbookName.ps1" -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName -Type PowerShell -ErrorAction Stop
        Publish-AzAutomationRunbook -Name $keyManagementRunbookName -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName -ErrorAction Stop
        Start-Sleep 5
    }
    else {
        Write-Verbose ("Key management runbook found: " + $keyManagementRunbook.Name)
    }
    write-Verbose ("Searching runbook schedule with name: $($keyManagementRunbookName) in resourcegroup $($ResourceGroupName)")
    # Waiting for schedule to be created before searching it.
    Start-Sleep -seconds 60 
    $keyManagementSchedule = Get-AzAutomationSchedule -Name $keyManagementRunbookName -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName -ErrorAction SilentlyContinue
    if (-not $keyManagementSchedule) {
        New-AzAutomationSchedule -AutomationAccountName $automationAccount.AutomationAccountName -Name $keyManagementRunbookName -StartTime $scheduleStartTime -ExpiryTime $scheduleExpiryTime -DayInterval 1 -TimeZone $scheduleTimeZone -ResourceGroupName $automationAccount.ResourceGroupName -ErrorAction Stop
        Register-AzAutomationScheduledRunbook -RunbookName $keyManagementRunbookName -ScheduleName $keyManagementRunbookName -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName
    }
    else {
        Write-Verbose ("Key management runbook schedule found: " + $keyManagementSchedule.Name)
    }

    $scheduleAssociation = Get-AzAutomationScheduledRunbook -RunbookName $keyManagementRunbookName -ScheduleName $keyManagementRunbookName -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName -ErrorAction SilentlyContinue
    if (-not $scheduleAssociation) {
        Register-AzAutomationScheduledRunbook -RunbookName $keyManagementRunbookName -Parameters $keyRotationIntervalScheduleParameter -ScheduleName $keyManagementRunbookName -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName -ErrorAction Stop
    }
    else {
        Write-Verbose ("Key management runbook associated with schedule: " + $scheduleAssociation.ScheduleName)
    }

    $policyRemediationRunbook = Get-AzAutomationRunbook -Name $policyRemediationRunbookName -AutomationAccountName $automationAccount.AutomationAccountName -ResourceGroupName $automationAccount.ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $policyRemediationRunbook) {
        Import-AzAutomationRunbook -Path "$runbooksPath$policyRemediationRunbookName.ps1" -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName -Type PowerShell -ErrorAction Stop
        Publish-AzAutomationRunbook -Name $policyRemediationRunbookName -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName -ErrorAction Stop
        Start-Sleep 5
    }
    else {
        Write-Verbose ("Policy Remediation runbook found: " + $policyRemediationRunbook.Name)
    }

    $policyRemediationSchedule = Get-AzAutomationSchedule -Name $policyRemediationRunbookName -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName -ErrorAction SilentlyContinue
    if (-not $policyRemediationSchedule) {
        $scheduleStartTime = (Get-Date $scheduleTime).AddDays(1).AddHours(-1)
        $scheduleExpiryTime = $scheduleStartTime.AddYears(99)
        New-AzAutomationSchedule -AutomationAccountName $automationAccount.AutomationAccountName -Name $policyRemediationRunbookName -StartTime $scheduleStartTime -ExpiryTime $scheduleExpiryTime -DayInterval 1 -TimeZone $scheduleTimeZone -ResourceGroupName $automationAccount.ResourceGroupName -ErrorAction Stop
        Register-AzAutomationScheduledRunbook -RunbookName $policyRemediationRunbookName -ScheduleName $policyRemediationRunbookName -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName
    }
    else {
        Write-Verbose ("Policy Remediation runbook schedule found: " + $policyRemediationSchedule.Name)
    }

    $scheduleAssociation = Get-AzAutomationScheduledRunbook -RunbookName $policyRemediationRunbookName -ScheduleName $policyRemediationRunbookName -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName -ErrorAction SilentlyContinue
    if (-not $scheduleAssociation) {
        Register-AzAutomationScheduledRunbook -RunbookName $policyRemediationRunbookName -ScheduleName $policyRemediationRunbookName -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName -ErrorAction Stop
    }
    else {
        Write-Verbose ("Policy Remediation runbook associated with schedule: " + $scheduleAssociation.ScheduleName)
    }

    #Landing zone processing

    Set-AzContext -SubscriptionId $deploymentSubscriptionId -ErrorAction Stop

    $spokeResourceGroup = Get-AzResourceGroup -Tag @{$($tagName) = $networkTagValue }
    if (-not $spokeResourceGroup) {
        Write-Error "Spoke Virtual Network Resoure Group not found!" -ErrorAction Stop
    }

    Write-Verbose ("Spoke resource group found: " + $spokeResourceGroup.ResourceGroupName)

    <#
    .NOTES
    The variables obtained using array indexes and the validation below must be adapted accordingly if a non standard ELZ naming convention was used for the landing zone onboarding.
    #>
    $namingParams = $spokeResourceGroup.ResourceGroupName.Split("-")
    $organizationCode = $namingParams[0]
    $subscriptionCode = $namingParams[1]
    $environmentCode = $namingParams[2]
    $deploymentLocation = $spokeResourceGroup.Location

    if (($organizationCode.Length -ne 3) -and ($subscriptionCode.Length -ne 4) -and ($environmentCode -ne 1)) {
        Write-Error "Error getting the naming parameters, possible custom naming convetion used!" -ErrorAction Stop   
    }
    #END NOTES

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

    Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like '*tmp-naming-rsg-deleteme' } | Remove-AzResourceGroup -Verbose -Force -AsJob -ErrorAction SilentlyContinue #cleanup temporary naming resource group

    $deploymentName = -join ('keyManagement-', (new-guid).Guid.Substring(0, 5), '-deployment')

    $templateParams = @{
        location                  = $spokeResourceGroup.Location
        subscriptionType          = $subscriptionType
        keyVaultAppObjectId       = $keyVaultAppObjectId
        keyManagementTags         = @{$($tagName)  = 'True' }
        automationAccountIdentity = $automationAccountIdentity
    }

    New-AzDeployment -Location $deploymentLocation -Name $deploymentName -TemplateFile $templateFile -TemplateParameterObject $templateParams -Verbose
}
catch {
    throw $_.Exception
}
