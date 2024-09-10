
# Global Configuration
[int]    $MaxAPIRequestRetries = 5

##
## Generic functions
##

function WriteDebugMsg {
  Param(
    [Parameter(Mandatory=$True)]
    [string] $DebugMsgTxt
  )
  If ($env:DEBUG -eq "TRUE") {
    Write-Host ("DEBUG: "+$DebugMsgTxt)
  }
}

function ValidateJSONMessage {
  Param(
      [Parameter(Mandatory=$True)]
      [object] $ConfigItemData
  )
  If ($ConfigItemData.Keys -notcontains ("payloadtype")) {return $false}
  switch ($configItemData.payloadtype)
  {
    itsm-cmdb
    {
      If ($ConfigItemData.Keys -notcontains ("eventtype")) {return $false}
      If ($ConfigItemData.Keys -notcontains ("targetsnowenv")) {return $false}
      If ($ConfigItemData.Keys -notcontains ("targetsnowfo")) {return $false}
      If ($ConfigItemData.Keys -notcontains ("resourceid")) {return $false}
    }
    itsm-event
    {
      If ($ConfigItemData.Keys -notcontains ("targetsnowenv")) {return $false}
      If ($ConfigItemData.Keys -notcontains ("targetsnowfo")) {return $false}
    }
     Default
    {
      return $false
    }
  }
  return $true
}

Function Invoke-RestAPIDataRequest {
  param(
    [Parameter(Mandatory = $True)]
    [string] $APIurl,

    [Parameter(Mandatory = $False)]
    [string] $APIMethod,

    [Parameter(Mandatory = $False)]
    [string] $APIVersion,

    [Parameter(Mandatory = $False)]
    [string] $BodyJSON,

    [Parameter(Mandatory = $False)]
    [string] $BasicUsername,

    [Parameter(Mandatory = $False)]
    [string] $BasicPassw
  )
  If (-Not $APIMethod) {
    $APIMethod = "GET"
  }
  If (($APIurl -like "http://*") -or ($APIurl -like "https://*")) {
    $APIurlString = $APIurl
  } else {
    $APIurlString = 'https://management.azure.com' + $APIurl
  }
  If ($APIVersion) {
    $APIurlString += ($APIurlString -like '*`?*') ? '&' : '?'
    $APIurlString += 'api-version=' + $APIVersion
  }
  If ((-Not $BasicUsername) -or (-Not $BasicPassw)) {
    $AzToken = (Get-AzAccessToken).Token
    $headers = @{ Authorization = "Bearer " + $AzToken; Accept = "application/json" }
  } else {
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $BasicUsername, $BasicPassw)))
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
    $headers.Add('Accept','application/json')
  }
  $NbTry = 0
  $global:apiErrorMessage = ""
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
      if (Test-Json -Json $_.ToString()) {
        $errorObj = $_.ToString() | ConvertFrom-Json -Depth 99
        $global:apiErrorMessage = $errorObj.error.message
      } else {
        $global:apiErrorMessage = $_.ToString()
      }
      if ($global:apiErrorMessage -eq 'User Not Authenticated') {
        return $APIResponse
      }
      write-host ("Failed to get Rest API response : $($_.ToString()) for url [" + $APIurlString + "] retry " + $Nbtry + "/" + $MaxAPIRequestRetries)
      Start-Sleep -Seconds 5
    }
  } until (($null -ne $APIResponse) -or ($Nbtry -eq $MaxAPIRequestRetries))
  If ($null -eq $APIResponse) {
    $message = ($null -eq $global:apiErrorMessage) ? "No response from API" : $global:apiErrorMessage
    write-host ("Failed to get Rest API response : $($message)")
  }
  return $APIResponse
}

Function Get-MonitoringIdFromResourceId {
  Param(
      [Parameter(Mandatory = $true)]
      [String] $resourceId,

      [Parameter(Mandatory = $false)]
      [String] $resourceName
  )

  If ($ResourceId -like "*microsoft.compute/virtualmachines*") {
    $resourceData = GetAzureGenericResourceData -resourceId $resourceId
    if ($null -eq $resourceData) {
      Write-Error ("Unable to retrieve Azure generic resource data for resourceId [" + $resourceId + "], resource not found !")
      return $null
    }  else{
      $isScaleSet = ($resourceData.type -eq 'Microsoft.Compute/virtualMachineScaleSets') ? $true : $false
      $uniqueId = $isScaleSet ? 'VMSS-' + $resourceData.properties.uniqueId : 'VM-' + $resourceData.properties.vmId
      $monitoringId = "azure://" + $uniqueId + "/" + $resourceData.name
    }  
  } else {
    If ((GetCMDBAzureSupportedResourceTypes -resourceId $resourceId) -eq $true) {
      $EncodedText = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($ResourceId.Tolower()))
      $BodyJSON = '{
          "$schema": "http://schemas.management.azure.com/deploymentTemplate?api-version=2014-04-01-preview",
          "contentVersion": "1.0.0.0",
          "parameters": {
              "'+$EncodedText.ToUpper()+'": {
              "type": "string"
              }
          },
          "resources": []
          }'
      $params = @{
          APIurl          = "/providers/Microsoft.Resources/calculateTemplateHash?api-version=2020-06-01"
          APIMethod       = "POST"
          BodyJSON        = $BodyJSON
      }
      $Response = Invoke-RestAPIDataRequest @params
      If ([string]::IsNullOrEmpty($resourceName)) {
        $resourceName = ($resourceId -split "/")[-1]
      }
      $MonitoringID = "azure://RID-" + $Response.templateHash + "/" + $ResourceName
    } else {
      $MonitoringID = $null
    }
  }
  return $MonitoringID
}

function GetAzureGenericResourceData {
  Param(
      [Parameter(Mandatory=$True)]
      [string] $resourceId
  )

  $providerName = ($resourceId -split "/")[6]
  $resourceType = ($resourceId -split "/")[7]
  $subscriptionId = ($resourceId -split "/")[2]

  # Get resource provider information
  $providersData = Invoke-RestAPIDataRequest -APIurl "/subscriptions/$($subscriptionId)/providers/$($providerName)" -APIVersion "2015-01-01"
  $providerData = $providersData.resourceTypes | Where-Object -FilterScript {$_.resourceType -EQ $resourceType}
  if ($providerData.count -ne 1) {
    Write-Error "Unable to get data for provider [$($providerName)]"
    return $null
  }

  # Get generic resource data using latest API Version
  $resourceData = Invoke-RestAPIDataRequest -APIurl $resourceId -APIVersion $providerData.apiVersions[0]

  return $resourceData
}

