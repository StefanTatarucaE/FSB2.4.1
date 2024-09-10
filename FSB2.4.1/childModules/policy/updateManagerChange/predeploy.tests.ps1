param (
    [Parameter(Mandatory = $true)]
    [string]$TemplateLocation 
)
Describe "Template File Checks" { 
    BeforeAll {
        $ShortGUID = ([system.guid]::newguid().guid).Substring(0, 5) 
        $TempValidationRG = "$ShortGUID-Pester-Validation-RG" 
        $Location = "North Europe"
        $TemplatePath = $TemplateLocation
        $Template = "policy.json"
        $TemplateFile = -join ($TemplatePath, "\", $Template)
        $Params = "dev.params.json"
        $ParamsFile = -join ($TemplatePath, "\", $Params)
        New-AzResourceGroup -Name $TempValidationRG -Location $Location 
    }
    AfterAll { 
        Remove-AzResourceGroup $TempValidationRG -Force 
    }
    Context "Component contents" { 
        It "Has a JSON template" { 
            $TemplateFile | Should -Exist
        }
    
        It "Has a parameters file" { 
            $ParamsFile | Should -Exist 
        }
    }
    Context "Template files contents" { 
        It "Has the expected properties in the json" {
            $ExpectedProperties = @(
                '$schema'
                'contentVersion'
                'metadata'
                'outputs'
                'parameters'
                'resources'
                'variables'
            )
            $TemplateProperties = (get-content $TemplateFile | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | ForEach-Object Name
            write-host $templateProperties
            Assert-Equivalent -Actual $TemplateProperties -Expected $ExpectedProperties
        }

        It "Creates the expected Azure resources" { 
            $ExpectedResources = @(
                'Microsoft.Authorization/policyDefinitions'
                'Microsoft.Authorization/policyDefinitions'
                'Microsoft.Authorization/policyDefinitions'
                'Microsoft.Authorization/policyDefinitions'
                'Microsoft.Authorization/policySetDefinitions'
                'Microsoft.Authorization/policyAssignments'
                'Microsoft.Resources/deployments'
            )

            $TemplateResources = (get-content $TemplateFile | ConvertFrom-Json -ErrorAction SilentlyContinue).Resources.type 

            Assert-Equivalent -Actual $TemplateResources -Expected $ExpectedResources
        }
    }
    Context "Template Validation" { 
        It "Template $TemplateFile and parameter file passes validation" { 
            # Complete mode - will deploy everything in the template from scratch. If the resource group already contains things (or even items that are not in the template) they will be deleted first. 
            # If it passes validation no output is returned, hence we test for NullOrEmpty 
            $deployParams = @{
                Location              = $Location
                TemplateFile          = $TemplateFile
                TemplateParameterFile = $ParamsFile
            }
            $ValidationResult = Test-AzDeployment @deployParams
            $ValidationResult | Should -BeNullOrEmpty 
        } 
    }
}