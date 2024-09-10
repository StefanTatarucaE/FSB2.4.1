##
## Eviden Landing Zones for Azure - Check Tags for Automation Accounts in Azure MGMT Subscription
##
 
Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
        $tagName1 = $tagPrefix + "Managed"
        $tagName2 = $tagPrefix + "Purpose"

        $tagValue1 = $tagValuePrefix + "LogAnalytics"
        $tagValue2 = $tagValuePrefix + "Monitoring"
        $tagValue3 = "True"
        $dateTime = (Get-Date).ToString()
    }

    Context 'Azure LogAnalytics Workspace Tags/Solutions Check' {

        It 'Step19-01. Check if the correct Tags/Values have been assigned to the LogAnalytics Workspace' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The LogAnalytics Workspace should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The LogAnalytics Workspace should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Monitoring TAG assigned' + ' Checked at: ' + $($dateTime)

            $logAnalyticsWorkspaceTags = (Get-LogAnalyticsWorkspace -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId).Tags

            $resourcetags = convert-hashToString($logAnalyticsWorkspaceTags)

            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue3`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue2`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }

        It 'Step19-02. Check whether the Solutions are present in the LogAnalytics Workspace' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The required Solutions should be enabled in the LogAnalytics Workspace' + ' Checked at: ' + $($dateTime)

            $logAnalyticsWorkspace = Get-LogAnalyticsWorkspace -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix

            $logAnalyticsWorkspaceSolList = (Get-AzOperationalInsightsIntelligencePack -ResourceGroupName  $logAnalyticsWorkspace.ResourceGroupName -WorkspaceName $logAnalyticsWorkspace.Name | Where-Object {$_.Enabled -eq $true}).Name

            $solutionList = @(
                "ADAssessment",
                "AgentHealthAssessment",
                "AlertManagement",
                "AzureActivity",
                "AzureSQLAnalytics",
                "KeyVaultAnalytics",
                "NetworkMonitoring",
                "SecurityCenterFree",
                "VMInsights"
            )
            foreach ($solution in $solutionList) {
                $logAnalyticsWorkspaceSolList -contains $solution | Should -Be $true -Because $becauseText1
            }
        }
    }
}