function GetAzureVirtualMachineResourceData  {
  Param(
    [Parameter(Mandatory=$True)]
    [System.Object] $resourceData
  )

  $subscriptionId = ($resourceData.id -split "/")[2]
  $isScaleSet = ($resourceData.type -eq 'Microsoft.Compute/virtualMachineScaleSets') ? $true : $false

  # Set values depending of type
  $tshirtSize = $isScaleSet ? $resourceData.sku.name : $resourceData.properties.hardwareProfile.vmSize
  $uniqueId = $isScaleSet ? 'VMSS-' + $resourceData.properties.uniqueId : 'VM-' + $resourceData.properties.vmId
  $monitoringId = "azure://" + $uniqueId + "/" + $resourceData.name

  # Get SKU data and get additional values
  $params = @{
    APIurl      = "https://management.azure.com/subscriptions/$($subscriptionId)/providers/Microsoft.Compute/skus?`$filter=location eq '$($resourceData.location)'"
    APIVersion  = "2019-04-01"
  }
  $skuData = Invoke-RestAPIDataRequest @params
  $skuData = $skuData.value | Where-Object -FilterScript {$_.name -EQ $tshirtSize}
  $vCPUs = ($skuData.capabilities | Where-Object -FilterScript {$_.name -EQ 'vCPUs'}).value
  $memoryGb = ([int] ($skuData.capabilities | Where-Object -FilterScript {$_.name -EQ 'memorygb'}).value) * 1024

  # Get instance data, powerstate, computername
  If ($isScaleSet) {
    $poweredOn = $false
    $instanceData = Invoke-RestAPIDataRequest -APIurl "$($resourceId)/virtualMachines?`$select=instanceView&`$expand=instanceView" -APIVersion "2022-08-01"
    foreach ($vmInstance in $instanceData.value) {
      if ($vmInstance.properties.instanceView.statuses[1].code -like '*running*') {
        $poweredOn = $true
      }
    }
    $computerName = $ConfigItemData.resourceName
    $fqdn = $null
  } else {
    $instanceData = Invoke-RestAPIDataRequest -APIurl "$($resourceId)/InstanceView" -APIVersion "2022-08-01"
    $poweredOn = $instanceData.statuses[1].code -like '*running*' ? $true : $false
    $computerName = $poweredOn ? $instanceData.computerName : $null
    $fqdn = $null
  }

  # Get OS information
  If ($isScaleSet) {
    $osFamily = $resourceData.properties.virtualMachineProfile.storageProfile.osDisk.osType
    $osNameVersion = $resourceData.properties.virtualMachineProfile.storageProfile.imageReference.offer
    If ($resourceData.properties.virtualMachineProfile.storageProfile.imageReference.sku) {
      $osNameVersion += ' '+$resourceData.properties.virtualMachineProfile.storageProfile.imageReference.sku.replace('-',' ')
    }
    If ($resourceData.properties.virtualMachineProfile.storageProfile.imageReference.exactVersion) {
      $osNameVersion += ' '+$resourceData.properties.virtualMachineProfile.storageProfile.imageReference.exactVersion
    }
  } else {
    $osFamily = $resourceData.properties.storageProfile.osDisk.osType
    $osNameVersion = $resourceData.properties.storageProfile.imageReference.offer
    If ($resourceData.properties.storageProfile.imageReference.sku) {
      $osNameVersion += ' '+$resourceData.properties.storageProfile.imageReference.sku.replace('-',' ')
    }
    If ($resourceData.properties.storageProfile.imageReference.exactVersion) {
      $osNameVersion += ' '+$resourceData.properties.storageProfile.imageReference.exactVersion
    }
  }
  If ($osNameVersion -like "* datacenter*") {
    $osNameVersion = $osNameVersion.split(" datacenter")[0] + " Datacenter"
  }
  $osNameVersion = $osNameVersion.Replace("WindowsServer", "Windows Server")
  If ($null -ne $resourceData.tags."$($env:COMPANY_TAG_PREFIX)OsVersion") {
    $osNameVersion = $resourceData.tags."$($env:COMPANY_TAG_PREFIX)OsVersion"
  }

  # Return data
  return [hashtable] @{
    computerName    = $computerName
    tshirtSize      = $tshirtSize
    osFamily        = $osFamily
    osNameVersion   = $osNameVersion
    monitoringId    = $monitoringId
    serialNumber    = $uniqueId
    vCPUs           = $vCPUs
    memoryGb        = $memoryGb
    poweredOn       = $poweredOn
    fqdn            = $fqdn
  }
}

##
## SNOW helper functions
##

