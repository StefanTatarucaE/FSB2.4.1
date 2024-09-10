<#
.SYNOPSIS
    This runbook is called durint the Automatic Testing pipeline and is responsible to deploy some resources before the tests

.DESCRIPTION
    This runbook will deply some resources needed for the tests.
#>

param(
    [Parameter(Mandatory = $True)]
    [string] $adminPassword,

    [Parameter(Mandatory = $True)]
    [string] $buildRepositoryLocalPath,

    [Parameter(Mandatory = $True)]
    [string] $customerCode,
    
    [Parameter(Mandatory = $True)]
    [string] $deployLocation,

    [Parameter(Mandatory = $True)]
    [string] $tenantId,

    [Parameter(Mandatory = $True)]
    [string] $custMgmtSubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $custCntySubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $custLndzSubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $custLndz2SubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $snowEnv,

    [Parameter(Mandatory = $True)]
    [string] $snowFo,

    [Parameter(Mandatory = $True)]
    [string] $tagPrefix,

    [Parameter(Mandatory = $True)]
    [string] $tagValuePrefix,

    [Parameter(Mandatory = $True)]
    [string] $company,

    [Parameter(Mandatory = $True)]
    [string] $product,

    [Parameter(Mandatory = $True)]
    [string] $productCode

)

###
### INIT
###

$ProjectRoot = $buildRepositoryLocalPath
$BicepModulesRoot = $buildRepositoryLocalPath + "/childModules"
If ((-Not($tenantId)) -or (-Not($custMgmtSubscriptionId)) -or (-Not($custLndzSubscriptionId)) -or (-Not($custLndz2SubscriptionId))) {
    Throw("Error missing variable parameter in pipeline !")
}


Import-Module Pester
$modulePath = $ProjectRoot + '/tests/Eviden.AzureIntegrationTesting/Eviden.AzureIntegrationTesting.psm1'
Import-Module -Name $modulePath  -Force
#Import-Module -Name .\Eviden.AzureIntegrationTesting -Force

$requiredModules = @("Az.CosmosDB", "Az.PostgreSql", "Az.MySql", "Az.MariaDb")
foreach ($module in $requiredModules) {
    if (-not (Get-Module -Name $module)) {
        Install-Module -Name $module -Force
        Write-Host "Module $module Installed."
    }    
}

###
### SCRIPT
###

$date = Get-Date -Format "ddMMyyyy"

# Default credentials for databases and VM's
$adminUsr = "admintest1"

# Default name prefix for resources
$textInfo = (Get-Culture).TextInfo
$namePrefix = $textInfo.ToTitleCase($customerCode.ToLower().SubString(0,3)) + "Test"

# 
# Deploying Windows and Linux VMs
# 

$ResourceGroupName = ($customerCode.ToLower() + "-lndz-d-rsg-integration-testing")
$ResourceGroupName2 = ($customerCode.ToLower() + "-lndz2-d-rsg-integration-testing")
$Location = $deployLocation
$TemplateFilePath = $BicepModulesRoot + "\virtualMachine\virtualMachine.bicep"

Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId

# Retrieving Back Spoke Subnet SubnetID for VM deployment
$SubnetId = (Get-AzVirtualnetwork | Get-AzVirtualNetworkSubnetConfig | Where-Object { $_.Name -like '*back*' }).Id
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force -Tag @{"${tagPrefix}Testing" = "true"}

write-verbose "Using Subnet in $($subNetId)"

Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId 
# Retrieving Back Spoke Subnet SubnetID for VM deployment
$SubnetId2 = (Get-AzVirtualnetwork | Get-AzVirtualNetworkSubnetConfig | Where-Object { $_.Name -like '*back*' }).Id

write-verbose "Using Subnet in $($subNetId)"

New-AzResourceGroup -Name $ResourceGroupName2 -Location $Location -Force -Tag @{"${tagPrefix}Testing" = "true"}

