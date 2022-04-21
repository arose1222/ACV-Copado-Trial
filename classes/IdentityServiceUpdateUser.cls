@RestResource(urlMapping='/IdentityService/updateuser')
global class IdentityServiceUpdateUser {
    
    @HTTPPATCH
    global static void updateUser(UserUpdateRequest user){
        ACVAPIHelper.SFResponse identityResult = new ACVAPIHelper.SFResponse(user, '', 200);
        identityResult.originalRequest = user;
        String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/services/identityservice/updateuser';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');
        List<Contact> clist = [SELECT ID, FirstName, LastName, Phone, MailingPostalCode FROM Contact WHERE Id__c = :user.id];
        if(clist.size() < 1){
            identityResult.message = 'User Does Not Exist';
            identityResult.statusCode = 501;
            IdentityHelper.makeLog(user, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', identityResult.message, SplunkHelper.LOGLEVEL.ERROR, identityResult.statusCode);
            identityResult.generateResponse(headerMap);
            return;
        }
        if(!String.isBlank(user.phone) && !ACVUtility.isValidPhone(user.phone)){
            identityResult.message = 'Phone is in a bad format';
            identityResult.statusCode = 409;
            IdentityHelper.makeLog(user, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', identityResult.message, SplunkHelper.LOGLEVEL.ERROR, identityResult.statusCode);
            identityResult.generateResponse(headerMap);
            return;
        }
        String firstName = '';
        String lastName = '';
        if(!String.isBlank(user.name)){
            List<String> nameStringList = user.Name.split(' ');
        
            for(Integer i = 0; i < nameStringList.size()-1; i++){
                firstName += nameStringList[i]+' ';
            }
            lastName= nameStringList[nameStringList.size()-1];
        }
        String compondPhone = String.isBlank(user.phoneExt) ? user.Phone : user.Phone+';'+user.phoneExt;
        clist[0].FirstName = String.isBlank(firstName) ? clist[0].FirstName : firstName.trim();
        clist[0].LastName = String.isBlank(lastName) ? clist[0].LastName : lastName.trim();
        clist[0].Phone = String.isBlank(compondPhone) ? clist[0].Phone : compondPhone;
        clist[0].MailingPostalCode = String.isBlank(user.zipCode) ? clist[0].MailingPostalCode : user.zipCode;

        try{
            update clist;
        }
        catch(Exception e){
            identityResult.message = 'Error Updating User';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(user, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', e.getStackTraceString()+':'+e.getMessage(), SplunkHelper.LOGLEVEL.ERROR, 500);
            identityResult.generateResponse(headerMap);
            return;
        }
        identityResult.apiResponse = user;
        identityResult.generateResponse(headerMap);
    }

    global class UserUpdateRequest{
        public String id;
        public String name;
        public String phone;
        public String zipCode;
        public String phoneExt;
    }
}