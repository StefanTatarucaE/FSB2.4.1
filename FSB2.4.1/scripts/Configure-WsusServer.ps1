<#
.SYNOPSIS
    Install and configure WSUS feature on Windows Server 2019 and Windows Server 2022

.DESCRIPTION
    This script will install the WSUS feature on a Windows Server 2019 and 2022 including the necessary configuration.

    The Windows Server will require an additional disk for WSUS Database, the script will initialize that disk as Letter U if is not already.

    Microsoft Report Viewer 2012 Runtime will be installed as a prerequisite, necessary for report view in wsus.

    Following settings are configured: Target Groups, Classifications and Products

    Connectivity between WSUS server and Internet is mandatory to be allowed on ports 80 and 433. 
    Detailed list of addresses for firewall configuration can be found on Microsoft webpage: https://learn.microsoft.com/fr-fr/security-updates/windowsupdateservices/18127344

    Recommendation: This script requires between 15 and 30 minutes to be executed, depending on Virtual Machine performance. It is recommended when executed in a GitHub Workflow or Bicep deployment to be executed with "-as job", and progress to be monitored in portal or directly on the Virtual Machine
    
.PARAMETER $wsusTargetGroup
    Specifies the TargetGroups for wsus configuration (Prod, QA, Test)

.PARAMETER $wsusProducts
    Specifies the Products required for wsus (Windows Server 2019, Windows Server 2016)

.PARAMETER $wsusClassifications
    Specifies the Classfication required for wsus (Critical Updates, Definition Updates, Security Updates)

.NOTES
    Version:        0.1
    Author:         bart.decker@eviden.com
    Creation Date:  20230301
                    
.EXAMPLE
    .\Configure-WsusServer.ps1 -wsusTargetGroup 'Prod, QA' -wsusProducts 'Windows Server 2019, Windows Server 2016' -wsusClassifications 'Critical Updates, Definition Updates, Security Updates'

#>

param(
    [Parameter(Mandatory = $True)]
    [String[]]$wsusTargetGroups,

    [Parameter(Mandatory = $True)]
    [String[]]$wsusProducts,

    [Parameter(Mandatory = $True)]
    [String[]]$wsusClassifications
)

Write-host "Parameters for deployment are: "
Write-Host "Target Groups: $($wsusTargetGroups)"
Write-Host "Products: $($wsusProducts)"
Write-Host "Classifications: $($wsusClassifications)"

$wsusTargetGroups = $wsusTargetGroups.split(",").Trim()
$wsusProducts = $wsusProducts.split(",").Trim()
$wsusClassifications = $wsusClassifications.split(",").Trim()

# Initialize additional disk for WSUS database and assign letter
write-host 'Initializing additional data disk for WSUS database'
$disknumber = (get-disk | where { $_.PartitionStyle -eq 'RAW' }).Number
if ($disknumber) {
    Initialize-Disk $disknumber
    New-Partition -DiskNumber $disknumber -DriveLetter U -UseMaximumSize
    Format-Volume -DriveLetter U -FileSystem NTFS
}
else {
    Write-Host "No disk found"
}

# Setup Directories for Wsus database and prerequisits
write-host 'Setup Directories'
New-Item 'C:\temp' -ItemType Directory -Force | Out-Null
$WSUSDir = "U:\WSUS_Updates"
$DirSqlSysCtrl = "C:\temp\SQLSysClrTypes.msi"
$DirRepViewer = "C:\temp\ReportViewer.msi"

