public class WorkRequestDispatchEvent extends TriggerInterface {
    
    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {
        Set<Id> saIdSet = new Set<Id>();
        for ( AssignedResource arRec : (List<AssignedResource>) newMap.values() ) {
            if ( !WorkRequestHub.firedDispatchEvent || WorkRequestHub.firedDispatchEvent && !WorkRequestHub.dispatchedSFRecSet.contains( arRec.Id ) ) {
                AssignedResource oldRec = (AssignedResource) oldMap.get( arRec.Id );
                if ( arRec.ServiceResourceId != oldRec.ServiceResourceId && arRec.ServiceResourceId != null ) {
                    saIdSet.add( arRec.ServiceAppointmentId );
                }
            }
        }

        if ( !saIdSet.isEmpty() ) {
            makeDispatchEvent( saIdSet );
        }
    }

    public override void afterInsert( Map<Id, SObject> newMap ) {
        Set<Id> saIdSet = new Set<Id>();
        for ( AssignedResource arRec : (List<AssignedResource>) newMap.values() ) {
            if ( !WorkRequestHub.firedDispatchEvent || WorkRequestHub.firedDispatchEvent && !WorkRequestHub.dispatchedSFRecSet.contains( arRec.Id ) ) {
                saIdSet.add( arRec.ServiceAppointmentId );
            }
        }

        if ( !saIdSet.isEmpty() ) {
            makeDispatchEvent( saIdSet );
        }
    }  

