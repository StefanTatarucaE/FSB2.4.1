##
## Eviden Landingzones for Azure - Check if the required Resource Providers are registered
##

Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null 
        $dateTime = (Get-Date).ToString()
    }

    Context 'Resource Providers Check' {
        It 'Step01. Verify if the required Resource providers are registered for MGMT subscription:' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $becauseText = 'The required Resource Providers should be registered' + ' Checked at: ' + $($dateTime)
            $getlist = Get-AzResourceProvider
            $getProviderListMgmt = $getlist.ProviderNamespace
            $providerListMgmt = @(
				"Microsoft.ContainerService",
				"Microsoft.Automation",
				"microsoft.insights",
				"Microsoft.Network",
				"Microsoft.EventGrid",
				"Microsoft.PolicyInsights"
            )
            foreach ($providerMgmt in $providerListMgmt) {
                $getProviderListMgmt -contains $providerMgmt | Should -Be $true -Because $becauseTxt
            }
        }
        It 'Step02. Verify if the required Resource providers are registered for CNTY subscription:' {
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $becauseText = 'The required Resource Providers should be registered' + ' Checked at: ' + $($dateTime)
            $getlist = Get-AzResourceProvider
            $getProviderListCnty = $getlist.ProviderNamespace
            $providerListCnty = @(
                "Microsoft.Automation",
				"microsoft.insights",
				"Microsoft.EventGrid",
				"Microsoft.Compute",
				"Microsoft.PolicyInsights"
            )
            foreach ($providerCnty in $providerListCnty) {
                $getProviderListCnty -contains $providerCnty | Should -Be $true -Because $becauseTxt
            }
            
        }   
        It 'Step03. Verify if the required Resource providers are registered for LNDZ subscription:' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
            $becauseText = 'The required Resource Providers should be registered' + ' Checked at: ' + $($dateTime)
            $getlist = Get-AzResourceProvider
            $getProviderListLndz = $getlist.ProviderNamespace
            $providerListLndz = @(
				"microsoft.insights",
				"Microsoft.Automation",
				"Microsoft.Compute",
				"Microsoft.EventGrid",
				"Microsoft.PolicyInsights" 
            )
            foreach ($providerLndz in $providerListLndz) {
                $getProviderListLndz -contains $providerLndz | Should -Be $true -Because $becauseTxt
            }
        }      
    }

    AfterAll {
    }    
}