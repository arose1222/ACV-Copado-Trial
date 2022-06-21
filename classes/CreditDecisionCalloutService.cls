/**
 * @description Service Class that handle calls to the credit decision process. Currently calls the Salesforce Gateway that calls Line of Credit. 
 * @author Oscar Argueyo
 * @since 06/16/2022
 * @group Capital
 * @see [CSO-660]https://acvauctions.atlassian.net/browse/CSO-660
 */
public class CreditDecisionCalloutService {
    
    /**
     * Method that manages the logic and initiate the Credit Decision Process if it match certain criteria.
     * @param oldMap - Map<Id,Opportunity> New Instances of Opportunities affected by the Apex Trigger
     * @param newMap - Map<Id,Opportunity> Old Instances of Opportunities affected by the Apex Trigger
     * @return void
     */
    public static void initOpportunityCreditDecisionProcess(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
        for (Opportunity opportunity : newMap.values()) {
            Id opptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ACV_Capital_Referral').getRecordTypeId();
            if (opportunity.RecordTypeId == opptyRecordTypeId && opportunity.Capital_Credit_Decisioning__c && !oldMap.get(opportunity.Id).Capital_Credit_Decisioning__c) {
                opportunity.AdditionalComments__c = 'Credit Decision Proccess Initiated';
                CreditDecisionCalloutService.makeCallout((String)opportunity.id);
            }
        }
    }
    
    /**
     * Future callout method that calls the Capital Line of Credit Service through the Salesforce Gateway for starting the credit decision process.
     * @param opportunityID - String - Opportunity ID 
     * @return void
     */
    @future(callout=true)
    public static void makeCallout(String opportunityID) {
        try{
            String message = 'Credit Decision Proccess Finished';
            // Getting Request Body for the service
            JSONGenerator applicationData = getCreditDecisionRequestBody(opportunityID);        
            // Getting endpoint information for making the request
            ACV_Credit_decision__mdt creditDecisionData =  getCreditDecisionCustomMDT();
            callCreditDecisionService(applicationData.getAsString(), creditDecisionData.Endpoint_URL__c);
            if(!Test.isRunningTest()) {
            	SplunkHelper.buildAndProcessLog(createLog(SplunkHelper.LOGLEVEL.INFO, message+' for Opportunity '+opportunityID, '-', ACVUtility.currentLineNumber()));
            }
            updateOpportunityComment(opportunityID , message);
        }catch(CreditDecisionCalloutException ex){
            if(!Test.isRunningTest()) {
            	SplunkHelper.buildAndProcessLog( createLog( SplunkHelper.LOGLEVEL.ERROR, ex.getMessage(), ex.getStackTraceString(), ACVUtility.currentLineNumber()));
            }
            updateOpportunityComment(opportunityID , ex.getMessage());
        }
    }
    
    /**
     * Get custom metadata type for obtain Experian Base URL and others custom fields.
     * @return Fast_Pass_Experian_Credential__mdt
     */
    public static ACV_Credit_decision__mdt getCreditDecisionCustomMDT(){
        ACV_Credit_decision__mdt acvCreditDecisionData = ACV_Credit_decision__mdt.getInstance('automated_credit_decision');
        return acvCreditDecisionData;
    }
    
     /**
     * Method that manages the logic and initiate the Credit Decision Process if it match certain criteria.
     * @param oldMap - Map<Id,Opportunity> New Instances of Opportunities affected by the Apex Trigger
     * @param newMap - Map<Id,Opportunity> Old Instances of Opportunities affected by the Apex Trigger
     * @return void
     */
    public static JSONGenerator getCreditDecisionRequestBody(String opportunity_id){
        List <Application__c> applications = [SELECT Id, Name, Opportunity__c, 
                                              Bank_Address__c, Bank_City__c, Bank_Zip__c,  Bank_State__c , Bank_Phone_Number__c,
                                              Account__r.BillingStreet, Account__r.BillingState, Account__r.BillingCity, 
                                              Account__r.BillingPostalCode, Account__r.Dealer_Phone__c, Account__r.Tax_ID__c
                                              FROM Application__c WHERE Opportunity__c = :opportunity_id LIMIT 1];
		
        if (applications.isEmpty() == false){
            return getInputBodyForApplications(applications[0]);
        }
        throw new CreditDecisionCalloutException('Application not found for this Opportunity');
    }
    
