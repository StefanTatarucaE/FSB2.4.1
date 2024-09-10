<#
  This include file is for implementation of ServiceNow using ATF2 - Specific functions
#>

##
## SNOW CMDB functions
##

# Define the list of supported resource types for Azure CMDB
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
    'microsoft.network/loadbalancers',
    'microsoft.containerregistry/registries',
    'microsoft.storage/storageaccounts',
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
    'microsoft.sql/managedinstances',
    'microsoft.sql/servers',
    'microsoft.sqlvirtualmachine/sqlvirtualmachines',
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

function BuildSNOWSoapRequestForCMDB {
  Param(
      [Parameter(Mandatory=$True)]
      [System.Collections.Specialized.OrderedDictionary] $Object
  )
  If ($null -eq $Object["SACM_URL"]) {
      throw("Missing mandatory property [SACM_URL] in object !")
  }
  $SACM_url = $Object["SACM_URL"]

  $SoapRequest = "<soapenv:Envelope xmlns:soapenv=`"http://schemas.xmlsoap.org/soap/envelope/`" xmlns:u=`"http://www.service-now.com/$($SACM_url)`">`n"
  $SoapRequest+= "    <soapenv:Header/>`n"
  $SoapRequest+= "    <soapenv:Body>`n"
  $SoapRequest+= "        <u:insertMultiple>`n"
  $SoapRequest+= "            <u:record>`n"

  Foreach ($property in $Object.GetEnumerator()) {
      If ($property.Key -eq "SACM_URL") {continue}
      If ($null -eq $property.Value) {
          $SoapRequest+= "                <"+$property.Key+"/>`n"
      } else {
          $SoapRequest+= "                <"+$property.Key+">"+$property.Value+"</"+$property.Key+">`n"
      }
  }

  $SoapRequest+= "            </u:record>`n"
  $SoapRequest+= "        </u:insertMultiple>`n"
  $SoapRequest+= "    </soapenv:Body>`n"
  $SoapRequest+= "</soapenv:Envelope>`n"
  return $SoapRequest
}

function SendSNOWSoapRequestsForCMDB {
  Param(
    [Parameter(Mandatory=$True)]
    [hashtable] $snowConfiguration
  )

  If ($env:DEBUG_SKIP_SNOW -eq "TRUE") {
    $snowConfiguration["InstanceUrl"] = ""
  }

  # Generate Headers
  $UserPass = $snowConfiguration["Username"]+":"+$snowConfiguration["Password"]
  $EncodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($UserPass))
  $AuthHeaderValue = "Basic ${EncodedCreds}"
  $Headers = @{
    "Accept"        = "application/json"
    "Authorization" = $AuthHeaderValue
  }

  # Loop to all CIs/relations to be created and send them to SNOW
  for($i=0; $i -lt $ConfigItemsObj.count; $i++){
    WriteDebugMsg ("----------------------------------------------------------------------")

    # Check if the CI already exists
    If ($ConfigItemsObj[$i].Keys -contains "u_monitoring_object_id") {
      $existingCI = GetSNOWCMDBConfigurationItemObject -snowConfiguration $snowConfiguration -monitoringId $ConfigItemsObj[$i]["u_monitoring_object_id"]
      If ($null -ne $existingCI) {
        WriteDebugMsg ("The CI already exists, it will be updated - SysID [" + $existingCI.sys_id + "]")
      } else {
        WriteDebugMsg ("The CI does not exist, it will be created")
        $installed_date = (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString()
        $ConfigItemsObj[$i]["u_installed"] = $installed_date
      }
    }

    # Build SOAP message for this CI
    $SoapRequest = BuildSNOWSoapRequestForCMDB -Object $ConfigItemsObj[$i]

    If ($snowConfiguration["InstanceUrl"] -like "https://*") {
      $snowEndpointUrl = $snowConfiguration["InstanceUrl"] + "/" +$ConfigItemsObj[$i]["SACM_URL"]
      Write-Host ("Processing SOAP Request #"+($i+1)+" ServiceNow Endpoint ["+$snowEndpointUrl+"] ["+$snowConfiguration["EnvironmentCode"]+"]")
      WriteDebugMsg ("`n"+$SoapRequest)
    } else {
      Write-Host ("Printing SOAP Request #"+($i+1)+" Invalid ServiceNow Endpoint Url, skipping API call")
      WriteDebugMsg ("`n"+$SoapRequest)
      continue;
    }

    $params = @{
      Method = "POST"
      headers = $headers
      ContentType = 'application/json'
      Body = $SoapRequest
      Uri = $snowEndpointUrl
    }

    try {
      [xml]$APIResponse = Invoke-RestMethod @params -ErrorAction Stop
      If ($APIResponse.Envelope.Body.insertMultipleResponse.insertResponse) {
        $status_msg = $APIResponse.Envelope.Body.insertMultipleResponse.insertResponse.status
        $status_txt = $APIResponse.Envelope.Body.insertMultipleResponse.insertResponse.status_message
        If ($status_txt) {
          $status_txt = $status_txt.replace("`nNormalisation results","- Normalisation results")
          $status_txt = $status_txt.replace("`n","")
        } else {
          $status_txt = "n/a"
        }
        If (@('inserted','updated','deleted','ignored') -notcontains $status_msg) {
          Write-Error ("Invalid status code ["+$status_msg+"] message ["+$status_txt+"]")
          return $false
        }
        Write-Host ("-> Status Response Code ["+$status_msg+"]")
        Write-Host ("-> Status Response Message ["+$status_txt+"]")
      }
      WriteDebugMsg ("----------------------------------------------------------------------")
    } catch {
      $ExceptionMessage = If ($_) {$_.ToString()} else {"Unknown Exception"}
      Write-Error ("Error during HTTP Post : "+$ExceptionMessage)
      return $false
    }
  }
  return $true
}

