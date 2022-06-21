public class WorkTypeGanttColor extends TriggerInterface {
    
   public override void beforeInsert(List<SObject> newList) {
       String runningUser = UserInfo.getName();
       List<FSL_Special_Gantt_Color_Setting__mdt> urgentServiceApptMetadata = new List<FSL_Special_Gantt_Color_Setting__mdt>([SELECT Label, Color__c FROM FSL_Special_Gantt_Color_Setting__mdt WHERE Label = :runningUser]);
       String color = (urgentServiceApptMetadata.size() == 1 ? urgentServiceApptMetadata[0].Color__c : null);
       
       Map<Id, WorkType> workTypeMap = FSLWorkProcessUtility.workTypeIdMap; 
       List<ServiceAppointment> svcApptList = (List<ServiceAppointment>) newList;
       
       Set<Id> workOrderIDs = new Set<Id>();
       // Retrieve & Save the Work Type Color for the Service Appointment
       for (ServiceAppointment saLoop : svcApptList) {
           workOrderIDs.add(saLoop.work_order__c);
       }
       
       Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>( [ SELECT Id, WorkTypeId FROM WorkOrder WHERE Id IN :workOrderIDs ] );
       
       for (ServiceAppointment saLoop : svcApptList) {
           if(saLoop.FSL__GanttColor__c == null) {
                saLoop.FSL__GanttColor__c = ( color != null ? color : workTypeMap.get(woMap.get(saLoop.work_order__c)?.workTypeId)?.Work_Type_Color__c);
           }
       }
   }

   public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
    FSL_Special_Gantt_Color_Setting__mdt liveAppraisalColorMetadata = [SELECT Label, Color__c FROM FSL_Special_Gantt_Color_Setting__mdt WHERE Label = 'Live Appraisal' LIMIT 1];
        for(ServiceAppointment sa : (List<ServiceAppointment>) newMap.values()) {
            ServiceAppointment oldSA = (ServiceAppointment) oldMap.get(sa.Id);
            if(oldSA.Live_Appraisal_Event__c != sa.Live_Appraisal_Event__c && sa.Live_Appraisal_Event__c && liveAppraisalColorMetadata.Color__c != null) {
                sa.FSL__GanttColor__c = liveAppraisalColorMetadata.Color__c;
            }
        }
   }
}