
<#
    .SYNOPSIS
        Eviden Landingzones for Azure Automation Module

    .DESCRIPTION
        This module must be used by the runbooks hosted in the automation accounts, it provides cmldlets to manage subscriptions and resources.
        See the runbook example template for usage.

        <IMPORTANT>
        This module is being converted to the new "AZ" modules, cmdlets/functions not yet converted are commented at the end of this file.

#>

# Global Configuration
[int] $automationRetryCount = 15
[string] $CustomAlertsLogAnalyticsTableName = "ELZCustomAlerts"
[int]    $MaxAPIRequestRetries = 5


function New-RunbookOutput {
    Param(
        [Parameter(Mandatory = $false)]
        [object]$Runbook
    )

    [pscustomobject]@{
        Result                 = $null
        ResultDescription      = $null
        AzureJobID             = $($Runbook.JobId)
        AzureAutomationAccount = $($Runbook.AutomationAccount)
        RequestorUserId        = ${RequestorUserAccount}
        ConfigurationItems     = @()
        Error                  = $null
    }

}


function Add-OutputError {
    Param (
        [Parameter(Mandatory = $true)]
        [object] $OutputObject,

        [Parameter(Mandatory = $false)]
        [object]$ErrorObject,

        [Parameter(Mandatory = $false)]
        [string]$ErrorMessage = ''
    )

    # Error object doesn't yet exist - create it
    if ($null -eq $OutputObject.Error) {
        $OutputObject.Error = [pscustomobject]@{
            ErrorMessage = $ErrorMessage
            ErrorDetail  = $null
        }
    }

    if ($ErrorMessage) {
        $OutputObject.Error.ErrorMessage = $ErrorMessage
    }
    if ($ErrorObject) {
        if ($OutputObject.Error.ErrorMessage -eq '') {
            # Blank error message - use the message from this error object instead
            $OutputObject.Error.ErrorMessage = $ErrorObject.ToString()
        }
        # Add just the top level of information from the error object
        $OutputObject.Error.ErrorDetail = $($ErrorObject | ConvertTo-JSON -Depth 1 | ConvertFrom-JSON)
    }
}

# Get Azure REST API data
Function Invoke-AzureRestAPIDataRequest {
    param(
        [Parameter(Mandatory = $True)]
        [string] $APIurl,

        [Parameter(Mandatory = $False)]
        [string] $APIMethod,

        [Parameter(Mandatory = $False)]
        [string] $BodyJSON        
    )
    If (-Not $APIMethod) {
        $APIMethod = "GET"
    }
    $AzToken = (Get-AzAccessToken).Token
    $APIurlString = 'https://management.azure.com' + $APIurl
    $headers = @{ Authorization = "Bearer " + $AzToken; Accept = "application/json" }
    $NbTry = 0
    Do {
        $Nbtry++
        try {
            If (-Not $BodyJSON) {
                $APIResponse = Invoke-RestMethod -Method $APIMethod -Uri $APIurlString -ContentType 'application/json' -headers $headers -ErrorAction Stop
            }
            else {
                $APIResponse = Invoke-RestMethod -Method $APIMethod -Body $BodyJSON -Uri $APIurlString -ContentType 'application/json' -headers $headers -ErrorAction Stop
            }
            
        }
        catch {
            $APIResponse = $null
            Write-Warning ("Failed to get Rest API response : $($_.ToString()) retry " + $Nbtry + "/" + $MaxAPIRequestRetries)
            Start-Sleep -Seconds 5
        }
    } until (($APIResponse -ne $null) -or ($Nbtry -eq $MaxAPIRequestRetries))
    If ($APIResponse -eq $null) {
        Write-Error ("Failed to get Rest API response : $($_.ToString())")
    }
    return $APIResponse
}

##
## Monitoring functions
##

