public class WorkTypeGanttColor extends TriggerInterface {

   public override void beforeInsert(List<SObject> newList) {
      Map<Id, WorkType> workTypeMap = FSLWorkProcessUtility.workTypeIdMap; 
      List<ServiceAppointment> svcApptList = (List<ServiceAppointment>) newList;

      Set<Id> workOrderIDs = new Set<Id>();
      // Retrieve & Save the Work Type Color for the Service Appointment
      for (ServiceAppointment saLoop : svcApptList) {
         workOrderIDs.add(saLoop.work_order__c);
      }

      Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>( [ SELECT Id, WorkTypeId FROM WorkOrder WHERE Id IN :workOrderIDs ] );

      for (ServiceAppointment saLoop : svcApptList) {
      	 saLoop.FSL__GanttColor__c = workTypeMap.get(woMap.get(saLoop.work_order__c)?.workTypeId)?.Work_Type_Color__c;
      }
   }

}