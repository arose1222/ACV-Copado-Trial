@RestResource(urlMapping='/IdentityService/affiliationdeactivation')
global class IdentityServiceAffiliationDeactivation {
    @testvisible global static boolean causeFailure = false;
    @HTTPPatch
    global static void affiliationDeactivation(affiliate affiliate){
        String affID = affiliate.userId+affiliate.dealerId;
        List<Affiliation__c> affList = [SELECT Id, Active__c, id__c, End_Date__c FROM Affiliation__c 
        WHERE Account__r.Dealership_ID__c = :affiliate.dealerId AND Contact__r.Id__c = :affiliate.userId AND active__c = true LIMIT 1];//id__c = :affId AND Active__c = TRUE LIMIT 1];
        ACVAPIHelper.SFResponse identityResult = new ACVAPIHelper.SFResponse(affiliate, '', 200);
        identityResult.originalRequest = affiliate;
        String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/services/identityservice/updatedealer';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');
        if(affList.size() == 0){
            identityResult.message = 'No Active Affiliation Found For That UserId/DealerId combination';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(affiliate, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', 'IdentityService.affiliationDeactivation Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.FATAL, 500);
            identityResult.generateResponse(headerMap);
            return;
        }

        try{
            affList[0].Active__c = false;
            affList[0].End_Date__c = System.today();
            if(causeFailure) Decimal i = 1/0;
            update affList;
        }
        catch(Exception e){
            identityResult.message = 'Error Updating Affiliation';
            identityResult.statusCode = 500;
            IdentityHelper.makeLog(affiliate, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', e.getStackTraceString()+':'+e.getMessage(), SplunkHelper.LOGLEVEL.FATAL, 500);
            identityResult.generateResponse(headerMap);
            return;
        }

        identityResult.message = 'Affiliation Deactivated';
        identityResult.statusCode = 201;
        identityResult.apiResponse = affiliate;
        IdentityHelper.makeLog(affiliate, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'PATCH', 'IdentityService.affiliationDeactivation Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.INFO, 201);
        identityResult.generateResponse(headerMap);
    }

    global class affiliate{
        global string userId;
        global string dealerId;
    }
}