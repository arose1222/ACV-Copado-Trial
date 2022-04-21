public class UpdateWOLIStatusFromServiceAppt extends TriggerInterface{

    public static final Map<String,String> SA_TO_WOLI_STATUS_MAP = new Map<String, String>{
        'New' => 'New',
        'Scheduled' => 'New',
        'Dispatched' => 'New',
        'Acknowledged' => 'New',
        'Travel' => 'In Progress',
        'Arrived' => 'In Progress',
        'In Progress' => 'In Progress',
        'Completed' => 'Inspected',
        'Cannot Complete' => 'Cannot Complete',
        'Canceled' => 'Canceled',
        'Expired' => 'Expired'
    };

    public override void afterUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap ) {
        Set<Id> asiWorkTypeIds = FSLWorkProcessUtility.getWorkTypeIdByGroupName( new Set<String>{ 'asi' } );

        Map<Id,ServiceAppointment> workOrderIdSAMap = new Map<Id,ServiceAppointment>();
        for ( ServiceAppointment serviceApptRec : (List<ServiceAppointment>) newMap.values() ) {
            if ( asiWorkTypeIds.contains( serviceApptRec.WorkTypeId ) && serviceApptRec.Bundled__c == false) {
                ServiceAppointment oldServiceApptRec = (ServiceAppointment) oldMap.get( serviceApptRec.Id );
                if (SA_TO_WOLI_STATUS_MAP.containsKey(serviceApptRec.Status) && (serviceApptRec.Status != oldServiceApptRec.Status || serviceApptRec.EarliestStartTime != oldServiceApptRec.EarliestStartTime || serviceApptRec.DueDate != oldServiceApptRec.DueDate ) && serviceApptRec.Work_Order__c != null ) {
                    workOrderIdSAMap.put(serviceApptRec.Work_Order__c, serviceApptRec);
                }
            }
        }

        if ( !workOrderIdSAMap.isEmpty() ) {
            List<WorkOrderLineItem> woliToUpdate = new List<WorkOrderLineItem>();
            for(WorkOrderLineItem woli : [ SELECT Id, Status, WorkOrderId, Earliest_Start_Date__c, Due_Date__c FROM WorkOrderLineItem WHERE WorkOrderId IN :workOrderIdSAMap.keyset() ] ) {
                ServiceAppointment sa = workOrderIdSAMap.get( woli.WorkOrderId );
                String woliStatus = SA_TO_WOLI_STATUS_MAP.get( sa.Status );

                woli.Status = woliStatus;
                woli.Earliest_Start_Date__c = sa.EarliestStartTime.date();
                woli.Due_Date__c = sa.DueDate.date();

                woliToUpdate.add( woli );
            }
            update woliToUpdate;
        }
    }
}