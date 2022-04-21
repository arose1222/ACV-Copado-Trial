public class PreventBadResourceCreation extends TriggerInterface {
    @testVisible private final static String INVALID_RESOURCE_CONFIG_ERROR = 'A Resource without a Identity Id cannot be created. Please open an R&I Ticket with the name of the resource you\'re trying to create to get this resolved';

    public override void afterInsert( Map<Id, SObject> newMap ) {
        Set<Id> srIdSet = new Set<Id>();
        for ( ServiceResource srRec : (List<ServiceResource>) newMap.values() ) {
            srIdSet.add( srRec.Id );
        }

        if ( !srIdSet.isEmpty() ) {
            checkResourceForConfigError( srIdSet, newMap );
        }
    }  

    public static void checkResourceForConfigError( Set<Id> serviceResourceIdSet, Map<Id,SObject> newMap ) {
        Map<String, Set<Id>> acvUserIdMap = new Map<String, Set<Id>>();
        for ( ServiceResource srRec : [ SELECT Id, RelatedRecordId FROM ServiceResource WHERE Id IN :serviceResourceIdSet ] ) {
            if ( acvUserIdMap.get( srRec.RelatedRecordId ) == null ) {
                acvUserIdMap.put( srRec.RelatedRecordId, new Set<Id>() );
            }
            acvUserIdMap.get( srRec.RelatedRecordId ).add( srRec.Id );
        }

        Map<String, String> conIdToGuidMap = new Map<String, String>();
        if ( !acvUserIdMap.isEmpty() ) {
            Id acvUserRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
            for ( Contact conRec : [ SELECT Id, ACV_User__c, Identity_Id__c FROM Contact WHERE ACV_User__c IN :acvUserIdMap.keySet() AND RecordTypeId = :acvUserRTId AND Active__c = TRUE AND Identity_Id__c != null ] ) {
                for ( Id badSRRecId : acvUserIdMap.get( conRec.ACV_User__c ) ) {
                    acvUserIdMap.remove( conRec.ACV_User__c );
                }
            }

            for ( String userId : acvUserIdMap.keyset() ) {
                for ( Id badARRecId : acvUserIdMap.get( userId ) ) {
                    newMap.get( badARRecId ).addError( INVALID_RESOURCE_CONFIG_ERROR );
                }
            }
        }
    }
}