public without sharing class ServiceAppointmentStatusIcon extends TriggerInterface {

   public Final List<String> resourceNameList = new List<String>{'FSLCommitted', 'FSLScheduled', 'FSLDispatched', 'FSLAcknowledged', 'FSLTravel', 'FSLArrived', 'FSLInProgress', 'FSLCompleted', 'FSLCannotComplete'};
   public Final List<String> statusNoIconList = new List<String>{'New', 'Canceled', 'Expired', 'Offer Attempted'};

   public override void beforeInsert(List<sObject> newList) {

      List<ServiceAppointment> newsaList = (List<ServiceAppointment>)newList;
      List<ServiceAppointment> saCommitLst = new List<ServiceAppointment>();

      // Loop through New Service Appointment values.  Need to check Committed flag in order to set the FSL__GanttIcon__c field.
      for (ServiceAppointment saLoop : newsaList) {
         if (saLoop.Committed__c == true) {
            saCommitLst.add( saLoop );
         }
      }

      if ( !saCommitLst.isEmpty() ) {
         Map<String, String> resourceMap = ACVUtility.getStaticResourceURLByName(resourceNameList);
         for ( ServiceAppointment saToModify : saCommitLst ) {
            saToModify.FSL__GanttIcon__c = resourceMap.get('FSLCommitted');
         }
      }
   }

   public override void beforeUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap ) {
      Map<Id, ServiceAppointment> oldsaMap = (Map<Id, ServiceAppointment>) oldMap;
      Map<Id, ServiceAppointment> newsaMap = (Map<Id, ServiceAppointment>) newMap;

      List<ServiceAppointment> modifiedSALst = new List<ServiceAppointment>();
      // Filter Records before query
      for (ServiceAppointment saLoop : newsaMap.values() ) {
         // Service Appointment Status OR Committed flag changed
         if ((oldsaMap.get(saLoop.Id).status != saLoop.status && saLoop.status != NULL) || (oldsaMap.get(saLoop.Id).Committed__c != saLoop.Committed__c && saLoop.Committed__c != NULL)) {
            modifiedSALst.add( saLoop );
         }
      }

      // Loop through New Service Appointment values.  Need to check status to set the FSL__GanttIcon__c field.
      if ( !modifiedSALst.isEmpty() ) {
         Map<String, String> resourceMap = ACVUtility.getStaticResourceURLByName(resourceNameList);

         for (ServiceAppointment saLoop : modifiedSALst ) {
            // Pinned flag is True, so add Committed icon and ';' for adding Status icon down below
            if (saLoop.Committed__c == true && !statusNoIconList.contains(saLoop.Status)) {
               saLoop.FSL__GanttIcon__c = resourceMap.get('FSLCommitted') + ';';
            // Pinned flag is True, so add Committed icon
            } else if (saLoop.Committed__c == true && statusNoIconList.contains(saLoop.Status)) {
               saLoop.FSL__GanttIcon__c = resourceMap.get('FSLCommitted');
            // Pinned flag is False, so do NOT add Committed icon
            } else {
               saLoop.FSL__GanttIcon__c = '';
            }

            // Retrieve Status icon to add it
            if (saLoop.status == 'Scheduled') {
               saLoop.FSL__GanttIcon__c = saLoop.FSL__GanttIcon__c + resourceMap.get('FSLScheduled');
            }
   
            if (saLoop.status == 'Dispatched') {
               saLoop.FSL__GanttIcon__c = saLoop.FSL__GanttIcon__c + resourceMap.get('FSLDispatched');
            }
   
            if (saLoop.status == 'Acknowledged') {
               saLoop.FSL__GanttIcon__c = saLoop.FSL__GanttIcon__c + resourceMap.get('FSLAcknowledged');
            }
   
            if (saLoop.status == 'Travel') {
               saLoop.FSL__GanttIcon__c = saLoop.FSL__GanttIcon__c + resourceMap.get('FSLTravel');
            }
   
            if (saLoop.status == 'Arrived') {
               saLoop.FSL__GanttIcon__c = saLoop.FSL__GanttIcon__c + resourceMap.get('FSLArrived');
            }
   
            if (saLoop.status == 'In Progress') {
               saLoop.FSL__GanttIcon__c = saLoop.FSL__GanttIcon__c + resourceMap.get('FSLInProgress');
            }
   
            if (saLoop.status == 'Completed') {
               saLoop.FSL__GanttIcon__c = saLoop.FSL__GanttIcon__c + resourceMap.get('FSLCompleted');
            }
   
            if (saLoop.status == 'Cannot Complete') {
               saLoop.FSL__GanttIcon__c = saLoop.FSL__GanttIcon__c + resourceMap.get('FSLCannotComplete');
            }
         }
      }
   }
}