public class GenerateWorkRequestParentUUID extends TriggerInterface {
    
    public override void beforeInsert( List<SObject> newList ) {
        for ( WorkOrder woRec: (List<WorkOrder>) newList ) {
            if ( String.isBlank( woRec.External_Record_Guid__c ) && woRec.Created_Without_Line_Items__c ) {
                woRec.External_Record_Guid__c = ACVUtility.NewGuid();
            }     
        }
    }
}