/**
 * This is the Controller for RateCardApprovalButtons
 * @author James Andre LaCour
 * @since May 4th, 2021
 */
public without sharing class RateCardApprovalButtonsCont {
    /**
     * The DeveloperName of the Queue that can Approve Rate Cards
     */
    @TestVisible private static final String RATE_CARD_APPROVER_QUEUE_DEVELOPER_NAME = 'Rate_Card_Approver';
    /**
     * Checks to confirm if the running user is in the Queue to Approve Rate Cards
     * And that this Rate Card is in Proper Approval process
     * @param recordId 
     * @return  `Boolean` whether this user can see the component
     */
    @AuraEnabled
    public static Boolean checkApprovalPermissions( String recordId ){
        Boolean hasApproverRights = false;
        List<Rate_Card__c> rcList = [ SELECT Id, Approval_Status__c FROM Rate_Card__c WHERE Id = :recordId ];
        if( rcList[0].Approval_Status__c == 'In Review'){
            List<GroupMember> queueMemberList = [ SELECT Id FROM GroupMember WHERE Group.DeveloperName = :RATE_CARD_APPROVER_QUEUE_DEVELOPER_NAME AND UserOrGroupId = :UserInfo.getUserId() ];
            List<ProcessInstanceWorkitem> piw = [ SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :recordId LIMIT 1 ];
            hasApproverRights = !queueMemberList.isEmpty() && !piw.isEmpty();
        }
        return hasApproverRights;
    }
    /**
     * This will send the RateCard to the endpoint and if successful,
     * approval the Salesforce record
     * @param comments - approval comments
     * @param recordId - recordId of the page the buttons appear on
     * @return  `String` JSON string indicating if errored and message
     */
    @AuraEnabled
    public static String approve( String comments, String recordId ){
        ReturnWrapper rw = new ReturnWrapper();
        // Gather data to hit endpoint
        String acvIdOfRunningUser = ACVUtility.getAcvUserId( new Set<String>{UserInfo.getUserEmail()} )?.get(UserInfo.getUserEmail())?.Id__c;
        if( String.isBlank(recordId) || String.isBlank(acvIdOfRunningUser) ){
            rw.message = 'There was an issue with the Record Id passed in, please refresh and try again.';
            rw.hasError = true;
            return JSON.serialize(rw);
        }
        List<Rate_Card__c> rcList = [ SELECT Id, Display_Name__c, Fee_Type__c, CreatedById, CreatedBy.Id__c, (SELECT Id, Price_Min__c, Fee_Charged__c FROM Rate_Card_Fees__r ORDER BY Price_Min__c ASC) FROM Rate_Card__c WHERE Id = :recordId ];
        String errorMessage = validateRateCardFees( rcList[0].Rate_Card_Fees__r );
        if( String.isNotBlank(errorMessage) ){
            rw.message = errorMessage;
            rw.hasError = true;
            return JSON.serialize(rw);
        }
        //Auth Endpoint then Payment Endpoint
        try{
            HttpRequest req = RateCardApi.createHttpRequestPublishRateCard( rcList[0], acvIdOfRunningUser );
            HttpResponse res = new Http().send(req);
            // On API Success
            if( res.getStatusCode() < 300 && res.getStatusCode() >= 200 ){
                RateCardApi.PublishRateCardResponse prcRes = (RateCardApi.PublishRateCardResponse)JSON.deserialize( res.getBody(), RateCardApi.PublishRateCardResponse.class );
                rcList[0].ACV_Id__c = String.valueOf( prcRes.data.id );
                update rcList;
                Approval.ProcessWorkitemRequest pwr = createApprovalProcessSubmission( comments, recordId, 'Approve');
                Approval.ProcessResult result = Approval.process(pwr);
                if( !result.isSuccess() ){
                    rw.hasError = true;
                    rw.message = 'There was an issue saving this Rate Card. A Salesforce Admin has been notified. Please do not hit approve again and wait until a Salesforce Admin has reached out.';
                    SplunkHelper.buildAndProcessLog( createLog( SplunkHelper.LOGLEVEL.FATAL, 'Approving Rate card failed when the Rate Card endpoint passed', 'Attempted to be approved by Salesforce User Id:' + UserInfo.getUserId(), ACVUtility.currentLineNumber(), recordId) );
                }
                SplunkHelper.buildAndProcessIntegrationLog( createLog( SplunkHelper.LOGLEVEL.INFO, 'Successfully Published Rate Card', 'Approved by Salesforce User Id:' + UserInfo.getUserId(), ACVUtility.currentLineNumber(), recordId), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
            // On API Failure
            }else{
                rw.hasError = true;
                rw.message = 'There was an issue when processing this request. A Salesforce Admin has been notified.';
                SplunkHelper.buildAndProcessIntegrationLog( createLog( SplunkHelper.LOGLEVEL.ERROR, 'Rate Card Publish Endpoint returned an error', 'Attempted to be approved by Salesforce User Id:' + UserInfo.getUserId(), ACVUtility.currentLineNumber(), recordId), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
            }
        }catch( Exception ex ){

            rw.hasError = true;
            rw.message = ' There was an issue when processing this request. A Salesforce Admin has been notified.';
            SplunkHelper.buildAndProcessLog( createLog( SplunkHelper.LOGLEVEL.FATAL, ex.getMessage(), ex.getStackTraceString(), ACVUtility.currentLineNumber(), recordId) );
        }
        return JSON.serialize(rw);
    }
    /**
     * Rejects the Rate Card and submits it to the Approval Process
     * @param comments - rejection comments
     * @param recordId - recordId of the page the buttons appear on
     * @return  `String` JSON string indicating if errored and message
     */
    @AuraEnabled
    public static String reject( String comments, String recordId ){
        ReturnWrapper rw = new ReturnWrapper();
        Approval.ProcessWorkitemRequest pwr = createApprovalProcessSubmission( comments, recordId, 'Reject');
        Approval.ProcessResult result = Approval.process(pwr);
        if( !result.isSuccess() ){
            rw.hasError = true;
            rw.message = 'There was an issue rejecting this Rate Card. Please refresh the page and try again.';
        }
        return JSON.serialize(rw);
    }
    /**
     * EXPECTS ORDERED BY PRICE_MIN__C ASC.
     * Validates whether the Rate Card Fees follow the required Validation:
     * Attached fees are a set of tuples: { (p1, f1), (p2, f2), … (pN, fN) } where p1 < p2 < … < pN and f1 ≤ f2 ≤ … ≤ fN
     * @param rcFeesList 
     * @return  `String` - errorMessage. If everything passed, errorMessage will be blank
     */
    public static String validateRateCardFees( List<Rate_Card_Fee__c> rcFeesList ){
        String errorMessage = '';
        if( rcFeesList.size() > 0 ){
            for( Integer i=0; i< rcFeesList.size(); i++ ){
                if( i == 0 ){
                    if( rcFeesList[i].Price_Min__c != 1 ){
                        errorMessage = 'At least one rate card must have a Price Minimum of $1';
                        break;
                    }
                }else{
                    if( rcFeesList[i].Price_Min__c == rcFeesList[i-1].Price_Min__c ){
                        errorMessage = 'There is a duplicate Price Minimum for the Price Minimum $' + String.valueOf(rcFeesList[i].Price_Min__c);
                    }else if( rcFeesList[i].Fee_Charged__c <= rcFeesList[i-1].Fee_Charged__c ){
                        errorMessage = 'The Fee Chagred for Price Minimum $' + String.valueOf(rcFeesList[i].Price_Min__c) + ' has to be greater than the previous tier Price Minimum $' + String.valueOf(rcFeesList[i].Price_Min__c);
                    }
                }
            }
        }else{
            errorMessage = 'There are no Rate Card Fees attached to the Rate Card';
        }
        return errorMessage;
    }
    /**
     * Helper to create the Approval Process Submission request
     * @param comments comments for approval/rejection
     * @param recordId recordId of Rate Card in question
     * @param actionType Either Approve or Reject
     * @return  `Approval.ProcessWorkitemRequest`
     */
    public static Approval.ProcessWorkitemRequest createApprovalProcessSubmission( String comments, String recordId, String actionType ){
        ProcessInstanceWorkitem piw = [ SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :recordId LIMIT 1 ];
        Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
        pwr.setComments(comments);
        pwr.setAction(actionType);
        pwr.setWorkitemId(piw.Id);
        return pwr;
    }
    /**
     * Creates SplunkHelper Log
     * @param loglevel - ERROR, FATAL, INFO, DEBUG, WARN, or PERFORMANCE
     * @param message - error message
     * @param stackTrace - Full Detailed Stack Trace
     * @param lineNumber - Line Number that the error has happened on
     * @param record - record ids
     * @return SplunkHelper.log
     */
    public static SplunkHelper.Log createLog( SplunkHelper.LOGLEVEL loglevel, String message, String stackTrace, Integer lineNumber, String recordId ){
        SplunkHelper.Log log = new SplunkHelper.log();
        log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.MARKETPLACE};
        log.sfObject = 'Rate Card';
        log.version = 'v1';
        log.componentName = 'LWC - Rate Card Approval Buttons';
        log.location = 'RateCardApprovalButtonsCont Line #' + String.valueOf(lineNumber);
        log.message = message;
        log.stackTrace = stackTrace;
        log.logLevel = loglevel;
        log.sfRecordId = recordId;
        log.setContext(SplunkHelper.CONTEXT_TYPE.LWC);
        return log;
    }
    
    /**
     * ReturnWrapper for the LWC component
     */
    public class ReturnWrapper{
        public String message;
        public Boolean hasError;
        public ReturnWrapper(){
            message = '';
            hasError = false;
        }
    }
}