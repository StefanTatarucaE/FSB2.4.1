/*
SUMMARY: azurelighthouse module.
DESCRIPTION: Onboarding of a customer tenant using azure lighthouse.
AUTHOR/S: alkesh.naik@eviden.com
VERSION: 0.0.1
*/

targetScope = 'subscription'

// PARAMETERS
@description('Specify the offer name')
@metadata({
  displayName: 'MSP Offer Name'
})
param mspOffer string

@description('Description for the Offer')
@metadata({
  displayName: 'Description for the Offer'
})
param mspOfferDescription string

@description('Specify the tenant id of Service provider company')
@metadata({
  displayName: 'Azure Active Directory tenant ID of Service provider company'
})
param managedByTenantId string

@description('Specify an array of objects, containing tuples of Azure Active Directory principalId, a Azure roleDefinitionId, and an optional principalIdDisplayName. The roleDefinition specified is granted to the principalId in the provider\'s Active Directory and the principalIdDisplayName is visible to customers.')
@metadata({
  displayName: 'JSON Array with definition of the delegated permanent roles to Service provider company'
})
param authorizations array

@description('Specify an array of objects, containing the eligible roles, the approver and the maximum duration of the just in time access for these roles.')
@metadata({
  displayName: 'JSON Array with definition of the delegated eligible roles to Service provider company'
})
param eligibleAuthorizations array


// VARIABLES
var mspRegistrationOffer = guid(mspOffer)
var mspAssignmentOffer = guid(mspOffer)

// RESOURCE DEPLOYMENTS
resource mspRegistration 'Microsoft.ManagedServices/registrationDefinitions@2020-02-01-preview' = {
  name: mspRegistrationOffer
  properties: {
    registrationDefinitionName: mspOffer
    description: mspOfferDescription
    managedByTenantId: managedByTenantId
    authorizations: authorizations
	  eligibleAuthorizations: eligibleAuthorizations
  }
}

resource mspAssignment 'Microsoft.ManagedServices/registrationAssignments@2020-02-01-preview' = {
  name: mspAssignmentOffer
  properties: {
    registrationDefinitionId: mspRegistration.id
  }
}

// OUTPUTS
output mspOffer string = 'Managed by ${mspOffer}'
output authorizations array = authorizations
output eligibleAuthorizations array = eligibleAuthorizations