# Find the primary Log Analytics workspace by searching in all customer subscription (based on the special tag)
Function Search-customerManagementLogAnalyticsWorkspace {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope = 'Function')]
    Param(
        [Parameter(Mandatory = $False)]
        [string] $tagName,

        [Parameter(Mandatory = $False)]
        [string] $tagValue
    )
    $Subscriptions = Get-AzSubscription
    $LogAnalyticsWorkspaceObject = $null
    $SearchLogAnalytics = Search-AzGraph -Subscription $Subscriptions -Query "resources| where (type == ""microsoft.operationalinsights/workspaces"" and tostring(tags) contains ""\""$($tagName)\"":\""$($tagValue)\"""")| project Name=name, ResourceGroupName=resourceGroup, CustomerId=properties.customerId, SubscriptionId=subscriptionId, ResourceId=id"
    if ($SearchLogAnalytics -ne $null) {
        if ($SearchLogAnalytics.Count -gt 1) {
            throw "More than one primary $($company) workspace found in the customer subscriptions, aborting !"
        }
        else {
            $LogAnalyticsWorkspaceObject = $SearchLogAnalytics
        }
    }
    if ($LogAnalyticsWorkspaceObject -eq $null) {
        throw "No primary $($company) workspace found in all the customer subscriptions, aborting !"
    }
    else {
        Set-AzContext -Subscription $LogAnalyticsWorkspaceObject.SubscriptionId | Out-Null
        $LogAnalyticsWorkspace = Get-AzOperationalInsightsWorkspace -Name $LogAnalyticsWorkspaceObject.Name -ResourceGroupName $LogAnalyticsWorkspaceObject.ResourceGroupName
        $WorkspaceSharedKeys = Get-AzOperationalInsightsWorkspaceSharedKey -Name $LogAnalyticsWorkspaceObject.Name -ResourceGroupName $LogAnalyticsWorkspaceObject.ResourceGroupName -WarningAction SilentlyContinue
        Write-Verbose "Found workspace [$($LogAnalyticsWorkspace.Name)] ($($LogAnalyticsWorkspace.CustomerId))"

        # Return data
        return [hashtable] @{
          LogAnalyticsWorkspace   = $LogAnalyticsWorkspace
          WorkspaceSharedKeys     = $WorkspaceSharedKeys
        }
    }
}

# Create an authorization signature for sending data to a Log Analytics workspace
Function Build-LogAnalyticsSignature ($omsWorkspaceId, $omsSharedKey, $date, $contentLength, $method, $contentType, $resource) {
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource
 
    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($omsSharedKey)
 
    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $omsWorkspaceId, $encodedHash
    return $authorization
}
 
# Create and post the JSON request to a Log Analytics workspace
Function Send-LogAnalyticsData ($omsWorkspaceId, $omsSharedKey, $JsonBody, $logType) {
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $JsonBody.Length
    $params = @{
        omsWorkspaceId = $omsWorkspaceId
        omsSharedKey   = $omsSharedKey
        date           = $rfc1123date
        contentLength  = $contentLength
        method         = $method
        contentType    = $contentType
        resource       = $resource
    }
    $signature = Build-LogAnalyticsSignature @params
    $uri = "https://" + $omsWorkspaceId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"
 
    Write-Verbose "Sending JSON data to Log Analytics workspace [$($omsWorkspaceId)] custom table [$($logType)]"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type"      = $logType;
        "x-ms-date"     = $rfc1123date;
    }
    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $JsonBody -UseBasicParsing
    return $response.StatusCode
}

# Send custom alert to the log analytics workspace custom table
Function Send-CustomAlertToLogAnalytics {
    param(
        ## Log analytics WS workspace data
        [Parameter(Mandatory = $True)]
        $LogAnalyticsWorkspace,

        ## Log analytics WS shared keys
        [Parameter(Mandatory = $True)]
        $WorkspaceSharedKeys,

        ## This is the alert name that will appear in the incident
        [Parameter(Mandatory = $True)]
        [string] $AlertName,

        ## This is an additional alert description that will appear in the incident
        [Parameter(Mandatory = $True)]
        [string] $AlertDescription,

        ## This is the alert category or the category of the resource monitored (ex: virtual machine) 
        [Parameter(Mandatory = $True)]
        [string] $AlertCategory,

        ## This is the alert/incident severity. can be 'warning' or 'error'
        [Parameter(Mandatory = $True)]
        [ValidateSet('warning', 'error')]
        [string] $AlertSeverity,

        ## This is an optional resource ID of the monitored item. 
        ## This ID must exist and the resource type must be managed by the ITSM logic-app (ex: virtual machine)
        ## As it will be used to attach the incident to the CI in SNOW
        ## If you just want to include the resourceID but still want the incident to be attached to the generic CI, use the following parameter
        [Parameter(Mandatory = $False)]
        [string] $AlertResourceId,

        # Force the incident to be attached to the generic CI when a resourceID is specified
        [Parameter(Mandatory = $False)]
        [Boolean] $ForceUseGenericCI
    )

    
    If (($ForceUseGenericCI) -and ($AlertResourceId)) {
        $AlertResourceId = "[FORCE_USE_GENERIC_CI]" + $AlertResourceId
    }

    # create the JSON data
    $data = [ordered]@{
        AlertName       = $AlertName
        AlertDesc       = $AlertDescription
        AlertCategory   = $AlertCategory
        AlertSeverity   = $AlertSeverity
        AlertResourceId = if ((-Not $AlertResourceId) -or ($AlertResourceId -eq "")) { "n/a" } else { $AlertResourceId }
    }   
    $jsonData = $data | ConvertTo-Json
    # Send the JSON data to the API
    Write-Output ("Sending custom alert [" + $AlertName + "] to the Log Analytics workspace [" + $LogAnalyticsWorkspace.name + "]")        
    $jsonBody = ([System.Text.Encoding]::UTF8.GetBytes("[" + $jsonData + "]"))
    $params = @{
        omsWorkspaceId = $LogAnalyticsWorkspace.CustomerId
        omsSharedKey   = $WorkspaceSharedKeys.PrimarySharedKey
        JsonBody       = $jsonBody
        logType        = $CustomAlertsLogAnalyticsTableName
    }
    $NbTry = 0
    Do {
        $Nbtry++
        $httpReturnCode = Send-LogAnalyticsData @params
        If ($httpReturnCode -ne 200) {
            Write-Warning ("Failed to send JSON data to Log Analytic workspace [$($LogAnalyticsWorkspace.CustomerId)] HTTP error code [$($httpReturnCode)] retry " + $Nbtry + "/" + $MaxAPIRequestRetries)
            Start-Sleep -Seconds 5
        }         
    } until (($httpReturnCode -eq 200) -or ($Nbtry -eq $MaxAPIRequestRetries))
    If ($httpReturnCode -ne 200) {
        Write-Error ("Failed to send JSON data to Log Analytic workspace [$($LogAnalyticsWorkspace.CustomerId)] HTTP error code [$($httpReturnCode)]")
    }
}


Export-ModuleMember -function "New-RunbookOutput"
Export-ModuleMember -function "Add-OutputError"
Export-ModuleMember -function "Search-customerManagementLogAnalyticsWorkspace"
Export-ModuleMember -function "Invoke-AzureRestAPIDataRequest"
Export-ModuleMember -function "Send-CustomAlertToLogAnalytics"