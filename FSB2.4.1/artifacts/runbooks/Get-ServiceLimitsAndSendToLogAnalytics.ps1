<#
    .SYNOPSIS
        Get Azure service limits for customer and send to Log Analytic workspace

    .DESCRIPTION
        This runbook loop through all the customer subscriptions and retrieve the Azure service limits and current usage of resources,
        and send to the Log Analytic workspace of the customer hosted in the management subscription.

    .OUTPUTS
        N/A

    .NOTES
        Author:     Frederic TRAPET
        Company:    Eviden
        Email:      frederic.Trapet@eviden.com
        Created:    2020-07-29
        Updated:    2023-08-07
        Version:    0.2
#>

Param (
    # Enable JSON structured output instead of simple output
    [Parameter(Mandatory = $false)]
    [bool]
    $JsonOutput
)

##
## CONFIGURATION   
##

[string] $LogAnalyticsTableName = "AzureQuota"

##
## LOCAL FUNCTIONS
##

# Define branding variables needed for the Get-ServiceAndSendToLogAnalytics runbook from the automation account variables
$company = Get-AutomationVariable -Name 'company'
$tagPrefix = Get-AutomationVariable -Name 'tagPrefix'
$tagValuePrefix = Get-AutomationVariable -Name 'tagValuePrefix'

# Tags & Tag Values used in the Get-ServiceAndSendToLogAnalytics runbook

$tagName = "$($tagPrefix)Purpose"
$tagValue = "$($tagValuePrefix)Monitoring"

#region functions

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
 
    Write-Verbose "Sending JSON data to Log Analytics workspace [$($omsWorkspaceId)]"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type"      = $logType;
        "x-ms-date"     = $rfc1123date;
    }
    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $JsonBody -UseBasicParsing
    return $response.StatusCode
}

# Get locations from Azure and return associate array
Function GetAzureLocationsArray () {
    $LocArray = @{}
    $Locations = Get-AzLocation
    if ($Locations -ne $null) {
        foreach ($location in $locations) {
            $LocArray += @{$location.Location = $location.DisplayName }
        }
    }
    return $LocArray
}

#endregion


##
## SCRIPT START
##

$RunbookOutput = New-RunbookOutput
$RunbookOutput.Result = 'SUCCESS'
$RunbookOutput.ResultDescription = 'Data sent successfully to the Log Analytics worspace'


# Get connected
try {

  #Disable the Context inheritance from a previous session
  Disable-AzContextAutosave -Scope Process

  Write-Output "Logging into Azure with System-assigned Identity"
  $azConnect = Connect-AzAccount -Identity

  if (-not $azConnect) {
      Write-Error "Login error: Logging into azure Failed..." -ErrorAction 'Stop' 
  }
  else {
      Write-Output "Successfully logged into the Azure Platform."
  }
}
catch {
  throw $_.Exception
}

# Search each customer subscription for the primary Log Analytics workspace (based on the special tag)
$workspaceSearch = Search-customerManagementLogAnalyticsWorkspace -tagname $tagName -tagValue $tagValue
$LogAnalyticsWorkspace = $workspaceSearch.LogAnalyticsWorkspace
$WorkspaceSharedKeys = $workspaceSearch.WorkspaceSharedKeys
Write-Output "Using log Analytics workspace [$($LogAnalyticsWorkspace.Name)] ($($LogAnalyticsWorkspace.CustomerId))"

