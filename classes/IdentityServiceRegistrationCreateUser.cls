@RestResource(urlMapping='/IdentityService/Registration/createUser')
global class IdentityServiceRegistrationCreateUser {
//Does not acutally create users, creates Contacts, This is named this way to prevent confusion from app side
//TODO: include phone validation

    global static String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();

    @HTTPPost
    global static void createUser(UserCreateRequest newUser){
        ACVAPIHelper.SFResponse identityResult = new ACVAPIHelper.SFResponse(newUser, '', 200);
        identityResult.originalRequest = newUser;
        String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/services/identityservice/createuser';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');
        String trimmedUsername= String.isBlank(newuser.UserName)?'':newuser.UserName.trim(); 
        List<Contact> contactList = [Select Id, Id__c from Contact WHERE Email = :trimmedUsername];
        if(!contactList.isEmpty()){
            identityResult.message = 'Duplicate Username Found';
            identityResult.statusCode = 409;
            IdentityHelper.makeLog(newUser, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createUser Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 409);
            identityResult.generateResponse(headerMap);
            return;
        }
        else{
            if(!String.isBlank(newUser.Phone) && !ACVUtility.isValidPhone(newUser.Phone))
            {
                identityResult.message = 'Invalid Phone Number Format';
                identityResult.statusCode = 400;
                IdentityHelper.makeLog(newUser, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createUser Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 409);
                identityResult.generateResponse(headerMap);
                return;
            }

            List<String> nameStringList = newUser.Name.split(' ');
            String firstName = '';
            for(Integer i = 0; i < nameStringList.size()-1; i++){
                firstName += nameStringList[i]+' ';
            }
            String lastName = nameStringList[nameStringList.size()-1];
            //Generate New Contact
            String compondPhone = String.isBlank(newUser.phoneExt) ? newUser.Phone : newUser.Phone+';'+newUser.phoneExt;
            
            Contact newContact = new Contact( FirstName = firstName.trim(), LastName = lastName.trim(), 
            Email = trimmedUsername, Promotion_Code__c = newUser.PromoCode, Phone = compondPhone,
            mailingPostalCode = newUser.postalCode, Contact_Guid__c = ACVUtility.NewGuid(), RecordTypeId = contactRTID);
            try{
                SalesforceGatewayUserCreateLogic.disableGatewayLogic();
                insert newContact;
            }
            catch(Exception e){
                identityResult.message = 'Error Generating Contact';
                identityResult.statusCode = 500;
                IdentityHelper.makeLog(newUser, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', e.getStackTraceString()+':'+e.getMessage(), SplunkHelper.LOGLEVEL.FATAL, 500);
                identityResult.generateResponse(headerMap);
                return;
            }
            List<Contact> conList = [SELECT Id, FirstName, LastName, Email, RecordTypeId, Promotion_Code__c, ID__c, Phone, mailingPostalCode, Contact_Guid__c FROM Contact WHERE ID = :newContact.Id];
            identityResult.message = 'User Created';
            identityResult.statusCode = 201;
            identityResult.apiResponse = new UserCreateResponse(conList[0]);
            IdentityHelper.makeLog(newUser, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createUser Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.INFO, 201);
        }
        identityResult.generateResponse(headerMap);
    }

    global class UserCreateRequest{
        global String Name;
        global String PromoCode;
        global String UserName; //this is the users email address
        global String postalCode;
        global String phone;
        global String phoneExt;
    }

    global class UserCreateResponse{
        global String Name {get;set;}
        global String PromoCode {get;set;}
        global String UserName {get;set;} //this is the users email address
        global String UserGUID {get;set;}
        global String UserId {get;set;}
        
        global UserCreateResponse(Contact c){
            this.Name = c.FirstName+' '+c.LastName;
            this.PromoCode = c.Promotion_Code__c;
            this.UserName = c.Email;
            this.UserGUID = c.Contact_Guid__c;
            this.UserId = c.ID__c;
        }
    }
}