    public static void makeDispatchEvent( Set<Id> saIdSet ) {
        Set<Id> woIdSet = new Set<Id>();
        Map<Id, Id> woIdToSaIdMap = new Map<Id, Id>();
        List<ServiceAppointment> saLst = new List<ServiceAppointment>();
        for ( ServiceAppointment saRec : [ SELECT Id, ParentRecordId, Status, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE Id IN :saIdSet ] ) {
            saLst.add( saRec );
            woIdSet.add( saRec.ParentRecordId );
            woIdToSaIdMap.put( saRec.ParentRecordId, saRec.Id );
        }

        // Organize Data
        List<WorkOrder> woLst = [ SELECT Id, Created_Without_Line_Items__c, External_Record_Guid__c, WorkTypeId, CreatedById, WorkType.Name,
                ( SELECT Id, External_Record_Guid__c, Inspection_Id__c, External_Invoice_Id__c,
                    WorkType.Name, CreatedById
                        FROM WorkOrderLineItems ) 
                                FROM WorkOrder WHERE Id IN :woIdSet ];

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
        if ( !saLst.isEmpty() ) {
            Set<String> acvUserIdSet = new Set<String>();
            Map<Id, AssignedResource> saToResourceMap = new Map<Id, AssignedResource>();
            for ( AssignedResource arRec : [ SELECT Id, ServiceResourceId, ServiceAppointmentId, ServiceResource.ASI_Resource_Id__c, ServiceResource.RelatedRecordId, ServiceResource.Name,
                                                    ServiceAppointment.SchedStartTime, ServiceAppointment.SchedEndTime, ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone
                                                FROM AssignedResource WHERE ServiceAppointmentId IN :saLst ] ) {
                saToResourceMap.put( arRec.ServiceAppointmentId, arRec );
                acvUserIdSet.add( arRec.ServiceResource.RelatedRecordId );
            }

            Map<String, String> conIdToGuidMap = new Map<String, String>();
            if ( !acvUserIdSet.isEmpty() ) {
                Id acvUserRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
                for ( Contact conRec : [ SELECT Id, ACV_User__c, Identity_Id__c FROM Contact WHERE ACV_User__c IN :acvUserIdSet AND RecordTypeId = :acvUserRTId AND Active__c = TRUE ] ) {
                    conIdToGuidMap.put( conRec.ACV_User__c, conRec.Identity_Id__c );
                }
            }

            List<Work_Request__e> createEventLst = new List<Work_Request__e>();
            List<String> uuidLst = new List<String>();
            for ( ServiceAppointment saRec : saLst ) {
                if ( saIdToWoliMap != null && !saIdToWoliMap.isEmpty() && saIdToWoliMap.get( saRec.Id ) != null && !saIdToWoliMap.get( saRec.Id ).isEmpty() ) {
                    for ( WorkOrderLineItem woliRec : saIdToWoliMap.get( saRec.Id ) ) {
                        createEventLst.add( new Work_Request__e(
                            event_type__c = 'dispatch',
                            work_Request_Id__c = woliRec.External_Record_Guid__c,
                            status__c = saRec.Status,
                            inspection_Id__c = woliRec.Inspection_Id__c,
                            ns_Invoice_Id__c = woliRec.External_Invoice_Id__c,
                            work_Type__c = woliRec.WorkType.Name,
                            assigned_Resource_Name__c = saToResourceMap.get( saRec.Id ).ServiceResource.Name,
                            assigned_Resource_Id__c = conIdToGuidMap.get( saToResourceMap.get( saRec.Id ).ServiceResource.RelatedRecordId ),
                            legacy_Resource_Id__c = saToResourceMap.get( saRec.Id ).ServiceResource.ASI_Resource_Id__c,
                            scheduled_Start__c = saRec.SchedStartTime,
                            scheduled_End__c = saRec.SchedEndTime,
                            local_Scheduled_Start__c = saRec.SchedStartTime != null ? saRec.SchedStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss', saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone ) : null,
                            local_Scheduled_End__c = saRec.SchedEndTime != null ? saRec.SchedEndTime.format('yyyy-MM-dd\'T\'HH:mm:ss', saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone ) : null,
                            legacy_System__c = FSLWorkProcessUtility.determineSystemOrigin( woliRec.CreatedById ) == 'Legacy Inspection Services' ? 'Legacy Inspection Services' : null,
                            origin_System__c = FSLWorkProcessUtility.determineSystemOrigin( woliRec.CreatedById )
                        ) );
                        WorkRequestHub.dispatchedSFRecSet.add( saToResourceMap.get( saRec.Id ).Id );
                        uuidLst.add( JSON.serialize( new FSLWorkProcessUtility.EventSaveStruct( woliRec.Id, woliRec.External_Record_Guid__c ) ) );
                    }
                } else if ( !saIdToWoMap.isEmpty() && saIdToWoMap.get( saRec.Id ) != null ) {
                    WorkOrder eventWork = saIdToWoMap.get( saRec.Id );
                    createEventLst.add( new Work_Request__e(
                        event_type__c = 'dispatch',
                        work_Request_Id__c = eventWork.External_Record_Guid__c,
                        status__c = saRec.Status,
                        //inspection_Id__c = eventWork.Inspection_Id__c,
                        work_Type__c = eventWork.WorkType.Name,
                        assigned_Resource_Name__c = saToResourceMap.get( saRec.Id ).ServiceResource.Name,
                        assigned_Resource_Id__c = conIdToGuidMap.get( saToResourceMap.get( saRec.Id ).ServiceResource.RelatedRecordId ),
                        legacy_Resource_Id__c = saToResourceMap.get( saRec.Id ).ServiceResource.ASI_Resource_Id__c,
                        scheduled_Start__c = saRec.SchedStartTime,
                        scheduled_End__c = saRec.SchedEndTime,
                        local_Scheduled_Start__c = saRec.SchedStartTime != null && saToResourceMap.get( saRec.Id ) != null && !String.isBlank( saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone ) ? saRec.SchedStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss', saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone ) : null,
                        local_Scheduled_End__c = saRec.SchedEndTime != null && saToResourceMap.get( saRec.Id ) != null && !String.isBlank( saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone ) ? saRec.SchedEndTime.format('yyyy-MM-dd\'T\'HH:mm:ss', saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone ) : null,
                        legacy_System__c = FSLWorkProcessUtility.determineSystemOrigin( eventWork.CreatedById ) == 'Legacy Inspection Services' ? 'Legacy Inspection Services' : null,
                        origin_System__c = FSLWorkProcessUtility.determineSystemOrigin( eventWork.CreatedById )
                    ) );
                    WorkRequestHub.dispatchedSFRecSet.add( saToResourceMap.get( saRec.Id ).Id );
                    uuidLst.add( JSON.serialize( new FSLWorkProcessUtility.EventSaveStruct( eventWork.Id, eventWork.External_Record_Guid__c ) ) );
                }
            }

            if ( createEventLst != null && !createEventLst.isEmpty() ) {
                List<Database.SaveResult> results = EventBus.publish( createEventLst );
                //FSLWorkProcessUtility.makeLogFromEvent( results, uuidLst, 'WorkRequestDispatchEvent', '' + ACVUtility.currentLineNumber() );
                WorkRequestHub.firedDispatchEvent = TRUE;
            }
        }
    }
}