##
## SNOW INCIDENT functions
##

function BuildSNOWSoapRequestForEvent {
  Param(
    [Parameter(Mandatory=$True)]
    [string] $eventId,

    [Parameter(Mandatory=$True)]
    [string] $dateTimeOccured,
    
    [Parameter(Mandatory=$True)]
    [string] $dateTimeSent,

    [Parameter(Mandatory=$True)]
    [string] $eventType,

    [Parameter(Mandatory=$True)]
    [string] $eventSender,

    [Parameter(Mandatory=$True)]
    [string] $eventMessage,

    [Parameter(Mandatory=$True)]
    [string] $eventHostname,

    [Parameter(Mandatory=$True)]
    [string] $eventSeverity,

    [Parameter(Mandatory=$True)]
    [int] $eventSeverityNb,

    [Parameter(Mandatory=$True)]
    [string] $monitoringId,

    [Parameter(Mandatory=$True)]
    [string] $eventSource,

    [Parameter(Mandatory=$True)]
    [string] $eventCategory,

    [Parameter(Mandatory=$True)]
    [string] $targetSnowFO

  )

  $SoapRequest = "<soapenv:Envelope xmlns:soapenv=`"http://schemas.xmlsoap.org/soap/envelope/`" xmlns:esb=`"http://esb.atos.net/services/ESBEventService/`" xmlns:com=`"http://esb.atos.net/schemas/common`" xmlns:even=`"http://esb.atos.net/schemas/event`">`n"
  $SoapRequest+= "  <soapenv:Header/>`n"
  $SoapRequest+= "  <soapenv:Body>`n"
  $SoapRequest+= "    <esb:createEvent>`n"
  $SoapRequest+= "      <statusNotificationSubscription>NEVER</statusNotificationSubscription>`n"
  $SoapRequest+= "      <event>`n"
  $SoapRequest+= "        <even:eventKey>`n"
  $SoapRequest+= "          <even:eventID>" + $eventId + "</even:eventID>`n"
  $SoapRequest+= "          <even:eventSender>" + $eventSender + "</even:eventSender>`n"
  $SoapRequest+= "        </even:eventKey>`n"
  $SoapRequest+= "        <even:eventTime>`n"
  $SoapRequest+= "          <even:timeOccured>" + $dateTimeOccured + "</even:timeOccured>`n"
  $SoapRequest+= "          <even:timeSent>" + $dateTimeSent + "</even:timeSent>`n"
  $SoapRequest+= "        </even:eventTime>`n"
  $SoapRequest+= "        <even:eventClass>`n"
  $SoapRequest+= "          <even:eventType>" + $eventType + "</even:eventType>`n"
  $SoapRequest+= "          <even:eventSenderType>" + $eventSender + "</even:eventSenderType>`n"
  $SoapRequest+= "          <even:eventMessageText>" + [System.Web.HttpUtility]::HtmlEncode($eventMessage) + "</even:eventMessageText>`n"
  $SoapRequest+= "          <even:eventHostname>" + $eventHostname + "</even:eventHostname>`n"
  $SoapRequest+= "          <even:eventSeverity>" + $eventSeverity + "</even:eventSeverity>`n"  
  $SoapRequest+= "        </even:eventClass>`n"
  $SoapRequest+= "        <even:configItemID>`n"
  $SoapRequest+= "          <even:id>" + $monitoringId + "</even:id>`n"
  $SoapRequest+= "          <even:idType>EXT_ID</even:idType>`n"
  $SoapRequest+= "          <even:configItemSource>" + $eventSource + "</even:configItemSource>`n"
  $SoapRequest+= "        </even:configItemID>`n"
  $SoapRequest+= "        <even:troubleTicket>`n"
  $SoapRequest+= "          <even:category>" + $eventCategory + "</even:category>`n"
  $SoapRequest+= "          <even:priority>High</even:priority>`n"
  $SoapRequest+= "        </even:troubleTicket>`n"
  $SoapRequest+= "        <even:additionalEventAttributes>`n"
  $SoapRequest+= "          <even:attribute>`n"
  $SoapRequest+= "            <even:name>FunctionalOrganization</even:name>`n"
  $SoapRequest+= "            <even:value>" + $targetSnowFO + "</even:value>`n"
  $SoapRequest+= "          </even:attribute>`n"
  $SoapRequest+= "          <even:attribute>`n"
  $SoapRequest+= "            <even:name>incident_urgency</even:name>`n"
  $SoapRequest+= "            <even:value>" + $eventSeverityNb + "</even:value>`n"
  $SoapRequest+= "          </even:attribute>`n"
  $SoapRequest+= "          <even:attribute>`n"
  $SoapRequest+= "            <even:name>incident_impact</even:name>`n"
  $SoapRequest+= "            <even:value>" + $eventSeverityNb + "</even:value>`n"
  $SoapRequest+= "          </even:attribute>`n"
  $SoapRequest+= "        </even:additionalEventAttributes>`n"
  $SoapRequest+= "      </event>`n"
  $SoapRequest+= "    </esb:createEvent>`n"
  $SoapRequest+= "  </soapenv:Body>`n"
  $SoapRequest+= "</soapenv:Envelope>`n"

  return $SoapRequest
}

