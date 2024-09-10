# childModules/vmCustomScriptExtension/vmCustomScriptExtension.bicep
Bicep module to deploy custom scripts (Powershell or bash) using vm extensions.

## Module Features
This module deploys a custom script inside a virtual machine using vm extension for post deployment configuration

Note: Limited testing for bash scripts and might require additional settings

## Parent Module Usage Example
```bicep
module wsusVirtualMachinePostDeployment '../../childModules/vmCustomScriptExtension/vmCustomScriptExtension.bicep' = {
  name: 'wsusvmtestpostdeployment'
  scope: wsusResourceGroup
  params: {
    virtualMachineName: wsusVirtualMachine.outputs.hostname
    deployCommandToExecute: deployCommandToExecute
    deployFiles: deployFiles
    location: wsusResourceGroup.location 
  }
}
```

## Module Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `virtualMachineName` | `string` | true | Specifies the name of the Virtual Machine where script will be deployed. |
| `location` | `string` | true | Specifies the location of the Virtual Machine. |
| `deployFiles` | `string` | true | Specifies the URL of the script that needs to be executed. |
| `deployCommandToExecute` | `array` | true | Specifies the command required for script execution. |

## Module outputs
NA

## Parameters file example
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "virtualMachineName": {
            "value": "wsusTest001"
        },
        "location": {
            "value": "westeurope"
        },
        "deployCommandToExecute": {
            "value": "powershell -ExecutionPolicy Unrestricted -File Configure-WsusServer.ps1"
        },
        "deployFiles": {
            "value": ["https://artifactsstgacc31.blob.core.windows.net/scripts/Configure-WsusServer.ps1"]
        }
    }
}
```