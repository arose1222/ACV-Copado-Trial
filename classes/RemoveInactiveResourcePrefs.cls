public class RemoveInactiveResourcePrefs extends TriggerInterface {
    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        Set<Id> userIdSet = new Set<Id>();
        for ( User newUser : (List<User>) newMap.values() ) {
            User oldUser = (User) oldMap.get( newUser.Id );
            if ( oldUser.isActive && !newUser.isActive ) { // Moved from Being Active to being Inactive
                userIdSet.add( newUser.Id );
            }
        }

        if ( !userIdSet.isEmpty() ) {
            Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>( [ SELECT Id FROM ServiceResource WHERE RelatedRecordId IN :userIdSet ] );
            Set<Id> srToProcessSet = srMap?.keyset();
            if ( srToProcessSet != null && !srToProcessSet.isEmpty() ) {
                RemoveResourcePreference.reviewResourcePreferences( srToProcessSet );
            }
        }
    }
}