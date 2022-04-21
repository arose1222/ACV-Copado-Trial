public class OptimizerServiceResourceFromUser extends TriggerInterface {

    public override void afterUpdate ( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        Set<String> changedUserSet = new Set<String>();
        for ( User userRec : (List<User>) newMap.values() ) {
            User oldUser = (User) oldMap.get( userRec.Id );
            if ( userRec.ProfileId != oldUser.ProfileId ) {
                changedUserSet.add( userRec.Id );
            }
        }
        processResource( changedUserSet );
    }

    public static void processResource( Set<String> userSet ) {
        Set<String> srIdSet = new Set<String>();
        for ( ServiceResource sr : [ SELECT Id, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId IN :userSet ] ) {
            srIdSet.add( sr.Id );
        }
        updateServiceResources( srIdSet, userSet );
    }

    @future
    public static void updateServiceResources( Set<String> srIdSet, Set<String> userSet ) {
        List<ServiceResource> srLst = [ SELECT Id, RelatedRecordId FROM ServiceResource WHERE Id IN :srIdSet ];
        update OptimizeServiceResource.processResources( srLst, userSet );
    }
}