function GetSNOWConfiguration {
  Param(
    [Parameter(Mandatory=$True)]
    [string] $snowEnvironmentCode,

    [Parameter(Mandatory=$True)]
    [string] $snowFunctionalOrg
  )

  # Determine SNOW instance Url and secret names
  $snowUrlSettingName = $nativeSNOWSupport ? 'CFG_NATIVE_SNOW_URLS' : 'CFG_SNOW_URLS'
  $snowUrlSetting = (Get-Item -Path "env:$snowUrlSettingName" -ErrorAction SilentlyContinue).value
  If ($null -eq $snowUrlSetting) {
    throw("Missing application settings property [$($snowUrlSettingName)] !")
  } else {
    $SnowUrls = $snowUrlSetting | ConvertFrom-Json
  }
  If ($SnowUrls.PSObject.Properties[$SnowEnvironmentCode].Value) {
    $SnowInstance = $SnowUrls.PSObject.Properties[$SnowEnvironmentCode].Value
    If ($SnowEnvironmentCode -eq "PROD") {
      $UserSecretName = ($nativeSNOWSupport ? $env:CFG_NATIVE_SECRET_NAME : $env:CFG_SECRET_NAME) + "-username"
      $PassSecretName = ($nativeSNOWSupport ? $env:CFG_NATIVE_SECRET_NAME : $env:CFG_SECRET_NAME) + "-password"
    } else {
      $UserSecretName = ($nativeSNOWSupport ? $env:CFG_NATIVE_SECRET_NAME : $env:CFG_SECRET_NAME) + "-username-" + $SnowEnvironmentCode
      $PassSecretName = ($nativeSNOWSupport ? $env:CFG_NATIVE_SECRET_NAME : $env:CFG_SECRET_NAME) + "-password-" + $SnowEnvironmentCode
    }
  } else {
    throw("SNOW environment ["+$SnowEnvironmentCode+"] is not defined in application settings [$($snowUrlSettingName)] !")
  }
  
  # Get vault secrets
  try {
    $secret1 = Get-AzKeyVaultSecret -VaultName $env:AZ_KEYVAULT_NAME -Name $UserSecretName -Warningaction Silentlycontinue -ErrorAction stop
    $ssPtr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret1.SecretValue)
  } catch {
    throw("Cannot retrieve secret ["+$UserSecretName+"] from keyvault ["+$env:AZ_KEYVAULT_NAME+"]")
  }
  try {
    $SnowUserName = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr1)
  } finally {
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr1)
  }
  try {
    $secret2 = Get-AzKeyVaultSecret -VaultName $env:AZ_KEYVAULT_NAME -Name $PassSecretName -Warningaction Silentlycontinue -ErrorAction stop
    $ssPtr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret2.SecretValue)
  } catch {
    throw("Cannot retrieve secret ["+$PassSecretName+"] from keyvault ["+$env:AZ_KEYVAULT_NAME+"]")
  }
  try {
    $SnowPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr2)
  } finally {
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr2)
  }

  # Get ServiceNow configuration using APIs, and validate connection
  $snowConfiguration = @{
    username        = $SnowUserName
    password        = $SnowPassword
    instanceUrl     = $SnowInstance
    environmentCode = $SnowEnvironmentCode
  }
  If ($nativeSNOWSupport) {
    $integrationUserData = GetSNOWIntegrationUserData -snowConfiguration $snowConfiguration
    $companySysId       = $integrationUserData.companySysId

    If (($null -eq $companySysId) -and ($global:apiErrorMessage -eq 'User Not Authenticated')) {
      throw("Invalid ServiceNow Credentials, aborting !")
    }
    $assignmentGroupId = ($env:CFG_NATIVE_INC_SUPPORT_GROUP) ? (GetSNOWAssignmentGroupId -snowConfiguration $snowConfiguration -assignmentGroupName $env:CFG_NATIVE_INC_SUPPORT_GROUP) : $null
    $snowConfiguration += @{
      companySysId        = $companySysId
      callerSysId         = $integrationUserData.callerSysId
      supportGroupId      = $assignmentGroupId
      functionalOrg       = ($null -eq $companySysId) ? '<empty>' : (GetSNOWCompanyNameFromId -snowConfiguration $snowConfiguration -companyId $companySysId)
      monitoringToolName  = "Native"
    }
  } else {
    $companySysId = GetSNOWCompanyId -snowConfiguration $snowConfiguration -snowFunctionalOrg $snowFunctionalOrg
    If ($null -eq $companySysId) {
      if ($global:apiErrorMessage -eq 'User Not Authenticated') {
        throw("Invalid ServiceNow Credentials, aborting !")
      } else {
        throw("Invalid ServiceNow Functional organization name '" + $snowFunctionalOrg + "' in instance [" + $SnowInstance + "], aborting !")
      }
    }
    $monitoringToolName = ($env:CFG_DEFAULT_INC_MONITORING_TOOL).Trim().ToUpper()
    $monitoringToolId = GetSNOWCMDBMonitoringToolId -snowConfiguration $snowConfiguration -monitoringToolName $monitoringToolName
    If ($null -eq $monitoringToolId) {
      throw("Invalid ServiceNow Monitoring tool name '" + $monitoringToolName + "' in instance [" + $SnowInstance + "], aborting !")
    }
    $snowConfiguration += @{
      companySysId        = $companySysId
      monitoringToolId    = $monitoringToolId
      monitoringToolName  = $monitoringToolName
      functionalOrg       = $snowFunctionalOrg
    }
  }

  return [hashtable] $snowConfiguration
}

function GetSNOWCompanyId {
  Param(
    [Parameter(Mandatory=$True)]
    [hashtable] $snowConfiguration,

    [Parameter(Mandatory=$True)]
    [string] $snowFunctionalOrg
  )
  
  # Get the ID of the company
  $params = @{
    apiUrl          = $snowConfiguration["InstanceUrl"] + "/api/now/table/core_company?sysparm_query=name%3D" + $snowFunctionalOrg
    basicUsername   = $snowConfiguration["Username"]
    basicPassw      = $snowConfiguration["Password"]
  }
  $response = Invoke-RestAPIDataRequest @params
  return ($null -eq $response ? $null : $response.result[0].sys_id)
}

function GetSNOWCompanyNameFromId {
  Param(
    [Parameter(Mandatory=$True)]
    [hashtable] $snowConfiguration,

    [Parameter(Mandatory=$True)]
    [string] $companyId
  )
  
  # Get the ID of the company
  $params = @{
    apiUrl          = $snowConfiguration["InstanceUrl"] + "/api/now/table/core_company?sysparm_query=sys_id%3D" + $companyId
    basicUsername   = $snowConfiguration["Username"]
    basicPassw      = $snowConfiguration["Password"]
  }
  $response = Invoke-RestAPIDataRequest @params
  return ($null -eq $response ? $null : $response.result[0].name)
}

function GetSNOWCMDBMonitoringToolId {
  Param(
    [Parameter(Mandatory=$True)]
    [hashtable] $snowConfiguration,

    [Parameter(Mandatory=$True)]
    [string] $monitoringToolName
  )

  $params = @{
      apiUrl          = $snowConfiguration["InstanceUrl"] + "/api/now/table/u_monitoring_tools?sysparm_query=u_name%3D" + $monitoringToolName
      basicUsername   = $snowConfiguration["Username"]
      basicPassw      = $snowConfiguration["Password"]
  }
  $response = invoke-RestAPIDataRequest @params
  return ($null -eq $response ? $null : $response.result[0].sys_id)
}

