<#
  This include file is for NATIVE implementation of ServiceNow - Specific functions
#>

##
## SNOW CMDB functions
##

# Define the list of supported resource types for Azure CMDB for NATIVE SNOW integration
function GetCMDBAzureSupportedResourceTypes {
  Param(
    [Parameter(Mandatory=$True)]
    [string] $resourceId
  )

  $managedResourceTypes = @(
    'microsoft.compute/virtualmachines',
    'microsoft.compute/virtualmachinescalesets',
    'microsoft.web/serverfarms',
    'microsoft.web/sites',
    'microsoft.network/applicationgateways',
    'microsoft.network/loadbalancers'
    'microsoft.containerregistry/registries',
    'microsoft.storage/storageaccounts'
    'microsoft.sql/managedinstances',
    'microsoft.sql/servers',
    'microsoft.keyvault/vaults',
    'microsoft.cache/redis',
    'microsoft.documentdb/databaseaccounts',
    'microsoft.dbformariadb/servers',
    'microsoft.dbformysql/servers',
    'microsoft.dbforpostgresql/servers',
    'microsoft.databricks/workspaces',
    'microsoft.datafactory/factories',
    'microsoft.sql/servers/databases',
    'microsoft.sql/managedinstances/databases',
    'microsoft.containerservice/managedclusters',
    'microsoft.network/networksecuritygroups',
    'microsoft.network/azurefirewalls',
    'microsoft.network/virtualnetworkgateways',
    'microsoft.network/expressroutecircuits',
    'microsoft.analysisservices/servers',
    'microsoft.network/bastionhosts'
  )

  $resourceType = ($resourceId -split "/")[6] + '/' + ($resourceId -split "/")[7]
  if ((($resourceType -eq 'Microsoft.Sql/servers') -or ($resourceType -eq 'Microsoft.Sql/managedInstances')) -and ($resourceId -like '*/databases/*')) {
    $resourceType += '/databases'
  }
  return ($managedResourceTypes -contains $resourceType) ? $true : $false
}

