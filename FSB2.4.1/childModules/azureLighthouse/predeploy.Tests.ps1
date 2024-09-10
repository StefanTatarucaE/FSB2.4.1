param (
    [Parameter(Mandatory=$true)]
    [string]$TemplateLocation 
)
Describe "Template File Checks" { 
    BeforeAll {
        $Location = "West Europe"
        $TemplatePath = $TemplateLocation
        $Template = "azurelighthouse.bicep"
        $TemplateFile = -join ($TemplatePath, "\", $Template)
        $Params = "dev.params.json"
        $ParamsFile = -join ($TemplatePath, "\", $Params) 
    }
    AfterAll { 
        #Remove-AzResourceGroup $TempValidationRG -Force 
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
		It "Has the expected properties in json" {
            $ExpectedProperties = @(
            '$schema'
            'contentVersion'
            'metadata'
            'outputs'
            'parameters'
            'resources'
            'variables'
            )
            $templateProperties = (Get-Content "$templatePath\deploy.json" | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | ForEach-Object Name | Sort-Object
            $templateProperties | Should -Be $ExpectedProperties
        }
		
        It "Has the expected properties in the json" {
            $ExpectedProperties = @(
                '$schema'
                'contentVersion'
                'parameters'
            ) 
            $TemplateProperties = (get-content $ParamsFile | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | ForEach-Object Name
            Assert-Equivalent -Actual $TemplateProperties -Expected $ExpectedProperties
			#$TemplateProperties | Should -Be $ExpectedProperties
        }

        It "Check if we have value for mspOfferName" { 
            $TemplateResources = (get-content $ParamsFile | ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.mspOffer
            $TemplateResources.value | should -NOT -BeNullOrEmpty 
        }
		
		It "Check if we have value for mspOfferName description" { 
            $TemplateResources = (get-content $ParamsFile | ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.mspOfferDescription
            $TemplateResources.value | should -NOT -BeNullOrEmpty 
        }
		
		It "Check if we have value for managedByTenantId" { 
            $TemplateResources = (get-content $ParamsFile | ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.managedByTenantId
            $TemplateResources.value | should -NOT -BeNullOrEmpty 
        }
		
		It "Check if we have value for authorizations" { 
            $TemplateResources = (get-content $ParamsFile | ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.authorizations
            $TemplateResources.value | should -NOT -BeNullOrEmpty 
        }
		
		It "Check if we have value for eligible authorizations" { 
            $TemplateResources = (get-content $ParamsFile | ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.eligibleAuthorizations
            $TemplateResources.value | should -NOT -BeNullOrEmpty 
        }
    }
    Context "Template Validation" { 
        It "Template $TemplateFile and parameter file passes validation" { 
            # Complete mode - will deploy everything in the template from scratch. If the resource group already contains things (or even items that are not in the template) they will be deleted first. 
            # If it passes validation no output is returned, hence we test for NullOrEmpty 
            $ValidationResult = Test-AzSubscriptionDeployment -Location 'West Europe' -TemplateFile $TemplateFile -TemplateParameterFile $ParamsFile 
            $ValidationResult | Should -BeNullOrEmpty
        } 
     }
}