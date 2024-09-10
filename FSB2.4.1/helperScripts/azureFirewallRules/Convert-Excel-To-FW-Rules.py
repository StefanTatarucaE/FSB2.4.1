import sys
import pandas as pd
import json
import ipaddress

import warnings
#To remove the future warnings that appear for the panda package after running the script 
warnings.simplefilter(action='ignore', category=FutureWarning)

#This class represents the firewall rule collection group. The property names should match the json properties of the azure firewall.
class fwRuleCollectionGroup(object):
    def __init__(self,name = None,properties=None):
        self.name = name
        self.properties = properties

#This class represents the property object in the rule collection group
class fwProperties(object):
    def __init__(self,priority = None,ruleCollection=None):
        self.priority = priority
        self.ruleCollections = ruleCollection

#This class represents the rule collection object in the rule collection group
class fwRuleCollection(object):
    def __init__(self,name = None, priority=None,action =None,rules=None):
        self.priority = priority
        self.action = action
        self.rules = rules
        self.name = name
        if removeSpace(str(action.type).strip()) == "DNAT":
            self.ruleCollectionType = "FirewallPolicyNatRuleCollection"
        else:
            self.ruleCollectionType = "FirewallPolicyFilterRuleCollection"

#This class represents the action object in the rule collection
class fwAction(object):
    def __init__(self,type=None):
        self.type = type

#This is a common class for rules which will be inherited by other classes
class commonRule(object):
    def __init__(self, name=None, valuesExcel=None, variableFromJson = None, ruleType = None,isApplicationRule = None):
        #variableFromJson = jsonVariables(variableFilePath)
        self.name = name
        self.ruleType = ruleType
        self.sourceAddresses = self.getSourceAndDestinationAddresses(valuesExcel[variableFromJson.intSource])
        self.destinationAddresses = self.getSourceAndDestinationAddresses(valuesExcel[variableFromJson.intDestination])

    #Get the Source and Destination address from the excel
    def getSourceAndDestinationAddresses(self,excelValueOfAddress):
        resultAddress = []
        if not pd.isna(excelValueOfAddress):
            splitExcelValue = str(excelValueOfAddress).split(',')
            if len(splitExcelValue) > 1:
                for excelValue in  splitExcelValue:
                    strExcelValue = removeSpace(str(excelValue))
                    resultAddress.append(strExcelValue)
            else:
                resultAddress.append(removeSpace(excelValueOfAddress))
        
        return resultAddress

    #This function gets the protocols from the excel sheet for the network rule
    def getProtocols(self,protocolArray,protocolInSheet,isApplicationRule = False):
        resultProtocol = []
        for tempProtocol in protocolInSheet:
            if(len(protocolArray)> tempProtocol):
                if not pd.isna(protocolArray[tempProtocol]):
                    if(isApplicationRule):
                        if not pd.isna(protocolArray[tempProtocol+1]):
                            tempValue = fwProtocol(protocolArray[tempProtocol],protocolArray[tempProtocol+1])
                            resultProtocol.append(tempValue)
                    else:
                        resultProtocol.append(protocolArray[tempProtocol])

        
        return resultProtocol
    
    #Get the ports details from the excel
    def getPorts(self,portArray,portsInSheet):
        resultPorts = []    
        for tempPorts in portsInSheet:
            if(len(portArray)> tempPorts):
                if not pd.isna(portArray[tempPorts]):
                    splitPort = str(portArray[tempPorts]).split(',')
                    if len(splitPort) > 1:
                        for tempPort in  splitPort:
                            tempValue = ""
                            tempValue = str(tempPort).strip()
                            tempValue = tempValue.replace(" ", "")
                            resultPorts.append(tempValue)
                    else:
                        tempValue = ""
                        tempValue = str(portArray[tempPorts]).strip()
                        tempValue = tempValue.replace(" ", "")
                        resultPorts.append(str(tempValue))

        return resultPorts
    

