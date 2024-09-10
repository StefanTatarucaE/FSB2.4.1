
<#
    .SYNOPSIS
        Eviden Integration testing module for ELZ Azure

    .DESCRIPTION
        This module is used by the Integration testing scripts to provide common helper functions
#>

# Global Configuration
[int]    $MaxAPIRequestRetries = 5

Function select-cntySubscription {
    Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
}

Function select-mgmtSubscription {
    Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
}

Function select-lndzSubscription {
    Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
}

Function select-lndz2Subscription {
    Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
}

Function convert-hashToString {
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable] $hash
    )
    $hashstr = ""
    $keys = $hash.keys
    foreach ($key in $keys) {
        $v = $hash[$key]
        If ($hashstr) {
            $hashstr += ";"
        }
        if ($key -match "\s") {
            $hashstr += "`"$key`"" + "=" + "`"$v`""
        }
        else {
            $hashstr += $key + "=" + "`"$v`""
        }
    }
    return $hashstr
}

function find-partialStringInArray {
    param (
        [Parameter(Mandatory = $true)]
        [Array] $array,

        [Parameter(Mandatory = $true)]
        [String] $partialString
    )

    $result = $false
    foreach ($string in $array) {
        If ($string -like "*" + $partialString + "*") {
            $result = $true
            # Write-Host ("Found partial string ["+$partialString+"] in array value ["+$string+"]")
        }
    }
    return $result
}

Function search-azureResourceByTag {
    Param(
        [Parameter(Mandatory = $false)]
        [string] $resourceType,

        [Parameter(Mandatory = $true)]
        [hashtable] $tags,

        [Parameter(Mandatory = $false)]
        [string] $resourceGroupName
    )

    $tagStr = convert-hashToString($tags)
    If (($resourceGroupName) -and ($resourceType)) {
        $resourceObject = Get-AzResource -resourceType $resourceType -tag $tags -resourceGroupName $resourceGroupName
    }
    elseif ($resourceType) {
        $resourceObject = Get-AzResource -resourceType $resourceType -tag $tags
    }
    else {
        $resourceObject = Get-AzResource -tag $tags
    }
    if ($resourceObject -ne $null) {
        if ($resourceObject.Count -gt 1) {
            throw ("Multiple resources of type [" + $resourceType + "] with tag [" + $tagStr + "] found, aborting !")
        }
    }
    return $resourceObject
}

Function get-deprecatedPolicies {
    Param(
    )
    $definitions = Get-AzPolicyAssignment
    $Deprecated_list = @()

    foreach ($items in $definitions.Properties.PolicyDefinitionId) {

        if ($items.contains("policySetDefinitions")) {
            $set_definitions = Get-AzPolicySetDefinition -Id $items

            $setPolicyType = $set_definitions.Properties.PolicyType
			if ($setPolicyType -eq "BuiltIn") {
                                # just check custom policy sets for deprecated policy definitions, so skip built-in policy sets
				$set_definitions = ""
			}
        }
        else {
            $set_definitions = Get-AzPolicyDefinition -Id $items
        }

        foreach ($policy in $set_definitions.Properties.PolicyDefinitions.policyDefinitionId) {

            $policy_definitions = Get-AzPolicyDefinition -Id $policy
            if ($policy_definitions.Properties.DisplayName.contains("Deprecated")) {
                $Deprecated_list += $policy_definitions.Properties.DisplayName
            }
        }
    }

    return $Deprecated_list
}

Function wait-untilTestingResourceIsReady {
    Param(
        [Parameter(Mandatory = $false)]
        [string] $resourceType,
        [Parameter(Mandatory = $true)]
        [string] $identifier,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix
    )

    $params = @{
        tags         = @{"${tagPrefix}Testing" = $identifier }
        resourceType = if ($resourceType -eq "") { $null } else { $resourceType }
    }

    $resourceObject = wait-loop -sleepTime 5 -numberOfRetries 120 -command "search-azureResourceByTag" -params $Params
    If (-Not($resourceObject)) {
        $tagStr = convert-hashToString($tags)
        throw ("Unable to find resource with tags [" + $tagStr + "], aborting !")
    }
    return $resourceObject
}


Function start-mgmtAutomationRunbook {
    # Starts a new runbook in the Mgmt automation account if it was not already running, and wait for the runbook to finish in both cases
    Param(
        [Parameter(Mandatory = $true)]
        [string] $runbookName,
        [Parameter (Mandatory = $True)]
        [string] $custMgmtSubscriptionId,
        [Parameter (Mandatory = $True)]
        [string] $tenantId,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix,
        [Parameter (Mandatory = $False)]
        [hashtable] $runbookParameters = @{}
    )

    Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
    $params = @{
        resourceType = "Microsoft.Automation/automationAccounts"
        tags         = @{"${tagPrefix}Purpose" = "${tagValuePrefix}Automation" }
    }

    $mgmt_aa = search-azureResourceByTag @params

    $runbookJobs = Get-AzAutomationJob -AutomationAccountName $mgmt_aa.name -resourceGroupName $mgmt_aa.resourceGroupName -RunbookName $runbookName

    $runbookJobId = $null
    foreach ($job in $runbookJobs) {
        If ($job.Status -in ("Running", "Starting", "Queued", "New", "Activating")) {
            $runbookJobId = $job.JobId
            $runbookJobStatus = $job.Status
        }
    }
    If (-Not($runbookJobId)) {
        # Use REST API to start the runbook due to issues in the 'Start-AzAutomationRunbook' cmdlet with Az.Automation 1.9.0
        # $job = Start-AzAutomationRunbook -AutomationAccountName $mgmt_aa.name -Name $runbookName -resourceGroupName $mgmt_aa.resourceGroupName
        $jobId = (New-Guid).ToString()
        $body = @{
          'properties' = @{
            'runbook'  = @{
              'name' = $RunbookName
            }
            'parameters' = $runbookParameters
          }
        } | ConvertTo-Json
        $params = @{
            apiUrl      = $mgmt_aa.id + "/jobs/" + $jobId + "?api-version=2019-06-01"
            apiMethod   = "PUT"
            bodyJson    = $body
        }
        $jobData = invoke-azureRestAPIDataRequest @params
        $runbookJobId = $jobData.properties.jobId
        $runbookJobStatus = "New"
    }
    While (($runbookJobStatus -in ("Running", "Starting", "Queued", "New", "Activating", "Resuming"))) {
        Start-sleep 5
        $runbookJob = Get-AzAutomationJob -AutomationAccountName $mgmt_aa.name -resourceGroupName $mgmt_aa.resourceGroupName -Id $runbookJobId
        $runbookJobStatus = $runbookJob.Status
    }
    $runbookJobError = (Get-AzAutomationJobOutput -AutomationAccountName $mgmt_aa.name -resourceGroupName $mgmt_aa.resourceGroupName -Id $runbookJobId -Stream "Error").Summary
    return ($runbookJobStatus -eq "Completed" -And $runbookJobError -eq $Null)
}

Function get-mgmtAutomationRunbookCompleted {
    # Search if the specified runbook is completed in the last minutes. 
    # Allow optional filtering by VMName in the webhook data for event-triggered runbook.
    Param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject] $automationAccount,

        [Parameter(Mandatory = $true)]
        [string] $runbookName,

        [Parameter(Mandatory = $true)]
        [Int] $lastMinutes,

        [Parameter(Mandatory = $false)]
        [string] $vmName
    )
    $cutoffTime = (Get-Date).AddMinutes(-$lastMinutes)
    $cutoffTime = $cutoffTime.ToUniversalTime()
    try {
        $runbookJobs = Get-AzAutomationJob -AutomationAccountName $automationAccount.name -resourceGroupName $automationAccount.resourceGroupName -RunbookName $runbookName -ErrorAction Stop | Where-Object { $_.EndTime -gt $cutoffTime }
    }
    catch {
        write-hogt "m : Error getting the Job list for runbook [$($runbookName)] !!"
        return $null
    }
    foreach ($job in $runbookJobs) {
        if ($job.Status -eq "Completed") {
            If ($vmName) {
                $response = invoke-azureRestAPIDataRequest ($automationAccount.id + "/Jobs/" + $job.JobId + "?api-version=2017-05-15-preview")
                If ($response) {
                    try {
                        $jobWebhookData = $response.properties.parameters.webhookData | ConvertFrom-Json
                        If ($jobWebhookData.RequestBody -like "*providers/Microsoft.Compute/virtualMachines/" + $vmName + "?*") {
                            return $job
                        }
                    }
                    catch {
                        write-hogt "m : Error getting the webhookdata for Job [$($job.JobId)] !!"
                    }
                }
                else {
                    write-hogt "m : Error getting API response !!"
                }
            }
            else {
                return $job
            }
        }
    }
    return $null
}


# Get Azure REST API data
Function invoke-azureRestApiDataRequest {
    param(
        [Parameter(Mandatory = $True)]
        [string] $apiUrl,

        [Parameter(Mandatory = $False)]
        [string] $apiMethod,

        [Parameter(Mandatory = $False)]
        [string] $bodyJson,

        [Parameter(Mandatory = $False)]
        [string] $basicUsername,
        
        [Parameter(Mandatory = $False)]
        [string] $basicPassw
    )
    If (-Not $apiMethod) {
        $apiMethod = "GET"
    }
    If (($apiUrl -like "http://*") -or ($apiUrl -like "https://*")) {
        $apiUrlString = $apiUrl
    }
    else {
        $apiUrlString = 'https://management.azure.com' + $apiUrl
    }    
    If ((-Not $basicUsername) -or (-Not $basicPassw)) {
        $azToken = (Get-AzAccessToken).Token
        $headers = @{ authorization = "Bearer " + $azToken; accept = "application/json" }
    }
    else {
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $basicUsername, $basicPassw)))
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add('Authorization', ('Basic {0}' -f $base64AuthInfo))
        $headers.Add('Accept', 'application/json')
    }
    $nbTry = 0
    Do {
        $nbtry++
        try {
            If (-Not $bodyJson) {
                $apiResponse = Invoke-RestMethod -Method $apiMethod -Uri $apiUrlString -ContentType 'application/json' -headers $headers -ErrorAction Stop
            }
            else {
                $apiResponse = Invoke-RestMethod -Method $apiMethod -Body $bodyJson -Uri $apiUrlString -ContentType 'application/json' -headers $headers -ErrorAction Stop
            }
            
        }
        catch {
            $apiResponse = $null
            write-host ("Failed to get Rest API response : $($_.ToString()) retry " + $Nbtry + "/" + $MaxAPIRequestRetries)
            Start-Sleep -Seconds 5
        }
    } until (($apiResponse -ne $null) -or ($nbtry -eq $maxApiRequestRetries))
    If ($apiResponse -eq $null) {
        write-host ("Failed to get Rest API response : $($_.ToString())")
    }
    return $apiResponse
}
Function get-runBookStat {
    Param(
        #
        [Parameter (Mandatory = $True)]
        [string] $automationAccount,
        [Parameter (Mandatory = $True)]
        [string] $resourceGroup,
        [Parameter (Mandatory = $True)]
        [string] $runbook
    )
    
    If ($automationAccount -ne $Null) {
        $AccountOk = (Get-AzAutomationAccount -Name $automationAccount -resourceGroupName $resourceGroup -erroraction 'silentlycontinue').state
    }
    If ($accountOk -ne "Ok") {
        $runbookJobError = "AutomationAccount $($automationAccount) not active or doesnot exist"
    }
    Else {
        # Check if given runbook is published
        $runbookOk = (Get-AzAutomationRunbook -Name $runbook -AutomationAccountname $automationAccount -resourceGroupName $resourceGroup -erroraction 'silentlycontinue').State 
    }
    If (($accountOk -eq "Ok") -And ($runbookOk -ne "Published")) {
        $runbookJobError = "Runbook $($runbook) not published or doesnot exist in AutomationAccount $($automationAccount)"
    }
    
    # Get Job information and status
    If (($accountOk -eq "Ok") -And ($runbookOk -eq "Published")) {
        $runbookJobError = "No runbook jobs ran"
        $runbookJobInfo = Get-AzAutomationJob -AutomationAccountName $automationAccount -RunbookName $runbook -resourceGroupName $resourceGroup
        If ($runbookJobInfo -ne $Null) {
            $runbookJobInfo = ($runbookJobInfo)[0] 
            $runbookJobWarning = (Get-AzAutomationJobOutput -AutomationAccountName $automationAccount -Id $runbookJobInfo.JobId -resourceGroupName $resourceGroup -Stream "Warning").Summary
            $runbookJobError = (Get-AzAutomationJobOutput -AutomationAccountName $automationAccount -Id $runbookJobInfo.JobId -resourceGroupName $resourceGroup -Stream "Error").Summary
        }
    }
    $runbookObjects = New-Object PSObject -Property @{
        Name      = $runbook
        JobId     = $runbookJobInfo.JobId
        StartTime = $runbookJobInfo.StartTime
        EndTime   = $runbookJobInfo.EndTime
        Status    = $runbookJobInfo.Status
        Warning   = $runbookJobWarning
        Error     = $runbookJobError
    }
    
    Return $runbookObjects | Select Name, JobId, Status, StartTime, EndTime, Warning, Error 
    
}
Function get-runbookAutomationAccount {
    # Get Automation Account in MGMT.
    Param(
        [Parameter (Mandatory = $True)]
        [string] $custMgmtSubscriptionId,
        [Parameter (Mandatory = $True)]
        [string] $tenantId,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix
    )
    Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
    $runbookAutomationAccount = search-azureResourceByTag -resourceType "Microsoft.Automation/AutomationAccounts" -tags @{"${tagPrefix}Purpose" = "${tagValuePrefix}Automation" }
    return $runbookAutomationAccount
}
Function get-sharedDashboard {
    # Check if given Shared dasboardname is created in MSP subscription in resourcegroup for reporting
    Param(
        [Parameter (Mandatory = $True)]
        [string] $custMgmtSubscriptionId,
        [Parameter (Mandatory = $True)]
        [string] $tenantId,
        [Parameter (Mandatory = $True)]
        [string] $dashboardName,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix
        
    )

    $purposeTag = $tagPrefix + "Purpose"
    $purposeTagValue = $tagValuePrefix + "Reporting"

    Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
    $dashboardExist = $Null -ne (Get-AzResource -resourceType "Microsoft.Portal/dashboards" -Tag @{$purposeTag = $purposeTagValue } | Where-object { ($_.Name -eq $dashboardName) -and ($_.resourceGroupName -match "-reporting$") })
    return $dashboardExist
}
Function get-sharedDashboardReport {
    # Check if given Shared dasboardname is created in MSP subscription in resourcegroup for reporting, 
    # if workbook is created in same resourcegroup and if tile with workbook is available in dashboard
    Param(
        [Parameter (Mandatory = $True)]
        [string] $custMgmtSubscriptionId,
        [Parameter (Mandatory = $True)]
        [string] $tenantId,
        [Parameter (Mandatory = $True)]
        [string] $dashboardName,
        [Parameter (Mandatory = $True)]
        [string] $workbookName,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix
    )

    $purposeTag = $tagPrefix + "Purpose"
    $purposeTagValue = $tagValuePrefix + "Reporting"
    $result = $False

    Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
    $dashboardExist = $Null -ne (Get-AzResource -resourceType "Microsoft.Portal/dashboards" -Tag @{$purposeTag = $purposeTagValue } | Where-object { ($_.Name -eq $dashboardName) -and ($_.resourceGroupName -match "-reporting$") })
    If ($dashboardExist -ne $False) {
        $workBookId = (Get-AzResource -resourceType "microsoft.insights/workbooks" | where-object { $_.tags.'hidden-title' -eq $workbookName }).ResourceId 
        If ($workBookId -ne $Null) {
            $query = "resources| where type == ""microsoft.portal/dashboards""| where name ==`"" + $dashboardName + "`"|extend jsonarray = parse_json(properties)|extend found=iif((jsonarray has `"" + $workBookId + "`"), ""True"", ""False"") |project found"
            $result = (Search-AzGraph -Query $query).found
        }
    }
    return $result
}
Function get-sharedDashboardLink {
    # Check if given Shared dasboardname is created in MSP subscription in resourcegroup and if given link is available in dashboard. 
    Param(
        [Parameter (Mandatory = $True)]
        [string] $custMgmtSubscriptionId,
        [Parameter (Mandatory = $True)]
        [string] $tenantId,
        [Parameter (Mandatory = $True)]
        [string] $dashboardName,
        [Parameter (Mandatory = $True)]
        [string] $dashboardLink,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix
    )

    $purposeTag = $tagPrefix + "Purpose"
    $purposeTagValue = $tagValuePrefix + "Reporting"
    $result = $False

    Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
    $dashboardExist = $Null -ne (Get-AzResource -resourceType "Microsoft.Portal/dashboards" -Tag @{$purposeTag = $purposeTagValue } | Where-object { ($_.Name -eq $dashboardName) -and ($_.resourceGroupName -match "-reporting$") })
    If ($dashboardExist -ne $False) {
        $query = "resources| where type == ""microsoft.portal/dashboards""| where name ==`"" + $dashboardName + "`"|extend jsonarray = parse_json(properties)|extend found=iif((jsonarray has `"" + $dashBoardLink + "`"), ""True"", ""False"") |project found"
        $result = (Search-AzGraph -Query $query).found
    }
    return $result
}

