import logging
import pandas as pd
import datetime

from azure.functions import InputStream
from io import BytesIO
from datetime import timedelta


from ..SharedCode import common
from ..SharedCode import billingCommon

def main(myblob: InputStream):
    logging.info(f"Python blob trigger function processed blob \n"
                 f"Name: {myblob.name}\n"
                 f"Blob Size: {myblob.length} bytes")
    
    blobName = str(myblob.name)
    cloudName = ""
    tempSplit = blobName.split("_")
    if len(tempSplit) > 0:
        temp = tempSplit[0]
        if temp != "" and len(temp) > 0:
            tempCloudSplit = temp.split("/")
            if len(tempCloudSplit) > 1:
                cloudName = tempCloudSplit[1]

    if cloudName != "":
        csvInput = BytesIO(myblob.read())
        billingReader = billingCommon.Billing(cloudName)
        isSuccess = billingReader.getFITFile(csvInput)
        logging.info(isSuccess)
        if isSuccess:
            logging.info("FIT File Generated Successfully")
        else:
            logging.info("FIT File Generation Failed")
    else:
        logging.info(f"Invalid Cloud Name")
        
    # csvInput = BytesIO(myblob.read())
    # csvIntermittent = pd.read_csv(csvInput, sep=',',header=0)
    # logging.info(csvIntermittent)
    # serviceCategoryColumn = csvIntermittent.columns[0]
    # costColumn = csvIntermittent.columns[1]
    # custColumn = csvIntermittent.columns[2]

    # for row in csvIntermittent.itertuples():
    #     name = row._1
    #     age = row._2
    #     location = row.CustomerName
    # refersub = data.columns[0]
    # logging.info(refersub)
    # referaas = data.columns[2]
    # logging.info(referaas)
    # refercost = data.columns[3]
    # logging.info(refercost)
    # aggcsv = data.groupby(referaas)[refercost].sum().reset_index()
    # # Assign the new column to the DataFrame
    # new_column_values = [common.CustomerName] * len(aggcsv)
    # aggcsv = aggcsv.assign(CustomerName=new_column_values)

    # CSVoutput = aggcsv.to_csv(index=False,encoding = "utf-8")
    # utc_timestamp = datetime.datetime.utcnow()-timedelta(days=1)
    # dateonfile = utc_timestamp.strftime("%Y%m%d")
    # nenamingtime = utc_timestamp.strftime("%H%M%S")
    # filename = f"FIT_FILE_{common.CustomerName}_{dateonfile}_{nenamingtime}"

    # common.writeToBlobStorage("fit-files",f"{filename}.csv",CSVoutput)