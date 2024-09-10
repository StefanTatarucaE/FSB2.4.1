import requests
import json
import datetime
import time
import logging
import pandas as pd
import io
import os
from io import StringIO

import azure.functions as func

from ..SharedCode import common
from datetime import timedelta

LogErrorOutput = ""
LogInfoOutput = ""
LogEnableDebug = False
VMData = dict()
CSVData = dict()
CSVHeader = dict()
ResourceIDs = dict()

def writeLog(txtInfo):
    global LogInfoOutput
    logging.info(txtInfo)
    LogInfoOutput += txtInfo+"\n"

def writeLogDebug(txtInfo):
    global LogInfoOutput
    if LogEnableDebug:
        logging.info("DEBUG: "+txtInfo)
        LogInfoOutput += txtInfo+"\n"

def writeLogError(txtError):
    global LogErrorOutput
    logging.error(txtError)
    LogErrorOutput += txtError+"\n"

def abortFunctionWithError(txtError):
    writeLogError(txtError)
    raise Exception(txtError)

def setCSVFileHeaderRow(billingItemCode, headerRow):
    global CSVHeader
    billingItemCode = billingItemCode.upper()
    CSVHeader[billingItemCode] = headerRow

def storeCSVDataForSubscription(billingItemCode, dataRow):
    global CSVData
    billingItemCode = billingItemCode.upper()
    # init array the first time
    if billingItemCode not in CSVData:
        CSVData[billingItemCode] = []
    # add CSV data row
    CSVData[billingItemCode].append(dataRow)

def createAndUploadCSVFiles(customerCode, datestart_str, dateend_str,dateFIT):
    global CSVData,CSVHeader
    skipGoogleUpload = True
    utc_timestamp = datetime.datetime.utcnow()-timedelta(days=1)


    if not BillingCustomerCode:
        writeLogError(f"The Billing customer name is no configured ! skipping Google upload part")
        skipGoogleUpload = True        
    # else:
    #     if not common.getGoogleBucketConfiguration():
    #         writeLogError(f"The Google bucket configuration could not be retrieved from the Keyvault! skipping Google upload part")
    #         skipGoogleUpload = True
    #     else:
    #         skipGoogleUpload = False

    for billingItemCode in CSVHeader.keys():

        #debug
        # if billingItemCode not in ["AZU-COST","AZU-OS"]:
        #     continue

        customerStr = customerCode.upper()
        customerStr = customerStr.replace("_","-")
        customerStr = customerStr.replace(" ","-")
        customerStr = customerStr.replace("/","")
        customerStr = customerStr.replace("$","")

        if billingItemCode.startswith('AZU-COST') or billingItemCode.startswith('AZU-OS'):
            customerStr = customerStr +"-"+billingItemCode.split(':')[1]
            displayBillingCode = billingItemCode.split(':')[0]
        else:
            displayBillingCode = billingItemCode

        CountryCode = common.getBillingCountryCode()        
        productCode = common.getProductCode()
        if "SVC" in displayBillingCode:
            if billingItemCode not in CSVData:
                CSVData[billingItemCode] = []
            dateonfile = utc_timestamp.strftime("%Y%m%d")
            nenamingtime = utc_timestamp.strftime("%H%M%S")

            # if ((datestart_str != None) and (dateend_str != None)):
            #     datestart_str = datestart_str.replace("-","")
            #     dateend_str = dateend_str.replace("-","")
            #     filename = f"DATA_ELZ_AZU_{customerStr}_{CountryCode}_GLB_ELZ_{displayBillingCode}_MSB-AZURE-FUNCTION_{datestart_str}_to_{dateend_str}"
            # else:
            #     filename = f"DATA_ELZ_AZU_{customerStr}_{CountryCode}_GLB_ELZ_{displayBillingCode}_MSB-AZURE-FUNCTION_{dateonfile}_{nenamingtime}"

            #writeLog(f"Generating CSV file [{filename}.csv]")
            df = pd.DataFrame (CSVData[billingItemCode] , columns = CSVHeader[billingItemCode])
            CSVoutput = df.to_csv(index=False,encoding = "utf-8")

            #upload to azure
            #common.writeToBlobStorage("billing-output-fit",f"{filename}.csv",CSVoutput)

            ###This part will take the SVC file and aggregate the values
            
            csvStringIO = StringIO(CSVoutput)
            csvStringPandaOutput = pd.read_csv(csvStringIO, sep=",", header=0)
            subidColumn = csvStringPandaOutput.columns[0]
            serviceCategaoryColumn = csvStringPandaOutput.columns[2]
            costColumn = csvStringPandaOutput.columns[3]
            writeLog(f"Now aggregating the csv with column {serviceCategaoryColumn} and {costColumn} ")
            aggregatedCSV = csvStringPandaOutput.groupby(serviceCategaoryColumn)[costColumn].sum().reset_index()

            ##Adding the month and year to the aggregated csv            
            fitPeriodColumnValue = [dateFIT] * len(aggregatedCSV)
            aggregatedCSV = aggregatedCSV.assign(FIT_PERIOD=fitPeriodColumnValue)

            ##Adding the customer name to the aggregated csv
            customerNameColumnValue = [common.CustomerName] * len(aggregatedCSV)
            aggregatedCSV = aggregatedCSV.assign(CustomerName=customerNameColumnValue)

            CSVoutputAgregated = aggregatedCSV.to_csv(index=False,encoding = "utf-8")
            filename = f"AZURE_{productCode}_AGGREGATED_FOR_FIT_{common.CustomerName}_{dateonfile}_{nenamingtime}"
            writeLog(f"The filename of the csv is {filename} ")
            
            writeLog(f"Uploading files to Azure storage account")
            common.writeToBlobStorage("newbilling",f"{filename}.csv",CSVoutputAgregated)
        else:
            writeLog(f"The displayBillingCode of the csv is {displayBillingCode} ")

        if common.getLastErrorMessage():
            abortFunctionWithError(common.getLastErrorMessage())

        #upload to google
        # if not skipGoogleUpload and (displayBillingCode in ["AZU-COST","AZU-OS"]) :
        #     writeLog(f"Uploading files to Google account")
        #     ctrstr = f"<?xml version=\"1.0\"?><collector><source version=\"1.0\" name=\"DCS_{displayBillingCode}\"/></collector>"
        #     UploadStatus = common.uploadToGoogle(f"{filename}.csv",CSVoutput)
        #     if UploadStatus['success']:
        #         writeLog(UploadStatus['message'])
        #     else:
        #         abortFunctionWithError(UploadStatus['message'])
        #     UploadStatus = common.uploadToGoogle(f"{filename.replace('DATA_','CTRL_')}.xml",ctrstr)
        #     if UploadStatus['success']:
        #         writeLog(UploadStatus['message'])
        #     else:
        #         abortFunctionWithError(UploadStatus['message'])