Function GetSNOWIntegrationUserData {
  param(
    [Parameter(Mandatory=$True)]
    [hashtable] $snowConfiguration
  )

  $params = @{
    apiUrl          = $snowConfiguration["InstanceUrl"] + "/api/now/table/sys_user?sysparm_query=user_name%3D" + $snowConfiguration["Username"]
    basicUsername   = $snowConfiguration["Username"]
    basicPassw      = $snowConfiguration["Password"]
  }
  $response = Invoke-RestAPIDataRequest @params

  $userData = @{
    companySysId    = ($null -eq $response) ? $null : $response.result[0].company.value
    callerSysId     = ($null -eq $response) ? $null : $response.result[0].sys_id
  }
  return $userData
}

Function GetSNOWAssignmentGroupId {
  param(
    [Parameter(Mandatory=$True)]
    [hashtable] $snowConfiguration,

    [Parameter(Mandatory = $True)]
    [string] $assignmentGroupName
  )

  $params = @{
    apiUrl          = $snowConfiguration["InstanceUrl"] + "/api/now/table/sys_user_group?sysparm_query=name%3D" + $assignmentGroupName
    basicUsername   = $snowConfiguration["Username"]
    basicPassw      = $snowConfiguration["Password"]
  }
  $response = Invoke-RestAPIDataRequest @params
  return ($response ? $response.result[0].sys_id : $null)
}

function GetSNOWCMDBConfigurationItemObject {
  Param(
    [Parameter(Mandatory=$True)]
    [hashtable] $snowConfiguration,

    [Parameter(Mandatory=$True)]
    [string] $monitoringId
  )

  If ($nativeSNOWSupport) {
    $monitoringidColumnName = 'short_description'
    $monitoringIdString     = "[MONITORING-ID:" + $monitoringId + "]"
    $encodedFilterString    = "company=" + $snowConfiguration.CompanySysId + "^"+$monitoringidColumnName+"LIKE"+$monitoringIdString
    $encodedFilterString    = [System.Web.HttpUtility]::UrlEncode($encodedFilterString)
  } else {
    $encodedFilterString    = "company%3D" + $snowConfiguration.CompanySysId + "%5Eoperational_status%3D1%5Eu_is_monitored%3Dtrue"
    $encodedFilterString   += "%5Eu_monitoring_tool_name%3D" + $snowConfiguration.MonitoringToolId + "%5Eu_monitoring_object_id%3D" + $monitoringId
  }
  $params = @{
      apiUrl          = $snowConfiguration["InstanceUrl"] + "/api/now/table/cmdb_ci?sysparm_query=" + $encodedFilterString
      basicUsername   = $snowConfiguration["Username"]
      basicPassw      = $snowConfiguration["Password"]
  }

  $response = Invoke-RestAPIDataRequest @params
  return ($response ? $response.result[0] : $null)
}

##
## SNOW CMDB functions
##

