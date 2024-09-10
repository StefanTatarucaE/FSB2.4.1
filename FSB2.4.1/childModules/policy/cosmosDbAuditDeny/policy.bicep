/*
SUMMARY: CosmosDB Audit/Deny Policy child module.
DESCRIPTION: Deployment of CosmosDB Audit/Deny Policy. Consists of definition set assignment & role assignment.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.1
*/

//SCOPE
targetScope = 'subscription' //Deploying at Subscription scope. Scope for Azure Policy can be Management Group(MG) or Subscription. ELZ Azure does not target MGs.

//PARAMETERS
@description('Specify metadata source value required for billing and monitoring')
param policyMetadata string

@description('Object which sets the values of the policy set definition parameters.')
param cosmosDbSettings object

@description('Specify set name for cosmosdb audit deny initiative')
param cosmosDbAuditDenySetName string

@description('Specify set displayname for cosmosdb audit deny initiative')
param cosmosdbAuditDenySetDisplayName string

@description('Specify set assignment name for cosmosdb audit deny initiative')
param cosmosdbAuditDenySetAssignmentName string

@description('Specify set assignment displayname for cosmosdb audit deny initiative')
param cosmosdbAuditDenySetAssignmentDisplayName string

// VARIABLES
// Variables for allowedValues.
var effectAuditDisabled = [
  'Audit'
  'Disabled'
]

var effectDeny = [
  'Deny'
]

var effectAuditDenyDisabled = concat(effectAuditDisabled,effectDeny)

//Variable which holds the definition set details
var policySetDefinitionProperties = {
  description: 'This policy set configures governance and security policies to CosmosDB'
  metadata: {
    category: 'Monitoring'
    source: policyMetadata
    version: '0.0.1'
  }
}

//Variable which holds the assignment details
var assignmentProperties = {
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region like other resources but the metadata is stored in a region hence requiring this to keep input parameters reduced.
  location: deployment().location
  identityType: 'SystemAssigned' //The identity type. This is the only required field when adding a system to a resource. Possible values 'None' & 'SystemAssigned'
  description: 'Ensures that CosmosDB has relevant governance and security policies'
  metadata: {
    source: policyMetadata
    version: '0.0.1'
  }
}

