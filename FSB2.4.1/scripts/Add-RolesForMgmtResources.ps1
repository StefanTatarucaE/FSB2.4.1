function Add-RolesForMgmtResources {
    <#
	.SYNOPSIS
		This script will set the necessary role assignments for the management subscription resources in the other subscriptions. 

    .DESCRIPTION
        This script will give permissions for the following resources from Management:
        - Shared Automation Account 
        - Metering And Billing Function App
        - Os-Version Function App
        - Alert Logic App
        - CMDB Logic App

        Script functionality description: 
        The script will check for the managed identities of the resources with the Purpose tag on that are placed in the 
        source subscription (Management) and it will switch to the target subscription where he will try to get each one of the 
        managed identities that has been found in the previous step. 

        If any managed identities are found, it will check for the current roles that are assigned for it and compare them with
        the list of roles that needs to be assigned. If the roles are present for the managed identities it will skip the assign 
        process, and if not, it will assign them.

        Also, If any of these resources from Management doesn't have any managed identity created for it, the script will 
        continue the process by skipping that type of resource, because we are having some optional resources that will probably
        not be always found.

        Warning : The module 'Az.ResourceGraph' is required

	.PARAMETER $sourceSubscriptionId
	      Specifies the environment management subscription id. 

	.PARAMETER $targetSubscriptionId
        Specifies the environment target subscription id where you want to add the role assignments.

	.PARAMETER $tagPrefix
        Specifies the prefix for the company name that will be used in the tag name part

	.PARAMETER $tagValuePrefix
        Specifies the prefix for the company name that will be used in the tag value part

	.INPUTS
        None.

    .OUTPUTS
        

    .NOTES
        Version:        0.5
        Author:         frederic.trapet@eviden.com
        Creation Date:  20220729
        Purpose/Change: Added dynamic tag names for rebranding

    .EXAMPLE
        $parameters = @{
            "sourceSubscriptionId"  = "2914575d-bxxc-488b-bx20-f1xxxxxx" 
            "targetSubscriptionId"  = "xxxxa3c-xx7a-4cxe-80f4-1xcb2xxx7exbx"
            "tagPrefix"             = "myCompany"
            "tagValuePrefix"        = "myCompany"
        }

        Add-RolesForMgmtResources @parameters
	#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]$sourceSubscriptionId,
        [Parameter(Mandatory = $True)]
        [string]$targetSubscriptionId,
        [Parameter(Mandatory = $True)]
        [string]$tagPrefix,
        [Parameter(Mandatory = $True)]
        [string]$tagValuePrefix
    )

    begin {
        function applyRoleAssignments {
            [CmdletBinding()]
            param(
                [Parameter(Mandatory = $True)]
                [string]$resourcePrincipalId,
                [Parameter(Mandatory = $True)]
                [array]$rolesNeededForResource
            )
        
            foreach ($identity in $resourcePrincipalId) {
                #List the current roles that are assigned to the resource managed identity if any.
                $listCurrentRoles = Get-AzRoleAssignment -ObjectId $identity
                if (-not ([string]::IsNullOrEmpty($identity)) -and ([string]::IsNullOrEmpty($listCurrentRoles))) {
                    #Assign roles for the resource managed identity in case of the roles are not existing.
                    $rolesNeededForResource | ForEach-Object {
                      Write-Verbose ("Adding role assignment ["+ $PSItem +"] for identity [" + $identity + "] ")
                      New-AzRoleAssignment -ObjectId $identity  -RoleDefinitionName $PSItem -Scope "/subscriptions/$targetSubscriptionId"
                    }
                }
                elseif (-not ([string]::IsNullOrEmpty($listCurrentRoles))) {
                    #Assign roles for the resource managed identity in case of the roles are not existing.
                    $compareListOfRoles = Compare-Object -ReferenceObject $rolesNeededForResource -DifferenceObject $listCurrentRoles.RoleDefinitionName -PassThru
                    $compareListOfRoles | ForEach-Object {
                      #We ignore the roles that may be already assigned to the identity but that are not in the required list
                      If ($rolesNeededForResource -contains $PSItem) {
                        Write-Verbose ("Adding role assignment ["+ $PSItem +"] for identity [" + $identity + "] ")
                        New-AzRoleAssignment -ObjectId $identity  -RoleDefinitionName $PSItem -Scope "/subscriptions/$targetSubscriptionId"
                      }
                    }
                }
                else {
                    #Skip the assignment of roles in case that no resource managed identity is found and proceed with the following step.
                    continue
                }
            }
        }

        #Roles needed for Automation Account runbooks
        $rolesForAutomationAccount = @(
            "Reader",
            "EventGrid EventSubscription Contributor",
            "Resource Policy Contributor",
            "Storage Blob Data Contributor",
            "Storage Account Contributor",
            "Log Analytics Contributor",
            "Virtual Machine Contributor",
            "Automation Runbook Operator",
            "Automation Contributor",
            "Backup Contributor",
            "Network Contributor"
        )

        #Roles needed for OsVersion Function App
        $rolesForOsVersion = @(
            "Virtual Machine Contributor"
        )

        #Roles needed for Metering/Billing Function App
        $rolesForBilling = @(
            "Reader",
            "Storage Table Data Reader"
        )

        #Roles needed for ITSM Alerts Logic App
        $rolesForItsmAlerts = @(
            "Reader"
            "Virtual Machine Contributor"
        )

        #Roles needed for ITSM CMDB Logic App
        $rolesForItsmCmdb = @(
            "Virtual Machine Contributor"
            "Log Analytics Contributor"
            "Monitoring Contributor"
        )

        #Roles needed for ITSM AL Listener Function App
        $rolesForItsmAlListener = @(
            "Reader"
            "Virtual Machine Contributor"
        )

        # Change context to the management subscription to get the principal id of the manage identities.
        Set-AzContext -Subscription $sourceSubscriptionId -ErrorAction Stop -WarningAction SilentlyContinue

        # Get the resources for which to create a role assignment

        # Get the Automation account principal id of the manage identity. 
        $TagName  = $tagPrefix + 'Purpose'
        $TagValue = $tagValuePrefix + 'Automation'
        $automationAccount = Search-AzGraph -Query "resources| where (type == ""microsoft.automation/automationaccounts"" and tostring(tags) contains ""\""$($TagName)\"":\""$($TagValue)\"""")|project identity"
        $automationAccountPrincipalId = $automationAccount.Identity.PrincipalId

        # Get the MeteringAndBilling Function App principal id of the manage identity.
        $TagName  = $tagPrefix + 'Purpose'
        $TagValue = $tagValuePrefix + 'Billing'
        $meteringAndBilling = Search-AzGraph -Query "resources| where (type == ""microsoft.web/sites"" and tostring(tags) contains ""\""$($TagName)\"":\""$($TagValue)\"""")|project identity"
        $meteringAndBillingPrincipalId = $meteringAndBilling.Identity.PrincipalId

        # Get the Os-Version Function App principal id of the manage identity.
        $TagName  = $tagPrefix + 'Purpose'
        $TagValue = 'FuncOsTagging'
        $osVersion = Search-AzGraph -Query "resources| where (type == ""microsoft.web/sites"" and tostring(tags) contains ""\""$($TagName)\"":\""$($TagValue)\"""")|project identity"
        $osVersionPrincipalId = $osVersion.Identity.PrincipalId

        # Get the ITSM Alerts Logic App principal id of the manage identity.
        $TagName  = $tagPrefix + 'Purpose'
        $TagValue = $tagValuePrefix + 'ItsmAlerts'
        $itsmAlert = Search-AzGraph -Query "resources| where (type == ""microsoft.logic/workflows"" and tostring(tags) contains ""\""$($TagName)\"":\""$($TagValue)\"""")|project identity"
        $itsmAlertPrincipalId = $itsmAlert.Identity.PrincipalId

        # Get the ITSM CMDB Logic App principal id of the manage identity.
        $TagName  = $tagPrefix + 'Purpose'
        $TagValue = $tagValuePrefix + 'ItsmCmdb'
        $itsmCmdb = Search-AzGraph -Query "resources| where (type == ""microsoft.logic/workflows"" and tostring(tags) contains ""\""$($TagName)\"":\""$($TagValue)\"""")|project identity"
        $itsmCmdbPrincipalId = $itsmCmdb.Identity.PrincipalId

        # Get the ITSM AL Listener Function App principal id of the manage identity.
        $TagName  = $tagPrefix + 'Purpose'
        $TagValue = $tagValuePrefix + 'ItsmListener'
        $itsmAbstractionLayer = Search-AzGraph -Query "resources| where (type == ""microsoft.web/sites"" and tostring(tags) contains ""\""$($TagName)\"":\""$($TagValue)\"""")|project identity"
        $itsmAbstractionLayerPrincipalId = $itsmAbstractionLayer.Identity.PrincipalId

    }

    process {
        # Change context to the target subscription to apply role assignments.
        Set-AzContext -Subscription $targetSubscriptionId -ErrorAction Stop -WarningAction SilentlyContinue

        # Apply role assignments for automation account principal id.
        if (-not ([string]::IsNullOrEmpty($automationAccountPrincipalId))) { 
            Write-Verbose "The resource managed identity for automation account has been found. Applying the roles."
            applyRoleAssignments -resourcePrincipalId $automationAccountPrincipalId -rolesNeededForResource $rolesForAutomationAccount
        }
        else {
            Write-Verbose "The resource managed identity for automation account hasn't been found. The assignment of roles for it will be skipped!"
        }

        # Apply role assignments for metering/billing function app.
        if (-not ([string]::IsNullOrEmpty($meteringAndBillingPrincipalId))) {
            Write-Verbose "The resource managed identity for metering/billing has been found. Applying the roles."
            applyRoleAssignments -resourcePrincipalId $meteringAndBillingPrincipalId -rolesNeededForResource $rolesForBilling 
        }
        else {
            Write-Verbose "The resource managed identity for metering/billing function app hasn't been found. The assignment of roles for it will be skipped!"
        }

        # Apply role assigments for OS Version function app.
        if (-not ([string]::IsNullOrEmpty($osVersionPrincipalId))) {
            Write-Verbose "The resource managed identity for os version function app has been found. Applying the roles."
            applyRoleAssignments -resourcePrincipalId $osVersionPrincipalId -rolesNeededForResource $rolesForOsVersion
        }
        else {
            Write-Verbose "The resource managed identity for os version function app hasn't been found. The assignment of roles for it will be skipped!"
        }

        # Apply role assignments for ITSM Alert logic app.
        if (-not ([string]::IsNullOrEmpty($itsmAlertPrincipalId))) {
            Write-Verbose "The resource managed identity for itsm alert logic app has been found. Applying the roles."
            applyRoleAssignments -resourcePrincipalId $itsmAlertPrincipalId -rolesNeededForResource $rolesForItsmAlerts
        }
        else {
            Write-Verbose "The resource managed identity for itsm alert logic app hasn't been found. The assignment of roles for it will be skipped!"
        }

        # Apply role assignmnts for ITSM CMDB logic app.
        if (-not ([string]::IsNullOrEmpty($itsmCmdbPrincipalId))) {
            Write-Verbose "The resource managed identity for itsm cmdb logic app has been found. Applying the roles."
            applyRoleAssignments -resourcePrincipalId $itsmCmdbPrincipalId -rolesNeededForResource $rolesForItsmCmdb
        }
        else {
            Write-Verbose "The resource managed identity for itsm cmdb logic app hasn't been found. The assignment of roles for it will be skipped!"
        }

        # Apply role assignmnts for ITSM Abstraction layer function app.
        if (-not ([string]::IsNullOrEmpty($itsmAbstractionLayerPrincipalId))) {
          Write-Verbose "The resource managed identity for itsm abstraction layer function app has been found. Applying the roles."
          applyRoleAssignments -resourcePrincipalId $itsmAbstractionLayerPrincipalId -rolesNeededForResource $rolesForItsmAlListener
        }
        else {
            Write-Verbose "The resource managed identity for itsm abstraction layer function app hasn't been found. The assignment of roles for it will be skipped!"
        }

    }

    end {
        # intentionally empty
    }
}

