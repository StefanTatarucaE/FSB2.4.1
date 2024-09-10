# computeGallery/computeGallery
Bicep module to create an Azure Compute Galleries.

## Description
The module will create an Azure Compute Gallery (Shared Image Gallery).


## Module Parameter File

```hcl
Below is the sample parameter file to create a shared image gallery.
Please refer to the TEMPLATE.params.json file as initial parameter settings in the module directory.

{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "computeGalleryName": {
        "value": "mibsig01"
      },
       "tags": {
        "value": {
            "Owner": "Muhammad Ibrahim",
            "Project": "Shared Image Gallery",
            "EvidenManaged": "true"
        }
    }
    }
  }
```

## Parent Module Example Use
```hcl
module exampleComputeGallery '../../modules/computeGallery/computeGallery.bicep' = {
  scope: resourceGroup('exampleResourceGroup')
  name: 'exampleComputegallery-deployment'
  params: {
    computeGalleryName: 'exampleGalleryName'
    location: 'francecentral'
    tags: {
      EvidenManaged: 'true'
    }
  }
}

```

## Module Arguments

|  Name | Type | Required | Description |
| --- | --- | --- | --- |
| `computeGalleryName` | `string` | true | SpecName of the Compute Gallery. Alphanumeric characters, with underscores and periods allowed in the middle, up to 80 characters total. All other special characters, including dashes, are disallowed. |
| `location` | `string` | true | Location of the resources. |
| `computeGalleryDescription` | `string` | true | Description for the Compute Gallery. |
| `tags` | `object` | true | TA mapping of tags to assign to the resource. Additional Details [here](#object---tags).|
| `utcShort` | `string` | false | Returns the current (UTC) datetime value in the RFC1123 pattern format. 2009-06-15T13:45:30 -> Mon, 15 Jun 2009 20:45:30 GMT|

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
| Name | Description | Value
| --- | --- | --- |
| `computeGalleryName` | The Name of the Shared Image Gallery. | `computeGalleryName` |
| `computeGalleryResourceId` | The resource ID of the Shared Image Gallery. | `computeGallery.id` |

## Parameters file example
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "computeGalleryName": {
      "value": "ats-lnd1-t-cg-001"
    },
    "location": {
      "value": "westeurope"
    },
    "computeGalleryDescription": {
      "value": "This is a test deploy"
    },
    "tags": {
      "value": {
        "Owner": "Sandro",
        "Project": "Test Bicep",
        "UserStory": "DCSAZ-1707",
        "EvidenManaged": "true"
      }
    }
  }
}
```