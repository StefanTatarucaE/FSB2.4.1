Param(
    [parameter (Mandatory = $false)]
    [object] $WebhookData
)

function AbortIfAnotherInstanceAlreadyRunning {
    Param(
        [Parameter(Mandatory = $True)]
        [string]$JobID,

        [Parameter(Mandatory = $True)]
        [string]$VMName
    )

    # Get-AzAutomation account usage for easy tag based retrieval of automation account.
    $automationAccount = Get-AzAutomationAccount | Where-Object { $_.Tags[$tagName] -eq $tagValue }
    # Another get with Get-AzResource because Get-AzAutomationAccount does not retrieve the needed resourceId.
    $automationAccountId = Get-AzResource -Name $AutomationAccount.AutomationAccountName -ErrorAction SilentlyContinue
    $ThisJob = Get-AzAutomationJob -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $AutomationAccount.AutomationAccountName -Id $JobID -ErrorAction SilentlyContinue
    if (!([string]::IsNullOrEmpty($ThisJob))) {
        $RunbookName = $ThisJob.RunbookName
    }
    else {
        Throw("Job: " + $JobID + " not found in automation account: " + $automationAccount.AutomationAccountName)
    }
    $RunningConcurrentJobs = Get-AzAutomationJob -ResourceGroupName $automationAccount.ResourceGroupName -AutomationAccountName $automationAccount.AutomationAccountName -Name $RunbookName -Status "Running"
    foreach ($job in $RunningConcurrentJobs) {
        if ($job.JobId -ne $JobID) {
            $alreadyRunning = $false
            try {
                $Response = Invoke-AzureRestAPIDataRequest ($automationAccountId.id + "/Jobs/" + $job.JobId + "?api-version=2017-05-15-preview")
                $JobWebhookData = $Response.properties.parameters.webhookData | ConvertFrom-Json
                If ($JobWebhookData.RequestBody -like "*providers/Microsoft.Compute/virtualMachines/" + $VMName + "?*") {
                    $alreadyRunning = $true
                }
            }
            catch {
                Write-Error ("Cannot retrieve Job input for job ID " + $JobID) 
            }
            If ($alreadyRunning) {
                Throw ("Another instance of [" + $RunbookName + "] JobID [" + $job.JobId + "] for VM [" + $VMName + "] is already running, aborting !")                
            }
        }
    }
}

# Define branding variables needed for the Execute-VMEncryption runbook from the automation account variables
$company = Get-AutomationVariable -Name 'company'
$tagPrefix = Get-AutomationVariable -Name 'tagPrefix'
$tagValuePrefix = Get-AutomationVariable -Name 'tagValuePrefix'

# Tags & Tag Values used in the Execute-VMEncryption runbook.
$tagName = "$($tagPrefix)Purpose"
$tagValue = "$($tagValuePrefix)Automation"
$managedTagName = "$($tagPrefix)Managed"
$vmEncryptionTag = "$($tagPrefix)Encryption"
$laWorkspaceTag = "$($tagValuePrefix)Monitoring"
$diskEncryptionSetTag = "$($tagPrefix)DiskEncryption"

#Convert incoming webhook parameter data into usable data
$RequestBody = $WebhookData.RequestBody | ConvertFrom-Json
$Data = $RequestBody.data

#Check to see if the data action which triggered the script, is the correct one. if not break.
$IncomingDataAction = $Data.authorization.action
Write-Verbose "The incoming webhook data action is: $IncomingDataAction"

#region [Initialization Variables]----------------------------------------------------------------------------------------------------------
#Get resource group and vm name from webhook data
$Resources = $Data.resourceUri.Split('/')
$VMSubscriptionId = $Resources[2]
$VMName = $Resources[8]
$resourceid = $RequestBody.subject
$EventTime = $RequestBody.eventTime
$covert = [datetime]$EventTime
$convert = $covert.AddSeconds(-1800)
$EventTimeStart = $convert.ToString("yyyy-MM-dd'T'HH:mm:ss.fff'Z'")

# Connect to the management subscription
Write-Verbose "Connect to default subscription"

# Get connected
try {

    #Disable the Context inheritance from a previous session
    Disable-AzContextAutosave -Scope Process

    Write-Output "Logging into Azure with System-assigned Identity"
    $azConnect = Connect-AzAccount -Identity

    if (-not $azConnect) {
        Write-Error "Login error: Logging into azure Failed..." -ErrorAction 'Stop'
    }
    else {
        Write-Output "Successfully logged into the Azure Platform."
    }
}
catch {
    throw $_.Exception
}

# Search each customer subscription for the primary Log Analytics workspace (based on the special tag)
# This will also make the MGMT as default subscription after the call
$workspaceSearch = Search-customerManagementLogAnalyticsWorkspace -tagname $tagName -tagValue $laWorkspaceTag
$LogAnalyticsWorkspace = $workspaceSearch.LogAnalyticsWorkspace
$WorkspaceSharedKeys = $workspaceSearch.WorkspaceSharedKeys
Write-output "Using log Analytics workspace [$($LogAnalyticsWorkspace.Name)] ($($LogAnalyticsWorkspace.CustomerId))"

