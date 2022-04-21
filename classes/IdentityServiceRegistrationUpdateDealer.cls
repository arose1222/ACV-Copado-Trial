@RestResource(urlMapping='/IdentityService/Registration/updatedealer')
global class IdentityServiceRegistrationUpdateDealer {
    
    @HTTPPatch
    global static void updateDealer(IdentityHelper.dealerRequest dealer){
        List<Account> acc = [SELECT ID, legal_name__c,  Cell__c,Dealer_Type__c, dba_trade_name__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Tax_Id__c, License_Number__c, Phone, Status__c FROM Account WHERE dealership_id__c = :dealer.dealer_id];
        ACVAPIHelper.SFResponse identityResult = new ACVAPIHelper.SFResponse(dealer, '', 200);
        identityResult.originalRequest = dealer;
        String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/services/IdentityService/Registration/updatedealer';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');

        identityResult = IdentityHelper.validateDealerUpdateData(dealer, acc, identityResult);
        if(identityResult.statusCode != 200){
            IdentityHelper.makeLog(dealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', identityResult.message, SplunkHelper.LOGLEVEL.FATAL, identityResult.statusCode);
            identityResult.generateResponse(headerMap);
            return;
        }
        Savepoint sp = Database.setSavePoint();
        try{
            acc = IdentityHelper.processDealerUpdateData(dealer, acc, '3');
            update acc;
        }
        catch(Exception e){
            identityResult.message = 'Error Updating Account';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(dealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', e.getStackTraceString()+':'+e.getMessage(), SplunkHelper.LOGLEVEL.ERROR, 500);
            identityResult.generateResponse(headerMap);
            Database.rollback( sp );
            return;
        }
        identityResult.message = 'Account Updated';
        identityResult.statusCode = 201;
        identityResult.apiResponse = new IdentityHelper.dealerResponse(dealer.dealer_id, String.IsBlank(dealer.legalName)? '' :acc[0].legal_name__c, String.IsBlank(dealer.dbaName)? '' :acc[0].dba_trade_name__c);
        IdentityHelper.makeLog(dealer, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', 'IdentityServiceRegistration.updateDealer Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.INFO, 201);
        identityResult.generateResponse(headerMap);
    }
}