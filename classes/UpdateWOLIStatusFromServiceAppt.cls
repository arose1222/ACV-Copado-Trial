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

        Map<Id,String> workOrderIdSAStatusMap = new Map<Id,String>();
        for ( ServiceAppointment serviceApptRec : (List<ServiceAppointment>) newMap.values() ) {
            if ( asiWorkTypeIds.contains( serviceApptRec.WorkTypeId ) ) {
                ServiceAppointment oldServiceApptRec = (ServiceAppointment) oldMap.get( serviceApptRec.Id );
                if (SA_TO_WOLI_STATUS_MAP.containsKey(serviceApptRec.Status) && serviceApptRec.Status != oldServiceApptRec.Status && serviceApptRec.Work_Order__c != null ) {
                    workOrderIdSAStatusMap.put(serviceApptRec.Work_Order__c, serviceApptRec.Status);
                }
            }
        }

        if ( !workOrderIdSAStatusMap.isEmpty() ) {
            List<WorkOrderLineItem> woliToUpdate = new List<WorkOrderLineItem>();
            for(WorkOrderLineItem woli : [ SELECT Id, Status, WorkOrderId FROM WorkOrderLineItem WHERE WorkOrderId IN :workOrderIdSAStatusMap.keyset() ] ) {
                String woliStatus = SA_TO_WOLI_STATUS_MAP.get( workOrderIdSAStatusMap.get( woli.WorkOrderId ) );
                if( woli.Status != woliStatus ) {
                    woli.Status = woliStatus;
                    woliToUpdate.add( woli );
                }
            }
            update woliToUpdate;
        }
    }
}