public class RemoveExcessRevolvingApptResourcePrefs extends TriggerInterface {
    public override void afterInsert( List<SObject> newList ) {
        Set<Id> workOrderIdSet = new Set<Id>();
        List<ResourcePreference> checkRPLst = new List<ResourcePreference>();
        for ( ResourcePreference rpRec : (List<ResourcePreference>) newList ) {  
            if ( rpRec.RelatedRecordId != null && rpRec.RelatedRecordId.getSObjectType() == Schema.WorkOrder.SObjectType ) {
                workOrderIdSet.add( rpRec.RelatedRecordId );
                checkRPLst.add( rpRec );
            }
        }

        if ( !workOrderIdSet.isEmpty() ) {
            Set<Id> hasOccurrenceSet = new Set<Id>();
            Map<Id, Id> woToSRIdMap = new Map<Id, Id>();
            for ( WorkOrder woRec : [ SELECT Id, Occurrence__c, Occurrence__r.Timeline__c, Occurrence__r.Timeline__r.Service_Resource__c FROM WorkOrder WHERE Id IN :workOrderIdSet
                AND Occurrence__c != null ] ) {
                    hasOccurrenceSet.add( woRec.Id );
                    woToSRIdMap.put( woRec.Id, woRec?.Occurrence__r?.Timeline__r?.Service_Resource__c );
            }

            List<ResourcePreference> resourcesToRemoveLst = new List<ResourcePreference>();


            for ( ResourcePreference checkRPRec : checkRPLst ) { 
                if ( hasOccurrenceSet.contains( checkRPRec.RelatedRecordId ) && woToSRIdMap.get( checkRPRec.RelatedRecordId ) != null
                && woToSRIdMap.get( checkRPRec.RelatedRecordId ) != checkRPRec.ServiceResourceId ) { // Different Service Resource then the Revolving Appointment Specifies
                    resourcesToRemoveLst.add( new ResourcePreference( 
                        Id = checkRPRec.Id 
                    ) );
                }
            }
            
            if ( !resourcesToRemoveLst.isEmpty() ) {
                delete resourcesToRemoveLst;
            }
        }
    }
}