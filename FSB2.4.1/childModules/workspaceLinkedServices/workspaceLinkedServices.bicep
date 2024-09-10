/*
SUMMARY: Workspace Linked Services
DESCRIPTION: Child Module for deployment of link service between Automation Account and Workspace Log Analytics
AUTHOR/S: the Eviden Langingzones for Azure Team
VERSION: 0.0.1
*/

// PARAMETERS

@description('Specifies the Workspace Log Analytics name')
param linkedWorkspaceName string

@description('Specifies the Automation Account ID for linked services')
param automationAccountId string

// VARIABLES

// RESOURCE DEPLOYMENTS

resource workspaceLinkedService 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  name: '${linkedWorkspaceName}/Automation'
  properties: {
    resourceId: automationAccountId
  }
}

// OUTPUTS
