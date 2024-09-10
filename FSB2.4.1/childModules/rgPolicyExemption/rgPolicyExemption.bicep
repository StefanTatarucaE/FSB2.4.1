/*
SUMMARY: Exemtpions child module. Exemption resources are extension resource so use them in a parent child fashion
DESCRIPTION: Deployment of Exemptions for the ELZ solution.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.1
*/

//PARAMETERS

@description('Holds the policy assignment shortcode of the policy or initiative.')
@allowed([
  'asb'
  'cis'
  'iso'
  'custom'
])
param policyAssignmentShortcode string

@description('Holds the policyAssignmentId of the initiative for which exemptions need to be created.')
param policyAssignmentId string

@description('Holds the referenceId of the to be exempted policy within an initiative.')
param policyDefinitionReferenceIds array

@description('resourceName is used to generate the name for the exemption.')
param resourceName string

@description('Holds the time to add to current time to calculate the expiry date  ')
param addTime string

@description('The basetime is used to calculated the expiry date in a variable.')
param baseTime string = utcNow('u')

@description('The category of the exemption. Possible options are Waiver or Mitigated.')
@allowed([
  'Waiver'
  'Mitigated'
])
param exemptionCategory string

//VARIABLES

@description('Calculate the expiry date')
var expiryDate = dateTimeAdd(baseTime, addTime)

//RESOURCES

resource policyExemption 'Microsoft.Authorization/policyExemptions@2020-07-01-preview' = [for i in range(0, length(policyDefinitionReferenceIds)): {

  name: substring('${policyAssignmentShortcode}.${policyDefinitionReferenceIds[i]}', 0, min(length('${policyAssignmentShortcode}.${policyDefinitionReferenceIds[i]}'), 64))
  properties: {
    description: 'This is an exemption for the ${policyAssignmentShortcode} initiative and is implemented for the following resource(s): ${resourceName} in resourcegroup ${resourceGroup().name}.\n\nThe exempted policy has the following referenceid: ${policyDefinitionReferenceIds[i]}\n\nDue to technical limitations exemptions are currently set on the resourcegroup instead of the resource'
    displayName: '${substring('${policyAssignmentShortcode} ${policyDefinitionReferenceIds[i]}',  0, min(length('${policyAssignmentShortcode}${policyDefinitionReferenceIds[i]}'), 47))} ${resourceName} policy exemption'
    exemptionCategory: exemptionCategory
    expiresOn: expiryDate
    policyAssignmentId: policyAssignmentId
    policyDefinitionReferenceIds: [
      policyDefinitionReferenceIds[i]
    ]
  }
}]
