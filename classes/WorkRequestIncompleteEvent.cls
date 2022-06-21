public class WorkRequestIncompleteEvent extends TriggerInterface {

    public override void beforeUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        Map<Id, Id> woIdToSaIdMap = new Map<Id, Id>();
        Set<Id> saIdSet = new Set<Id>();
        List<ServiceAppointment> saLst = new List<ServiceAppointment>();

        for ( ServiceAppointment saRec : (List<ServiceAppointment>) newMap.values() ) {
            ServiceAppointment oldSARec = (ServiceAppointment) oldMap.get( saRec.Id );
            if ( saRec.Status != oldSARec.Status && saRec.StatusCategory == FSLWorkProcessUtility.SA_INCOMPELTE_CATEGORY && !String.isBlank( saRec.Status ) ) {
                    saLst.add( saRec );
                    saIdSet.add( saRec.Id );
                    woIdToSaIdMap.put( saRec.ParentRecordId, saRec.Id );
            }
        }   

        if ( woIdToSaIdMap != null && !woIdToSaIdMap.isEmpty() ) {
            List<WorkOrder> woLst = [ SELECT Id, Created_Without_Line_Items__c, External_Record_Guid__c, WorkTypeId, CreatedById, WorkType.Name,
                    ( SELECT Id, External_Record_Guid__c, Inspection_Id__c, External_Invoice_Id__c,
                        WorkType.Name, CreatedById
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
            if ( saIdSet != null && !saIdSet.isEmpty() ) {
                Set<String> acvUserIdSet = new Set<String>();
                Map<Id, AssignedResource> saToResourceMap = new Map<Id, AssignedResource>();
                for ( AssignedResource arRec : [ SELECT Id, ServiceResourceId, ServiceAppointmentId, ServiceResource.ASI_Resource_Id__c, ServiceResource.RelatedRecordId, ServiceResource.Name, ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone
                                                    FROM AssignedResource WHERE ServiceAppointmentId IN :saIdSet ] ) {
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
                DateTime incompleteTime = DateTime.now();
                //List<String> uuidLst = new List<String>();
                for ( ServiceAppointment saRec : saLst ) {
                    if ( saIdToWoliMap != null && !saIdToWoliMap.isEmpty() && saIdToWoliMap.get( saRec.Id ) != null && !saIdToWoliMap.get( saRec.Id ).isEmpty() ) {
                        for ( WorkOrderLineItem woliRec : saIdToWoliMap.get( saRec.Id ) ) {
                            createEventLst.add( new Work_Request__e(
                                event_type__c = 'incomplete',
                                work_Request_Id__c = woliRec.External_Record_Guid__c,
                                due_Date__c = saRec.DueDate != null ? saRec.DueDate.date() : null,
                                original_Due_Date__c = saRec.Original_Due_Date__c != null ? saRec.Original_Due_Date__c.date() : null,
                                earliest_Start_Date__c = saRec.EarliestStartTime != null ? saRec.EarliestStartTime.date() : null,
                                estimated_Duration__c = saRec.Duration,
                                scheduled_Start__c = saRec.SchedStartTime,
                                scheduled_End__c = saRec.SchedEndTime,
                                local_Scheduled_Start__c = saRec.SchedStartTime != null ? saRec.SchedStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss', saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone ) : null,
                                local_Scheduled_End__c = saRec.SchedEndTime != null ? saRec.SchedEndTime.format('yyyy-MM-dd\'T\'HH:mm:ss', saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone ) : null,
                                incomplete_Time__c = incompleteTime,
                                local_Incomplete_Time__c = saToResourceMap.get( saRec.Id ) != null ? incompleteTime.format('yyyy-MM-dd\'T\'HH:mm:ss', saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone ) : null,
                                status__c = saRec.Status,
                                reason__c = saRec.Cannot_Complete_Reason__c,
                                inspection_Id__c = woliRec.Inspection_Id__c,
                                ns_Invoice_Id__c = woliRec.External_Invoice_Id__c,
                                work_Type__c = FSLWorkProcessUtility.workTypeIdMap.get( woliRec.WorkTypeId ) != null ? FSLWorkProcessUtility.workTypeIdMap.get( woliRec.WorkTypeId ).Name : null,
                                assigned_Resource_Name__c = saToResourceMap.get( saRec.Id ) != null ? saToResourceMap.get( saRec.Id ).ServiceResource.Name : null,
                                assigned_Resource_Id__c = saToResourceMap.get( saRec.Id ) != null ? conIdToGuidMap.get( saToResourceMap.get( saRec.Id ).ServiceResource.RelatedRecordId ) : null,
                                legacy_Resource_Id__c = saToResourceMap.get( saRec.Id ) != null ? saToResourceMap.get( saRec.Id ).ServiceResource.ASI_Resource_Id__c : null,
                                legacy_System__c = FSLWorkProcessUtility.determineSystemOrigin( woliRec.CreatedById ) == 'Legacy Inspection Services' ? 'Legacy Inspection Services' : null,
                                origin_System__c = FSLWorkProcessUtility.determineSystemOrigin( woliRec.CreatedById ),
                                comment__c = !String.isBlank( saRec.Completed_Canceled_Notes__c ) ? saRec.Completed_Canceled_Notes__c : 'Comment not provided',
                                contact_Name__c = saRec.Contact_Name__c
                            ) );
                            //uuidLst.add( JSON.serialize( new FSLWorkProcessUtility.EventSaveStruct( woliRec.Id, woliRec.External_Record_Guid__c ) ) );
                        }
                    } else if ( saIdToWoMap != null && !saIdToWoMap.isEmpty() && saIdToWoMap.get( saRec.Id ) != null ) {
                        WorkOrder eventWork = saIdToWoMap.get( saRec.Id );
                        createEventLst.add( new Work_Request__e(
                            event_type__c = 'incomplete',
                            work_Request_Id__c = eventWork.External_Record_Guid__c,
                            due_Date__c = saRec.DueDate != null ? saRec.DueDate.date() : null,
                            original_Due_Date__c = saRec.Original_Due_Date__c != null ? saRec.Original_Due_Date__c.date() : null,
                            earliest_Start_Date__c = saRec.EarliestStartTime != null ? saRec.EarliestStartTime.date() : null,
                            estimated_Duration__c = saRec.Duration,
                            scheduled_Start__c = saRec.SchedStartTime,
                            scheduled_End__c = saRec.SchedEndTime,
                            local_Scheduled_Start__c = saRec.SchedStartTime != null && saToResourceMap != null && saToResourceMap.get( saRec.Id ) != null ? saRec.SchedStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss', saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone ) : null,
                            local_Scheduled_End__c = saRec.SchedEndTime != null && saToResourceMap != null && saToResourceMap.get( saRec.Id ) != null ? saRec.SchedEndTime.format('yyyy-MM-dd\'T\'HH:mm:ss', saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone ) : null,
                            incomplete_Time__c = incompleteTime,
                            local_Incomplete_Time__c = saToResourceMap.get( saRec.Id ) != null && saToResourceMap != null && saToResourceMap.get( saRec.Id ) != null ? incompleteTime.format('yyyy-MM-dd\'T\'HH:mm:ss', saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone ) : null,
                            status__c = saRec.Status,
                            reason__c = saRec.Cannot_Complete_Reason__c,
                            //inspection_Id__c = eventWork.Inspection_Id__c,
                            work_Type__c = FSLWorkProcessUtility.workTypeIdMap.get( eventWork.WorkTypeId ) != null ? FSLWorkProcessUtility.workTypeIdMap.get( eventWork.WorkTypeId ).Name : null,
                            assigned_Resource_Name__c = saToResourceMap.get( saRec.Id ) != null ? saToResourceMap.get( saRec.Id ).ServiceResource.Name : null,
                            assigned_Resource_Id__c = saToResourceMap.get( saRec.Id ) != null && conIdToGuidMap != null ? conIdToGuidMap.get( saToResourceMap.get( saRec.Id ).ServiceResource.RelatedRecordId ) : null,
                            legacy_Resource_Id__c = saToResourceMap.get( saRec.Id ) != null ? saToResourceMap.get( saRec.Id ).ServiceResource.ASI_Resource_Id__c : null,
                            legacy_System__c = FSLWorkProcessUtility.determineSystemOrigin( eventWork.CreatedById ) == 'Legacy Inspection Services' ? 'Legacy Inspection Services' : null,
                            origin_System__c = FSLWorkProcessUtility.determineSystemOrigin( eventWork.CreatedById ),
                            comment__c = !String.isBlank( saRec.Completed_Canceled_Notes__c ) ? saRec.Completed_Canceled_Notes__c : 'Comment not provided',
                            contact_Name__c = saRec.Contact_Name__c
                        ) );
                        //uuidLst.add( JSON.serialize( new FSLWorkProcessUtility.EventSaveStruct( eventWork.Id, eventWork.External_Record_Guid__c ) ) );
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