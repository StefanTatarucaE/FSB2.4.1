<#
.SYNOPSIS
    This runbook will create CSV and HTML files that contains offline reports.
    It will create the reports in a folder in the "Offlinereports" container in the customers storage account.

.DESCRIPTION
    This runbook will create CSV and HTML files that contains offline reports.
    It will create a folder in the "Offlinereports" container in the customers storage account.

.PARAMETER ResourceGroupName
    Optional. The name of the Azure Resource Group containing the Automation account to update all modules for.
    If a resource group is not specified, then it will use the current one for the automation account
    if it is run from the automation service

.PARAMETER AutomationAccountName
    Optional. The name of the Automation account to update all modules for.
    If an automation account is not specified, then it will use the current one for the automation account
    if it is run from the automation service

.EXAMPLE
    N/A

.NOTES
    AUTHOR: Klaas Jan de Jager
    Created: 07-03-2022
	Updated: 20-09-2022 (CESAZURE-612)
    Updated: 06-10-2022 (CESAZURE-563)
    Updated: 01-08-2023 (PCAZURE-1720)
    Updated: 18-10-2023 (PCAZURE-2201)
#>
# modules required
#import-module Az.ResourceGraph
#import-Module Az.OperationalInsights
#import-Module Microsoft.PowerShell.Utility

# Input parameters for manual starting the runbook
# Day at which report will be created
# By default create on first day of (next) month
# If $monthreportday = "00" report will be made on current day
Param
(
    [Parameter (Mandatory = $false)]
    [String] $monthreportday = "01"
)

# Report starts in Central european timezone (UTC+1)
# For determining date and time $UtcOffset is needed as automation account uses UTC time.
# change this setting for other timezones
$UtcOffset = "1"

# Define branding variables needed for Offline reporting from automation account variables
$company = Get-AutomationVariable -Name 'company'
$tagPrefix = Get-AutomationVariable -Name 'tagPrefix'
$tagValuePrefix = Get-AutomationVariable -Name 'tagValuePrefix'

# kql Query to retrieve all VM resources and show managed tag settings.
$taggingAndPatchingkqlQuery = @"
resources
| where type == "microsoft.compute/virtualmachines"| where tostring(tags) !has "\"databricks-instance-name\""
| extend VmStatus = properties.extended.instanceView.powerState.displayStatus
| extend ${tagPrefix}PatchingTag = iff(isempty(tags.${tagPrefix}Patching),"notset",tags.${tagPrefix}Patching)
| extend ${tagPrefix}OsVersionTag = iff(isempty(tags.${tagPrefix}OsVersion),"notset",tags.${tagPrefix}OsVersion)
| extend isSupportedOS = (${tagPrefix}OsVersionTag != "notset")
| extend PatchState = case(tostring(tags) contains '"${tagPrefix}":"true"' and not(isSupportedOS), "VM is ${tagPrefix}Managed but OS version is not supported", tostring(tags) contains '"${tagPrefix}Managed":"true"' and tags contains "${tagPrefix}Patching" and ${tagPrefix}PatchingTag != "notset" and isSupportedOS, "VM is ${tagPrefix}Managed and in Patch Schedule", tostring(tags) contains '"${tagPrefix}Managed":"true"', "VM is ${tagPrefix}Managed but not in Patch Schedule", tags contains "${tagPrefix}Patching" and ${tagPrefix}PatchingTag != "notset", "VM is not ${tagPrefix}Managed but is in Patch Schedule","VM does not have the correct tags")
| join kind=leftouter (resourcecontainers| where type == "microsoft.resources/subscriptions"
| project subscriptionId, subname=name) on subscriptionId| extend ${tagPrefix}Managed = iff(tostring(tags) has '"${tagPrefix}Managed":"true"', "True", "False")
| extend ${tagPrefix}Antimalware = iff(tostring(tags) has '"${tagPrefix}Antimalware":""true"', "True", "False")
| extend ${tagPrefix}Compliance = iff(tostring(tags) has '"${tagPrefix}Compliance":"true"', "True", "False")| extend ${tagPrefix}Encryption = iff(tostring(tags) has '"${tagPrefix}Encryption":"true"', "True", "False")
| project ["Virtual Machine"] = name, ["Resource Group"] = resourceGroup, Subscription = subname, PatchState, ${tagPrefix}Patching=tostring(tags.${tagPrefix}Patching), ${tagPrefix}OsVersion=tostring(tags.${tagPrefix}OsVersion), ${tagPrefix}Managed, ${tagPrefix}Antimalware, ${tagPrefix}Compliance, ${tagPrefix}Backup=tostring(tags.${tagPrefix}Backup), ${tagPrefix}Encryption
"@

