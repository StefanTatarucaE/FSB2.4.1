<#
    .SYNOPSIS
        Powershell AL 2.2 CMDB and EVENT Listener

    .DESCRIPTION
        Process incoming messages sent from Logic-app specific format and output SOAP messages to SNOW
        Managed CI classes can be found under subfolder CLASSES\*
#>

using namespace System.Net
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ConfigItemsObj', Justification = 'Variable is used in the included script')]

# Get HTTP POST input from function call
param($postRequest)

# Include external functions file and initialize application settings
. "$PSScriptRoot\psfunctions.ps1"

Write-Host "PowerShell HTTP trigger function processed a request."

# Validate JSON data
If (($null -eq $postRequest.Body) -or ($postRequest.Body.GetType().FullName) -ne "System.Collections.Hashtable") {
  throw("Invalid JSON message received ! Format not supported [$($postRequest.Body.GetType().FullName)]")
} else {
  $configItemData = $postRequest.Body
  If (-Not (ValidateJSONMessage -ConfigItemData $configItemData)) {
    throw("Invalid JSON message received ! Missing mandatory properties")
  }
}

# Connect to Azure
If (-Not ($env:AZURE_FUNCTIONS_ENVIRONMENT -eq "Development")) {
  Connect-AzAccount -Identity -WarningAction SilentlyContinue | Out-Null
}

# Initialize variables
$configItemsObj = [System.Collections.ArrayList]::new()
$nativeSNOWSupport = ($env:CFG_NATIVE_SERVICENOW -eq "TRUE")
If ($configItemData.targetsnowenv -eq "DEFAULT") {
  $configItemData.targetsnowenv = $env:CFG_DEFAULT_SNOW_ENV
}
If ($configItemData.targetsnowfo -eq "DEFAULT") {
  $configItemData.targetsnowfo = $env:CFG_DEFAULT_SNOW_FO
}
If ($nativeSNOWSupport) {
  . "$PSScriptRoot\psfunctions-native.ps1"
} else {
  . "$PSScriptRoot\psfunctions-atf.ps1"
}

# Get SNOW configuration, and validate connection and settings in selected ServiceNow Environment
$snowConfiguration = GetSNOWConfiguration -snowEnvironmentCode $configItemData.targetsnowenv -snowFunctionalOrg $configItemData.targetsnowfo

# Process received payload
switch ($configItemData.payloadtype)
{
  # CMDB CI creation/udpate/decomission
  itsm-cmdb
  {
    If ($env:CFG_CMDB_ENABLE_CI_CREATION -eq "TRUE") {
      Write-Host ($nativeSNOWSupport ? "Processing CMDB event from logic-app (NATIVE SNOW)" : "Processing CMDB event from logic-app")
      Write-Host "* Event Type = $($configItemData.eventType)"
      Write-Host "* Resource ID = $($configItemData.resourceId)"
      Write-Host "* Target Snow ENV = $($snowConfiguration.environmentCode)"
      Write-Host "* Target Snow FO = $($snowConfiguration.functionalOrg)"

      $params = @{
        snowConfiguration = $snowConfiguration
        eventType         = $configItemData.eventType
        resourceId        = $configItemData.resourceId
      }
      If (CreateSNOWCMDBConfigurationItem @params) {
        Write-Host "CMDB event successfully processed."
      } else {
        Write-Error "CMDB event processing failed !"
      }
    } else {
      WriteDebugMsg "CMDB CI creation disabled, ignoring incoming CMDB event"
    }
  }

  # Incident creation
  itsm-event
  {
    Write-Host ($nativeSNOWSupport ? "Processing ALERT event from logic-app (NATIVE SNOW)" : "Processing ALERT event from logic-app")
    Write-Host "* Target Snow ENV = $($snowConfiguration.environmentCode)"
    Write-Host "* Target Snow FO = $($snowConfiguration.functionalOrg)"
    If ($configItemData.eventMessageText -like "*Alert Name :*") {
      $alertNameStr = $configItemData.eventMessageText.split("Alert Name : ")
      Write-Host "* Alert Name = $($alertNameStr[1].split('\r')[0])"
    }
    $params = @{
      snowConfiguration     = $snowConfiguration
      dateTimeOccured       = $configItemData.dateTimeOccured
      eventCategory         = $configItemData.eventCategory
      eventSeverity         = $configItemData.eventSeverity
      eventType             = $configItemData.eventType
      eventMessageText      = $configItemData.eventMessageText
      genericCIMonitoringId = $configItemData.genericCIMonitoringId
      resourceId            = $configItemData.resourceId
      forcedMonitoringId    = $configItemData.forcedMonitoringId
    }
    If (CreateSNOWIncident @params) {
      Write-Host "ALERT event successfully processed."
    } else {
      Write-Error "ALERT event processing failed !"
    }
  }
  Default
  {
    throw("Unsupported payload type [$($configItemData.payloadtype)] !")
  }
}

# End function with Success code
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
  statusCode = [HttpStatusCode]::OK
  body       = "This HTTP triggered function executed successfully"
})