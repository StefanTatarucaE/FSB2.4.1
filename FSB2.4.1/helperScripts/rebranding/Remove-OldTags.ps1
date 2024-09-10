<#
.SYNOPSIS

This script removes existing tags if "ReplaceTagName" = true OR "RemoveExistingTag" = true.
This script accept same input json as other tag conversion scripts.

Checks all resources which has tag mentioned as 'ExistingTagName' in input json.

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
	tenantID = 'qa6738234-6d93-46ac-ae9c-c2a2840hy5s'
    mgmtSubscriptionId = 'wqe23234-dc03-4329-bbfwre423wef2'
    inputfilePath = '.\Tag-Conversion-Input.json'
}

Remove-OldTags.ps1 @params
#>


param (
    [Parameter(Mandatory = $True)]
    [string]$tenantID,

    [Parameter(Mandatory = $True)]
    [string]$mgmtSubscriptionId,

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
        Add-Content -Path ".\RemoveTagsLogFile-$($tenantID).txt" -Value $outputText
    }
    else {
        Write-Output "$timestamp | $outputText"
        Add-Content -Path ".\RemoveTagsLogFile-$($tenantID).txt" -Value "$timestamp | $outputText"
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

$mgmtnamingfilepath =  '.\mgmtNaming.json'
$inputNamingModule = Get-Content -Path $mgmtnamingfilepath -Raw | ConvertFrom-Json

WriteOutput "-------------------Input JSON File ----------------------------"
WriteOutput (ConvertTo-Json $inputJsonTagList ) -isobject $true

#region List Subscription
$Subscriptions = $inputJsonTagList.Subscriptions
WriteOutput $Subscriptions -isObject $true
try {
    #Looping through each subscription ("Include": true)
    foreach ($sub in $Subscriptions | Where-Object { $_.Include -eq $True }) {

        $removeAtosTags = @{}
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
        foreach ($inputTag in $inputJsonTagList.SubscriptionsTags | Where-Object { ($_.ReplaceTagName -eq $True) -or ($_.RemoveExistingTag -eq $True) }) {

            if (($inputTag.ReplaceTagName -eq $True) -or ($inputTag.RemoveExistingTag -eq $True)) {
                if ($null -ne $subTags.Properties.TagsProperty.$($inputTag.NewTagName)) {
                    WriteOutput "Subscription Contains $($inputTag.ExistingTagName)"
                    #Make sure subscription has new tag already added.
                    if ($null -ne $subTags.Properties.TagsProperty.$($inputTag.NewTagName)) {
                        WriteOutput "New tag is available on subscription, Old tag can be removed."
                        # Add tag with existing value in array
                        $removeAtosTags.Add($inputTag.ExistingTagName, $subTags.Properties.TagsProperty.$($inputTag.ExistingTagName))
                    }
                }
            }
        }
        if ($removeAtosTags.Count -gt 0) {
            #Remove old tag from Subscription
            $null = Update-AzTag -ResourceId $subResourceID -Tag $removeAtosTags -Operation Delete
            WriteOutput "Sucessfully Removed below tags from Subscription - $($sub.SubscriptionName)"
            WriteOutput ($removeAtosTags | ConvertTo-Json) -isobject $true
        }

        try {
            WriteOutput "Processing with Resource Groups tags"
            #Looping through each Resource tag from input json file to compare with Resource group
            foreach ($inputTag in $inputJsonTagList.ResourceTags) {

                if (($inputTag.ReplaceTagName -eq $True) -or ($inputTag.RemoveExistingTag -eq $True)) {
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
                            $rsgRemoveTags = @{$inputTag.ExistingTagName = $existingtagValue }

                            if (($null -ne $resourceGroup.tags[$inputTag.NewTagName]) -or (($null -ne $inputTag.RemoveExistingTag) -and ($True -eq $inputTag.RemoveExistingTag))) {
                                #Remove old tag from Resource Group
                                $null = Update-AzTag -ResourceId $resourceGroup.ResourceId -Tag $rsgRemoveTags -Operation Delete
                                WriteOutput "Removed below tag from Resource group - $($resourceGroup.ResourceGroupName)"
                                WriteOutput ($rsgRemoveTags | ConvertTo-Json) -isobject $true
                            }
                        }
                    }

                    #Get list of resoruces which has selected tag
                    $tagResources = $null
                    $tagResources = Get-AzResource -TagName $inputTag.ExistingTagName
                    WriteOutput "Total $($tagResources.Count) resources contains '$($inputTag.ExistingTagName)' tag"

                    foreach ( $tagresource in $tagResources) {
                        # Get existing tag value of resource group
                        $existingtagValue = $tagresource.tags.$($inputTag.ExistingTagName)
                        if (($null -ne $tagresource.tags.$($inputTag.NewTagName)) -or (($null -ne $inputTag.RemoveExistingTag) -and ($True -eq $inputTag.RemoveExistingTag))) {
                            $removeOldTags = @{$inputTag.ExistingTagName = $existingtagValue }
                            $null = Update-AzTag -ResourceId $tagresource.ResourceId -Tag $removeOldTags -Operation Delete
                            WriteOutput "Below old tags are removed from resource - $($tagresource.type) - '$($tagresource.name)'."
                            WriteOutput ($removeOldTags | ConvertTo-Json) -isObject $True
                        }
                    }
                }
            }
        }
        catch {
            WriteOutput "Error : Removing old tags failed. Try again.."
            WriteOutput $_ -isObject $True
        }
    }
}
catch {
    WriteOutput "Error : Removing old tags failed. Try again.."
    WriteOutput $_ -isObject $True
}
WriteOutput "Process of Removing old tags completed successfully."

WriteOutput "Connecting to MGMT Subscription"
Set-AzContext -SubscriptionId $mgmtSubscriptionId

# Start function Apps
WriteOutput "Starting function apps.."
try {

    $ITSMFunctionAppName = $inputNamingModule.customerItsmPwshFunctionApp.Name
    $ITSMFunctionAppResourceGroup = $inputNamingModule.managementItsmResourceGroup.name

    $OSTaggingFunctionAppName = $inputNamingModule.osTaggingFuncApp.name
    $OSTaggingFunctionAppResourceGroup = $inputNamingModule.osTaggingResourceGroup.name

    try {
        WriteOutput "Starting Function app - $ITSMFunctionAppName"
        Start-AzFunctionApp -ResourceGroupName $ITSMFunctionAppResourceGroup -Name $ITSMFunctionAppName
        WriteOutput "Function app - $ITSMFunctionAppName started successfully."
    }
    catch {
        WriteOutput "Error : failed to start function app.. Try again"
        WriteOutput $_ -isObject $True
    }

    try {
        WriteOutput "Starting Function app - $OSTaggingFunctionAppName"
        Start-AzFunctionApp -ResourceGroupName $OSTaggingFunctionAppResourceGroup -Name $OSTaggingFunctionAppName
        WriteOutput "Function app - $OSTaggingFunctionAppName started successfully."
    }
    catch {
        WriteOutput "Error : failed to start function app.. Try again"
        WriteOutput $_ -isObject $True
    }
}
catch {
    WriteOutput "Error : failed to start function app.. Try again"
    WriteOutput $_ -isObject $True
}
