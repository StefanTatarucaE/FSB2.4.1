<#
    .SYNOPSIS
        Part of the optional feature that enables the storage account key management by dedicated Key Vault resources (legacy solution). 
        Creates remediation tasks to assign the Storage Account Key Operator Service Role for Key Vault Identity to storage accounts with the key management tag set.

    .DESCRIPTION
        This runbook loops through all subscriptions in the Customer tenant and checks if the policy that assigns the Storage Account Key Operator Service Role
        is compliant. If not it creates a new remediation task to assign the required role.

    .OUTPUTS
        N/A

    .NOTES
        Author:     Catalin Gurgu
        Company:    Eviden
        Email:      bart.decker@eviden.com
        Created:    2022-10-15
        Updated:    2023-08-07
        Version:    0.2
#>

#Define variable for policy to remediate if non-compliant
$policyDefinitionName = "storage-roleassg-change-policy-def"

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

    $nonCompliantPolicies = Get-AzPolicyState -DefaultProfile $Subcontext | Where-Object { $_.ComplianceState -eq "NonCompliant" -and ("deployIfNotExists","modify" -contains $_.PolicyDefinitionAction) -and $_.PolicyAssignmentName -like "*-" + $policyDefinitionName + "-*" }

    foreach ($policy in $nonCompliantPolicies) {
        $runningRemediation = Get-AzPolicyRemediation -DefaultProfile $Subcontext | Where-Object { ($_.ProvisioningState -eq "Accepted" -or $_.ProvisioningState -eq "Running") -and $_.Name -like '*' + $policy.PolicyDefinitionName }
        if (-not $runningRemediation) {
            $remediationName = "remediation-" + $policy.PolicyDefinitionName
            try {
                Start-AzPolicyRemediation -Name $remediationName -PolicyAssignmentId $policy.PolicyAssignmentId -DefaultProfile $Subcontext
                $policy.PolicyDefinitionReferenceId
                Start-Sleep 20
                Write-Output "New remediation task created with the name" $remediationName
            }
            catch {
                Write-Output "Failed to create remediation task: " + $_.Exception
            }
        }
        else {
            Write-Output "Remediation already running"
        }
    }
}