def searchResourceInSubscription(subid, resourceTypeFilter, resourceTagFilter):
    resourceIdList = []
    url = f"https://management.azure.com/subscriptions/{subid}/resources?$filter=resourceType eq '{resourceTypeFilter}'&api-version=2019-09-01"
    resourceList = common.callREST(url,apiToken,LogEnableDebug)
    if 'value' in resourceList:
        if len(resourceList['value']) >0:
            for resource in resourceList['value']:
                if 'tags' in resource:
                    resourceTags = dict((k.lower(), v) for k, v in resource['tags'].items())
                    if resourceTagFilter['TagName'].lower() in resourceTags:
                        valtag = resourceTags[resourceTagFilter['TagName'].lower()]
                        if (valtag.lower() == resourceTagFilter['TagValue'].lower()) or (resourceTagFilter['TagValue'] == "*"):
                            resourceIdList.append(resource["id"].lower())
    return resourceIdList

def searchResourceInAllSubscriptions(resourceTypeFilter, resourceTagFilter):
    resourceIdList = []
    resp = common.callREST(f"https://management.azure.com/subscriptions?api-version=2020-01-01",apiToken,LogEnableDebug)
    if 'value' in resp:
        if len(resp['value']) >0:
            for subs in resp['value']:
                subResourceList = searchResourceInSubscription(
                    subs['subscriptionId'], 
                    resourceTypeFilter, 
                    resourceTagFilter)
                if (len(subResourceList) > 0):
                    resourceIdList += subResourceList
    return resourceIdList

def retrievePatchSchedules():
    UpdateSchedules = []
    maintenanceConfigItems = searchResourceInAllSubscriptions(
        "Microsoft.Maintenance/maintenanceConfigurations", 
        common.getApplicationConfigJSON("MAINTENANCE_CONFIG_TAG")
    )
    if (len(maintenanceConfigItems) == 0):
        writeLogError(f"No Maintenance Configuration items found ! skipping UPDATE part")
    else:
        for maintenanceConfigItem in maintenanceConfigItems:
            writeLog(f"Found Maintenance Configuration item [{maintenanceConfigItem.split('/')[8]}] used for update management schedule")
            UpdateSchedules.append(maintenanceConfigItem.split('/')[8])
    return UpdateSchedules