function CreateSNOWCMDBConfigurationItem {
  Param(
    [Parameter(Mandatory=$True)]
    [hashtable] $snowConfiguration,

    [Parameter(Mandatory=$True)]
    [string] $eventType,

    [Parameter(Mandatory=$True)]
    [string] $resourceId
  )

  # Get resource type and set up variables
  If (@('high','medium-high','medium','medium-low','low') -notcontains $env:CFG_DEFAULT_CMDB_CI_CRITICALITY) {
    Write-Error "Invalid configuration value [$($env:CFG_DEFAULT_CMDB_CI_CRITICALITY)] for [CFG_DEFAULT_CMDB_CI_CRITICALITY], defaults to 'medium'"
    $env:CFG_DEFAULT_CMDB_CI_CRITICALITY = "medium"
  }
  $resourceType = ($resourceId -split "/")[6] + '/' + ($resourceId -split "/")[7]
  if ((($resourceType -eq 'Microsoft.Sql/servers') -or ($resourceType -eq 'Microsoft.Sql/managedInstances')) -and ($resourceId -like '*/databases/*')) {
    $resourceType += '/databases'
  }
  $ConfigItemData += @{
    resourceName = ($resourceId -split "/")[-1]
    resourceType = $resourceType
  }
  $ConfigItemData.resourceId = $resourceId

  # Ignore CI creation request if the resource type is not supported in Native mode
  If (($nativeSNOWSupport) -and ((GetCMDBAzureSupportedResourceTypes -resourceId $resourceId) -eq $false)) {
    Write-Host ("Unsupported resource type [$($resourceType)], ignoring CI creation request !")
    return $true
  }

  # Get generic resource Data if the resource is not deleted
  If ($eventType -eq 'create_or_update') {
    $resourceData = GetAzureGenericResourceData -resourceId $resourceId
    if ($null -eq $resourceData) {
      Write-Error ("Unable to retrieve Azure generic resource data for resourceId [" + $resourceId + "], resource not found !")
      return $false
    }
  } else {
    $resourceData = $null
  }

  # Define class name and attributes depending of resource type.
  # WARNING : If you add a resource type here, it needs to be added also in the function 'GetCMDBAzureSupportedResourceTypes' !!
  switch ($resourceType)
  {
    microsoft.compute/virtualmachines
    {
      $ConfigItemData += @{
        className             = 'compute'
        resourceFriendlyName  = 'Azure Virtual Machine'
      }
      If ($eventType -eq 'create_or_update') {
        $ConfigItemData += GetAzureVirtualMachineResourceData -resourceData $resourceData
      }

    }
    microsoft.compute/virtualmachinescalesets
    {
      $ConfigItemData += @{
        className             = 'compute'
        resourceFriendlyName  = 'Azure Virtual Machine ScaleSet'
      }
      If ($eventType -eq 'create_or_update') {
        $ConfigItemData += GetAzureVirtualMachineResourceData -resourceData $resourceData
      }
    }
    microsoft.web/serverfarms
    {
      $ConfigItemData += @{
        className             = 'application'
        resourceFriendlyName  = 'Azure App Service Plan'
        modelId               = $env:CFG_CMDB_CI_APPSERVICEPLAN_MODELID
      }
    }
    microsoft.web/sites
    {
      $ConfigItemData += @{
        className             = 'application'
        resourceFriendlyName  = 'Azure App Service'
        modelId               = $env:CFG_CMDB_CI_APPSERVICE_MODELID
      }
    }
    microsoft.network/applicationgateways
    {
      $ConfigItemData += @{
        className             = 'loadbalancer'
        resourceFriendlyName  = 'Azure Application Gateway'
        modelId               = $env:CFG_CMDB_CI_APPGATEWAY_MODELID
      }
    }
    microsoft.network/loadbalancers
    {
      $ConfigItemData += @{
        className             = 'loadbalancer'
        resourceFriendlyName  = 'Azure Load Balancer'
        modelId               = $env:CFG_CMDB_CI_LOADBALANCER_MODELID
      }
    }
    microsoft.containerregistry/registries
    {
      $ConfigItemData += @{
        className             = 'container'
        resourceFriendlyName  = 'Azure Container Registry'
        modelId               = $env:CFG_CMDB_CI_CONTAINEREGISTRY_MODELID
      }
    }
    microsoft.storage/storageaccounts
    {
      $ConfigItemData += @{
        className             = 'container'
        resourceFriendlyName  = 'Azure Storage Account'
        skuName               = $resourceData.sku.name
        accessTier            = $resourceData.properties.accessTier
        modelId               = $env:CFG_CMDB_CI_STORAGEACCOUNT_MODELID
      }
    }
    microsoft.keyvault/vaults
    {
      $ConfigItemData += @{
        className             = 'database'
        resourceFriendlyName  = 'Azure KeyVault'
        modelId               = $env:CFG_CMDB_CI_KEYVAULT_MODELID
      }
    }
    microsoft.cache/redis
    {
      $ConfigItemData += @{
        className             = 'database'
        resourceFriendlyName  = 'Azure Redis Cache'
        modelId               = $env:CFG_CMDB_CI_REDISCACHE_MODELID
      }
    }
    microsoft.documentdb/databaseaccounts
    {
      $ConfigItemData += @{
        className             = 'database'
        resourceFriendlyName  = 'Azure CosmosDB Database'
        databaseType          = 'DocumentDB'
        modelId               = $env:CFG_CMDB_CI_COSMOSDB_MODELID
      }
    }
    microsoft.dbformariadb/servers
    {
      $ConfigItemData += @{
        className             = 'database'
        resourceFriendlyName  = 'Azure MariaDB Database'
        databaseType          = 'MariaDB'
        modelId               = $env:CFG_CMDB_CI_MARIADB_MODELID
      }
    }
    microsoft.dbformysql/servers
    {
      $ConfigItemData += @{
        className             = 'database'
        resourceFriendlyName  = 'Azure MySQL Database'
        databaseType          = 'MySQL'
        modelId               = $env:CFG_CMDB_CI_MYSQLDB_MODELID
      }
    }
    microsoft.dbforpostgresql/servers
    {
      $ConfigItemData += @{
        className             = 'database'
        resourceFriendlyName  = 'Azure PostgreSQL Database'
        databaseType          = 'Postgres SQL'
        modelId               = $env:CFG_CMDB_CI_POSTGRESQLDB_MODELID
      }
    }
    microsoft.databricks/workspaces
    {
      $ConfigItemData += @{
        className             = 'database'
        resourceFriendlyName  = 'Azure Data Bricks'
        modelId               = $env:CFG_CMDB_CI_DATABRICKS_MODELID
      }
    }
    microsoft.datafactory/factories
    {
      $ConfigItemData += @{
        className             = 'database'
        resourceFriendlyName  = 'Azure Data Factory'
        modelId               = $env:CFG_CMDB_CI_DATAFACTORY_MODELID
      }
    }
    microsoft.sql/servers/databases
    {
      $ConfigItemData += @{
        className             = 'database'
        resourceFriendlyName  = 'Azure SQL Database'
        databaseType          = 'SQL'
        modelId               = $env:CFG_CMDB_CI_SQLDB_MODELID
        modelIdDbInstance     = $env:CFG_CMDB_CI_SQLSRVDB_MODELID
      }
    }
    microsoft.sql/managedinstances/databases
    {
      $ConfigItemData += @{
        className             = 'database'
        resourceFriendlyName  = 'Azure SQL Database'
        databaseType          = 'SQL'
        modelId               = $env:CFG_CMDB_CI_SQLDB_MODELID
        modelIdDbInstance     = $env:CFG_CMDB_CI_SQLSRVDB_MODELID
      }
    }
    microsoft.sql/managedinstances
    {
      $ConfigItemData += @{
        className             = 'dbinstance'
        modelId               = $env:CFG_CMDB_CI_SQLSRVDB_MODELID
      }
    }
    microsoft.sql/servers
    {
      $ConfigItemData += @{
        className             = 'dbinstance'
        modelId               = $env:CFG_CMDB_CI_SQLSRVDB_MODELID
      }
    }
    microsoft.sqlvirtualmachine/sqlvirtualmachines
    {
      $ConfigItemData += @{
        className             = 'database'
        resourceFriendlyName  = 'SQL virtual machine'
        databaseType          = 'SQL'
        modelId               = $env:CFG_CMDB_CI_SQLDB_MODELID
      }
    }
    microsoft.containerservice/managedclusters
    {
      $ConfigItemData += @{
        className             = 'k8s'
        modelId               = $env:CFG_CMDB_CI_K8CLUSTER_MODELID
      }
    }
    microsoft.network/networksecuritygroups
    {
      $ConfigItemData += @{
        className             = 'netgear'
        deviceType            = '--'
        functionType          = 'Access'
        resourceFriendlyName  = 'Network security group'
        modelId               = $env:CFG_CMDB_CI_NSG_MODELID
      }
    }
    microsoft.network/azurefirewalls
    {
      $ConfigItemData += @{
        className             = 'netgear'
        deviceType            = 'Virtual Firewall'
        functionType          = 'Firewall'
        resourceFriendlyName  = 'Azure Firewall'
        modelId               = $env:CFG_CMDB_CI_FIREWALL_MODELID
      }
    }
    microsoft.network/virtualnetworkgateways
    {
      $ConfigItemData += @{
        className             = 'netgear'
        deviceType            = 'Gateway'
        functionType          = 'Network Appliance'
        resourceFriendlyName  = ($resourceData.properties.gatewayType -eq 'Vpn') ? 'VPN gateway' : ($resourceData.properties.gatewayType -eq 'ExpressRoute') ? 'ExpressRoute virtual network gateway' : ''
        modelId               = $env:CFG_CMDB_CI_VIRTUALNETGATEWAY_MODELID
      }
    }
    microsoft.network/expressroutecircuits
    {
      $ConfigItemData += @{
        className             = 'netgear'
        deviceType            = 'HA-Pair'
        functionType          = 'N/A'
        resourceFriendlyName  = 'ExpressRoute circuit'
        modelId               = $env:CFG_CMDB_CI_EXPRESSROUTE_MODELID
      }
    }
    microsoft.network/bastionhosts
    {
      $ConfigItemData += @{
        className             = 'application'
        resourceFriendlyName  = 'Azure Bastion'
        modelId               = $env:CFG_CMDB_CI_BASTION_MODELID
      }
    }
    microsoft.analysisservices/servers
    {
      $ConfigItemData += @{
        className             = 'application'
        resourceFriendlyName  = 'Azure Analysis Services'
        modelId               = $env:CFG_CMDB_CI_ANALYSISSVC_MODELID
      }
    }
    Default
    {
      throw("Unsupported resource type [$($resourceType)] !")
    }
  }

  # Load class file to create CI's
  If (!(Test-Path "$PSScriptRoot\classes\$($ConfigItemData.className)\$($ConfigItemData.className).ps1"))  {
    throw("Unsupported class name ["+$($ConfigItemData.className)+"] !")
  }
  . "$PSScriptRoot\classes\$($ConfigItemData.className)\$($ConfigItemData.className).ps1"

  # Create all CI's objects in SNOW
  If ($nativeSNOWSupport) {
    $result = SendSNOWCmdbNative -snowConfiguration $snowConfiguration
  } else {
    $result = SendSNOWSoapRequestsForCMDB -snowConfiguration $snowConfiguration
  }
  
  return $result
}