Function Get-DashboardArtifacts {

    # Get the artifacts folder that is used for the dashboard images, Eviden logo and manuals and check its existence.

    Param(
        [Parameter (Mandatory = $True)]
        [string] $custMgmtSubscriptionId,
        [Parameter (Mandatory = $True)]
        [string] $tenantId,
        [Parameter (Mandatory = $True)]
        [string] $DashboardName,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix

    )

    $purposeTag = $tagPrefix + "Purpose"
    $purposeTagValue = $tagValuePrefix + "Reporting"
    $ArtifactFolder = ""
    $Blobs = ""
    $Result = $False

    Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
    $SearchstorageAccountArtifact = get-azresource -resourcetype "Microsoft.Storage/storageAccounts" -tag @{$purposeTag = $purposeTagValue }
    $StorageAccountArtifact = get-azstorageaccount -ResourceGroupName $SearchstorageAccountArtifact.ResourceGroupName -StorageAccountName $SearchstorageAccountArtifact.Name
    $StorageAccountArtifactContext = $StorageAccountArtifact.context
    $ArtifactFolder = 'https://' + $SearchstorageAccountArtifact.Name + '.blob.core.windows.net/artifacts/'
    $Bloblink = "*"
    $Blobs = Get-AzStorageBlob -Container 'artifacts' -Blob $Bloblink -context $StorageAccountArtifactContext -erroraction 'silentlycontinue'
    if ($Blobs -ne "") {

        $Result = $True

    }
    $ArtifactFolderObjects = New-Object PSObject -Property @{
        Name   = $ArtifactFolder
        Result = $Result
    }

    Return $ArtifactFolderObjects | Select Result, Name

}
Function get-updateManagementCheck {
    Param(
        #
        [Parameter (Mandatory = $True)]
        [string] $custMgmtSubscriptionId,
        [Parameter (Mandatory = $True)]
        [string] $tenantId,
        [Parameter (Mandatory = $True)]
        [string] $virtualMachine,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix
    )
    
    # Get Workspace, WorkspaceID, SourceComputerId and define query
    $workspace = get-logAnalyticsWorkspace -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
    $workspaceId = (Get-AzOperationalInsightsWorkspace -Name $workspace.Name -resourceGroupName $workspace.resourceGroupName -erroraction 'silentlycontinue').CustomerId
    If ($workspaceId -ne $null) {
        # Query to check if VM is patched in the past 2 hours
        $query = "UpdateRunProgress | where TimeGenerated > ago(2h) | where Computer == ""@@@@@""| where InstallationStatus==""Succeeded"" or InstallationStatus==""Failed""| summarize Updates=count() by UpdateRunName, InstallationStatus| project [""PatchSchedule""]=UpdateRunName, [""InstallationStatus""]=InstallationStatus, Updates"
        $query = $query -replace "@@@@@", $($virtualMachine)
        
        # execute query
        $report = Invoke-AzOperationalInsightsQuery -WorkspaceId "$($workspaceId)" -Query $query
        $resultsArray = [System.Linq.Enumerable]::ToArray($report.results)
        if ($resultsArray.PatchSchedule -eq $Null) {
            $result = "NotScheduledYet"
        }
        else {
            $result = $resultsArray.installationstatus -contains "Succeeded"
        }
    }
    Else {
        $result = "$($workspace) does not exist in resourcegroup $($workspaceResourceGroup)"
    }
          
    Return $result
}

