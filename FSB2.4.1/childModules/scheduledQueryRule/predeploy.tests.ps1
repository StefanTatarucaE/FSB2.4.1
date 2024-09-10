param (
    [Parameter(Mandatory=$true)]
    [string]$TemplateLocation 
)
Describe "Template File Checks" { 
    BeforeAll {
        $templateFileName = 'scheduledQueryRule.json'
        $parameterFileName = 'test.params.json'
        $ShortGUID = ([system.guid]::newguid().guid).Substring(0, 5) 
        $TempValidationRG = "$ShortGUID-Pester-Validation-RG" 
        $Location = "West US"
        $TemplatePath = $TemplateLocation
        New-AzResourceGroup -Name $TempValidationRG -Location $Location 
    }
    AfterAll { 
        Remove-AzResourceGroup $TempValidationRG -Force 
    }
    Context "Component contents" { 
        It "Has a JSON template" { 
             "$TemplatePath\$templateFileName" | Should -Exist 
        }
    
        It "Has a parameters file" { 
            "$TemplatePath\$parameterFileName" | Should -Exist 
        }
    }
    Context "Template files contents" { 
        It "Has the expected properties in the json" {
            $ExpectedProperties = @(
                '$schema'
                'contentVersion'
                'parameters'
                # 'variables'
                'resources'
                'outputs'
                'metadata'
            ) 
            $TemplateProperties = (get-content "$TemplatePath\$templateFileName" -ErrorAction Stop | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | ForEach-Object Name
            Assert-Equivalent -Actual $TemplateProperties -Expected $ExpectedProperties
        }

        It "Creates the expected Azure resources" { 
            $ExpectedResources = @(
                'Microsoft.Insights/scheduledQueryRules'
            )
            $TemplateResources = (get-content "$TemplatePath\$templateFileName" | ConvertFrom-Json -ErrorAction SilentlyContinue).Resources.type 
            Assert-Equivalent -Actual $TemplateResources -Expected $ExpectedResources
        }

    }
    Context "Template Validation" { 
        It "Template $TemplatePath\$templateFileName and parameter file passes validation" { 
            # Complete mode - will deploy everything in the template from scratch. If the resource group already contains things (or even items that are not in the template) they will be deleted first. 
            # If it passes validation no output is returned, hence we test for NullOrEmpty 
            $ValidationResult = Test-AzResourceGroupDeployment -ResourceGroupName $TempValidationRG -Mode Complete -TemplateFile "$TemplatePath\$templateFileName" -TemplateParameterFile "$TemplatePath\test.params.json" 
            $ValidationResult | Should -BeNullOrEmpty 
        } 
     }
}