param (
    [Parameter(Mandatory = $true)]
    [string]$TemplateLocation 
)
Describe "Template File Checks" { 
    BeforeAll {
        $ShortGUID = ([system.guid]::newguid().guid).Substring(0, 5) 
        $TempValidationRG = "$ShortGUID-Pester-Validation-RG" 
        $Location = "West Europe"
        $TemplatePath = $TemplateLocation
        New-AzResourceGroup -Name $TempValidationRG -Location $Location 
    }
    AfterAll { 
        Remove-AzResourceGroup $TempValidationRG -Force 
    }
    Context "Component contents" { 
        It "Has a JSON template" { 
            "$TemplatePath\automationAccountArtifacts.json" | Should -Exist
        }
    
        It "Has a parameters file" { 
            "$TemplatePath\dev.params.json" | Should -Exist 
        }
    }
    Context "Template files contents" { 
        It "Has the expected properties in the json" {
            $ExpectedProperties = @(
                '$schema'
                'metadata'
                'contentVersion'
                'parameters'
                'resources'
                'variables'
                'outputs'
            )
            $TemplateProperties = (get-content "$TemplatePath\automationAccountArtifacts.json" | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | ForEach-Object Name
            Assert-Equivalent -Actual $TemplateProperties -Expected $ExpectedProperties
        }

        It "Creates the expected Azure resources" { 
            $ExpectedResources = @(
                'Microsoft.Automation/automationAccounts/runbooks'
                'Microsoft.Automation/automationAccounts/webhooks'
                'Microsoft.Automation/automationAccounts/schedules'
                'Microsoft.Automation/automationAccounts/jobSchedules'
                'Microsoft.Automation/automationAccounts/modules'
            )
            $TemplateResources = (get-content "$TemplatePath\automationAccountArtifacts.json" | ConvertFrom-Json -ErrorAction SilentlyContinue).Resources.type 
            Assert-Equivalent -Actual $TemplateResources -Expected $ExpectedResources
        }
    }
    Context "Template Validation" { 
        It "Template $TemplatePath\automationAccountArtifacts.json and parameter file passes validation" { 
            # Complete mode - will deploy everything in the template from scratch. If the resource group already contains things (or even items that are not in the template) they will be deleted first. 
            # If it passes validation no output is returned, hence we test for NullOrEmpty 
            $ValidationResult = Test-AzResourceGroupDeployment -ResourceGroupName $TempValidationRG -Mode Complete -TemplateFile "$TemplatePath\automationAccountArtifacts.json" -TemplateParameterFile "$TemplatePath\dev.params.json" 
            $ValidationResult | Should -BeNullOrEmpty 
        } 
    }
}
