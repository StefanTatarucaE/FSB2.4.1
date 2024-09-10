<#
.SYNOPSIS
    Publishes the wsus artifacts for Windows VMs configuration  

.DESCRIPTION
    This function will create the artifacts required for Guest Configuration Policy based on the patching groups required.
    The function will create one artifact (zip file) with the registry key configuration for Windows VMs for each patching group.

    Registry configured:
     - wsus server
     - wsus status server
     - target group
     - use wsus set to 1
     - proxy configuration set to 0
     - auto update set to 4 (only check for updates without downloading or installing them)
     - no auto update set to 1


.PARAMETER $wsusServer
    Specifies the Wsus server that will be set in registry for Windows VMs

.PARAMETER $targetGroups
    Specifies the list for wsus target groups reguired for VMs configuration

.PARAMETER $wsusOutputPath
    Specifies the location of the artifacts in order to be uploaded to storage account

.NOTES
    Version:        0.1
    Author:         bart.decker@eveiden.com
    Creation Date:  20230609

.EXAMPLE
    Publish-WsusArtifacts -wsusServer "10.10.0.7" -targetGroups "Prod, QA, Test" -wsusOutputPath ".\output"

#>
function Publish-WsusArtifacts {

     [CmdletBinding()]
     param
     (
          [Parameter(Position = 0, Mandatory)]
          [ValidateNotNullOrEmpty()]
          [string]$wsusServer,

          [Parameter(Position = 1, Mandatory)]
          [ValidateNotNullOrEmpty()]
          [string[]]$targetGroups,

          [Parameter(Position = 5)]
          [ValidateNotNullOrEmpty()]
          [string] $wsusOutputPath
     )

     process {
          $targetGroups = $targetGroups.split(",").Trim()
          try {

               foreach ($targetGroup in $targetGroups) {

                    Configuration WindowsWsusRegistry
                    {
 
                         Import-DSCResource -ModuleName 'PSDscResources'
 
                         Node localhost
                         {
                              Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' {
                                   ValueName = 'WUServer'
                                   ValueType = 'String'
                                   Key       = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
                                   ValueData = 'http://' + $wsusServer + ':8530'
                                   Force     = $true
  
                              }
                              Registry 'Registry(POL2): HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' {
                                   ValueName = 'WUStatusServer'
                                   ValueType = 'String'
                                   Key       = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
                                   ValueData = 'http://' + $wsusServer + ':8530'
                                   Force     = $true
  
                              }
                              Registry 'Registry(POL3): HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' {
                                   ValueName = 'UpdateServiceUrlAlternate'
                                   ValueType = 'String'
                                   Key       = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
                                   ValueData = 'http://' + $wsusServer + ':8530'
                                   Force     = $true
  
                              }
                              Registry 'Registry(POL4): HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' {
                                   ValueName = 'TargetGroup'
                                   ValueType = 'String'
                                   Key       = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
                                   ValueData = $targetGroup
                                   Force     = $true
  
                              }
                              Registry 'Registry(POL5): HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' {
                                   ValueName = 'TargetGroupEnabled'
                                   ValueType = 'dword'
                                   Key       = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
                                   ValueData = 1
                                   Force     = $true
  
                              }
                              Registry 'Registry(POL6): HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' {
                                   ValueName = 'SetProxyBehaviorForUpdateDetection'
                                   ValueType = 'dword'
                                   Key       = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
                                   ValueData = 0
                                   Force     = $true
  
                              }
                              Registry 'Registry(POL7): HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' {
                                   ValueName = 'UseWUServer'
                                   ValueType = 'dword'
                                   Key       = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
                                   ValueData = 1
                                   Force     = $true
  
                              }
                              Registry 'Registry(POL8): HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' {
                                   ValueName = 'NoAutoUpdate'
                                   ValueType = 'dword'
                                   Key       = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
                                   ValueData = 1
                                   Force     = $true
  
                              }
                              Registry 'Registry(POL9): HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' {
                                   ValueName = 'DetectionFrequencyEnabled'
                                   ValueType = 'dword'
                                   Key       = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
                                   ValueData = 1
                                   Force     = $true
  
                              }
                              Registry 'Registry(POL10): HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' {
                                   ValueName = 'DetectionFrequency'
                                   ValueType = 'dword'
                                   Key       = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
                                   ValueData = 1
                                   Force     = $true
  
                              }
                              Registry 'Registry(POL11): HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' {
                                   ValueName = 'AUOptions'
                                   ValueType = 'dword'
                                   Key       = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
                                   ValueData = 4
                                   Force     = $true
  
                              }
                         }
                    }
                    WindowsWsusRegistry
                    Start-Sleep 5
                    New-GuestConfigurationPackage `
                         -Name $targetGroup `
                         -Configuration './WindowsWsusRegistry\localhost.mof' `
                         -Type AuditAndSet  `
                         -Path $wsusOutputPath `
                         -Force
               } # foreach end
          }
          catch {
               Write-Error "Failed to create artifact file. $($_.Exception.Message)" -ErrorAction 'Stop'
          }
     } # process end
} # funtion end