     /**
     * Method that creates the json object from the Application Informacion and its principals.
     * @param applicationObj - Application__c Instance of an Application_c object
     * @return JSONGenerator with the information requested by the endpoint.
     */
    public static JSONGenerator getInputBodyForApplications(Application__c applicationObj){
        
        List<Principal__c> principals = getPrincipalsForApplication(applicationObj);
        
        JSONGenerator application = JSON.createGenerator(true);
        application.writeStartObject();      
        application.writeFieldName('data');
        application.writeStartObject();
        application.writeFieldName('business');
        application.writeStartObject();
        application.writeStringField('ref_id', String.valueOf(applicationObj.Opportunity__c));
        application.writeStringField('app_id', String.valueOf(applicationObj.Id));
        application.writeStringField('name', String.valueOf(applicationObj.Name));
        if (applicationObj.Account__r.Tax_ID__c != null){
            application.writeStringField('taxId', String.valueOf(applicationObj.Account__r.Tax_ID__c));
        }else{
            application.writeStringField('taxId', '');
        }
        application.writeFieldName('bank_address');
        application.writeStartObject();
        if (applicationObj.Bank_Address__c != null){
            application.writeStringField('street', applicationObj.Bank_Address__c);
        }else{
            application.writeStringField('street', '');
        }
        if (applicationObj.Bank_City__c != null){
            application.writeStringField('city', applicationObj.Bank_City__c);
        }else{
            application.writeStringField('city', applicationObj.Bank_City__c);
        }
        if (applicationObj.Bank_Zip__c != null){
            application.writeStringField('state', applicationObj.Bank_State__c);
        }else{
            application.writeStringField('state', applicationObj.Bank_State__c);
        }
        
        if (applicationObj.Bank_Zip__c != null){
            application.writeStringField('zip', applicationObj.Bank_Zip__c);                
        }else{
            application.writeStringField('zip', '');
        }
        if (applicationObj.Bank_Phone_Number__c != null){
            application.writeStringField('phone', applicationObj.Bank_Phone_Number__c);
        }else{
            application.writeStringField('phone', '');
        }
        
        application.writeEndObject(); // end business address
        application.writeFieldName('business_address');
        application.writeStartObject();
        if (applicationObj.Account__r.BillingStreet != null){
            application.writeStringField('street', applicationObj.Account__r.BillingStreet); 
        }
        if (applicationObj.Account__r.BillingCity != null){
            application.writeStringField('city', applicationObj.Account__r.BillingCity);
        }
        if (applicationObj.Account__r.BillingState != null){
            application.writeStringField('state', applicationObj.Account__r.BillingState);
        }
        if (applicationObj.Account__r.BillingPostalCode != null){
            application.writeStringField('zip', applicationObj.Account__r.BillingPostalCode);
        }
        if (applicationObj.Account__r.Dealer_Phone__c != null){
            application.writeStringField('phone', applicationObj.Account__r.Dealer_Phone__c);
            
        }
        application.writeEndObject(); // end business address
        application.writeEndObject(); // end business
        application.writeFieldName('owners');
        application.writeStartArray();
        
        if (principals.isEmpty() == false){
            for (Principal__c principal: principals){
                
                application.writeStartObject();
                application.writeStringField('ref_id', String.valueOf(principal.Id));
                if (principal.Principal_Type__c != null){
                    application.writeStringField('owner_type', String.valueOf(principal.Principal_Type__c));
                }
                if (principal.OwnerTitle__c != null){
                    application.writeStringField('owner_title', String.valueOf(principal.OwnerTitle__c));
                }
                if (principal.Owner_Name__r != null){
                    application.writeStringField('first_name', String.valueOf(principal.Owner_Name__r.FirstName));
                }
                if (principal.Owner_Name__r.MiddleName != null){
                    application.writeStringField('middle_name', String.valueOf(principal.Owner_Name__r.MiddleName));
                }
                if (principal.Owner_Name__r.LastName != null){
                    application.writeStringField('last_name', String.valueOf(principal.Owner_Name__r.LastName));
                }
                if (principal.SSN__c != null){
                    application.writeStringField('ssn', String.valueOf(principal.SSN__c));
                }
                if (principal.Principal_Date_of_BIrth_c__c != null){
                    application.writeStringField('dob', String.valueOf(principal.Principal_Date_of_BIrth_c__c));
                }
                if (principal.principalHome_Address__c != null){
                    application.writeStringField('street', principal.principalHome_Address__c);
                }
                if (principal.State__c != null){
                    application.writeStringField('state', principal.State__c);
                }
                if (principal.City__c != null){
                    application.writeStringField('city', principal.City__c);
                }
                if (principal.Z__c != null){
                    application.writeStringField('zip_code', principal.Z__c);
                }
                if (principal.principalPhone__c != null){
                    application.writeStringField('phone', principal.principalPhone__c);
                }
                if (principal.Ownership__c != null){
                    application.writeStringField('ownership', String.valueOf(principal.Ownership__c));
                }
                
                application.writeEndObject(); // end principal object
            }
        }
        application.writeEndArray(); // end owners list
        application.writeEndObject(); //end data object
        application.writeEndObject(); //End json object
        application.close();
        return application;
    }
    

