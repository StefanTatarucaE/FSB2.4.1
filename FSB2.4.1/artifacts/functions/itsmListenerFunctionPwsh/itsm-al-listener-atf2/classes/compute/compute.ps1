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
## VM SERVER
##


# Determine the CI class depending on the VM O.S
$server_os_string = ($ConfigItemData.osNameVersion+"|"+$ConfigItemData.osFamily).ToLower()
$server_ci_class = 'cmdb_ci_win_server'
ForEach ($keyword in ('linux', 'redhat', 'debian', 'ubuntu', 'archos')) {
    If ($server_os_string -like ("*"+$keyword+"*")) {$server_ci_class = 'cmdb_ci_linux_server'}
}


If (-Not($nativeSNOWSupport)) {

  ##
  ## Create CI Object for ATF ServiceNow implementation
  ##

  $VMInstanceCIName = $ConfigItemData.resourceName + $env:CFG_CMDB_VM_CI_VMINSTANCE_NAME_SUFFIX
  $VMServerCIName = $ConfigItemData.resourceName + $env:CFG_CMDB_VM_CI_SERVER_NAME_SUFFIX

  $params = @{
      SNOW_Transform_Map = "u_sacm_ci_server"
      MonitoringId = $ConfigItemData.monitoringId
      MonitoringId_LastSegment = $ConfigItemData.resourceName + "-OS"
      CMDB_Attributes = [ordered] @{
          u_name                          = $VMServerCIName
          u_class                         = $server_ci_class
          u_model_id                      = $env:CFG_CMDB_CI_VMSERVER_MODELID
          u_ram                           = $ConfigItemData.memoryGb
          u_cpu_count                     = $ConfigItemData.vCPUs
          u_t_shirt_size                  = $ConfigItemData.tshirtSize
          u_fully_qualified_domain_name   = $ConfigItemData.fqdn
          u_operating_system              = $ConfigItemData.osNameVersion
          u_os_version                    = $ConfigItemData.osNameVersion
          u_os_family                     = $ConfigItemData.osFamily
          u_host_name                     = $ConfigItemData.computerName
          u_serial_number                 = $ConfigItemData.serialNumber
          u_is_virtual                    = "true"
          u_device_type                   = "Virtual Server"
      }
  }
  RegisterSNOWConfigItemObject @params

  ## VM INSTANCE

  $params = @{
      SNOW_Transform_Map = "u_sacm_ci_vm_instance"
      MonitoringId = $ConfigItemData.monitoringId
      CMDB_Attributes = [ordered] @{
          u_name                          = $VMInstanceCIName
          u_class                         = "cmdb_ci_vm_instance"
          u_model_id                      = $env:CFG_CMDB_CI_VMINSTANCE_MODELID
          u_object_id                     = $ConfigItemData.resourceId
          u_memory__mb_                   = $ConfigItemData.memoryGb
          u_cpus                          = $ConfigItemData.vCPUs
          u_t_shirt_size                  = $ConfigItemData.tshirtSize
          u_power_status                  = $ConfigItemData.poweredOn ? 'poweredOn' : 'poweredOff'
          u_fully_qualified_domain_name   = $ConfigItemData.fqdn
          u_operating_system              = $ConfigItemData.osNameVersion
          u_serial_number                 = $ConfigItemData.serialNumber
          u_description                   = $ConfigItemData.resourceFriendlyName + " Resource ID " + $ConfigItemData.resourceId
      }
  }
  RegisterSNOWConfigItemObject @params

  ## RELATIONS

  $params = @{
      Relations_Attributes = @{
          r_parent_name               = $VMServerCIName
          r_type                      = "Virtualized by::Virtualizes"
          r_child_name                = $VMInstanceCIName
      }
  }
  RegisterSNOWConfigItemRelations @params

} else {

  ##
  ## Create CI Object for NATIVE ServiceNow implementation
  ##
  
  $VMServerCIName = $ConfigItemData.resourceName

  $params = @{
    MonitoringId = $ConfigItemData.monitoringId
    CMDB_Attributes = [ordered] @{
        name                            = $VMServerCIName
        class                           = $server_ci_class
        host_name                       = $VMServerCIName
        virtual                         = 'true'
        ram                             = [string] $ConfigItemData.memoryGb
        cpu_count                       = [string] $ConfigItemData.vCPUs
        os                              = $ConfigItemData.osFamily
        os_version                      = $ConfigItemData.osNameVersion
        short_description               = $ConfigItemData.resourceFriendlyName + " Resource ID " + $ConfigItemData.resourceId
    }
  }
  RegisterSNOWConfigItemObject @params
}
