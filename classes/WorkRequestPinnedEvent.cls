public class WorkRequestPinnedEvent extends TriggerInterface {

    public override void afterUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap ) {
        Map<Id, Id> woIdToSaIdMap = new Map<Id, Id>();
        Set<Id> saIdSet = new Set<Id>();
        List<ServiceAppointment> saLst = new List<ServiceAppointment>();
        for ( ServiceAppointment sa : (List<ServiceAppointment>) newMap.values() ) {
            ServiceAppointment oldSA = (ServiceAppointment) oldMap.get( sa.Id );
            if ( sa.Committed__c != oldSA.Committed__c && sa.Committed__c  ) {
                saLst.add( sa );
                saIdSet.add( sa.Id );
                woIdToSaIdMap.put( sa.ParentRecordId, sa.Id );
            }
        }

        if ( !woIdToSaIdMap.isEmpty() ) {
            List<WorkOrder> woLst = [ SELECT Id, Created_Without_Line_Items__c, External_Record_Guid__c, WorkTypeId, CreatedById, WorkType.Name,
                    ( SELECT Id, External_Record_Guid__c, Inspection_Id__c, External_Invoice_Id__c,
                        WorkType.Name, CreatedById, Cloned_for_Grouping__c
                            FROM WorkOrderLineItems )
                                    FROM WorkOrder WHERE Id IN :woIdToSaIdMap.keyset() ];

            Map<Id, List<WorkOrderLineItem>> saIdToWoliMap = new Map<Id, List<WorkOrderLineItem>>();
            Map<Id, WorkOrder> saIdToWoMap = new Map<Id, WorkOrder>();
            for ( WorkOrder woRec : woLst ) {
                Id saId = woIdToSaIdMap.get( woRec.Id );
                if ( !woRec.Created_Without_Line_Items__c ) {
                    if ( saIdToWoliMap.get( saId ) == null ) {
                        saIdToWoliMap.put( saId, new List<WorkOrderLineItem>() );
                    }

                    for ( WorkOrderLineItem woliRec : woRec.WorkOrderLineItems ) {
                        saIdToWoliMap.get( saId ).add( woliRec );
                    }
                } else {
                    saIdToWoMap.put( saId, woRec );
                }
            }

            // Get Resource Info
            if ( !saIdSet.isEmpty() ) {
                Map<Id, String> apptTimezoneMap = new Map<Id, String>();
                for ( ServiceAppointment saPrep : [ SELECT Id, ServiceTerritory.OperatingHours.TimeZone FROM ServiceAppointment WHERE Id IN :saIdSet ] ) {
                    apptTimezoneMap.put( saPrep.Id, saPrep.ServiceTerritory.OperatingHours.TimeZone );
                }

                List<Work_Request__e> createEventLst = new List<Work_Request__e>();
                List<String> uuidLst = new List<String>();
                DateTime pinnedTime = DateTime.now();
                for ( ServiceAppointment saRec : saLst ) {
                    if ( !saIdToWoliMap.isEmpty() && !saIdToWoliMap.get( saRec.Id ).isEmpty() ) {
                        for ( WorkOrderLineItem woliRec : saIdToWoliMap.get( saRec.Id ) ) {
                            createEventLst.add( new Work_Request__e(
                                event_type__c = 'pinned',
                                work_Request_Id__c = woliRec.External_Record_Guid__c,
                                scheduled_Start__c = saRec.SchedStartTime,
                                local_Scheduled_Start__c = saRec.SchedStartTime != null ? saRec.SchedStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss', apptTimezoneMap.get( saRec.Id ) ) : null,
                                work_Type__c = FSLWorkProcessUtility.workTypeIdMap.get( woliRec.WorkTypeId ) != null ? FSLWorkProcessUtility.workTypeIdMap.get( woliRec.WorkTypeId ).Name : null,
                                origin_System__c = woliRec.Cloned_for_Grouping__c ? 'Legacy Inspection Services' : FSLWorkProcessUtility.determineSystemOrigin( woliRec.CreatedById ),
                                pinned_Time__c = pinnedTime,
                                local_Pinned_Time__c = pinnedTime.format('yyyy-MM-dd\'T\'HH:mm:ss', apptTimezoneMap.get( saRec.Id ) )
                            ) );
                            uuidLst.add( JSON.serialize( new FSLWorkProcessUtility.EventSaveStruct( woliRec.Id, woliRec.External_Record_Guid__c ) ) );
                        }
                    } else if ( !saIdToWoMap.isEmpty() && saIdToWoMap.get( saRec.Id ) != null ) {
                        WorkOrder eventWork = saIdToWoMap.get( saRec.Id );
                        createEventLst.add( new Work_Request__e(
                            event_type__c = 'pinned',
                            work_Request_Id__c = eventWork.External_Record_Guid__c,
                            scheduled_Start__c = saRec.SchedStartTime,
                            local_Scheduled_Start__c = saRec.SchedStartTime != null && !apptTimezoneMap.isEmpty() && apptTimezoneMap.get( saRec.Id ) != null ? saRec.SchedStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss', apptTimezoneMap.get( saRec.Id ) ) : null,
                            work_Type__c = FSLWorkProcessUtility.workTypeIdMap.get( eventWork.WorkTypeId ) != null ? FSLWorkProcessUtility.workTypeIdMap.get( eventWork.WorkTypeId ).Name : null,
                            origin_System__c = FSLWorkProcessUtility.determineSystemOrigin( eventWork.CreatedById ),
                            pinned_Time__c = pinnedTime,
                            local_Pinned_Time__c = !apptTimezoneMap.isEmpty() && apptTimezoneMap.get( saRec.Id ) != null ? pinnedTime.format('yyyy-MM-dd\'T\'HH:mm:ss', apptTimezoneMap.get( saRec.Id ) ) : null
                        ) );
                        uuidLst.add( JSON.serialize( new FSLWorkProcessUtility.EventSaveStruct( eventWork.Id, eventWork.External_Record_Guid__c ) ) );
                    }
                }

                if ( createEventLst != null && !createEventLst.isEmpty() ) {
                    List<Database.SaveResult> results = EventBus.publish( createEventLst );
                    //FSLWorkProcessUtility.makeLogFromEvent( results, uuidLst, 'WorkRequestIncompleteEvent', '' + ACVUtility.currentLineNumber() );
                }
            }
        }
    }
}