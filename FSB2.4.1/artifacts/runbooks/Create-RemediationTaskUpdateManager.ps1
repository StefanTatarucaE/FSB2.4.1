<#
    .SYNOPSIS
        Create Remediation task for the resources that are not-compliant with the policies in the Update Manager Change Initiative.

    .DESCRIPTION
        This runbook loops through all subscriptions in the Customer tenant and on each subscription,
        loops through the policies that are not-compliant with the policies in the Update Manager Change Initiative, removes existing remediation task (if present)
        and creates a new remediation task for each policy that is not-compliant.

    .OUTPUTS
        N/A

    .NOTES
        Author:     Bart Deccker
        Company:    Eviden
        Email:      bart.decker@eviden.com
        Created:    2024-02-22
        Updated:    2024-02-22
        Version:    0.1
#>

#Define variable for policy to remediate if non-compliant
$policyDefinitionNameUpdateAssessmentWindows = "windows-update-assessment-change-policy-def"
$policyDefinitionNameUpdateAssessmentLinux = "linux-update-assessment-change-policy-def"
$policyDefinitionLinuxVmUpdatePatchMode = "linux-update-patch-mode-change-policy-def"
$policyDefinitionWindowsVmUpdatePatchMode = "windows-update-patch-mode-change-policy-def"


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

    $Subcontext = Get-AzContext -ListAvailable | Where-Object { $_.Subscription -like $subscription.Id }

    Write-Output ("Selected Subscription is " + $subscription.Name)

    $nonCompliantPoliciesWin = Get-AzPolicyState -DefaultProfile $Subcontext | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyDefinitionAction -eq "modify" -and $_.PolicyDefinitionName -eq $policyDefinitionNameUpdateAssessmentWindows }
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
    $nonCompliantPoliciesLinux = Get-AzPolicyState -DefaultProfile $Subcontext | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyDefinitionAction -eq "modify" -and $_.PolicyDefinitionName -eq $policyDefinitionNameUpdateAssessmentLinux }
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
    $nonCompliantPatchModePoliciesLinux = Get-AzPolicyState -DefaultProfile $Subcontext | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyDefinitionAction -eq "deployIfNotExists" -and $_.PolicyDefinitionName -eq $policyDefinitionWindowsVmUpdatePatchMode }
    foreach ($policy in $nonCompliantPatchModePoliciesLinux) {
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
    $nonCompliantPatchModePoliciesWindows = Get-AzPolicyState -DefaultProfile $Subcontext | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyDefinitionAction -eq "deployIfNotExists" -and $_.PolicyDefinitionName -eq $policyDefinitionLinuxVmUpdatePatchMode }
    foreach ($policy in $nonCompliantPatchModePoliciesWindows) {
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