$DeploymentParameters = @{
    # Parameter Block for Windows VM in LND1
    deployment1 = @{
        computerName             = $namePrefix + 'VM1-Win'
        adminUsername            = $adminUsr
        adminPassword            = $adminPassword
        vmSize                   = 'Standard_DS1_v2'
        dataDiskSizeGB           = 1023
        osDiskStorageAccountType = 'StandardSSD_LRS'
        subnetId                 = $SubnetId
        publicIpName             = $namePrefix + 'VM1-Win-pip'
        deployPublicIp           = $false
        publicIPAllocationMethod = 'Dynamic'
        publicIpSku              = 'Basic'
        domainNameLabel          = $namePrefix.ToLower() + 'vm1win'
        nicName                  = $namePrefix.ToLower() + 'VM1-Win-nicName'
        imageReference           = @{
            'publisher' = 'MicrosoftWindowsServer'
            'offer'     = 'WindowsServer'
            'sku'       = '2019-Datacenter'
            'version'   = 'latest'
        }
        tags                     = @{
            "${tagPrefix}Antimalware" = 'true'
            "${tagPrefix}Managed"  = 'true'
            "${tagPrefix}Backup"   = 'Bronze-Enhanced'
            "${tagPrefix}Patching" = 'Windows-Dev'
            "${tagPrefix}Testing" = 'winvm01'
        }
    }
    # Parameter Block for Linux VM
    deployment2 = @{
        computerName             = $namePrefix + 'VM1-Lin'
        adminUsername            = $adminUsr
        adminPassword            = $adminPassword
        vmSize                   = 'Standard_DS1_v2'
        dataDiskSizeGB           = 1023
        osDiskStorageAccountType = 'StandardSSD_LRS'
        subnetId                 = $SubnetId
        publicIpName             = $namePrefix + 'VM1-Lin'
        deployPublicIp           = $false
        publicIPAllocationMethod = 'Dynamic'
        publicIpSku              = 'Basic'
        domainNameLabel          = $namePrefix.ToLower() + 'vm1lin'
        nicName                  = $namePrefix.ToLower() + 'VM1-Lin-nicName'
        imageReference           = @{
            'publisher' = 'Canonical'
            'offer'     = 'UbuntuServer'
            'sku'       = '18.04-LTS'
            'version'   = 'latest'
        }
        tags                     = @{
            "${tagPrefix}Managed"  = 'true'
            "${tagPrefix}Backup"   = 'Bronze-Enhanced'
            "${tagPrefix}Patching" = 'Linux-Dev'
            "${tagPrefix}Testing" = 'linvm01'
        }
    }
    # Parameter Block for Windows VM in LND2
    deployment3 = @{
        computerName             = $namePrefix + 'VM2-Win'
        adminUsername            = $adminUsr
        adminPassword            = $adminPassword
        vmSize                   = 'Standard_DS1_v2'
        dataDiskSizeGB           = 1023
        osDiskStorageAccountType = 'StandardSSD_LRS'
        subnetId                 = $SubnetId2
        publicIpName             = $namePrefix + 'VM2-Win-pip'
        deployPublicIp           = $false
        publicIPAllocationMethod = 'Dynamic'
        publicIpSku              = 'Basic'
        domainNameLabel          = $namePrefix.ToLower() + 'vm2win'
        nicName                  = $namePrefix.ToLower() + 'VM2-Win-nicName'
        imageReference           = @{
            'publisher' = 'MicrosoftWindowsServer'
            'offer'     = 'WindowsServer'
            'sku'       = '2019-Datacenter'
            'version'   = 'latest'
        }
        tags                     = @{
            "${tagPrefix}ntimalware" = 'true'
            "${tagPrefix}Managed"  = 'true'
            "${tagPrefix}Backup"   = 'Bronze-Enhanced'
            "${tagPrefix}Patching" = 'Windows-Dev'
            "${tagPrefix}Testing" = 'winvm02'
        }
    }
}

Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
New-AzResourceGroupDeployment -Name vmdeploymentWin -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFilePath -TemplateParameterObject $DeploymentParameters.deployment1 -Verbose
New-AzResourceGroupDeployment -Name vmdeploymentlin -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFilePath -TemplateParameterObject $DeploymentParameters.deployment2

Set-AzContext -Subscription $custLndz2SubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
New-AzResourceGroupDeployment -Name vmdeploymentWin2 -ResourceGroupName $ResourceGroupName2 -TemplateFile $TemplateFilePath -TemplateParameterObject $DeploymentParameters.deployment3 -Verbose


# Deploying Storage Account for Diagnosticrule test


$TemplateFilePathstorage = $BicepModulesRoot + "\storageAccount\storageAccount.bicep"
Set-AzContext -Subscription $custLndzSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null