#This class represents the network rule object in the rule collection
class networkRule(commonRule): 
    def __init__(self, name=None, valuesExcel=None, variableFromJson = None, ruleType = None):
        super().__init__( name, valuesExcel, variableFromJson, ruleType)
        self.destinationPorts = self.getPorts(valuesExcel,variableFromJson.networkPortsInSheet)        
        self.ipProtocols = self.getProtocols(valuesExcel,variableFromJson.networkProtocolInSheet)
        
        self.hasWrongValues = self.checkForEmptyValues(self.sourceAddresses,self.destinationAddresses,name,self.ipProtocols,self.destinationPorts)

        #This is for validation purpose. This function checks for empty values in fields that should not have empty values.
    def checkForEmptyValues(self,sourceAddresses,destinationAddresses,name,protocols,destinationPorts):
        returnValue = False
        if ((len(sourceAddresses) == 0) and (len(destinationAddresses) == 0)):             
             self.message =  f"Both 'Source Addresses' and 'Destination Addresses' has to be set for the rule {name}"
             returnValue = True
        elif (len(sourceAddresses) > 0) and (len(destinationAddresses) == 0):
            self.message =  f"'Destination Addresses' has to be set for the rule {name}"
            returnValue = True   
        elif (len(sourceAddresses) == 0) and (len(destinationAddresses) > 0):
            self.message =  f"'Source Addresses' has to be set for the rule {name}"
            returnValue = True     
        if(len(protocols) == 0):
            self.message =  f"'Protocols' has to be set for the rule {name}"
            returnValue = True   
        if(len(destinationPorts) == 0):
            self.message =  f"'Ports' has to be set for the rule {name}"
            returnValue = True 

        return returnValue

#This class represents the application rule object in the rule collection
class applicationRule(commonRule):
    def __init__(self, name=None, valuesExcel=None, variableFromJson = None, ruleType = None, isApplicationRule = None):
        super().__init__(name, valuesExcel,variableFromJson, ruleType,isApplicationRule)
        self.terminateTLS = False           
        self.targetFqdns = self.getSourceAndDestinationAddresses(valuesExcel[variableFromJson.intFQDN])
        self.fqdnTags = self.getSourceAndDestinationAddresses(valuesExcel[variableFromJson.intTranslatedPort])
        self.webCategories = self.getSourceAndDestinationAddresses(valuesExcel[variableFromJson.intWebCategories])
        self.protocols = self.getProtocols(valuesExcel,variableFromJson.appRUleProtocolInSheet,isApplicationRule)
        self.hasWrongValues = self.checkForEmptyValues(self.sourceAddresses,self.destinationAddresses,self.targetFqdns,self.fqdnTags,self.webCategories,name,self.protocols)

    #This is for validation purpose. This function checks for empty values in fields that should not have empty values.
    def checkForEmptyValues(self,sourceAddresses,destinationAddresses,targetFqdns,fqdnTags,webCategories,name,protocols):
        returnValue = False
        if len(sourceAddresses) == 0:
            self.message =  f"There is no source address for the rule {name}"
            returnValue = True
        if len(protocols) == 0:
            self.message =  f"Protocol details are not correct for the rule {name}"
            returnValue = True
        elif len(protocols) > 0:
            for temp in protocols:
                if temp.protocolType == "Https" and temp.port == 80:
                    self.message =  f"Protocol details are not correct for the rule {name}, Http value should have 80 and Https value should have 443"
                    returnValue = True
                elif temp.protocolType == "Http" and temp.port == 443: 
                    self.message =  f"Protocol details are not correct for the rule {name}, Http value should have 80 and Https value should have 443"
                    returnValue = True
                if returnValue:
                    break          

        if ((len(destinationAddresses) > 0) and (len(targetFqdns) > 0) and (len(fqdnTags) > 0) and (len(webCategories) > 0)):
            self.message =  f"Only one value should be there either destinationAddresses or targetFqdns or fqdnTags or webCategories for the rule {name}"
            returnValue = True
        elif ((len(destinationAddresses) > 0) and (len(targetFqdns) > 0)):
            self.message =  f"Only one value should be there either destinationAddresses or targetFqdns or fqdnTags or webCategories for the rule {name}"
            returnValue = True
        elif ((len(destinationAddresses) > 0) and (len(fqdnTags) > 0)):
            self.message =  f"Only one value should be there either destinationAddresses or targetFqdns or fqdnTags or webCategories for the rule {name}"
            returnValue = True
        elif ((len(destinationAddresses) > 0) and (len(webCategories) > 0)):
            self.message =  f"Only one value should be there either destinationAddresses or targetFqdns or fqdnTags or webCategories for the rule {name}"
            returnValue = True
        elif ((len(targetFqdns) > 0) and (len(fqdnTags) > 0)):
            self.message =  f"Only one value should be there either destinationAddresses or targetFqdns or fqdnTags or webCategories for the rule {name}"
            returnValue = True
        elif ((len(targetFqdns) > 0) and (len(webCategories) > 0)):
            self.message =  f"Only one value should be there either destinationAddresses or targetFqdns or fqdnTags or webCategories for the rule {name}"
            returnValue = True
        elif ((len(fqdnTags) > 0) and (len(webCategories) > 0)):
            self.message =  f"Only one value should be there either destinationAddresses or targetFqdns or fqdnTags or webCategories for the rule {name}"
            returnValue = True
        elif ((len(destinationAddresses) == 0) and (len(targetFqdns) == 0) and (len(fqdnTags) == 0) and (len(webCategories) == 0)):
            self.message =  f"Either destinationAddresses or targetFqdns or fqdnTags or webCategories should be present for the rule {name}"
            returnValue = True
       

        return returnValue

