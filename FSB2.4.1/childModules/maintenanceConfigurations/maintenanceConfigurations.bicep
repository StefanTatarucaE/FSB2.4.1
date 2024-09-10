/*
SUMMARY: Child module for creating a maintenance Configuration
DESCRIPTION: Module to create a maintenance Configuration (formerly known as patch schedules)
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.1
*/

//PARAMETERS
@description('Specifies the deploy location.')
param location string

@description('Specifies the Maintenance Configuration name.')
param maintenanceConfigurationName string

@description('Specifies the classification category of patches to be patched for Linux.')
param linuxUpdateClassificationsToInclude array

@description('Specifies the classification category of patches to be patched for Windows.')
param windowsUpdateClassificationsToInclude array

@description('Specifies the package names to be excluded for patching Linux.')
param linuxUpdatePackageNameMasksToExclude array

@description('Specifies the package names to be included for patching Linux.')
param linuxUpdatePackageNameMasksToInclude array

@description('Specifies to exclude patches which need reboot for Windows.')
@allowed([
  true
  false
])
param windowsExcludeKbsRequiringReboot bool

@description('Specifies the Windows KBID to be excluded for patching..')
param windowsKbNumbersToExclude array

@description('Specifies the Windows KBID to be included for patching.')
param windowsKbNumbersToInclude array

@description('Specifies the maintenanceScope of the configuration')
@allowed([
  'Extension'
  'Host'
  'InGuestPatch'
  'OSImage'
  'Resource'
  'SQLDB'
  'SQLManagedInstance'
])
param maintenanceScope string

@description('Specifies the reboot preference setting for the patching')
@allowed([
  'ifRequired'
  'Never'
  'Always'
])
param updateRebootSetting string

@description('Specifies the maintenance window duration.')
param maintenanceWindowDuration string

@description('Specifies the maintenance window expiration date time.')
param maintenanceWindowExpirationDateTime string

@description('Specifies the maintenance window recur every.')
param maintenanceWindowRecurEvery string

@description('Specifies the maintenance window start date time.')
param maintenanceWindowStartTime string

@description('Specifies the maintenance window time zone.')
param maintenanceWindowTimeZone string

@description('Specifies the maintenance configuration tag.')
param maintenanceConfigurationTag object

//RESOURCES
// Create the maintenanceConfiguration resource
resource maintenanceConfiguration 'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01' = {
  name: maintenanceConfigurationName
  location: location
  tags:maintenanceConfigurationTag
  properties: {
    extensionProperties: {
      inGuestPatchmode: 'User'
    }
    installPatches: {
      linuxParameters: {
        classificationsToInclude: linuxUpdateClassificationsToInclude
        packageNameMasksToExclude: linuxUpdatePackageNameMasksToExclude
        packageNameMasksToInclude: linuxUpdatePackageNameMasksToInclude
      }
      rebootSetting: updateRebootSetting
      windowsParameters: {
        classificationsToInclude: windowsUpdateClassificationsToInclude
        excludeKbsRequiringReboot: windowsExcludeKbsRequiringReboot
        kbNumbersToExclude: windowsKbNumbersToExclude
        kbNumbersToInclude: windowsKbNumbersToInclude
      }
    }
    maintenanceScope: maintenanceScope
    maintenanceWindow: {
      duration: maintenanceWindowDuration
      expirationDateTime: maintenanceWindowExpirationDateTime
      recurEvery: maintenanceWindowRecurEvery
      startDateTime: maintenanceWindowStartTime
      timeZone: maintenanceWindowTimeZone
    }
    visibility: 'Custom'
  }
}