# kql Query to retrieve all '<company>Managed: True' tagged VM's to create availability report.
$availabilityKqlQueryTaggedVm = @"
resources
| where type =="microsoft.compute/virtualmachines"
| where tostring(tags) has '"${tagPrefix}Managed":"true"'
| project ${tagPrefix}Managed=strcat("VM ",name, " is deleted before end of the month")
"@

# kql Query to retrieve all VM's to create availability report.
$availabilityKqlQueryAllVm = @"
resources
| where type =="microsoft.compute/virtualmachines"
| project ${tagPrefix}Managed=strcat("VM ",name, " is deleted before end of the month")
"@

# kql Query to create monthly availability report (Log Analytics Workspace)
$availabilityKQLQuery = @"
let offset=${UtcOffset};
let currenttime=now();
let localtime=datetime_add("hour",offset, currenttime);
let utcmonthEnd = (startofmonth(localtime)-1s);
let utcmonthStart = (startofmonth(utcmonthEnd));
let timeRangeStart = datetime_add("hour",-offset, utcmonthStart);
let timeRangeEnd = datetime_add("hour",-offset, utcmonthEnd);
Heartbeat
| where TimeGenerated > timeRangeStart and TimeGenerated < timeRangeEnd
| extend RGroup = tolower(ResourceGroup)
| extend RGroup = case(RGroup <>"", RGroup, "On-Prem")
| summarize heartbeat_per_hour=count() by bin_at(TimeGenerated, 1h, timeRangeStart), Resource, _ResourceId, OSType, SubscriptionId, RGroup
| extend available_per_hour=iff(heartbeat_per_hour>0, true, false)
| summarize total_available_hours=countif(available_per_hour==true) by Resource, _ResourceId, OSType, SubscriptionId, RGroup
| extend total_number_of_buckets=round((timeRangeEnd-timeRangeStart)/1h)
| extend round(availability_rate=total_available_hours*100/total_number_of_buckets,2)
| project ["Virtual Machine"]=Resource, ["Operating System"]=OSType, ["Subscription"]=SubscriptionId, ["Resource Group"]=RGroup, ["Start Time Range"]=format_datetime(utcmonthStart,'yy-MM-dd [HH:mm:ss]'), ["End Time Range"]=format_datetime(utcmonthEnd,'yy-MM-dd [HH:mm:ss]'), ["Availability Percentage"]=strcat(availability_rate, " %"), ["Total available hours"]=total_available_hours, ["Total hours"]=total_number_of_buckets, ["Managed by ${company}"]=strcat("VM ",Resource, " is deleted before end of the month")
"@

$availabilityKQLManualQuery = @"
let offset=${UtcOffset}; 
let currenttime=now(); 
let localtime=datetime_add("hour",offset, currenttime); 
let utcmonthEnd = (startofmonth(localtime)); 
let utcmonthStart = (startofmonth(utcmonthEnd)); 
let timeRangeStart = datetime_add("hour",-offset, utcmonthStart); 
let timeRangeEnd = datetime_add("hour",-offset, localtime); 
Heartbeat
| where TimeGenerated > timeRangeStart and TimeGenerated < timeRangeEnd
| extend RGroup = tolower(ResourceGroup)
| extend RGroup = case(RGroup <>"", RGroup, "On-Prem")
| summarize heartbeat_per_hour=count() by bin_at(TimeGenerated, 1h, timeRangeStart), Resource, _ResourceId, OSType, SubscriptionId, RGroup
| extend available_per_hour=iff(heartbeat_per_hour>0, true, false)
| summarize total_available_hours=countif(available_per_hour==true) by Resource, _ResourceId, OSType, SubscriptionId, RGroup
| extend total_number_of_buckets=round((timeRangeEnd-timeRangeStart)/1h)
| extend round(availability_rate=total_available_hours*100/total_number_of_buckets,2)
| project ["Virtual Machine"]=Resource, ["Operating System"]=OSType, ["Subscription"]=SubscriptionId, ["Resource Group"]=RGroup, ["Start Time Range"]=format_datetime(utcmonthStart,'yy-MM-dd [HH:mm:ss]'), ["End Time Range"]=format_datetime(utcmonthEnd,'yy-MM-dd [HH:mm:ss]'), ["Availability Percentage"]=strcat(availability_rate, " %"), ["Total available hours"]=total_available_hours, ["Total hours"]=total_number_of_buckets, ["Managed by ${company}"]=strcat("VM ",Resource, " is deleted before end of the month")
"@