# Download and install Microsoft Report Viewer 2012 and Prerequisits
if (Get-WmiObject Win32_Product | where { $_.Name -eq 'Microsoft Report Viewer 2012 Runtime' }) {
    Write-Host "Report Viewer already installed"
}
else {
    write-host 'Download Microsoft Report Viewer 2012 and prerequisits'
    $URLSql = "http://go.microsoft.com/fwlink/?LinkID=239644"
    Start-BitsTransfer $URLSql $DirSqlSysCtrl -RetryInterval 60 -RetryTimeout 180 -ErrorVariable err
    $URLRep = "https://download.microsoft.com/download/F/B/7/FB728406-A1EE-4AB5-9C56-74EB8BDDF2FF/ReportViewer.msi"
    Start-BitsTransfer $URLRep $DirRepViewer -RetryInterval 60 -RetryTimeout 180 -ErrorVariable err

    write-host 'Installing Microsoft Report Viewer 2012 and prerequisits'

    $setup = Start-Process $DirSqlSysCtrl -ArgumentList '/q' -Wait -PassThru
    if ($setup.exitcode -eq 0) {
        write-host "Successfully installed SqlSysCtrl"
    }
    else {
        write-host 'Prerequisits for Microsoft Report Viewer 2012 did not install correctly.'
    }

    $setup = Start-Process $DirRepViewer -ArgumentList '/q' -Wait -PassThru
    if ($setup.exitcode -eq 0) {
        write-host "Successfully installed"
    }
    else {
        write-host 'Microsoft Report Viewer 2012 did not install correctly.'
    }
}

# Install WSUS feature
if ((Get-WindowsFeature -Name UpdateServices).InstallState -eq 'Installed') {
    Write-Host "WSUS feature already installed"
    $wsusConfigurationOnly = $true
}
else {
    write-host 'Installing WSUS for WID (Windows Internal Database)'
    Install-WindowsFeature -Name UpdateServices -IncludeManagementTools

    Set-Location "C:\Program Files\Update Services\Tools"
    .\wsusutil.exe postinstall CONTENT_DIR=$WSUSDir
}

# Get WSUS Server Object
$wsus = Get-WSUSServer
foreach ($wsusTargetGroup in $wsusTargetGroups) {
    $createGroup = $null
    $wsus.GetComputerTargetGroups() | foreach {
        $Group = $_.Name
        if ($Group -eq $wsusTargetGroup) {
            $createGroup = $true
            Write-Host "$($wsusTargetGroup) already created"
        }
    }
    if ($createGroup -ne $true) {
        $wsus.CreateComputerTargetGroup($wsusTargetGroup)
    }
}

# Connect to WSUS server configuration
$wsusConfig = $wsus.GetConfiguration()
 
# Set to download updates from Microsoft Updates
Set-WsusServerSynchronization -SyncFromMU
 
# Set Update Languages to English and save configuration settings
$wsusConfig.AllUpdateLanguagesEnabled = $false
$wsusConfig.SetEnabledUpdateLanguages("en")
$wsusConfig.Save()

$subscription = $wsus.GetSubscription()
$subscription.StartSynchronizationForCategoryOnly()
write-host 'Beginning first WSUS Sync to get available Products etc'
write-host 'Will take some time to complete'
While ($subscription.GetSynchronizationStatus() -ne 'NotProcessing') {
    Start-Sleep -Seconds 5
}
Write-Host "Sync is done."

if ($wsusConfigurationOnly -ne $true) {
    Get-WsusProduct  | Set-WsusProduct -Disable
    Start-Sleep 10
}
write-host 'Setting WSUS Products'
foreach ($wsusProduct in $wsusProducts) {
    Get-WsusProduct | where-Object {
        $_.Product.Title -in ($wsusProduct)
    } | Set-WsusProduct
}

write-host 'Setting WSUS Classifications'
foreach ($wsusClassification in $wsusClassifications) {
    Get-WsusClassification | Where-Object {
        $_.Classification.Title -in ($wsusClassification)
    } | Set-WsusClassification
}

#Set Use Group Policy for hosts
Write-Host "Set Use Group Policy for hosts"
$wsusConfig.TargetingMode = "Client"
$wsusConfig.Save()

#Disable Microsoft Update Improvment Program
Write-Verbose "Disable Microsoft Update Improvment Program"
$wsusConfig.MURollupOptin = $false
$wsusConfig.Save()

# Remove WSUS configuration pop-up when opening WSUS Management Console
Write-Verbose "Remove WSUS configuration pop-up when opening WSUS Management Console"
$wsusConfig.OobeInitialized = $true
$wsusConfig.Save()

write-host 'Starting WSUS Sync, will take some time'
$subscription.StartSynchronization()