##
## Eviden Landingzones for Azure  - Check Tags for Resource Groups in Azure Subscriptions
##
 
Describe 'Smoke and Sanity Testing for ELZ Azure Solution' {

    BeforeAll {
        $tagName1 = $tagPrefix + "Managed"
        $tagName2 = $tagPrefix + "Purpose"
        $tagValue1 = $tagValuePrefix + "Automation"
        $tagValue2 = $tagValuePrefix +  "Bootstrap"
        $tagValue3 = $tagValuePrefix + "SharedImageGallery"
        $tagValue4 = $tagValuePrefix + "ITSM"
        $tagValue5 = $tagValuePrefix + "Billing"
        $tagValue6 = "True"
        $tagValue7 = $tagValuePrefix + "Monitoring"
        $tagValue8 = $tagValuePrefix + "VmOsManagementAutomation"
        $tagValue9 = $tagValuePrefix + "OSTagging"
        $tagValue10 = $tagValuePrefix + "Reporting"
        $tagValue11 = $tagValuePrefix + "NetworkingHub"
        $tagValue12 = $tagValuePrefix + "DiskEncryption"
        $tagValue13 = $tagValuePrefix + "RecoveryServicesVault"
        $tagValue14 = $tagValuePrefix + "NetworkingSpoke"

        $dateTime = (Get-Date).ToString()
    }

    Context 'MGMT Automation RSG Tag Check' {

        It 'Step04-01. Check if the correct Tags/Values have been assigned to the MGMT Automation RSG' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText1 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText2 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Automation TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-automation
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag1 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag2 = ($resourcetags -match "$tagName2=`"$tagValue1`"")

            $resourceMatchesTag1 | Should -BeTrue -Because $becauseText1
            $resourceMatchesTag2 | Should -BeTrue -Because $becauseText2

        }
    }

    Context 'MGMT Bootstrap RSG Tag Check' {
    
        It 'Step04-02. Check if the correct Tags/Values have been assigned to the MGMT Bootstrap RSG' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText3 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText4 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Bootstrap TAG assigned' + ' Checked at: ' + $($dateTime)


            $resourceGroup = Get-AzResourceGroup -Name *-rsg-bootstrap
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag3 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag4 = ($resourcetags -match "$tagName2=`"$tagValue2`"")

            $resourceMatchesTag3 | Should -BeTrue -Because $becauseText3
            $resourceMatchesTag4 | Should -BeTrue -Because $becauseText4

        }
    }

    Context 'MGMT SharedImageGallery RSG Tag Check' {
    
        It 'Step04-03. Check if the correct Tags/Values have been assigned to the MGMT SharedImageGallery RSG' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText5 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText6 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'SharedImageGallery TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-computegallery
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag5 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag6 = ($resourcetags -match "$tagName2=`"$tagValue3`"")

            $resourceMatchesTag5 | Should -BeTrue -Because $becauseText5
            $resourceMatchesTag6 | Should -BeTrue -Because $becauseText6

        }
    }

    Context 'MGMT ITSM RSG Tag Check' {
    
        It 'Step04-04. Check if the correct Tags/Values have been assigned to the MGMT ITSM RSG' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText7 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText8 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'ITSM TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-itsm
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag7 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag8 = ($resourcetags -match "$tagName2=`"$tagValue4`"")

            $resourceMatchesTag7 | Should -BeTrue -Because $becauseText7
            $resourceMatchesTag8 | Should -BeTrue -Because $becauseText8

        }
    }

    Context 'MGMT Billing RSG Tag Check' {
    
        It 'Step04-05. Check if the correct Tags/Values have been assigned to the MGMT Billing RSG' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText9 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText10 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Billing TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-metering
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag9 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag10 = ($resourcetags -match "$tagName2=`"$tagValue5`"")

            $resourceMatchesTag9 | Should -BeTrue -Because $becauseText9
            $resourceMatchesTag10 | Should -BeTrue -Because $becauseText10

        }
    }

    Context 'MGMT Monitoring RSG Tag Check' {
    
        It 'Step04-06. Check if the correct Tags/Values have been assigned to the MGMT Monitoring RSG' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText11 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText12 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Monitoring TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-monitoring
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag11 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag12 = ($resourcetags -match "$tagName2=`"$tagValue7`"")

            $resourceMatchesTag11 | Should -BeTrue -Because $becauseText11
            $resourceMatchesTag12 | Should -BeTrue -Because $becauseText12

        }
    }

    Context 'MGMT VmOsManagementAutomation RSG Tag Check' {
    
        It 'Step04-07. Check if the correct Tags/Values have been assigned to the MGMT VmOsManagementAutomation RSG' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText13 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText14 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'VmOsManagementAutomation TAG assigned' + ' Checked at: ' + $($dateTime)
            $resourceGroup = Get-AzResourceGroup -Name *-rsg-osmgmtautomation
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag13 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag14 = ($resourcetags -match "$tagName2=`"$tagValue8`"")

            $resourceMatchesTag13 | Should -BeTrue -Because $becauseText13
            $resourceMatchesTag14 | Should -BeTrue -Because $becauseText14

        }
    }

    Context 'MGMT OSTagging RSG Tag Check' {
    
        It 'Step04-08. Check if the correct Tags/Values have been assigned to the MGMT OSTagging RSG' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText15 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText16 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'OSTagging TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-ostagging
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag15 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag16 = ($resourcetags -match "$tagName2=`"$tagValue9`"")

            $resourceMatchesTag15 | Should -BeTrue -Because $becauseText15
            $resourceMatchesTag16 | Should -BeTrue -Because $becauseText16

        }
    }

    Context 'MGMT Reporting RSG Tag Check' {
    
        It 'Step04-09. Check if the correct Tags/Values have been assigned to the MGMT Reporting RSG' {
            Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText17 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText18 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Reporting TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-reporting
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag17 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag18 = ($resourcetags -match "$tagName2=`"$tagValue10`"")

            $resourceMatchesTag17 | Should -BeTrue -Because $becauseText17
            $resourceMatchesTag18 | Should -BeTrue -Because $becauseText18

        }
    }

    Context 'CNTY Firewall Policy RSG Tag Check' {
    
        It 'Step05-01. Check if the correct Tags/Values have been assigned to the CNTY Firewall Policy RSG' {
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText19 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText20 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingHub TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-hub-firewallPolicy
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag19 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag20 = ($resourcetags -match "$tagName2=`"$tagValue11`"")

            $resourceMatchesTag19 | Should -BeTrue -Because $becauseText19
            $resourceMatchesTag20 | Should -BeTrue -Because $becauseText20

        }
    }

    Context 'CNTY Network Hub RSG Tag Check' {
    
        It 'Step05-02. Check if the correct Tags/Values have been assigned to the CNTY Network Hub RSG' {
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText19 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText20 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingHub TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-hub-network
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag19 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag20 = ($resourcetags -match "$tagName2=`"$tagValue11`"")

            $resourceMatchesTag19 | Should -BeTrue -Because $becauseText19
            $resourceMatchesTag20 | Should -BeTrue -Because $becauseText20

        }
    }

    Context 'CNTY Monitoring RSG Tag Check' {
    
        It 'Step05-03. Check if the correct Tags/Values have been assigned to the CNTY Monitoring RSG' {
            Set-AzContext -Subscription $custCntySubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText21 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText22 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Monitoring TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-monitoring
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag21 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag22 = ($resourcetags -match "$tagName2=`"$tagValue7`"")

            $resourceMatchesTag21 | Should -BeTrue -Because $becauseText21
            $resourceMatchesTag22 | Should -BeTrue -Because $becauseText22

        }
    }

    Context 'LNDZ DiskEncryption RSG Tag Check' {
    
        It 'Step06-01. Check if the correct Tags/Values have been assigned to the LNDZ DiskEncryption RSG' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText23 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText24 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'DiskEncryption TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-disk-encryption
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag23 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag24 = ($resourcetags -match "$tagName2=`"$tagValue12`"")

            $resourceMatchesTag23 | Should -BeTrue -Because $becauseText23
            $resourceMatchesTag24 | Should -BeTrue -Because $becauseText24

        }
    }

    Context 'LNDZ Monitoring RSG Tag Check' {
    
        It 'Step06-02. Check if the correct Tags/Values have been assigned to the LNDZ Monitoring RSG' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText21 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText22 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'Monitoring TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-monitoring
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag21 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag22 = ($resourcetags -match "$tagName2=`"$tagValue7`"")

            $resourceMatchesTag21 | Should -BeTrue -Because $becauseText21
            $resourceMatchesTag22 | Should -BeTrue -Because $becauseText22

        }
    }

    Context 'LNDZ RecoveryServicesVault RSG Tag Check' {
    
        It 'Step06-03. Check if the correct Tags/Values have been assigned to the LNDZ RecoveryServicesVault RSG' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText25 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText26 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'RsecoveryServicesVault TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-recovery-vaults
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag25 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag26 = ($resourcetags -match "$tagName2=`"$tagValue13`"")

            $resourceMatchesTag25 | Should -BeTrue -Because $becauseText25
            $resourceMatchesTag26 | Should -BeTrue -Because $becauseText26

        }
    }

    Context 'CNTY NetworkingSpoke RSG Tag Check' {
    
        It 'Step06-04. Check if the correct Tags/Values have been assigned to the CNTY NetworkingSpoke RSG' {
            Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

            $becauseText27 = 'The Resource Group should have the ' + $($tagPrefix) + 'Managed=true TAG assigned' + ' Checked at: ' + $($dateTime)
            $becauseText28 = 'The Resource Group should have the ' + $($tagPrefix) + 'Purpose = '+ $($tagValuePrefix)+ 'NetworkingSpoke TAG assigned' + ' Checked at: ' + $($dateTime)

            $resourceGroup = Get-AzResourceGroup -Name *-rsg-spoke-network
            $resourcetags = convert-hashToString($resourceGroup.tags)
            $resourceMatchesTag27 = ($resourcetags -match "$tagName1=`"$tagValue6`"")
            $resourceMatchesTag28 = ($resourcetags -match "$tagName2=`"$tagValue14`"")

            $resourceMatchesTag27 | Should -BeTrue -Because $becauseText27
            $resourceMatchesTag28 | Should -BeTrue -Because $becauseText28

        }
    }
}