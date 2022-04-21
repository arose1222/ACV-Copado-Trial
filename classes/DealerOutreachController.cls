public with sharing class DealerOutreachController {

    /**
     * Returns true or false based on ability for current user to create Retention_Ignition__c records
     * @return  `Boolean`    
     */
    @AuraEnabled
    public static Boolean checkRetentionCreateAccess(){
        return Retention_Ignition__c.sObjectType.getDescribe().isCreateable();
    }

    /**
     * Given an account, this will return true if account is locked in an approval process
     * @param accountId 
     * @return  `Boolean` 
     */
    @AuraEnabled
    public static Boolean checkForLockedAccount(Id accountId){
        return Approval.isLocked(accountId);
    }

    /**
     * Returns the recordtypeId for an Inside Sales task
     * @return  `Id`
     */
    @AuraEnabled
    public static Id getInsideSalesRecordTypeId(){
        return Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Inside_Sales').getRecordTypeId();
    }
    
    /**
     * Inserts a retention_ignition__c record from the dealerOutreach LWC
     * @param jsonString    The data that will be used to create retention_ignition__c record
     * @return  `Id`        Returns the ID of the record created
     */
    @AuraEnabled
    public static Id createRetention(String jsonString){
        try {
            NewRetentionIgnition retentionDetails = (NewRetentionIgnition)JSON.deserialize(jsonString, NewRetentionIgnition.class);
            String activityStatus = [SELECT Id, Account_Activity_Status__c FROM Account WHERE Id = :retentionDetails.account].Account_Activity_Status__c;
            Retention_Ignition__c retentionRecord = new Retention_Ignition__c
                (
                    AccountName__c = retentionDetails.account,
                    ContactName__c = retentionDetails.contact,
                    DateOfCall__c = System.today(),
                    Dealer_Comments__c = retentionDetails.comments,
                    Call_Direction__c = retentionDetails.direction,
                    No_Answer__c = retentionDetails.noAnswer,
                    Type__c = retentionDetails.callType,
                    Next_Steps__c = retentionDetails.nextSteps,
                    Latest_ACV_Experience__c = retentionDetails.experience,
                    Account_Activity_Status__c = activityStatus
                );
            insert retentionRecord;

            if(retentionDetails.nextSteps != null){
                update new Account(Id = retentionDetails.account, Account_Management_Next_Steps__c = retentionDetails.nextSteps);
            }
            return retentionRecord.Id;
            
        } 
        catch (Exception e) {
            SplunkHelper.buildAndProcessLog( createLog( SplunkHelper.LOGLEVEL.FATAL, e.getMessage(), e.getStackTraceString(), ACVUtility.currentLineNumber()) );
            return null;
        }
    }

    public class NewRetentionIgnition { //object for inbound data
        public String account;
        public String contact;
        public String comments;
        public String direction;
        public String noAnswer;
        public String callType;
        public String nextSteps;
        public String experience;
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
        log.sfObject = 'Retention_Ignition__c';
        log.version = 'v1';
        log.componentName = 'LWC - DealerOutreach';
        log.location = 'DealerOutreachController Line #' + String.valueOf(lineNumber);
        log.message = message;
        log.stackTrace = stackTrace;
        log.logLevel = loglevel;
        log.setContext(SplunkHelper.CONTEXT_TYPE.LWC);
        return log;
    }
}