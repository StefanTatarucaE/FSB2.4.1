##
## Eviden Landing Zones for Azure - Feature test
##
 
Describe 'Core -  Check Missing Diagnostic Rules' {

    BeforeAll {
        $DateTime = (Get-Date).ToString()
    }

    Context 'MGMT' {
                                 
        It 'Missing MGMT Diagnostic Rules' {
            
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            #Check if diagnosticrules are missing for managed tagged resources
            $missing = get-allMissingDiagRules -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -whichCheck "missing" -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = 'we expect 0 missing diagnostic rules but found ' + $missing + ' Checked at: ' + $($DateTime)
            $missing.count | Should -Be 0 -Because $becauseText
        }
        It 'Check for wrong LA Workspace' {
            
            #Check if wrong LA Workspace is set for the diagnosticrule
            $checking = get-allMissingDiagRules -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -whichCheck "existing" -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = 'we expect the correct LA Workspace to be set but that is not the case for' + $checking + ' Checked at: ' + $($DateTime)
            $checking.count | Should -Be 0 -Because $becauseText
        }
    }
    Context 'LNDZ' {
                                 
        It 'Missing LNDZ Diagnostic Rules' {
            
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            #Check if diagnosticrules are missing for managed tagged resources
            $missing = get-allMissingDiagRules -custMgmtSubscriptionId $custLndzSubscriptionId -tenantId $tenantId -whichCheck "missing" -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = 'we expect 0 missing diagnostic rules but found ' + $missing + ' Checked at: ' + $($DateTime)
            $missing.count | Should -Be 0 -Because $becauseText
        }
        It 'Check for wrong LA Workspace' {
            
            #Check if wrong LA Workspace is set for the diagnosticrule
            $checking = get-allMissingDiagRules -custMgmtSubscriptionId $custLndzSubscriptionId -tenantId $tenantId -whichCheck "existing" -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = 'we expect the correct LA Workspace to be set but that is not the case for' + $checking + ' Checked at: ' + $($DateTime)
            $checking.count | Should -Be 0 -Because $becauseText
        }
    }
    Context 'CNTY' {
                                 
        It 'Missing CNTY Diagnostic Rules' {
            
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            #Check if diagnosticrules are missing for managed tagged resources
            $missing = get-allMissingDiagRules -custMgmtSubscriptionId $custCntySubscriptionId -tenantId $tenantId -whichCheck "missing" -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = 'we expect 0 missing diagnostic rules but found ' + $missing + ' Checked at: ' + $($DateTime)
            $missing.count | Should -Be 0 -Because $becauseText
        }
        It 'Check for wrong LA Workspace' {
            
            #Check if wrong LA Workspace is set for the diagnosticrule
            $checking = get-allMissingDiagRules -custMgmtSubscriptionId $custCntySubscriptionId -tenantId $tenantId -whichCheck "existing" -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
            $becauseText = 'we expect the correct LA Workspace to be set but that is not the case for' + $checking + ' Checked at: ' + $($DateTime)
            $checking.count | Should -Be 0 -Because $becauseText
        }
    }
    
}