function SendSNOWCmdbNative {
  Param(
    [Parameter(Mandatory=$True)]
    [hashtable] $snowConfiguration
  )

  If ($env:DEBUG_SKIP_SNOW -eq "TRUE") {
    $snowConfiguration["InstanceUrl"] = ""
  }

  # Loop through all CIs and create them in SNOW, ignore relations
  for($i=0; $i -lt $ConfigItemsObj.count; $i++){
    If ($ConfigItemsObj[$i].Keys -contains "r_type") {Continue}
    WriteDebugMsg ("----------------------------------------------------------------------")

    # Construct attributes array for CI
    $configItemAttributes = [ordered] @{}
    ForEach ($CMDB_Attribute in $ConfigItemsObj[$i].GetEnumerator()) {
      If (@('class','monitoring_object_id') -notcontains $CMDB_Attribute.Name) {
        If ($CMDB_Attribute.Name -eq 'short_description') {
          $monitoringIdString = "[MONITORING-ID:" + $ConfigItemsObj[$i]["monitoring_object_id"] + "]"
          $configItemAttributes["short_description"] = $monitoringIdString + "`n" + $CMDB_Attribute.Value
        } else {
          $configItemAttributes[$CMDB_Attribute.Name] = $CMDB_Attribute.Value
        }
      }
    }
    $configItemParamsJson = $configItemAttributes | ConvertTo-Json -Depth 99

    # Check if the CI already exists in Snow with same name
    $encodedFilterString    = "company=" + $snowConfiguration.CompanySysId + "^name=" + $configItemAttributes.name
    $encodedFilterString    = [System.Web.HttpUtility]::UrlEncode($encodedFilterString)
    $params = @{
        apiUrl          = $snowConfiguration["InstanceUrl"] + "/api/now/table/cmdb_ci?sysparm_query=" + $encodedFilterString
        basicUsername   = $snowConfiguration["Username"]
        basicPassw      = $snowConfiguration["Password"]
    }
    $response = Invoke-RestAPIDataRequest @params
    If (($null -ne $response) -and ($null -ne $response.result[0].sys_id)) {
      $existingCISysId = $response.result[0].sys_id
      $apiUrl = $snowConfiguration["InstanceUrl"] + '/api/now/table/' + $ConfigItemsObj[$i]["class"] + '/' + $existingCISysId
      $apiMethod = "PUT"
      WriteDebugMsg ("Found existing CI in ServiceNow with same name, updating CI with ID [$($existingCISysId)]")
    } else {
      $existingCISysId = $null
      $apiUrl = $snowConfiguration["InstanceUrl"] + '/api/now/table/' + $ConfigItemsObj[$i]["class"]
      $apiMethod = "POST"
      WriteDebugMsg ("No existing CI found in ServiceNow with same name, creating a new CI")
    }

    # Send CI creation request to SNOW
    If ($snowConfiguration["InstanceUrl"] -like "https://*") {
      Write-Host ("Processing REST $($apiMethod) request to CMDB Instance API [" + $snowConfiguration["InstanceUrl"] + "] [" + $snowConfiguration["EnvironmentCode"] + "]")
      WriteDebugMsg ("`n" + $configItemParamsJson)
    } else {
      Write-Host ("Printing REST $($apiMethod) request data - Invalid ServiceNow Endpoint Url, skipping API call")
      WriteDebugMsg ("`n" + $configItemParamsJson)
      Continue
    }
    $params = @{
      APIurl          = $apiUrl
      basicUsername   = $snowConfiguration["Username"]
      basicPassw      = $snowConfiguration["Password"]
      APIMethod       = $apiMethod
      BodyJSON        = $configItemParamsJson
    }
    $response = Invoke-RestAPIDataRequest @params
    If ($response) {
      $ConfigItemsObj[$i]["sys_id"] = $response.result.sys_id
      WriteDebugMsg ("API RESPONSE:`n" + ($response.result | ConvertTo-Json -Depth 99))
    }
  }
  
  # Loop through all CIs relations and create them in SNOW
  for($i=0; $i -lt $ConfigItemsObj.count; $i++){
    If ($ConfigItemsObj[$i].Keys -notcontains "r_type") {Continue}
    WriteDebugMsg ("----------------------------------------------------------------------")

    # Get ID of the specified relation type, and get parent and child CIs
    $params = @{
      APIUrl          = $snowConfiguration["InstanceUrl"] + "/api/now/table/cmdb_rel_type?sysparm_query=name%3D" + $ConfigItemsObj[$i]["r_type"]
      basicUsername   = $snowConfiguration["Username"]
      basicPassw      = $snowConfiguration["Password"]
    }
    $response = invoke-RestAPIDataRequest @params
    $relationTypeId = $response.result[0].sys_id
    $parentCI = $ConfigItemsObj | Where-Object -FilterScript {$_.name -EQ $ConfigItemsObj[$i]["r_parent_name"]}
    $childCI = $ConfigItemsObj | Where-Object -FilterScript {$_.name -EQ $ConfigItemsObj[$i]["r_child_name"]}
    If ((-Not($relationTypeId)) -or (-Not($parentCI)) -or (-Not($childCI))) {
      Write-Error ("Invalid data to create the relationship beetween CI ! skipping relation")
      Continue
    }

    # Construct attributes array for CI relation
    $relationParams = @{
      source              = "ServiceNow"
      outbound_relations  = @(@{"type"=$relationTypeId;"target"=$childCI.sys_id})
      inbound_relations   = @()
    }
    $relationParamsJson = $relationParams | ConvertTo-Json -Depth 99

    # Send CI relation creation request to SNOW
    If ($snowConfiguration["InstanceUrl"] -like "https://*") {
      Write-Host ("Processing REST POST request to CMDB Instance API [" + $snowConfiguration["InstanceUrl"] + "] [" + $snowConfiguration["EnvironmentCode"] + "]")
      WriteDebugMsg ("`n" + $relationParamsJson)
    } else {
      Write-Host ("Printing REST POST request data - Invalid ServiceNow Endpoint Url, skipping API call")
      WriteDebugMsg ("`n" + $relationParamsJson)
      Continue
    }
    $params = @{
      APIUrl          = $snowConfiguration["InstanceUrl"] + "/api/now/cmdb/instance/" + $ConfigItemsObj[$i]["r_parent_class"] + "/" + $parentCI.sys_id + "/relation"
      basicUsername   = $snowConfiguration["Username"]
      basicPassw      = $snowConfiguration["Password"]
      APIMethod       = 'POST'
      BodyJSON        = $relationParamsJson
    }
    $response = Invoke-RestAPIDataRequest @params
    If ($response) {
      WriteDebugMsg ($response.result[0] | ConvertTo-Json -Depth 99)
    }
  }

  return $true
}

