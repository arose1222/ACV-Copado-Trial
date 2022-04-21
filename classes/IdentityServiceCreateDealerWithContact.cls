@RestResource(urlMapping='/IdentityService/Registration/createDealerWithContact')
global with sharing class IdentityServiceCreateDealerWithContact {

    private static final Map<String, String> AccountTypeMap = new Map<String,String>{'unknown'=>'0', 'franchise'=>'1', 'independent'=>'2', 'wholesaler'=>'3', 'acv certified independent'=>'4', 'commercial'=>'5'};
    private static final string standardAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();

    @HTTPPost
    global static void createDealerWithContact(CreateDealerRequest newDealer){
        ACVAPIHelper.SFResponse identityResult = new ACVAPIHelper.SFResponse(newDealer, '', 200);
        identityResult.originalRequest = newDealer;
        String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/services/IdentityService/Registration/createDealerWithContact';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');

        List<Contact> conList = [select id, Id__c, AccountId from Contact where Id__c = :newDealer.User_Id];
        if(conList.isEmpty()){
            identityResult.message = 'User Not Found';
            identityResult.statusCode = 409;
            IdentityHelper.makeLog(newDealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PUT', 'IdentityService.createDealerWithContact Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 409);
            identityResult.generateResponse(headerMap);
            return;
        }

        String sanitizedLegalName= String.IsBlank(newDealer.Legal_Name)? '' : newDealer.Legal_Name.replaceAll('`','\'');
        List<Account> accList = [select id from Account where legal_name__c = :sanitizedLegalName and BillingStreet=:newDealer.Street 
                                    and BillingCity=:newDealer.City];
        if(!String.isBlank(sanitizedLegalName) && !accList.isEmpty()){
            identityResult.message = 'Duplicate dealer found';
            identityResult.statusCode = 409;
            IdentityHelper.makeLog(newDealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PUT', 'IdentityService.createDealerWithContact Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 409);
            identityResult.generateResponse(headerMap);
            return;
        }
        //Phone validator will need updated in the future for country codes
        if(!String.isBlank(newDealer.Cell) && !ACVUtility.isValidPhone(newDealer.Cell)){
            identityResult.message = 'Invalid Phone Format for Cell';
            identityResult.statusCode = 400;
            IdentityHelper.makeLog(newDealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PUT', 'IdentityService.createDealerWithContact Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 400);
            identityResult.generateResponse(headerMap);
            return;
        }
        if(!String.isBlank(newDealer.Phone) && !ACVUtility.isValidPhone(newDealer.Phone)){
            identityResult.message = 'Invalid Phone Format for Phone';
            identityResult.statusCode = 400;
            IdentityHelper.makeLog(newDealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PUT', 'IdentityService.createDealerWithContact Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 400);
            identityResult.generateResponse(headerMap);
            return;
        }
 
        Account newAccount = new Account();
        Savepoint sp = Database.setSavepoint();
        try{
            String compondPhone = String.isBlank(newDealer.phoneExt) ? newDealer.Phone : newDealer.Phone+';'+newDealer.phoneExt;
            String sanitizedDBATradeName= String.IsBlank(newDealer.DBA_Trade_Name)? '' : newDealer.DBA_Trade_Name.replaceAll('`','\'');
            String namePlaceHolder = String.isBlank(sanitizedDBATradeName) ? sanitizedLegalName : sanitizedDBATradeName;
            newAccount = new Account(recordTypeId = standardAccountRecordTypeId, Active__c = false, dba_trade_name__c = sanitizedDBATradeName, 
                            Name = namePlaceHolder, cell__c = newDealer.Cell, Phone = compondPhone, Status__c = '3', legal_name__c = sanitizedLegalName, 
                            Dealer_Type__c = AccountTypeMap.get(newDealer.Dealership_Type.toLowerCase()), Organization_Guid__c = ACVUtility.NewGuid(),
                            BillingStreet= newDealer.Street, BillingCity= newDealer.City, BillingState= newDealer.State, BillingPostalCode= newDealer.Zip_code,
                            Tax_Id__c= newDealer.Federal_Tax_ID, License_Number__c= newDealer.License_Number);
            insert newAccount;
        }
        catch(Exception e){
            identityResult.message = 'Error Generating Account';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(newDealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PUT', e.getStackTraceString()+':'+e.getMessage(), SplunkHelper.LOGLEVEL.ERROR, 500);
            identityResult.generateResponse(headerMap);
            Database.rollback( sp );
            return;
        }
        newAccount = [SELECT Id, Name, Status__c, Organization_Guid__c, Dealer_Type__c, legal_name__c, cell__c, dba_trade_name__c, Active__c, Phone, Dealership_ID__c FROM Account WHERE Id = :newAccount.Id limit 1];
        conList[0].AccountId = newAccount.Id;

        try{
            update conList;
            
        }
        catch(Exception e){
            identityResult.message = 'Error Relating Contact or Associating Location';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(newDealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PUT', e.getStackTraceString()+':'+e.getMessage(), SplunkHelper.LOGLEVEL.ERROR, 500);
            identityResult.generateResponse(headerMap);
            Database.rollback( sp );
            return;
        }

        if(!String.isBlank(newDealer.Street))
        {
                AddressHelper.AddressWrapper aw = new AddressHelper.AddressWrapper();
                aw.Street =  newDealer.Street;
                aw.City =  newDealer.City;
                aw.State = newDealer.State;
                aw.PostalCode =  newDealer.Zip_code;
                aw.Country = 'US'; 
                aw.type = 'billing';
               
            try {
                insert AddressHelper.generateAddressStack(aw, newAccount.Id);
            } 
            catch(Exception e){
                identityResult.message = 'Error Generating Associated Location';
                identityResult.statusCode = 500;
                IdentityHelper.makeLog(newDealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PUT', e.getStackTraceString(), SplunkHelper.LOGLEVEL.ERROR, 500);
                identityResult.generateResponse(headerMap);
                Database.rollback( sp );
                return;
            }
        }
        Affiliation__c newAff = new Affiliation__c();
        newAff.Account__c = newAccount.Id;
        newAff.Contact__c = conList[0].Id;
        newAff.Active__c = True;
        newAff.primary_contact__c = True;
        newAff.type__c = 'admin';
        newAff.id__c = IdentityHelper.createAffiliationId(newAccount.Dealership_ID__c, conList[0].ID__c);
        newAff.Start_Date__c = System.today();

        try{
            insert newAff;
        }
        catch(Exception e){
            identityResult.message = 'Error Generating Affiliation';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(newDealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PUT', e.getStackTraceString(), SplunkHelper.LOGLEVEL.ERROR, 500);
            identityResult.generateResponse(headerMap);
            Database.rollback( sp );
            return;
        }

        CreateDealerResponse dcr = new CreateDealerResponse();
        dcr.Dealer_Id = newAccount.Dealership_ID__c;
        dcr.Affiliation_Id = newAff.id__c;
        dcr.Dealer_GUID = newAccount.Organization_Guid__c;
        dcr.Sanitized_Legal_Name= newAccount.legal_name__c;
        dcr.Sanitized_DBA_Name= newAccount.dba_trade_name__c;
        identityResult.message = 'Account Created';
        identityResult.statusCode = 201;
        identityResult.apiResponse = dcr;
        IdentityHelper.makeLog(newDealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createDealerWithContact Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.INFO, 201);
        identityResult.generateResponse(headerMap);
    }

    global class CreateDealerRequest{
        global String DBA_Trade_Name;
        global String Legal_Name;
        global String User_Id;
        global String Phone;
        global String phoneExt;
        global String Cell;
        global String Dealership_Type;
        public string Street;
        public string City;
        public string State;
        public string Zip_code;
        public string Federal_Tax_ID;
        public string License_Number;
        
    }

    global class CreateDealerResponse{
        global String Dealer_Id;
        global String Dealer_GUID;
        global String Affiliation_Id;
        global String Sanitized_Legal_Name;
        global String Sanitized_DBA_Name;
    }
}