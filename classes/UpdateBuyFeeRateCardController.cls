/** 
 * Controller class for updateBuyFeeRateCard LWC
 **/
public class UpdateBuyFeeRateCardController {
    static string eligibleRateCardFeeType='buy_fee';
    static List<string> ineligibleApprovalStatus = new List<string>{'Draft', 'In Review'};
    static List<string> ineligibleRateCardState = new List<string>{'Legacy', 'Archived'};
    @TestVisible static final String PUBLISH_RATE_CARD_ENDPOINT_SUFFIX = '/api/v1/ratecards/';
   
   /** 
    * Returns active and published buy fee rate cards
    **/
    @AuraEnabled
    public static List<Rate_Card__c> GetRateCards(){
        
        List<Rate_Card__c> rateCardList = [SELECT Id, Name, Display_Name__c FROM Rate_Card__c WHERE Fee_Type__c=:eligibleRateCardFeeType 
                                            and Approval_Status__c not in:ineligibleApprovalStatus 
                                            and Rate_Card_State__c not in:ineligibleRateCardState];
        return rateCardList;
    }

    /** 
     * Updates buy fee rate for an account
     **/
    @AuraEnabled
    public static String UpdateBuyFeeRateCard(Id recordId, Id rateCard){
        ReturnWrapper rw = new ReturnWrapper();
        try{
            // Check if running user is an ACV User
            String acvIdOfRunningUser = ACVUtility.getAcvUserId( new Set<String>{UserInfo.getUserEmail()} )?.get(UserInfo.getUserEmail())?.Id__c;
            if(String.isBlank(acvIdOfRunningUser) || !acvIdOfRunningUser.isNumeric())
            {
                SplunkHelper.buildAndProcessLog( createLog( SplunkHelper.LOGLEVEL.FATAL, 'Attempting to update the buy fee rate card. ACV User Id is not present for:'+UserInfo.getUserEmail() , '', ACVUtility.currentLineNumber(), recordId) );
                rw.hasError= true;
                rw.message= 'ACV User Id is missing for the User. Please contact a System Admin';
                return JSON.serialize(rw);
            } 

            // Check if Dealership_ID__c is present for the dealer
            List<Account> accountRecords = [SELECT Name, Dealership_ID__c, Buy_Fee_Rate_Card__c FROM Account WHERE Id=:recordId];
            Integer dealershipId= 0;
            if(!accountRecords.isEmpty() && !String.IsBlank(accountRecords[0].Dealership_ID__c) && accountRecords[0].Dealership_ID__c.isNumeric())
            {
                dealershipId= integer.valueOf(accountRecords[0].Dealership_ID__c);
            }
            if(dealershipId == 0)
            {
                SplunkHelper.buildAndProcessLog( createLog( SplunkHelper.LOGLEVEL.FATAL, 'Attempting to update the buy fee rate card. Dealership ID is missing on the Account Record', 'UpdateBuyFeeRateCardController: Line number 26', ACVUtility.currentLineNumber(), recordId) );
                rw.hasError= true;
                rw.message= 'Dealership ID missing on the Account Record. Please contact a System Admin';
                return JSON.serialize(rw);
            } 

            // Check if the rate card has an ACV Id
            List<Rate_Card__c> rateCardList = [SELECT Id, Name, Display_Name__c, ACV_Id__c FROM Rate_Card__c WHERE Id=:rateCard];
            if(rateCardList.isEmpty() || String.isBlank(rateCardList[0].ACV_Id__c))
            {
                SplunkHelper.buildAndProcessLog( createLog( SplunkHelper.LOGLEVEL.FATAL, 'Attempting to update the buy fee rate card. Rate Card does not have ACV ID assigned.', '', ACVUtility.currentLineNumber(), recordId) );
                rw.hasError= true;
                rw.message= 'Rate Card Does not have ACV ID assigned. Please contact a System Admin';
                return JSON.serialize(rw);
            } 
         
            // Make a callout
            HttpResponse res = new HttpResponse();
            HttpRequest req= createHTTPRequest(rateCardList[0].ACV_Id__c, dealershipId, Integer.valueOf(acvIdOfRunningUser));
            try{
                res = new HTTP().send(req);
            }
            catch(Exception ex){
                SplunkHelper.buildAndProcessLog( createLog( SplunkHelper.LOGLEVEL.FATAL, ex.getMessage(), ex.getStackTraceString(), ACVUtility.currentLineNumber(), recordId) );
                rw.hasError= true;
                rw.message= 'Attempt to update the buy fee rate card failed with an exception. Please contact System Administrator. Exception Message:'+ ex.getMessage();
                return JSON.serialize(rw);
            }
            // If callout is success
            if( res.getStatusCode() < 300 && res.getStatusCode() >= 200 ){
                accountRecords[0].Buy_Fee_Rate_Card__c= rateCard;
                update accountRecords;
                SplunkHelper.buildAndProcessIntegrationLog( createLog( SplunkHelper.LOGLEVEL.INFO, 'Successfully update the Rate Card', 'Updated by Salesforce User Id:' + UserInfo.getUserId(), ACVUtility.currentLineNumber(), recordId), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
                rw.hasError= false;
                rw.message= 'Successfully update the Rate Card';
                return JSON.serialize(rw);
            }
            else{ // If callout is not success
                SplunkHelper.buildAndProcessIntegrationLog( createLog( SplunkHelper.LOGLEVEL.ERROR, 'Attempt to update the buy fee rate card failed with an error', 'Attempted by Salesforce User Id:' + UserInfo.getUserId(), ACVUtility.currentLineNumber(), recordId), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
                rw.hasError= true;
                rw.message= 'Attempt to update the buy fee rate card failed with an exception in the gateway. Please contact a system administrator.';
                return JSON.serialize(rw);
            }
        }
        catch(Exception ex){
            SplunkHelper.buildAndProcessLog( createLog( SplunkHelper.LOGLEVEL.FATAL, ex.getMessage(), ex.getStackTraceString(), ACVUtility.currentLineNumber(), recordId) );
            rw.hasError= true;
            rw.message= 'Attempt to update the buy fee rate card failed with an exception. Please contact System Administrator.';
            return JSON.serialize(rw);
        }
    }
   /** 
    * Returns Http request for the callout
    **/
    private static HttpRequest createHTTPRequest(string rateCardACVId, Integer organizationId, Integer acvUserId)
    {
        HttpRequest req = new HttpRequest();
        req.setHeader( 'Content-Type', 'application/json');
        req.setHeader('Authorization', '{!$Credential.Password}');
        Map <String, Integer> mapping = New Map<String, Integer>();
        mapping.put('organizationId', organizationId);	
        mapping.put('createdBy', acvUserId);
        string endpoint= PUBLISH_RATE_CARD_ENDPOINT_SUFFIX+ rateCardACVId;
        req.setEndpoint('callout:Salesforce_Gateway' + endpoint);
        req.setBody(json.serialize(mapping));
        req.setMethod('PUT');
        req.setTimeout(120000);
        return req;
    }

    /** 
    * Returns Log request for Splunk
    **/
    public static SplunkHelper.Log createLog( SplunkHelper.LOGLEVEL loglevel, String message, String stackTrace, Integer lineNumber, String recordId ){
        SplunkHelper.Log log = new SplunkHelper.log();
        log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.MARKETPLACE};
        log.sfObject = 'Account';
        log.version = 'v1';
        log.componentName = 'LWC - Update Buy Fee Rate Card';
        log.location = 'UpdateBuyFeeRateCardController Line #' + String.valueOf(lineNumber);
        log.message = message;
        log.stackTrace = stackTrace;
        log.logLevel = loglevel;
        log.sfRecordId = recordId;
        return log;
    }

    /** 
    * Response Wrapper to the LWC
    **/
    public class ReturnWrapper{
        public String message;
        public Boolean hasError;
        public ReturnWrapper(){
            message = '';
            hasError = false;
        }
    }
}