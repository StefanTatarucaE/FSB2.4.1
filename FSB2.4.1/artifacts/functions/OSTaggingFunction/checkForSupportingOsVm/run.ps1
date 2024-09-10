# Adding ignore rule for parameter 'TriggerMetadata' that we don't use in the code for now
# V 2.0 - Fix for endless loop
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'TriggerMetadata', Justification = 'False positive')]

param($eventGridEvent, $TriggerMetadata)

Write-Host "PowerShell event trigger function processed a request."
write-host ($eventGridEvent | Convertto-json -depth 99)
$resId = $eventGridEvent.subject
$eveSub = $eventGridEvent.subject.split('/')
$vmName = $eveSub[8]
$ResourceGroupName = $eveSub[4]
$subId = $eventGridEvent.data.subscriptionId
$tagPrefix = $env:COMPANY_TAG_PREFIX
$osVersionTag = $tagPrefix + "OsVersion"

write-host "**********Resource Id: $resId**********"
write-host "**********VM Name: $vmName**********"
write-host "**********ResourceGroup Name: $ResourceGroupName**********"
write-host "**********Subscription Id: $subId**********"

#Connect to the environment using the Managed Identity
Connect-AzAccount -Identity

#Check the permissions
$subscriptions = Get-AzSubscription
Write-Host $subscriptions

#Connect to the subscription in which the VM is running
Set-AzContext -Subscription $subId

#Get VM resource details
Do {
    $vmStatus = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName -Status
    # Check if the VM is found if not throw an error
    If (-not ($vmStatus)) {
        Throw 'ERROR! VM not found'
    }
    # Add a counter to break out of the loop if the OsName property is not filled by Microsoft within 10 minutes
    $maxTries = $maxTries + 1
    start-sleep -s 30
    write-host "***********Waiting until OsName property is filled by Microsoft**********"
    # Drop out of the until loop if the maxTries is reached or when osName is filled
}Until((("OsName" -in $vmStatus.PSobject.Properties.Name) -and ($vmStatus.OsName -ne $null )) -or ($maxTries -eq 20))

write-host "***********Exiting the loop, OsName property is filled with: $($vmStatus.OsName) **********"

$vmPowerState = $vmStatus.Statuses[1].Code
write-host "***********VM Power State: $vmPowerState**********"

#OS validation
if ($vmPowerState -eq "PowerState/running") {
    # $resource = Get-AzResource -Name $vmName -ResourceGroupName $ResourceGroupName
    $resource = Get-AzVM -Name $vmName -ResourceGroupName $ResourceGroupName

    If (-not ($resource)) {
        Throw 'ERROR! Resource not found'
    }
    $tag = $resource.Tags
    $vmOsTagValue = $tag[$osVersionTag]
    $osName = $vmStatus.OsName
    $osVersion = $vmStatus.OsVersion
    if ($osName -match "Windows") {
        $tagValue = $osName
    }
    else {
        $tagValue = $osName + " " + $osVersion
    }
    write-host "***********OS Name: $osName**********"
    write-host "***********OS Version: $osVersion**********"

    write-host ("comparing existing tag value [" + $vmOsTagValue + "] with Os value [" + $tagValue + "] ...")
    if ( $vmOsTagValue -eq $tagValue) {
        Write-Host "Already assigned with correct OS Version tag ($osVersionTag : "$tagValue")"
    }
    else {
        if ($osName -match "Windows") {
            $vmOsTagValue = $osName
        }
        else {
            $vmOsTagValue = $tagValue
        }
        #Assign OsVersion tag
        $mergedTags = @{$osVersionTag = $vmOsTagValue }
        Update-AzTag -ResourceId $resId -Tag $mergedTags -Operation Merge -ErrorAction stop
        Write-Host "$osVersionTag tag has been added to VM $vmName"
    }
}
else {
    Write-Host "VM is not running, hence OS details not validated"
}