Function set-keyVaultAccessPolicyForPipelineAccount {
    param(
        [Parameter(Mandatory = $True)]
        [string] $keyVaultName
    )
    $context = Get-AzContext
    Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName $context.Account.Id -PermissionsToSecrets set, delete, get -ErrorAction stop
}

Function add-keyVaultSecret {
    param(
        [Parameter(Mandatory = $True)]
        [string] $keyVaultName,

        [Parameter(Mandatory = $True)]
        [string] $secretName,

        [Parameter(Mandatory = $True)]
        [string] $secretValue
    )
    $secureSecretValue = ConvertTo-SecureString $secretValue -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -SecretValue $secureSecretValue | Out-Null
}

Function remove-keyVaultSecret {
    param(
        [Parameter(Mandatory = $True)]
        [string] $keyVaultName,

        [Parameter(Mandatory = $True)]
        [string] $secretName
    )
    Remove-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Out-Null
}

##
## OS-MGMT FUNCTIONS
##

Function get-updateManagementAutomationAccount {
    # Get Automation Account in MGMT.
    Param(
        [Parameter (Mandatory = $True)]
        [string] $custMgmtSubscriptionId,
        [Parameter (Mandatory = $True)]
        [string] $tenantId,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix
    )
    Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
    $updateManagementAutomationAccount = search-azureResourceByTag -resourceType "Microsoft.Automation/AutomationAccounts" -tags @{"${tagPrefix}Purpose" = "${tagValuePrefix}VmOsManagementAutomation" }
    return $UpdateManagementAutomationAccount
}
Function test-vmExtension {
    <#
.SYNOPSIS
Check VM for extension presence and successful provisioning

.DESCRIPTION
Installed extensions for VM are being retrieved. Extension from parameter is being checked (if present) for provisioning status.
Returns $True if extension is present and provisioning succeeded.

.PARAMETER virtualMachine
VM name

.PARAMETER resourceGroup
Resource group where VM is deployed

.PARAMETER extension
Name of extension

.EXAMPLE
$params = @{
    virtualMachine = "vm-demo"
    resourceGroup = "cu1-sub3-d-rsg-testing"
    extension = "MicrosoftMonitoringAgent"
}
Write-Output (Test-VmExtension @params)

or 

Write-Output (Test-VmExtension -virtualMachine "vm-linux-1" -resourceGroup "cu1-sub3-d-rsg-testing" -extension "OMSAgentForLinux")

.NOTES
Assumes that correct subscription context is set before this function is called
#>
    Param(
        [Parameter(Mandatory = $true)]
        [string] $virtualMachine,

        [Parameter(Mandatory = $true)]
        [string] $resourceGroup,

        [Parameter(Mandatory = $true)]
        [string] $extension
    )

    $vmProperties = Get-AzVM -Name $virtualMachine -resourceGroupName $resourceGroup
    If ($null -ne $vmProperties) {
        foreach ($vmExtension in $vmProperties.Extensions) {
            if ($vmExtension.Name -eq $extension) {
                $provisioningState = $vmExtension.ProvisioningState
            }
        }
    }
        
    $success = ($provisioningState -eq "Succeeded")
    return $success
}
Function get-vmPowerState {
    # Get power state for VM
    # Returns [string] powerState like e.g 'running', 'starting', 'stopping', 'deallocated' or 'stopped'
    Param(
        [Parameter(Mandatory = $true)]
        [string] $virtualMachine,

        [Parameter(Mandatory = $true)]
        [string] $resourceGroup
    )

    $vmStatus = Get-AzVM -Name $virtualMachine -resourceGroupName $resourceGroup -Status
    foreach ($status in $vmStatus.Statuses) {
        if ($status.Code -match "PowerState") {
            $powerState = $status.Code.Split("/")[1]
        }
    }
    return $powerState
}

Function get-logAnalyticsWorkspace {
    Param(
        [Parameter (Mandatory = $True)]
        [string] $custMgmtSubscriptionId,
        [Parameter (Mandatory = $True)]
        [string] $tenantId,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix
    )
    # Get log analytics workspace from mgmt subscription
    Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
    $logAnalyticsWorkspace = search-azureResourceByTag -resourceType "Microsoft.OperationalInsights/workspaces" -tags @{"${tagPrefix}Purpose" = "${tagValuePrefix}Monitoring" }
    return $logAnalyticsWorkspace
}


Function invoke-logAnalyticsQuery {
    # Run query in log analytics workspace
    Param(
        [Parameter (Mandatory = $True)]
        [string] $tenantId,

        [Parameter(Mandatory = $true)]
        [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResource] $logAnalyticsWorkspace,

        [Parameter(Mandatory = $true)]
        [string] $logAnalyticsQuery
    )

    # Switch subscription context, if current context differs from Log Analytics Workspace subscription
    $lawSubscription = $logAnalyticsWorkspace.ResourceId.Split('/')[2]
    if ($lawSubscription -ne (Get-AzContext).Subscription.Id) {
        Set-AzContext -Subscription $lawSubscription -tenant $tenantId -ErrorAction Stop | Out-Null
    }
    
    $workspace = Get-AzOperationalInsightsWorkspace -resourceGroupName $logAnalyticsWorkspace.resourceGroupName -Name $logAnalyticsWorkspace.Name
    $queryOutput = Invoke-AzOperationalInsightsQuery -Workspace $workspace -Query $logAnalyticsQuery
    return $queryOutput.results
}