     /**
     * Method that creates the json object from the Application Informacion and its principals.
     * @param applicationObj - Application__c Instance of an Application_c object
     * @return List<Principal__c> list of principals related to an application.
     */
    public static List<Principal__c> getPrincipalsForApplication(Application__c applicationObj){
        
       List<Principal__c> principals = [SELECT Id, Owner_Name__r.FirstName, Owner_Name__r.LastName, Owner_Name__r.MiddleName,
                                         Application__c, Principal_Date_of_BIrth_c__c, SSN__c, OwnerTitle__c , principalHome_Address__c, Principal_Type__c, Ownership__c,  
                                         State__c, City__c, Z__c, principalPhone__c 
                                         from Principal__c where Principal_Type__c = 'Individual' and Application__c = :applicationObj.Id];
        
        return principals;
    }
    
    /**
     * Call Credit Decision Service in Capital Line of Credit (through Salesforce Gateway)
     * @param body of the requests
     * @param url of the endpoint provided by the Salesforce Custom Metadata Type
     * @return nothing
     */
	public static void callCreditDecisionService(String body, String url){
        HttpRequest request = new HttpRequest();
        request.setBody(body);
        request.setEndPoint(url);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        // TODO: Fix Authorization Token for production environment 
        request.setHeader('Authorization', 'eyJvcmciOiI1ZTRmNjNiMmExMzczNDAwMDE3YzU0MGMiLCJpZCI6IjllOGRmZWE3MTI0YjRmOWJiYzRmOWQwMTkwYWJkNGY5IiwiaCI6Im11cm11cjEyOCJ9');
        
        HttpResponse response = new HTTP().send(request);
        if (response.getStatusCode() != 200){
            throw new CreditDecisionCalloutException('Credit Decision Process Failed');
        }
     
    }
    
     /**
     * Update additional comments field in Opportunity with a given message 
     * @param opportunity_id 
     * @param message - Comment message
     * @return void
     */
    public static void updateOpportunityComment(String opportunity_id, String message){
        Opportunity opportunityObj = [SELECT Id, AdditionalComments__c FROM Opportunity WHERE Id = :opportunity_id];
        opportunityObj.AdditionalComments__c = message;
        update opportunityObj;
        
    }
    
    /**
     * Creates SplunkHelper Log
     * @param loglevel - ERROR, FATAL, INFO, DEBUG, WARN, or PERFORMANCE
     * @param message - error message
     * @param stackTrace - Full Detailed Stack Trace
     * @param lineNumber - Line Number that the error has happened on
     * @return SplunkHelper.log
     */
    public static SplunkHelper.Log createLog(SplunkHelper.LOGLEVEL loglevel, String message, String stackTrace, Integer lineNumber){
        SplunkHelper.Log log = new SplunkHelper.log();
        log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.SALES};
        log.sfObject = 'Opportunity';
        log.version = 'v1';
        log.componentName = 'CreditDecisionCalloutService';
        log.location = 'CreditDecisionCalloutService Line #' + String.valueOf(lineNumber);
        log.message = message;
        log.stackTrace = stackTrace;
        log.logLevel = loglevel;
        log.setContext(SplunkHelper.CONTEXT_TYPE.LWC);
        return log;
    }
}