# Everything wrapped in a try/catch to ensure Snow-compatible output
try {

    # Recreate the output object to populate it with runbook details
    $RunbookOutput = New-RunbookOutput
    $Subscriptions = Get-AzSubscription

    ##
    ## Loop though each customer subscription, collect usage data and send to Log Analytics
    ##

    $LocationsDisplayname = GetAzureLocationsArray
    foreach ($subscription in $subscriptions) {
        $Subcontext = Get-AzContext -ListAvailable | Where-Object {$_.Subscription -like $subscription.Id}
        Write-Output ("Selected Subscription is " + $subscription.Name)

        # Find all locations used in this subscription
        $locations = @()
        $FindAllResources = Get-AzResource -DefaultProfile $Subcontext
        if ($FindAllResources -ne $null) {
            Foreach ($resource in $FindAllResources) {
                If ($LocationsDisplayname[$resource.location] -ne $null) {
                    $Location = $LocationsDisplayname[$resource.location]
                }
                else {
                    $Location = $resource.location
                }
                If (($locations -notcontains $Location) -and ($Location -ne "global")) {
                    $locations += $Location
                }
            }
        }

        # Loop though each locations and generate JSON data
        $jsonData = ''
        Foreach ($location in $locations) {
            Write-Output ("Processing location [" + $location + "] for subscription [" + $subscription.Name + "] (" + $subscription.Id + ")")

            # Get Network Quota
            $networkQuotas = Get-AzNetworkUsage -DefaultProfile $Subcontext -location $location -ErrorAction SilentlyContinue
            foreach ($networkQuota in $networkQuotas) {
                $usage = 0
                $value = $networkQuota.currentValue
                If ($value -lt 0) { $value = 0 }
                if ($networkQuota.limit -gt 0) { $usage = $value / $networkQuota.limit }
                if (($jsonData -ne '') -and ($jsonData.substring($jsonData.Length - 1) -ne ",")) { $jsonData += "," }
                $jsonData += @"
{ "SubscriptionId":"$($subscription.Id)", "SubscriptionName":"$($subscription.Name)", "Name":"$($networkQuota.name.localizedValue)", "Category":"Network", "Location":"$location", "CurrentValue":$($value), "Limit":$($networkQuota.limit),"Usage":$usage },
"@
            }

            # Get VM quotas
            $vmQuotas = Get-AzVMUsage -DefaultProfile $Subcontext -Location $location -ErrorAction SilentlyContinue
            foreach ($vmQuota in $vmQuotas) {
                $usage = 0
                if ($vmQuota.Limit -gt 0) { $usage = $vmQuota.CurrentValue / $vmQuota.Limit }
                if (($jsonData -ne '') -and ($jsonData.substring($jsonData.Length - 1) -ne ",")) { $jsonData += "," }
                $jsonData += @"
{ "SubscriptionId":"$($subscription.Id)", "SubscriptionName":"$($subscription.Name)", "Name":"$($vmQuota.Name.LocalizedValue)", "Category":"Compute", "Location":"$location", "CurrentValue":$($vmQuota.CurrentValue), "Limit":$($vmQuota.Limit),"Usage":$usage },
"@
            }

            # Get Storage Quota
            $storageQuota = Get-AzStorageUsage -DefaultProfile $Subcontext -Location $location -ErrorAction SilentlyContinue
            $usage = 0
            if ($storageQuota.Limit -gt 0) { $usage = $storageQuota.CurrentValue / $storageQuota.Limit }
            if (($jsonData -ne '') -and ($jsonData.substring($jsonData.Length - 1) -ne ",")) { $jsonData += "," }
            $jsonData += @"
{ "SubscriptionId":"$($subscription.Id)", "SubscriptionName":"$($subscription.Name)", "Name":"$($storageQuota.LocalizedName)", "Location":"$($location)", "Category":"Storage", "CurrentValue":$($storageQuota.CurrentValue), "Limit":$($storageQuota.Limit),"Usage":$usage }
"@
        }

        # Send the JSON data to the API
        Write-Output ("Sending JSON data to the Log Analytics workspace")        
        $jsonBody = ([System.Text.Encoding]::UTF8.GetBytes("[" + $jsonData + "]"))
        $params = @{
            omsWorkspaceId = $LogAnalyticsWorkspace.CustomerId
            omsSharedKey   = $WorkspaceSharedKeys.PrimarySharedKey
            JsonBody       = $jsonBody
            logType        = $LogAnalyticsTableName     
        }
        $httpReturnCode = Send-LogAnalyticsData @params
        If ($httpReturnCode -ne 200) {
            Write-Error ("Failed to send JSON data to Log Analytic workspace [$($LogAnalyticsWorkspace.CustomerId)] HTTP error code [$($httpReturnCode)]")  
            $RunbookOutput.Result = 'WARNING'
            $RunbookOutput.ResultDescription = 'ERROR while sending data to the Log Analytics worspace'
        }
    }  
    Write-Output ("Process completed")       
}
catch {
    $RunbookOutput.Result = 'FAILURE'
    $RunbookOutput.ResultDescription = $_.ToString()
    #  Add error detail into the JSON output.
    Add-OutputError -OutputObject $RunbookOutput -ErrorObject $_ # -ErrorMessage "You can add a specific error message if you like"
    Write-Verbose "Fatal error: $($_.ToString()) [$($_.InvocationInfo.ScriptLineNumber), $($_.InvocationInfo.OffsetInLine)]"
}

if ($JsonOutput -eq $true) {
    # Write output as a JSON string
    Write-Output $RunbookOutput | ConvertTo-JSON -Depth 99
}
else {
    # Write simple SNOW-compatible output
    Write-Output $RunbookOutput.Result
    Write-Output $RunbookOutput.ResultDescription
}


