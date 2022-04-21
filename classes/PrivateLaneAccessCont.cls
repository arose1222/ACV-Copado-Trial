/**
 * This class is the controller for the PRivateLaneAccessLayout LWC
 * @author James Andre LaCour
 */
public class PrivateLaneAccessCont {
    /********************AuraEnabled Methods***********************/
    /**
     * Submits the Private Lane Access to the API. If successful, saves to Salesforce
     * @param filedsJson - this is a json Map of the Private Lane Access Field to Value
     * @return JSON Serialized DataWrapper
     */
    @AuraEnabled
    public static string submit( String fieldsJson ){
        DataWrapper dw = new DataWrapper();
        Private_Lane_Access__c pla = (Private_Lane_Access__c)JSON.deserialize(fieldsJson, Private_Lane_Access__c.class);
        Map<Id,Private_Lane__c> plMap = new Map<Id,Private_Lane__c>([ SELECT Id, Lane_Id__c FROM Private_Lane__c WHERE Id = :pla.Private_Lane__c LIMIT 1 ]);
        // Check to see if we have the needed information from the Group and Private Lane records
        if( plMap.isEmpty() || String.isBlank(plMap.get(pla.Private_Lane__c)?.Lane_Id__c) ){
            SplunkHelper.buildAndProcessLog( createLog(SplunkHelper.LOGLEVEL.ERROR, 'No Private Lane record was found', 'Private Lane Query in PrivateLaneAccessCont', ACVUtility.currentLineNumber(), pla?.Id) );
            dw.statusCode = 500;
            dw.statusMessage = 'Please refresh your page and try again.';
            return JSON.serialize(dw);
        }
        Map<Id,Group__c> groupMap = new Map<Id,Group__c>([ SELECT Id, Group_Guid__c FROM Group__c WHERE Id = :pla.Organization_Group__c LIMIT 1 ]);
        if( groupMap.isEmpty() || String.isBlank(groupMap.get(pla.Organization_Group__c)?.Group_Guid__c) ){
            SplunkHelper.buildAndProcessLog( createLog(SplunkHelper.LOGLEVEL.ERROR, 'No Group record was found', 'Group Query in PrivateLaneAccessCont', ACVUtility.currentLineNumber(), pla?.Id) );
            dw.statusCode = 500;
            dw.statusMessage = 'Please refresh your page and try again.';
            return JSON.serialize(dw);
        }
        // Currently the endpoint can only handle one at a time so no bulk needed
        String laneId = plMap.get(pla?.Private_Lane__c)?.Lane_Id__c;
        List<PrivateLaneAccessAPI.PermissionDetail> pdsList = new List<PrivateLaneAccessAPI.PermissionDetail>();
        pdsList.add( PrivateLaneAccessAPI.createPermissionDetail(laneId, groupMap.get(pla?.Organization_Group__c)?.Group_Guid__c, pla?.Buying_Power__c, pla?.Selling_Power__c));
        // Sends to API
        HttpRequest req = PrivateLaneAccessAPI.createSetRequest(laneId, pdsList);
        HttpResponse res = new Http().send(req);
        if( res.getStatusCode() == 200 ){
            // Success
            dw.statusMessage = 'Success';
            try{
                upsert pla;
                SplunkHelper.buildAndProcessIntegrationLog(createLog(SplunkHelper.LOGLEVEL.INFO, 'Success', '', ACVUtility.currentLineNumber(), pla?.Id), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND);
            }catch(Exception ex){
                dw.statusCode = 500;
                dw.statusMessage = 'A Salesforce Admin has been contacted to fix this issue.';
                SplunkHelper.buildAndProcessIntegrationLog(createLog(SplunkHelper.LOGLEVEL.FATAL, 'Failed update of Salesforce Record on API Success', ex.getStackTraceString(), ACVUtility.currentLineNumber(), pla?.Id), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND);
            }
        }else{
            // Failed - We don't want to update the Salesforce side if it fails from the endpoint
            String stackTrace = '';
            try{
                PrivateLaneAccessAPI.SetResponse sr = (PrivateLaneAccessAPI.SetResponse)JSON.deserialize( res.getBody(), PrivateLaneAccessAPI.SetResponse.class );
                List<String> errorMessages = new List<String>();
                for( PrivateLaneAccessAPI.ErrorDetail ed : sr?.detail ){
                    errorMessages.add(ed?.msg);
                }
                dw.statusMessage = String.join(errorMessages, ', ');
                dw.statusCode = res.getStatusCode();
                stackTrace = 'Endpoint failed to Delete';
            }catch(Exception ex){
                dw.statusMessage = 'There was an issue with setting this permission';
                stackTrace = ex.getStackTraceString();
            }
            String recordId = pla?.Id == null ? UserInfo.getUserId() : pla.Id;
            SplunkHelper.buildAndProcessIntegrationLog(createLog(SplunkHelper.LOGLEVEL.ERROR, dw.statusMessage, stackTrace, ACVUtility.currentLineNumber(), recordId), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND);
        }
        return JSON.serialize(dw);
    }
    /***********************Helper Methods************************/
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
        log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.PRIVATE_AUCTIONS};
        log.sfObject = 'Private Lane';
        log.version = 'v1';
        log.componentName = 'LWC - PrivateLaneAccessLayout';
        log.location = 'PrivateLaneAccessCont Line #' + String.valueOf(lineNumber);
        log.message = message;
        log.stackTrace = stackTrace;
        log.logLevel = loglevel;
        log.sfRecordId = recordId;
        log.setContext(SplunkHelper.CONTEXT_TYPE.LWC);
        return log;
    }
    /***********************Inner Class***************************/
    /* This class holds the return items for the LWC
    */
    public class DataWrapper{
        public String statusMessage;
        public Integer statusCode;
        public DataWrapper(){
            statusMessage = '';
            statusCode = 200;
        }
    }
}