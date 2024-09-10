##
## Eviden Landing Zones for Azure - Feature test
##
 
Describe 'OS-MGMT - Validate the VM OS Image Gallery' {

    BeforeAll {
        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
    }

    Context 'check deployed Shared Image Gallery resources' {
        
        # After successful deployment, there should be a Shared Image Gallery resource created.
        It "is Shared Image Gallery resource created" {
            $becauseText = 'Shared Image Gallery should be available' + ' Checked at: ' + $($dateTime)
            $imageGallery = search-azureResourceByTag -resourceType Microsoft.Compute/galleries -Tags @{"${tagPrefix}Purpose" = "${tagValuePrefix}SharedImageGallery"}
            $imageGallery | Should -Not -BeNullOrEmpty `
                -Because $becauseText
        }

        # After successful deployment, there should be a storage account created which must have 3 containers - vhdcheck, vhdready, vhdupload
        It "is storage account created" {
            # there should be a storage account created
            $Becausetext1 = 'Storage account for storing Shared VM images should be available' + ' Checked at: ' + $($dateTime)
            $imageStorageAccount = search-azureResourceByTag -resourceType Microsoft.Storage/storageAccounts -Tags @{"${tagPrefix}Purpose" = "${tagValuePrefix}SharedImageGallery"}
            $imageStorageAccount | Should -Not -BeNullOrEmpty `
                -Because $Becausetext1

            # must have 3 containers - vhdcheck, vhdready, vhdupload
            $rqdContainers = @()
            $rqdContainers += "vhdcheck"
            $rqdContainers += "vhdready"
            $rqdContainers += "vhdupload"

            $imageStorageContext = get-storageAccountContext -storageAccount $imageStorageAccount
            $imageContainers = Get-AzStorageContainer -Context $imageStorageContext
            $Becausetext2 = '3 containers named vhd* needed for storing VM image files' + ' Checked at: ' + $($dateTime)

            $rqdContainers | Should -BeIn $imageContainers.Name `
                -Because $Becausetext2
        }
    }
}