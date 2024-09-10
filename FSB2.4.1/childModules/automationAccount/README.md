# automationAccount/automationAccount.bicep
Bicep module to create a Automation Account with managed identity.

## Description
With an Automation account, you can authenticate runbooks by managing resources in either Azure Resource Manager or the classic deployment model. One Automation Account can manage resources across all regions and subscriptions for a given tenant.

## Module example use
```hcl

// Deploys Automation Account with System Assigned managed identity
module devAutomationAccount '../../modules/automationAccount/automationAccount.bicep' = {
  scope: resourceGroup('cux-subx-d-rsg-development')
  name: 'exampleAutomationAccount-deployment'
  skuName: 'Free'
  location: 'westeurope'
  params: {
    automationAccountName: 'cuxdaa<randomstring>'
    tags: {
        Owner: 'HR'
        Application: 'App X'
        Environment: 'Development' 
        Costcenter: 'TA-556'
    }
    location : 'West Europe'
    skuName : 'Free'
    systemAssignedIdentity: true
    userAssignedIdentities : {}
  }
}

// Deploys Automation Account with User Assigned managed identity
module devAutomationAccount '../../modules/automationAccount/automationAccount.bicep' = {
  scope: resourceGroup('cux-subx-d-rsg-development')
  name: 'exampleAutomationAccount-deployment'
  skuName: 'Free'
  location: 'westeurope'
  params: {
    automationAccountName: 'cuxdaa<randomstring>'
    tags: {
        Owner: 'HR'
        Application: 'App X'
        Environment: 'Development' 
        Costcenter: 'TA-556'
    }
    location : 'West Europe'
    skuName : 'Free'
    systemAssignedIdentity: false
    userAssignedIdentities : {
      '/subscriptions/3bed9a6a-d129-47e1-bbe5-6df00467a2e1/resourceGroups/MC_dev3-lndz-d-rsg-integration-testing_Dev3Testaks01_westus/providers/Microsoft.ManagedIdentity/userAssignedIdentities/omsagent-dev3testaks01': {}
    }
  }
}

// Deploys Automation Account without managed identity
module devAutomationAccount '../../modules/automationAccount/automationAccount.bicep' = {
  scope: resourceGroup('cux-subx-d-rsg-development')
  name: 'exampleAutomationAccount-deployment'
  skuName: 'Free'
  location: 'westeurope'
  params: {
    automationAccountName: 'cuxdaa<randomstring>'
    tags: {
        Owner: 'HR'
        Application: 'App X'
        Environment: 'Development' 
        Costcenter: 'TA-556'
    }
    location : 'West Europe'
    skuName : 'Free'
    systemAssignedIdentity: false
    userAssignedIdentities : {}
  }
}
```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `automationAccountName` | `string` | true | Specifies the name of the Automation Account |
| `location` | `string` | true| Specify the location where automation account is to be created |
| `tags` | `object` | true | Speciy mapping of tags attached to automation account. Additional Details [here](#object---tags). |
| `skuName` | `string` | true | The SKU of the automation account account. Valid options are Free, Basic |
| `systemAssignedIdentity` | `bool` | true | Optional. Enables system assigned managed identity on the resource. |
| `userAssignedIdentities` | `bool` | true | Optional. The ID(s) to assign to the resource. |
| `mgmtNaming` | `object` | true| naming for mgmt subscription as loaded in parentmodule. Used for branding variables. |

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
## Module outputs

| Name | Description | Value |
| --- | --- | --- |
| `automationAccountId` | Resource ID of created automation account. | `automationAccount.id` |
| `automationAccountName` | Name of created automation account. | `automationAccount.name` |
| `automationAccountLocation` | Location of created automation account | `automationAccount.location` |
| `AutomationAccManagedIdentityPrincipalId` | Returns principal id of system assigned identity if created | `identityType == 'SystemAssigned' ? automationAccount.identity.principalId : 'None'`

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "automationAccountName": {
            "value": "test321"
        },
        "location": {
            "value": "westeurope"
        },
        "tags": {
            "value": {}
        },
        "skuName": {
            "value": "Free"
        },
        "systemAssignedIdentity": {
            "value": true
        },
        "userAssignedIdentities": {
            "value": {}
        }
    }
}
```