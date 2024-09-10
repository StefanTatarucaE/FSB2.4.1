# logicApp/logicApp.bicep
Bicep module to create Logic App

## Description
This module deploys logic app along with design workflow. The module is capable of deploying system identity or user managed identity attached to logic app. 

The design workflow required for logic app can be defined in JSON file or bicep object. 


## Module Example Use
```hcl

var definition = loadJsonContent('../definitionWorkflow/testdefinition1.json')
var keyVaultURL = 'https://${customerKeyVaultName}${environment().suffixes.keyvaultDns}'
var definitionParameters = {
  'tempvar' : {
      'value': keyVaultURL
    }
    'connections' : {
      'value': connections
    }
}

// Deploys logic app without managed identity
module logicApp '../logicApp.bicep' ={
  name: logicAppName
  scope: itsmResourceGroup
  params: {
    definition: definition
    location: location
    logicAppName: logicAppName
    logicAppState: 'Enabled'
    definitionParameters: definitionParameters
    systemAssignedIdentity : false
    userAssignedIdentities : {}
    tags: tags
  }
}

// Deploys logic app with System Assigned Managed Identity
module logicApp '../logicApp.bicep' ={
  name: logicAppName
  scope: itsmResourceGroup
  params: {
    definition: definition
    location: location
    logicAppName: logicAppName
    definitionParameters: definitionParameters
    logicAppState: 'Enabled'
    systemAssignedIdentity : true
    userAssignedIdentities : {}
    tags: tags
  }
}


// Deploys logic app with user managed identity
module logicApp '../logicApp.bicep' ={
  name: logicAppName
  scope: itsmResourceGroup
  params: {
    definition: definition
    location: location
    logicAppName: logicAppName
    definitionParameters: definitionParameters
    logicAppState: 'Enabled'
    userAssignedIdentities: {
      '/subscriptions/3bed9a6a-d129-47e1-bbe5-6df00467a2e1/resourceGroups/MC_dev3-lndz-d-rsg-integration-testing_Dev3Testaks01_westus/providers/Microsoft.ManagedIdentity/userAssignedIdentities/omsagent-dev3testaks01': {}
    }
    systemAssignedIdentity: false
    tags: tags
  }
}
```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `logicAppName` | `string` | true | Specify globally unique Logic App Name |
| `location` | `string` | true| Specify the location where logic app is to be created |
| `tags`| `object` | true | Speciy mapping of tags attached to logic app. Additional Details [here](#object---tags). |
| `definition` | `object` | true | Provide the definition for workflow. Additional Details [here](#object---definition). |
| `definitionParameters` | `object` | true | Specify parameter object required for definition workflow. Additional Details [here](#object---definitionparameters). |
| `systemAssignedIdentity` | `bool` | true | Optional. Enables system assigned managed identity on the resource. |
| `userAssignedIdentities` | `bool` | true | Optional. The ID(s) to assign to the resource. |
| `logicAppState` | `string` | true | Specify the workflow state. Accepted values: Completed, Deleted, Disabled, Enabled, NotSpecified|

### Object - tags
Below is an example of the tags object

`"key"`:`"value"`

**Example:**
```json
{
    "EvidenManaged": "true",
    "Project": "Monitoring Parent Module",
    "ManagedBy": "AzureBicep"
}
```

### Object - definition
| Name | Type  | Description |
| --- | --- | --- | 
| `$schema` | `string`  | The location for the JSON schema file that describes the Workflow Definition Language version, which you can find here: https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json |
| `actions` | `object` | false| The definitions for one or more actions to execute at workflow runtime. For more information, see [Triggers and actions](https://docs.microsoft.com/azure/logic-apps/logic-apps-workflow-definition-language#triggers-actions). Maximum actions: 250 |
| `contentVersion`| `string`  | Speciy mapping of tags attached to logic app |
| `outputs` | `object`  | The definitions for the outputs to return from a workflow run. For more information, see [Outputs](https://docs.microsoft.com/azure/logic-apps/logic-apps-workflow-definition-language#outputs). Maximum outputs: 10 |
| `parameters` | `object`  | The definitions for one or more parameters that pass the values to use at your logic app's runtime. For more information,see [Parameters](https://docs.microsoft.com/azure/logic-apps/logic-apps-workflow-definition-language#parameters). Maximum parameters: 50 |
| `staticResults` | `object` | false | The definitions for one or more static results returned by actions as mock outputs when static results are enabled on those actions. In each action definition, the runtimeConfiguration.staticResult.name attribute references the corresponding definition inside staticResults. For more information, see [Static results](https://docs.microsoft.com/azure/logic-apps/logic-apps-workflow-definition-language#static-results). |
| `triggers` | `object` | false | The definitions for one or more triggers that instantiate your workflow. You can define more than one trigger, but only with the Workflow Definition Language, not visually through the Logic Apps Designer. For more information, see [Triggers and actions](https://docs.microsoft.com/azure/logic-apps/logic-apps-workflow-definition-language#triggers-actions). Maximum triggers: 10 |

### Object - definitionParameters
This will contain the parameters for the logic app.

`"key"`:`{"value":"The value of the parameter"}`

**Example:**
```json
"tempvar" : {
                "value": "https://cu1-sub1-d-kvt-001.vault.azure.net"
            }
```

## Module outputs
| Name | Description | Value
| --- | --- | --- |
| `logicAppID` | The resource ID of the created logic app. | `logicApp.id` |
| `logicAppPrincipalId` | Returns principal id of managed identity if deployed. | `identityType == 'SystemAssigned' ? logicApp.identity.principalId : 'None'` |
| `logicAppCallbackUrl` | Callback URL for the created logic app. Optionally needed in Monitoring Action Groups | `logicApp.listCallbackUrl().value` |

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "logicAppName": {
            "value": "test000085454"
        },
        "location": {
            "value": "West Europe"
        },
        "logicAppState": {
            "value": "Enabled"
        },
        "tags": {
            "value": {
              }
        },
        "systemAssignedIdentity": {
            "value": false
        },
        "userAssignedIdentities": {
            "value": {}
        },
        "definition": {
            "value": {
                "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
                "actions": {
                    "Initialize_variable": {
                        "inputs": {
                            "variables": [
                                {
                                    "name": "testvar",
                                    "type": "string",
                                    "value": "temp"
                                }
                            ]
                        },
                        "runAfter": {},
                        "type": "InitializeVariable"
                    },
                    "Initialize_variable_2": {
                        "inputs": {
                            "variables": [
                                {
                                    "name": "connection",
                                    "type": "string",
                                    "value": "temp"
                                }
                            ]
                        },
                        "runAfter": {},
                        "type": "InitializeVariable"
                    },
                    "Set_variable": {
                        "inputs": {
                            "name": "testvar",
                            "value": "@{parameters('tempvar')}"
                            
                        },
                        "runAfter": {
                            "Initialize_variable": [
                                "Succeeded"
                            ]
                        },
                        "type": "SetVariable"
                    },
                    "Set_variable_2": {
                        "inputs": {
                            "name": "testvar",
                            "value": "@parameters('connections')['servicebus']['id']"
                            
                        },
                        "runAfter": {
                            "Initialize_variable_2": [
                                "Succeeded"
                            ]
                        },
                        "type": "SetVariable"
                    }
                    
                },
                "contentVersion": "1.0.0.0",
                "outputs": {},
                "parameters": {
                    "tempvar": {
                        "type": "String"
                    },
                    "connections": {
                        "defaultValue": {},
                        "type": "Object"
                    }
                },
                "triggers": {
                    "manual": {
                        "inputs": {
                            "schema": {}
                        },
                        "kind": "Http",
                        "type": "Request"
                    }
                }
            }
        },
        "definitionParameters": {
            "value": {
                "tempvar" : {
                    "value": "https://cu1-sub1-d-kvt-001.vault.azure.net"
                  },
                  "connections" : {
                    "value": {
                        "servicebus": {
                          "connectionId": "testconnectionId",
                          "connectionName": "sbConnectionName",
                          "id": "/subscriptions/${subscription().id}/providers/Microsoft.Web/locations/${itsmResourceGroup.location}/managedApis/servicebus"
                        }
                      }
                  }
              }
        }
    }
  }
```