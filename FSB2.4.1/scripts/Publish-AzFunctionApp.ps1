<#
.SYNOPSIS
    Publishes the code to Azure function app. 

.DESCRIPTION
    This function will deploy the code in the Azure Function app. This is a generic function and can deploy any function app powershell or python. However the correct app should be selected with the correct runtime. There is no option to select the runtime in this code. Here the assumption is made that we will be deploying using a ubuntu machine using pipelines as the code is tailored for linux machines.
    If we want to use Custom roles below are the permissions needed
    "permissions": [
            {
                "actions": [
                    "Microsoft.Web/sites/config/list/Action",
                    "Microsoft.Web/sites/publishxml/Action",
                    "Microsoft.Resources/subscriptions/resourceGroups/read",
                    "Microsoft.Web/sites/Read",
                    "Microsoft.Web/sites/slots/Read",
                    "Microsoft.Web/sites/config/Read",
                    "microsoft.web/sites/config/web/appsettings/read",
                    "microsoft.web/sites/config/web/connectionstrings/read",
                    "microsoft.web/sites/config/appsettings/read",
                    "microsoft.web/sites/networkfeatures/read",
                    "microsoft.web/sites/slots/networkConfig/read",
                    "Microsoft.Web/sites/slots/config/Read",
                    "microsoft.web/sites/slots/config/appsettings/read",
                    "microsoft.web/sites/slots/config/web/connectionstrings/read",
                    "microsoft.web/sites/slots/deployments/read",
                    "microsoft.web/sites/functions/read"
                ],
                "notActions": [],
                "dataActions": [],
                "notDataActions": []
            }
        ]

.PARAMETER $functionApp
    Specifies the Azure Function where the code has to be deployed. Again the correct app should be selected with the correct runtime.

.PARAMETER $functionAppResourceGroup
    Specifies the resource group where the Azure function resides.

.PARAMETER $localFunctionPath
    Specifies the function path in the local github repo in the machine. As shown in the example below it should be the path where the host.json resides.
    Example : /home/runner/work/elz-azure-bicep/elz-azure-bicep/ListenerFunction/ListenerFunction

.PARAMETER $functionListInApp
    This is the list of "Functions" in the Azure function that actually are callable. This is the actual operations done by the Azure function. These are needed to check if all the functions have been correctly implemented.
    Example @('agea-listener-atf2-cmdb','agea-listener-atf2-event')

.NOTES
    Version:        0.2
    Author:         alkesh.naik@eviden.com,frederic.trapet@eviden.com
    Creation Date:  20220718
    Purpose/Change: Modified to use az-graph to avoid issue in other cmdleds that are not always reliable and can have delay

.EXAMPLE
    $functionListInApp = @('agea-listener-atf2-cmdb','agea-listener-atf2-event')
    $functionApp = "testfunctionappdeplopswh1"
    $functionAppResourceGroup = "testpwshscriptosmgmt"
    $localFunctionPath = "/home/alkeshazure/testdelpoy/ListenerFunction/ListenerFunction"
    Publish-AzFunctionApp.ps1 -functionApp $functionApp -functionAppResourceGroup $functionAppResourceGroup -localFunctionPath $localFunctionPath -functionListInApp $functionListInApp
#>

