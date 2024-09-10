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
## Database Instance (server)
##

If (-Not($nativeSNOWSupport)) {

  ##
  ## Create CI Object for ATF ServiceNow implementation
  ##

  $params = @{
    SNOW_Transform_Map = "u_sacm_ci_database_instance"
    CMDB_Attributes = [ordered] @{
        u_name            = $ConfigItemData.resourceName + "-DBI"
        u_class           = "cmdb_ci_db_instance"
        u_model_id        = $ConfigItemData.modelId
        u_category        = "Resource"
        u_subcategory     = "Database"
        u_device_type     = "Database Instance"
        u_function_type   = "Database Server"
        u_support_status  = "Supported"
        u_service_scope   = "Single Customer"
        u_description     = "Azure Database Instance Resource ID " + $ConfigItemData.resourceId
    }
 }

} else {

  ##
  ## Create CI Object for NATIVE ServiceNow implementation
  ##

  $params = @{
    CMDB_Attributes = [ordered] @{
        name                = $ConfigItemData.resourceName + "-DBI"
        class               = "cmdb_ci_db_instance"
        short_description   = "Azure Database Instance Resource ID " + $ConfigItemData.resourceId
    }
  }

}

RegisterSNOWConfigItemObject @params