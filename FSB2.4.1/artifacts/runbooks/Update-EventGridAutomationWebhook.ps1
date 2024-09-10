<#
    .SYNOPSIS
        Creation of Automation Webhooks on Eventdriven runbooks in the MGMT automation account.
        Creation & registration of Webhooks with Eventgrid Azure subscription events.

    .DESCRIPTION
        This is a scheduled automation runbook which runs once a month. Thew runbook refreshes the
        webhook for the disk encryption solution. The disk encryption solution is deployed with an expiry
        date on the webhook which needs to be refreshed to keep the solution working.

        The runbook is setup in a generic way to enable easy addition of future solutions.

    .OUTPUTS
        N/A

    .NOTES
        Author:     Bart Decker
        Company:    Eviden
        Email:      bart.decker@eviden.com
        Created:    2021-09-01
        Updated:    2023-08-07
        Changes:    Adjusted for Bicep release.
        Version:    1.0
#>


#region [function]
# Find the primary Automation Account by searching in all customer subscription (based on the special tag)
Function Search-customerManagementAutomationAccount {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope = 'Function')]
    Param(
        [Parameter(Mandatory = $False)]
        [string] $tagName,

        [Parameter(Mandatory = $False)]
        [string] $tagValue,

        [Parameter(Mandatory = $False)]
        [string] $company
    )
    $Subscriptions = Get-AzSubscription
    $AutomationAccountObject = $null
    $SearchAutomationAccount = Search-AzGraph -Subscription $Subscriptions -Query "resources| where (type == ""microsoft.automation/automationaccounts"" and tostring(tags) contains ""\""$($tagName)\"":\""$($tagValue)\"""")| project Name=name, ResourceGroupName=resourceGroup, CustomerId=properties.customerId, SubscriptionId=subscriptionId, ResourceId=id"

    if ($null -ne $SearchAutomationAccount ) {
        if ($SearchAutomationAccount.Count -gt 1) {
            throw "More than one primary $($company) Automation Account found in the customer subscriptions, aborting !"
        }
        else {
            $AutomationAccountObject = $SearchAutomationAccount
        }
    }
    if ( $null -eq $AutomationAccountObject) {
        throw "No primary $($company) Automation account found in all the customer subscriptions, aborting !"
    }
    else {
        Set-AzContext -Subscription $AutomationAccountObject.SubscriptionId | Out-Null
        $AutomationAccount = Get-AzAutomationAccount -Name $AutomationAccountObject.Name -ResourceGroupName $AutomationAccountObject.ResourceGroupName
        Write-Output "Found Automation Account [$($AutomationAccount.Name)]"

        # Return data
        return [hashtable] @{
        AutomationAccount   = $AutomationAccount
        }
    }
}
#endregion [function]


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

# Define branding variables needed for the Execute-VMEncryption runbook from the automation account variables

$tagPrefix = Get-AutomationVariable -Name 'tagPrefix'
$tagValuePrefix = Get-AutomationVariable -Name 'tagValuePrefix'
$company = Get-AutomationVariable -Name 'company'

# Tags & Tag Values used in the Execute-VMEncryption runbook.
$tagName = "$($tagPrefix)Purpose"
$tagValue = "$($tagValuePrefix)Automation"

#region [Initialization Variables]----------------------------------------------------------------------------------------------------------
#data array with runbook & evengrid details. Add second data element for upcoming runbooks.

$array = @(

    @{  eventName        = 'evgs-rb-osdiskencrypt';
        webhookName      = 'VMEncryption-webhook';
        runbookName      = 'OSMGMT-Execute-VMEncryption';
        includeEventType = "Microsoft.Resources.ResourceWriteSuccess";
        endpointType     = "webhook";
        filter1          = @{
            operator = 'StringBeginsWith'
            key      = 'data.operationName'
            Values   = @('Microsoft.Compute/virtualMachines/write', "Microsoft.Resources/tags/write")
        };
        filter2          = @{
            operator = 'StringContains'
            key      = 'data.authorization.scope'
            Values   = @('Microsoft.Compute/virtualMachines')
        };
        filter3          = @{
            operator = 'StringBeginsWith'
            key      = 'data.authorization.action'
            Values   = @('Microsoft.Resources/tags/write')
        }
    }
)

#Set subscriptions to take action on
$subscriptions = Get-AzSubscription
Write-Output "Subscriptions where webhooks on runbooks will be created or modified are:" $subscriptions.name

# Find out MGMT Subscription with the help of Tags and management resource automation account

$automationAccountSearch = Search-customerManagementAutomationAccount -tagname $tagName -tagValue $tagValue -company $company
$automationAccount = $automationAccountSearch.AutomationAccount

#Set Variables to be used when creating a new webhook
$dateAppend = Get-Date -Format "yyMMhhmmss"
$expiryDate = ((Get-Date).AddMonths(1))

#endregion [Initialization Variables]

#region [Webhook & EventGrid logic]----------------------------------------------------------------------------------------------------------
foreach ($data in $array) {

    #Set variables for events, webhooks & runbooks to create or modify

    $eventGridProperties = @{
        EventSubscriptionName = $data.eventName
        AdvancedFilter        = @($data.filter1, $data.filter2, $data.filter3)
        IncludedEventType     = $data.includeEventType
        EndpointType          = $data.endpointType
    }

    #Create the web hook
    Write-Output "Get the AutomationWebhook from runbook: $($data.runbookName) in resourcegroup: $($automationAccount.ResourceGroupName)"

    $CommonRunbookParams = @{
        RunbookName           = $data.runbookName
        ResourceGroup         = $automationAccount.ResourceGroupName
        AutomationAccountName = $automationAccount.AutomationAccountName
    }

    $existingWebhook = Get-AzAutomationWebhook @CommonRunbookParams
    write-output $existingWebhook
    #Removing existing webhooks before creating a new one
    if (-not $existingWebhook) {
        Write-Output "No Webhook data in $existingWebhook"
    }
    else {
        Get-AzAutomationWebhook @CommonRunbookParams | Remove-AzAutomationWebhook -Verbose
    }

    $webHookName = -join ($data.webhookName, $dateAppend)

    $newRunbookParams = @{
        Name                  = $webHookName
        IsEnabled             = $True
        ExpiryTime            = $expiryDate
        RunbookName           = $data.runbookName
        ResourceGroup         = $automationAccount.ResourceGroupName
        AutomationAccountName = $automationAccount.AutomationAccountName
        Force                 = $True
    }

    #Creating the new webhook
    $webhookResult = New-AzAutomationWebhook @NewRunbookParams
    Write-Output "Created new webhook with name:  $($webhookResult.Name)"
    [string]$webhookUrl = $webhookResult.WebhookURI
    $eventGridProperties['Endpoint'] = $webhookUrl

    #Create the eventgrid eventsubscriptions on the customer subscriptions
    foreach ($subscription in $subscriptions) {

        $subscriptionId = $subscription.Id
        $Subcontext = Get-AzContext -ListAvailable | Where-Object {$_.Subscription -like $subscriptionId}

        $eventExist = Get-AzEventGridSubscription -EventSubscriptionName $data.eventName -ErrorAction SilentlyContinue -DefaultProfile $Subcontext

        # Check if the eventsubscription we want to update is there.
        if ($eventExist.EventSubscriptionName -eq $data.eventName) {
            Write-Output "Reconfiguring the webhook for subscription: $subscription and runbook: $($data.runbookname)"
            Update-AzEventGridSubscription @eventGridProperties -DefaultProfile $Subcontext
        }
        else {
            Write-Output "No Event Subscription found to reconfigure"
        }
    }
}
#endregion [Webhook & EventGrid logic]