def processBillingForAZUCost(customerCode, subid, billingCode, currencyCode):
    setCSVFileHeaderRow(
        billingCode, 
        [
            "Customer",
            "SubscriptionId",
            "Service",
            "Region",
            "ServiceType",
            "UnblendedCost",
            "Currency",
            "InstanceID"
        ]
    )
    for resourceId, meterNames in ResourceIDs.items():
        for meterName, data in meterNames.items():
            writeLogDebug(f"[{billingCode}] Resource [{resourceId}] Meter [{meterName}] cost [{data['costcurr']:.2f}]")
            SplitResourceId = resourceId.replace("/subscriptions/"+subid+"/providers/","")
            SplitResourceId = SplitResourceId.replace("/subscriptions/"+subid+"/resourceGroups/","")
            SplitResourceId = SplitResourceId.replace("/subscriptions/"+subid+"/resourcegroups/","")
            SplitResourceId = SplitResourceId.replace("/subscriptions/"+subid+"/","")
            storeCSVDataForSubscription(
                billingCode,
                [
                    customerCode,
                    subid,
                    meterName,
                    data['location'],
                    data['svccategory'],
                    formatNumber(data['costcurr']),
                    currencyCode,
                    SplitResourceId
                ]
            )        

def processBillingForVM(customerCode, subid, billingCode, currencyCode):
    setCSVFileHeaderRow(
        billingCode, 
        [
            "Customer",
            "SubscriptionId",
            "InstanceID",
            "InstanceName",
            "OS",
            "UnblendedCost",
            "Currency"
        ]        
    )    
    for resourceId, data in VMData.items():
        if "windows" in data['osversion'].lower():
            osname = "Windows"
        elif data['osversion'] != "Unknown":
            osname = "Linux"
        else:
            osname = "Unknown"
        writeLogDebug(f"[{billingCode}] Resource [{data['name']}] OS [{osname}] cost [{data['costcurr']:.2f}]")
        SplitResourceId = resourceId.replace("/subscriptions/"+subid+"/providers/","")
        SplitResourceId = SplitResourceId.replace("/subscriptions/"+subid+"/resourceGroups/","")
        SplitResourceId = SplitResourceId.replace("/subscriptions/"+subid+"/resourcegroups/","")
        SplitResourceId = SplitResourceId.replace("/subscriptions/"+subid+"/","")
        storeCSVDataForSubscription(
            billingCode,
            [
                customerCode,
                subid,
                SplitResourceId,
                data['name'],
                osname,
                formatNumber(data['costcurr']),
                currencyCode
            ]
        )  

def processBillingForResourceType(customerCode, subid, billingCode, resourceTypeFilter, resourceTagFilter, headerRow, TagValueArray = None):
    setCSVFileHeaderRow(billingCode, headerRow)
    writeLog(f"Calling REST API for subscription [{subid}] resource type [{resourceTypeFilter}]")
    url = f"https://management.azure.com/subscriptions/{subid}/resources?$filter=resourceType eq '{resourceTypeFilter}'&api-version=2019-09-01"
    resourceList = common.callREST(url,apiToken,LogEnableDebug)
    if 'value' in resourceList:
        if len(resourceList['value']) >0:
            for resource in resourceList['value']:
                resourceName = resource['name']
                resourceId = resource["id"]
                resourceGroupName = resource["id"].split("/")[4]

                if (resourceTagFilter and resourceTagFilter['TagName'] != "" and resourceTagFilter['TagValue'] != ""):
                    if resourceTagFilter['TagValue'] == "*":
                        tagDisplayVal = f"{resourceTagFilter['TagName']}:<any value>"
                    else:
                        tagDisplayVal = f"{resourceTagFilter['TagName']}:{resourceTagFilter['TagValue']}"
                    tagFound = False
                    if 'tags' in resource:
                        resourceTags = dict((k.lower(), v) for k, v in resource['tags'].items())
                        if resourceTagFilter['TagName'].lower() in resourceTags:
                            valtag = resourceTags[resourceTagFilter['TagName'].lower()]
                            if not TagValueArray and type(TagValueArray).__name__ != 'list':
                                if (valtag.lower() == resourceTagFilter['TagValue'].lower()) or (resourceTagFilter['TagValue'] == "*"):
                                    tagFound = True
                            else:
                                if (valtag.lower() in TagValueArray):
                                    tagDisplayVal = f"{resourceTagFilter['TagName']}:{valtag}"
                                    tagFound = True                                

                    if not tagFound:
                        #writeLogDebug(f"[{billingCode}] SKIP resource [{resourceId}] because tag is invalid")
                        continue
                else:
                    tagDisplayVal = "n/a"

                writeLogDebug(f"[{billingCode}] Service [{resourceTypeFilter}] Resource [{resourceGroupName}\{resourceName}]")

                storeCSVDataForSubscription(
                    billingCode,
                    [subid,resourceGroupName,resourceName,tagDisplayVal]
                )

                # if billingCode == "SPOKES":
                #     storeCSVDataForSubscription(
                #         "AZU-COST:"+subid,
                #         [
                #             customerCode,
                #             subid,
                #             "Spoke",
                #             "NoRegion",
                #             "Spoke",
                #             1,
                #             "",
                #             "Spoke"
                #         ]
                #     )                    

