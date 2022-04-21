public with sharing class FslAcvAnywhereOnboardingController {

    public class RegistrationResponse {
        @AuraEnabled public Integer errorId;
        @AuraEnabled public String message;
    }

    public class EligibilityResponse {
        @AuraEnabled public Boolean isAlreadyRegistered;
        @AuraEnabled public Boolean isActiveDealer;
    }


    @AuraEnabled
    public static EligibilityResponse checkEligibility ( Id accountId ) {
        EligibilityResponse response = new EligibilityResponse();

        Account acc = [SELECT Id, ACV_Anywhere_Registration_Date__c, Dealership_ID__c, Active__c FROM Account WHERE Id = :accountId];

        if(acc.Active__c != true || acc.Dealership_ID__c == null){
            response.isActiveDealer = false;
        } else {
            response.isActiveDealer = true;
        }

        if(acc.ACV_Anywhere_Registration_Date__c == null){
            response.isAlreadyRegistered = false;
        }else{
            response.isAlreadyRegistered = true;
        }

        return response;

    }


    @AuraEnabled
    public static RegistrationResponse acvAnywhereRegistrationRequest ( Id accountId ) {
        RegistrationResponse response = new RegistrationResponse();

        Account acc = [SELECT Id, Name, Dealership_ID__c, ACV_Anywhere_Registration_Date__c FROM Account WHERE Id = :accountId];

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1]?.IsSandbox;

        HttpRequest req = new HttpRequest();

        if(isSandbox){
            req.setEndpoint('callout:AsiAcvAnywhereRegDEV');
        }else{
            req.setEndpoint('callout:ASIACVAnywhereReg');
        }

        req.setMethod('POST');
        Http http = new Http();

        String jsonBody = JSON.serialize(
        new Map<String, String> {
        'AcvDealerID' => acc.Dealership_ID__c,
        'CreateUser' => 'FslAcvAnywhereOnboard',
        'DealerName' => acc.Name});
        req.setHeader('Content-Type','application/json');
        req.setHeader('Content-Length',jsonBody.length()+'');
        req.setBody(jsonBody);

        HTTPResponse res = http.send(req);
        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        if(res.getStatusCode() == 200){
            acc.ACV_Anywhere_Registration_Date__c = System.now();
        }
        update acc;

        makeLog(req, res, responseMap, acc);

        response.errorId = Integer.valueOf(responseMap.get('ErrorId'));
        response.message = String.valueOf(responseMap.get('Message'));

        return response;
    }

    public static void makeLog(HttpRequest req, HttpResponse res, Map<String,Object> responseMap, Account acc){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.componentName = 'FslAcvAnywhereOnboardingController';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>();
        infoLog.location = 'FslAcvAnywhereOnboardingController:'+ACVUtility.currentLineNumber();

        if(res.getStatusCode() == 200){
            infoLog.logLevel = SplunkHelper.LOGLEVEL.INFO;
        } else {
            infoLog.logLevel = SplunkHelper.LOGLEVEL.ERROR;
        }

        infoLog.message = String.valueOf(responseMap.get('Message'));
        infoLog.sfObject = 'Account';
        infoLog.sfRecordId = acc.Id;
        infoLog.stackTrace = 'FslAcvAnywhereOnboardingController: '+ACVUtility.currentLineNumber();
        infoLog.version = '1';
        infoLog.setContext(SplunkHelper.CONTEXT_TYPE.LWC);
        SplunkHelper.buildAndProcessIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
    }
}