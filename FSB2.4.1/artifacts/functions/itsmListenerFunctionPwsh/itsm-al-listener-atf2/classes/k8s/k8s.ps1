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
## Kubernetes Cluster
##

If (-Not($nativeSNOWSupport)) {

  
  ##
  ## Create CI Objects for ATF ServiceNow implementation
  ##

  # Create CI Object for k8s cluster
  $params = @{
    SNOW_Transform_Map = "u_sacm_ci_kubernetes"
    CMDB_Attributes    = [ordered] @{
        u_name          = $ConfigItemData.resourceName + "-CLU"
        u_class         = "cmdb_ci_kubernetes_cluster"
        u_model_id      = $ConfigItemData.modelId
        u_description   = "Azure Kubernetes Service Resource ID " + $ConfigItemData.resourceId
        u_device_type   = "Cluster"
    }
  }
  RegisterSNOWConfigItemObject @params

  # Create CI Object for k8s service
  $params = @{
    SNOW_Transform_Map = "u_sacm_ci_kubernetes"
    MonitoringId_LastSegment = $ConfigItemData.resourceName + "-APP" # cannot be same as monitoring id for k8s cluster
    CMDB_Attributes    = [ordered] @{
        u_name          = $ConfigItemData.resourceName + "-APP"
        u_class         = "cmdb_ci_kubernetes_service"
        u_model_id      = $ConfigItemData.modelId
        u_manufacturer  = ""
        u_description   = "Azure Kubernetes Service Resource ID " + $ConfigItemData.resourceId
        u_device_type   = "Cluster Resource"
    }
  }
  RegisterSNOWConfigItemObject @params

  ##
  ## RELATIONS
  ##
  $params = @{
    Relations_Attributes = @{
        r_parent_name  = $ConfigItemData.resourceName + "-CLU"
        r_parent_class = "cmdb_ci_kubernetes_cluster"
        r_type         = "Provides::Provided By"
        r_child_name   = $ConfigItemData.resourceName + "-APP"
        r_child_class  = "cmdb_ci_kubernetes_service"
    }
  }
  RegisterSNOWConfigItemRelations @params

} else {

  ##
  ## Create CI Objects for NATIVE ServiceNow implementation
  ##

  $params = @{
    CMDB_Attributes = [ordered] @{
        name                = $ConfigItemData.resourceName + "-CLU"
        class               = "cmdb_ci_cluster"
        short_description   = "Azure Kubernetes Service Resource ID " + $ConfigItemData.resourceId
    }
  }
  RegisterSNOWConfigItemObject @params

}

