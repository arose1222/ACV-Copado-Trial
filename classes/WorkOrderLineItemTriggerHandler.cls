public class WorkOrderLineItemTriggerHandler extends TriggerInterface {

//before update and before insert functions have been disabled to prevent date validation

    // protected override void beforeInsert(List<SObject> newList) {
    //     WorkOrderLineItemUtility.validateStatusTimeframe( (List<WorkOrderLineItem>)newList );
    // }
    
    public override void afterInsert(Map<Id, sOBJECT> newMap) {
        WorkOrderLineItemUtility.processParentStatus( WorkOrderLineItemTriggerHandler.getParentIds( newMap.values(), null ) );
    }

    public override void beforeUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
    //     WorkOrderLineItemUtility.validateStatusTimeframe( WorkOrderLineItemTriggerHandler.filterWorkOrderIds( Trigger.newMap.values(), (Map<Id, WorkOrderLineItem>) Trigger.oldMap, new Set<String>{ 'Status' } ) );
    


        //stampComplete timestamps line items if their status changes from anything not complete to complete
       // WorkOrderLineItemUtility.stampComplete((Map<Id, WorkOrderLineItem>)newMap, (Map<Id, WorkOrderLineItem>)oldMap);
    }

    public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sobject> newMap) {
        WorkOrderLineItemUtility.processParentStatus( WorkOrderLineItemTriggerHandler.getParentIds( newMap.values(), (Map<Id, WorkOrderLineItem>) oldMap ) );
    }

    /**
     * getWorkOrderIds
     *  GIVEN a list of Work Order Line Item
     *  WHEN a Work Order Line Item's StatusCategory has changed
     *  THEN return a list of Work Order Ids filtered
     *
     * @param  workOrderIdSet - A set of Salesforce Ids that belong to modified Work Order Line Items
     * @param  oldWorkItemMap - A map representing the Salesforce Trigger.old context of previous Work Order Line Item values
     *
     * @return  a Set of Work Order Salesforce Ids
     */ 
    private static Set<Id> getParentIds( List<WorkOrderLineItem> workItemLst, Map<Id, WorkOrderLineItem> oldWorkItemMap ) {
        List<WorkOrderLineItem> filteredWorkItemLst = oldWorkItemMap == null ? workItemLst : filterWorkOrderIds( workItemLst, oldWorkItemMap, new Set<String>{ 'StatusCategory' } );
        Set<Id> returnParentIdSet = new Set<Id>();
        for ( WorkOrderLineItem woliRecord : filteredWorkItemLst ) {
            returnParentIdSet.add( woliRecord.WorkOrderId );
        }

        return returnParentIdSet;
    }

    /**
     * getWorkOrderIds
     *  GIVEN a list of Work Order Line Item
     *  WHEN a Work Order Line Item's fields have changed
     *  THEN return a list of Work Order line items filtered by provided field changes
     *
     * @param  workOrderIdSet - A set of Salesforce Ids that belong to modified Work Order Line Items
     * @param  oldWorkItemMap - A map representing the Salesforce Trigger.old context of previous Work Order Line Item values
     * @param  filterFieldSet - A set of Work Order Line Item fields to be filtered down by this method
     *
     * @return  a List of Work Order Line Items
     */ 
    private static List<WorkOrderLineItem> filterWorkOrderIds( List<WorkOrderLineItem> workItemLst, Map<Id, WorkOrderLineItem> oldWorkItemMap, Set<String> filterFieldSet ) {
        List<WorkOrderLineItem> workOrderIdLst = new List<WorkOrderLineItem>();
        for ( WorkOrderLineItem woliRecord : workItemLst ) {
            // Filter out for all new records or updated records with status changes only
            for ( String fieldName : filterFieldSet ) {
                if ( oldWorkItemMap != null && woliRecord.get( fieldName ) != oldWorkItemMap.get( woliRecord.Id ).get( fieldName ) ) {
                    workOrderIdLst.add( woliRecord );
                }
            }
        }
        return workOrderIdLst;
    }
}