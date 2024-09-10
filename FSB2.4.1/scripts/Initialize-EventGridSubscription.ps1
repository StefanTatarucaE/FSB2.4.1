function Initialize-EventGridSubscription {
  <#
    .SYNOPSIS
        Initializes eventgrid subscription for a functionApp function resource id, logicApp webhook url or automationAccount runbook webook url.

    .DESCRIPTION
        The function in this script file use the specific resources cmdlet to gather the necessary information,
        by locating the resource using the provided tag. If multiple resource of the same type and tags are found, the script will fail.
        With the information the New-AzEventGridSubscription or Update-AzEventGridSubscription cmdlet is used to create or update an eventgrid subscription.

        Dot source this file before being able to use the function in this file.
        To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
        . .\Initialize-EventGridSubscription.ps1

        Warning : The module 'Az.ResourceGraph' is required when using runbook webhook registration

    .PARAMETER eventSubscriptionName
        Specifies the namespace of the Resource Provider to register.

    .PARAMETER resourceType
        Specifies the type of the resource to create an eventgrid subscription for. Currently suported resource types are:
        - Microsoft.Web/sites (Function-Apps)
        - Microsoft.Logic/workflows (Logic-Apps)
        - Microsoft.Automation/automationAccounts/runbooks (Runbooks)

    .PARAMETER resourceTagName
        Specifies the tag name of the resource to create an eventgrid subscription for.

    .PARAMETER resourceTagValue
        Specifies the tag value (which goes with the tag name) of the resource to create an eventgrid subscription for.

    .PARAMETER functionName
        Optional parameter. Specifies the function name to create an eventgrid subscription for.
        (This enables functionality to find a specific function if multiple ones are configured on 1 functionApp)
        It is not necessary to specify this when creating eventgrid subscriptions for logicApp or automationAccount/runbook.

    .PARAMETER advancedFilters
        Specifies the advanced filters which holds an array of multiple Hashtable values that are used for the attribute-based filtering. 
        Each Hashtable value has the following keys-value info: Operation, Key and Value or Values.

        For more information on the Operator, Key or Values 'keys', see the Microsoft Docs [page](https://docs.microsoft.com/en-us/powershell/module/az.eventgrid/new-azeventgridsubscription?view=azps-8.2.0#parameters).

        As an example of the advanced filter parameters:
        $advancedFilters=@($filter1, $filter2) where
        $filter1=@{operator="StringBeginsWith"; key="data.authorization.action"; Values=@('Microsoft.Resources/tags/write')} and 
        $filter2=@{operator="StringIn"; key="data.operationName"; Values=@('Microsoft.Sql/servers/write')}

    .PARAMETER includedEventType
        Specifies the array that holds the list of event types to include.

    .PARAMETER targetSubscriptionId
        Specifies the subscription id of the subscription, where the resources are configured,
        for which eventgrid subscriptions are being created.

    .PARAMETER sourceSubscriptionId
        Specifies the subscription id of the subscription, where the eventgrid subscriptions are being created.

    .PARAMETER subscriptionCode
        Specifies the subscription code of the subscription, where the eventgrid subscriptions are being created.
        This is used to create a specific name for the automation account runbook webhook name.

        Example values are: 'mgmt', 'cnty', 'lnd1', 'lnd9', 'tool'

    .PARAMETER inputJson
        Specifies the json file which holds the parameter values to be used with this function.

    .INPUTS
        None.

    .OUTPUTS
        $eventGridSubscriptionObject. A PS custom object containg info about the created eventgrid subscription.

    .NOTES
        Version:        0.8
        Author:         frederic.trapet@eviden.com
        Creation Date:  20220816
        Purpose/Change: Updated for rebranding and white labeling
 
    .EXAMPLE
        Using the parameters (except for inputJson) directly:

        $filter1 = @{
            operator = 'StringBeginsWith'
            key = 'data.authorization.action'
            Values = @('Microsoft.Compute/virtualMachines/write','Microsoft.Compute/virtualMachines/start/action')
        }
        $filter2 = @{
            operator = 'StringBeginsWith'
            key = 'data.authorization.action'
            Values = @('Microsoft.Resources/tags/write','Microsoft.EventGrid/eventSubscriptions/write','Microsoft.Compute/virtualMachines/write')
        }
        $advancedFilters = @($filter1, $filter2)

        $params = @{
            eventSubscriptionName = 'funcapp-eventgrid-OSVersionTag'
            resourceType = 'Microsoft.Web/sites'
            resourceTagName = 'myCompanyPurpose'
            resourceTagValue = 'myCompanyOsTagging'
            functionName = 'vse-lnd1-d-functionapp-ostagging'
            includedEventType = @('Microsoft.Resources.ResourceWriteSuccess','Microsoft.Resources.ResourceActionSuccess')
            advancedFilters = $advancedFilters
            targetSubscriptionId = 'xxxxx xxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
            sourceSubscriptionId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
            subscriptionCode = 'mgmt'
        }
        Initialize-EventGridSubscription @params

        Or using the inputJson parameter to read in the parameter values from a json file:

        Initialize-EventGridSubscription -inputJson '.\input\evGridSub.lapp.itsmos.json' -Verbose

  #>
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
    [string]$eventSubscriptionName,

    [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
    [string]$resourceType,

    [Parameter(Position = 2, ValueFromPipelineByPropertyName)]
    [string]$resourceTagName,

    [Parameter(Position = 3, ValueFromPipelineByPropertyName)]
    [string]$resourceTagValue,

    [Parameter(Position = 4, ValueFromPipelineByPropertyName)]
    [string]$functionName,

    [Parameter(Position = 5, ValueFromPipelineByPropertyName)]
    [pscustomobject]$advancedFilters,

    [Parameter(Position = 6, ValueFromPipelineByPropertyName)]
    [string[]]$includedEventType,

    [Parameter(Position = 7, ValueFromPipelineByPropertyName)]
    [string]$targetSubscriptionId,

    [Parameter(Position = 8, ValueFromPipelineByPropertyName)]
    [string]$sourceSubscriptionId,

    [Parameter(Position = 9, ValueFromPipelineByPropertyName)]
    [string]$subscriptionCode,

    [Parameter(Position = 10, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]$inputJson
  )

  begin {
    if (-not ([string]::IsNullOrEmpty($inputJson))) {

      # If the $inputJson parameter is not empty use it to set the parameter values provided in the json file
      if (Test-Path -Path $inputJson) {
        $jsonObject = Get-Content -Path $inputJson -Raw | ConvertFrom-Json

        Write-Verbose "The json file has been succesfully loaded."
        Write-Verbose "Load result: $jsonObject"

        $resourceType = $jsonObject.resourceType

        # If no value is provided in the $resourceTagName parameter, use the json file value
        if ([string]::IsNullOrEmpty($resourceTagName)) {
          $resourceTagName = $jsonObject.resourceTagName
        }

        # If no value is provided in the $resourceTagValue parameter, use the json file value
        if ([string]::IsNullOrEmpty($resourceTagValue)) {
          $resourceTagValue = $jsonObject.resourceTagValue
        }

        $includedEventType = $jsonObject.includedEventType

        # If no value is provided in the $eventSubscripionName parameter, use the json file value
        if ([string]::IsNullOrEmpty($eventSubscriptionName)) {
          $eventSubscriptionName = $jsonObject.eventSubscriptionName
        }

        # If no value is provided in the $functionName parameter, use the json file value
        if ([string]::IsNullOrEmpty($functionName)) {
          $functionName = $jsonObject.functionName
        }

        # If no value is provided in the $targetSubscriptionId  parameter, use the json file value
        if ([string]::IsNullOrEmpty($targetSubscriptionId)) {
          $targetSubscriptionId = $jsonObject.targetSubscriptionId
        }

        # If no value is provided in the $sourceSubscriptionId parameter, use the json file value
        if ([string]::IsNullOrEmpty($sourceSubscriptionId)) {
          $sourceSubscriptionId = $jsonObject.sourceSubscriptionId
        }

        # The array of objects in the json file needs to be converted to a hashtable 
        # for the New-AzEventGridSubscription & Update-AzEventGridSubscription cmdlets to be able to accept it as a parameter 
        $advancedFilters = foreach ($filter in $jsonObject.advancedFilters) {
          [hashtable]@{
            operator = $filter.operator
            key      = $filter.key
            Values   = $filter.Values
          }
        }

        Write-Verbose "All necessary parameters for this function has been set."
      }
    }

    # Set the Azure context to the target subscriptionId (where the resources are which are targeted for eventgrid subcription)
    $azTargetContext = Set-AzContext -Subscription $targetSubscriptionId -WarningAction SilentlyContinue

    Write-Verbose "Switched context to $($azTargetContext.Name)"

    if ($azTargetContext) {

      # Get the dedicated cmdlet to get the resource using the tag name & value provided & store the results in the azResourceObject
      Write-Verbose "Retrieving resource of type '$($resourceType)' using tagname '$($resourceTagName)' : tagvalue '$($resourceTagValue)' to find the correct resource."

      # Check to see if the current object being processed is of the functionApp resourcetype
      if ($resourceType -like '*.Web/sites') {
        $azResource = Search-AzGraph -Query "resources| where (type == ""microsoft.web/sites"" and tostring(tags) contains ""\""$($resourceTagName)\"":\""$($resourceTagValue)\"""")"
      }

      # Check to see if the current object being processed is of the logicApp resourcetype
      elseif ($resourceType -like '*.Logic/workflows') {
        $azResource = Search-AzGraph -Query "resources| where (type == ""microsoft.logic/workflows"" and tostring(tags) contains ""\""$($resourceTagName)\"":\""$($resourceTagValue)\"""")"
      }

      # Check to see if the current object being processed is of the automationAccounts/runbooks resourcetype
      elseif ($resourceType -like '*.Automation/automationAccounts/runbooks') {
        $azResource = Search-AzGraph -Query "resources| where (type == ""microsoft.automation/automationaccounts/runbooks"" and tostring(tags) contains ""\""$($resourceTagName)\"":\""$($resourceTagValue)\"""")"
      }
      else {
        Write-Error "Unsupported resource type '$($resourceType)' detected. Currently no support for this resource type available." -ErrorAction 'Stop'
      }

    }
    else {
      Write-Error 'No azure context found. Retry with the correct subscriptionId' -ErrorAction 'Stop'
    }

    # Test if the provided tag name & value has returned Az Resource(s)
    if ($azResource) {
      if ($azResource.count -eq 1) {
        $resourceName = $azResource.Name
        $resourceGroupName = ($azResource.Id -split '/')[4]
        $resourceId = $azResource.id
        Write-Verbose "A resource has been found; name: '$($resourceName)' resourcegroup: '$($resourceGroupName)'"
      }
      else {
        Write-Error 'More than one resource found with the provided parameters, aborting.' -ErrorAction 'Stop'
      }
    }
    else {
      Write-Error 'No resource found with the provided parameters, aborting.' -ErrorAction 'Stop'
    }

    # Splat the parameters needed to create or update the necessary eventgrid subscription.
    $eventGridSubscriptionParams = @{
      EventSubscriptionName = $eventSubscriptionName
      IncludedEventType     = $includedEventType
      AdvancedFilter        = $advancedFilters
    }
  }

  process {
    # Process the resource
    try {
      # Check to see if the current object being processed is of the functionApp resourcetype
      if ($resourceType -like '*.Web/sites') {
        Write-Verbose "Resource type '$($resourceType)' detected. Preparing FunctionApp eventgrid subscription..."

        # functionApp functions can not be tagged and thus can not be targeted directly...
        # ...setting necessary variables (using splatting) to get the function(s) on the functionApp
        # Using the native Azure REST API to obtain the function list, as Get-AzResource is sometime not reliable
        $azFunctionAppApi = '2022-03-01'
        $webAppApiParams = @{
          Authentication = 'Bearer'
          Method         = 'GET'
          Token          = ConvertTo-SecureString -String ((Get-AzAccessToken).Token) -AsPlainText -Force
          ContentType    = 'application/json'
          Uri            = 'https://management.azure.com' + $resourceId + '/functions?api-version=' + $azFunctionAppApi
        }
        $functions = (Invoke-RestMethod @webAppApiParams).value

        # Process every function in the functions object & compare to the provided function name, 
        # if there is a match, an eventgrid subscription will be created for the function.
        $functionResourceId = $null
        foreach ($function in $functions) {
          $detectedFunctionName = ($function.Name -split '/')[1]
          if ($detectedFunctionName -eq $functionName) {
            # Set the resourceId of the function to a variable
            [string]$functionResourceId = $function.id
          }
        }

        # Fail if the function cannot be found in the function-app
        if (-Not($functionResourceId)) {
          Write-Error "Failed to find the function '$($functionName)' in the Function App" -ErrorAction 'Stop'
        }

        # Add in the extra information for the function to the splat hashtable to be used when creating or updating the eventgrid subscription
        $eventGridSubscriptionParams['Endpoint'] = $functionResourceId
        $eventGridSubscriptionParams['EndpointType'] = 'azurefunction'
      }

      # Check to see if the current object being processed is of the logicApp resourcetype
      elseif ($resourceType -like '*.Logic/workflows') {

        # check if logic app is enabled and if not enable for the actions to follow
        $logicAppStatus = Get-AzLogicApp -ResourceGroupName $resourceGroupName -Name  $resourceName
        if ($logicAppStatus.State -ne 'Enabled') {
          Write-Verbose "Enabling logic app: '$($resourceName)'"
          Set-AzLogicApp -ResourceGroupName $resourceGroupName -Name $resourceName -State 'Enabled' -Force
          $wasDisabled = $true
        }

        Write-Verbose "Resource type '$($resourceType)' detected. Preparing logicApp eventgrid subscription..."

        # Splatting the necessary info to be able to query the logicApp url needed for the eventgrid subscription creation or update
        $logicAppParams = @{
          ResourceGroupName = $resourceGroupName
          Name              = $resourceName
          TriggerName       = "manual"
        }
        [string]$webhookUrl = (Get-AzLogicAppTriggerCallbackUrl @logicAppParams).Value

        # Add in the extra information for the function to the splat hashtable to be used when creating or updating the eventgrid subscription
        $eventGridSubscriptionParams['Endpoint'] = $webhookUrl
        $eventGridSubscriptionParams['EndpointType'] = 'webhook'
      }

      # Check to see if the current object being processed is of the automationAccounts/runbooks resourcetype
      elseif ($resourceType -like '*.Automation/automationAccounts/runbooks') {
        Write-Verbose "Resource type '$($resourceType)' detected. Preparing automationAccounts/runbook eventgrid subscription..."

        # If a current webhook is configured on a runbook, the corresponding webhook url needed for eventgrid subscription creation...
        # ...or update is not available. The webhook url is only available during creation.
        # So the necessary information is retrieved, saved in variables & splatted to be used to get the webhook, remove it if present & create a new one.
        $AutomationAccountName = ($resourceId -split '/')[8]
        $runbookName = $resourceName
        $webhookName = -join ($runbookName, '-webhook-', $subscriptionCode)
        Write-Verbose "Automation account name is '$($AutomationAccountName)'"

        $runbookParams = @{
          AutomationAccountName = $AutomationAccountName
          ResourceGroupName     = $resourceGroupName
          RunbookName           = $runbookName
        }
        $existingWebhook = Get-AzAutomationWebhook @runbookParams

        if (-not $existingWebhook) {
          Write-Verbose "No Webhook data found.."
        }
        else {
          foreach ($hook in $existingWebhook) {
            if ($hook.Name -eq $webhookName) {
              Write-Verbose "Removing the existing webhook: '$($hook.Name)' from runbook: '$($runbookName)'"
              $hook | Remove-AzAutomationWebhook -Verbose
            }
          }
        }

        Write-Verbose "Setting webhook config details for: '$($webhookName)' connected to runbook: '$($runbookName)'"
        $expiryTime = ((Get-Date).AddMonths(6))

        $runbookParams['Name'] = $webhookName
        $runbookParams['ExpiryTime'] = $expiryTime
        $runbookParams['IsEnabled'] = $True
        $runbookParams['Force'] = $True
        # Creating the new webhook
        $newWebhook = New-AzAutomationWebhook @runbookParams

        # Store the webhook url
        [string]$webhookUrl = $newWebhook.WebhookURI

        # Add in the extra information for the function to the splat hashtable to be used when creating or updating the eventgrid subscription
        $eventGridSubscriptionParams['Endpoint'] = $webhookUrl
        $eventGridSubscriptionParams['EndpointType'] = 'webhook'
      }

      else {
        Write-Error "Unsupported resource type '$($resourceType)' detected. Currently no support for this resource type available." -ErrorAction 'Stop'
      }
    }
    catch {
      Write-Error "Failed detecting or constructing information needed for setting the correct Endpoint values. $($_.Exception.Message)" -ErrorAction 'Stop'
    }

    # Set the Azure context to the source subscriptionId (where the eventgrid subcription is being created)
    $azSourceContext = Set-AzContext -Subscription $sourceSubscriptionId -WarningAction SilentlyContinue

    Write-Verbose "Switched context to $($azSourceContext.Name)"

    if (-not $azSourceContext) {
      Write-Error 'No azure context found. Retry with the correct subscriptionId' -ErrorAction 'Stop'
    }

    # Retrieving the eventgrid subscription which was provided as a parameter
    $exisitingEventGridSubscriptionParams = @{
      EventSubscriptionName = $eventSubscriptionName
      ErrorAction           = 'SilentlyContinue'
    }
    $exisitingEventGridSubscription = Get-AzEventGridSubscription @exisitingEventGridSubscriptionParams

    $maxEventgridRetries = 5
    $nbTry = 0
    Do {
      $nbtry++
      try {
        # Check to see if the eventgrid subscription is already present if yes update, if no create it.
        if (-not $exisitingEventGridSubscription) {
          Write-Verbose "No eventgrid subscription:'$($eventSubscriptionName)' detected, creating a new one..."
          $eventGridSubscription = New-AzEventGridSubscription @eventGridSubscriptionParams
        }
        else {
          Write-Verbose "Eventgrid subscription named:'$($eventSubscriptionName)' detected, updating it..."
          $eventGridSubscription = Update-AzEventGridSubscription @eventGridSubscriptionParams
        }
      }
      catch {
        $eventGridSubscription = $null
        Write-Verbose ("Failed creating or updating an eventgrid subscription : $($_.ToString()) retry " + $nbTry + "/" + $maxEventgridRetries)
        Start-Sleep -Seconds 30
      }
    } until (($null -ne $eventGridSubscription) -or ($nbtry -eq $maxEventgridRetries))
    If ($null -eq $eventGridSubscription) {
      Write-Error ("Failed creating or updating an eventgrid subscription : $($_.ToString())") -ErrorAction 'Stop'
    }

    # If the logic app was disabled, re-enable it
    if ($wasDisabled) {
      Write-Verbose "Disabling logic app: '$($resourceName)'"
      # Set the Azure context to the target subscriptionId (where the resources are which are targeted for eventgrid subcription)
      $azTargetContext = Set-AzContext -Subscription $targetSubscriptionId -WarningAction SilentlyContinue
      Set-AzLogicApp -ResourceGroupName $resourceGroupName -Name $resourceName -State 'Disabled' -Force
    }

    # Create a custom object of the updated or created eventgrid subscription & output it
    $eventGridSubscriptionObject = $eventGridSubscription | Select-Object EventSubscriptionName, Id, Type, ProvisioningState, Endpoint
    Write-Output $eventGridSubscriptionObject
  }

  end {
    # intentionally empty
  }
}