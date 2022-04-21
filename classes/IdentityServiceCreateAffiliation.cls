/*
 * 
 * 10/11/2021 - Ravi Shukla (Anablock) - New value 'back office staff member' added for type field in condition.
 * 
*/

@RestResource(urlMapping='/IdentityService/affiliationcreate')
global class IdentityServiceCreateAffiliation {
 
    @HTTPPost
    global static void createAffiliation(affiliate affiliate){
        String affID = IdentityHelper.createAffiliationId(affiliate.dealerId, affiliate.userId);
        ACVAPIHelper.SFResponse identityResult = new ACVAPIHelper.SFResponse(affiliate, '', 200);
        identityResult.originalRequest = affiliate;
        String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/services/identityservice/updatedealer';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');
        List<Account> accList = new List<Account>([SELECT ID FROM ACCOUNT WHERE Dealership_ID__c = :affiliate.dealerId]);
        List<Contact> conList = new List<Contact>([SELECT ID FROM CONTACT WHERE Id__c = :affiliate.userId]);


        if([Select Id From Affiliation__c WHERE id__c = :affId AND Active__c = TRUE].size() >= 1){
            identityResult.message = 'Active Affiliation Exists For Found For That UserId/DealerId Combination';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(affiliate, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST','IdentityServiceCreateAffiliation:'+identityResult.message, SplunkHelper.LOGLEVEL.FATAL, 500);
            identityResult.generateResponse(headerMap);
            return;
        }
        if(accList.size() == 0){
            identityResult.message = 'No Dealer Found with that Dealer Id';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(affiliate, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityServiceCreateAffiliation:'+identityResult.message, SplunkHelper.LOGLEVEL.FATAL, 500);
            identityResult.generateResponse(headerMap);
            return;
        }
        if(conList.size() == 0){
            identityResult.message = 'No User Found with that User Id';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(affiliate, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityServiceCreateAffiliation:'+identityResult.message, SplunkHelper.LOGLEVEL.FATAL, 500);
            identityResult.generateResponse(headerMap);
            return;
        }
        if(affiliate.type != 'rep' && affiliate.type != 'admin' && affiliate.type != 'backoffice'){
            identityResult.message = 'Only accepted Affiliate Types are "rep", "admin" and "backoffice"';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(affiliate, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityServiceCreateAffiliation:'+identityResult.message, SplunkHelper.LOGLEVEL.FATAL, 500);
            identityResult.generateResponse(headerMap);
            return;
        }
        try{
            insert new Affiliation__c(type__c = affiliate.type, id__c = affID, Account__c = accList[0].id, Contact__c = conList[0].id, Active__c = true, Start_Date__c = System.Today());
        }
        catch(Exception e){
            identityResult.message = 'Error Creating new Affiliation';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(affiliate, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', e.getStackTraceString()+':'+e.getMessage(), SplunkHelper.LOGLEVEL.FATAL, 500);
            identityResult.generateResponse(headerMap);
            return;
        }
        identityResult.message = 'Affiliation Created';
        identityResult.statusCode = 201;
        identityResult.apiResponse = affiliate;
        IdentityHelper.makeLog(affiliate, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', 'IdentityService.createAffiliation Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.INFO, 201);
        identityResult.generateResponse(headerMap);
    }

    global class affiliate{
        global string userId;
        global string dealerId;
        global string type;
    }
}