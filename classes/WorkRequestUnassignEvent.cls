public class WorkRequestUnassignEvent extends TriggerInterface {

    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {
        Set<Id> saIdSet = new Set<Id>();
        Map<Id, List<AssignedResource>> sa2ARMap = new Map<Id, List<AssignedResource>>();
        Map<Id, Id> srIdMap = new Map<Id, Id>();
        for ( AssignedResource arRec : (List<AssignedResource>) newMap.values() ) {
            if ( !WorkRequestHub.firedDispatchEvent || WorkRequestHub.firedDispatchEvent && !WorkRequestHub.dispatchedSFRecSet.contains( arRec.Id ) ) {
                AssignedResource oldRec = (AssignedResource) oldMap.get( arRec.Id );
                if ( arRec.ServiceResourceId != oldRec.ServiceResourceId && oldRec.ServiceResourceId != null ) {
                    saIdSet.add( arRec.ServiceAppointmentId );
                    if ( sa2ARMap.get( arRec.ServiceAppointmentId ) == null ) {
                        sa2ARMap.put( arRec.ServiceAppointmentId, new List<AssignedResource>() );
                    }
                    sa2ARMap.get( arRec.ServiceAppointmentId ).add( arRec );
                    if ( arRec.ServiceResourceId != null ) { srIdMap.put( arRec.Id, oldRec.ServiceResourceId ); }
                }
            }
        }

        if ( !saIdSet.isEmpty() ) {
            makeUnassignEvent( saIdSet, sa2ARMap, srIdMap );
        }
    }

    public override void afterDelete( List<SObject> oldList ) {
        Set<Id> saIdSet = new Set<Id>();
        Map<Id, List<AssignedResource>> sa2ARMap = new Map<Id, List<AssignedResource>>();
        Map<Id, Id> srIdMap = new Map<Id, Id>();
        for ( AssignedResource arRec : (List<AssignedResource>) oldList ) {
            if ( !WorkRequestHub.firedUnassignEvent || WorkRequestHub.firedUnassignEvent && !WorkRequestHub.unassignedSFRecSet.contains( arRec.Id ) ) {
                saIdSet.add( arRec.ServiceAppointmentId );
                if ( sa2ARMap.get( arRec.ServiceAppointmentId ) == null ) {
                    sa2ARMap.put( arRec.ServiceAppointmentId, new List<AssignedResource>() );
                }
                sa2ARMap.get( arRec.ServiceAppointmentId ).add( arRec );
                if ( arRec.ServiceResourceId != null ) { srIdMap.put( arRec.Id, arRec.ServiceResourceId ); }
            }
        }

        if ( !saIdSet.isEmpty() ) {
            makeUnassignEvent( saIdSet, sa2ARMap, srIdMap );
        }
    }

    public static void makeUnassignEvent( Set<Id> providedSAIdSet, Map<Id, List<AssignedResource>> saToARMap, Map<Id, Id> arIdToSRUserIdMap ) {
        Set<Id> woIdSet = new Set<Id>();
        Map<Id, Id> woIdToSaIdMap = new Map<Id, Id>();
        List<ServiceAppointment> saLst = new List<ServiceAppointment>();
        for ( ServiceAppointment saRec : [ SELECT Id, ParentRecordId, Status FROM ServiceAppointment WHERE Id IN :providedSAIdSet AND StatusCategory != :FSLWorkProcessUtility.SA_INCOMPELTE_CATEGORY ] ) {
            saLst.add( saRec );
            woIdSet.add( saRec.ParentRecordId );
            woIdToSaIdMap.put( saRec.ParentRecordId, saRec.Id );
        }

        // Organize Data
        List<WorkOrder> woLst = [ SELECT Id, Created_Without_Line_Items__c, External_Record_Guid__c, WorkTypeId, CreatedById, WorkType.Name,
                ( SELECT Id, External_Record_Guid__c, Inspection_Id__c, External_Invoice_Id__c,
                    WorkType.Name, CreatedById, Cloned_for_Grouping__c
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
            Map<Id, ServiceResource> srIdToResourceMap = new Map<Id, ServiceResource>();
            for ( ServiceResource srRec : [ SELECT Id, ASI_Resource_Id__c, RelatedRecordId, Name FROM ServiceResource WHERE Id IN :arIdToSRUserIdMap.values() ] ) {
                srIdToResourceMap.put( srRec.Id, srRec );
                acvUserIdSet.add( srRec.RelatedRecordId );
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
                        for ( AssignedResource oldAR : saToARMap.get( saRec.Id ) ) {
                            Work_Request__e newRequest = new Work_Request__e(
                                event_type__c = 'unassign',
                                work_Request_Id__c = woliRec.External_Record_Guid__c,
                                status__c = saRec.Status,
                                inspection_Id__c = woliRec.Inspection_Id__c,
                                ns_Invoice_Id__c = woliRec.External_Invoice_Id__c,
                                work_Type__c = woliRec.WorkType.Name,
                                origin_System__c = woliRec.Cloned_for_Grouping__c ? 'Legacy Inspection Services' : FSLWorkProcessUtility.determineSystemOrigin( woliRec.CreatedById )
                            );

                            if ( arIdToSRUserIdMap.get( oldAR.Id ) != null ) {
                                ServiceResource resourceSR = srIdToResourceMap.get( arIdToSRUserIdMap.get( oldAR.Id ) );
                                newRequest.assigned_Resource_Name__c = resourceSR.Name;
                                newRequest.assigned_Resource_Id__c = conIdToGuidMap.get(resourceSR.RelatedRecordId );
                                newRequest.legacy_Resource_Id__c = resourceSR.ASI_Resource_Id__c;
                                newRequest.legacy_System__c = FSLWorkProcessUtility.determineSystemOrigin( woliRec.CreatedById ) == 'Legacy Inspection Services' || woliRec.Cloned_for_Grouping__c ? 'Legacy Inspection Services' : null;
                            }
                            createEventLst.add( newRequest );
                            uuidLst.add( JSON.serialize( new FSLWorkProcessUtility.EventSaveStruct( woliRec.Id, woliRec.External_Record_Guid__c ) ) );
                            WorkRequestHub.unassignedSFRecSet.add( oldAR.Id );
                        }
                    }
                } else if ( !saIdToWoMap.isEmpty() && saIdToWoMap.get( saRec.Id ) != null ) {
                    WorkOrder eventWork = saIdToWoMap.get( saRec.Id );
                    for ( AssignedResource oldAR : saToARMap.get( saRec.Id ) ) {
                        Work_Request__e newRequest = new Work_Request__e(
                            event_type__c = 'unassign',
                            work_Request_Id__c = eventWork.External_Record_Guid__c,
                            status__c = saRec.Status,
                            //inspection_Id__c = eventWork.Inspection_Id__c,
                            work_Type__c = eventWork.WorkType.Name,
                            origin_System__c = FSLWorkProcessUtility.determineSystemOrigin( eventWork.CreatedById )
                        );

                        if ( arIdToSRUserIdMap.get( oldAR.Id ) != null ) {
                            ServiceResource resourceSR = srIdToResourceMap.get( arIdToSRUserIdMap.get( oldAR.Id ) );
                            newRequest.assigned_Resource_Name__c = resourceSR.Name;
                            newRequest.assigned_Resource_Id__c = conIdToGuidMap.get(resourceSR.RelatedRecordId );
                            newRequest.legacy_Resource_Id__c = resourceSR.ASI_Resource_Id__c;
                            newRequest.legacy_System__c = FSLWorkProcessUtility.determineSystemOrigin( eventWork.CreatedById ) == 'Legacy Inspection Services' ? 'Legacy Inspection Services' : null;
                        }
                        createEventLst.add( newRequest );
                        uuidLst.add( JSON.serialize( new FSLWorkProcessUtility.EventSaveStruct( eventWork.Id, eventWork.External_Record_Guid__c ) ) );
                        WorkRequestHub.unassignedSFRecSet.add( oldAR.Id );
                    }
                }
            }

            if ( createEventLst != null && !createEventLst.isEmpty() ) {
                List<Database.SaveResult> results = EventBus.publish( createEventLst );
                //FSLWorkProcessUtility.makeLogFromEvent( results, uuidLst, 'WorkRequestUnassignEvent', '' + ACVUtility.currentLineNumber() );
                WorkRequestHub.firedUnassignEvent = TRUE;
            }
        }
    }
}