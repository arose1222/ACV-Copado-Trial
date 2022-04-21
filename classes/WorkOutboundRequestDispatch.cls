public class WorkOutboundRequestDispatch extends TriggerInterface {

    public override void afterUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap ) {
        List<ServiceAppointment> dispatchedSALst = new List<ServiceAppointment>();
        Map<Id, Id> woIdToSaIdMap = new Map<Id, Id>();
        for ( ServiceAppointment sa : (List<ServiceAppointment>) newMap.values() ) {
            ServiceAppointment oldSA = (ServiceAppointment) oldMap.get( sa.Id );
            if ( sa.Status != oldSA.Status && sa.Status == FSLWorkProcessUtility.SA_DISPATCH_STATUS && FSLWorkProcessUtility.determineSystemOrigin( sa.CreatedById ) == FSLWorkProcessUtility.LEGACY_INSPECTION_SOURCE ) {
                dispatchedSALst.add( sa );
                woIdToSaIdMap.put( sa.ParentRecordId, sa.Id );
            }
        }

        if ( !dispatchedSALst.isEmpty() ) {
            List<WorkOrder> woLst = [ SELECT Id, 
                ( SELECT Id, External_Record_Guid__c, Inspection_Id__c, External_Invoice_Id__c,
                    WorkType.Name, CreatedById
                        FROM WorkOrderLineItems ) 
                                FROM WorkOrder WHERE Id IN :woIdToSaIdMap.keyset() ];

            Map<Id, List<WorkOrderLineItem>> saIdToWoliMap = new Map<Id, List<WorkOrderLineItem>>();
            for ( WorkOrder woRec : woLst ) {
                Id saId = woIdToSaIdMap.get( woRec.Id );
                if ( saIdToWoliMap.get( saId ) == null ) {
                    saIdToWoliMap.put( saId, new List<WorkOrderLineItem>() );
                }

                for ( WorkOrderLineItem woliRec : woRec.WorkOrderLineItems ) {
                    saIdToWoliMap.get( saId ).add( woliRec );
                }
            }

            // Get Resource Info
            if ( !saIdToWoliMap.isEmpty() ) {
                Map<Id, AssignedResource> saToResourceMap = new Map<Id, AssignedResource>();
                for ( AssignedResource arRec : [ SELECT Id, ServiceResourceId, ServiceAppointmentId, ServiceResource.ASI_Resource_Id__c, ServiceResource.RelatedRecord.Id__c, ServiceResource.Name,
                                                        ServiceAppointment.SchedStartTime, ServiceAppointment.SchedEndTime,
                                                        ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone
                                                    FROM AssignedResource WHERE ServiceAppointmentId IN :dispatchedSALst ] ) 
                {
                    saToResourceMap.put( arRec.ServiceAppointmentId, arRec );
                }

                Integer counter = 1;
                List<LegacyInspectionStruct> sendToAPILst = new List<LegacyInspectionStruct>();
                List<LegacyInspectionStruct> sendToAPILst2 = new List<LegacyInspectionStruct>();
                List<LegacyInspectionStruct> sendToAPILst3 = new List<LegacyInspectionStruct>();
                List<LegacyInspectionStruct> sendToAPILst4 = new List<LegacyInspectionStruct>();
                for ( ServiceAppointment saRec : dispatchedSALst ) {
                    if ( saToResourceMap.get( saRec.Id ) != null && saToResourceMap.get( saRec.Id )?.ServiceResource != null && saToResourceMap.get( saRec.Id )?.ServiceResource?.ASI_Resource_Id__c != null ) {
                        for ( WorkOrderLineItem woliRec : saIdToWoliMap.get( saRec.Id ) ) {               
                            LegacyInspectionStruct newStruct = new LegacyInspectionStruct();
                            newStruct.AssignmentStart = saRec.SchedStartTime.format('yyyy-MM-dd\'T\'HH:mm:ssZ', saToResourceMap.get( saRec.Id ).ServiceAppointment.ServiceTerritory.OperatingHours.TimeZone );
                            newStruct.MessageType = 'Dispatched'; // This logic always sends Dispatched Message Type
                            newStruct.PersonID = saToResourceMap.get( saRec.Id ).ServiceResource.ASI_Resource_Id__c;
                            newStruct.Status = saRec.Status;
                            newStruct.UUID = woliRec.External_Record_Guid__c;
                            newStruct.UpdateUser = 'FSLOptimizer'; // Hardcoded for now, not sure long term plan

                            if ( counter <= 50 ) { sendToAPILst.add( newStruct );
                            } else if ( counter > 50 && counter <= 100 ) { sendToAPILst2.add( newStruct ); 
                            } else if ( counter > 100 && counter <= 150 ) { sendToAPILst3.add( newStruct ); 
                            } else { sendToAPILst4.add( newStruct ); }
                            counter++;
                        }
                    }
                }

                if ( !sendToAPILst.isEmpty() ) { System.enqueueJob( new LegacyInspectionCallout( sendToAPILst ) ); }
                if ( !sendToAPILst2.isEmpty() ) { System.enqueueJob( new LegacyInspectionCallout( sendToAPILst2 ) ); }
                if ( !sendToAPILst3.isEmpty() ) { System.enqueueJob( new LegacyInspectionCallout( sendToAPILst3 ) ); }
                if ( !sendToAPILst4.isEmpty() ) { System.enqueueJob( new LegacyInspectionCallout( sendToAPILst4 ) ); }
            }
        }
    }
}