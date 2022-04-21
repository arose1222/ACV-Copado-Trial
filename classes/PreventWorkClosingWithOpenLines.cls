public class PreventWorkClosingWithOpenLines extends TriggerInterface {
    private static final Set<string> CHECK_WORK_TYPE_SET = new Set<string>{ 'promo work' };
    private static final Set<string> CHECK_STATUS_CATEGORY = new Set<string>{ 'Completed', 'Closed' };
    private static final Set<string> CHECK_LINE_STATUS_CATEGORY = new Set<string>{ 'Completed', 'Canceled', 'CannotComplete', 'Closed' };
    @TestVisible private static final string CANNOT_MARK_COMPLETE_ERROR = 'You cannot mark a Work Order as Completed without having all Work Order Line Items marked properly first';

    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        Set<Id> woQueryIdSet = new Set<Id>();

        for ( WorkOrder newWO : (List<WorkOrder>) newMap.values() ) {
            WorkOrder oldWO = (WorkOrder) oldMap.get( newWO.Id );
            if ( FSLWorkProcessUtility.workTypeIdMap.get( newWO.WorkTypeId ) != null && CHECK_WORK_TYPE_SET.contains( FSLWorkProcessUtility.workTypeIdMap.get( newWO.WorkTypeId ).Work_Type_Unique_ID__c ) && newWO.Status != oldWO.Status && CHECK_STATUS_CATEGORY.contains( newWO.StatusCategory ) ) {
                woQueryIdSet.add( newWO.Id );
            }
        }

        if ( !woQueryIdSet.isEmpty() ) {
            for ( WorkOrder checkWO : [ SELECT Id, ( SELECT Id, StatusCategory FROM WorkOrderLineItems ) FROM WorkOrder WHERE Id IN :woQueryIdSet ] ) {
                for ( WorkOrderLineItem childLineItem : checkWO.WorkOrderLineItems ) {
                    if ( !CHECK_LINE_STATUS_CATEGORY.contains( childLineItem.StatusCategory ) ) { // Any Category besides Complete for a line item means error thrown
                        newMap.get( checkWO.Id ).addError( CANNOT_MARK_COMPLETE_ERROR );
                    }
                }
            }
        }
    }
}