def processBillingForCustomPolicies(subid, billingCode, resourceTypeFilter, resourceTagFilter, headerRow):
    setCSVFileHeaderRow(billingCode, headerRow)    
    writeLog(f"Calling REST API for subscription [{subid}] resource type [{resourceTypeFilter}]")
    url = f"https://management.azure.com/subscriptions/{subid}/providers/Microsoft.Authorization/policyDefinitions?$filter=policyType eq 'Custom'&api-version=2020-09-01"
    resourceList = common.callREST(url,apiToken,LogEnableDebug)
    if 'value' in resourceList:
        if len(resourceList['value']) >0:
            for resource in resourceList['value']:
                if 'properties' in resource:
                    prop = resource['properties']
                    policyName = prop['displayName']
                    if (resourceTagFilter and resourceTagFilter['TagName'] != "" and resourceTagFilter['TagValue'] != ""):
                        tagFound = False
                        if 'metadata' in prop:
                            resourceTags = dict((k.lower(), v) for k, v in prop['metadata'].items())
                            if resourceTagFilter['TagName'].lower() in resourceTags:
                                valtag = resourceTags[resourceTagFilter['TagName'].lower()]
                                if (valtag.lower() == resourceTagFilter['TagValue'].lower()) or (resourceTagFilter['TagValue'] == "*"):
                                    tagFound = True
                        if not tagFound:
                            #writeLogDebug(f"[{billingCode}] SKIP resource [{policyName}] because tag is invalid")
                            continue
                                        
                    writeLogDebug(f"[{billingCode}] Service [{resourceTypeFilter}] Resource [{policyName}]")

                    storeCSVDataForSubscription(
                        billingCode,
                        [subid,policyName]
                    )

def processBillingForVMBackup(subid, billingCode, VMresourceTagFilter, RVresourceTagFilter, headerRow):
    setCSVFileHeaderRow(billingCode, headerRow)
    VMWithBackupTagsList = searchResourceInSubscription(
        subid, 
        "Microsoft.Compute/virtualMachines", 
        VMresourceTagFilter)
    DCSRecoveryVaultsList = searchResourceInSubscription(
        subid, 
        "Microsoft.RecoveryServices/vaults", 
        RVresourceTagFilter)
    if (len(DCSRecoveryVaultsList) > 0):
        for DCSRecoveryVault in DCSRecoveryVaultsList:
            resp = common.callREST("https://management.azure.com"+DCSRecoveryVault+"/backupProtectedItems?api-version=2021-02-10",apiToken,LogEnableDebug)
            if 'value' in resp:
                if len(resp['value']) >0:
                    for backupItems in resp['value']:
                        vaultName = backupItems['id'].split("/")[8]
                        prop = backupItems['properties']
                        if (prop['workloadType'] == "VM"):
                            VMResourceId = prop['virtualMachineId']
                            backupPolicyName = prop['policyName']
                            if (VMResourceId.lower() in VMWithBackupTagsList):
                                VMName = prop['virtualMachineId'].split("/")[8]
                                VMresourceGroupName = prop['virtualMachineId'].split("/")[4]
                                tagDisplayVal = f"{tagPrefix}Backup:{backupPolicyName}"
                                writeLogDebug(f"[{billingCode}] Resource [{VMresourceGroupName}\{VMName}] Vault [{vaultName}] Backup policy [{backupPolicyName}]")

                                storeCSVDataForSubscription(
                                    billingCode,
                                    [subid,VMresourceGroupName,VMName,vaultName,backupPolicyName,tagDisplayVal]
                                )

                            else:
                                writeLogDebug(f"[{billingCode}] SKIP resource [{VMResourceId}]")
                                continue
    else:
        writeLogError(f"No ELZ recovery vaults found in subscription [{subid}]")

def getServiceCategory(serviceType):
    getServiceCategory = None
    if len(serviceSplitData) > 0:
        for serviceEntry in serviceSplitData[0]:
            #writeLogError(f"No ELZ recovery vaults found in subscription [{serviceEntry}]")
            ServiceCategoryName = serviceEntry['ServiceCategoryName']
            Providers = serviceEntry['Providers']
            if serviceType.lower() in (item.lower() for item in Providers):
                getServiceCategory = ServiceCategoryName
    return getServiceCategory

def formatNumber(floatNum):
    numValue = round(floatNum,6)
    strValue = f"{numValue:.6f}"
    return strValue

def validateDateTimeFormat(date_text):
    isCorrectFormat = True
    try:
        datetime_object = datetime.datetime.strptime(date_text, '%Y-%m-%d')
    except ValueError:
        isCorrectFormat = False
    return isCorrectFormat
    
