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
            "$TemplatePath\workspaceLinkedServices.json" | Should -Exist
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
                'functions'
                'parameters'
                'resources'
                'outputs'
            )
            $TemplateProperties = (get-content "$TemplatePath\workspaceLinkedServices.json" | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | ForEach-Object Name
            Assert-Equivalent -Actual $TemplateProperties -Expected $ExpectedProperties
        }

        It "Creates the expected Azure resources" { 
            $ExpectedResources = @(
                'Microsoft.OperationalInsights/workspaces/linkedServices'
            )
            $TemplateResources = (get-content "$TemplatePath\workspaceLinkedServices.json" | ConvertFrom-Json -ErrorAction SilentlyContinue).Resources.type 
            Assert-Equivalent -Actual $TemplateResources -Expected $ExpectedResources
        }
    }
    Context "Template Validation" { 
        It "Template $TemplatePath\workspaceLinkedServices.json and parameter file passes validation" { 
            # Complete mode - will deploy everything in the template from scratch. If the resource group already contains things (or even items that are not in the template) they will be deleted first. 
            # If it passes validation no output is returned, hence we test for NullOrEmpty 
            $ValidationResult = Test-AzResourceGroupDeployment -ResourceGroupName $TempValidationRG -Mode Complete -TemplateFile "$TemplatePath\workspaceLinkedServices.json" -TemplateParameterFile "$TemplatePath\dev.params.json" 
            $ValidationResult | Should -BeNullOrEmpty 
        } 
    }
}
