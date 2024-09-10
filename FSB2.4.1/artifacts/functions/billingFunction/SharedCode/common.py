import datetime
import logging
import os
import json
import time
import requests
import hashlib
import hmac
import base64

import azure.functions as func
from azure.storage.blob import BlockBlobService
from azure.storage.file import FileService

from google.cloud import storage
from google.oauth2 import service_account

identity_endpoint = os.environ["IDENTITY_ENDPOINT"]
identity_header = os.environ["IDENTITY_HEADER"]
accountdetails = os.environ["AzureWebJobsStorage"]
billingCountryCode = os.environ["BillingCountryCode"]
companyTagPrefix = os.environ["COMPANY_TAG_PREFIX"]
productCode = os.environ["PRODUCT_CODE"]
CustomerName = os.environ["CustomerName"]
FITTable = os.environ["FITTable"]
timeFrame = os.environ["TimeFrame"] if (("TimeFrame" in os.environ) and (os.environ["TimeFrame"] != "")) else ""
GoogleBucketName = None
GoogleBucketKey = None
LastErrorMessage = ""

def getCompanyTagPrefix():
    return companyTagPrefix

def getBillingCountryCode():
    return billingCountryCode

def getProductCode():
    return productCode

def getLastErrorMessage():
    return LastErrorMessage

def getProductCode():
    return productCode


def getApplicationConfigJSON(varName):
    try:
        varValue = json.loads(os.environ[varName])
    except Exception as e:
        varValue = ""
    return varValue

def getStorageAccountName():
    accountname = ""
    try:
        accdet = accountdetails.split(";")
        accountnametemp = accdet[1].split("=")
        accountname = accountnametemp[1]
        logging.info(f"The storage account name is [{accountname}]")
    except Exception as e:
        logging.error(f'The error at getStorageAccountName is {e}')

    return accountname

def getStorageAccountSecret():
    accstrgkey = ""
    try:
        accdet = accountdetails.split(";")
        accstrgkeytemp = accdet[2].split("=")
        accstrgkey = accstrgkeytemp[1]
        if len(accstrgkeytemp) > 2:
            lenkey = len(accstrgkeytemp)
            for i in range(2,lenkey):
                accstrgkey = accstrgkey + "="

        #logging.info(f"The account key at getStorageAccountSecret is  {accstrgkey}")
    except Exception as e:
        logging.error(f'The error at getStorageAccountSecret is {e}')

    return accstrgkey

def writeToBlobStorage(containerName,fileName,output):
    global LastErrorMessage
    LastErrorMessage = ""
    try:
        accountname = getStorageAccountName()
        #logging.info(f"The account name is  {accountname}")
        accountKey = getStorageAccountSecret()
        #logging.info(f"The accountKey is  {accountKey}")
        otpstr = str(output)
        blobService = BlockBlobService(account_name=accountname, account_key=accountKey)

        #if '/' in containerName:
        #    splcon = containerName.split('/')
        #    for i in range(0,splcon-1):
        #        blnCont = blobService.create_container(splcon[i])

        blnCont = blobService.create_container(containerName)
        blobService.create_blob_from_text(containerName, fileName, otpstr)

        #####For File service
        #fileser = FileService(account_name=accountname, account_key=accountKey)
        #blncount = fileser.create_share(sharename)
        #blncount1 = fileser.create_directory(sharename,directoryname)
        #fileser.create_file_from_text(sharename, directoryname, fileName, output)

    except Exception as e:
        logging.error(f'writeToBlobStorage error : {e}')
        LastErrorMessage = f'writeToBlobStorage error : {e}'

def readfromBlob(containerName,fileName):
    global LastErrorMessage
    LastErrorMessage = ""
    blobText=""
    try:
        accountname = getStorageAccountName()
        #logging.info(f"The account name is  {accountname}")
        accountKey = getStorageAccountSecret()
        #logging.info(f"The accountKey is  {accountKey}")

        blobService = BlockBlobService(account_name=accountname, account_key=accountKey)

        blobTemp = blobService.get_blob_to_text(containerName, fileName)
        blobText = blobTemp.content
        #logging.info(f"The blobText is  {blobText}")
        
    except Exception as e:
        LastErrorMessage = f"readFromBlob error : The specified blob [{fileName}] cannot be found in container [{containerName}]"
        logging.error(LastErrorMessage)

    return blobText

def getGoogleBucketConfiguration():
    global GoogleBucketName, GoogleBucketKey
    try:
        keyvault_name = os.environ["AZ_KEYVAULT_NAME"]
        secret_name_bucket_name = os.environ["GOOGLE_BUCKET_NAME_SECRET_NAME"]
        secret_name_bucket_key = os.environ["GOOGLE_BUCKET_KEY_SECRET_NAME"]

        if ("_LOCAL_DEV_VAULT_TOKEN" in os.environ):
            api_token_kv = os.environ["_LOCAL_DEV_VAULT_TOKEN"]
        else:
            api_token_kv = getTokenFromManage('https://vault.azure.net')

        url = f"https://{keyvault_name}.vault.azure.net/secrets/{secret_name_bucket_name}/?api-version=7.2"
        resp = callREST(url,api_token_kv,True)
        logging.info(resp)
        if 'value' in resp:
            GoogleBucketName = resp['value']
        url = f"https://{keyvault_name}.vault.azure.net/secrets/{secret_name_bucket_key}/?api-version=7.2"
        resp = callREST(url,api_token_kv)
        if 'value' in resp:
            GoogleBucketKey = resp['value']
        if GoogleBucketName and GoogleBucketKey:
            logging.info(f"Sucessfully loaded Google bucket config from keyvault [{keyvault_name}]")
            return True
        else:
            return False
    except Exception as e:
        return False

