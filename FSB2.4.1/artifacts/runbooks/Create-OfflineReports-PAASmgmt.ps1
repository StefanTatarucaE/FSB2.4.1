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

# kql Query to retrieve all <company>Managed: True tagged PAAS resources.
$paasresourcesKQLQuery = @"
resources
| where type in~ ("microsoft.sql/servers","microsoft.sql/managedinstances","microsoft.datafactory/factories","microsoft.analysisservices/servers","microsoft.databricks/workspaces","microsoft.web/sites","microsoft.network/applicationgateways","microsoft.documentdb/databaseaccounts","microsoft.cache/redis","microsoft.dbformysql/servers","microsoft.dbformysql/flexibleservers","microsoft.dbformariadb/servers","microsoft.dbformysql/flexibleservers","microsoft.dbforpostgresql/flexibleservers","microsoft.dbforpostgresql/servergroups","microsoft.dbforpostgresql/servergroupsv2","microsoft.dbforpostgresql/servers","microsoft.dbforpostgresql/serversv2","microsoft.kusto/clusters","microsoft.sql/instancepools","microsoft.sql/servers/databases","microsoft.sql/servers/elasticpools","microsoft.synapse/privatelinkhubs","microsoft.synapse/workspaces","microsoft.synapse/workspaces/sqlpools","microsoft.synapse/workspaces/sqldatabases","microsoft.azurearcdata/postgresinstances","microsoft.containerregistry/registries","microsoft.containerservice/managedclusters", "microsoft.containerservice/containerservices","Microsoft.Logic/workflows") 
| extend ${tagPrefix}Managed = iff(tostring(tags) has '"${tagPrefix}Managed":"true"', "True", "False") 
| join kind=leftouter (resourcecontainers 
| where type == "microsoft.resources/subscriptions" 
| project subscriptionId, subname=name) on subscriptionId 
| project Name=name, Type=type, ["Resource Group"]=resourceGroup, Subscription=subname, Location=location, ["${tagPrefix} Managed"]=${tagPrefix}Managed | order by Type asc
"@

# Variables to hold the batch size to be able to get paginated results.
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

    #Get Managed loganalytics workspace in customer subscriptions
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

    # create PAAS Service overview with Managed State report (Azure resource Graph)
    # determine previous month for report title and name
    If ($DayOfMonth -eq $monthreportday) {
        # If UtcOffset is positive, UTC time is still in previous month so name of previous month is determined correctly when runbook is scheduled at 0:00 local time.
        # If UtcOffset is zero or negative, UTC time is already in next month so need to subtract a month to get name of previous month (in UTC) when runbook is scheduled at 0:00 local time.
        If ($UtcOffset -gt 0) { $months = "0" } else { $months = "-1" }

        $date = (Get-Date).addmonths($months).tostring('yyyy/MM')
        $Title = -join ("PAAS Service overview with ${tagPrefix}Managed State monthly Report ", $date)

        # create temporary files for CSV and HTML report
        $tempcsvfile = New-TemporaryFile 
        $temphtmlfile = New-TemporaryFile 

        # execute query

        # initialize skipResult token to 0 and make graphresult empty
        $skipResult = 0
        $graphResult = $null

        while ($true) {

            if ($skipResult -gt 0) {
                $graphResult = Search-AzGraph -Query $paasresourcesKQLQuery   -first $batchSize -SkipToken $graphResult.SkipToken
            }
            else {
                $graphResult = Search-AzGraph -Query $paasresourcesKQLQuery   -first $batchSize
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
        If ($report.count -eq 0) { $Title = -join ($($Title), "<br><br><font color=""red""> - No PAAS Services found! -</font>") }
        $PreContent = -join ("<h2>", $Title, "</h2>")
        $HTMLReport = $report | convertto-html -Title $Title -PreContent $PreContent -Head $header
        $HTMLReport = $HTMLReport -replace '<td>true</td>', '<td class="Managed">True</td>'
        $HTMLReport = $HTMLReport -replace '<td>false</td>', '<td class="NotManaged">False</td>'
        $HTMLReport | out-file -filepath $temphtmlfile.FullName
        $CSVname = "CSV Reports - " + $date + $manual + "_Paas_Services_${tagPrefix}Managed_tag_Report.csv"
        $HTMLname = "HTML Reports - " + $date + $manual + "_Paas_Services_${tagPrefix}Managed_tag_Report.html"

        # Put the CSV in the right container.
        Set-AzStorageBlobContent -File $tempcsvfile.FullName -Container 'offlinereports' -Blob $CSVname -Context $ctx -Force
        # Put the HTML in the right container.
        Set-AzStorageBlobContent -File $temphtmlfile.FullName -Container 'offlinereports' -Blob $HTMLname -Context $ctx -Force
    }
    # Next Report

}
catch {
    throw $_.Exception
}