##
## SNOW INCIDENT functions
##

function SendSNOWIncidentNative {
  Param(
    [Parameter(Mandatory=$True)]
    [hashtable] $snowConfiguration,

    [Parameter(Mandatory=$True)]
    [string] $incidentMessage,

    [Parameter(Mandatory=$True)]
    [string] $incidentSeverity,

    [Parameter(Mandatory=$True)]
    [AllowNull()]
    $configItemSysId
  )

  If ($env:DEBUG_SKIP_SNOW -eq "TRUE") {
    $snowConfiguration["InstanceUrl"] = ""
  }

  If ($incidentMessage -like "*Alert Name :*") {
    $alertNameStr = ($incidentMessage.split("Alert Name : "))[1].split("`n")[0]
  } else {
    $alertNameStr = $env:PRODUCT_CODE + ' Azure incident'
  }

  $incidentStateMapping = @{
    '1' = 'New/Open'
    '2' = 'In Progress'
  }

  $incidentParams = @{
    company           = $snowConfiguration.CompanySysId
    category          = 'incident'
    subcategory       = 'azuremonitoring'
    urgency           = $incidentSeverity
    impact            = $incidentSeverity
    cmdb_ci           = $configItemSysId
    assignment_group  = $snowConfiguration.supportGroupId
    short_description = $alertNameStr
    description       = $incidentMessage
    caller_id         =  $snowConfiguration.callerSysId
  }
  $incidentParamsJson = $incidentParams | ConvertTo-Json -Depth 99

  # Search if an open incident exists with same Alert UID, and exit if found
  If ($incidentParams.description -match "Alert UID \[[0-9]*\]") {
    $alertUid = $Matches[0]
    $encodedFilterString = "stateIN1,2^descriptionSTARTSWITH" + $alertUid
    $encodedFilterString = [System.Web.HttpUtility]::UrlEncode($encodedFilterString)
    $params = @{
      apiUrl          = $snowConfiguration["InstanceUrl"] + "/api/now/table/incident?sysparm_query=" + $encodedFilterString
      basicUsername   = $snowConfiguration["Username"]
      basicPassw      = $snowConfiguration["Password"]
    }
    $response = Invoke-RestAPIDataRequest @params
    if ($response.result.count -gt 0) {
      $incNumber = $response.result[0].number
      $incState = $incidentStateMapping[$response.result[0].state]
      Write-Host "Duplicate incident detected for $($alertUid) number [$($incNumber)] state [$($incState)], alert ignored"
      return $True
    }
  }

  WriteDebugMsg ("----------------------------------------------------------------------")
  If ($snowConfiguration["InstanceUrl"] -like "https://*") {
    Write-Host ("Processing REST POST request to incident table API [" + $snowConfiguration["InstanceUrl"] + "] [" + $snowConfiguration["EnvironmentCode"] + "]")
    WriteDebugMsg ("`n" + $incidentParamsJson)
  } else {
    Write-Host ("Printing REST POST request data - Invalid ServiceNow Endpoint Url, skipping API call")
    WriteDebugMsg ("`n" + $incidentParamsJson)
    return $True
  }

  # Send incident to SNOW
  $params = @{
    apiUrl          = $snowConfiguration["InstanceUrl"] + "/api/now/table/incident"
    basicUsername   = $snowConfiguration["Username"]
    basicPassw      = $snowConfiguration["Password"]
    APIMethod       = 'POST'
    BodyJSON        = $incidentParamsJson
  }
  $response = Invoke-RestAPIDataRequest @params

  return ($response ? $response.result[0] : $null)
}



