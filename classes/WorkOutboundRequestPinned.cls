public class WorkOutboundRequestPinned extends TriggerInterface {

    public override void afterUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap ) {
        Map<Id, Id> woIdToSaIdMap = new Map<Id, Id>();
        Set<Id> saIdSet = new Set<Id>();
        List<ServiceAppointment> saLst = new List<ServiceAppointment>();
        for ( ServiceAppointment sa : (List<ServiceAppointment>) newMap.values() ) {
            ServiceAppointment oldSA = (ServiceAppointment) oldMap.get( sa.Id );
            if ( sa.Committed__c != oldSA.Committed__c && sa.Committed__c &&
            FSLWorkProcessUtility.workTypeIdMap.get( sa.WorkTypeId ).Work_Type_Unique_ID__c.containsIgnoreCase( 'cpo' ) &&
            FSLWorkProcessUtility.determineSystemOrigin( sa.CreatedById ) == FSLWorkProcessUtility.LEGACY_INSPECTION_SOURCE ) {
                saLst.add( sa );
                saIdSet.add( sa.Id );
                woIdToSaIdMap.put( sa.ParentRecordId, sa.Id );
            }
        }

        if ( !woIdToSaIdMap.isEmpty() ) {
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
            if ( !saIdSet.isEmpty() ) {
                // Needed due to AssignedResources not existing on Canceled Records
                Map<Id, String> apptTimezoneMap = new Map<Id, String>();
                for ( ServiceAppointment saPrep : [ SELECT Id, ServiceTerritory.OperatingHours.TimeZone FROM ServiceAppointment WHERE Id IN :saIdSet ] ) {
                    apptTimezoneMap.put( saPrep.Id, saPrep.ServiceTerritory.OperatingHours.TimeZone );
                }


                Integer counter = 1;
                List<LegacyInspectionStruct> sendToAPILst = new List<LegacyInspectionStruct>();
                List<LegacyInspectionStruct> sendToAPILst2 = new List<LegacyInspectionStruct>();
                List<LegacyInspectionStruct> sendToAPILst3 = new List<LegacyInspectionStruct>();
                List<LegacyInspectionStruct> sendToAPILst4 = new List<LegacyInspectionStruct>();
                for ( ServiceAppointment saRec : saLst ) {
                    for ( WorkOrderLineItem woliRec : saIdToWoliMap.get( saRec.Id ) ) {
                        if ( saRec.SchedStartTime != null && apptTimezoneMap.get( saRec.Id ) != null ) {
                            LegacyInspectionStruct newStruct = new LegacyInspectionStruct();
                            newStruct.AssignmentStart = saRec.SchedStartTime.format('yyyy-MM-dd\'T\'HH:mm:ssZ', apptTimezoneMap.get( saRec.Id ) );
                            newStruct.MessageType = 'Committed'; // This logic always sends IncompleteStatus Message Type
                            newStruct.UUID = woliRec.External_Record_Guid__c;
                            newStruct.UpdateUser = 'FSLOptimizer'; // Hardcoded for now, not sure long term plan
                            newStruct.CommitmentMade = 'True';
                            newStruct.WorkType = woliRec.WorkType.Name;

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