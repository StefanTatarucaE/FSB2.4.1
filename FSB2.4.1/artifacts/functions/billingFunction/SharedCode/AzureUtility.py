## Import any modules needed specifically for the GCP utility here
import os
import requests
import logging

##Add all your needed imports here. All the imported items will have to be used by all the clouds as in future this has to work with all the module and all the clouds as common.
## This is required for the azure utility when using this for anything other than azure please comment this line
from azure.storage.blob import BlockBlobService

class AzureUtility(object):
    def __init__(self):
        self.storageAccount = self.getStorageAccountName()
        self.fitTable = os.environ["FITTable"]
        self.accountKey = self.getStorageAccountSecret()
        self.identityEndpoint = os.environ["IDENTITY_ENDPOINT"]
        self.identityHeader = os.environ["IDENTITY_HEADER"]
    
    ## This function will get the FIT data from the db table and the output should be in the form <class 'dict'> and status code
    def getFITData(self,customerName = None, serviceCategory=None):
        respJson = dict()
        statusCode = 400
        try:
            apiToken = self.getToken()
            if apiToken != "":
                headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer ' + apiToken, 'Accept' : 'application/json;odata=nometadata', 'x-ms-version': '2017-11-09'}
                
                urlFIT = f"https://{self.storageAccount}.table.core.windows.net/{self.fitTable}(PartitionKey='{customerName}',RowKey='{serviceCategory}')"

                self.writeLog(f'urlFIT : {urlFIT}', "Info")
                respRestFIT = requests.get(urlFIT, headers=headers,timeout=100)
                
                statusCode = respRestFIT.status_code

                if respRestFIT.status_code == 200 and respRestFIT.reason == "OK":
                    respRestFIT = respRestFIT.json()            

                respJson = respRestFIT
                
                if 'PartitionKey' in respJson:
                    del respJson['PartitionKey']
                if 'RowKey' in respJson:
                    del respJson['RowKey']
                if 'Timestamp' in respJson:
                    del respJson['Timestamp']
                if 'month' in respJson:
                    del respJson['month']
            else:
                statusCode = 400
                self.writeLog(f'apiToken is empty', "Error")
               

            return respJson, statusCode
        
        except Exception as error:
            self.writeLog(f'getFITData error : {error}', "Error")

        return respJson, statusCode
    
    def getStorageAccountName(self):
        accountname = ""
        accountdetails = os.environ["AzureWebJobsStorage"]
        try:
            accdet = accountdetails.split(";")
            accountnametemp = accdet[1].split("=")
            accountname = accountnametemp[1]
            self.writeLog(f"The storage account name is [{accountname}]","Info")
        except Exception as e:
            self.writeLog(f'The error at getStorageAccountName is {e}',"Error")

        return accountname
    
    def getStorageAccountSecret(self):
        accstrgkey = ""
        accountdetails = os.environ["AzureWebJobsStorage"]
        try:
            accdet = accountdetails.split(";")
            accstrgkeytemp = accdet[2].split("=")
            accstrgkey = accstrgkeytemp[1]
            if len(accstrgkeytemp) > 2:
                lenkey = len(accstrgkeytemp)
                for i in range(2,lenkey):
                    accstrgkey = accstrgkey + "="

        except Exception as e:
            self.writeLog(f'The error at getStorageAccountSecret is {e}',"Error")

        return accstrgkey
    
    ## This function will write the contents to the blob storage
    def writeToStorageAccount(self,containerName=None,fileName=None,output=None):
        isSuccess = True
        try:
            accountname = self.storageAccount
            accountKey = self.accountKey
            otpstr = str(output)
            blobService = BlockBlobService(account_name=accountname, account_key=accountKey)

            blnCont = blobService.create_container(containerName)
            blobService.create_blob_from_text(containerName, fileName, otpstr)

        except Exception as e:
            isSuccess = False
            self.writeLog(f'writeToBlobStorage error : {e}',"Error")

        return isSuccess
    
    ## This function will be used to add logs. This is present as the logging may be different per cloud.
    def writeLog(self, message, typeofLog = "Info"):
        if typeofLog == "Info":
            logging.info(message)
        elif typeofLog == "Debug":
            logging.debug(message)
        elif typeofLog ==  "Error":
            logging.error(message)
    
    ## This function will get the token for the REST API call
    def getToken(self):
        access_token = ""
        resource_uri = "https://storage.azure.com/" 
        try:
            token_auth_uri = f"{self.identityEndpoint}?resource={resource_uri}&api-version=2017-09-01"
            headers = {'Content-Type': 'application/json', 'secret': self.identityHeader,'Access-Control-Allow-Credentials': 'true','Access-Control-Allow-Origin': 'http://localhost:8081','Access-Control-Allow-Methods': 'GET','Access-Control-Request-Headers': 'X-Custom-Header'}
            
            try:
                resp = requests.get(token_auth_uri, headers=headers)
                resp.raise_for_status()
            except requests.exceptions.HTTPError as err:
                self.writeLog(f"getToken: The error while getting token {err}", "Error")
                return err


            access_token = resp.json()['access_token']
            
        except Exception as error:
            self.writeLog(f'getToken: error : {error}', "Error")

        return access_token
        
