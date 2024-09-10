/*
SUMMARY: RecoveryServicesVault child module.
DESCRIPTION: Deployment of RecoveryServicesVault resource for the Eviden Landingzones for Azure solution.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

//PARAMETERS

@description('Name of the Recovery Services Vault')
param recoveryServicesVaultName string

@description('Name of the resourceGroup')
param location string = resourceGroup().location

@description('Storage tier. Allowed values: GeoRedundant, LocallyRedundant')
@metadata({
  displayName: 'Storage Redundancy'
})
@allowed([
  'GeoRedundant'
  'LocallyRedundant'
])
param backupStorageType string

@description('Locked or Unlocked. Once a machine is registered against a resource, the storageTypeState is always Locked.')
@metadata({
  displayName: 'Storage Type State'
})
@allowed([
  'Invalid'
  'Locked'
  'Unlocked'
])
param storageTypeState string

@description('A JSON structure used to specify the backup policy configuration. For predefined ELZ backup policies (Bronze, Silver, Gold) use EvidenELZ as input parameter in an array. For custom backup policies, input the JSON structure. For more information about JSON structure, visit https://docs.cloud.eviden.com/02.%20Eviden%20Landing%20Zones/02.%20AZURE/02.-Release-2.3/02.-Solutions/09.-VM-OS-Management/01.-Low-Level-Design/01.-Design-Decisions/001-Recovery-Services-Vault/')
@metadata({
  displayName: 'Backup Policy configuration'
})
param backupPolicyConfigurations object

@description('A mapping of tags to assign to the resource.')
param tags object

@description('Returns the current (UTC) datetime value in the RFC1123 pattern format. 2009-06-15T13:45:30 -> Mon, 15 Jun 2009 20:45:30 GMT')
param utcShort string = utcNow('r')

//VARIABLES
var shortDate = substring(dateTimeAdd(utcShort, 'P1D'), 0, 11)

//RESOURCES
// Create Recovery Service Vault
resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2020-10-01' = {
  tags: tags
  name: recoveryServicesVaultName
  location: location
  sku: {        // sku 'name' and 'tier' can only have below values. hence no need to configure as parameter
    name: 'RS0'         
    tier: 'Standard'
  }
  properties: {}
}

// Create Vault Config
resource vaultStorageConfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2016-12-01' = {
  parent: recoveryServicesVault
  name: 'vaultstorageconfig'       // value has to be hardcoded as per MS Documentation https://docs.microsoft.com/en-us/azure/templates/microsoft.recoveryservices/vaults/backupstorageconfig?tabs=bicep
  location: location
  properties: {
    storageModelType: backupStorageType
    storageType: backupStorageType
    storageTypeState: storageTypeState
  }
}

// Create Backup Policy
resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2021-06-01' = [for policies in backupPolicyConfigurations.list: {
  parent: recoveryServicesVault
  name: '${policies.backupTagNamePrefix}-Enhanced'
  location: location
  properties: {
    policyType: policies.properties.policyType
    backupManagementType: policies.properties.backupManagementType
    instantRpRetentionRangeInDays: policies.properties.instantRpRetentionRangeInDays
    schedulePolicy:{
      scheduleRunFrequency: policies.properties.schedulePolicy.scheduleRunFrequency
      scheduleRunDays: policies.properties.schedulePolicy.scheduleRunDays
      schedulePolicyType: policies.properties.schedulePolicy.schedulePolicyType
      dailySchedule:{
        scheduleRunTimes: ['${shortDate}${policies.scheduleStartTime}:00.00Z']
      }
    }
    retentionPolicy:{
      dailySchedule:((contains(policies.properties.retentionPolicy,'dailySchedule')) ? union(policies.properties.retentionPolicy.dailySchedule,{retentionTimes: ['${shortDate}${policies.scheduleStartTime}:00.00Z']}): null)
      weeklySchedule:((contains(policies.properties.retentionPolicy,'weeklySchedule')) ? union(policies.properties.retentionPolicy.weeklySchedule,{retentionTimes: ['${shortDate}${policies.scheduleStartTime}:00.00Z']}): null)
      monthlySchedule:((contains(policies.properties.retentionPolicy,'monthlySchedule')) ? union(policies.properties.retentionPolicy.monthlySchedule,{retentionTimes: ['${shortDate}${policies.scheduleStartTime}:00.00Z']}): null)
      yearlySchedule:((contains(policies.properties.retentionPolicy,'yearlySchedule')) ? union(policies.properties.retentionPolicy.yearlySchedule,{retentionTimes: ['${shortDate}${policies.scheduleStartTime}:00.00Z']}): null)
      retentionPolicyType: policies.properties.retentionPolicy.retentionPolicyType
    }
    timeZone:policies.properties.timeZone
  }
}]

// output Vault Name and ID
output vaultName string = recoveryServicesVaultName
output vaultID string = recoveryServicesVault.id
output vaultLocation string = recoveryServicesVault.location