# variables to hold the batch size to be able to get paginated results.
$batchSize = 1000

# Determine day of month for timezone and on what day to create the monthly reports
# By default create on first day of (next) month
# if parameter used, report will have _manual_ in name to indicate it is not generated using the (default) schedule
$DayOfMonth = (Get-Date).addhours($UtcOffset).tostring('dd')
$manual = ""
If ($monthreportday -eq "00") {
    $monthreportday = $DayOfMonth
    $manual = "_MANUAL_"
}
#CSS
$header = @"
<style>

   table {
		font-size: 12px;
		border: 0px;
		font-family: Arial, Helvetica, sans-serif;
	}

    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}

    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
        text-align: left;
	}

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }
    .Managed {
    color: #008000;
    }

    .NotManaged {
    color: #ff0000;
    }
</style>
"@

# Get connected
try {

    try {

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

    # Get Reporting Storage Account
    $subscriptions = Get-AzSubscription
    $ctx = $null
    $SearchstorageAccountReporting = Search-AzGraph -Subscription $subscriptions -Query "resources| where (type == ""microsoft.storage/storageaccounts"" and tostring(tags) contains ""\""${tagPrefix}Purpose\"":\""${tagValuePrefix}Reporting\"""")| project Name=name, ResourceGroup=resourceGroup, subscriptionId"
    if ($null -eq $SearchstorageAccountReporting) {
        throw "No storage account with tag ${tagPrefix}Purpose = ${tagValuePrefix}Reporting found in all the customer subscriptions, aborting !"
    }

    #determine if there is only one reporting storage account
    if ($SearchstorageAccountReporting.count -gt 1) {
        Throw "More than one primary storage account with tag ${tagPrefix}Purpose = ${tagValuePrefix}Reporting found in subscriptions, aborting !"
    }
    elseif ($SearchstorageAccountReporting.count -eq 1) {
        # Get the <company>managed container context
        $context = set-azcontext $SearchstorageAccountReporting.subscriptionId
        $StorageAccountReporting = get-azstorageaccount -ResourceGroupName $SearchstorageAccountReporting.ResourceGroup -StorageAccountName $SearchstorageAccountReporting.Name
        $ctx = $StorageAccountReporting.context
        Write-Output $("Storage accountname             : " + $StorageAccountReporting.StorageAccountName)
        Write-Output $("Storage account resource group  : " + $StorageAccountReporting.ResourceGroupName)
        Write-Output $("Storage account subscription    : " + $context.Name)
        Write-Output $("Storage account ctx             : " + $ctx)
    }

    # Create reports on customer subscriptions
    Write-Output $("Subscriptions                   : " + $subscriptions)

    #Get managed loganalytics workspace in customer subscriptions
    $LogAnalyticsWorkspace = $null
    $SearchLogAnalytics = Search-AzGraph -Subscription $subscriptions -first 5 -Query "resources| where (type == ""microsoft.operationalinsights/workspaces"" and tostring(tags) contains ""\""${tagPrefix}Purpose\"":\""${tagValuePrefix}Monitoring\"""")| project name, customerid=properties.customerId"
    if ($null -ne $SearchLogAnalytics) {
        if ($SearchLogAnalytics.Count -gt 1) {
            throw "More than one primary ${company} managed log analytics workspace found in the customer subscriptions, aborting !"
        }
        else {
            $LogAnalyticsWorkspace = $SearchLogAnalytics
        }
    }
    if ($null -eq $LogAnalyticsWorkspace.name) {
        throw "No primary ${company} managed log analytics workspace found (with tag ${tagPrefix}Purpose = ${tagValuePrefix}Monitoring) in all the customer subscriptions, aborting !"
    }
    else {
        Write-Output $("Using log Analytics workspace   : " + $LogAnalyticsWorkspace.name)
    }

    # create Patching and Tagging report (Azure resource Graph)
    # determine previous month for report title and name
    If ($DayOfMonth -eq $monthreportday) {
        # If UtcOffset is positive, UTC time is still in previous month so name of previous month is determined correctly when runbook is scheduled at 0:00 local time.
        # If UtcOffset is zero or negative, UTC time is already in next month so need to subtract a month to get name of previous month (in UTC) when runbook is scheduled at 0:00 local time.
        If ($UtcOffset -gt 0) { $months = "0" } else { $months = "-1" }
        $date = (Get-Date).addmonths($months).tostring('yyyy/MM')
        $Title = -join ("VM Tagging and Patching monthly Report ", $date)

        # create temporary files for CSV and HTML report
        $tempcsvfile = New-TemporaryFile 
        $temphtmlfile = New-TemporaryFile 
        # execute query and filter out databricks vm workers

        #Initialize skipResult token to 0
        $skipResult = 0

        while ($true) {

            if ($skipResult -gt 0) {
                $graphResult = Search-AzGraph -Query $taggingAndPatchingkqlQuery   -first $batchSize -SkipToken $graphResult.SkipToken
            }
            else {
                $graphResult = Search-AzGraph -Query $taggingAndPatchingkqlQuery    -first $batchSize
            }

            $report += $graphResult.data

            if ($graphResult.data.Count -lt $batchSize) {
                break;
            }
            $skipResult += $skipResult + $batchSize
        }

        Write-Output "There will be $($report.count) resources in the report"

        # save result to temp file
        $report | export-csv -notype $tempcsvfile.FullName

        # Format HTML report
        If ($report.count -eq 0) { $Title = -join ($($Title), "<br><br><font color=""red""> - No Virtual Machines found! -</font>") }
        $PreContent = -join ("<h2>", $Title, "</h2>")
        $HTMLReport = $report | convertto-html -Title $Title -PreContent $PreContent -Head $header
        $HTMLReport = $HTMLReport -replace '<td>true</td>', '<td class="Managed">True</td>'
        $HTMLReport = $HTMLReport -replace '<td>false</td>', '<td class="NotManaged">False</td>'
        $HTMLReport | out-file -filepath $temphtmlfile.FullName
        $CSVname = "CSV Reports - " + $date + $manual + "_VM_tag_patching_Report.csv"
        $HTMLname = "HTML Reports - " + $date + $manual + "_VM_tag_patching_Report.html"

        # Put the CSV in the right container.
        Set-AzStorageBlobContent -File $tempcsvfile.FullName -Container 'offlinereports' -Blob $CSVname -Context $ctx -Force
        # Put the HTML in the right container.
        Set-AzStorageBlobContent -File $temphtmlfile.FullName -Container 'offlinereports' -Blob $HTMLname -Context $ctx -Force
    }

    # create monthly availability report (Log Analytics Workspace)
    # determine previous month for report title and file name
    If ($DayOfMonth -eq $monthreportday) {
        # If UtcOffset is positive, UTC time is still in previous month so name of previous month is determined correctly when runbook is scheduled at 0:00 local time.
        # If UtcOffset is zero or negative, UTC time is already in next month so need to subtract a month to get name of previous month (in UTC) when runbook is scheduled at 0:00 local time.
        If ($UtcOffset -gt 0) { $months = "0" } else { $months = "-1" }
        $date = (Get-Date).addmonths($months).tostring('yyyy/MM')
        $Title = -join ("VM availability monthly Report ", $date, " for log analytics workspace: ", $LogAnalyticsWorkspace.name)

        # if $manual="_MANUAL_" like for testing purposes report must be for current month otherwise result will probably be an empty report
        if ($manual -eq "_MANUAL_") {
            $Query = $availabilityKQLManualQuery 
        }
        else {
            $Query = $availabilityKQLQuery
        }

        # execute query
        $report = Invoke-AzOperationalInsightsQuery -WorkspaceId "$($LogAnalyticsWorkspace.customerid)" -Query $Query

        # Convert query result to CSV
        $CSVreport = $report.results | convertto-csv -notypeInformation

        # execute query for availability report (tagged VM)
        # initialize skipResult token to 0 and make graphresult empty
        $skipResult = 0
        $graphResult = $null

        while ($true) {

            if ($skipResult -gt 0) {
                $graphResult = Search-AzGraph -Query $availabilityKqlQueryTaggedVm  -first $batchSize -SkipToken $graphResult.SkipToken
            }
            else {
                $graphResult = Search-AzGraph -Query $availabilityKqlQueryTaggedVm   -first $batchSize
            }

            $Managedvms += $graphResult.data

            if ($graphResult.data.Count -lt $batchSize) {
                break;
            }
            $skipResult += $skipResult + $batchSize
        }

        # execute query for availability report (All VM)

        # initialize skipResult token to 0 and make graphresult empty
        $skipResult = 0
        $graphResult = $null

        while ($true) {

            if ($skipResult -gt 0) {
                $graphResult = Search-AzGraph -Query $availabilityKqlQueryAllVm  -first $batchSize -SkipToken $graphResult.SkipToken
            }
            else {
                $graphResult = Search-AzGraph -Query $availabilityKqlQueryAllVm   -first $batchSize
            }

            $Allvms += $graphResult.data

            if ($graphResult.data.Count -lt $batchSize) {
                break;
            }
            $skipResult += $skipResult + $batchSize
        }

        # Determine if VM is <company>Managed and put True or False in column 'Managed by <company>'.
        # or, if VM is not available in Azure at the moment the report is created, message that the vm is deleted before the end of the month.
        $Managedtag = ${tagPrefix} + 'Managed'
        foreach ($vmname in $Managedvms) {
            $CSVReport = $CSVReport -replace $($vmname.${Managedtag}), 'True'
        }
        foreach ($vmname in $Allvms) {
            $CSVReport = $CSVReport -replace $($vmname.${Managedtag}), 'False'
        }

        # add subscription names instead of subscriptionId for CSV report
        foreach ($subscription in $subscriptions) {
            $CSVReport = $CSVReport -replace $($subscription.Id), $($subscription.name)
        }
        #Save CSV report to temp file.
        $CSVReport | out-file -filepath $tempcsvfile.FullName

        # Format HTML report, add title in HTML content and  format content
        # First check if report is not empty by converting results to array and check number of rows.
        $resultsArray = [System.Linq.Enumerable]::ToArray($report.Results)
        If ($resultsArray.count -eq 0) { $Title = -join ($($Title), "<br><br><font color=""red""> - No Virtual Machines connected to Log Analytics Workspace found for this month! -</font>") }
        $PreContent = -join ("<h2>", $Title, "</h2>")
        $HTMLReport = $report.results | convertto-html -PreContent $PreContent -Head $header

        # Determine if VM is Managed and put True or False in column 'Managed by <company>'.
        # or, if VM is not available in Azure at the moment the report is created, message that the vm is deleted before the end of the month.
        $Managedtag = ${tagPrefix} + 'Managed'
        foreach ($vmname in $Managedvms) {
            $HTMLReport = $HTMLReport -replace $($vmname.${Managedtag}), 'True'
        }
        foreach ($vmname in $Allvms) {
            $HTMLReport = $HTMLReport -replace $($vmname.${Managedtag}), 'False'
        }
    
        # add subscription names instead of subscriptionId for HTML report
        foreach ($subscription in $subscriptions) {
            $HTMLReport = $HTMLReport -replace $($subscription.Id), $($subscription.name)
        }

        # show <company>Managed tags in green (True) or red (false) if available in report
        $HTMLReport = $HTMLReport -replace '<td>true</td>', '<td class="Managed">True</td>'
        $HTMLReport = $HTMLReport -replace '<td>false</td>', '<td class="NotManaged">False</td>'
    
        #Save HTML report to temp file.
        $HTMLReport | out-file -filepath $temphtmlfile.FullName

        # create CSV and HTML file names with year and month information with a folder per type per year like "CSV Reports-2021/Dec_VM_Availability_Report.csv"
        $CSVname = "CSV Reports - " + $date + $manual + "_VM_Availability_Report.csv"
        $HTMLname = "HTML Reports - " + $date + $manual + "_VM_Availability_Report.html"
    
        # Put the CSV and HTML files in the offlinereports container.
        Set-AzStorageBlobContent -File $tempcsvfile.FullName -Container 'offlinereports' -Blob $CSVname -Context $ctx -Force
        Set-AzStorageBlobContent -File $temphtmlfile.FullName -Container 'offlinereports' -Blob $HTMLname -Context $ctx -Force
    }
}
catch {
    throw $_.Exception
}

