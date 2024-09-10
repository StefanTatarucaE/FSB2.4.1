##
## Eviden Landing Zones for Azure - Feature test
##

Describe 'Core -  Test Security Center Data Export' {

    BeforeAll {
        $dateTime = (Get-Date).ToString()
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $laWorkspace = get-logAnalyticsWorkspace -custMgmtSubscriptionId $custMgmtSubscriptionId -tenantId $tenantId -tagPrefix $tagPrefix -tagValuePrefix $tagValuePrefix
        Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $resourceGroup_cnty = Get-AzResourceGroup -ResourceGroupName *rsg-monitoring*
        Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $resourceGroup_lndz = Get-AzResourceGroup -ResourceGroupName *rsg-monitoring*
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $resourceGroup_mgmt = Get-AzResourceGroup -ResourceGroupName *rsg-monitoring*

        $apiVersion = ((Get-AzResourceProvider -ProviderNamespace Microsoft.Security).ResourceTypes | Where-Object ResourceTypeName -eq automations).ApiVersions[0]
    }

    Context 'CNTY Subscription' {
                              
        It 'Test ASC Resourcegroup' {
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $becauseText = "We expect the ASC ResourceGroup to be in place" + ' Checked at: ' + $($dateTime)
            $resourceGroup_cnty.resourcegroupname | Should -Not -BeNullOrEmpty -Because $becauseText           
        }
            
        It 'Test Security Center Data Export in CNTY' {
            $response_cnty = Invoke-AzureRestAPIDataRequest  ("/subscriptions/" + $custCntySubscriptionId + "/resourcegroups/" + $resourceGroup_cnty.ResourceGroupName + "/providers/Microsoft.Security/automations/ExportToWorkspace" + "?api-version=" + $apiVersion)
            $becauseText = "Security Center Data Export should be enabled." + ' Checked at: ' + $($dateTime)
            $response_cnty.properties.isenabled[0] | Should -Be true -Because $becauseText
            $response_cnty.properties.actions.workspaceResourceId | Should -BeLike $laWorkspace.ResourceId
        }
          
    }

    Context 'LNDZ Subscription' {
                              
        It 'Test ASC Resourcegroup' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $becauseText = "We expect the ASC ResourceGroup to be in place" + ' Checked at: ' + $($dateTime)
            $resourceGroup_lndz.resourcegroupname | Should -Not -BeNullOrEmpty -Because $becauseText
        }
        It 'Test Security Center Data Export in LNDZ' {
            $response_lndz = Invoke-AzureRestAPIDataRequest  ("/subscriptions/" + $custLndzSubscriptionId + "/resourcegroups/" + $resourceGroup_lndz.ResourceGroupName + "/providers/Microsoft.Security/automations/ExportToWorkspace" + "?api-version=" + $apiVersion)
            $becauseText = "Security Center Data Export should be enabled." + ' Checked at: ' + $($dateTime)
            $response_lndz.properties.isenabled[0] | Should -Be true -Because $becauseText
            $response_lndz.properties.actions.workspaceResourceId | Should -BeLike $laWorkspace.ResourceId
        }
    }
    
    Context 'MGMT Subscription' {
                              
        It 'Test ASC Resourcegroup' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $becauseText = "We expect the ASC ResourceGroup to be in place" + ' Checked at: ' + $($dateTime)
            $resourceGroup_mgmt.resourcegroupname | Should -Not -BeNullOrEmpty -Because $becauseText
        }
        It 'Test Security Center Data Export in MGMT' {
            $response_mgmt = Invoke-AzureRestAPIDataRequest  ("/subscriptions/" + $custMgmtSubscriptionId + "/resourcegroups/" + $resourceGroup_mgmt.ResourceGroupName + "/providers/Microsoft.Security/automations/ExportToWorkspace" + "?api-version=" + $apiVersion)
            $becauseText = "Security Center Data Export should be enabled." + ' Checked at: ' + $($dateTime)
            $response_mgmt.properties.isenabled[0] | Should -Be true -Because $becauseText
            $response_mgmt.properties.actions.workspaceResourceId | Should -BeLike $laWorkspace.ResourceId
        }    
    }
}
  

