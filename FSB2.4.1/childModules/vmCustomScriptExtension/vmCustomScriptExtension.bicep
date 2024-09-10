
/*
SUMMARY: Deployment of powershell script using vm extensions.
DESCRIPTION: Deploy a powershell script inside a virtual machine using vm extension for post deployment configuration
AUTHOR/S: bart.decker@eviden.com
VERSION: 0.1
*/

// PARAMETERS

@description('Name of the Virtual Machine')
param virtualMachineName string

@description('Location of the Virtual Machine')
param location string

@description('URL of the script that needs to be executed')
param deployFiles array

@description('Command required for script execution')
param deployCommandToExecute string

// RESOURCE DEPLOYMENTS
resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-07-01' existing = {
  name: virtualMachineName
}

resource virtualMachinePostDeployment 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' =  {
  parent: virtualMachine
  name: 'postDeployment'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      fileUris: deployFiles
      commandToExecute: deployCommandToExecute
    }
  }
}