def main(mytimer: func.TimerRequest,errorOutput: func.Out[str],infoOutput: func.Out[str]) -> None:
   
    ##
    ## MAIN SCRIPT
    ##

    if mytimer.past_due:
        writeLog('The timer is past due!')

    writeLog("Billing function started")

    # Declaring variables
    global LogEnableDebug, VMData, ResourceIDs, apiToken, serviceSplitData, BillingCustomerCode, tagPrefix
    if (("LOG_LEVEL" in os.environ) and (os.environ["LOG_LEVEL"] == "DEBUG")):
        LogEnableDebug = True
    utc_timestamp = datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc).isoformat()    
    todayDay = datetime.datetime.utcnow().day
    timeScriptStart = time.time()
    
    writeLog(f"the time frame is {common.timeFrame}")
    
    BillingCustomerCode = common.getBillingCustomerNameConfiguration()
    if not BillingCustomerCode:
        writeLogError(f"The Billing customer name could not be retrieved from the Keyvault, using default value")
        customerCode = "cus"
    else:
        customerCode = BillingCustomerCode

    tagPrefix = common.getCompanyTagPrefix()

    dtstart = None
    dtend = None
    fitDate = None

    if common.timeFrame != "" and common.timeFrame == "Daily":

        utc_timestamp = datetime.datetime.utcnow()-timedelta(days=1)
        yesterdayDate = utc_timestamp.strftime("%Y-%m-%d")
        fitDate = utc_timestamp.strftime("%Y%m")
        dtstart = str(yesterdayDate)+"T00:00:00Z"
        dtstart2 = str(yesterdayDate)
        dtend = str(yesterdayDate)+"T23:59:00Z"
        dtend2 = str(yesterdayDate)
    elif common.timeFrame != "" and common.timeFrame == "Month":
        fromDateTemp = datetime.datetime.today().replace(day=1) - timedelta(days=1)
        fromDateLastMonth = fromDateTemp.replace(day=1)
        fitDate = fromDateLastMonth.strftime("%Y%m")
        yesterdayDate = fromDateLastMonth.strftime("%Y-%m-%d")
        dtstart = str(yesterdayDate)+"T00:00:00Z"

        toDateTemp = datetime.datetime.today().replace(day=1) - timedelta(days=1)
        endOfMonth = toDateTemp.strftime('%Y-%m-%d')
        dtend = str(endOfMonth)+"T23:59:00Z"
    elif common.timeFrame != "" and "timePeriod" in common.timeFrame:
            jsonObjTimeFrame = json.loads(common.timeFrame)
            writeLog(f"the from date is {jsonObjTimeFrame['timePeriod']['from']}")
            dtstartJson = jsonObjTimeFrame['timePeriod']['from']
            ddtEndJson = jsonObjTimeFrame['timePeriod']['to']
            
            isStartDateCorrect = validateDateTimeFormat(dtstartJson)
            isEndDateCorrect = validateDateTimeFormat(ddtEndJson)

            if isStartDateCorrect and isEndDateCorrect:
                datetime_object = datetime.datetime.strptime(dtstartJson, '%Y-%m-%d')
                dttime = datetime_object.strftime("%Y-%m-%d")
                fitDate = datetime_object.strftime("%Y%m")
                dtstart = str(dttime)+"T00:00:00Z"

                datetime_object = datetime.datetime.strptime(ddtEndJson, '%Y-%m-%d')
                dttime = datetime_object.strftime("%Y-%m-%d")
                dtend = str(dttime)+"T23:59:00Z"
            else:
                dtstart = None
                dtend = None                    
                writeLog(f"The date format is not correct, please use the format YYYY-MM-DD")




    writeLog(f"The billing period is from [{dtstart}] to [{dtend}] and fitDate {fitDate} the timeframe is {common.timeFrame}")

    if (("BILLING_DAY_PERIOD_START" in os.environ) and ("BILLING_DAY_PERIOD_END" in os.environ)):
            datestart_str = os.environ["BILLING_DAY_PERIOD_START"]
            dateend_str = os.environ["BILLING_DAY_PERIOD_END"]
    else:
        datestart_str = None
        dateend_str = None

    
    serviceSplitData = common.getApplicationConfigJSON("SERVICES_SPLIT_DATA")
    serviceProviderManagedTag = common.getApplicationConfigJSON("VM_COMPL_TAG")
    VirtualMachineOSVersionTag = common.getApplicationConfigJSON("VM_OSVERSION_TAG")

    # Get the token from the managed identity
    if ("_LOCAL_DEV_MGMT_TOKEN" in os.environ):
        apiToken = os.environ["_LOCAL_DEV_MGMT_TOKEN"]
        utc_timestamp_local_test = datetime.datetime.utcnow()-timedelta(days=15)
        yesterdayDate = utc_timestamp_local_test.strftime("%Y-%m-%d")
        dtstart = str(yesterdayDate)+"T00:00:00Z"
        dtstart2 = str(yesterdayDate)
    else:
        apiToken = common.getTokenFromManage('https://management.azure.com/')

    # Search for the ELZ unique Automation account in CUST MGMT and retrieve the update schedules
    UpdateSchedules = retrievePatchSchedules()

    ##
    ## Customer subscriptions MAIN LOOP
    ##

    if dtstart != None and dtend != None:
        resp = common.callREST(f"https://management.azure.com/subscriptions?api-version=2020-01-01",apiToken,LogEnableDebug)
        if 'statuscode' not in resp:
            if 'value' in resp:
                if len(resp['value']) >0:
                    for subs in resp['value']:

                        subid = subs['subscriptionId']
                        subname = subs['displayName']
                        currencyCode = ""
                        VMData = dict()
                        ResourceIDs = dict()
                        ServiceCost = dict()
                        SubsTotalCost = 0

                        writeLog(f"Connecting to subscription [{subname}] ({subid})")

                        ##
                        ## SUBSCRIPTIONS COST
                        ##

                        
                        billingAPIurl = f"https://management.azure.com/subscriptions/{subid}/providers/Microsoft.Consumption/usageDetails?api-version=2019-10-01&startDate={dtstart}&endDate={dtend}&metric=actualcost&$expand=meterDetails"

                        while (billingAPIurl != None):
                            writeLog(f"Calling REST API for Usage detail for subscription [{subid}]")  
                            writeLog(f"The billingAPIurl is [{billingAPIurl}]")          

                            usagedetails = common.callREST(billingAPIurl,apiToken,LogEnableDebug)

                            writeLog(f"The usagedetails response is [{usagedetails}]")  

                            # handle paging in API answer
                            if 'nextLink' in usagedetails:
                                billingAPIurl = usagedetails['nextLink']
                            else:
                                billingAPIurl = None

                            # process billing resource item
                            if 'value' in usagedetails:
                                if len(usagedetails['value']) >0:
                                    for val in usagedetails['value']:
                                        if 'properties' in val:

                                            # Retrieve properties from billing entry
                                            apikind = val['kind']
                                            prop = val['properties']
                                            meterid = prop['meterId']
                                            serviceType = prop['consumedService'].lower().replace("microsoft.","").capitalize()
                                            resourceLocation = prop['resourceLocation']     
                                            resourceUsageDate = prop['date'].replace("T00:00:00Z","").replace("T00:00:00.0000000Z","")                               
                                            if apikind == "modern":
                                                meterName = prop['meterName']
                                                resourceId = prop['instanceName'].lower()
                                                currencyCode = prop['billingCurrencyCode']
                                                #currencyCostProperty = 'paygCostInBillingCurrency'
                                                currencyCostProperty = 'costInBillingCurrency'
                                            else:
                                                meterDetails = prop['meterDetails']
                                                if 'meterName' in meterDetails:
                                                    meterName = meterDetails['meterName']
                                                else:
                                                    meterName = "n/a"
                                                resourceId = prop['resourceId'].lower()
                                                currencyCode = prop['billingCurrency']
                                                currencyCostProperty = 'cost'
                                            if len(resourceId.split("/")) >= 4: 
                                                resourceGroupName = resourceId.split("/")[4]
                                            else:
                                                resourceGroupName = "n/a"
                                            if len(resourceId.split("/")) >= 8: 
                                                resourceName = resourceId.split("/")[8]
                                                resourceType = resourceId.split("/")[6]+"/"+resourceId.split("/")[7]
                                            else:
                                                resourceName = ""
                                                resourceType = prop['consumedService']
                                        
                                            # Calculate the cost for this resource
                                            valueRate = 0
                                            billingCurrencyFix = ""
                                            if (("BillingCurrencyFix" in os.environ)):
                                                billingCurrencyFix = os.environ["BillingCurrencyFix"]
                                                
                                            if currencyCostProperty in prop:
                                                valueRate = prop[currencyCostProperty]
                                                writeLogDebug(f"[SUBS] Old Value rate [{valueRate}]")
                                                writeLogDebug(f"[SUBS] billingCurrencyFix [{billingCurrencyFix}]")
                                                if billingCurrencyFix == "Yes":
                                                    writeLogDebug(f"We are in the new Logic")
                                                    exchangeRate = float(prop["exchangeRate"])
                                                    quantity = float(prop["quantity"])
                                                    unitPrice = float(prop["unitPrice"])
                                                    writeLogDebug(f"[SUBS] exchangeRate [{exchangeRate}] quantity [{quantity}] unitPrice [{unitPrice}] ]")
                                                    valueRate = exchangeRate*quantity*unitPrice
                                                    writeLogDebug(f"[SUBS] valueRate [{valueRate}]")
                                                    
                                                SubsTotalCost += valueRate
                                                writeLogDebug(f"[SUBS] Service [{serviceType}] Resource [{resourceGroupName}\\{resourceName}] Meter [{meterName}] Cost [{valueRate:.2f} {currencyCode}] TotalCost [{SubsTotalCost:.2f}]")
                                            else:
                                                writeLogError(f"ERROR: COST not found for Service [{serviceType}] Resource [{resourceGroupName}\\{resourceName}] !")

                                            if 'pricingModel' in prop:
                                                pricingModelValue = prop['pricingModel']
                                            else:
                                                pricingModelValue = "n/a"

                                            # Check if managed TAG is present
                                            managedTag = "No"
                                            managedTagValue = "n/a"                                    
                                            if 'tags' in val and val['tags']!=None:
                                                resourceTags = dict((k.lower(), v) for k, v in val['tags'].items())
                                                if serviceProviderManagedTag['TagName'].lower() in resourceTags:
                                                    valtag = resourceTags[serviceProviderManagedTag['TagName'].lower()]
                                                    if ((valtag.lower() == serviceProviderManagedTag['TagValue'].lower()) or (valtag.lower().startswith(tagPrefix.lower()))):
                                                        managedTag = "YES"
                                                        managedTagValue = valtag
                                            else:
                                                resourceTags = None

                                            # For managed VMs, store information and cost per resourceID for later use
                                            if resourceType.lower() == "microsoft.compute/virtualmachines":
                                                if managedTag == "YES":
                                                    if VirtualMachineOSVersionTag['TagName'].lower() in resourceTags:
                                                        osVersion = resourceTags[VirtualMachineOSVersionTag['TagName'].lower()]
                                                    else:
                                                        osVersion = "Unknown"
                                                    if resourceId not in VMData:
                                                        VMData[resourceId] = {
                                                            'costcurr': valueRate,
                                                            'osversion': osVersion,
                                                            'name': resourceName
                                                            }
                                                    else:
                                                        VMData[resourceId]['costcurr'] += valueRate
                                                        if osVersion != "Unknown":
                                                            VMData[resourceId]['osversion'] = osVersion

                                            # Check if the resource if part of a service category and the managed TAG is present, if yes then store cost
                                            if LogEnableDebug:
                                                logging.info(f"The point of error is [{prop['consumedService']}]")
                                            svcCategory = getServiceCategory(prop['consumedService'])
                                            if (svcCategory) and (managedTag == "YES"):
                                                if svcCategory not in ServiceCost:
                                                    ServiceCost[svcCategory] = 0
                                                ServiceCost[svcCategory] += valueRate
                                                #writeLogDebug(f"[SVC-{svcCategory}] Adding cost [{valueRate:.2f}] - TotalCost [{ServiceCost[svcCategory]:.2f}]")
                                            else:
                                                svcCategory = "None"

                                            # For AZU-COST, store information and cost per resourceID/Metername for later use
                                            if managedTag == "YES":
                                                if resourceId not in ResourceIDs:
                                                    ResourceIDs[resourceId] = dict()
                                                else:
                                                    if meterName not in ResourceIDs[resourceId]:
                                                        ResourceIDs[resourceId][meterName] = {
                                                                'costcurr': valueRate,
                                                                'location': resourceLocation,
                                                                'svccategory': svcCategory.replace("+","")
                                                                }
                                                    else:
                                                        ResourceIDs[resourceId][meterName]['costcurr'] += valueRate

                                            # Add resource to global list CSV
                                            setCSVFileHeaderRow(
                                                "ALL", 
                                                [
                                                    "Subscription Id",
                                                    "Subscription Name",
                                                    "Service Category",
                                                    "Resource Type",
                                                    "Resource Name",
                                                    "Resource Group",
                                                    "Resource Location",                                                
                                                    "Managed TAG (Y/N)",
                                                    "Managed TAG Value",
                                                    "Meter Name",
                                                    "Cost ("+currencyCode+")",
                                                    "Pricing Model",
                                                    "Resource ID"
                                                ]
                                            )
                                            storeCSVDataForSubscription(
                                                "ALL",
                                                [
                                                    subid,
                                                    subname,
                                                    svcCategory,
                                                    resourceType.lower(),                                                    
                                                    resourceName,
                                                    resourceGroupName,
                                                    resourceLocation,
                                                    managedTag,
                                                    managedTagValue,
                                                    meterName,
                                                    formatNumber(valueRate),
                                                    pricingModelValue,
                                                    resourceId
                                                ]
                                            )      

                        # Add subscription total cost to CSV
                        setCSVFileHeaderRow("SUBS", ["Subscription Id","Subscription Name","Cost ("+currencyCode+")"])
                        storeCSVDataForSubscription(
                            "SUBS",
                            [subid,subname,formatNumber(SubsTotalCost)]
                        )
                        writeLogDebug(f"[SUBS] Total cost for subscription is [{formatNumber(SubsTotalCost)} {currencyCode}]")

                        # Add services category total cost to CSV
                        if len(serviceSplitData) > 0 :
                            for serviceEntry in serviceSplitData[0]:
                                ServiceCategoryName = serviceEntry['ServiceCategoryName']
                                if ServiceCategoryName not in ServiceCost:
                                    ServiceCost[ServiceCategoryName] = 0
                                SvcTotalCost = formatNumber(ServiceCost[ServiceCategoryName])
                                setCSVFileHeaderRow("SVC", ["Subscription Id","Subscription Name","Service Category","Cost ("+currencyCode+")"])                            
                                storeCSVDataForSubscription(
                                    "SVC",
                                    [subid,subname,ServiceCategoryName,SvcTotalCost]
                                )
                                writeLogDebug(f"[SVC] Total cost for Service [{ServiceCategoryName}] for subscription is [{SvcTotalCost} {currencyCode}]")

                        ##
                        ## AZU-COST (CloudDB)
                        ##

                        processBillingForAZUCost(
                            customerCode,
                            subid,
                            "AZU-COST:"+subid,
                            currencyCode
                        )

                        # ##
                        # ## ELZ SPOKES VNET
                        # ##

                        processBillingForResourceType(
                            customerCode,
                            subid,
                            "SPOKES",
                            "Microsoft.Network/virtualNetworks",
                            common.getApplicationConfigJSON("VNET_SPOKES_TAG"),
                            ["Subscription Id","Resource Group Name", "Spoke VNET Name", "Tag"]
                        )

                        ##
                        ## ELZ IMAGE GALLERY
                        ##

                        processBillingForResourceType(
                            customerCode,
                            subid,
                            "IMAGE_GALLERY",
                            "Microsoft.Compute/galleries",
                            common.getApplicationConfigJSON("IMG_GALLERY_TAG"),
                            ["Subscription Id","Resource Group Name", "Shared Image Gallery Name", "Tag"]
                        )

                        ##
                        ## ELZ POLICY DEFINITIONS
                        ##

                        processBillingForCustomPolicies(
                            subid,
                            "CUSTOM_POLICIES",
                            "Microsoft.Authorization/policyDefinitions",
                            common.getApplicationConfigJSON("CUSTOM_POLICIES_METADATA"),
                            ["Subscription Id","Policy Definition Name"]
                        )                            

                        ##
                        ## VM COMPLIANT TAG (CloudDB)
                        ##

                        processBillingForVM(
                            customerCode,
                            subid,
                            "AZU-OS:"+subid,
                            currencyCode
                        )

                        ##
                        ## VM PATCH TAG
                        ##

                        processBillingForResourceType(
                            customerCode,
                            subid,
                            "INST_VM_PATCH_TAG",
                            "Microsoft.Compute/virtualMachines",
                            common.getApplicationConfigJSON("VM_PATCH_TAG"),
                            ["Subscription Id","Resource Group Name", "VM Name", "Tag"],
                            UpdateSchedules
                        )
                        
                        ##
                        ## VM BACKUP TAG
                        ##

                        processBillingForVMBackup(
                            subid,
                            "INST_VM_BACKUP_TAG",
                            common.getApplicationConfigJSON("VM_BACKUP_TAG"),
                            common.getApplicationConfigJSON("RECOVERY_VAULT_TAG"),
                            ["Subscription Id","Resource Group Name", "VM Name", "Recovery Vault Name", "Backup Policy", "Tag"]
                        )

                        storeCSVDataForSubscription(
                            "AZU-COST:"+subid,
                            [customerCode,subid,"Heartbeat","NoRegion","Heartbeat","0","USD","Heartbeat"]
                        )
                        storeCSVDataForSubscription(
                            "AZU-OS:"+subid,
                            [customerCode,subid,"Heartbeat","Heartbeat","Heartbeat",0,"USD"]
                        )  
                # Generate all CSV files and upload them
                createAndUploadCSVFiles(customerCode,datestart_str,dateend_str,fitDate)
    else:
        writeLogError(f"The billing period is from [{dtstart}] to [{dtend}] and the timeframe is {common.timeFrame}")

    # Finish function
    timeScriptEnd = time.time()
    timeScripTotal = (timeScriptEnd - timeScriptStart)
    writeLog(f"Billing function completed. Elapsed time {round(timeScripTotal,1)} sec")
    errorOutput.set(LogErrorOutput)
    infoOutput.set(LogInfoOutput)
    logging.info('Python timer trigger function ran at %s ', utc_timestamp)
