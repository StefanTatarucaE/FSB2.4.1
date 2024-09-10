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
## APPLICATION GATEWAY - Load balancer
##

If (-Not($nativeSNOWSupport)) {

  ##
  ## Create CI Object for ATF ServiceNow implementation
  ##

  $params = @{
    SNOW_Transform_Map = "u_sacm_ci_sw_load_balancer"
    CMDB_Attributes    = [ordered] @{
        u_name          = $ConfigItemData.resourceName + "-SLB"
        u_class         = "cmdb_ci_lb_appl"
        u_model_id      = $ConfigItemData.modelId
        u_install_staus = "1"
        u_category      = "Software"
        u_subcategory   = "Loadbalancer"
        u_function_type = "Load Balancer"
        u_software      = ($null -ne $ConfigItemData.lb_software) ? $ConfigItemData.lb_software : ""
        u_ip_address    = ($null -ne $ConfigItemData.lb_ipaddress) ? $ConfigItemData.lb_ipaddress : ""
        u_description   = $ConfigItemData.resourceFriendlyName + " Resource ID " + $ConfigItemData.resourceId
        u_device_type   = "Virtual Load Balancer"
    }
  }

} else {

  ##
  ## Create CI Object for NATIVE ServiceNow implementation
  ##

  $params = @{
    CMDB_Attributes = [ordered] @{
        name                = $ConfigItemData.resourceName + "-SLB"
        class               = "cmdb_ci_lb_appl"
        category            = "Software"
        subcategory         = "Loadbalancer"
        function_type       = "Load Balancer"
        software            = ($null -ne $ConfigItemData.lb_software) ? $ConfigItemData.lb_software : ""
        ip_address          = ($null -ne $ConfigItemData.lb_ipaddress) ? $ConfigItemData.lb_ipaddress : ""
        short_description   = $ConfigItemData.resourceFriendlyName + " Resource ID " + $ConfigItemData.resourceId
    }
  }

}

RegisterSNOWConfigItemObject @params