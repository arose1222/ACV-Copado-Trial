/**
 * This class is the Controller for the ParticipatingDealershipGroupsRL LWC
 * @author James Andre LaCour
 */
public class ParticipatingDealershipGroupsRLCont {
    /*************AuraEnabled Methods**************/
    /**
     * Gets all the Private Lane Access a Private Labe has
     * @param recordId - the record Id of the Private Lane this is on
     * @return JSON Serialized ReturnWrapper
     */
    @AuraEnabled
    public static string getPrivateLaneAccess( String recordId ){
        ReturnWrapper rw = new ReturnWrapper();
        try{
            if( String.isNotBlank(recordId) ){
                rw.plaList = [ SELECT Id, Buying_Power__c, Selling_Power__c, Organization_Group__c, Organization_Group__r.Name
                            FROM Private_Lane_Access__c 
                            WHERE Private_Lane__c = :recordId ];
                if( rw.plaList.isEmpty() ){
                    try{
                        Id tempId = Id.valueOf(recordId);
                    }catch( Exception ex ){
                        SplunkHelper.buildAndProcessLog( createLog(SplunkHelper.LOGLEVEL.FATAL, 'Id given but no record found', 'Running Salesforce User Id: ' + UserInfo.getUserId(), ACVUtility.currentLineNumber(), recordId) );
                    }
                }
            }else{
                rw.hasError = true;
                rw.message = 'Please contact a Salesforce Admin';
                SplunkHelper.buildAndProcessLog( createLog(SplunkHelper.LOGLEVEL.ERROR, 'RecordId is blank', 'Running Salesforce User Id: ' + UserInfo.getUserId(), ACVUtility.currentLineNumber(), UserInfo.getUserId()) );
            }
        }catch( Exception ex ){
            // Considered Fatal as it could mean recordId is not properly populating from Salesforce and needs to be investigated into
            rw.hasError = true;
            rw.message = 'Please contact your Salesforce Admin';
            SplunkHelper.buildAndProcessLog( createLog(SplunkHelper.LOGLEVEL.FATAL, ex.getMessage(), ex.getStackTraceString(), ACVUtility.currentLineNumber(), recordId) );
        }
        return JSON.serialize(rw);
    }
    /**
     * Deletes the Private Lane Access that was selected
     * @param privateAccessId - the record Id of the Private Lane Access
     * @return JSON Serialized ReturnWrapper
     */
    @AuraEnabled
    public static string deletePLA( String privateAccessId ){
        ReturnWrapper rw = new ReturnWrapper();
        List<Private_Lane_Access__c> plaAccessList = [ SELECT Id, Private_Lane__c, Private_Lane__r.Lane_Id__c, Organization_Group__c, Organization_Group__r.Group_Guid__c
                                                       FROM Private_Lane_Access__c
                                                       WHERE Id = :privateAccessId
        ];
        // Send Request first
        HttpRequest req = PrivateLaneAccessAPI.createDeleteRequest( plaAccessList[0]?.Private_Lane__r?.Lane_Id__c, plaAccessList[0]?.Organization_Group__r?.Group_Guid__c );
        HttpResponse res = new Http().send(req);
        if( res.getStatusCode() == 200 ){
            // Success
            try{
                delete plaAccessList;
                SplunkHelper.buildAndProcessIntegrationLog( createLog(SplunkHelper.LOGLEVEL.INFO, 'Successfully Deleted', 'deletePLA', ACVUtility.currentLineNumber(), privateAccessId), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
            }catch(Exception ex){
                // If Delete failed, we need to go in and manually delete. This is a fatal log that will generate a Slack notification
                rw.hasError = true;
                rw.message = 'Please contact a Salesforce Admin';
                SplunkHelper.buildAndProcessIntegrationLog( createLog(SplunkHelper.LOGLEVEL.FATAL, ex.getMessage(), ex.getStackTraceString(), ACVUtility.currentLineNumber(), privateAccessId), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
            }
        }else{
            // Failure in Callout
            try{
                PrivateLaneAccessAPI.DeleteResponse dr = (PrivateLaneAccessAPI.DeleteResponse)JSON.deserialize( res.getBody(), PrivateLaneAccessAPI.DeleteResponse.class );
                List<String> errorMessages = new List<String>();
                for( PrivateLaneAccessAPI.ErrorDetail ed : dr.detail ){
                    errorMessages.add(ed.msg);
                }
                rw.message = String.join(errorMessages, ', ');
            }catch( Exception ex ){          
                rw.message = 'Please contact a Salesforce Admin';
            }
            rw.hasError = true;
            SplunkHelper.buildAndProcessIntegrationLog( createLog(SplunkHelper.LOGLEVEL.ERROR, rw.message, 'Callout != 200 else section', ACVUtility.currentLineNumber(), privateAccessId), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
        }
        return JSON.serialize(rw);
    }
    /*****************Helper Methods***************/
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
        log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.SUPPLY};
        log.sfObject = 'Private Lane';
        log.version = 'v1';
        log.componentName = 'LWC - ParticipatingDealershipGroupRL';
        log.location = 'ParticipatingDealershipGroupsRLCont Line #' + String.valueOf(lineNumber);
        log.message = message;
        log.stackTrace = stackTrace;
        log.logLevel = loglevel;
        log.sfRecordId = recordId;
        log.setContext(SplunkHelper.CONTEXT_TYPE.LWC);
        return log;
    }
    /*****************Inner Classes****************/
    /**
     * Holds the data structure to return the code needed for the LWC
     * @Author James Andre LaCour
     */
    public class ReturnWrapper{
        public Boolean hasError;
        public String message;
        public List<Private_Lane_Access__c> plaList;
        public ReturnWrapper(){
            hasError = false;
            message = '';
            plaList = new List<Private_Lane_Access__c>();
        }
    }
}