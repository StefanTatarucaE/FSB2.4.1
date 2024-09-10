<#
    .SYNOPSIS
        Create Remediation task for the resources that are not-compliant with the Install Azure Monitor Agent policy set definition.

    .DESCRIPTION
        This runbook loops through all subscriptions in the Customer tenant and on each subscription, 
        loops through the policies that are not-compliant with the policy definition for installing the Azure Monitor Agent
        and creates a remediation task for each policy that is not-compliant.

    .OUTPUTS
        N/A

    .NOTES
        Author:     Catalin Gurgu / Fred Trapet
        Company:    Eviden
        Email:      catalin-alexandru.gurgu@eviden.com
        Created:    2023-05-29
        Updated:    2024-02-27
        Version:    0.1
#>

function remediatePolicy {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$PolicyDefinitionName,
        [Parameter(Mandatory = $true)]
        [object[]]$Subscription
    )
    $compliantPolicy = $true
    $Subcontext = Get-AzContext -ListAvailable | Where-Object { $_.Subscription -like $subscription.Id }
    $nonCompliantPolicies = Get-AzPolicyState -DefaultProfile $Subcontext | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyDefinitionAction -eq "deployIfNotExists" -and $_.PolicyDefinitionName -eq $policyDefinitionName }

    foreach ($policy in $nonCompliantPolicies) {
        $compliantPolicy = $false
        $runningRemediation = Get-AzPolicyRemediation -DefaultProfile $Subcontext | where-object { $_.ProvisioningState -eq "Accepted" -or $_.ProvisioningState -eq "Running" -and $_.PolicyDefinitionReferenceId -eq $policy.PolicyDefinitionReferenceId }
        if (!$runningRemediation) {
            $remediationName = "remediation-" + $policy.PolicyDefinitionName
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
    return $compliantPolicy
}

#Define variable for policy to remediate if non-compliant
$policyDefinitionNameAmaWindows         = "vm-enableamagentwin-change-policy-def"
$policyDefinitionNameAmaWindowsScaleSet = "vmss-enableamagentwin-change-policy-def"
$policyDefinitionNameDcrWindows         = "dcr-amagent-association-win-change-policy-def"
$policyDefinitionNameAmaLinux           = "vm-enableamagentlnx-change-policy-def"
$policyDefinitionNameAmaLinuxScaleSet   = "vmss-enableamagentlnx-change-policy-def"
$policyDefinitionNameDcrLinux           = "dcr-amagent-association-lnx-change-policy-def"

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

    $compliantPolicyVm = remediatePolicy -PolicyDefinitionName $policyDefinitionNameAmaWindows -Subscription $subscription
    $compliantPolicySs = remediatePolicy -PolicyDefinitionName $policyDefinitionNameAmaWindowsScaleSet -Subscription $subscription

    if ($compliantPolicyVm -or $compliantPolicySs) {
        remediatePolicy -PolicyDefinitionName $policyDefinitionNameDcrWindows -Subscription $subscription
    }

    $compliantPolicyVm = remediatePolicy -PolicyDefinitionName $policyDefinitionNameAmaLinux -Subscription $subscription
    $compliantPolicySs = remediatePolicy -PolicyDefinitionName $policyDefinitionNameAmaLinuxScaleSet -Subscription $subscription

    if ($compliantPolicyVm -or $compliantPolicySs) {
        remediatePolicy -PolicyDefinitionName $policyDefinitionNameDcrLinux -Subscription $subscription
    }
}