function RegisterSNOWConfigItemObject {
  Param(
    [Parameter(Mandatory=$False)]
    [string] $SNOW_Transform_Map = '',

    [Parameter(Mandatory=$False)]
    [string] $MonitoringId = $Null,

    [Parameter(Mandatory=$False)]
    [string] $MonitoringId_LastSegment = $Null,

    [Parameter(Mandatory=$True)]
    [System.Collections.Specialized.OrderedDictionary] $CMDB_Attributes
  )

  # validate mandatory properties
  If ($nativeSNOWSupport) {
    $Mandatory_parameters = @("name","class")
  } else {
    $Mandatory_parameters = @("u_name","u_class","u_model_id")
    If ($SNOW_Transform_Map -eq '') {
      throw("Missing mandatory parameter [SNOW_Transform_Map] in CI Object !")
    }
  }
  ForEach ($param in $Mandatory_parameters) {
    If ($null -eq $CMDB_Attributes[$param]) {
      throw("Missing mandatory property ["+$param+"] in CI Object !")
    }
  }

  # prepare values
  $monitoring_tool = ($env:CFG_DEFAULT_INC_MONITORING_TOOL).Trim().ToUpper()
  if ($MonitoringId) {
    if ($MonitoringId_LastSegment) {
      $monitoring_id = $MonitoringId.Substring(0,$MonitoringId.LastIndexOf('/')) + '/' + $MonitoringId_LastSegment
    } else {
      $monitoring_id = $MonitoringId
    }
  } else {
    if ($MonitoringId_LastSegment) {
      $monitoring_id = Get-MonitoringIdFromResourceId -ResourceName $MonitoringId_LastSegment -ResourceId $ConfigItemData.resourceId
    } else {
      $monitoring_id = Get-MonitoringIdFromResourceId -ResourceName $ConfigItemData.resourceName -ResourceId $ConfigItemData.resourceId
    }
  }
  $criticalityMapping = @{
    'high' = 1
    'medium-high' = 2
    'medium' = 3
    'medium-low' = 4
    'low' = 5
  }
  $ciCriticalityTag = $env:COMPANY_TAG_PREFIX + 'ITSMServiceNowCICriticality'  

  $in_service_date = (Get-Date -Format "yyyy-MM-dd").ToString()
  $last_inventory_date = (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString()

  # prepare CI properties
  If ($ConfigItemData.eventType -eq "delete") {
    $operational_status = ($nativeSNOWSupport) ? "7" : "Decommissioned"

    # Add base properties for decomissioned CI
    if ($nativeSNOWSupport) {
      $Object = [ordered] @{
        discovery_source      = 'Other Automated'
        company               = $snowConfiguration.CompanySysId
        install_status        = $operational_status
        name                  = $CMDB_Attributes["name"]
        class                 = $CMDB_Attributes["class"]
      }
    } else {
      $Object = [ordered] @{
        SACM_URL              = $SNOW_Transform_Map+".do?SOAP"
        u_company             = $ConfigItemData.targetsnowfo
        u_operational_status  = $operational_status
        u_name                = $CMDB_Attributes["u_name"]
        u_class               = $CMDB_Attributes["u_class"]
        u_model_id            = $CMDB_Attributes["u_model_id"]
        u_last_inventory_date = $last_inventory_date
      }
    }
  } else {
    $operational_status = ($nativeSNOWSupport) ? "1" : "Live"
    $ciCriticality = ( $resourceData.tags.$ciCriticalityTag ) ? $resourceData.tags.$ciCriticalityTag : $env:CFG_DEFAULT_CMDB_CI_CRITICALITY
    $ciCriticalityNumber = ( $criticalityMapping[$ciCriticality] ) ? $criticalityMapping[$ciCriticality] : $criticalityMapping[$env:CFG_DEFAULT_CMDB_CI_CRITICALITY]

    # Add base properties for live CI
    if ($nativeSNOWSupport) {
      $Object = [ordered] @{
        discovery_source        = 'Other Automated'
        company                 = $snowConfiguration.CompanySysId
        install_status          = $operational_status
        monitoring_object_id    = $monitoring_id
        serial_number           = $monitoring_id.replace('azure://','')
      }
    } else {
      $Object = [ordered] @{
        SACM_URL                = $SNOW_Transform_Map+".do?SOAP"
        u_company               = $ConfigItemData.targetsnowfo
        u_operational_status    = $operational_status
        u_is_monitored          = "true"
        u_monitoring_object_id  = $monitoring_id
        u_monitoring_tool       = $monitoring_tool
        #u_location              = $env:CFG_DEFAULT_CI_LOCATION
        u_serial_number         = $monitoring_id.split('/')[2]
        u_criticality           = $ciCriticalityNumber
        u_in_service_date       = $in_service_date
        u_last_inventory_date   = $last_inventory_date
        u_assigned_to           = $null
        u_ip_address            = $null
      }
      
      # add properties and value for support group, but only if existing CI in ServiceNow has empty values (do not overwrite existing values)
      $existingCI = GetSNOWCMDBConfigurationItemObject -snowConfiguration $snowConfiguration -monitoringId $monitoring_id
      $supportGroup = (($env:CFG_DEFAULT_SNOW_SUPPORT_GROUP) ? $env:CFG_DEFAULT_SNOW_SUPPORT_GROUP.Trim() : $Null)
      if (-not ($existingCI.assignment_group.value)) { $Object["u_support_group_l1"] = $supportGroup }
      if (-not ($existingCI.support_group.value))    { $Object["u_support_group_l2"] = $supportGroup }
    }

    # Add additional CI properties and override base value if needed. Null value are skipped.
    ForEach ($CMDB_Attribute in $CMDB_Attributes.GetEnumerator()) {
      if (($Mandatory_parameters -contains $CMDB_Attribute.Name) -or ($null -ne $CMDB_Attribute.Value)) {
        $Object[$CMDB_Attribute.Name] = $CMDB_Attribute.Value
      }
    }
  }

  # Store object for sending to SNOW
  $ConfigItemsObj.Add($Object) | Out-Null
}

function RegisterSNOWConfigItemRelations {
  Param(
    [Parameter(Mandatory=$True)]
    [hashtable] $Relations_Attributes
  )

  # ignore relations on delete action
  If ($ConfigItemData.eventType -eq "delete") {
    return
  }

  # validate mandatory properties
  $Mandatory_parameters = @("r_type","r_parent_name","r_child_name")
  ForEach ($param in $Mandatory_parameters) {
    If ($null -eq $Relations_Attributes[$param]) {
      throw("Missing mandatory property ["+$param+"] in CI Object !")
    }
  }

  # validate optional params
  $Optional_parameters = @("r_parent_class","r_child_class")
  ForEach ($param in $Optional_parameters) {
    If ($null -ne $Relations_Attributes[$param]) {
      New-Variable -Name $param -Value $Relations_Attributes[$param]
    }
  }

  # Find classes for objects
  $nameField = ($nativeSNOWSupport) ? "name" : "u_name"
  $classField = ($nativeSNOWSupport) ? "class" : "u_class"
  if ($null -ne $r_parent_class) {
    $u_p_class = $r_parent_class
  }
  else {
    $u_p_class = $null
    ForEach ($ci in $ConfigItemsObj) {
      if ($ci[$nameField] -eq $Relations_Attributes["r_parent_name"]) {
        $u_p_class = $ci[$classField]
      }
    }
  }

  if ($null -ne $r_child_class) { 
    $u_c_class = $r_child_class
  }
  else {
    $u_c_class = $null
    ForEach ($ci in $ConfigItemsObj) {
      if ($ci[$nameField] -eq $Relations_Attributes["r_child_name"]) {
        $u_c_class = $ci[$classField]
      }
    }
  }

  If ((!$u_p_class) -or (!$u_c_class)) {
    throw("Invalid object names in relations !")
  }

  # Construct base properties for new CI
  if ($nativeSNOWSupport) {
    $Object = [ordered] @{
      r_parent_name           = $Relations_Attributes["r_parent_name"]
      r_parent_class          = $u_p_class
      r_type                  = $Relations_Attributes["r_type"]
      r_child_name            = $Relations_Attributes["r_child_name"]
      r_child_class           = $u_c_class
    }
  } else {
    $Object = [ordered] @{
      SACM_URL = "u_ci_relationship.do?SOAP"
      u_operation             = "create"
      u_p_class               = $u_p_class
      u_p_name                = $Relations_Attributes["r_parent_name"]
      u_p_company             = $ConfigItemData.targetsnowfo
      u_type                  = $Relations_Attributes["r_type"]
      u_c_class               = $u_c_class
      u_c_name                = $Relations_Attributes["r_child_name"]
      u_c_company             = $ConfigItemData.targetsnowfo
      u_connection_strength   = "Always"
      u_percent_outage        = "100"
    }
  }
  
  # Store object for sending to SNOW
  $ConfigItemsObj.Add($Object) | Out-Null
}

##
## SNOW INCIDENT functions
##

function CreateSNOWIncident {
  Param(
    [Parameter(Mandatory=$True)]
    [hashtable] $snowConfiguration,

    [Parameter(Mandatory=$False)]
    [datetime] $dateTimeOccured,

    [Parameter(Mandatory=$True)]
    [ValidateSet('DEFAULT', 'availability', 'performance')]
    [string] $eventType,

    [Parameter(Mandatory=$False)]
    [string] $eventCategory = 'DEFAULT',

    [Parameter(Mandatory=$False)]
    [ValidateSet($null, 'warning', 'error', 'critical')]
    [string] $eventSeverity,

    [Parameter(Mandatory=$True)]
    [string] $eventMessageText,

    [Parameter(Mandatory=$False)]
    [string] $genericCIMonitoringId = 'DEFAULT',

    [Parameter(Mandatory=$False)]
    [string] $resourceId,

    [Parameter(Mandatory=$False)]
    [string] $forcedMonitoringId
  )

  # Set default values
  If (@('critical','error','warning') -notcontains $env:CFG_DEFAULT_INC_CRITICALITY) {
    Write-Error "Invalid configuration value [$($env:CFG_DEFAULT_INC_CRITICALITY)] for [CFG_DEFAULT_INC_CRITICALITY], defaults to 'warning'"
    $env:CFG_DEFAULT_INC_CRITICALITY = "warning"
  }
  If (@('availability', 'performance') -notcontains $env:CFG_DEFAULT_INC_TYPE) {
    Write-Error "Invalid configuration value [$($env:CFG_DEFAULT_INC_TYPE)] for [CFG_DEFAULT_INC_TYPE], defaults to 'availability'"
    $env:CFG_DEFAULT_INC_TYPE = "availability"
  }
  $dateTimeSent = (get-date -AsUTC -format O).ToString()
  $eventSeverity = ([string]::IsNullOrEmpty($eventSeverity)) ? $env:CFG_DEFAULT_INC_CRITICALITY : $eventSeverity
  $severityMapping = @{
    critical = 1
    error = 2
    warning = 3
  }

  # Strip HTML tags from text and handle line returns
  $eventMessageText = $eventMessageText -replace '<[^>]+>',''
  $eventMessageText = $eventMessageText -replace "\\r", "`n"
  $eventMessageText = $eventMessageText -replace "`n`n", "`n"

  # Determine monitoring ID
  $genericCIMonitoringId = ($genericCIMonitoringId -eq "DEFAULT") ? ($env:CFG_DEFAULT_INC_GENERIC_CI_MONITORINGID).Trim() : $genericCIMonitoringId
  $monitoringId = $genericCIMonitoringId
  If (-Not ([string]::IsNullOrEmpty($forcedMonitoringId))) {
    $monitoringId = $forcedMonitoringId
  } elseif (-Not ([string]::IsNullOrEmpty($resourceId))) {
    $monitoringId = Get-MonitoringIdFromResourceId -ResourceId $resourceId
    If ($null -eq $monitoringId) {
      WriteDebugMsg "CMDB CI class not supported, fallback to generic CI"
      $monitoringId = $genericCIMonitoringId
    }
  }
  if ($monitoringId -ne $genericCIMonitoringId) {
    # If not generic CI was specified, verify if the CI exists
    $CI = GetSNOWCMDBConfigurationItemObject -snowConfiguration $snowConfiguration -monitoringId $monitoringId

    If (($null -ne $CI) -or ($CI.count -eq 1)) {
      Write-Host ("Found CI with monitoring ID [" + $monitoringId + "] and monitoring tool [" + $snowConfiguration.MonitoringToolName + "]")
    } else {
      If ($env:CFG_CMDB_ENABLE_CI_CREATION -eq "TRUE") {
        If ([string]::IsNullOrEmpty($forcedMonitoringId)) {
          Write-Error ("Cannot find CI with monitoring ID [" + $monitoringId + "] and monitoring tool [" + $snowConfiguration.MonitoringToolName + "]")

          # CI does not exists, try to create the CI
          Write-Host "CMDB CI not found, trying to create the CI in ServiceNow"
          $params = @{
            snowConfiguration = $snowConfiguration
            eventType         = 'create_or_update'
            resourceId        = $resourceId
          }
          CreateSNOWCMDBConfigurationItem @params | Out-Null

          # Verify the CI creation, if not found then fallback to the generic CI
          $CI = GetSNOWCMDBConfigurationItemObject -snowConfiguration $snowConfiguration -monitoringId $monitoringId
          If (($null -ne $CI) -and ($CI.count -eq 1)) {
            Write-Host "CMDB CI created successfully"
          } else {
            Write-Error "CMDB CI failed to be created ! fallback to generic CI"
            $monitoringId = $genericCIMonitoringId
          }
        } else {
          # CI does not exists, but a custom monitoring ID was specified, do not try to create the CI and fallback to generic CI
          Write-Error ("Cannot find CI with monitoring ID [" + $monitoringId + "] and monitoring tool [" + $snowConfiguration.MonitoringToolName + "], fallback to generic CI")
          $monitoringId = $genericCIMonitoringId
        }
      } else {
        WriteDebugMsg "CMDB CI creation disabled, fallback to generic CI"
        $monitoringId = $genericCIMonitoringId
      }
    }
  }

  # Send the Incident to SNOW
  If ($nativeSNOWSupport) {
    $CI = GetSNOWCMDBConfigurationItemObject -snowConfiguration $snowConfiguration -monitoringId $monitoringId
    $params = @{
      snowConfiguration   = $snowConfiguration
      incidentMessage     = $eventMessageText
      incidentSeverity    = $severityMapping[$eventSeverity]
      configItemSysId     = $CI.sys_id
    }
    $result = SendSNOWIncidentNative @params
  } else {
    # Create the SOAP request for the ATF Event that will create the incident
    $params = @{
      eventId         = 'azure://' + (New-Guid).Guid.ToString() + '/' + (Get-Date -Format 'HmmMMddyyyy').ToString()
      dateTimeOccured = ([string]::IsNullOrEmpty($dateTimeOccured)) ? $dateTimeSent : (Get-Date -Date $dateTimeOccured -AsUTC -Format O).ToString()
      dateTimeSent    = $dateTimeSent
      eventType       = ($eventType -eq "DEFAULT") ? ($env:CFG_DEFAULT_INC_TYPE).ToUpper() : $eventType.ToUpper()
      eventSender     = ($env:CFG_DEFAULT_INC_MONITORING_TOOL).Trim().ToUpper()
      eventMessage    = $eventMessageText
      eventHostname   = 'azure://' + $monitoringId.replace('azure://','')
      eventSeverity   = $eventSeverity
      eventSeverityNb = $severityMapping[$eventSeverity]
      monitoringId    = $monitoringId
      eventSource     = ($env:CFG_DEFAULT_INC_MONITORING_TOOL).Trim().replace('ATF-','').Tolower()
      eventCategory   = ($eventCategory -eq "DEFAULT") ? ($env:CFG_DEFAULT_INC_CATEGORY).Trim() : $eventCategory + ($env:CFG_DEFAULT_INC_CAT_SUFFIX).Trim()
      targetSnowFO    = $configItemData.targetsnowfo
    }
    $soapRequest = BuildSNOWSoapRequestForEvent @params

    # Send request to Snow
    $result = SendSNOWSoapRequestsForEvent -snowConfiguration $snowConfiguration -soapRequest $soapRequest
  }

  return $result
}
