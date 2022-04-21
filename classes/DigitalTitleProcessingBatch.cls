global class DigitalTitleProcessingBatch {
    
}
/*
global class DigitalTitleProcessingBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    global static List<SplunkHelper.SFErrorRecord> errorList = new List<SplunkHelper.SFErrorRecord>();
    global static Set<String> succesIdList = new Set<String>();
    global static String errorStackTraceString = '';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
        String query = 'SELECT Id FROM Case WHERE RecordTypeId = :recordTypeId AND Digital_Title__c = TRUE AND Easypost_Tracker__c = null AND Hold_For_Payment__c = null AND (Status = \'Received\' OR Status = \'Working\')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        List<Id> caseIdList = new List<Id>();
        List<Case> caseRecLst = new List<Case>();
        for(Case c :scope){
            caseIdList.add(c.id);
            caseRecLst.add( c );
        }
        try{
            TitlesShippingAutomation.validateSendingLabel(caseIdList);
            succesIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(caseIdList), List<String>.class));
        }
        catch(Exception e){
            for(Case c :caseRecLst){
                errorList.add(new SplunkHelper.SFErrorRecord( JSON.serialize( c ), e.getMessage()));
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        SplunkHelper.Log log = new SplunkHelper.Log();
        log.componentName = 'DigitalTitleProcessingBatch';
        log.sfObject = 'Case';
        log.domainSet = new Set<SplunkHelper.DOMAIN>();
        log.domainSet.add(SplunkHelper.DOMAIN.POST_TRANSACTION);
        log.logLevel = errorList.size() > 0 ? SplunkHelper.LOGLEVEL.ERROR : SplunkHelper.LOGLEVEL.INFO;
        log.setContext(SplunkHelper.CONTEXT_TYPE.BATCH);
        log.sfRecordId = bc.getJobId();
        log.stackTrace = 'DigitalTitleProcessingBatch.finish: '+ACVUtility.currentLineNumber()+2;
        log.location = 'DigitalTitleProcessingBatch.finish: '+ACVUtility.currentLineNumber()+1;
        SplunkHelper.processBatchLog(log, errorList, succesIdList);
    }

    public override void executeScheduledLogic() {
        //schedule
        DigitalTitleProcessingBatch almb = new DigitalTitleProcessingBatch();
        Database.executeBatch(almb, 20);
    }
}*/