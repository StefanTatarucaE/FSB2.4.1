/*
SUMMARY: Compute Gallery child module.
DESCRIPTION: Deployment of Compute Gallery resource for the Eviden Landingzones for Azure solution.
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.0.3
*/

// PARAMETERS
@description('Name of the Compute Gallery. Alphanumeric characters, with underscores and periods allowed in the middle, up to 80 characters total. All other special characters, including dashes, are disallowed.')
param computeGalleryName string

@description('Location of the resources.')
param location string

@description('Description for the Compute Gallery.')
param computeGalleryDescription string

@description('A mapping of tags to assign to the resource.')
param tags object

// RESOURCE DEPLOYMENTS
resource computeGallery 'Microsoft.Compute/galleries@2020-09-30' = {
  name: computeGalleryName
  location: location
  tags: tags
  properties: {
    description: computeGalleryDescription
  }
}

// OUTPUTS
output computeGalleryName string = computeGallery.name
output computeGalleryResourceId string = computeGallery.id