Function test-vmHeartbeat {
    # Check if in last hour heartbeat is logged by VM's Monitoring Agent in Log Analytics Heartbeat table
    Param(
        [Parameter(Mandatory = $true)]
        [string] $virtualMachine,

        [Parameter (Mandatory = $True)]
        [string] $custMgmtSubscriptionId,

        [Parameter (Mandatory = $True)]
        [string] $tenantId,

        [Parameter(Mandatory = $true)]
        [string] $resourceGroup,

        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,

        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix
    )

    $laWorkspace = get-logAnalyticsWorkspace -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
    $queryText = "Heartbeat|where TimeGenerated > ago(1h)|summarize arg_max(TimeGenerated,*) by SourceComputerId|where Resource==`"" + $virtualMachine + "`""
    $queryOutput = Invoke-LogAnalyticsQuery -logAnalyticsWorkspace $laWorkspace -logAnalyticsQuery $queryText -tenantId $tenantId

    $vmHeartbeat = ("$($queryOutput)" -match "resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$virtualMachine")
    return $vmHeartbeat
}

Function get-diskEncryptionSet {
    # Get DiskEncryptionSet deployed
    Param(
        [Parameter(Mandatory = $false)]
        [string] $location,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix
    )

    if (-Not $location) {
        $diskEncryptionSet = Get-AzResource -Tag @{"${tagPrefix}Purpose" = "${tagValuePrefix}DiskEncryption" } -resourceType Microsoft.Compute/diskEncryptionSets
    }
    else {
        $diskEncryptionSet = Get-AzResource -Tag @{"${tagPrefix}Purpose" = "${tagValuePrefix}DiskEncryption" } -resourceType Microsoft.Compute/diskEncryptionSets -ODataQuery "location eq `'$location`'"
    }
    return $diskEncryptionSet
}

Function test-vmTags {
    # Check if VM has tagName set to tagValue
    Param(
        [Parameter(Mandatory = $true)]
        [string] $virtualMachine,

        [Parameter(Mandatory = $true)]
        [string] $resourceGroup,

        [Parameter(Mandatory = $true)]
        [string] $tagName,

        [Parameter(Mandatory = $true)]
        [string] $tagValue
    )

    $resourceObject = Get-AzResource -Name $virtualMachine -resourceGroupName $resourceGroup -resourceType "Microsoft.Compute/virtualMachines" -TagName $tagName -TagValue $tagValue
    $resourcetags = convert-hashToString($resourceObject.tags)
    $resourceMatchesTag = ($resourcetags -match "$tagName=`"$tagValue`"")

    return ($resourceMatchesTag)
}

Function test-vNetTags {
    # Check if VM has tagName set to tagValue
    Param(
        [Parameter(Mandatory = $true)]
        [string] $vnetName,

        [Parameter(Mandatory = $true)]
        [string] $resourceGroup,

        [Parameter(Mandatory = $true)]
        [string] $tagName,

        [Parameter(Mandatory = $true)]
        [string] $tagValue
    )

    $resourceObject = Get-AzResource -Name $vnetName -resourceGroupName $resourceGroup -resourceType "Microsoft.Network/virtualNetworks" -TagName $tagName -TagValue $tagValue
    $resourcetags = convert-hashToString($resourceObject.tags)
    $resourceMatchesTag = ($resourcetags -match "$tagName=`"$tagValue`"")

    return ($resourceMatchesTag)
}

Function test-vmEncryption {
    # Returns true if VM has Encryption at Host enabled
    Param(
        [Parameter(Mandatory = $true)]
        [string] $virtualMachine,

        [Parameter(Mandatory = $true)]
        [string] $resourceGroup
    )

    $vmProperties = Get-AzVM -Name $virtualMachine -resourceGroupName $resourceGroup
    return ($null -ne $vmProperties.SecurityProfile.EncryptionAtHost)
}

Function test-vmIsStarted {
    # Returns true if VM has Encryption at Host enabled
    Param(
        [Parameter(Mandatory = $true)]
        [string] $virtualMachine,

        [Parameter(Mandatory = $true)]
        [string] $resourceGroup
    )

    $vmProperties = Get-AzVM -Name $virtualMachine -resourceGroupName $resourceGroup -status
    return ($vmProperties.Statuses[1].DisplayStatus -eq "VM running")
}

Function get-vmOsDiskEncryptionType {   
    # Get encryption type for VM's OS Disk
    # Returns [string] EncryptionType like e.g 'SSE with CMK', 'SSE with PMK', 'SSE with PMK and CMK', 'No Encryption at Rest'
    Param(
        [Parameter(Mandatory = $true)]
        [string] $virtualMachine,

        [Parameter(Mandatory = $true)]
        [string] $resourceGroup,

        [Parameter(Mandatory = $true)]
        [string] $expectedEncryption       
    )

    $vmProperties = Get-AzVM -Name $virtualMachine -resourceGroupName $resourceGroup
    If ($null -ne $vmProperties) {
        $vmOsDiskEncryptionType = (Get-AzDisk -resourceGroupName $vmProperties.resourcegroup -DiskName $vmProperties.StorageProfile.OSDisk.Name).Encryption.Type
        if ($null -eq $vmOsDiskEncryptionType) {
            $vmOsDiskADE = (Get-AzDisk -resourceGroupName $vmProperties.resourcegroup -DiskName $vmProperties.StorageProfile.OSDisk.Name).EncryptionSettingsCollection.Enabled
        }
    
    }
    else {
        Write-Error "VM properties not found"
        $vmOsDiskEncryptionType = $null
    }

    $encryptionType = switch ($vmOsDiskEncryptionType) {
        { ($_ -eq "EncryptionAtRestWithCustomerKey") } { "SSE with CMK" }
        { ($_ -eq "EncryptionAtRestWithPlatformKey") } { "SSE with PMK" }
        { ($_ -eq "EncryptionAtRestWithPlatformAndCustomerKeys") } { "SSE with PMK and CMK" }
        Default { "No Encryption at Rest" }
    }
    if ($vmOsDiskADE) {
        $encryptionType = "Azure Disk Encryption"
    }
    return ($encryptionType -eq $expectedEncryption)
}

Function get-vmOsVersion {
    # Returns OS-version for running VM, $null if VM not running
    Param(
        [Parameter(Mandatory = $true)]
        [string] $virtualMachine,

        [Parameter(Mandatory = $true)]
        [string] $resourceGroup
    )

    $vmStatus = Get-AzVM -Name $virtualMachine -resourceGroupName $resourceGroup -status
    if ($null -ne $vmStatus.OsName) {
        if ($vmStatus.OsName -match "Windows") {
            $vmOsVersion = $vmStatus.OsName
        }
        else {
            $vmOsVersion = $vmStatus.OsName + " " + $vmStatus.OsVersion
        }
    }
    else {
        $vmOsVersion = $null
    }
    return ($vmOsVersion)
}

function get-backupPolicyStatus {
    #This function will list only if the resources are included in a policy. Output should be true or false. 
    
    param (
        [Parameter(Mandatory = $true)]                            
        [String] $vmName,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix
    )

    $vmProperties = Get-AzResource -resourceType "Microsoft.Compute/virtualMachines" -Tag @{"${tagPrefix}Managed" = "true" } | Where-Object { $_.Name -eq $vmName }
    $vmPolicyStatus = (Get-AzRecoveryServicesBackupStatus -Name $vmName -resourceGroupName $vmProperties.resourceGroupName -Type AzureVM).BackedUp
    $vmPolicyStatus

}
Function start-vmBackup {
    param (

        [Parameter(Mandatory = $true)]
        [String] $vmName,
        [Parameter(Mandatory = $true)]
        [string] $resourceGroup,
        [Parameter(Mandatory = $true)]
        [String] $policyName,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix
    )


    $vaultProperties = search-azureResourceByTag -resourceType "Microsoft.RecoveryServices/vaults" -tags @{"${tagPrefix}Purpose" = "${tagValuePrefix}OsVmManagement" }
    $targetVault = Get-AzRecoveryServicesVault -resourceGroupName $vaultProperties.resourceGroupName -Name $vaultProperties.Name

    #Trigger a backup
    $backupContainer = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -FriendlyName $vmName -resourceGroupName $resourceGroup -VaultId $targetVault.ID -WarningAction Silentlycontinue
    $item = Get-AzRecoveryServicesBackupItem -Container $backupContainer -WorkloadType "AzureVM" -VaultId $targetVault.ID -WarningAction Silentlycontinue
    Backup-AzRecoveryServicesBackupItem -Item $item -VaultId $targetVault.ID -WarningAction Silentlycontinue

    #Monitor the backup job
    $joblist = Get-AzRecoveryservicesBackupJob -Status "InProgress" -VaultId $targetVault.ID -WarningAction Silentlycontinue
    $joblist[0]
    Write-Host "The backup job has been triggered succesfully and it is In Progress."

}

#EventGridSubscriptions
Function get-eventGridSubscription {
    
    $output = Get-AzEventGridSubscription

    return $output.PsEventSubscriptionsList | ConvertTo-Json -Depth 99 | ConvertFrom-Json
	
}

function search-eventGridSub {
    param (
        [Parameter(Mandatory = $true)]
        [string] $keyword
    )
    
    $output = Get-AzEventGridSubscription
    $output2 = $output.PsEventSubscriptionsList | ConvertTo-Json -Depth 99 | ConvertFrom-Json

    Write-Host "List of Azure Event Grid Subscriptions containing the keyword:"
    $output2.EventSubscriptionName | Select-String -Pattern $keyword

    Write-Host "Selected Azure Event Grid Subscription(s) details:"
    return $output2 | Where-Object -Property EventSubscriptionName -Match $keyword

}

function get-functionAppFunctions {
    param (
        # resourceId of FunctionApp object
        [Parameter(Mandatory = $true)]
        [string] $resourceId
    )

    $functionAppFunctions = (invoke-azureRestAPIDataRequest -APIurl ($resourceId + "/functions?api-version=2015-08-01"))
    return $functionAppFunctions.value
}

function get-functionAppLogsResult {
    # Retrieves latest message with result from FunctionAppLogs table in Log Analytics Workspace

    param (
        # resourceId of FunctionApp object
        [Parameter(Mandatory = $true)]
        [string] $resourceId,

        [Parameter(Mandatory = $true)]
        [string] $functionName,

        [Parameter(Mandatory = $true)]
        [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResource] $logAnalyticsWorkspace,

        [Parameter(Mandatory = $true)]
        [string] $searchText,

        [Parameter (Mandatory = $True)]
        [string] $tenantId,
        
        [Parameter(Mandatory = $false)]
        [string] $timeRange
    )

    $queryText = "FunctionAppLogs"
    if ($timeRange) {
        $queryText += "|where TimeGenerated > ago($timeRange)"
    }
    $queryText += "|where _ResourceId matches regex '(?i:$resourceId\\z)'|where FunctionName == '$functionName'|where Message matches regex '(?i:$searchText)'|join (FunctionAppLogs|where Message contains 'Duration=') on FunctionInvocationId|extend result=split(split(Message1,'(')[1], ',')[0]|project TimeGenerated,_ResourceId,FunctionName,Message,result|top 1 by TimeGenerated desc"
    $queryOutput = Invoke-LogAnalyticsQuery -logAnalyticsWorkspace $logAnalyticsWorkspace -logAnalyticsQuery $queryText -tenantId $tenantId
    return $queryOutput
}

function start-functionAppFunction {
    # Force start of a schedule function (non http triggered)

    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject] $functionApp,

        [Parameter(Mandatory = $true)]
        [string] $functionName
    )

    $apiUrl = $functionApp.id + '/host/default/listKeys?api-version=2021-02-01'
    $functionKeys = invoke-azureRestAPIDataRequest -APIurl $apiUrl -APIMethod "POST"
    $params = @{
        Uri         = 'https://' + $functionApp.Name + '.azurewebsites.net/admin/functions/' + $functionName
        Method      = "POST"
        Body        = '{ "input": "test" }'
        ContentType = 'application/json'
        headers     = @{ 
            "Content-Type"    = "application/json"
            "x-functions-key" = $functionKeys.masterKey
        }
    }
    try {
        Invoke-RestMethod @params -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}



