param (
    [Parameter(Mandatory = $true)]
    [string]$templateLocation 
)
Describe "Template File Checks" { 
    BeforeAll {
        $shortGUID = ([system.guid]::newguid().guid).Substring(0, 5) 
        $tempValidationRG = "$ShortGUID-Pester-Validation-RG" 

        $location = 'West Europe'
        $templatePath = $templateLocation
        $template = 'firewallPolicy.json'
        $params = 'dev.params.json'

        $templateFile = -join ($TemplatePath, "\", $Template)
        $paramsFile = -join ($TemplatePath, "\", $Params)

        New-AzResourceGroup -Name $tempValidationRG -Location $location -Verbose
    }
    AfterAll { 
        Remove-AzResourceGroup $tempValidationRG -Force -Verbose
    }
    Context "Component contents" { 
        It "Has a JSON template" { 
            $templateFile | Should -Exist
        }
    
        It "Has a parameters file" { 
            $paramsFile | Should -Exist 
        }
    }
    Context "Template files contents" { 
        It "Has the expected properties in the json" {
            $expectedProperties = @(
                '$schema'
                'contentVersion'
                'metadata'
                'parameters'
                'variables'
                'resources'
                'outputs'
            )
            $templateProperties = (Get-Content $TemplateFile | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | ForEach-Object Name
            Assert-Equivalent -Actual $templateProperties -Expected $expectedProperties
        }

        It "Creates the expected Azure resources" { 
            $expectedResources = @(
                'Microsoft.Network/firewallPolicies'
                'Microsoft.Network/firewallPolicies/ruleCollectionGroups'
                'Microsoft.Network/firewallPolicies/ruleCollectionGroups'
                'Microsoft.Network/firewallPolicies/ruleCollectionGroups'
            )
            $templateResources = (Get-Content $TemplateFile | ConvertFrom-Json -ErrorAction SilentlyContinue).Resources.type 
            Assert-Equivalent -Actual $templateResources -Expected $expectedResources
        }
    }
    Context "Template Validation" { 
        It "Template $templateFile and parameter file passes validation" { 
            # Complete mode - will deploy everything in the template from scratch. If the resource group already contains things (or even items that are not in the template) they will be deleted first. 
            # If it passes validation no output is returned, hence we test for NullOrEmpty 
            $deployParams = @{
                ResourceGroupName     = $tempValidationRG
                Mode                  = 'Complete'
                TemplateFile          = $templateFile
                TemplateParameterFile = $paramsFile
            }
            $validationResult = Test-AzResourceGroupDeployment @deployParams
            $validationResult | Should -BeNullOrEmpty 
        } 
    }
}
