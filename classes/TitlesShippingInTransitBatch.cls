global class TitlesShippingInTransitBatch {
    
}
/*
global class TitlesShippingInTransitBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    global static List<SplunkHelper.SFErrorRecord> errorList = new List<SplunkHelper.SFErrorRecord>();
    global static Set<String> succesIdList = new Set<String>();
    global static String errorStackTraceString = '';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
        String query = 'SELECT Id, Status, Easypost_Tracker__c FROM Case WHERE RecordTypeId = :recordTypeId AND Easypost_Tracker__c != null AND Digital_Title__c = TRUE AND Status != \'sent\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        List<Case> updateCaseList = new List<Case>();
        for(Case c :scope){
            if(!String.isBlank(c.Easypost_Tracker__c)){
                HttpRequest request = new HttpRequest();
                request.setMethod('GET');
                request.setEndpoint('callout:EasyPost/v2/trackers?tracking_code='+c.Easypost_Tracker__c);
                request.setHeader('Authorization', '{!$Credential.Password}');
                request.setTimeout(60000);
                request.setHeader('Content-Type', 'application/json');
                HttpResponse response = new Http().send(request);
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                    EasyPostTrackerResponse EPTracker = EasyPostTrackerResponse.parse(response.getBody());
                    for(EasyPostTrackerResponse.Trackers tracker :EPTracker.trackers){
                        if( (tracker.status == 'in_transit' || tracker.status == 'delivered') && tracker.tracking_code == c.Easypost_Tracker__c){
                            c.status = 'Sent';
                            updateCaseList.add(c);
                        }
                    }
                }
                else{
                    SplunkHelper.Log log = new SplunkHelper.Log();
                    log.componentName = 'TitlesShippingInTransitBatch';
                    log.domainSet = new Set<SplunkHelper.DOMAIN>();
                    log.domainSet.add(SplunkHelper.DOMAIN.POST_TRANSACTION);
                    log.logLevel = SplunkHelper.LOGLEVEL.ERROR;
                    log.setContext(SplunkHelper.CONTEXT_TYPE.INTEGRATION);
                    log.stackTrace = 'TitlesShippingInTransitBatch.execute: '+ACVUtility.currentLineNumber()+2;
                    log.location = 'TitlesShippingInTransitBatch.execute: '+ACVUtility.currentLineNumber()+1;
                    SplunkHelper.buildAndProcessIntegrationLog(log,request,response, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND);
                }
            }
        }

        if(updateCaseList.size() > 0){
            List<Database.SaveResult> dbResultLst = Database.update( updateCaseList, FALSE );
            for ( Integer index = 0; index < dbResultLst.size(); index++ ) {
                Database.SaveResult dbResultRec = dbResultLst[index]; 
                Case caseRec = updateCaseList[index];
                if ( !dbResultRec.isSuccess() ) {
                    List<String> errList = new List<String>();
                    for(Database.Error err :dbResultRec.getErrors()){
                        errList.add(err.getMessage());
                    }
                    errorList.add(new SplunkHelper.SFErrorRecord( JSON.serialize( caseRec ) , string.join(errList,',')));
                }
                else{
                    succesIdList.add(dbResultRec.id);
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        SplunkHelper.Log log = new SplunkHelper.Log();
        log.componentName = 'TitlesShippingInTransitBatch';
        log.sfObject = 'Case';
        log.domainSet = new Set<SplunkHelper.DOMAIN>();
        log.domainSet.add(SplunkHelper.DOMAIN.POST_TRANSACTION);
        log.logLevel = errorList.size() > 0 ? SplunkHelper.LOGLEVEL.ERROR : SplunkHelper.LOGLEVEL.INFO;
        log.setContext(SplunkHelper.CONTEXT_TYPE.BATCH);
        log.sfRecordId = bc.getJobId();
        log.stackTrace = 'TitlesShippingInTransitBatch.finish: '+ACVUtility.currentLineNumber()+2;
        log.location = 'TitlesShippingInTransitBatch.finish: '+ACVUtility.currentLineNumber()+1;
        SplunkHelper.processBatchLog(log, errorList, succesIdList);
    }

    public override void executeScheduledLogic() {
        //schedule
        TitlesShippingInTransitBatch almb = new TitlesShippingInTransitBatch();
        //doing 90 here to give a little breathing room on limits
        Database.executeBatch(almb, 50);
    }
}*/