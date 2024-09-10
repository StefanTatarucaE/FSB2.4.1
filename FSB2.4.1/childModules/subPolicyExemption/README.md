# subPolicyExemption/subPolicyExemption.bicep
Bicep module to create policy exemptions on the Subscription.

If a subscription needs for example 2 exemptions, one in ISO and two in ASB, the module must be called twice, once for ISO with one policyDefinitionReferenceIds and once for ASB with two policyDefinitionReferenceIds filled out.

More info about CIS, ISO, ASB Policy Initiatives:

ISO: https://docs.microsoft.com/en-us/azure/governance/policy/samples/iso-27001
CIS: https://docs.microsoft.com/en-us/azure/governance/policy/samples/cis-azure-1-3-0
ASB: https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/policy-security-baseline

## Module Features

Module deploys policy exemptions on the resourcegroup for CIS, ISO, ASB or other policies depending on the value of the policyAssignmentId when calling the module.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policyExemptions@2020-07-01-preview` | [2020-07-01-preview](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2020-07-01-preview/policyexemptions) |


## Module Example Use with CIS, ISO, ASB Governance initiatives.

```hcl
module exampleExemption '../childModules/subPolicyExemption/subPolicyExemption.bicep' = {
  scope: subscription()
  name: 'exemptionDeploy'
   params: {
    exemptionCategory: 'Waiver'
    addTime:'P180D'
    resourceName: storagemodule2.outputs.storageAccountname
    policyAssignmentId: "/subscriptions/xxxxx-e0d8-416d-8331-da20bed4e8c3/providers/Microsoft.Authorization/policyAssignments/cis140.change.policy.set.assignment"
    policyDefinitionReferenceIds: [
      'disableUnrestrictedNetworkToStorageAccountMonitoring'
    ]
  }
```
## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `exemptionCategory` | `string` | true | Specifies the category of the exemption (Waiver or Mitigated). |
| `policyAssignmentShortcode` | `string` | true | Specifies the policy initiative to create the exemption for (cis, iso, asb, custom). Value is used in description and displayname only. |
| `policyDefinitionReferenceIds` | `string[]` | true | Specifies the policy within the initiative to create a exemption for. The policy id, which should be a GUID, has to be used. |
| `policyAssignmentId` | `string` | true | Holds the assignment id of the policy or initiative for which an exemption is created. |
| `addTime` | `string` | true | Specifies the time in ISO 8601 format to add up to the current time to set the expiry date.|
| `baseTime` | `string` | false | The basetime is used to calculated the expiry date in a variable.|

## Module outputs
NA

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "policyAssignmentShortcode": {
            "value": "cis"
        },
        "policyDefinitionReferenceIds": {
            "value": [
                "34c877ad-507e-4c82-993e-3452a6e0ad3c",
                "7fe3b40f-802b-4cdd-8bd4-fd799c948cc2"
            ]
        },
        "exemptionCategory": {
            "value": "Waiver"
        },
        "addTime": {
            "value": "P180D"
        },
        "customInitiative": {
            "value": ""
        }
    }
}
```

