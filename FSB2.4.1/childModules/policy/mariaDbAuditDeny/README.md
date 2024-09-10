# policy/mariaDbAuditDeny/policy.bicep
Bicep module to create Azure policy resources.

## Module Features
This module deploys 1 Azure policy set definition & 1 policy assignment.

This policy configures governance and security policies for the Azure Database for MariaDB.

## Resource types

| Resource Type | API Version |
| --- | --- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions) |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments) |


## Module Example Use
```bicep
module examplePolicy '../childModules/policy/mariaDbAuditDeny/policy.bicep' = {
  name: 'deployExamplePolicy'
  params: {
    mariaDbSettings:
    {
      geoRedundantBackupEnabledEffect: 'Audit'
      useVirtualNetwokServiceEndPointEffect : 'AuditIfNotExists'
      privateEndPointEnabledEffect: 'AuditIfNotExists'
      mariadbPublicNetworkAccessDisableEffect" : 'Audit'
    }
    mariaDbAuditDenySetName : 'mariadb.auditdeny.policy.set'
    mariaDbAuditDenySetDisplayName": 'mariaDb auditdeny policy set'
    mariaDbAuditDenySetAssignmentName : 'mariadb.auditdeny.policy.set.assignment'
    mariaDbAuditDenySetAssignmentDisplayName : 'mariaDb auditdeny policy set assignment'
    policyMetadata : 'EvidenELZ'
    }
}
```

## Module Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `mariaDbSettings` | `object` | true | Object which sets the values of the policy set definition parameters. The specific parameters & what they are for, are described in the `policySetDefinition` resource block. Additional Details [here](#object---mariadbsettings).|
| `mariaDbAuditDenySetName` | `string` | true | set name for mariaDb audit deny initiative. |
| `mariaDbAuditDenySetDisplayName` | `string` | true | set displayname for mariaDb audit deny initiative. |
| `mariaDbAuditDenySetAssignmentName` | `string` | true | set assignment name for mariaDb audit deny initiative. |
| `mariaDbAuditDenySetAssignmentDisplayName` | `string` | true | set assignment displayname for mariaDb audit deny initiative. |
| `policyMetadata` | `string` | true | Specify metadata source value required for billing and monitoring. |

### Object - mariaDbSettings
| Name | Type | Description |
| --- | --- | --- |
| `geoRedundantBackupEnabledEffect` | `string` | Geo-redundant backup should be enabled for Azure Database for MariaDB. |
| `useVirtualNetwokServiceEndPointEffect` | `string` | MariaDB server should use a virtual network service endpoint. |
| `privateEndPointEnabledEffect` | `string` | Private endpoint should be enabled for MariaDB servers. |
| `mariadbPublicNetworkAccessDisableEffect` | `string` | Public network access should be disabled for MariaDB servers. |

## Module Outputs
None.

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "mariaDbSettings": {
      "value": {
        "geoRedundantBackupEnabledEffect": "Audit",
        "useVirtualNetwokServiceEndPointEffect": "AuditIfNotExists",
        "privateEndPointEnabledEffect": "AuditIfNotExists",
        "mariadbPublicNetworkAccessDisableEffect": "Audit"
      }
    },
    "mariaDbAuditDenySetName": {
      "value": "mariadb.auditdeny.policy.set"
    },
    "mariaDbAuditDenySetDisplayName": {
      "value": "mariaDb auditdeny policy set"
    },
    "mariaDbAuditDenySetAssignmentName": {
      "value": "mariadb.auditdeny.policy.set.assignment"
    },
    "mariaDbAuditDenySetAssignmentDisplayName": {
      "value": "mariaDb auditdeny policy set assignment"
    },
    "policyMetadata": {
     "value": "EvidenELZ"
    }
  }
}
```