function Publish-AzFunctionApp {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $True)]
    [string]$functionApp,
    [Parameter(Mandatory = $True)]
    [string]$functionAppResourceGroup,
    [Parameter(Mandatory = $True)]
    [string]$localFunctionPath,
    [Parameter(Mandatory = $True)]
    [string[]]$functionListInApp
  )

  begin {
    $checkCompletionOfPublish = @()
    $functionUploadRetryCount = 30
    $apiVersion = "2019-08-01"
    $subscriptionId = ""

    Write-Verbose "Starting Function-app publish script"
    Write-Verbose "Function-app name : $($functionApp)"
    Write-Verbose "Function-app resource group name : $($functionAppResourceGroup)"
    Write-Verbose "Function-app files local path: $($localFunctionPath)"

    #Check if the local path exsts
    if (-Not (Test-Path -Path $localFunctionPath)) {
      Write-Error ("ERROR: Cannot find function source code in '" + $localFunctionPath + "'") -ErrorAction Stop
    }
    else {
      #Check if the resource group exists
      try {
        $params = @{
          Name = $functionAppResourceGroup
        }
        Get-AzResourceGroup @params -ErrorAction Stop | Out-Null
      }
      catch {
        Write-Error ("ERROR: Cannot find the resource group '" + $functionAppResourceGroup + "' in the current susbcription. It threw the below exception $($_.Exception.Message). Please make sure you are connected to the correct subscription !") -ErrorAction Stop
      }

      #Check if the Azure function exists
      $getAzFunction = Search-AzGraph -Query "resources| where (type == ""microsoft.web/sites"" and resourceGroup == ""$($functionAppResourceGroup)"" and name == ""$($functionApp)"")"

      if (-Not $getAzFunction) {
        Write-Error ("ERROR: Cannot find the Azure function-app '" + $functionApp + "' in the current susbcription. It threw the below exception $($_.Exception.Message).  Please make sure you are connected to the correct subscription !") -ErrorAction Stop
      }
      else {
        #This part of the code gets the subscription id where the function resides. 
        #This is needed so that we can call the api to get app details and check if the function is deployed correctly
        $subscriptionId = ($getAzFunction.Id).Split("/")[2]
      }
    }

    #Zip the function code.
    $currentPath = (Get-Location).Path
    $zipFileName = "$functionApp.zip"
    $zipLocation = Join-Path -Path $currentPath -ChildPath $zipFileName

    try {
      [System.IO.Compression.ZipFile]::CreateFromDirectory($localFunctionPath, $zipLocation)
    }
    catch {
      Write-Error ("ERROR: $($_.Exception.Message) There was an error while compressing the file '" + $zipLocation + "'") -ErrorAction Stop
    }

    # Check if the zip file is created in the zip location.
    If (-Not (Test-Path -Path $zipLocation)) {
      Write-Error ("ERROR: Cannot find zip file in the path '" + $zipLocation + "'") -ErrorAction Stop
    }

  }

  process {
    #Start the publish of the source code in the function-app (retry loop in case of errors)
    $retryCount = 0
    $publishSucceeded = $false

    Do {
      $retryCount++
      try {
        $publishSucceeded = $true
        $params = @{
          ResourceGroupName = $functionAppResourceGroup
          Name              = $functionApp
          ArchivePath       = $zipLocation
          Force             = $True
          ErrorAction       = 'Stop'
        }
        #Calling the Publish Web app powershell command.
        Publish-AzWebApp @params
      }
      catch {
        $publishSucceeded = $false
        Write-Verbose "Error while publishing  $($_.Exception.Message) , retrying ..."
        Start-Sleep 30
      }
    } until (($publishSucceeded) -or ($retryCount -ge $functionUploadRetryCount))
    
    if (-Not ($publishSucceeded)) {
      Write-Error "Error while publishing  $($_.Exception.Message) $functionApp"
    }

    #This is added as the Publish api normally takes some time to deploy.
    Start-Sleep 30

    #This part of the code is a do while loop which checks to see if the deployment was successful. It will try the number of time mentioned in the variable $functionUploadRetryCount times or until it gets finds all the functions mentioned in the $functionListInApp. There are Verbose logs written to debug if any issues.
    $retryCount = 0

    Do {
      Start-Sleep 10
      $checkCompletionOfPublish = @()

      if (($null -ne $functionListInApp) -and ($functionListInApp.count -gt 0)) {
        Write-Verbose "Checking if functions are published using Azure API"
        $params = @{
          apiUrl = '/subscriptions/' + $subscriptionId + '/resourceGroups/' + $functionAppResourceGroup + '/providers/Microsoft.Web/sites/' + $functionApp + '/functions?api-version=' + $apiVersion
          apiMethod = "GET"
        }
        $apiResponse = invoke-azureRestApiDataRequest @params
        $functionAvailable = $apiResponse.value
        
        if (($null -ne $functionAvailable) -and ($functionAvailable.count -gt 0)) {
          Write-Verbose "In the if condition to check if the REST API gave the correct output. Output: $functionAvailable" 
          
          foreach ($functionOps in $functionAvailable) {
            Write-Verbose "In the loop to check if the function app has the correct functions. Output: $functionOps"
            
            if ($functionOps.properties.name -in $functionListInApp) { 
              $tempLoopVariable = $functionOps.properties.name
              
              Write-Verbose "Checking if the function names match the function list. Output: $tempLoopVariable"
              
              $checkCompletionOfPublish += $true 
            }
            else {
              $checkCompletionOfPublish += $false 
            }
          }
        }
        else {
          $retryCount++
        }

        if (($false -in $checkCompletionOfPublish)) {
          $retryCount++
        }

        Write-Verbose "Checking for all the values so it can be debugged in case of error."
        Write-Verbose "checkCompletionOfPublish: $checkCompletionOfPublish"
        Write-Verbose "retryCount: $retryCount"
      }
    } until (($false -notin $checkCompletionOfPublish -and $checkCompletionOfPublish.count -gt 0) -or ($retryCount -ge $functionUploadRetryCount))
    
    if ($false -notin $checkCompletionOfPublish) {
      Write-Verbose "Deployment completed."
    }
    else {
      Write-Error ("ERROR: Cannot upload function code into function-app '" + $FunctionAppObject.Name + "'. Function deployement aborted.") -ErrorAction Stop    
    }
  }

  end {
    # intentionally empty 
  }

}

# Function to communicate with Azure RM REST API
Function invoke-azureRestApiDataRequest {
  param(
      [Parameter(Mandatory = $True)]
      [string] $apiUrl,
      [Parameter(Mandatory = $True)]
      [string] $apiMethod
  )
  $MaxAPIRequestRetries = 10
  $apiUrlString = 'https://management.azure.com' + $apiUrl
  $azToken = (Get-AzAccessToken).Token
  $headers = @{ authorization = "Bearer " + $azToken; accept = "application/json" }
  $nbTry = 0
  Do {
      $nbtry++
      try {
          $apiResponse = Invoke-RestMethod -Method $apiMethod -Uri $apiUrlString -ContentType 'application/json' -headers $headers -ErrorAction Stop
      }
      catch {
          $apiResponse = $null
          Write-Verbose ("Failed to get Rest API response : $($_.ToString()) retry " + $Nbtry + "/" + $MaxAPIRequestRetries)
          Start-Sleep -Seconds 5
      }
  } until (($null -ne $apiResponse) -or ($nbtry -eq $maxApiRequestRetries))
  If ($null -eq $apiResponse) {
    Write-Error ("Failed to get Rest API response : $($_.ToString())")
  }
  return $apiResponse
}
