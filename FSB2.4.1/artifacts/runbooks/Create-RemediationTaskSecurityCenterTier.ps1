<#
    .SYNOPSIS
        Create Remediation task for the resources that are not-compliant with the Security Center Tier policy definition.

    .DESCRIPTION
        This runbook loops through in the Customer tenant and on each subscription,
        loops through the policies that are not-compliant with the policy definition for Enabling Azure Security Center standard tier, removes existing remediation task (if present)
        and creates a new remediation task for each policy that is not-compliant.

    .OUTPUTS
        N/A

    .NOTES
        Author:     Dan Popescu
        Company:    Eviden
        Email:      bart.decker@eviden.com
        Created:    2020-09-15
        Updated:    2023-08-07
        Version:    0.1
#>

#Define variable for policy to remediate if non-compliant
$policyDefinitionName = "asc-pricing-change-policy-def"

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
catch
    {
        throw $_.Exception
    }

$subscriptions = Get-AzSubscription

Write-Output "Subscriptions where non-compliant policies will be remediated are" $subscriptions.name

foreach ($subscription in $subscriptions) {

    $Subcontext = Get-AzContext -ListAvailable | Where-Object {$_.Subscription -like $subscription.Id}

    Write-Output ("Selected Subscription is " + $subscription.Name)

    $nonCompliantPolicies = Get-AzPolicyState -DefaultProfile $Subcontext | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyDefinitionAction -eq "deployIfNotExists" -and $_.PolicyDefinitionName -eq $policyDefinitionName }

    foreach ($policy in $nonCompliantPolicies) {
        $existingremediation = Get-AzPolicyRemediation -DefaultProfile $Subcontext | Where-Object { $_.Name -like "*" + $policy.PolicyDefinitionName }
        if ($existingremediation) {
            $existingremediation | Remove-AzPolicyRemediation -DefaultProfile $Subcontext -AllowStop
            Write-Output "Removed existing remediation task" $existingremediation.name
            $remediationName = "remediation." + $policy.PolicyDefinitionName
            Start-Sleep 20
            try {
                Start-AzPolicyRemediation -Name $remediationName -PolicyAssignmentId $policy.PolicyAssignmentId -DefaultProfile $Subcontext
                Write-Output "New remediation task created with the name" $remediationName
            }
            catch {
                Write-Output "Failed to create remediation task"
            }
        }
        else {
            $remediationName = "remediation." + $policy.PolicyDefinitionName
            try {
                Start-AzPolicyRemediation -Name $remediationName -PolicyAssignmentId $policy.PolicyAssignmentId -DefaultProfile $Subcontext
                Write-Output "Remediation task created with the name" $remediationName
            }
            catch {
                Write-Output "Failed to create remediation task"
            }
        }
    }
}