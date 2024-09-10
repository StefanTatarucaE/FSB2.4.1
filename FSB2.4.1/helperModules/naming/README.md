# naming/naming.bicep
Bicep template to provide naming to other modules, it enforces the ELZ Azure naming convention.

## Template features
This template generates and provides names to azure resources being deployed via Bicep.
It enforces the ELZ Azure naming convention.

## Template overview
Nothing to display. There are no resources deployed, just the outputs being generated.

## Template usage
The template is deployed multiple times via a pwsh script (../scripts/Publish-AzResourceNames.ps1) in the `prepare` job of every workflow which is used to deploy ELZ Azure.

One time for each subscription type (msp, mgmt, cnty & lnd(n)) and the output of the deployment is captured and saved as a json file.
Depending on how many subscriptions are there for any given Azure environment, the number of json files created will vary.
For example; mspNaming.json, mgmtNaming.json, cntyNaming.json, lnd1Naming.json ... lnd15Naming.json etc etc...

These json files are then uploaded as an artifact to the workflow, so that they can be used in subsequent jobs.

## Template example deployment

```powershell

$rgParams = @{
    Name                  = 'exampleDeploymentName'
    ResourceGroupName     = 'exampleResourceGroupName'
    TemplateFile          = 'naming.bicep'
    TemplateParameterFile = 'naming.params.json'
    Verbose               = $true
}

$deploy = New-AzResourceGroupDeployment @rgParams

```

### Using the naming module outputs / json files
```hcl

var naming = json(loadTextContent('../../naming.json'))

var someStorageAccountName = naming.storageAccount.name

module testStorageAccount '../../childModules/storageAccount/storageAccount.bicep' = {
  scope: testResourceGroup
  name: 'testSaModule'
  params: {
    storageAccountName: someStorageAccountName
    ...
    ...
    ...
  }
  dependsOn: [
    testResourceGroup
  ]
}
```
## Module Arguments
| Name               | Type           | Required | Description                                                                                                                                                                                          |
|--------------------|----------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `organizationCode` | `string`       | true     | A three character UNIQUE Customer code according to Eviden naming convention indicating which customer we are deploying this automation for. |                                       |
| `subscriptionCode` | `string`       | true     | A four character Evidencode according to ELZ naming convention to indicate which subscription we are deploying the automation to. Example 'mgmt' for management, 'lnd1' for the 1st landingzone. |
| `environmentCode`  | `string`       | true     | A one character Evidencode according to ELZ naming convention to indicate which environment type will be deployed to. Example 'd' for Development, 't' for Test etc.                             |
| `azureLocation`    | `string`       | true     | The Azure location/region to which the resources are being deployed. This will be used to get the corresponding four character Eviden code according to ELZ naming convention.                    |
| `suffix`           | `list(string)` | false    | Possible suffixes to add to the name being generated. Example 'artifact', 'repo', 'backend'. No limits on number of characters.                                                                      |
| `company`    | `string`       | true     | Name of the company that developed this release |
| `companyCode`    | `string`       | true     | Abbreviation or code of the name of the company that developed this release. To be used for branding of the tags|
| `product`    | `string`       | true     | Name of the product of this release |
## Module outputs
The module outputs the names generated for the resources, please see the outputs section in the `naming.bicep` file for details.

