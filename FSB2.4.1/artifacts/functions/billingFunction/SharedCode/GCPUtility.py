## Import any modules needed specifically for the GCP utility here

class GCPUtility(object):
    ## Initialize the object with the required parameters
    def __init__(self):
        print("Object Created for GCPUtility")

    ## This function will get the FIT data from the db table and the output should be in the form <class 'dict'> and status code
    def getFITData(self,customerName = None, serviceCategory=None):

        ####Code to get the data from the GCP database which holds the FIT data
        try:
            pass
        except Exception as error:
            print(f'getFITData error : {error}')

        return dict(), 200
    
    ## This function will write the contents to the blob storage
    def writeToStorageAccount(self,containerName=None,fileName=None,output=None):
        isSuccess = True

        #### Code to write the contents to the respective storage account
        try:
            pass
        except Exception as error:
            print(f'getFITData error : {error}')
        return isSuccess
    
    ## This function will be used to add logs. This is present as the logging may be different per cloud.
    def writeLog(self, message, typeofLog = "Info"):
        if typeofLog == "Info":
            print(message)
        elif typeofLog == "Debug":
            print(message)
        elif typeofLog ==  "Error":
            print(message)

    ## This function will get the token for the REST API call
    def getToken(self):
        apiToken = ""
        return apiToken

    