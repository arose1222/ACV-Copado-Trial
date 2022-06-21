public class WorkRequestAppointmentUpdateEvent extends TriggerInterface {

    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        Map<Id, Id> woIdToSaIdMap = new Map<Id, Id>();
        List<ServiceAppointment> saLst = new List<ServiceAppointment>();
        Set<Id> saIdSet = new Set<Id>();
        Map<Id, String> oldSAStatusMap = new Map<Id, String>();
        for ( ServiceAppointment saRec : (List<ServiceAppointment>) newMap.values() ) {                     
            if ( oldMap.get( saRec.Id ) != null ) {
                ServiceAppointment oldSARec = (ServiceAppointment) oldMap.get( saRec.Id );
                if ( ( saRec.DueDate != oldSARec.DueDate ||
                    saRec.EarliestStartTime != oldSARec.EarliestStartTime ||
                    saRec.SchedStartTime != oldSARec.SchedStartTime ||
                    saRec.SchedEndTime != oldSARec.SchedEndTime || 
                    ( saRec.DurationInMinutes != oldSARec.DurationInMinutes && saRec.DurationType == saRec.DurationType ) ||
                    ( saRec.Status != oldSARec.Status && saRec.StatusCategory != FSLWorkProcessUtility.SA_COMPELTED_CATEGORY && saRec.StatusCategory != FSLWorkProcessUtility.SA_INCOMPELTE_CATEGORY )
                ) && !String.isBlank( saRec.Status ) && saRec.ParentRecordId != null ) {
                        saLst.add( saRec );
                        saIdSet.add( saRec.Id );
                        woIdToSaIdMap.put( saRec.ParentRecordId, saRec.Id );
                    	if ( !String.isBlank( oldSARec.Status ) ) { oldSAStatusMap.put( saRec.Id, oldSARec.Status ); }
                }
            }
        }

        if ( saLst != null && !saLst.isEmpty() ) {
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
            Set<String> acvUserIdSet = new Set<String>();
            Map<Id, AssignedResource> saToResourceMap = new Map<Id, AssignedResource>();
            for ( AssignedResource arRec : [ SELECT Id, ServiceResourceId, ServiceAppointmentId, ServiceResource.ASI_Resource_Id__c, ServiceResource.RelatedRecordId, ServiceResource.Name, ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone
                                                FROM AssignedResource WHERE ServiceAppointmentId IN :saIdSet ] ) {
                saToResourceMap.put( arRec.ServiceAppointmentId, arRec );
                acvUserIdSet.add( arRec.ServiceResource.RelatedRecordId );
            }

            Map<Id, String> apptTimezoneMap = new Map<Id, String>();
            for ( ServiceAppointment saPrep : [ SELECT Id, ServiceTerritory.OperatingHours.TimeZone FROM ServiceAppointment WHERE Id IN :saIdSet ] ) {
                if ( saPrep.ServiceTerritory != null && saPrep.ServiceTerritory.OperatingHours != null && saPrep.ServiceTerritory.OperatingHours.TimeZone != null  ) {
                    apptTimezoneMap.put( saPrep.Id, saPrep.ServiceTerritory.OperatingHours.TimeZone );
                }
            }

            Map<String, String> conIdToGuidMap = new Map<String, String>();
            if ( !acvUserIdSet.isEmpty() ) {
                Id acvUserRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
                for ( Contact conRec : [ SELECT Id, ACV_User__c, Identity_Id__c FROM Contact WHERE ACV_User__c IN :acvUserIdSet AND RecordTypeId = :acvUserRTId AND Active__c = TRUE ] ) {
                    conIdToGuidMap.put( conRec.ACV_User__c, conRec.Identity_Id__c );
                }
            }

            List<Work_Request__e> createEventLst = new List<Work_Request__e>();
            //List<String> uuidLst = new List<String>();
            for ( ServiceAppointment saRec : saLst ) {
                Boolean checkForResource = ( saToResourceMap != null && saToResourceMap.get( saRec.Id ) != null );
                if ( saIdToWoliMap != null && !saIdToWoliMap.isEmpty() && saIdToWoliMap.get( saRec.Id ) != null && !saIdToWoliMap.get( saRec.Id ).isEmpty() ) {
                    for ( WorkOrderLineItem woliRec : saIdToWoliMap.get( saRec.Id ) ) {                                  
                        createEventLst.add( new Work_Request__e(
                            event_type__c = 'appointment-update',
                            work_Request_Id__c = woliRec.External_Record_Guid__c,
                            due_Date__c = saRec.DueDate?.date(),
                            original_Due_Date__c = saRec.Original_Due_Date__c != null ? saRec.Original_Due_Date__c?.date() : saRec.DueDate?.date(),
                            earliest_Start_Date__c = saRec.EarliestStartTime?.date(),
                            estimated_Duration__c = saRec.DurationInMinutes,
                            scheduled_Start__c = saRec.SchedStartTime,
                            scheduled_End__c = saRec.SchedEndTime,
                            local_Scheduled_Start__c = saRec.SchedStartTime != null && apptTimezoneMap.get( saRec.Id ) != null ? saRec.SchedStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss', apptTimezoneMap.get( saRec.Id ) ) : null,
                            local_Scheduled_End__c = saRec.SchedEndTime != null && apptTimezoneMap.get( saRec.Id ) != null ? saRec.SchedEndTime.format('yyyy-MM-dd\'T\'HH:mm:ss', apptTimezoneMap.get( saRec.Id ) ) : null,
                            status__c = saRec.Status,
                            previous_Status__c = oldSAStatusMap.get( saRec.Id ),
                            inspection_Id__c = woliRec.Inspection_Id__c,
                            ns_Invoice_Id__c = woliRec.External_Invoice_Id__c,
                            work_Type__c = FSLWorkProcessUtility.workTypeIdMap.get( woliRec.WorkTypeId )?.Name,
                            update_User__c = UserInfo.getName(),
                            origin_System__c = FSLWorkProcessUtility.determineSystemOrigin( woliRec.CreatedById ),
                            assigned_Resource_Name__c = checkForResource ? saToResourceMap.get( saRec.Id ).ServiceResource.Name : null,
                            assigned_Resource_Id__c = checkForResource ? conIdToGuidMap.get( saToResourceMap.get( saRec.Id ).ServiceResource.RelatedRecordId ) : null,
                            legacy_Resource_Id__c = checkForResource ? saToResourceMap.get( saRec.Id ).ServiceResource.ASI_Resource_Id__c : null,
                            legacy_System__c = checkForResource && FSLWorkProcessUtility.determineSystemOrigin( woliRec.CreatedById ) == 'Legacy Inspection Services' ? 'Legacy Inspection Services' : null
                        ) );
                        //uuidLst.add( JSON.serialize( new FSLWorkProcessUtility.EventSaveStruct( woliRec.Id, woliRec.External_Record_Guid__c ) ) );
                    }
                } else if ( saIdToWoMap != null && !saIdToWoMap.isEmpty() && saIdToWoMap.get( saRec.Id ) != null ) {
                    WorkOrder eventWork = saIdToWoMap.get( saRec.Id );
                    createEventLst.add( new Work_Request__e(
                        event_type__c = 'appointment-update',
                        work_Request_Id__c = eventWork.External_Record_Guid__c,
                        due_Date__c = saRec.DueDate != null ? saRec.DueDate?.date() : null,
                        original_Due_Date__c = saRec.Original_Due_Date__c != null ? saRec.Original_Due_Date__c?.date() : ( saRec.DueDate != null ? saRec.DueDate?.date() : null ),
                        earliest_Start_Date__c = saRec.EarliestStartTime != null ? saRec.EarliestStartTime?.date() : null,
                        estimated_Duration__c = saRec.DurationInMinutes,
                        scheduled_Start__c = saRec.SchedStartTime,
                        scheduled_End__c = saRec.SchedEndTime,
                        local_Scheduled_Start__c = saRec.SchedStartTime != null && apptTimezoneMap != null && apptTimezoneMap.get( saRec.Id ) != null ? saRec.SchedStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss', apptTimezoneMap.get( saRec.Id ) ) : null,
                        local_Scheduled_End__c = saRec.SchedEndTime != null && apptTimezoneMap != null && apptTimezoneMap.get( saRec.Id ) != null ? saRec.SchedEndTime.format('yyyy-MM-dd\'T\'HH:mm:ss', apptTimezoneMap.get( saRec.Id ) ) : null,
                        status__c = saRec.Status,
                        previous_Status__c = oldSAStatusMap != null && oldSAStatusMap.get( saRec.Id ) != null ? oldSAStatusMap.get( saRec.Id ) : null,
                        //inspection_Id__c = eventWork.Inspection_Id__c,
                        work_Type__c = FSLWorkProcessUtility.workTypeIdMap != null && FSLWorkProcessUtility.workTypeIdMap?.get( eventWork.WorkTypeId ) != null ? FSLWorkProcessUtility.workTypeIdMap?.get( eventWork.WorkTypeId )?.Name : null,
                        update_User__c = UserInfo.getName(),
                        origin_System__c = FSLWorkProcessUtility.determineSystemOrigin( eventWork.CreatedById ),
                        assigned_Resource_Name__c = checkForResource ? saToResourceMap.get( saRec.Id ).ServiceResource.Name : null,
                        assigned_Resource_Id__c = checkForResource && conIdToGuidMap != null && conIdToGuidMap.get( saToResourceMap.get( saRec.Id ).ServiceResource.RelatedRecordId ) != null ? conIdToGuidMap.get( saToResourceMap.get( saRec.Id ).ServiceResource.RelatedRecordId ) : null,
                        legacy_Resource_Id__c = checkForResource && saToResourceMap.get( saRec.Id ).ServiceResource != null && saToResourceMap.get( saRec.Id ).ServiceResource.ASI_Resource_Id__c != null ? saToResourceMap.get( saRec.Id ).ServiceResource.ASI_Resource_Id__c : null,
                        legacy_System__c = checkForResource && FSLWorkProcessUtility.determineSystemOrigin( eventWork.CreatedById ) == 'Legacy Inspection Services' ? 'Legacy Inspection Services' : null
                    ) );
                    //uuidLst.add( JSON.serialize( new FSLWorkProcessUtility.EventSaveStruct( eventWork.Id, eventWork.External_Record_Guid__c ) ) );
                }
            }

            if ( !createEventLst.isEmpty() ) {
                List<Database.SaveResult> results = EventBus.publish( createEventLst );      
                //FSLWorkProcessUtility.makeLogFromEvent( results, uuidLst, 'WorkRequestAppointmentUpdateEvent', '' + ACVUtility.currentLineNumber() );
            }
        }
    }
}