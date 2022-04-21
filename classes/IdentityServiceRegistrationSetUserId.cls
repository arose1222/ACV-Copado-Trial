@RestResource(urlMapping='/IdentityService/Registration/setUserIdentityId')
global class IdentityServiceRegistrationSetUserId {

    @HTTPPatch
    global static void setUserIdentityId(userUpdate userObj){
        ACVAPIHelper.SFResponse identityResult = new ACVAPIHelper.SFResponse(userObj, '', 200);
        identityResult.originalRequest = userObj;
        String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/services/identityservice/setUserIdentityId';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');

        if(String.isBlank(userObj.userId)){
            //do error here to let us know config isn't working
            identityResult.message = 'Provided User Id is Blank';
            identityResult.statusCode = 401;
            IdentityHelper.makeLog(userObj, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', 'IdentityServiceRegistrationSetUserId.setUserIdentityId Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 501);
            identityResult.generateResponse(headerMap);
            return;
        }

        if(String.isBlank(userObj.identityId)){
            //do error here to let us know config isn't working
            identityResult.message = 'Provided Identity Id is Blank';
            identityResult.statusCode = 401;
            IdentityHelper.makeLog(userObj, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', 'IdentityServiceRegistrationSetUserId.setUserIdentityId Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 501);
            identityResult.generateResponse(headerMap);
            return;
        }

        List<Contact> conList = [SELECT ID, Identity_Id__c FROM Contact WHERE ID__c = :userObj.userId];
        if(conList.size() < 1){
            identityResult.message = 'Provided User Id Can Not Be Found';
            identityResult.statusCode = 501;
            IdentityHelper.makeLog(userObj, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', 'IdentityServiceRegistrationSetUserId.setUserIdentityId Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 501);
            identityResult.generateResponse(headerMap);
            return;
        }

        conList[0].Identity_Id__c = userObj.identityId;

        try{
            update conList;
        }
        catch(Exception e){
            identityResult.message = 'Error Updating User';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(userObj, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', e.getStackTraceString()+':'+e.getMessage(), SplunkHelper.LOGLEVEL.FATAL, 500);
            identityResult.generateResponse(headerMap);
            return;
        }
        identityResult.message = 'User Updated';
        identityResult.statusCode = 201;
        identityResult.apiResponse = userObj;
        IdentityHelper.makeLog(userObj, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', 'IdentityService.setUserIdentityId Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.INFO, 201);
        identityResult.generateResponse(headerMap);
    }

    global class userUpdate{
        global String userId;
        global String identityId;
    }
}