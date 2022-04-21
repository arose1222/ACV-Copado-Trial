public class GenerateWorkRequestUUID extends TriggerInterface {
    
    public override void beforeInsert( List<SObject> newList ) {
        for ( WorkOrderLineItem woliRec: (List<WorkOrderLineItem>) newList ) {
            if ( String.isBlank( woliRec.External_Record_Guid__c ) ) {
                woliRec.External_Record_Guid__c = ACVUtility.NewGuid();
            }     
        }
    }
}