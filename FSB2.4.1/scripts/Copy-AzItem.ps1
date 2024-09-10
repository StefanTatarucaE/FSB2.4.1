
function Copy-AzItem {
	<#
	.SYNOPSIS
		This function simplifies the process of uploading files to an Azure Storage Account Container.

	.DESCRIPTION
		The function uses the az storage azcopy cli extension, which will be installed automatically the first time if it is not available.

		Prerequisites are:
		- Az cli installed.
		- Logged into the Azure platform via az cli. az account set --subscription $subscriptionId

		A Storage Account Name and the Resourcegroup name where it is located need to be provided manually. 

		Dot source this file before being able to use the function in this file. 
        	To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
        	. .\Copy-AzItem.ps1

	.PARAMETER storageAccountName
		Specifies the name of the Azure Storage Account, where the Container is configured

	.PARAMETER resourceGroupName
		Specifies the resourcegroup name of the Azure Storage Account

	.PARAMETER containerName
		Specifies the name of the Container the file(s) will be copied to.

	.PARAMETER pathToUpload
		Specifies the local path of the file(s) to be uploaded to an Azure Storage Account Container.

	.PARAMETER tokenDuration
		Specifies the duration of the token in minutes. If no value is provided, the token duration defaults to 15 mins.

	.PARAMETER subFolder
		Optional. Specify subfolder where the files will be upload in the container

	.PARAMETER exclusions
		Optional. Specify files in source folder that should not be uploaded, like README.md or *.csv.


	.INPUTS
        	None.

	.OUTPUTS
        	None.

	.NOTES
		Version:        0.2
		Author:         frederic.trapet@eviden.com
		Creation Date:  20220707
		Purpose/Change: Modified to avoid using the get-azresource cmdlet that is not always reliable and can have delay

	.EXAMPLE
		Copy-AzItem -storageAccountName 'zzctsaartf6y53t57vt' -resourceGroupName "myresourcegroup" -containerName 'elz-artifacts' -pathToUpload './artifacts/reporting/*' -tokenDuration 60

		Copy-AzItem -storageAccountName 'zzctsaartf6y53t57vt' -resourceGroupName "myresourcegroup" -containerName 'customer-artifacts' -pathToUpload './test/files/*'

		Copy-AzItem -storageAccountName 'zzctsaartf6y53t57vt' -resourceGroupName "myresourcegroup" -containerName 'customer-artifacts' -pathToUpload './test/files/*' -subFolder 'myfolder' -exclusions 'README.md;*.csv'
	#>
	[CmdletBinding()]
	param
	(
		[Parameter(Position = 0, Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$storageAccountName,

		[Parameter(Position = 1, Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$resourceGroupName,

		[Parameter(Position = 2, Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$containerName,

		[Parameter(Position = 3, Mandatory, ValueFromPipelineByPropertyName)]
		[ValidateNotNullOrEmpty()]
		[string]$pathToUpload,

		[Parameter(Position = 4)]
		[int]$tokenDuration = 15,

		[Parameter(Position = 5)]
		[AllowNull()]
		[string] $subFolder,

		[Parameter(Position = 6)]
		[AllowNull()]
		[string] $exclusions
	)

	begin {
  		# Function to capture errors from az cli command
		  function Test-LastExitCode {
			if ( $LastExitCode -ne 0 ) {
				Write-Error "Operation failed with exit code $LastExitCode" -ErrorAction 'Stop'
			}
		}
		try {
			# Get the storage account resource with the parameters provided
			$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName
			Write-Verbose "Coping artificats over to storage container $containerName"

	  
			# Create a 15 mins during SAS token to the specified container, to use with az cli upload command.
			$startTime = Get-Date
			$endTime = $startTime.AddMinutes($tokenDuration)
			Write-Verbose "The sas token will be valid till $endTime"

			$sasTokenParams = @{
				Context    = $storageAccount.Context
				Name       = $containerName
				Permission = 'rdwl'
				ExpiryTime = $endTime
			}
			$sasToken = New-AzStorageContainerSASToken @sasTokenParams
			# On Windows, SAS token causes errors due to & character. When enclosed with double quote characters this is resolved.
			$token = $IsWindows ? "`"$sasToken`"" : $sasToken
			Write-Verbose "The sas token is $token"
		}
		catch {
			Write-Error "Failed trying to find the correct storage account or creating a SAS token. $($_.Exception.Message)" -ErrorAction 'Stop'
		}

		# Installing azcopy as an extension with prompting the user
		az config set extension.use_dynamic_install=yes_without_prompt

	}

	process {
		if (Test-Path -Path $pathToUpload) {

			# double the slash in the path to make it work on Linux pipeline
			$pathToUpload = $pathToUpload.replace('/', '//')

			Write-Verbose ("Uploading file from path : " + $pathToUpload)

			# Executing az cli command to upload the folders & files to Azure Storage Account Container
			az storage copy `
			 --source "${pathToUpload}" `
			 --destination "https://$($storageAccount.StorageAccountName).blob.core.windows.net/${containerName}$( ($subFolder) ? "/${subFolder}" : '')" `
			 --recursive `
			 --exclude-pattern "$( ($exclusions) ? "${exclusions}" : '/')" `
			 --sas-token "$token"

			# See if the az cli command ran without errors, if not write an error to pwsh session
			Test-LastExitCode
		}

		else {
			Write-Error "Failed to validate the path to upload to the storage container $($_.Exception.Message)" -ErrorAction 'Stop'
		}
	}

	end {
		# intentionally empty
	}
}
