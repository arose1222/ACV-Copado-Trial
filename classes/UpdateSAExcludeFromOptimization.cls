public class UpdateSAExcludeFromOptimization extends TriggerInterface {
    
    public override void afterInsert(List<SObject> newList) {
        Set<Id> woIdSet = new Set<Id>();
        for ( WorkOrderLineItem woli : (List<WorkOrderLineItem>) newList ) {        
            if ( woli.Exclude_From_Optimization__c ) {
                woIdSet.add( woli.WorkOrderId );
            }
        }

        if ( !woIdSet.isEmpty() ) {
            List<ServiceAppointment> saLst = [ SELECT Id FROM ServiceAppointment WHERE ParentRecordId IN :woIdSet ];
            for ( ServiceAppointment sa : saLst ) { // If it is in the query, it automatically gets marked true
                sa.Exclude_From_Optimization__c = TRUE;
            }
            update saLst;
        }
    }
}