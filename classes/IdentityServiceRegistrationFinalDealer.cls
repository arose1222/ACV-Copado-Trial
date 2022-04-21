@RestResource(urlMapping='/IdentityService/Registration/finalizeDealer')
global class IdentityServiceRegistrationFinalDealer {
    
    @HTTPPatch
    global static void finalizeDealer(dealerInput dealer){
        ACVAPIHelper.SFResponse identityResult = new ACVAPIHelper.SFResponse(dealer, '', 200);
        identityResult.originalRequest = dealer;
        String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/services/IdentityService/Registration/finalizeDealer';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');

        if(String.isBlank(dealer.orgId)){
            //throw error
            identityResult.message = 'Provided Dealer Id is Blank';
            identityResult.statusCode = 401;
            IdentityHelper.makeLog(dealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', 'IdentityServiceRegistrationFinalDealer.finalizeDealer Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 401);
            identityResult.generateResponse(headerMap);
            return;
        }

        List<Account> accList = [SELECT Id, Status__c FROM Account WHERE Dealership_Id__c = :dealer.orgId];
        if(accList.size() < 1){
            //throw error
            identityResult.message = 'Provided Dealer Id Returns no Dealers';
            identityResult.statusCode = 401;
            IdentityHelper.makeLog(dealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', 'IdentityServiceRegistrationFinalDealer.finalizeDealer Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 401);
            identityResult.generateResponse(headerMap);
            return;
        }
        
        accList[0].Status__c = '4';

        try{
            update accList;
            OrganizationChangeEvent.organizationRegisteredEvent(accList);
        }
        catch(Exception e){
            identityResult.message = 'Error Updating Account';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(dealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', e.getStackTraceString()+':'+e.getMessage(), SplunkHelper.LOGLEVEL.ERROR, 500);
            identityResult.generateResponse(headerMap);
            return;
        }

        identityResult.message = 'Account Updated';
        identityResult.statusCode = 201;
        identityResult.apiResponse = dealer;
        IdentityHelper.makeLog(dealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', 'IdentityServiceRegistrationFinalDealer.finalizeDealer Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.INFO, 201);
        identityResult.generateResponse(headerMap);
    }

    global class dealerInput{
        global String userId;
        global String orgId; 
    }
}