# Using customer code as a prefix for the storage account to have the highest chance of uniqueness

$storageaccountname = $namePrefix.ToLower() + "storage" + $date

# Parameter Block for Storage Account

$storagedeployment = @{

    storageAccountName           = $storageaccountname
    sku                          = 'Standard_LRS'
    containerNames               = @(
        @{containerName='test1';containerAcccess='None'},
        @{containerName='test2';containerAcccess='None'}
    )
    shouldCreateContainers       = $false
    tags                 = @{
        "${tagPrefix}Testing" = 'storageacc01' 
    }
    kind                         = 'StorageV2'
    #containerAccess              = 'None'
    location                     = $Location
    accesstier                   = 'Hot'
    allowBlobPublicAccess        = $false
    allowSharedKeyAccess         = $true
    isHnsEnabled                 = $false
    networkAcls                  = @{
        bypass        = 'AzureServices, Logging, Metrics'
        defaultAction = 'Deny'
        ipRules = @(
            @{action='Allow';value='84.106.218.12'},
            @{action='Allow';value='147.161.183.00'}
        )
    }
    changeFeed                   = @{
        "enabled"         = $true
        "retentionInDays" = 7
    }
    shouldCreateShares           = $true
    shareNames                   = "testshare01", "testshare02"
    fileShareQuota               = 100
    shouldCreateQueues           = $true
    queueNames                   = "testqueue01", "testqueue02"
    shouldCreateTables           = $true
    tableNames                   = "testtable01", "testtable02"
    blobSvcDeleteRetentionPolicy = @{
        enabled = $true
        days    = 7
    }
}

#Storage Account Deployment
New-AzResourceGroupDeployment -Name storagedeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFilePathStorage -TemplateParameterObject $storagedeployment -Verbose

############################################## 
# Deploying additional resources (not BICEP) #
##############################################

###
### SQL SRV + DB
###

$defaultCred = New-Object System.Management.Automation.PSCredential($adminUsr,(ConvertTo-SecureString $adminPassword -AsPlainText -Force))
If (-Not (Get-AzSqlServer -ResourceGroupName $ResourceGroupName -ServerName ($namePrefix.ToLower() + "sqlsrv01") -ErrorAction SilentlyContinue)) {
    $Params = @{
        ResourceGroupName                   = $ResourceGroupName
        ServerName                          = $namePrefix.ToLower() + "sqlsrv01" + $date
        Location                            = $deployLocation 
        ServerVersion                       = "12.0"
        SqlAdministratorCredentials         = $defaultCred
        tag                                 = @{
            "${tagPrefix}Managed"  = 'true'
            "${tagPrefix}Testing" = 'sqlsrv01'
        }
    }
    $sqlsrv = New-AzSqlServer @params -ErrorAction SilentlyContinue
}
If (-Not (Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName ($namePrefix.ToLower() +"sqlsrv01") -DatabaseName ($namePrefix.ToLower() +"sqldb01") -ErrorAction SilentlyContinue)) {
    $Params = @{
        ResourceGroupName                   = $ResourceGroupName
        ServerName                          = $namePrefix.ToLower() + "sqlsrv01" + $date
        DatabaseName                        = $namePrefix.ToLower() + "sqldb01" + $date
        tag                                 = @{
            "${tagPrefix}Managed"  = 'true'
            "${tagPrefix}Testing" = 'sqldb01'
        }
    }
    $sqldb = New-AzSqlDatabase @params -ErrorAction SilentlyContinue
}

###
### COSMOS DB
###

$Params = @{
    ResourceGroupName                   = $ResourceGroupName
    Name                                = $namePrefix.ToLower() + "cosmos01" + $date
    Location                            = $deployLocation
    DisableKeyBasedMetadataWriteAccess  = $true
    tag                                 = @{
        "${tagPrefix}Managed"  = 'true'
        "${tagPrefix}Testing" = 'cosmosdb01'
    }
}
$Cosmos = New-AzCosmosDBAccount @params -ErrorAction SilentlyContinue

###
### POSTGRE-SQL
###

