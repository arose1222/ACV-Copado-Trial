public class WorkRequestParentCreateEvent extends TriggerInterface {
    public override void afterInsert( Map<Id, SObject> newMap ) {
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>();

        for ( WorkOrder woCheckRec : (List<WorkOrder>) newMap.values() ) {
            if ( woCheckRec.Created_Without_Line_Items__c ) {
                woMap.put( woCheckRec.Id, woCheckRec );
            } 
        }

        if ( !woMap.isEmpty() ) {
            Map<Id, ServiceAppointment> woIdToSAMap = new Map<Id, ServiceAppointment>();
            for ( ServiceAppointment saRec : [ SELECT Id, ParentRecordId, DueDate, EarliestStartTime, Original_Due_Date__c, Status, Duration FROM ServiceAppointment WHERE ParentRecordId IN :woMap.keyset() ] ) {
                woIdToSAMap.put( saRec.ParentRecordId, saRec );
            }

            List<Work_Request__e> createEventLst = new List<Work_Request__e>();
            List<String> uuidLst = new List<String>();
            for ( WorkOrder woRec : (List<WorkOrder>) newMap.values() ) {
                createEventLst.add( new Work_Request__e(
                    event_type__c = 'create',
                    work_Request_Id__c = woRec.External_Record_Guid__c,
                    dealer_Id__c = woRec.Account.Dealership_ID__c,
                    street__c = woRec.Street,
                    city__c = woRec.City,
                    state__c = woRec.State,
                    postal_Code__c = woRec.PostalCode,
                    country__c = woRec.Country,
                    work_Order_Work_Type__c = woRec.WorkType.Name,
                    due_Date__c = woIdToSAMap.get( woRec.Id ).DueDate.date(),
                    original_Due_Date__c = woIdToSAMap.get( woRec.Id )?.Original_Due_Date__c?.date(),
                    earliest_Start_Date__c = woIdToSAMap.get( woRec.Id ).EarliestStartTime.date(),
                    estimated_Duration__c = woIdToSAMap.get( woRec.Id ).Duration,
                    status__c = woIdToSAMap.get( woRec.Id ).Status,
                    origin__c = String.isBlank( woRec.Origin__c ) ? 'Method not Provided' : woRec.Origin__c,
                    //inspection_Id__c = woliRec.Inspection_Id__c,
                    work_Type__c = FSLWorkProcessUtility.workTypeIdMap.get( woRec.WorkTypeId ).Name,
                    origin_System__c = FSLWorkProcessUtility.determineSystemOrigin( woRec.CreatedById )
                ) );
                uuidLst.add( JSON.serialize( new FSLWorkProcessUtility.EventSaveStruct( woRec.Id, woRec.External_Record_Guid__c ) ) );
            }

            if ( !createEventLst.isEmpty() ) {
                List<Database.SaveResult> results = EventBus.publish( createEventLst );        
                //FSLWorkProcessUtility.makeLogFromEvent( results, uuidLst, 'WorkRequestCreateEvent', '' + ACVUtility.currentLineNumber() );
            }
        }
    }
}