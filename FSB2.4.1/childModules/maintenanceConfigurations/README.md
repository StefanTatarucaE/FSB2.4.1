# childModules/maintenanceConfigurations/maintenanceConfigurations.bicep
Bicep module to create the maintenance configurations (formerly known as patch schedules)

## Module Features
This module deploys the `maintenance configurations` resource to the target subscription..

## Parent Module Usage Example
```bicep
module maintenanceConfiguration '../../childModules/maintenanceConfigurations/maintenanceConfigurations.bicep' {
  scope: updateManagerAutomationResourceGroup
  name: 'maintenanceConfig-deployment'
  params: {
    maintenanceConfigurationName: 'linux-dev'
    location: 'west us'
    maintenanceConfigurationTag: {'EvidenPurpose':'EvidenMaintenanceConfig'}
    linuxUpdateClassificationsToInclude: []
    linuxUpdatePackageNameMasksToExclude: []
    linuxUpdatePackageNameMasksToInclude: []
    updateRebootSetting: 'ifRequired'
    windowsUpdateClassificationsToInclude: []
    windowsExcludeKbsRequiringReboot: true
    windowsKbNumbersToExclude: []
    windowsKbNumbersToInclude: '03:55'
    maintenanceScope: 'InGuestPatch'
    maintenanceWindowExpirationDateTime: '9999-12-31 23:59:59'
    maintenanceWindowRecurEvery: '1Day'
    maintenanceWindowStartTime: '2024-02-28 15:00'
    maintenanceWindowTimeZone: 'W. Europe Standard Time'
  }
}
```

## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `maintenanceConfigurationName` | `string` | true | The name of the maintenance configuration. |
| `location` | `string` | true | The deployment location of the maintenance configuration. |
| `maintenanceConfigurationTag` | `Dictionary of tag names and values` | false | the tags used on the maintenance configuration. |
| `linuxUpdateClassificationsToInclude` | `string[]` | true | Classification category of patches to be patched. |
| `linuxUpdatePackageNameMasksToExclude` | `string[]` | false | Package names to be excluded for patching. |
| `linuxUpdatePackageNameMasksToInclude` | `string[]` | false | Package names to be included for patching. |
| `updateRebootSetting` | `string` | true | Possible reboot preference as defined by the user based on which it would be decided to reboot the machine or not after the patch operation is completed. Allowed values: Always, IfRequired , Never |
| `windowsUpdateClassificationsToInclude` | `string` | true | Classification category of patches to be patched. |
| `windowsExcludeKbsRequiringReboot` | `bool` | true | Exclude patches which need reboot. |
| `windowsKbNumbersToExclude` | `string[]` | false | Windows KBID to be excluded for patching. |
| `windowsKbNumbersToInclude` | `string[]` | false | Windows KBID to be included for patching. |
| `maintenanceScope` | `string` | true | maintenanceScope of the configuration. Allowed values: Extension, Host, InGuestPatch, OSImage, Resource, SQLDB, SQLManagedInstance  |
| `maintenanceWindowExpirationDateTime` | `string` | true | Effective expiration date of the maintenance window in YYYY-MM-DD hh:mm format. The window will be created in the time zone provided and adjusted to daylight savings according to that time zone. Expiration date must be set to a future date. If not provided, it will be set to the maximum datetime 9999-12-31 23:59:59. |
| `maintenanceWindowRecurEvery` | `string` | true | Rate at which a Maintenance window is expected to recur. The rate can be expressed as daily, weekly, or monthly schedules. Daily schedule are formatted as recurEvery: [Frequency as integer]['Day(s)']. If no frequency is provided, the default frequency is 1. Daily schedule examples are recurEvery: Day, recurEvery: 3Days. Weekly schedule are formatted as recurEvery: [Frequency as integer]['Week(s)'] [Optional comma separated list of weekdays Monday-Sunday]. Weekly schedule examples are recurEvery: 3Weeks, recurEvery: Week Saturday,Sunday. Monthly schedules are formatted as [Frequency as integer]['Month(s)'] [Comma separated list of month days] or [Frequency as integer]['Month(s)'] [Week of Month (First, Second, Third, Fourth, Last)] [Weekday Monday-Sunday] [Optional Offset(No. of days)]. Offset value must be between -6 to 6 inclusive. Monthly schedule examples are recurEvery: Month, recurEvery: 2Months, recurEvery: Month day23,day24, recurEvery: Month Last Sunday, recurEvery: Month Fourth Monday, recurEvery: Month Last Sunday Offset-3, recurEvery: Month Third Sunday Offset6. |
| `maintenanceWindowStartTime` | `string` | true | Effective start date of the maintenance window in YYYY-MM-DD hh:mm format. The start date can be set to either the current date or future date. The window will be created in the time zone provided and adjusted to daylight savings according to that time zone. |
| `maintenanceWindowTimeZone` | `string` | true | Name of the timezone. List of timezones can be obtained by executing [System.TimeZoneInfo]::GetSystemTimeZones() in PowerShell. Example: Pacific Standard Time, UTC, W. Europe Standard Time, Korea Standard Time, Cen. Australia Standard Time. |

## Module outputs
NA

## Additional information
More information about how to define the maintenance configurations is found here: 
https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": {
      "value": "west us"
    },
    "maintenanceConfigurationName": {
      "value": "ExampleMaintenanceConfigurationName"
    },
    "linuxUpdateClassificationsToInclude": {
      "value": []
    },
    "windowsUpdateClassificationsToInclude": {
      "value": []
    },
    "linuxUpdatePackageNameMasksToExclude": {
      "value": []
    },
    "linuxUpdatePackageNameMasksToInclude": {
      "value": []
    },
    "windowsExcludeKbsRequiringReboot": {
      "value": true
    },
    "windowsKbNumbersToExclude": {
      "value": []
    },
    "windowsKbNumbersToInclude": {
      "value": []
    },
    "maintenanceScope": {
      "value": "InGuestPatch"
    },
    "updateRebootSetting": {
      "value": "ifRequired"
    },
    "maintenanceWindowDuration": {
      "value": "03:55"
    },
    "maintenanceWindowExpirationDateTime": {
      "value": "9999-12-31 23:59:59"
    },
    "maintenanceWindowRecurEvery": {
      "value": "1Day"
    },
    "maintenanceWindowStartTime": {
      "value": "2024-02-28 15:00"
    },
    "maintenanceWindowTimeZone": {
      "value": "W. Europe Standard Time"
    },
    "maintenanceConfigurationTag": {
      "value": {"EvidenPurpose":"EvidenMaintenanceConfig"}
    }
  }
}
```