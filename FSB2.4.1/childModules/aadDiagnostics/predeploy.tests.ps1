param (
    [Parameter(Mandatory=$false)]
    [string]$TemplateLocation = $PSScriptRoot
)
Describe "Template File Checks" { 
    BeforeAll {
        $templateFileName = 'aadDiagnostics.json'
        $parameterFileName = 'test.params.json'
        $Location = "West US"
        $TemplatePath = $TemplateLocation
    }
    AfterAll {}
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
                'resources'
                'metadata'
            ) 
            $TemplateProperties = (get-content "$TemplatePath\$templateFileName" -ErrorAction Stop | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | ForEach-Object Name
            Assert-Equivalent -Actual $TemplateProperties -Expected $ExpectedProperties
        }

        It "Creates the expected Azure resources" { 
            $ExpectedResources = @(
                'microsoft.aadiam/diagnosticSettings'
            )
            $TemplateResources = (get-content "$TemplatePath\$templateFileName" | ConvertFrom-Json -ErrorAction SilentlyContinue).Resources.type 
            Assert-Equivalent -Actual $TemplateResources -Expected $ExpectedResources
        }

    }
    Context "Template Validation" { 
        It "Template $TemplatePath\$templateFileName and parameter file passes validation" { 
            # If it passes validation no output is returned, hence we test for NullOrEmpty
            $deployParams = @{
                Location              = $Location
                TemplateFile          = "$TemplatePath\$templateFileName"
                TemplateParameterFile = "$TemplatePath\test.params.json"
            }
            $ValidationResult = Test-AzDeployment @deployParams
            $ValidationResult | Should -BeNullOrEmpty 
        } 
     }
}