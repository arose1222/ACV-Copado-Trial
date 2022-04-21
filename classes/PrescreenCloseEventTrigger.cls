public class PrescreenCloseEventTrigger extends TriggerInterface{

   public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
       Map<Id, Condition_Report_Prescreen__c> oldPrescreenMap = (Map<Id, Condition_Report_Prescreen__c>)oldmap;
       Map<Id, Condition_Report_Prescreen__c> newPrescreenMap = (Map<Id, Condition_Report_Prescreen__c>)newMap;

       Map<Id, Set<String>> changedFields = ACVUtility.getChangedFields(newPrescreenMap,oldPrescreenMap,'Condition_Report_Prescreen__c');
       //Map<Id, Condition_Report_Prescreen__c> prescreenQuestionMap = new Map<Id, Condition_Report_Prescreen__c>([SELECT ID, name, (SELECT ID FROM CR_Questions__r) FROM Condition_Report_Prescreen__c WHERE ID in :newPrescreenMap.keySet()]);

       List<Condition_Report_Prescreen__c> approvedWithChangeList = new List<Condition_Report_Prescreen__c>();
       List<Condition_Report_Prescreen__c> rejectedWithChangeList = new List<Condition_Report_Prescreen__c>();
       List<Condition_Report_Prescreen__c> approvedChangeList = new List<Condition_Report_Prescreen__c>();
       List<Condition_Report_Prescreen__c> autoClosedList = new List<Condition_Report_Prescreen__c>();

       for(Condition_Report_Prescreen__c crp :newPrescreenMap.values()){
           if(changedFields.get(crp.id) != null && changedFields.get(crp.id).contains('status__c') && crp.Status__c == 'Closed' && crp.closed_date__c != null){
                if(crp.CR_Update_by_pre_Screener__c == 'Yes'){
                    // prescreen approved with changes
                    approvedWithChangeList.add(crp);
                }
                else if(crp.CR_Update_by_pre_Screener__c == 'No' && !String.isBlank(crp.Question_Notes__c)){
                        // prescreen rejected with comments
                        rejectedWithChangeList.add(crp);
                }
                else if(crp.CR_Update_by_pre_Screener__c == 'No' && String.isBlank(crp.Question_Notes__c)){
                    // prescreen approved
                    approvedChangeList.add(crp);
                }
                else if(crp.CR_Review_Timeout__c){
                    //auto closed and approved
                    autoClosedList.add(crp);
                }
           }
       }

       if(!approvedWithChangeList.isEmpty()){
        PrescreenChangeEvent.prescreenEvent(approvedWithChangeList,PrescreenChangeEvent.subStatus.approved_with_changes,PrescreenChangeEvent.eventType.prescreen_approved);
       }
       if(!rejectedWithChangeList.isEmpty()){
        PrescreenChangeEvent.prescreenEvent(rejectedWithChangeList,PrescreenChangeEvent.subStatus.rejected_with_feedback,PrescreenChangeEvent.eventType.prescreen_rejected);
       }
       if(!approvedChangeList.isEmpty()){
        PrescreenChangeEvent.prescreenEvent(approvedChangeList,PrescreenChangeEvent.subStatus.approved,PrescreenChangeEvent.eventType.prescreen_approved);
       }
       if(!autoClosedList.isEmpty()){
        PrescreenChangeEvent.prescreenEvent(autoClosedList,PrescreenChangeEvent.subStatus.auto_approved,PrescreenChangeEvent.eventType.prescreen_approved);
       }
   }
}