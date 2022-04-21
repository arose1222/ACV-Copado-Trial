public class PriorityEngine extends TriggerInterface {
   
    public override void beforeInsert( List<SObject> newList ) {
        if ( !newList?.isEmpty() ) {
            List<WorkOrder> woLst = (List<WorkOrder>) newList;

            // Get Rules
            Map<String, String> workTypeToPriorityMap = new Map<String, String>();
            for ( FSL_Priority_Engine_Rule__mdt priorityRuleRec : [ SELECT Label, Priority_Assignment__c FROM FSL_Priority_Engine_Rule__mdt ] ) {
                workTypeToPriorityMap.put( priorityRuleRec.Label, priorityRuleRec.Priority_Assignment__c );
            }
        
            for ( WorkOrder woRec : woLst ) {
                woRec.Priority = workTypeToPriorityMap.get( FSLWorkProcessUtility.workTypeIdMap.get( woRec.WorkTypeId )?.Name ) != null ? workTypeToPriorityMap.get( FSLWorkProcessUtility.workTypeIdMap.get( woRec.WorkTypeId )?.Name ) : woRec.Priority; 
            }
        }
    }
}