##
## ITSM FUNCTIONS
##

Function get-itsmMgmtApiConnectionStatus {
    param(
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix
    )
    $params = @{
        resourceType      = "Microsoft.Web/connections"
        resourceGroupName = $runbook.ResourceGroup
        tags              = @{"${tagPrefix}Purpose" = "${tagValuePrefix}ItsmAlerts"}
    }
    $api_connection = search-azureResourceByTag @params
    $connectionObj = invoke-azureRestAPIDataRequest -APIurl ($api_connection.id + '?api-version=2016-06-01')
    $connectionObj.properties.statuses.status
    return $connectionObj.properties.statuses.status
}

Function enable-monitoringAlertRule {
    Param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject] $laWorkspace,

        [Parameter(Mandatory = $true)]
        [String] $alertRuleName    
    )
    $alertRule = Get-AzScheduledQueryRule -resourceGroupName $laWorkspace.resourceGroupName -Name $alertRuleName -WarningAction SilentlyContinue
    $alertRule | Update-AzScheduledQueryRule -Enabled:$true -WarningAction SilentlyContinue | Out-Null
    return $alertRule.id
}

Function disable-monitoringAlertRule {
    Param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject] $laWorkspace,

        [Parameter(Mandatory = $true)]
        [String] $alertRuleName    
    )
    $alertRule = Get-AzScheduledQueryRule -resourceGroupName $laWorkspace.resourceGroupName -Name $alertRuleName -WarningAction SilentlyContinue
    $alertRule | Update-AzScheduledQueryRule -Enabled:$false -WarningAction SilentlyContinue | Out-Null
}

Function update-monitoringAlertRuleDesc {
    Param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject] $laWorkspace,

        [Parameter(Mandatory = $true)]
        [String] $alertRuleName,

        [Parameter(Mandatory = $true)]
        [String] $testDesc
    )
    $alertRule = Get-AzScheduledQueryRule -resourceGroupName $laWorkspace.resourceGroupName -Name $alertRuleName -WarningAction SilentlyContinue
    $desc = $alertRule.Description
    if ($desc -like "*`{INT-TEST:*") {
        $splitstr = $desc -Split '{INT-TEST:'
        $desc = $splitstr[0] + "{INT-TEST:" + $testDesc + "}"
    }
    else {
        $desc += " {INT-TEST:" + $testDesc + "}"
    }
    $alertRule | Update-AzScheduledQueryRule -WarningAction SilentlyContinue -Description $desc | Out-Null
}

Function add-monitoringTestAlertRule {
    Param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject] $laWorkspace,

        [Parameter(Mandatory = $true)]
        [String] $resourceTypeName,

        [Parameter(Mandatory = $false)]
        [String] $resourceId,

        [Parameter(Mandatory = $true)]
        [String] $alertName
    )
    $testAlertRule = Get-AzScheduledQueryRule -resourceGroupName $laWorkspace.resourceGroupName -Name "Example test alert" -WarningAction SilentlyContinue

    $testAlertTag = $resourceTypeName + (Get-Date -Format "HHmmMMddyyyy")
    $alertDesc = $testAlertRule.Description
    if ($alertDesc -like "*`{INT-TEST:*") {
        $splitstr = $alertDesc -Split '{INT-TEST:'
        $alertDesc = $splitstr[0] + "{INT-TEST:" + $testAlertTag + "}"
    }
    else {
        $alertDesc += " {INT-TEST:" + $testAlertTag + "}"
    }

    If ($resourceId) {
      $alertQuery           = 'AzureActivity|top 1 by TimeGenerated desc|summarize AggregatedValue=count() by bin(TimeGenerated,5m)|extend SubscriptionId="' + $laWorkspace.id.split('/')[2] + '"|extend ResourceId="' + $resourceId + '"|project TimeGenerated,AggregatedValue,SubscriptionId,ResourceId,ResourceID=ResourceId'
      $dimension = New-AzScheduledQueryRuleDimensionObject -Name "ResourceId" -Operator Include -Value *
    } else {
      $alertQuery           = 'AzureActivity|top 1 by TimeGenerated desc|summarize AggregatedValue=count() by bin(TimeGenerated,5m)|extend SubscriptionId="' + $laWorkspace.id.split('/')[2] + '"|project TimeGenerated,AggregatedValue,SubscriptionId'
      $dimension = New-AzScheduledQueryRuleDimensionObject -Name "SubscriptionId" -Operator Include -Value *
    }

    $params = @{
        Dimension                               = $dimension
        Query                                   = $alertQuery
        TimeAggregation                         = "Maximum"
        MetricMeasureColumn                     = "AggregatedValue"
        Operator                                = "GreaterThan"
        Threshold                               = "0"
        FailingPeriodNumberOfEvaluationPeriod   = 1
        FailingPeriodMinFailingPeriodsToAlert   = 1
    }
    $alertCondition = New-AzScheduledQueryRuleConditionObject @params

    $params = @{
        Name                  = $alertName
        DisplayName           = $alertName
        Description           = $alertDesc
        Tag                   = $testAlertRule.Tag.ToJsonString() | ConvertFrom-Json -AsHashTable
        ResourceGroupName     = $laWorkspace.resourceGroupName
        Location              = $laWorkspace.Location
        Scope                 = $testAlertRule.scope
        Severity              = $testAlertRule.Severity
        WindowSize            = $testAlertRule.WindowSize
        EvaluationFrequency   = $testAlertRule.EvaluationFrequency
        CriterionAllOf        = $alertCondition
        ActionGroupResourceId = $testAlertRule.ActionGroup
    }
    $alertRule = New-AzScheduledQueryRule @params
    write-host ("Creating alert [" + $alertName + "] with description tag {INT-TEST:" + $testAlertTag + "} Id ["+$alertRule.id+"]")

    # Return data
    return [hashtable] @{
      descriptionTag  = $testAlertTag
      alertID         = $alertRule.id
    }    
}

Function remove-monitoringAlertRule {
  Param(
      [Parameter(Mandatory = $true)]
      [PSCustomObject] $laWorkspace,

      [Parameter(Mandatory = $true)]
      [String] $alertRuleName
  )
  Remove-AzScheduledQueryRule -resourceGroupName $laWorkspace.resourceGroupName -Name $alertRuleName -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Out-Null
}

