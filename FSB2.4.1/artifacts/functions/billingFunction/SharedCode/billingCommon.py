import pandas as pd


from datetime import datetime
from ..SharedCode import AzureUtility

## This class is where the aggregated csv provided by the hyperscalers will be processed and the respective cloud object will be called to get the FIT data
class Billing(object):
    def __init__(self, cloudType = ""):
        self.cloudType = cloudType

    ## This will check if a string is a number or not. We are doing this as we do not know what the value of the column will be. It can be a string or a number. To determine the correct field for it we are using this function
    def checkIfStringIsNumber(self, inputString = None,cloudUtility = None):
        isNumber = True
        try:
            if isinstance(float(inputString), float):
                isNumber = True
                print("1")
        except Exception as e:
            isNumber = False
            cloudUtility.writeLog(f'There was an error while checking if the column is of type float hence assuming it is a string : {e}',"Info")

        return isNumber   
                
    ## This function will take input as a BytesIO object containg the text in csv format. This function will return a bool value indicating the success or failure

    def getFITFile(self,csvInput = None):  
        isSuccess = True   
        customerName = "NA"
        serviceCategory = "NA"
        costColumn = "NA"   
        fitPeriod = "NA"   
        try:
            utc_timestamp = datetime.utcnow()       
            dateonfile = utc_timestamp.strftime("%Y%m%d")
            dateonFItFile = utc_timestamp.strftime("%Y%m")
            nenamingtime = utc_timestamp.strftime("%H%M%S")

            ## Cloud specific object has to be called here like AzureUtility, GCPUtility, AWSUtility
            cloudUtility = None
            if self.cloudType.upper() == "AZURE":
                cloudUtility = AzureUtility.AzureUtility()
            elif self.cloudType.upper() == "GCP":
                cloudUtility = GCPUtility.GCPUtility()
            elif self.cloudType.upper() == "AWS":
                cloudUtility = AWSUtility.AWSUtility()

            ## Uses panda to read the csv file with seperator as ','
            csvIntermittent = pd.read_csv(csvInput, sep=',',header=0)
            cloudUtility.writeLog(csvIntermittent,"Info")
                    


            ## dict object is initialized and the required columns i.e. 'FIT_PERIOD' and  'ORIGINAL_QTY' are added to it
            dictFITFile = dict()
            dictFITFile['FIT_PERIOD'] = []
            dictFITFile['ORIGINAL_QTY'] = []
            
            ## The csv file is iterated and the customer name, service category and the cost column is extracted
            for row in csvIntermittent.itertuples():
                customerName = row.CustomerName
                fitPeriod = row.FIT_PERIOD
                if self.checkIfStringIsNumber(row[1],cloudUtility):
                    costColumn = row[1]
                else:                  
                    serviceCategory = row[1]
                
                if self.checkIfStringIsNumber(row[2],cloudUtility):
                    costColumn = row[2]
                else:                  
                    serviceCategory = row[2]
                
                ## The cloud specific object is called to get the FIT data from the database
                FITData, statusCode = cloudUtility.getFITData(customerName,serviceCategory)
                if statusCode == 200:
                    
                    ## The FIT data is added to the dict object from the database which contains the FIT data
                    for key, value in FITData.items():
                        if key in dictFITFile:
                            dictFITFile[key].append(value)
                        else:
                            dictFITFile[key] = [value]

                    dictFITFile['FIT_PERIOD'].append(fitPeriod)
                    dictFITFile['ORIGINAL_QTY'].append(costColumn)
                else:
                    cloudUtility.writeLog(f"FIT data not found for {customerName} and {serviceCategory}","Info")
                        
            ## The dict object is converted to a dataframe and then to csv format adn then written to the storage
            fitFileDataFrame = pd.DataFrame(dictFITFile)
            filtFileCsvOutput = fitFileDataFrame.to_csv(index=False,encoding = "utf-8")
            filename = f"{self.cloudType}_FIT_FILE_{customerName}_{dateonfile}_{nenamingtime}"
            cloudUtility.writeToStorageAccount("fit-files",f"{filename}.csv",filtFileCsvOutput)
        
        except Exception as e:
            isSuccess = False
            cloudUtility.writeLog(f'getFITFile error : {e}',"Error")

        return isSuccess
