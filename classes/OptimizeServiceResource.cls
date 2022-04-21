public class OptimizeServiceResource extends TriggerInterface {

    public override void beforeUpdate ( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        List<ServiceResource> changedSRLst = new List<ServiceResource>();
        for ( ServiceResource sr : (List<ServiceResource>) newMap.values() ) {
            ServiceResource oldSR = (ServiceResource) oldMap.get( sr.Id );
            if ( sr.RelatedRecordId != oldSR.RelatedRecordId ) {
                changedSRLst.add( sr );
            }
        }

        getUserInfo( changedSRLst );
    }

    public override void beforeInsert( List<SObject> newLst ) {
        // Just send entire list
        getUserInfo( (List<ServiceResource>) newLst );
    }

    public static final Set<String> USER_PROFILE_SET {
        get {
            if ( USER_PROFILE_SET == null ) {
                USER_PROFILE_SET = new Set<String>();
                for ( Salesforce_Setting__mdt var : [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE Label LIKE '%OPTIMIZE PROFILE NAME :%' ] ) {
                    USER_PROFILE_SET.add( var.Value__c );
                }
            }
            return USER_PROFILE_SET;
        }
        set;
    }

    public static void getUserInfo( List<ServiceResource> srLst ) {
        Set<String> userIdSet = new Set<String>();
        for ( ServiceResource srRec : srLst ) {
            userIdSet.add( srRec.RelatedRecordId );
        }

        processResources( srLst, userIdSet );
    }

    public static List<ServiceResource> processResources( List<ServiceResource> srObjectLst, Set<String> userIdSet ) {
        Map<Id, Boolean> optimizeUserMap = new Map<Id, Boolean>();
        for ( User u : [ SELECT Id, Profile.Name FROM User WHERE Id IN :userIdSet ] ) {
            optimizeUserMap.put( u.Id, USER_PROFILE_SET.contains( u.Profile.Name ) );
        }

        for ( ServiceResource srRec : srObjectLst ) {
            srRec.IsOptimizationCapable = optimizeUserMap.get( srRec.RelatedRecordId );
        }

        return srObjectLst;
    }
}