Function get-alertHistoryInTimeRange {
    Param(
        [Parameter(Mandatory = $true)]
        [String] $alertRuleId,

        [Parameter(Mandatory = $true)]
        [Int] $historyInMinutes
    )
    $cutoffTime = (Get-Date).AddMinutes(-$historyInMinutes)
    $cutoffTime = $CutoffTime.ToUniversalTime()
    $firedAlerts = Get-AzAlert -Severity "Sev2" -TimeRange '1h' -MonitorCondition "Fired" -AlertRuleId $alertRuleId | Where-Object { $_.StartDateTime -gt $cutoffTime }
    return $firedAlerts
}

Function get-logicAppHistoryInTimeRange {
    Param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject] $logicApp,

        [Parameter(Mandatory = $true)]
        [Int] $historyInMinutes,

        [Parameter(Mandatory = $true)]
        [String] $outputVariable,

        [Parameter(Mandatory = $true)]
        [String] $outputValue

    )
    $cutoffTime = (Get-Date).AddMinutes(-$historyInMinutes)
    $cutoffTime = $cutoffTime.ToUniversalTime()
    $outputValue = "*" + $outputValue + "*"
    $history = Get-AzLogicAppRunHistory -FollowNextPageLink -MaximumFollowNextPageLink 99 -resourceGroupName $logicApp.resourceGroupName -Name $logicApp.Name `
    | Where-Object { ($_.EndTime -gt $cutoffTime) -and ($_.Outputs.$outputVariable.value -like $outputValue) }    
    return $history
}

Function get-serviceNowIncidentForSpecificAlert {
    Param(
        [Parameter(Mandatory = $false)]
        [String] $snowEnv = "DEV",

        [Parameter(Mandatory = $true)]
        [String] $functionalOrg,

        [Parameter(Mandatory = $true)]
        [String] $basicUsername,

        [Parameter(Mandatory = $true)]
        [String] $basicPassw,

        [Parameter(Mandatory = $true)]
        [String] $alertName,

        [Parameter(Mandatory = $true)]
        [String] $descriptionTag
        
    )

    # SNOW Incidents and Events states :
    # New/Open      1
    # In Progress   2
    # Resolved      6
    # Closed        7
    # Duplicate     40

    $snow_url = "https://atosglobal" + $snowEnv.ToLower() + ".service-now.com"
    
    # Get the ID of the company
    $params = @{
        apiUrl        = $snow_url + "/api/now/table/core_company?sysparm_query=name%3D" + $functionalOrg
        basicUsername = $basicUsername
        basicPassw    = $basicPassw
    }
    $response = invoke-azureRestAPIDataRequest @params
    $snow_FO_sysid = $response.result[0].sys_id

    # Get opened incident for this company, filtering on the alert name and description tag
    $encodedFilterString = "company%3D" + $snow_FO_sysid + "%5EstateIN1,2%5EdescriptionLIKE" + $alertName + "%5EdescriptionLIKE{INT-TEST:" + $descriptionTag + "}" 
    $params = @{
        apiUrl        = $snow_url + "/api/now/table/incident?sysparm_query=" + $encodedFilterString
        basicUsername = $basicUsername
        basicPassw    = $basicPassw
    }
    $response = invoke-azureRestAPIDataRequest @params

    # Get the affected CI name and ID
    Foreach ($incident in $response.result) {
        If ($incident.cmdb_ci.value) {
            $params = @{
                apiUrl        = $snow_url + "/api/now/table/cmdb_ci?sysparm_query=sys_id%3D" + $incident.cmdb_ci.value
                basicUsername = $basicUsername
                basicPassw    = $basicPassw
            }
            $cmdbResponse = invoke-azureRestAPIDataRequest @params
            If ($cmdbResponse.result[0].Name) {
                $incident.cmdb_ci | Add-Member -Name 'name' -Type NoteProperty -Value $cmdbResponse.result[0].Name
            }
            If ($cmdbResponse.result[0].sys_class_name) {
                $incident.cmdb_ci | Add-Member -Name 'class' -Type NoteProperty -Value $cmdbResponse.result[0].sys_class_name
            }
            If ($cmdbResponse.result[0].u_monitoring_object_id) {
                $incident.cmdb_ci | Add-Member -Name 'monitoring_object_id' -Type NoteProperty -Value $cmdbResponse.result[0].u_monitoring_object_id
            }               
        }
    }

    # If No incident found, we look at an existing ATF-Event with status 'root cause event detected'
    If ($response.result.Count -eq 0) {
        # Get Event for this company, filtering on the alert name and description tag
        $encodedFilterString = "company%3D" + $snow_FO_sysid + "%5Estate=50%5Eu_event_message_textLIKE" + $alertName + "%5Eu_event_message_textLIKE{INT-TEST:" + $descriptionTag + "}"
        $params = @{
            apiUrl        = $snow_url + "/api/now/table/u_service_event?sysparm_query=" + $encodedFilterString
            basicUsername = $basicUsername
            basicPassw    = $basicPassw
        }
        $response = invoke-azureRestAPIDataRequest @params       

        Foreach ($event in $response.result) {
            If ($event.cmdb_ci.value) {
                $params = @{
                    apiUrl        = $snow_url + "/api/now/table/cmdb_ci?sysparm_query=sys_id%3D" + $event.cmdb_ci.value
                    basicUsername = $basicUsername
                    basicPassw    = $basicPassw
                }
                $cmdbResponse = invoke-azureRestAPIDataRequest @params
                If ($cmdbResponse.result[0].Name) {
                    $event.cmdb_ci | Add-Member -Name 'name' -Type NoteProperty -Value $cmdbResponse.result[0].Name
                }
                If ($cmdbResponse.result[0].sys_class_name) {
                    $event.cmdb_ci | Add-Member -Name 'class' -Type NoteProperty -Value $cmdbResponse.result[0].sys_class_name
                }
                If ($cmdbResponse.result[0].u_monitoring_object_id) {
                    $event.cmdb_ci | Add-Member -Name 'monitoring_object_id' -Type NoteProperty -Value $cmdbResponse.result[0].u_monitoring_object_id
                }
            }
        }
    }
    return $response.result
}

Function get-serviceNowCiByMonitoringId {
    Param(
        [Parameter(Mandatory = $false)]
        [String] $snowEnv = "DEV",

        [Parameter(Mandatory = $true)]
        [String] $functionalOrg,

        [Parameter(Mandatory = $true)]
        [String] $basicUsername,

        [Parameter(Mandatory = $true)]
        [String] $basicPassw,

        [Parameter(Mandatory = $true)]
        [String] $monitoringId
        
    )

    $snow_url = "https://atosglobal" + $snowEnv.ToLower() + ".service-now.com"
    
    # Get the ID of the company
    $params = @{
        apiUrl        = $snow_url + "/api/now/table/core_company?sysparm_query=name%3D" + $functionalOrg
        basicUsername = $basicUsername
        basicPassw    = $basicPassw
    }
    $response = invoke-azureRestAPIDataRequest @params
    $snow_FO_sysid = $response.result[0].sys_id

    # Get opened incident for this company, filtering on the alert name and description tag

    $encodedFilterString = "company%3D" + $snow_FO_sysid + "%5Eoperational_status=1%5Eu_is_monitored=true%5Eu_monitoring_object_id=" + $monitoringId
    $params = @{
        apiUrl        = $snow_url + "/api/now/table/cmdb_ci?sysparm_query=" + $encodedFilterString        
        basicUsername = $basicUsername
        basicPassw    = $basicPassw
    }
    $response = invoke-azureRestAPIDataRequest @params
    return $response.result
}

Function get-monitoringIdFromResourceId {
    Param(
        [Parameter(Mandatory = $true)]
        [String] $resourceId,

        [Parameter(Mandatory = $true)]
        [String] $resourceName
    )

    $encodedText = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($resourceId.Tolower()))
    $bodyJson = '{
        "$schema": "http://schemas.management.azure.com/deploymentTemplate?api-version=2014-04-01-preview",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "'+ $encodedText.ToUpper() + '": {
            "type": "string"
            }
        },
        "resources": []
        }'
    $params = @{
        apiUrl    = "/providers/Microsoft.Resources/calculateTemplateHash?api-version=2020-06-01"
        apiMethod = "POST"
        BodyJSON  = $BodyJson
    }
    $response = invoke-azureRestAPIDataRequest @params            
    $monitoringID = "azure://RID-" + $response.templateHash + "/" + $resourceName  
    return $monitoringID
}

function get-pricingPlans {   
    
    $pricingPlans = New-Object PSObject -Property @{
        virtualMachines               = Get-AzSecurityPricing  -Name virtualMachines
        sqlServers                    = Get-AzSecurityPricing  -Name sqlServers
        appServices                   = Get-AzSecurityPricing  -Name appServices
        storageAccounts               = Get-AzSecurityPricing  -Name storageAccounts
        sqlServerVirtualMachines      = Get-AzSecurityPricing  -Name sqlServerVirtualMachines
        keyVaults                     = Get-AzSecurityPricing  -Name keyVaults
        dns                           = Get-AzSecurityPricing  -Name dns
        arm                           = Get-AzSecurityPricing  -Name arm
        openSourceRelationalDatabases = Get-AzSecurityPricing  -Name openSourceRelationalDatabases
        cosmosDbs                     = Get-AzSecurityPricing  -Name cosmosDbs
        containers                    = Get-AzSecurityPricing  -Name containers

    }
    return $pricingPlans 

}
function get-diagRule {
    <#
.SYNOPSIS

Function to read the diagnosticrule based upon the ResourceId

.DESCRIPTION

This function reads the diagnlosticrule(s) configured for a specific resource based upon the resourceid. 
- [string] ResourceId = ResourceId for which the diagnosticrule need to be retreived
          
.OUTPUTS 

Output is PSServiceDiagnosticSettings object per ResourceId. In case of a Microsoft.Storage/storageAccounts resourceType
this will be an array of PSServiceDiagnosticSettings objects.

Example PSServiceDiagnosticSettings Object:

Location                    :
tags                        :
StorageAccountId            : /subscriptions/54c0f1b6-842e-4d1c-884f-9c1ae0db98d9/resourceGroups/cu1-sub1-d-rsg-storage/providers/Microsoft.Storage/storageAccounts/cu1dstgdscpriv
ServiceBusRuleId            :
EventHubAuthorizationRuleId :
EventHubName                :
Metrics
    TimeGrain       :
    Category        : Transaction
    Enabled         : True
    RetentionPolicy
    Enabled : False
    Days    : 0


    TimeGrain       :
    Category        : Capacity
    Enabled         : False
    RetentionPolicy
    Enabled : False
    Days    : 0


Logs
WorkspaceId                 : /subscriptions/54c0f1b6-842e-4d1c-884f-9c1ae0db98d9/resourceGroups/cu1-sub1-d-rsg-monitoring/providers/microsoft.operationalinsights/workspaces/cu1-sub1-d-loganalytics
LogAnalyticsDestinationType : 
Id                          : /subscriptions/54c0f1b6-842e-4d1c-884f-9c1ae0db98d9/resourceGroups/cu1-sub1-d-rsg-storage/providers/microsoft.storage/storageaccounts/cu1
dstgdscpriv/providers/microsoft.insights/diagnosticSettings/myCompanyDiagnosticRule-SendToLogAnalytics
Name                        : myCompanyDiagnosticRule-SendToLogAnalytics
Type                        : Microsoft.Insights/diagnosticSettings

.EXAMPLE
    
Get-DiagRule -resourceId $ResourceId

#>
    Param(
        # ResourceID as parameter input   
        [Parameter(Mandatory = $True)]
        [string] $resourceId
    
    )
    
    # Pull in information relted to the resource to do resourcetype checking for storage case
    # Do nothing if the id is for a subscription
    If ($resourceId.Split('/').count -gt 3) {
        $resource = Get-AzResource -resourceid $resourceId
    }
    else {
        $resource = $null
    }    
       
    # Check if supplied ResourceId is part of a StorageAccount if so get all storage related diagRules         
    if ($resource.resourcetype -eq "Microsoft.Storage/storageAccounts" ) {
        
        $blobService = $resource.Id + "/BlobServices/default"
        $fileService = $resource.Id + "/FileServices/default"
        $queueService = $resource.Id + "/QueueServices/default"
        $tableService = $resource.Id + "/TableServices/default"

        $diagRules = New-Object PSObject -Property @{
            StorageAccountdiagrule = Get-AzDiagnosticSetting -ResourceId $resource.Id -WarningAction SilentlyContinue
            BlobServicediagrule    = Get-AzDiagnosticSetting -ResourceId $blobService -WarningAction SilentlyContinue
            QueueDiagrule          = Get-AzDiagnosticSetting -ResourceId $queueService -WarningAction SilentlyContinue
            FileServicediagrule    = Get-AzDiagnosticSetting -ResourceId $fileService -WarningAction SilentlyContinue
            TableDiagRule          = Get-AzDiagnosticSetting -ResourceId $tableService -WarningAction SilentlyContinue
        }

        #Returns array of psobjects with PSServiceDiagnosticSettings object as defined above
        return $diagRules
            
    }
    else {
        #Returns single PSServiceDiagnosticSettings object to the caller
        $diagRules = Get-AzDiagnosticSetting -ResourceId $resourceId -WarningAction SilentlyContinue
        return $diagRules
    }
}

function wait-loop {

    Param(
        # Number of Maximum Retries   
        [Parameter(Mandatory = $True)]
        [string] $numberOfRetries,

        # wait between Retries.   
        [Parameter(Mandatory = $True)]
        [string] $sleepTime,

        [Parameter(Mandatory = $True)]
        [string] $command,

        [Parameter(Mandatory = $True)]
        [PSCustomObject] $params
    
    )

    $attemptCount = 0
    Do {
        $attemptCount++
        $finishRetry = $False
        $commandOutput = & $command @params
        If (([string]::IsNullOrWhitespace($commandOutput)) -or (-not($commandOutput))) {
            write-host "Wait/Retry loop with $sleepTime seconds wait time for command [$command], Retry $attemptCount/$numberOfRetries"
            start-sleep -Seconds $sleepTime
        } 
        else { 
            $finishRetry = $true 
        }
    } Until ($finishRetry -eq $true -or ($attemptCount -gt $numberOfRetries))
    return $commandOutput
}

function start-policyScan {
    Param(
        [Parameter(Mandatory = $false)]
        [string] $resourceGroupName
    )

    if ( !$resourceGroupName ) {
        write-host "Starting AzPolicyComplianceScan on Subscription, can take a while"
        $job = Start-AzPolicyComplianceScan -AsJob -PassThru
        $job | Wait-Job
    }
    else {
        write-host "Starting AzPolicyComplianceScan on ResourceGroup, can take a while"
        $job = Start-AzPolicyComplianceScan -AsJob -Resourcegroupname $resourceGroupName -PassThru
        $job | Wait-Job
    }
    return $job.State
}

function get-numberOfExemptions {

    #$Exemptions_list = New-Object -TypeName 'System.Collections.ArrayList'
    $Exemptions_list = @()
    $ResourceGroups = Get-AzResourceGroup
    $SubscriptionExemptions = Get-AzPolicyExemption
    $Exemptions_list += $SubscriptionExemptions.ResourceId

    foreach ($ResourceGroup in $resourcegroups) {

        $ResourceExemptions = Get-AzPolicyExemption -Scope $ResourceGroup.Resourceid
        $Exemptions_list += $ResourceExemptions.ResourceId
    }

    $unique = $Exemptions_list | select-object -unique
    
    return $unique.count
}

function get-incompliantDcsResources {
    Param(
        [Parameter(Mandatory = $true)]
        [string] $policyAssignmentName,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix
    )

    $incompliantList = New-Object System.Collections.Generic.List[System.Object]
    # Filter out incompliancy's on subscriptions. Only include resource incompliancy's for the policy.
    $incompliant = Get-AzPolicyState | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyAssignmentName -eq $policyAssignmentName -and $_.resourceType -ne "microsoft.compute/virtualmachines/extensions" -and $_.resourceType -ne "Microsoft.Resources/subscriptions" -and $_.resourceType -ne "Microsoft.Authorization/roleDefinitions" -and $_.resourcetype -ne "microsoft.compute/virtualmachines" -and $_.resourceGroup -ne "NetworkWatcherRG" }

    # Filter out resources which have the testing tag set and just skip if 0 are found

    if (-not ([string]::IsNullOrEmpty($incompliant))) {

        foreach ($resource in $incompliant) {

            if ($resource.resourceType -ne "Microsoft.Resources/subscriptions/resourceGroups") {

                $filtered = Get-AzResource -Resourceid $resource.ResourceId -WarningAction SilentlyContinue | Where-Object { $_.tags.Keys -notcontains "${tagPrefix}Testing" }
                $incompliantList.add($filtered.ResourceName)
            }
            else {

                $filtered = Get-AzResourceGroup -Resourceid $resource.ResourceId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Where-Object { $_.tags.Keys -notcontains "${tagPrefix}Testing" }
                $incompliantList.add($filtered.Resourceid)

            }
        }
    }

    # measure-object more reliable than direct $incompliant_list.count.
    $count = $incompliantList | select-object -unique | measure-object
    return $count.count

}

Function get-firewallPolicies { 
    param (
        [Parameter(Mandatory = $true)]
        [String] $fwPolicyName,
        [Parameter(Mandatory = $true)]
        [String] $resourceGroupName,
        [Parameter(Mandatory = $true)]
        [String] $ruleCollName
    )
    $openPorts = @()
    $listFw = Get-AzFirewallPolicyRuleCollectionGroup -AzureFirewallPolicyName $fwPolicyName -resourceGroupName $resourceGroupName -Name $ruleCollName
    ForEach ($rule in $listFw.Properties.RuleCollection.Rules) {
        ForEach ($port in $rule.DestinationPorts) {
            If (($port -ne "*") -and ($openPorts -notcontains $port)) {
                $openPorts += $port
            }
        }
    }
    return $openPorts
}

function get-storageAccountContext {
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject] $storageAccount
    )

    $storageAccountKey = (Get-AzStorageAccountKey -resourceGroupName $storageAccount.resourceGroupName -Name $storageAccount.Name)[0].Value
    $storageAccountContext = New-AzStorageContext -StorageAccountName $storageAccount.Name -StorageAccountKey $storageAccountKey
    return $storageAccountContext
}

function get-storageAccountBlobFiles {
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext] $storageAccountContext,

        [Parameter(Mandatory = $true)]
        [String] $containerName,
        [Parameter(Mandatory = $false)]
        [Int] $historyInMinutes
    )
    
    if ($historyInMinutes) {
        $cutoffTime = (Get-Date).AddMinutes(-$historyInMinutes)
        $cutoffTime = $cutoffTime.ToUniversalTime()
        $blobFiles = Get-AzStorageBlob -Context $storageAccountContext -Container $containerName | Where-Object { $_.LastModified -gt $cutoffTime }
    }
    else {
        $blobFiles = Get-AzStorageBlob -Context $storageAccountContext -Container $containerName
    } 
    return $blobFiles
}
Function get-allMissingDiagRules {

    Param(
        [Parameter(Mandatory = $true)]
        [string] $whichCheck,
        [Parameter (Mandatory = $True)]
        [string] $custMgmtSubscriptionId,
        [Parameter (Mandatory = $True)]
        [string] $tenantId,
        [Parameter(Mandatory = $false)]
        [string] $environment,
        [Parameter (Mandatory = $True)]
        [string] $tagPrefix,
        [Parameter (Mandatory = $True)]
        [string] $tagValuePrefix

    )

    $emptyDiagRules = @()
    $resourceGroups = Get-AzResourceGroup
    $filteredResource = @()
    $checkDiagRules = @()  

    foreach ($resource in $resourceGroups) {
        # $Resources will hold resources with <company>Managed tag which are capable of having a diagrule.
        $resources = Get-AzResource -resourceGroupName $resource.resourcegroupname | where-object { $_.tags.Keys -contains "${tagPrefix}Managed" -and $_.tags.Keys -notcontains "${tagPrefix}Testing" -and $_.resourcetype -ne "Microsoft.Automation/automationAccounts" -and $_.resourcetype -ne "Microsoft.ManagedIdentity/userAssignedIdentities" -and $_.resourcetype -ne "microsoft.insights/activityLogAlerts" -and $_.resourceType -ne "microsoft.insights/scheduledqueryrules" -and $_.resourceType -ne "microsoft.insights/actiongroups" -and $_.resourcetype -ne "microsoft.insights/workbooks" -and $_.resourceType -ne "Microsoft.Compute/galleries" -and $_.resourceType -ne "Microsoft.OperationsManagement/solutions" -and $_.resourceType -ne "Microsoft.Portal/dashboards" -and $_.resourceType -ne "Microsoft.Network/networkWatchers" -and $_.resourceType -ne "Microsoft.Security/automations" -and $_.resourceType -ne "Microsoft.OperationalInsights/workspaces" -and $_.resourcetype -ne "Microsoft.Logic/workflows" -and $_.resourcetype -ne "microsoft.insights/components" -and $_.resourcetype -ne "Microsoft.Network/firewallPolicies" -and $_.resourceType -ne "Microsoft.Network/routeTables" -and $_.resourceType -ne "Microsoft.Compute/diskEncryptionSets" -and $_.resourceType -ne "Microsoft.Network/ipGroups" -and $_.resourceType -ne "microsoft.web/connections" -and $_.resourcetype -ne "Microsoft.Compute/disks" -and $_.resourceType -ne "Microsoft.Resources/deploymentScripts" -and $_.resourceType -ne "Microsoft.Network/privateDnsZones" -and $_.resourceType -ne "Microsoft.Network/privateDnsZones/virtualNetworkLinks" }
        $filteredResource += $resources
    }

    if ($whichCheck -eq "missing") {

        foreach ($checkResources in $filteredResource) {
            $diagRules = Get-AzDiagnosticSetting -ResourceId $checkResources.resourceid -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

            # Only catch the resource which don't have a diagnosticrule set.
            if (($null -eq $diagRules) -and ($checkResources.resourceid -notlike "*/flowLogs/*")) {
                $emptyDiagRules += $checkResources.ResourceId
            }
        }
        return $emptyDiagRules
    }
    if ($whichCheck -eq "existing") {
        $workspace = get-logAnalyticsWorkspace -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        foreach ($checkResources in $filteredResource) {
            $diagRules = Get-AzDiagnosticSetting -ResourceId $checkResources.resourceid -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | where-object { $_.Name -eq "${tagPrefix}DiagnosticRule-SendToLogAnalytics" -and $_.WorkspaceId -ne $workspace }
            $checked_diagules += $checkResources.ResourceId
        }
        return $checkDiagRules
    }
}
Function get-webRequestSucceeded {

    Param(
        [Parameter(Mandatory = $true)]
        [string] $webLink
    )
    $statusCodeOk = "200"
    try {
        $response = Invoke-WebRequest -Uri $webLink
        $statusCode = $response.StatusCode
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
    }
    return $result = ($statusCode -eq $statusCodeOk)
} 



Export-ModuleMember -function "select-cntySubscription"
Export-ModuleMember -function "select-mgmtSubscription"
Export-ModuleMember -function "select-lndzSubscription"
Export-ModuleMember -function "select-lndz2Subscription"
Export-ModuleMember -function "find-partialStringInArray"
Export-ModuleMember -function "search-azureResourceByTag"
Export-ModuleMember -function "wait-untilTestingResourceIsReady"
Export-ModuleMember -function "start-mgmtAutomationRunbook"
Export-ModuleMember -function "get-mgmtAutomationRunbookCompleted"
Export-ModuleMember -function "invoke-azureRestApiDataRequest"
Export-ModuleMember -function "get-runBookStat"
Export-ModuleMember -function "get-runbookAutomationAccount"
Export-ModuleMember -function "get-sharedDashboard"
Export-ModuleMember -function "get-sharedDashboardReport"
Export-ModuleMember -function "get-sharedDashboardLink"
Export-ModuleMember -function "get-dashboardArtifacts"
Export-ModuleMember -function "get-updateManagementCheck"
Export-ModuleMember -function "set-keyVaultAccessPolicyForPipelineAccount"
Export-ModuleMember -function "add-KeyVaultSecret"
Export-ModuleMember -function "remove-KeyVaultSecret"
Export-ModuleMember -function "get-updateManagementAutomationAccount"
Export-ModuleMember -function "test-vmExtension"
Export-ModuleMember -function "get-vmPowerState"
Export-ModuleMember -function "get-logAnalyticsWorkspace"
Export-ModuleMember -function "invoke-logAnalyticsQuery"
Export-ModuleMember -function "test-vmHeartbeat"
Export-ModuleMember -function "get-diskEncryptionSet"
Export-ModuleMember -function "test-vmTags"
Export-ModuleMember -function "test-vNetTags"
Export-ModuleMember -function "test-vmEncryption"
Export-ModuleMember -function "test-vmIsStarted"
Export-ModuleMember -function "get-vmOsDiskEncryptionType"
Export-ModuleMember -function "get-vmOsVersion"
Export-ModuleMember -function "get-backupPolicyStatus"
Export-ModuleMember -function "start-vmBackup"
Export-ModuleMember -function "get-eventGridSubscription"
Export-ModuleMember -function "search-eventGridSub"
Export-ModuleMember -function "get-functionAppFunctions"
Export-ModuleMember -function "get-functionAppLogsResult"
Export-ModuleMember -function "start-functionAppFunction"
Export-ModuleMember -function "get-itsmMgmtApiConnectionStatus"
Export-ModuleMember -function "enable-monitoringAlertRule"
Export-ModuleMember -function "disable-monitoringAlertRule"
Export-ModuleMember -function "update-monitoringAlertRuleDesc"
Export-ModuleMember -function "add-monitoringTestAlertRule"
Export-ModuleMember -function "remove-monitoringAlertRule"
Export-ModuleMember -function "get-alertHistoryInTimeRange"
Export-ModuleMember -function "get-logicAppHistoryInTimeRange"
Export-ModuleMember -function "get-serviceNowIncidentForSpecificAlert"
Export-ModuleMember -function "get-serviceNowCiByMonitoringId"
Export-ModuleMember -function "get-monitoringIdFromResourceId"
Export-ModuleMember -function "get-pricingPlans"
Export-ModuleMember -function "get-diagRule"
Export-ModuleMember -function "wait-loop"
Export-ModuleMember -function "start-policyScan"
Export-ModuleMember -function "get-numberOfExemptions"
Export-ModuleMember -function "get-incompliantDcsResources"
Export-ModuleMember -Function "get-firewallPolicies"
Export-ModuleMember -function "get-storageAccountContext"
Export-ModuleMember -function "get-storageAccountBlobFiles"
Export-ModuleMember -function "get-allMissingDiagRules"
Export-ModuleMember -function "get-webRequestSucceeded"
Export-ModuleMember -function "convert-hashToString"
Export-ModuleMember -function "get-deprecatedPolicies"
