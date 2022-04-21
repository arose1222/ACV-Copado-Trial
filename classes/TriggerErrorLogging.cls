public class TriggerErrorLogging extends TriggerInterface {
    public override void afterInsert( List<SObject> newLst ) {
        sendToSplunk( (List<Trigger_Event__e>) newLst );
    }

    public static void sendToSplunk( List<Trigger_Event__e> newErrLst ) {
        Trigger_Event__e trigEvent = newErrLst[0]; // Only one event should fire per context, we also only want to fire one splunk event
        SplunkHelper.Log createLogRec = new SplunkHelper.Log();
        createLogRec.version = trigEvent.Version__c;
        createLogRec.logLevel = SplunkHelper.LOGLEVEL.ERROR;
        createLogRec.location = trigEvent.Location__c;
        createLogRec.message = trigEvent.Message__c;
        createLogRec.stackTrace = trigEvent.Stack_Trace__c;
        createLogRec.sfRecordId = trigEvent.SF_Record_Id__c;
        createLogRec.componentName = trigEvent.Component_Name__c;
        createLogRec.sfObject = trigEvent.SF_Object__c;
        createLogRec.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.ENTERPRISE_APPS };
        
        SplunkHelper.buildandProcessLog( createLogRec );
    }
}