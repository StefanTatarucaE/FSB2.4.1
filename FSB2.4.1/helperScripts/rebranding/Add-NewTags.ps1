<#
.SYNOPSIS
Add new tags with exsiting tag value.

Loop all the tags from list and will add only tags which has marked "ReplaceTagName" is 'true' on resources which has  'ExistingTagName' Tag.

Tags will get added on Subscriptions, Resource groups and Resources. Tag value will be same as existing tag.

.DESCRIPTION

.PARAMETER $customerTenantId
    Specified the customer's tenant id

.PARAMETER $inputfilePath
    Specifies the input json file path '.\Tag-Conversion-Input.json'

.OUTPUTS
    Log file at same location 'PrerequisitesLogFile-$($tenantID).txt'

.NOTES
    Version:        0.1
    Author:         abhijit.kakade@eviden.com
    Creation Date:  2023/9/15

.EXAMPLE
$params = @{
	tenantID = 'bc57f51a-6d93-46ac-ae9c-c2a2840d090e'
    inputfilePath = '.\Tag-Conversion-Input.json'
}

Add-NewTags.ps1 @params
#>

param (
    [Parameter(Mandatory = $True)]
    [string]$tenantID,

    [Parameter(Mandatory = $True)]
    [string]$inputfilePath
)

function WriteOutput {
    param (

        [Parameter(Mandatory = $True)]
        $outputText,

        [Parameter(Mandatory = $False)]
        [bool]
        $isObject = $False
    )
    $timestamp = Get-Date -Format "MM.dd.yyyy HH:mm"
    if ($isObject -eq $True) {
        # Write-Output "$timestamp | Object Output "
        Write-Output $outputText
        Add-Content -Path ".\Add-NewTagsLogFile-$($tenantID).txt" -Value $outputText
    }
    else {
        Write-Output "$timestamp | $outputText"
        Add-Content -Path ".\Add-NewTagsLogFile-$($tenantID).txt" -Value "$timestamp | $outputText"
    }
}

## Login into Azure tenant
$global:tenantID = $tenantID

#region AZ Login
try {

    $azConnect = Connect-AzAccount -tenantID $tenantID
    if (-not $azConnect) {

        WriteOutput "Login error: Logging into azure Failed..."
        Write-Error "Login error: Logging into azure Failed..." -ErrorAction 'Stop'
    }
    else {
        WriteOutput "Successfully logged into the Azure Platform."
    }
}
catch {
    throw $_.Exception
}
#endregion AZ Login


#Get List of all tags available on the Subscription (Resoruces and Resource groups) (Summary of tags)
$existingTagsCount = get-azTag | ConvertTo-Json
WriteOutput "---------------- Summary of existing Tags and counts -------------------------"
WriteOutput $existingTagsCount -isobject $true

# Load JSON file
$inputJsonTagList = Get-Content -Path $inputfilePath -Raw | ConvertFrom-Json

WriteOutput "-------------------Input JSON File ----------------------------"
WriteOutput (ConvertTo-Json $inputJsonTagList ) -isobject $true