def getBillingCustomerNameConfiguration():
    global BillingCustomerName
    try:
        keyvault_name = os.environ["AZ_KEYVAULT_NAME"]
        secret_name = "billing-customer-name"
        BillingCustomerName = None

        if ("_LOCAL_DEV_VAULT_TOKEN" in os.environ):
            api_token_kv = os.environ["_LOCAL_DEV_VAULT_TOKEN"]
        else:
            api_token_kv = getTokenFromManage('https://vault.azure.net')

        url = f"https://{keyvault_name}.vault.azure.net/secrets/{secret_name}/?api-version=7.2"
        resp = callREST(url,api_token_kv,True)
        logging.info(resp)
        if 'value' in resp:
            BillingCustomerName = f"{resp['value']}"
            logging.info(f"Sucessfully loaded Billing Customer Name [{BillingCustomerName}] from keyvault [{keyvault_name}]")
            # BillingCustomerName = resp['value']
            return BillingCustomerName
    except Exception as e:
        return False        
 
def uploadToGoogle(fileName,fileContent):
    successStatus = True
    if GoogleBucketName and GoogleBucketKey:
        service_account_info = json.loads(GoogleBucketKey)
        google_credentials = service_account.Credentials.from_service_account_info(service_account_info)
        ##scoped_credentials = google_credentials.with_scopes()
        try:
            client = storage.Client(project= None,credentials=google_credentials)
            bucket = client.get_bucket(GoogleBucketName)
            object_name_in_gcs_bucket = bucket.blob(f"{fileName}")
            result = object_name_in_gcs_bucket.upload_from_string(fileContent)
            all_blobs = list(client.list_blobs(bucket))
            #logging.info(f'Google bucket [{GoogleBucketName}] blob content : {all_blobs}')
            statusStr = f"Successfully uploaded file [{fileName}] to Google bucket [{GoogleBucketName}]"
        except Exception as e:
            statusStr = f"Error while trying to upload file [{fileName}] to Google bucket [{GoogleBucketName}] Error : {str(e)}"
            successStatus = False
    else:
        statusStr = f"Unable to access Google Bucket configuration !"
        successStatus = False
    StatusObj = {"success": successStatus, "message" : statusStr }
    return StatusObj

def get_bearer_token(resource_uri):
    #logging.info(resource_uri)
    #logging.info(identity_endpoint)
    #logging.info(identity_header)
    #logging.info(my_app_setting_value)
    #url = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01"
    token_auth_uri = f"{identity_endpoint}?resource={resource_uri}&api-version=2017-09-01"
    #head_msi = {'X-IDENTITY-HEADER':identity_header}
    #head_msi={'X-IDENTITY-HEADER': ide}
    headers = {'Content-Type': 'application/json', 'secret': identity_header,'Access-Control-Allow-Credentials': 'true','Access-Control-Allow-Origin': 'http://localhost:8081','Access-Control-Allow-Methods': 'GET','Access-Control-Request-Headers': 'X-Custom-Header'}
    #head_msi = {'Metadata':'true'}

    #logging.info(token_auth_uri)
    #logging.info(headers)
    
    try:
        resp = requests.get(token_auth_uri, headers=headers)
        #logging.info(resp.text)
        resp.raise_for_status()
        #logging.info(resp.text)
    except requests.exceptions.HTTPError as err:
        logging.error(err)
        return err


    #logging.info(resp)
    access_token = resp.json()['access_token']
    return access_token

def getTokenFromManage(resource):
    toke_get = get_bearer_token(resource)
    return toke_get

def callREST(url, token, debuglogging = True):
    if debuglogging:
        logging.info(f'Calling REST API with Uri [{url}]')
    headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token}
    retry_sec = 5
    max_retries = 10
    nb_retries = 0
    while (nb_retries < max_retries):
        try:
            resp = None
            resp = requests.get(url, headers=headers,timeout=100)
            if debuglogging:
                logging.info(f'The response is [{resp.json()}]')
        except Exception as e:
            resp = None

        if (resp and resp.json() and 'error' in resp.json()):
            resp = None

        if ((resp != None) and ((resp.status_code < 200) or (resp.status_code > 299 and resp.status_code != 401))):
            http_error = resp.status_code
        else:
            http_error = None
        
        if (resp == None or http_error != None):
            nb_retries += 1
            scode = "0" if resp == None else http_error
            if debuglogging:
                logging.info(f'Request failed with HTTP code [{scode}], retrying ({nb_retries}/{max_retries}) after {retry_sec} sec')
            if scode != 404:
                time.sleep(retry_sec)
                retry_sec += 5
        else:
            caalRestresp = resp.json()
            break

    if (resp == None or http_error != None):
        scode = "0" if resp == None else http_error
        sts = '{"statuscode":'+ str(scode)+'}'
        caalRestresp = json.loads(sts)
        err_msg = f"Request failed with HTTP code [{scode}] after {max_retries} retries."
        logging.info(err_msg)
        raise Exception(err_msg)
       
    return caalRestresp

