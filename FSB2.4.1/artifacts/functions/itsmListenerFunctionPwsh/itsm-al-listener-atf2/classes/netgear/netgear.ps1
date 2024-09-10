#################################################################################################
##                                                                                             ## 
##                           INCLUDE FILE FOR CMDB CI-CLASS                                    ##
##                                                                                             ## 
##   Input JSON message from CMDB Logic-app is available in variable $ConfigItemData           ##
##   Example : $ConfigItemData.myproperty                                                      ##
##                                                                                             ## 
##   RegisterSNOWConfigItemObject (for ATF ServiceNow / Non-native support)                    ## 
##    - SNOW_Endpoint : Something like "u_sacm_ci_server.do?SOAP"                              ## 
##    - MonitoringId_LastSegment : Last part of monitoringId (optional, default to u_name)     ## 
##    - CMDB_Attributes :                                                                      ##
##      Mandatory parameters are : u_name, u_class, u_model_id                                 ##
##      Following parameters are automaticaly generated and should not be provided :           ##
##        - u_company                                                                          ##
##        - u_is_monitored                                                                     ##
##        - u_monitoring_object_id                                                             ##
##        - u_monitoring_tool                                                                  ##
##        - u_location                                                                         ##
##        - u_criticality                                                                      ##
##        - u_in_service_date                                                                  ##
##        - u_installed                                                                        ##
##        - u_operational_status                                                               ##
##                                                                                             ##
##   RegisterSNOWConfigItemObject (for Native support)                                         ##
##    - MonitoringId_LastSegment : Last part of monitoringId (optional, default to name)       ##
##    - CMDB_Attributes :                                                                      ##
##      Mandatory parameters are : name, class                                                 ##
##                                                                                             ##
#################################################################################################


##
## Network Gear
##

If (-Not($nativeSNOWSupport)) {

  ##
  ## Create CI Object for ATF ServiceNow implementation
  ##

  $params = @{
    SNOW_Transform_Map = "u_sacm_ci_network_gear"
    CMDB_Attributes = [ordered] @{
        u_name            = $ConfigItemData.resourceName
        u_class           = "cmdb_ci_netgear"
        u_model_id        = $ConfigItemData.modelId
        u_device_type     = ( $null -ne $ConfigItemData.deviceType ) ? $ConfigItemData.deviceType : ''
        u_function_type   = ( $null -ne $ConfigItemData.functionType ) ? $ConfigItemData.functionType : ''
        u_is_virtual      = "true"
        u_description     = $ConfigItemData.resourceFriendlyName + " Resource ID " + $ConfigItemData.resourceId
    }
  }

} else {

  ##
  ## Create CI Object for NATIVE ServiceNow implementation
  ##
  
  If ($ConfigItemData.deviceType -eq "Virtual Firewall") {$ConfigItemData.deviceType = "Firewall"}
  If ($ConfigItemData.deviceType -eq "HA-Pair") {$ConfigItemData.deviceType = "Bridge"}

  $params = @{
    CMDB_Attributes = [ordered] @{
        name                = $ConfigItemData.resourceName
        class               = "cmdb_ci_netgear"
        device_type         = ( $null -ne $ConfigItemData.deviceType ) ? $ConfigItemData.deviceType : ''
        short_description   = $ConfigItemData.resourceFriendlyName + " Resource ID " + $ConfigItemData.resourceId
    }
  }

}

RegisterSNOWConfigItemObject @params