#region List Subscription
$Subscriptions = $inputJsonTagList.Subscriptions
WriteOutput $Subscriptions -isObject $true
try {
    #Looping through each subscription ("Include": true)
    foreach ($sub in $Subscriptions | Where-Object { $_.Include -eq $True }) {

        $addEvidentags = @{}
        #Setting context so the script will be executed within the subscription's scope
        Get-AzSubscription -SubscriptionName $sub.SubscriptionName -TenantId $tenantID | Set-AzContext

        #Get all subscription tags
        $subResourceID = "/subscriptions/$($sub.SubscriptionID)"
        WriteOutput "Selected Subscription - $($sub.SubscriptionName)"
        $subTags = get-azTag -ResourceId $subResourceID

        WriteOutput "Tags on $($sub.SubscriptionName) Subscription are as below : "

        if ($null -ne $subTags.PropertiesTable) {
            WriteOutput $subTags.PropertiesTable -isObject $True
        }
        else {
            WriteOutput "No tags found on Subscription $($sub.SubscriptionName)"
        }

        #Looping through each Subscription tag from input json file
        foreach ($inputTag in $inputJsonTagList.SubscriptionsTags | Where-Object { $_.ReplaceTagName -eq $True }) {
            if ($inputTag.ReplaceTagName -eq $True) {
                if ($null -ne $subTags.Properties.TagsProperty.$($inputTag.ExistingTagName)) {
                    WriteOutput "Subscription Contains $($inputTag.ExistingTagName)"
                    # Add tag with old value in array
                    $addEvidentags.Add($inputTag.NewTagName, $subTags.Properties.TagsProperty.$($inputTag.ExistingTagName))
                }
            }
        }
        if ($addEvidentags.Count -gt 0) {
            WriteOutput "Adding new tags on Subscription - $($sub.SubscriptionName)"
            #Add new tag on Subscription
            $null = Update-AzTag -ResourceId $subResourceID -Tag $addEvidentags -Operation Merge
            WriteOutput "Sucessfully added below tags on Subscription - $($sub.SubscriptionName)"
            WriteOutput ($addEvidentags | ConvertTo-Json) -isobject $true
        }

        WriteOutput "Processing with Resource Groups tags"
        try {
            #Looping through each Resource tag from input json file to compare with Resource group
            foreach ($inputTag in $inputJsonTagList.ResourceTags) {

                if ($inputTag.ReplaceTagName -eq $True) {
                    #WriteOutput ($inputTag | ConvertTo-Json) -isobject $true
                    WriteOutput "Move to next tag  - '$($inputTag.ExistingTagName)'"
                    $resourcegroupTags = @{$inputTag.ExistingTagName = "" }
                    $resourceGroupList = $null

                    #Get list of Resource group which has selected tag.
                    $resourceGroupList = Get-AzResourceGroup -Tag $resourcegroupTags
                    WriteOutput "Total $($resourceGroupList.Count) resource groups contains '$($inputTag.ExistingTagName)' tag"

                    if ($resourceGroupList) {
                        WriteOutput "List of Resource groups which contains - $($inputTag.ExistingTagName) tag :"
                        WriteOutput ($resourceGroupList | Select-Object -Property ResourceGroupName, Location, ResourceId, Tags | ConvertTo-Json) -isobject $true

                        #Looping resource group object which has selected tag
                        foreach ($resourceGroup in $resourceGroupList ) {
                            # Get existing tag value of resource group
                            $existingtagValue = $resourceGroup.tags[$inputTag.ExistingTagName]
                            $rsgNewTags = @{$inputTag.NewTagName = $existingtagValue }

                            if ($resourceGroup.tags.($inputTag.NewTagName)) {
                                WriteOutput "Resource group $($resourceGroup.ResourceGroupName) already has '$($inputTag.NewTagName)' tag."
                            }
                            else {
                                #Add new tag on Resource Group
                                Update-AzTag -ResourceId $resourceGroup.ResourceId -Tag $rsgNewTags -Operation Merge
                                WriteOutput "Resource group - $($resourceGroup.ResourceGroupName) updated with new tag."
                                WriteOutput ($rsgNewTags | ConvertTo-Json) -isobject $true
                            }
                        }
                    }

                    #Get list of resoruces which has selected tag
                    $tagResources = $null
                    $tagResources = Get-AzResource -TagName $inputTag.ExistingTagName
                    WriteOutput "Total $($tagResources.Count) resources contains '$($inputTag.ExistingTagName)' tag"

                    foreach ( $tagresource in $tagResources) {
                        if ($tagresource.Tags.($inputTag.NewTagName)) {
                            WriteOutput "Resource $($tagresource.type) - '$($tagresource.name)' already has '$($inputTag.NewTagName)' tag."
                        }
                        else {
                            $existingtagValue = $tagresource.tags.$($inputTag.ExistingTagName)
                            $newTagonResource = @{$inputTag.NewTagName = $existingtagValue }
                            $null = Update-AzTag -ResourceId $tagresource.ResourceId -Tag $newTagonResource -Operation Merge
                            WriteOutput "Resource $($tagresource.type) - '$($tagresource.name)' - updated successfully with below new tag."
                            WriteOutput ($newTagonResource | ConvertTo-Json) -isObject $True
                        }
                    }
                }
            }
        }
        catch {
            WriteOutput "Error : Adding new tags on Resources failed.."
            WriteOutput $_ -isObject $True
        }
    }
}
catch {
    WriteOutput "Error : Adding new tags failed.."
    WriteOutput $_ -isObject $True
}

WriteOutput "Process of adding new tag completed successfully."
