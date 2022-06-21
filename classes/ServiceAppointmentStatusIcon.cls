public without sharing class ServiceAppointmentStatusIcon extends TriggerInterface {

   public Final List<String> resourceNameList = new List<String>{'FSLCommitted', 'FSLScheduled', 'FSLDispatched', 'FSLAcknowledged', 'FSLTravel', 'FSLArrived', 'FSLInProgress', 'FSLCompleted', 'FSLCannotComplete', 'FSLDryRun', 'FSLRescheduled'};

   public override void beforeInsert(List<sObject> newList) {

      List<ServiceAppointment> newsaList = (List<ServiceAppointment>)newList;
      List<ServiceAppointment> saCommitLst = new List<ServiceAppointment>();
      List<ServiceAppointment> dryRunLst = new List<ServiceAppointment>();

      // Loop through New Service Appointment values.  Need to check Committed flag in order to set the FSL__GanttIcon__c field.
      for (ServiceAppointment saLoop : newsaList) {
         if (saLoop.Committed__c == true) {
            saCommitLst.add( saLoop );
         }
         if (saLoop.Dry_Run__c == true) {
            dryRunLst.add( saLoop );
         }
      }

      if(!saCommitLst.isEmpty() || !dryRunLst.isEmpty()) {
         Map<String, String> resourceMap = ACVUtility.getStaticResourceURLByName(resourceNameList);
         if ( !saCommitLst.isEmpty() ) { 
            for ( ServiceAppointment saToModify : saCommitLst ) {
               saToModify.FSL__GanttIcon__c = resourceMap.get('FSLCommitted');
               if(dryRunLst.contains(saToModify)) {
                  saToModify.FSL__GanttIcon__c = saToModify.FSL__GanttIcon__c + ';' + resourceMap.get('FSLDryRun');
                  dryRunLst.remove(dryRunLst.indexOf(saToModify));
               }
            }
         }
   
         if ( !dryRunLst.isEmpty() ) { 
            for ( ServiceAppointment saToModify : saCommitLst ) {
               saToModify.FSL__GanttIcon__c = resourceMap.get('FSLDryRun');
            }
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
         if ((oldsaMap.get(saLoop.Id).status != saLoop.status && saLoop.status != NULL) 
         || (oldsaMap.get(saLoop.Id).Committed__c != saLoop.Committed__c && saLoop.Committed__c != NULL) 
         || (oldsaMap.get(saLoop.Id).Dry_Run__c != saLoop.Dry_Run__c && saLoop.Dry_Run__c != NULL) 
         || (oldsaMap.get(saLoop.Id).Has_Been_Rescheduled__c != saLoop.Has_Been_Rescheduled__c && saLoop.Has_Been_Rescheduled__c != NULL)) {
            modifiedSALst.add( saLoop );
         }
      }

      // Loop through New Service Appointment values.  Need to check status to set the FSL__GanttIcon__c field.
      if ( !modifiedSALst.isEmpty() ) {
         Map<String, String> resourceMap = ACVUtility.getStaticResourceURLByName(resourceNameList);

         for (ServiceAppointment saLoop : modifiedSALst ) {

            // Pinned flag is True, so add Committed icon and ';' for adding Status icon down below
            if (saLoop.Committed__c == true) {
               saLoop.FSL__GanttIcon__c = resourceMap.get('FSLCommitted');
            } else {
               saLoop.FSL__GanttIcon__c = '';
            }

            // Retrieve Status icon to add it
            if (saLoop.status == 'Scheduled') {
               saLoop.FSL__GanttIcon__c = (saLoop.FSL__GanttIcon__c == '' ? resourceMap.get('FSLScheduled') : saLoop.FSL__GanttIcon__c + ';' + resourceMap.get('FSLScheduled'));
            }
   
            if (saLoop.status == 'Dispatched') {
               saLoop.FSL__GanttIcon__c = (saLoop.FSL__GanttIcon__c == '' ? resourceMap.get('FSLDispatched') : saLoop.FSL__GanttIcon__c + ';' + resourceMap.get('FSLDispatched'));
            }
   
            if (saLoop.status == 'Acknowledged') {
               saLoop.FSL__GanttIcon__c = (saLoop.FSL__GanttIcon__c == '' ? resourceMap.get('FSLAcknowledged') : saLoop.FSL__GanttIcon__c + ';' + resourceMap.get('FSLAcknowledged'));
            }
   
            if (saLoop.status == 'Travel') {
               saLoop.FSL__GanttIcon__c = (saLoop.FSL__GanttIcon__c == '' ? resourceMap.get('FSLTravel') : saLoop.FSL__GanttIcon__c + ';' + resourceMap.get('FSLTravel'));
            }
   
            if (saLoop.status == 'Arrived') {
               saLoop.FSL__GanttIcon__c = (saLoop.FSL__GanttIcon__c == '' ? resourceMap.get('FSLArrived') : saLoop.FSL__GanttIcon__c + ';' + resourceMap.get('FSLArrived'));
            }
   
            if (saLoop.status == 'In Progress') {
               saLoop.FSL__GanttIcon__c = (saLoop.FSL__GanttIcon__c == '' ? resourceMap.get('FSLInProgress') : saLoop.FSL__GanttIcon__c + ';' + resourceMap.get('FSLInProgress'));
            }
   
            if (saLoop.status == 'Completed') {
               saLoop.FSL__GanttIcon__c = (saLoop.FSL__GanttIcon__c == '' ? resourceMap.get('FSLCompleted') : saLoop.FSL__GanttIcon__c + ';' + resourceMap.get('FSLCompleted'));
            }
   
            if (saLoop.status == 'Cannot Complete') {
               saLoop.FSL__GanttIcon__c = (saLoop.FSL__GanttIcon__c == '' ? resourceMap.get('FSLCannotComplete') : saLoop.FSL__GanttIcon__c + ';' + resourceMap.get('FSLCannotComplete'));
            }

            if (saLoop.Dry_Run__c) {
               saLoop.FSL__GanttIcon__c = (saLoop.FSL__GanttIcon__c == '' ? resourceMap.get('FSLDryRun') : saLoop.FSL__GanttIcon__c + ';' + resourceMap.get('FSLDryRun'));
            }

            if (saLoop.Has_Been_Rescheduled__c) {
               saLoop.FSL__GanttIcon__c = (saLoop.FSL__GanttIcon__c == '' ? resourceMap.get('FSLRescheduled') : saLoop.FSL__GanttIcon__c + ';' + resourceMap.get('FSLRescheduled'));
            }
         }
      }
   }
}