# Abort if another job is running
$JobID = $($PSPrivateMetadata.JobId.Guid)
AbortIfAnotherInstanceAlreadyRunning -JobID $JobID -VMName $VMName

$retry = 0
$maxRetry = 5
do {
    $VMcontext = Get-AzContext -ListAvailable | Where-Object { $_.Subscription -like $VMSubscriptionId }

    Write-Output ("Logging in to subscription " + $VMSubscriptionId)
    $vm = Get-AzVM -Name $VMName -DefaultProfile $VMcontext
    Start-Sleep 10
    $Retry += 1
    $Retry
} until ($vm -or ($retry -gt $maxRetry))

# Set the current date and time
$currentDateTime = Get-Date
$currentDateTimeString = $currentDateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
$currentDateTimeString

if ((Get-azresource -resourcetype Microsoft.compute/virtualmachines -name $vm.name -tag @{$managedTagName = "true" } -DefaultProfile $VMcontext ) -ne $Null) {
    Write-output "$($vm.name) is $($company) Managed"
    $Body = '
{
    "fetchPropertyChanges": true,
    "interval": {
      "end": "' + $currentDateTimeString + '",
      "start": "' + $EventTimeStart + '"
    },
    "resourceId": "' + $resourceid + '"
  }
'

    $params = @{
        APIurl    = "/providers/Microsoft.ResourceGraph/resourceChanges?api-version=2018-09-01-preview"
        APIMethod = "POST"
        BodyJSON  = $Body

    }
    $Response = Invoke-AzureRestAPIDataRequest @params

    $encryption = $null
    $tag = $null
    $aftervalue = $null

    foreach ($change in $Response.changes.propertyChanges) {
        $tag = $change.propertyName
        $aftervalue = $change.afterValue
        # Write-Output "tag is $($tag)"
        # Write-Output "after value is $($aftervalue)"
        if ($tag -eq "tags.$($vmEncryptionTag)" -and $aftervalue -eq "True") {
            Write-Output "tag is $($tag)"
            Write-Output "after value is $($aftervalue)"
            Write-Output "$($VMName) will be encrypted"
            $encryption = 'true'
        }
    }

    if (!$encryption) {
        Write-Output "No tag for Encryption set on VM $($VMName)"
    }
    else {
        #Select-AzSubscription -SubscriptionId $VMSubscriptionId | Out-Null
        $VMcontext = Get-AzContext -ListAvailable | Where-Object { $_.Subscription -like $VMSubscriptionId }

        $vm = Get-AzVM -Name $VMName -DefaultProfile $VMcontext
        $adestatus = $null
        $adestatus = Get-AzVMExtension -VMName $vm.Name -ResourceGroupName $vm.ResourceGroupName -DefaultProfile $VMcontext | Where-Object { $_.ExtensionType -match 'AzureDiskEncryption' }

        If ($adestatus) {
            Write-Output "$($vm.Name) has Azure Disk Encryption enabled"

            # Creating incident in ITSM because encryption is not enabled
            $params = @{
                AlertName        = "Virtual Machine cannot be enabled for disk encryption because ADE is already enabled"
                AlertDescription = "The Virtual Machine [" + $vm.Name + "] has Azure Disk Encryption (ADE) already enabled and cannot be enabled for Azure Storage Service Encryption (SSE)."
                AlertCategory    = "Virtual Machine - Disk Encryption"
                AlertSeverity    = "warning"
                AlertResourceId  = $vm.Id
                LogAnalyticsWorkspace  = $LogAnalyticsWorkspace
                WorkspaceSharedKeys    = $WorkspaceSharedKeys
            }
            Send-CustomAlertToLogAnalytics @params
        }
        else {

            ### check if VM has HostEncryption capability. If true check if Host needs encryption and enable it
            if ($vm.SecurityProfile.EncryptionAtHost -match 'True') {
                Write-Output "$($vm.Name) has Encryption At Host already enabled"
            }
            else {              
                if ((get-azvm -name $vm.name -Status -DefaultProfile $VMcontext).PowerState -ne 'VM deallocated') { 
                    $StartupAgain = $True
                    Write-output "$($vm.name) will be stopped"
                    Stop-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -DefaultProfile $VMcontext -Force -AsJob
                }
                # Wait about 3 minutes for VM to stop. If VM won't stop Update-AZVM is executed and will result in creation of incident in ITSM
                $I = 0
                while (((get-azvm -name $vm.name -Status -DefaultProfile $VMcontext).PowerState -ne 'VM deallocated') -and ($I -lt 36)) { 
                    $a = Get-Date
                    Write-Output "Waiting 5 seconds for $VMName to stop: $a"
                        
                    $state = (get-azvm -name $vm.name -Status -DefaultProfile $VMcontext).PowerState
                    Write-Output "State: $state"
                    start-sleep -s 5 
                    $I++
                }
                try {
                    Update-AzVM -VM $VM -ResourceGroupName $vm.ResourceGroupName -EncryptionAtHost $true -DefaultProfile $VMcontext -ErrorAction Stop
                    Write-Output "Encryption At Host for $($vm.Name) has been enabled"
                }
                catch {
                    Write-Output "Error is:"
                    $errmsg = $Error[0].ToString()
                    Write-Output $errmsg

                    # Creating incident in ITSM because encryption at host failed
                    $params = @{
                        AlertName        = "Virtual Machine cannot be enabled for host encryption"
                        AlertDescription = "The host encryption process failed on Virtual Machine [" + $vm.Name + "] with the following error: " + $errmsg
                        AlertCategory    = "Virtual Machine - Disk Encryption"
                        AlertSeverity    = "warning"
                        AlertResourceId  = $vm.Id
                        LogAnalyticsWorkspace  = $LogAnalyticsWorkspace
                        WorkspaceSharedKeys    = $WorkspaceSharedKeys                        
                    }
                    Send-CustomAlertToLogAnalytics @params
                }          
            }

            #get all disks from VM
            $alldisks = $null
            $alldisks = @($vm.StorageProfile.OsDisk.Name)
            if ($vm.StorageProfile.DataDisks.name) {
                $alldisks += @($vm.StorageProfile.DataDisks.name)
            }

            #get status of disk encryption for each disk and perform encryption
            $disk = $null
            $enset = $null            
            $enset = Get-AzDiskEncryptionSet -DefaultProfile $VMcontext | Where-Object { $_.Location -eq $vm.Location -and $_.Tags[$tagName] -eq $diskEncryptionSetTag }

            foreach ($diskname in $alldisks) {
                $disk = Get-AzDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $diskname -DefaultProfile $VMcontext
                Write-Output $disk.Encryption.DiskEncryptionSetId
                if (!$disk.Encryption.DiskEncryptionSetId) {
                    if ((get-azvm -name $vm.name -Status -DefaultProfile $VMcontext).PowerState -ne 'VM deallocated') {
                        $StartupAgain = $True 
                        Stop-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -DefaultProfile $VMcontext -Force -AsJob
                    }
                    # Wait about 3 minutes for VM to stop. If VM won't stop Update-AZVM is executed and will result in creation of incident in ITSM
                    $I = 0
                    while (((get-azvm -name $vm.name -Status -DefaultProfile $VMcontext).PowerState -ne 'VM deallocated') -and ($I -lt 36)) { 
                        $a = Get-Date
                        Write-Output "Waiting 5 seconds for $VMName to stop: $a"
                        
                        $state = (get-azvm -name $vm.name -Status -DefaultProfile $VMcontext).PowerState
                        Write-Output "State: $state"
                        start-sleep -s 5 
                        $I++
                    }
                    try {
                        New-AzDiskUpdateConfig -EncryptionType “EncryptionAtRestWithCustomerKey” -DiskEncryptionSetId $enset.Id -DefaultProfile $VMcontext | Update-AzDisk -ResourceGroupName $disk.ResourceGroupName -DiskName $disk.Name -DefaultProfile $VMcontext -ErrorAction Stop
                        Write-Output "$($disk.Name) was encrypted"
                    }
                    catch {
                        Write-Output "Error is:"
                        $errmsg = $Error[0].ToString()
                        Write-Output $errmsg

                        # Creating incident in ITSM because disk encryption failed
                        $params = @{
                            AlertName        = "Virtual Machine disk cannot be encrypted"
                            AlertDescription = "The disk [" + $disk.Name + "] of the Virtual Machine [" + $vm.Name + "] cannot be encrypted because of the following error: " + $errmsg
                            AlertCategory    = "Virtual Machine - Disk Encryption"
                            AlertSeverity    = "warning"
                            AlertResourceId  = $vm.Id
                            LogAnalyticsWorkspace  = $LogAnalyticsWorkspace
                            WorkspaceSharedKeys    = $WorkspaceSharedKeys
                        }
                        Send-CustomAlertToLogAnalytics @params
                    }
                }
            }
            if (((get-azvm -name $vm.name -Status -DefaultProfile $VMcontext).PowerState -ne 'VM Running') -and ($StartupAgain -eq $True)) { 
                Write-output "VM $($vm.name) will be started again"
                Start-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -DefaultProfile $VMcontext -AsJob
            }
            else {
                $state = (get-azvm -name $vm.name -Status).PowerState
                Write-Output "$($vm.name) State: $state"
            }
        } #finish else from ADE
    }
}
else {
    Write-Output "VM $($VMName) is not $($company) Managed"
}