#This class represents the dnat rule object in the rule collection
class dnatRules(commonRule):
    def __init__(self, name=None, valuesExcel=None, variableFromJson = None, ruleType = None):
        super().__init__(name, valuesExcel, variableFromJson, ruleType)
        
        self.destinationPorts = self.getPorts(valuesExcel,variableFromJson.dnatPortsInSheet)        
        self.ipProtocols = self.getProtocols(valuesExcel,variableFromJson.dnatProtocolInSheet)
        translatedAddress = valuesExcel[variableFromJson.intFQDN]
        translatedPort = valuesExcel[variableFromJson.intTranslatedPort]
        translatedFqdn = valuesExcel[variableFromJson.intWebCategories]
        
        if translatedFqdn == None or isNaN(translatedFqdn):
             self.translatedFqdn = ""
        else:
            self.translatedFqdn = translatedFqdn
        if translatedAddress == None or isNaN(translatedAddress):
             self.translatedAddress = ""
        else:
            self.translatedAddress = translatedAddress
        self.translatedPort = translatedPort
        self.hasWrongValues = self.checkForEmptyValues(self.sourceAddresses,self.destinationAddresses,self.ipProtocols,self.destinationPorts,translatedAddress,translatedFqdn,name,self.translatedPort)

    #This is for validation purpose. This function checks for empty values in fields that should not have empty values.
    def checkForEmptyValues(self,sourceAddresses,destinationAddresses,protocols,destinationPorts,translatedAddress,translatedFqdn,name,translatedPort):
        returnValue = False
        if ((len(sourceAddresses) == 0) and (len(destinationAddresses) == 0)):             
             self.message =  f"Both 'Source Addresses' and 'Destination Addresses' has to be set for the rule {name}"
             returnValue = True
        elif (len(sourceAddresses) > 0) and (len(destinationAddresses) == 0):
            self.message =  f"'Destination Addresses' has to be set for the rule {name}"
            returnValue = True   
        elif (len(sourceAddresses) == 0) and (len(destinationAddresses) > 0):
            self.message =  f"'Source Addresses' has to be set for the rule {name}"
            returnValue = True   
        
        if(len(protocols) == 0):
            self.message =  f"'Protocols' has to be set for the rule {name}"
            returnValue = True   
        if(len(destinationPorts) == 0):
            self.message =  f"'Ports' has to be set for the rule {name}"
            returnValue = True 
        
        if(checkinNaN.isNaN(translatedPort)):
            self.message =  f"'Translated Ports' has to be set for the rule {name}"
            returnValue = True 
        
        
        if (not checkinNaN.isNaN(translatedFqdn) and (not checkinNaN.isNaN(translatedAddress))):
            self.message =  f"Only one value should be there either translatedAddress or translatedFqdn for the rule {name}"
            returnValue = True
        elif (checkinNaN.isNaN(translatedFqdn) and (checkinNaN.isNaN(translatedAddress))):
            self.message =  f"Either translatedAddress or translatedFqdn has to be present for the rule {name}" 
            returnValue = True           
        
        
        return returnValue

