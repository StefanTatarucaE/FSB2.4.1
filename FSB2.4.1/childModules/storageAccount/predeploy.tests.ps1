param (
    [Parameter(Mandatory=$true)]
    [string]$TemplateLocation 
)
Describe "Template File Checks" { 
    BeforeAll {
        $ShortGUID = ([system.guid]::newguid().guid).Substring(0, 5) 
        $TempValidationRG = "$ShortGUID-Pester-Validation-RG" 
        $Location = "West Europe"
        $TemplatePath = $TemplateLocation
        $Template = "storageAccount.json"
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
                'parameters'
                'variables'
                'resources'
                'outputs'
            ) 
            $TemplateProperties = (get-content "$TemplatePath\storageAccount.json" | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | ForEach-Object Name
            Assert-Equivalent -Actual $TemplateProperties -Expected $ExpectedProperties
        }

        It "Creates the expected Azure resources" { 
            $ExpectedResources = @(
                'Microsoft.Storage/storageAccounts' 
                'Microsoft.Storage/storageAccounts/blobServices' 
                'Microsoft.Storage/storageAccounts/blobServices/containers' 
                'Microsoft.Storage/storageAccounts/fileServices' 
                'Microsoft.Storage/storageAccounts/fileServices/shares' 
                'Microsoft.Storage/storageAccounts/queueServices' 
                'Microsoft.Storage/storageAccounts/queueServices/queues' 
                'Microsoft.Storage/storageAccounts/tableServices' 
                'Microsoft.Storage/storageAccounts/tableServices/tables' 
            )
            $TemplateResources = (get-content $TemplateFile | ConvertFrom-Json -ErrorAction SilentlyContinue).Resources.type 
            Assert-Equivalent -Actual $TemplateResources -Expected $ExpectedResources
        }
    }
    Context "Template Validation" { 
        It "Template $TemplateFile and parameter file passes validation" { 
            # Complete mode - will deploy everything in the template from scratch. If the resource group already contains things (or even items that are not in the template) they will be deleted first. 
            # If it passes validation no output is returned, hence we test for NullOrEmpty 
            $ValidationResult = Test-AzResourceGroupDeployment -ResourceGroupName $TempValidationRG -Mode Complete -TemplateFile $TemplateFile -TemplateParameterFile $ParamsFile
            $ValidationResult | Should -BeNullOrEmpty 
        } 
     }
}