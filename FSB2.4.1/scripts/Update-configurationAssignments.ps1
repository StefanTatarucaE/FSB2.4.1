function Update-configurationAssignments {
  <#
  .SYNOPSIS
    This script is used to deploy the configuration assignments for the maintenance configurations (formerly known as Patch Schedules) which are deployed in the management subscription.

  .DESCRIPTION
    The management workflow deploys the maintenance configurations in the management subscription. This script is used to deploy the configuration assignments for the maintenance configurations in the designated subscriptions.

  .PARAMETER subscriptionId
    Specifies the subscription id where the configuration assignments will be deployed.

  .PARAMETER mgmtSubscriptionId
    Specifies the subscription id where the configuration configurations are deployed.

  .PARAMETER configurationAssignmentTemplateFile
    Specifies the configuration assignment template file to be used for the deployment.

  .PARAMETER $tagPrefix
    Specifies the prefix for the company name that will be used in the tag name part

  .PARAMETER $tagValuePrefix
    Specifies the prefix for the company name that will be used in the tag value part

  .PARAMETER deployLocation
    specifies the location where the dynamic scope will be deployed.

  .INPUTS
      Parameters value coming from the pipeline.

  .OUTPUTS
      None.

  .NOTES
      Version:        0.1
      Author:         bart.decker@eviden.com
      Creation Date:  2024-02-19
      Purpose/Change: First version which is feature ready to use.

  .EXAMPLE
      $parameters = @{
          "mgmtSubscriptionId" = "xxxxa3c-xx7a-4cxe-80f4-1xcb2xxx7exbx"
          "configurationAssignmentsTemplateFile" = " C:\Repos\dcs-azure-bicep\childModules\configurationAssignments\configurationAssignments.bicep"
          "tagPrefix"          = "myCompany"
          "tagValuePrefix"     = "myCompany"
          "subscriptionId" = "xxxxa3c-xx7a-4cxe-80f4-1xcb2xxx7exbx"
          "location"     = "westeurope"
      }

      Update-configurationAssignments @parameters
#>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $True)]
    [string]$mgmtSubscriptionId,
    [Parameter(Mandatory = $True)]
    [string]$configurationAssignmentsTemplateFile,
    [Parameter(Mandatory = $True)]
    [string]$lndzSubscriptionId,
    [Parameter(Mandatory = $True)]
    [string]$tagPrefix,
    [Parameter(Mandatory = $True)]
    [string]$tagValuePrefix,
    [Parameter(Mandatory = $True)]
    [string]$location
  )

  #Tags used in this script:
  $tagValue = $tagValuePrefix + 'MaintenanceConfig'
  $managedTagValue = $tagValuePrefix + 'Managed'
  $maintenanceConfigurationsTagName = $tagPrefix + 'Patching'

  # Switching context to the management subscription.
  Write-Verbose "Switching context to the Management subscription"
  Set-AzContext -SubscriptionId $mgmtSubscriptionId -WarningAction SilentlyContinue

  # Get all the maintenance configurations with the specified tag value in the management subscription.
  $maintenanceConfigurations = Get-AzMaintenanceConfiguration | Where-Object { $_.tags.values -contains $tagValue }
  Write-Verbose "Found $($maintenanceConfigurations.Count) maintenance configurations with tag value $tagValue."

  # Switching context to the subscription where the Dynamic Scopes will be created.
  Write-Verbose "Switching context to the Landingzone subscription"
  set-azcontext -subscriptionid $lndzSubscriptionId -WarningAction SilentlyContinue

  # Loop through all the maintenance configurations and deploy the configuration assignment for that configuration.
  foreach ($maintenanceConfiguration in $maintenanceConfigurations) {

    $configurationAssignmentsTagObject = @{
      $maintenanceConfigurationsTagName = @($maintenanceConfiguration.Name)
      $managedTagValue= @('True')
    }

    # Construct the deployment parameters
    $subDeployParams = @{
      Name                                  = "dynamicScope-$($maintenanceConfiguration.name)"
      Location                              = $location
      configurationAssignmentName           = $maintenanceConfiguration.Name
      configurationAssignmentsTagObject     = $configurationAssignmentsTagObject
      maintenanceConfigurationId            = $maintenanceConfiguration.Id
      configurationAssignmentsResourceTypes = "Microsoft.Compute/virtualMachines"
      subscriptionId                    = "/subscriptions/$($lndzSubscriptionId)"
      TemplateFile                          = $configurationAssignmentsTemplateFile
      Verbose                               = $true
    }
    # Deploy the dynamic scope for the patch schedule.
    Write-Verbose "Deploying configuration assignment for the maintenance configuration with name: $($maintenanceConfiguration.name)"
    New-AzSubscriptionDeployment @subDeployParams -verbose
  }
}