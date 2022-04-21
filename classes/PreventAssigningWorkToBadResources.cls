public class PreventAssigningWorkToBadResources extends TriggerInterface {
    @TestVisible private final static String INVALID_RESOURCE_CONFIG_ERROR = 'A Resource without a Contact GUID cannot be assigned to Work. Please open an R&I Ticket with the name of the resource you\'re trying to assign to get this resolved';

    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {
        Set<Id> arIdSet = new Set<Id>();
        for ( AssignedResource arRec : (List<AssignedResource>) newMap.values() ) {
            AssignedResource oldRec = (AssignedResource) oldMap.get( arRec.Id );
            if ( arRec.ServiceResourceId != oldRec.ServiceResourceId && arRec.ServiceResourceId != null ) {
                arIdSet.add( arRec.Id );
            }
        }

        if ( !arIdSet.isEmpty() ) {
            checkResourceForConfigError( arIdSet, newMap );
        }
    }

    public override void afterInsert( Map<Id, SObject> newMap ) {
        Set<Id> arIdSet = new Set<Id>();
        for ( AssignedResource arRec : (List<AssignedResource>) newMap.values() ) {
            arIdSet.add( arRec.Id );
        }

        if ( !arIdSet.isEmpty() ) {
            checkResourceForConfigError( arIdSet, newMap );
        }
    }  

    public static void checkResourceForConfigError( Set<Id> assignResourceIdSet, Map<Id,SObject> newMap ) {
        Map<String, Set<Id>> acvUserIdMap = new Map<String, Set<Id>>();
        for ( AssignedResource arRec : [ SELECT Id, ServiceResource.RelatedRecordId FROM AssignedResource WHERE Id IN :assignResourceIdSet ] ) {
            if ( acvUserIdMap.get( arRec.ServiceResource.RelatedRecordId ) == null ) {
                acvUserIdMap.put( arRec.ServiceResource.RelatedRecordId, new Set<Id>() );
            }
            acvUserIdMap.get( arRec.ServiceResource.RelatedRecordId ).add( arRec.Id );
        }

        Map<String, String> conIdToGuidMap = new Map<String, String>();
        if ( !acvUserIdMap.isEmpty() ) {
            Id acvUserRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
            for ( Contact conRec : [ SELECT Id, ACV_User__c, Contact_Guid__c FROM Contact WHERE ACV_User__c IN :acvUserIdMap.keySet() AND RecordTypeId = :acvUserRTId AND Active__c = TRUE ] ) {
                acvUserIdMap.remove( conRec.ACV_User__c );
            }

            for ( String userId : acvUserIdMap.keyset() ) {
                for ( Id badARRecId : acvUserIdMap.get( userId ) ) {
                    newMap.get( badARRecId ).addError( INVALID_RESOURCE_CONFIG_ERROR );
                }
            }
        }
    }
}