$Params = @{
    Name                            = $namePrefix + "PostgreDb01" + $date
    ResourceGroupName               = $ResourceGroupName
    Location                        = $deployLocation
    Sku                             = 'GP_Gen5_4'
    AdministratorUserName           = $adminUsr
    AdministratorLoginPassword      = (ConvertTo-SecureString -String $adminPassword -AsPlainText -Force)
    tag                             = @{
        "${tagPrefix}Managed"  = 'true'
        "${tagPrefix}Testing" = 'postgredb01'
    }
}
$posgredb = New-AzPostgreSqlServer @params -ErrorAction SilentlyContinue

###
### MY-SQL
###

$Params = @{
    Name                            = $namePrefix + "MysqlDb01" + $date
    ResourceGroupName               = $ResourceGroupName
    Location                        = $deployLocation
    Sku                             = 'GP_Gen5_4'
    AdministratorUser               = $adminUsr
    AdministratorLoginPassword      = (ConvertTo-SecureString -String $adminPassword -AsPlainText -Force)
    tag                             = @{
        "${tagPrefix}Managed"  = 'true'
        "${tagPrefix}Testing" = 'mysqldb01'
    }
}
$mysqldb = New-AzMySqlServer @params -ErrorAction SilentlyContinue

###
### MARIA-DB
###

$Params = @{
    Name                            = $namePrefix + "MariaDb01" + $date
    ResourceGroupName               = $ResourceGroupName
    Location                        = $deployLocation
    Sku                             = 'B_Gen5_1'
    AdministratorUsername           = $adminUsr
    AdministratorLoginPassword      = (ConvertTo-SecureString -String $adminPassword -AsPlainText -Force)
    tag                             = @{
        "${tagPrefix}Managed"  = 'true'
        "${tagPrefix}Testing" = 'mariadb01'
    }
}
$dbmaria = New-AzMariaDbServer @params -ErrorAction SilentlyContinue

###
### REDIS CACHE
###

$Params = @{
    ResourceGroupName               = $ResourceGroupName
    Name                            = $namePrefix + "Redis01" + $date
    Location                        = $deployLocation 
    tag                             = @{
        "${tagPrefix}Managed"  = 'true'
        "${tagPrefix}Testing" = 'rediscache01'
    }
}
$RedisCache = New-AzRedisCache @params -ErrorAction SilentlyContinue

###
### APP GATEWAY
###

$TagParams = @{
    PublicIpTag = @{
        "${tagPrefix}Managed" = 'true'
        "${tagPrefix}Testing" = 'PublicIpAppGateway01'
    }
    VnetTag = @{
        "${tagPrefix}Managed"  = 'true'
        "${tagPrefix}Testing" = 'VNet01'
    }
}

$Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24
$VNet = New-AzVirtualNetwork -Name "VNet01" -ResourceGroupName $ResourceGroupName -Location $deployLocation -AddressPrefix 10.0.0.0/16 -Subnet $Subnet -Tag $TagParams.VnetTag -Force
$VNet = Get-AzVirtualNetwork -Name "VNet01" -ResourceGroupName $ResourceGroupName
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name "Subnet01" -VirtualNetwork $VNet 
$GatewayIPconfig = New-AzApplicationGatewayIPConfiguration -Name "GatewayIp01" -Subnet $Subnet
$Pool = New-AzApplicationGatewayBackendAddressPool -Name "Pool01" -BackendIPAddresses 10.10.10.1, 10.10.10.2, 10.10.10.3
$PoolSetting = New-AzApplicationGatewayBackendHttpSetting -Name "PoolSetting01"  -Port 80 -Protocol "Http" -CookieBasedAffinity "Disabled"
$FrontEndPort = New-AzApplicationGatewayFrontendPort -Name "FrontEndPort01"  -Port 80
$PublicIp = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name "PublicIpAppGateway01" -Location $deployLocation -AllocationMethod "Static" -Tag $TagParams.PublicIpTag -Force -Sku "Standard"
$FrontEndIpConfig = New-AzApplicationGatewayFrontendIPConfig -Name "FrontEndConfig01" -PublicIPAddress $PublicIp
$Listener = New-AzApplicationGatewayHttpListener -Name "ListenerName01"  -Protocol "Http" -FrontendIpConfiguration $FrontEndIpConfig -FrontendPort $FrontEndPort
$Rule = New-AzApplicationGatewayRequestRoutingRule -Name "Rule01" -RuleType basic -BackendHttpSettings $PoolSetting -HttpListener $Listener -BackendAddressPool $Pool -priority "1"
$Sku = New-AzApplicationGatewaySku -Name "Standard_v2" -Tier Standard_v2 -Capacity 2
$Params = @{
    Name                            = $namePrefix + "AppGateway01"
    ResourceGroupName               = $ResourceGroupName
    Location                        = $deployLocation
    BackendAddressPools             = $Pool
    BackendHttpSettingsCollection   = $PoolSetting
    FrontendIpConfigurations        = $FrontEndIpConfig
    GatewayIpConfigurations         = $GatewayIpConfig
    FrontendPorts                   = $FrontEndPort
    HttpListeners                   = $Listener
    RequestRoutingRules             = $Rule
    force                           = $true
    Sku                             = $Sku
    tag                             = @{
        "${tagPrefix}Managed"  = 'true'
        "${tagPrefix}Testing" = 'appgateway01'
    }
}
$Gateway = New-AzApplicationGateway @params

