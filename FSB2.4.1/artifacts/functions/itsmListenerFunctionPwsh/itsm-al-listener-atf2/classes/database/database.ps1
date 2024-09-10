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
## Database
##


If (-Not($nativeSNOWSupport)) {

  ##
  ## Create CI Object for ATF ServiceNow implementation
  ##

  $params = @{
    SNOW_Transform_Map = "u_sacm_ci_database"
    CMDB_Attributes    = [ordered] @{
        u_name           = $ConfigItemData.resourceName + "-DBA"
        u_class          = "cmdb_ci_database"
        u_model_id       = $ConfigItemData.modelId
        u_type           = ($null -ne $ConfigItemData.databaseType) ? $ConfigItemData.databaseType : ""
        u_ci_supported   = "true"
        u_platform_type  = "Production"
        u_support_status = "Supported"
        u_category       = "Resource"
        u_subcategory    = "database"
        u_install_status = "1"
        u_description    = $ConfigItemData.resourceFriendlyName + " Resource ID " + $ConfigItemData.resourceId
        u_function_type  = "Database Server"
        u_device_type    = "Database"
        u_sacm_ci_type   = "Database"
        u_service_scope  = "Single Customer"
        u_state          = "Live"
    }
  }

} else {

  ##
  ## Create CI Object for NATIVE ServiceNow implementation
  ##

  
  switch ($ConfigItemData.databaseType)
  {
    "SQL"
    {
      $dbtype = "Microsoft SQL Server"
    }
    "Postgres SQL"
    {
      $dbtype = "Postgres SQL"
    }
    "MySQL"
    {
      $dbtype = "MySQL"
    }
    Default
    {
      $dbtype = ""
    }
  }

  $params = @{
    CMDB_Attributes = [ordered] @{
        name                = $ConfigItemData.resourceName + "-DBA"
        class               = "cmdb_ci_database"
        type                = $dbtype
        short_description   = $ConfigItemData.resourceFriendlyName + " Resource ID " + $ConfigItemData.resourceId
    }
  }

}

RegisterSNOWConfigItemObject @params

## Only for Microsoft.SQL databases (SQL Server + Managed Instance), create a relationship with database server instance
if( ($ConfigItemData.resourceId -like '*/providers/Microsoft.Sql/*') -and    ($ConfigItemData.resourceId -like '*/databases/*') -and ($ConfigItemData.eventType -ne "delete") ) {

    $db_instance_name = ($ConfigItemData.resourceId -split "/")[8]
    $db_instance_resource_id = ($ConfigItemData.resourceId -split "/databases/")[0]

    If (-Not($nativeSNOWSupport)) {

      ##
      ## Create CI Object for parent Database Instance - ATF ServiceNow implementation
      ##

      $params = @{
          SNOW_Transform_Map = "u_sacm_ci_database_instance"
          MonitoringId = Get-MonitoringIdFromResourceId -ResourceId $db_instance_resource_id -ResourceName $db_instance_name
          CMDB_Attributes = [ordered] @{
              u_name            = $db_instance_name + "-DBI"
              u_class           = "cmdb_ci_db_instance"
              u_model_id        = $ConfigItemData.modelIdDbInstance
              u_category        = "Resource"
              u_subcategory     = "Database"
              u_device_type     = "Database Instance"
              u_function_type   = "Database Server"
              u_support_status  = "Supported"
              u_service_scope   = "Single Customer"
              u_description     = "Azure Database Instance Resource ID " + $db_instance_resource_id
          }
      }
      RegisterSNOWConfigItemObject @params

    } else {

      ##
      ## Create CI Object for parent Database Instance - NATIVE ServiceNow implementation
      ##

      $params = @{
        CMDB_Attributes = [ordered] @{
            name                = $db_instance_name + "-DBI"
            class               = "cmdb_ci_db_instance"
            short_description   = "Azure Database Instance Resource ID " + $db_instance_resource_id
        }
      }
      RegisterSNOWConfigItemObject @params
    }

    $params = @{
      Relations_Attributes = @{
          r_child_name   = $db_instance_name + "-DBI"
          r_child_class  = "cmdb_ci_db_instance"
          r_type         = "Used by::Uses"
          r_parent_name  = $ConfigItemData.resourceName + "-DBA"
          r_parent_class = "cmdb_ci_database"
      }
    }
    RegisterSNOWConfigItemRelations @params

}