function SendSNOWSoapRequestsForEvent {
  Param(
    [Parameter(Mandatory=$True)]
    [hashtable] $snowConfiguration,

    [Parameter(Mandatory=$True)]
    [string] $soapRequest
  )

  If ($env:DEBUG_SKIP_SNOW -eq "TRUE") {
    $snowConfiguration["InstanceUrl"] = ""
  }

  # Generate Headers
  $UserPass = $snowConfiguration["Username"]+":"+$snowConfiguration["Password"]
  $EncodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($UserPass))
  $AuthHeaderValue = "Basic ${EncodedCreds}"
  $Headers = @{
    "Accept"        = "application/json"
    "Authorization" = $AuthHeaderValue
  }

  WriteDebugMsg ("----------------------------------------------------------------------")

  If ($snowConfiguration["InstanceUrl"] -like "https://*") {
    $snowEndpointUrl = $snowConfiguration["InstanceUrl"] + "/ServiceEventManagement.do?SOAP"
    Write-Host ("Processing SOAP Request #"+($i+1)+" ServiceNow Endpoint ["+$snowEndpointUrl+"] ["+$snowConfiguration["EnvironmentCode"]+"]")
    WriteDebugMsg ("`n"+$soapRequest)
  } else {
    Write-Host ("Printing SOAP Request #"+($i+1)+" Invalid ServiceNow Endpoint Url, skipping API call")
    WriteDebugMsg ("`n"+$soapRequest)
    continue;
  }

  $params = @{
    Method = "POST"
    headers = $headers
    ContentType = 'application/json'
    Body = $soapRequest
    Uri = $snowEndpointUrl
  }

  try {
    [xml]$APIResponse = Invoke-RestMethod @params -ErrorAction Stop
    If ($APIResponse.Envelope.Body.createEventResponse.return) {
      $returnCode = $APIResponse.Envelope.Body.createEventResponse.return.returnCode
      $returnCodeDesc = $APIResponse.Envelope.Body.createEventResponse.return.description
      $returnDetail = $APIResponse.Envelope.Body.createEventResponse.return.detail

      If (($returnCode -eq "SIA-0000") -or ($returnDetail -match "\[EVENT.{10}?\]" )) {
        Write-Host ("Success, return code '"+ $returnCode +"' desc '"+ $returnCodeDesc +"' detail '"+ $returnDetail +"'")
      } else {
        Write-Error ("Invalid return code '"+ $returnCode +"' desc '"+ $returnCodeDesc +"' detail '"+ $returnDetail +"'")
        return $false
      }
    }
    WriteDebugMsg ("----------------------------------------------------------------------")
  } catch {
    $ExceptionMessage = If ($_) {$_.ToString()} else {"Unknown Exception"}
    Write-Error ("Error during HTTP Post : "+$ExceptionMessage)
    return $false
  }

  return $true
}