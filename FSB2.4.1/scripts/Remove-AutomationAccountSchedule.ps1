<#
.SYNOPSIS
    To delete the schedules in automation account before they are deployed via bicep. Here there will be option to delete all or just OSMGMT and PAASMGMT
.DESCRIPTION
    This script will do the following
    1. It will delete all the non OSmgmt and PaasMgmt schedules.
    2. It will delete all the OSMGMT schedules
    3. It will delete the PAASMGMT schedules      
    The code can independently run to delete all schedules or only the OSMGMT or PAASMGMT. If the operations team wants to only update the OS or PaaS schedules in future then they have the flexibility. If all have to be done simaltaneously then all the parameter i.e. removeAllSchedulesExceptOsPaas,removeOsMgmtSchedules and removePaasMgmtSchedules have to be set true. If only anyone of them have to be done than the particular parameter will have to be marked as true and other false.
.PARAMETER $azAutomationAccount
    Specifies the automation account in which we want to delete the schedules.
.PARAMETER $azAutomationAccountResourceGroup
    Specifies the automation account resource group in which we want to delete the schedules.
.PARAMETER $removeAllSchedulesExceptOsPaas
    This parameter will check if we need to delete all the schedules except OSMGMT and PAASMGMT.   
.PARAMETER $removeOsMgmtSchedules
    This parameter will check if we need to delete the OSMGMT Schedules.
.PARAMETER $removePaasMgmtSchedules
    This parameter will check if we need to delete the PAASMGMT Schedules.        

.NOTES
    Author:      Alkesh Naik
    Company:     Eviden
    Email:       alkesh.naik@eviden.com
    Updated:     8 July 2022
    Version:     0.1
.EXAMPLE
     Remove-AutomationAccountSchedule -azAutomationAccount $azAutomationAccount -azAutomationAccountResourceGroup $azAutomationAccountResourceGroup -removeAllSchedulesExceptOsPaas -removeOsMgmtSchedules -removePaasMgmtSchedules
#>

function Remove-AutomationAccountSchedule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string] $azAutomationAccount,
        [Parameter(Mandatory = $True)]
        [string] $azAutomationAccountResourceGroup,     
        [Parameter(Mandatory = $False)]
        [switch] $removeAllSchedulesExceptOsPaas,
        [Parameter(Mandatory = $False)]
        [switch] $removeOsMgmtSchedules,
        [Parameter(Mandatory = $False)]
        [switch] $removePaasMgmtSchedules
    )

    begin {
        $resourceGroup = Get-AzResourceGroup -Name $azAutomationAccountResourceGroup
        if (-not $resourceGroup) {
            Write-Error $('Resourcegroup: ' + $azAutomationAccountResourceGroup + ' not found.') -ErrorAction 'Stop'
        }

        $automationAccount = Get-AzAutomationAccount -ResourceGroupName $azAutomationAccountResourceGroup -AutomationAccountName $azAutomationAccount
        if (-not $automationAccount) {
            Write-Error $('Automationaccount: ' + $azAutomationAccount + ' not found.') -ErrorAction 'Stop'
        }
    }

    Process {
        
        #Deleting all the schedule(only if it needs to be deleted) so that new can be added when the automation bicep runs.
        if ($removeAllSchedulesExceptOsPaas.IsPresent) {        
            try {            

                # Remove any existing schedule to avoid clashes with new deployed ones        
                Get-AzAutomationSchedule -ResourceGroupName $azAutomationAccountResourceGroup -AutomationAccountName $azAutomationAccount |  Where-Object { $_.Name -notlike 'OSMGMT-*' -and $_.Name -notlike 'PAASMGMT-*' } | Remove-AzAutomationSchedule -Force
                Write-Verbose "All the schedules, except OSMGMT and PAASMGMT schedules, have been deleted for the automation account : $azAutomationAccount"        

            }
            catch {
                Write-Error "There was an error while procesing deletion of all schedules for automation account : $azAutomationAccount with error message $($_.Exception.Message)" -ErrorAction 'Stop'
            }
        }

        #Deleting the OSMGMT schedule so that new can be added when the automation bicep runs.
        if ($removeOsMgmtSchedules.IsPresent) {
            try {
                # Remove any existing OSMGMT schedule to avoid clashes with new deployed ones            
                Get-AzAutomationSchedule -ResourceGroupName $azAutomationAccountResourceGroup -AutomationAccountName $azAutomationAccount | Where-Object { $_.Name -like 'OSMGMT-*' } | Remove-AzAutomationSchedule -Force
                Write-Verbose "The OSMGMT schedules have been deleted for the automation account : $azAutomationAccount"

            }
            catch {
                Write-Error "There was an error while procesing deletion of OSMGMT schedules for automation account : $automationAccount with error message $($_.Exception.Message)" -ErrorAction 'Stop'
            }
        }

        #Deleting the PAASMgmt schedule so that new can be added when the automation bicep runs.
        if ($removePaasMgmtSchedules.IsPresent) {
            try {
                # Remove any existing PAAS schedule to avoid clashes with new deployed ones            
                Get-AzAutomationSchedule -ResourceGroupName $azAutomationAccountResourceGroup -AutomationAccountName $azAutomationAccount | Where-Object { $_.Name -like 'PAASMGMT-*' } | Remove-AzAutomationSchedule -Force
                Write-Verbose "The PAASMGMT schedules have been deleted for the automation account : $azAutomationAccount"

            }
            catch {
                Write-Error "There was an error while procesing deletion of PAASMGMT schedules  for automation account : $automationAccount with error message $($_.Exception.Message)" -ErrorAction 'Stop'
            }
        }
    }
    end {
        # intentionally empty 
    }
}