//RESOURCE DEPLOYMENTS
//Deploy the policy definition set for the definitions created in previous resource block
resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: cosmosDbAuditDenySetName
  properties: {
    displayName: cosmosdbAuditDenySetDisplayName
    description: policySetDefinitionProperties.description
    metadata: policySetDefinitionProperties.metadata
    parameters: {
      firewallRuleEnabledEffect: {
        type: 'String'
        metadata: {
          description: 'Firewall rules should be defined on your Azure Cosmos DB accounts to prevent traffic from unauthorized sources. Accounts that have at least one IP rule defined with the virtual network filter enabled are deemed compliant. Accounts disabling public access are also deemed compliant. Allowed Values: Audit, Deny, Disabled'
          displayName: 'firewallRuleEnabledEffect'
        }
        allowedValues: effectAuditDenyDisabled
      }
      useCustomerManagedKeyEffect: {
        type: 'String'
        metadata: {
          description: 'Customer-managed keys to encrypt data at rest effect. Allowed Values: Audit, Deny, Disabled'
          displayName: 'useCustomerManagedKeyEffect'
        }
        allowedValues: effectAuditDenyDisabled
      }
      allowedLocationEffect: {
        type: 'String'
        metadata: {
          description: 'Allowed locations effect. Allowed Values: Audit, Deny, Disabled'
          displayName: 'allowedLocationEffect'
        }
        allowedValues: effectAuditDenyDisabled
      }
      disablePublicNetworkAccessEffect: {
        type: 'String'
        metadata: {
          description: 'Disable public network access effect. Allowed Values: Audit, Deny, Disabled'
          displayName: 'disablePublicNetworkAccessEffect'
        }
        allowedValues: effectAuditDenyDisabled
      }
      throughputMaxEffect: {
        type: 'String'
        metadata: {
          description: 'Maximum throughput effect. Allowed Values: Audit, Deny, Disabled'
          displayName: 'throughputMaxEffect'
        }
        allowedValues: effectAuditDenyDisabled
      }
      localAuthenticationDisableEffect: {
        type: 'String'
        metadata: {
          description: 'Local authentication methods disable. Allowed Values: Audit, Deny, Disabled'
          displayName: 'localAuthenticationDisableEffect'
        }
        allowedValues: effectAuditDenyDisabled
      }
      virtualNetworkServiceEndpointEffect: {
        type: 'String'
        metadata: {
          description: 'Check if CosmosDB is using a virtual network service endpoint. Allowed Values: Audit, Disabled'
          displayName: 'virtualNetworkServiceEndpointEffect'
        }
        allowedValues: effectAuditDisabled
      }
      usePrivateLinkEffect: {
        type: 'String'
        metadata: {
          description: 'Check if CosmosDB is using a private link. Allowed Values: Audit, Disabled'
          displayName: 'usePrivateLinkEffect'
        }
        allowedValues: effectAuditDisabled
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/862e97cf-49fc-4a5c-9de4-40d4e2e7c8eb'
        parameters: {
          effect: {
            value: '[parameters(\'firewallRuleEnabledEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1f905d99-2ab7-462c-a6b0-f709acca6c8f'
        parameters: {
          effect: {
            value: '[parameters(\'useCustomerManagedKeyEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0473574d-2d43-4217-aefe-941fcdf7e684'
        parameters: {
          policyEffect: {
            value: '[parameters(\'allowedLocationEffect\')]'
          }
          listOfAllowedLocations: {
            value: cosmosDbSettings.listOfAllowedLocations
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/797b37f7-06b8-444c-b1ad-fc62867f335a'
        parameters: {
          effect: {
            value: '[parameters(\'disablePublicNetworkAccessEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0b7ef78e-a035-4f23-b9bd-aff122a1b1cf'
        parameters: {
          effect: {
            value: '[parameters(\'throughputMaxEffect\')]'
          }
          throughputMax: {
            value: cosmosDbSettings.throughputMax
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/5450f5bd-9c72-4390-a9c4-a7aba4edfdd2'
        parameters: {
          effect: {
            value: '[parameters(\'localAuthenticationDisableEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e0a2b1a3-f7f9-4569-807f-2a9edebdf4d9'
        parameters: {
          effect: {
            value: '[parameters(\'virtualNetworkServiceEndpointEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/58440f8a-10c5-4151-bdce-dfbaad4a20b7'
        parameters: {
          effect: {
            value: '[parameters(\'usePrivateLinkEffect\')]'
          }
        }
      }
    ]
  }
}

//Deploy the policy assignemnt 
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: cosmosdbAuditDenySetAssignmentName
  location: assignmentProperties.location
  identity: {
    type: assignmentProperties.identityType
  }
  properties:{
    description: assignmentProperties.description
    displayName: cosmosdbAuditDenySetAssignmentDisplayName
    metadata: assignmentProperties.metadata
    parameters: {
      firewallRuleEnabledEffect: {
        value: cosmosDbSettings.firewallRuleEnabledEffect
      }       
      useCustomerManagedKeyEffect: {
        value: cosmosDbSettings.useCustomerManagedKeyEffect
      }   
      allowedLocationEffect: {
        value: cosmosDbSettings.allowedLocationEffect
      }      
      disablePublicNetworkAccessEffect: {
        value: cosmosDbSettings.disablePublicNetworkAccessEffect
      }
      throughputMaxEffect: {
        value: cosmosDbSettings.throughputMaxEffect
      }    
      localAuthenticationDisableEffect: {
        value: cosmosDbSettings.localAuthenticationDisableEffect
      }    
      virtualNetworkServiceEndpointEffect: {
        value: cosmosDbSettings.virtualNetworkServiceEndpointEffect
      }    
      usePrivateLinkEffect: {
        value: cosmosDbSettings.usePrivateLinkEffect
      }
    }
    policyDefinitionId: policySetDefinition.id
  }
}

//OUTPUTS
