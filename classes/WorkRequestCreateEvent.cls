public class WorkRequestCreateEvent extends TriggerInterface {
    
    public override void afterInsert( Map<Id, SObject> newMap ) {
        Set<Id> woIdSet = new Set<Id>();
        for ( WorkOrderLineItem woliRec : (List<WorkOrderLineItem>) newMap.values() ) {
            woIdSet.add( woliRec.WorkOrderId );
        }

        if ( !woIdSet.isEmpty() ) {
            Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(
                [ SELECT Id, Street, City, State, PostalCode, Country, Account.Dealership_ID__c, WorkType.Name 
                        FROM WorkOrder WHERE Id IN :woIdSet ]
            );

            Map<Id, ServiceAppointment> woIdToSAMap = new Map<Id, ServiceAppointment>();
            for ( ServiceAppointment saRec : [ SELECT Id, ParentRecordId, DueDate, EarliestStartTime, Original_Due_Date__c, Status, Duration FROM ServiceAppointment WHERE ParentRecordId IN :woIdSet ] ) {
                woIdToSAMap.put( saRec.ParentRecordId, saRec );
            }

            List<Work_Request__e> createEventLst = new List<Work_Request__e>();
            List<String> uuidLst = new List<String>();
            for ( WorkOrderLineItem woliRec : (List<WorkOrderLineItem>) newMap.values() ) {
                createEventLst.add( new Work_Request__e(
                    event_type__c = 'create',
                    work_Request_Id__c = woliRec.External_Record_Guid__c,
                    vehicle_Make__c = woliRec.Make__c,
                    vehicle_Color__c = woliRec.Color__c,
                    vehicle_Model__c = woliRec.Model__c,
                    vehicle_Vin__c = woliRec.Vin__c,
                    vehicle_Year__c = woliRec.Year__c != null ? Integer.valueOf( woliRec.Year__c ) : null,
                    dealer_Id__c = woMap.get( woliRec.WorkOrderId ).Account.Dealership_ID__c,
                    street__c = woMap.get( woliRec.WorkOrderId ).Street,
                    city__c = woMap.get( woliRec.WorkOrderId ).City,
                    state__c = woMap.get( woliRec.WorkOrderId ).State,
                    postal_Code__c = woMap.get( woliRec.WorkOrderId ).PostalCode,
                    country__c = woMap.get( woliRec.WorkOrderId ).Country,
                    work_Order_Work_Type__c = woMap.get( woliRec.WorkOrderId ).WorkType.Name,
                    due_Date__c = woIdToSAMap.get( woliRec.WorkOrderId ).DueDate.date(),
                    original_Due_Date__c = woIdToSAMap.get( woliRec.WorkOrderId )?.Original_Due_Date__c?.date(),
                    earliest_Start_Date__c = woIdToSAMap.get( woliRec.WorkOrderId ).EarliestStartTime.date(),
                    estimated_Duration__c = woIdToSAMap.get( woliRec.WorkOrderId ).Duration,
                    status__c = woIdToSAMap.get( woliRec.WorkOrderId ).Status,
                    origin__c = String.isBlank( woliRec.Origin__c ) ? 'Method not Provided' : woliRec.Origin__c,
                    inspection_Id__c = woliRec.Inspection_Id__c,
                    ns_Invoice_Id__c = woliRec.External_Invoice_Id__c,
                    work_Type__c = FSLWorkProcessUtility.workTypeIdMap.get( woliRec.WorkTypeId ).Name,
                    origin_System__c = FSLWorkProcessUtility.determineSystemOrigin( woliRec.CreatedById )
                ) );
                uuidLst.add( JSON.serialize( new FSLWorkProcessUtility.EventSaveStruct( woliRec.Id, woliRec.External_Record_Guid__c ) ) );
            }

            if ( !createEventLst.isEmpty() ) {
                List<Database.SaveResult> results = EventBus.publish( createEventLst );        
                //FSLWorkProcessUtility.makeLogFromEvent( results, uuidLst, 'WorkRequestCreateEvent', '' + ACVUtility.currentLineNumber() );
            }
        }
    }
}