#This class represents the protocol object in the rule collection
class fwProtocol(object):
    def __init__(self,protocolType,port):
        self.protocolType = protocolType
        self.port = port

#This class gets all the values from the variable json file. the variable json has all the variables that can/may be changed in the future without touching the code
class jsonVariables(object):
    def __init__(self,variableFilePath = None):
        variableValue = self.getDetails(variableFilePath)
        self.filePath = variableValue['filePath']
        self.ruleCollectionNames = variableValue['ruleCollectionNames']
        self.columnsToUse = variableValue['columnsToUse']
        self.networkProtocolInSheet = variableValue['networkProtocolInSheet']
        self.networkPortsInSheet = variableValue['networkPortsInSheet']
        self.appRUleProtocolInSheet = variableValue['appRUleProtocolInSheet']
        self.dnatProtocolInSheet = variableValue['dnatProtocolInSheet']
        self.dnatPortsInSheet = variableValue['dnatPortsInSheet']
        self.intName = variableValue['intName']
        self.intPriority = variableValue['intPriority']
        self.intAction = variableValue['intAction']
        self.intSource = variableValue['intSource']
        self.intDestination = variableValue['intDestination']
        self.intFQDN = variableValue['intFQDN']
        self.intTranslatedPort = variableValue['intTranslatedPort']
        self.intWebCategories = variableValue['intWebCategories']
        self.outputFile = variableValue['outputFile']
        self.applicationSheetName = variableValue['applicationSheetName']
        self.dnatSheetName = variableValue['dnatSheetName']
        self.startOfValuesInExcel = variableValue['startOfValuesInExcel']
    
    def getDetails(self,variableFilePath):
        variableFile = open(variableFilePath)
        # returns JSON object as 
        # a dictionary
        variableValue = json.load(variableFile)
        return variableValue

#This class is used to check if the object is Nan
class checkinNaN:

    def isNaN(num):
        return num != num
    
#This function removes any exces space in a string
def removeSpace(string):
    return string.replace(" ", "")

#This function checks if the object is NaN
def isNaN(num):
    return num != num

