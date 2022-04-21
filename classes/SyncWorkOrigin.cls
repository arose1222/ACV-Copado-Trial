public class SyncWorkOrigin extends TriggerInterface {

    public override void afterInsert(Map<Id,SObject> newMap) {
        Map<Id, WorkOrderLineItem> passMap = new Map<Id, WorkOrderLineItem>();
        for ( WorkOrderLineItem woliRec : (List<WorkOrderLineItem>) newMap.values() ) {
            if ( !String.isBlank( woliRec.Origin__c ) ) {
                passMap.put( woliRec.WorkOrderId, woliRec);
            }
        }

        if ( !passMap.isEmpty() ) {
            checkAndProcessWorkOrigin( passMap );
        }
    }

    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {
        Map<Id, WorkOrderLineItem> passMap = new Map<Id, WorkOrderLineItem>();

        for ( WorkOrderLineItem woliRec : (List<WorkOrderLineItem>) newMap.values() ) {
            WorkOrderLineItem oldWoliRec = (WorkOrderLineItem) oldMap.get( woliRec.Id );
            if ( !String.isBlank( woliRec.Origin__c ) && woliRec.Origin__c != oldWoliRec.Origin__c ) {
                passMap.put( woliRec.WorkOrderId, woliRec );
            }
        }

        if ( !passMap.isEmpty() ) {
            checkAndProcessWorkOrigin( passMap );
        }
    }

    public static void checkAndProcessWorkOrigin( Map<Id, WorkOrderLineItem> workIdToLineMap ) {
        List<WorkOrder> updateWorkLst = new List<WorkOrder>();

        For ( WorkOrder woRec : [ SELECT Id, Origin__c FROM WorkOrder WHERE Id IN :workIdToLineMap.keyset() AND ( Origin__c = null OR Origin__c = '' ) ] ) {
            if ( String.isBlank( woRec.Origin__c ) && workIdToLineMap.get( woRec.Id ) != null && !String.isBlank( workIdToLineMap.get( woRec.Id ).Origin__c ) ) {
                woRec.Origin__c = workIdToLineMap.get( woRec.Id ).Origin__c;
                updateWorkLst.add( woRec );
            }
        }

        if ( !updateWorkLst.isEmpty() ) {
            update updateWorkLst;
        }
    }
}