###
### LOAD BALANCER
###
$PublicIpLoadBalancerTag = @{
    "${tagPrefix}Managed"  = 'true'
    "${tagPrefix}Testing" = 'PublicIpLoadBalancer01'
}
$publicip = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name "PublicIpLoadBalancer01" -Location $deployLocation -AllocationMethod "Dynamic" -Tag $PublicIpLoadBalancerTag -Force
$frontend = New-AzLoadBalancerFrontendIpConfig -Name "MyFrontEnd" -PublicIpAddress $publicip
$backendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name "MyBackendAddPoolConfig02"
$probe = New-AzLoadBalancerProbeConfig -Name "MyProbe" -Protocol "http" -Port 80 -IntervalInSeconds 15 -ProbeCount 2 -RequestPath "healthcheck.aspx"
$inboundNatRule1 = New-AzLoadBalancerInboundNatRuleConfig -Name "MyinboundNatRule1" -FrontendIPConfiguration $frontend -Protocol "Tcp" -FrontendPort 3389 -BackendPort 3389 -IdleTimeoutInMinutes 15 -EnableFloatingIP
$inboundNatRule2 = New-AzLoadBalancerInboundNatRuleConfig -Name "MyinboundNatRule2" -FrontendIPConfiguration $frontend -Protocol "Tcp" -FrontendPort 3391 -BackendPort 3392
$lbrule = New-AzLoadBalancerRuleConfig -Name "MyLBruleName" -FrontendIPConfiguration $frontend -BackendAddressPool $backendAddressPool -Probe $probe -Protocol "Tcp" -FrontendPort 80 -BackendPort 80 -IdleTimeoutInMinutes 15 -EnableFloatingIP -LoadDistribution SourceIP
$Params = @{
    Name                            = $namePrefix + "LoadBalancer01" + $date
    ResourceGroupName               = $ResourceGroupName
    Location                        = $deployLocation
    FrontendIpConfiguration         = $frontend
    BackendAddressPool              = $backendAddressPool
    Probe                           = $probe
    InboundNatRule                  = $inboundNatRule1,$inboundNatRule2
    LoadBalancingRule               = $lbrule    
    force                           = $true
    tag                             = @{
        "${tagPrefix}Managed"  = 'true'
        "${tagPrefix}Testing" = 'loadbalancer01'
    }
}
$lb = New-AzLoadBalancer @params

###
### APP SERVICE PLAN + APP SERVICE
###

$Params = @{
    Name                = $namePrefix + "AppSvcPlan" + $date
    Location            = $deployLocation
    ResourceGroupName   = $ResourceGroupName
    Tier                = "Free"
    tag                     = @{
        "${tagPrefix}Managed"  = 'true'
        "${tagPrefix}Testing" = 'appsvcplan01'
    }
}
New-AzAppServicePlan @params | Out-Null

$Params = @{
    Name                = $namePrefix + "AppSvc" + $date
    Location            = $deployLocation
    AppServicePlan      = $namePrefix + "AppSvcPlan"
    ResourceGroupName   = $ResourceGroupName
}
$resource = New-AzWebApp @params -ErrorAction SilentlyContinue
If ($resource.Id) {
    $tags = @{
        "${tagPrefix}Managed"  = 'true'
        "${tagPrefix}Testing" = 'appsvc01'
    }
    Update-AzTag -ResourceId $resource.Id -Tag $tags -Operation Merge -ErrorAction SilentlyContinue
}


