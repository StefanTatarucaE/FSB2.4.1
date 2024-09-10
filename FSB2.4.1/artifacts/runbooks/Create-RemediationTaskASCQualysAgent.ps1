<#
    .SYNOPSIS
        Create Remediation task for the resources that are not-compliant with the Install ASC Qualys Agent policy definition.

    .DESCRIPTION
        This runbook loops through all subscriptions in the customer tenant and on each subscription, 
        loops through the policies that are not-compliant with the policy definition for installing the ASC Qualys Agent, removes existing remediation task (if present)
        and creates a new remediation task for each policy that is not-compliant.

    .OUTPUTS
        N/A

    .NOTES
        Author:     Surbhi Sharma / Bart Decker
        Company:    Eviden
        Email:      bart.decker@eviden.com
        Created:    2021-03-11
        Updated:    2023-08-07
        Version:    0.2
#>

#Define variable for policy to remediate if non-compliant
$policyDefinitionNameWindows = "ascqualysagent-windows-change-policy-def"
$policyDefinitionNameLinux = "ascqualysagent-linux-change-policy-def"

# Get connected
try {

    #Disable the Context inheritance from a previous session
    Disable-AzContextAutosave -Scope Process

    Write-Output "Logging into Azure with System-assigned Identity"
    $azConnect = Connect-AzAccount -Identity

    if (-not $azConnect) {
        Write-Error "Login error: Logging into azure Failed..." -ErrorAction 'Stop'
    }
    else {
        Write-Output "Successfully logged into the Azure Platform."
    }
}
catch {
    throw $_.Exception
}

$subscriptions = Get-AzSubscription

Write-Output "Subscriptions where non-compliant policies will be remediated are" $subscriptions.name


foreach ($subscription in $subscriptions) {

    $Subcontext = Get-AzContext -ListAvailable | Where-Object {$_.Subscription -like $subscription.Id}

    Write-Output ("Selected Subscription is " + $subscription.Name)

    $nonCompliantPoliciesWin = Get-AzPolicyState -DefaultProfile $Subcontext | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyDefinitionAction -eq "deployIfNotExists" -and $_.PolicyDefinitionName -eq $PolicyDefinitionNameWindows }
    foreach ($policy in $nonCompliantPoliciesWin) {
        $runningRemediation = Get-AzPolicyRemediation -DefaultProfile $Subcontext | where-object { $_.ProvisioningState -eq "Accepted" -or $_.ProvisioningState -eq "Running" -and $_.PolicyDefinitionReferenceId -eq $policy.PolicyDefinitionReferenceId }



        if (!$runningRemediation) {

            $remediationName = "remediation." + $policy.PolicyDefinitionName

            try {
                Start-AzPolicyRemediation -Name $remediationName -PolicyAssignmentId $policy.PolicyAssignmentId -PolicyDefinitionReferenceId $policy.PolicyDefinitionReferenceId -DefaultProfile $Subcontext
                Start-Sleep 5
                Write-Output "New remediation task created with the name" $remediationName
            }
            catch {
                Write-Output "Failed to create remediation task"
            }
        }
        else {
            Write-Output "Remediation already running"
        }
    }
    $nonCompliantPoliciesLinux = Get-AzPolicyState -DefaultProfile $Subcontext | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyDefinitionAction -eq "deployIfNotExists" -and $_.PolicyDefinitionName -eq $policyDefinitionNameLinux }
    foreach ($policy in $nonCompliantPoliciesLinux) {
        $runningRemediation = Get-AzPolicyRemediation -DefaultProfile $Subcontext | where-object { $_.ProvisioningState -eq "Accepted" -or $_.ProvisioningState -eq "Running" -and $_.PolicyDefinitionReferenceId -eq $policy.PolicyDefinitionReferenceId }

        if (!$runningRemediation) {

            $remediationName = "remediation." + $policy.PolicyDefinitionName

            try {
                Start-AzPolicyRemediation -Name $remediationName -PolicyAssignmentId $policy.PolicyAssignmentId -PolicyDefinitionReferenceId $policy.PolicyDefinitionReferenceId -DefaultProfile $Subcontext
                Start-Sleep 5
                Write-Output "New remediation task created with the name" $remediationName
            }
            catch {
                Write-Output "Failed to create remediation task"
            }
        }
        else {
            Write-Output "Remediation already running"
        }
    }
}