#This is the main function    
def main(variableFilePath):
    #Variables common for the whole main function
    fwRuleArray = []

    #Get the variables from the variable json
    variableFromJson = jsonVariables(variableFilePath)

    #Loop through the rule collection (sheets in the excel)
    for ruleName in variableFromJson.ruleCollectionNames:
        #Variables needed within the loop of the rule collections
        ruleCollections = []        
        countLoop = 0
        fwRules = []
        isApplicationRule = False
        isDnatRule = False
        ruleType = "NetworkRule"
        actionFw = "" 
        duplicateRuleName = []
        IsDuplicate = False
        errorMessage = []
        
        #Here we read the excel file using panda
        excelRuleData = pd.read_excel(variableFromJson.filePath,sheet_name=ruleName,usecols=variableFromJson.columnsToUse)

        #Get the excel data frame values into readable format
        ruleData = pd.DataFrame(excelRuleData)


        #Looping through the rule values in the excel sheet
        if len(ruleData.values) > 0:
            for values in ruleData.values:

                #This will increment the loop number. This is to check the row of the excel.
                countLoop=countLoop +1
                
                #Checking the first column name to decide if this is a Application rule or a DNAT rule
                if countLoop == 1:
                    if str(values[variableFromJson.intName]).strip() == variableFromJson.applicationSheetName:
                        isApplicationRule = True
                        isDnatRule = False
                        ruleType = "ApplicationRule"
                    elif str(values[variableFromJson.intName]).strip() == variableFromJson.dnatSheetName:
                        isApplicationRule = False
                        isDnatRule = True
                        ruleType = "NatRule"

                #The actual values start from the 3rd line.
                if countLoop >= variableFromJson.startOfValuesInExcel:

                    #Getting the source and destination addresses, priority and the action values
                    if not pd.isna(values[variableFromJson.intName]):
                        rulePriority = values[variableFromJson.intPriority]
                        actionFw = values[variableFromJson.intAction]
                        
                        ruleNameToBeUpdated = f"{values[variableFromJson.intName]}"
                    
                        #Checking if the rule is application rule
                        if isApplicationRule:
                            #Setting the application rule collection object.
                            ruleObject = applicationRule(ruleNameToBeUpdated,values,variableFromJson,ruleType,isApplicationRule)
                            
                        
                        #Checking if the rule is dnat rule
                        elif isDnatRule:
                            #Setting the application rule collection object.
                            ruleObject = dnatRules(ruleNameToBeUpdated,values,variableFromJson,ruleType)
                            
                        
                        #If its not the above then its a network rul
                        else:
                            #Setting the network rule collection object.
                            ruleObject = networkRule(ruleNameToBeUpdated,values,variableFromJson,ruleType)
                            
                       #This code finds if there are duplicate rule names in tehe excel.
                        IsDuplicate = False
                        if len(fwRules)>0:
                            for fwValue in fwRules: 
                                if fwValue.name == ruleObject.name:
                                    if len(duplicateRuleName) > 0:
                                        for duplicate in duplicateRuleName:
                                            if duplicate == ruleObject.name:
                                                IsDuplicate = False
                                                break
                                            else:
                                                IsDuplicate = True 
                                    else:
                                        IsDuplicate = True
                                        break

                        if IsDuplicate:                     
                            duplicateRuleName.append(ruleObject.name)
                        else:
                            fwRules.append(ruleObject)

                        #This field checks if there are multiple values where actually there should be only one for eg for DNAT either the translated address or  translated fqdn either one should be present and not both at the same time
                        if ruleObject.hasWrongValues:
                            errorMessage.append(ruleObject.message)
                    else:
                        mainErrorMessage = "There is a name missing for the rule, hence can't proceed with this rule collection group."
                        errorMessage.append(mainErrorMessage)

                            
                                    
        if len(duplicateRuleName) > 0:
            for duplicate in duplicateRuleName:
                print(f"There are duplicate values for {duplicate}, hence will not proceed with adding this in the rule as it will break the deployment") 
        elif len(errorMessage)>0: 
            for message in errorMessage:
                print(f"{message}") 
        else: 
            #Checking if priority is set, it will always take the Priority from the final row.
            if isNaN(rulePriority) or rulePriority == "" or (not isinstance(rulePriority, int)):
                print(f"There is no priority defined or priority value is not an integer for the rule collection group {ruleName}, hence cannot proceed further with this rule collection group.") 
            #Checking if action is set, it will always take the action from the final row. 
            elif isNaN(actionFw) or actionFw == "" or ((not isDnatRule and actionFw != "Allow") and (not isDnatRule and actionFw != "Deny") or (isDnatRule and actionFw != "DNAT")):
                print(f"There is no action defined or action value is wrong for the rule collection group {ruleName}, hence cannot proceed further with this rule collection group.") 
            else:      
                #Setting the object for Action, RuleCollection and than adding it to an array.               
                actionFireWall = fwAction(actionFw)
                ruleCollectionFireWall = fwRuleCollection(ruleName,rulePriority,actionFireWall,fwRules)
                ruleCollections.append(ruleCollectionFireWall)
                
                #Setting the object for properties and then using it to form the rule collection group. Finally the rule collection group is added to an Array.   
                propertyFW = fwProperties(rulePriority,ruleCollections)
                ruleCollectionGroupFireWall = fwRuleCollectionGroup(ruleName,propertyFW)
                fwRuleArray.append(ruleCollectionGroupFireWall)

    #The final array in the above section is then converted into the json format understood by the bicep module.
    jsonResult = json.dumps(fwRuleArray, default = lambda x: x.__dict__)

    #This steps writes the json to a file, the name and path of the file should be specified in the variable json file.
    with open(variableFromJson.outputFile, 'w') as file:
        file.write(jsonResult)

#This is the main excution of this file.
if __name__ == "__main__":
    #This value is taken from the arguments passed while running the python script
    variableFilePath = sys.argv[1]
    main(variableFilePath)