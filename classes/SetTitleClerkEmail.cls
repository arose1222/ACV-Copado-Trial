public class SetTitleClerkEmail extends TriggerInterface {

    public override void beforeInsert( List<SObject> newList ){
        processCaseLst( (List<Case>) newList, new Map<Id, Case>() );
    }

    public override void beforeUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        processCaseLst( (List<Case>) newMap.values(), (Map<Id, Case>) oldMap );
    }

    public List<Case> processCaseLst( List<Case> newCaseLst, Map<Id, Case> oldMap ) {
        List<Case> titleCaseLst = new List<Case>();
        for ( Case caseRec : newCaseLst ) {
            if ( ACVUtility.recordTypeCheck( CaseUtility.TITLES_RECORDTYPE_DEV_NAME, 'Case', caseRec.RecordTypeId ) ) {
                titleCaseLst.add( caseRec );
            }
        }

        if ( !titleCaseLst.isEmpty() ) {
            return setTitleClerkEmails( titleCaseLst, ( oldMap.isEmpty() ? null : oldMap ) );
        }
        return null;
    }

    /**
     * setTitleClerkEmails 
     *  GIVEN A Titles Case
     *  WHEN A Seller Account is changed
     *  THEN update the Clerk email fields to reflect the new Account
     *
     * @param  newLst
     * @param  oldMap
     */
    private static List<Case> setTitleClerkEmails(List<Case> newLst, Map<Id,Case> oldMap){
        Map<Id, List<Case>> acctIdToCaseMap = new Map<Id, List<Case>>();

        for(Case c : newLst ){
            // Seller Email Logic - If Seller changed, update email clerk field
            if ( acctIdToCaseMap.get( c.Seller_Dealership__c ) == null ) {
                acctIdToCaseMap.put( c.Seller_Dealership__c, new List<Case>() );
            }
            acctIdToCaseMap.get( c.Seller_Dealership__c ).add( c );
            if ( oldMap != null && c.Seller_Dealership__c == null && c.Seller_Dealership__c != oldMap.get(c.id).Seller_Dealership__c ) {
                c.Seller_Title_Clerk_Email__c = null;
            }
        }

        if ( !acctIdToCaseMap.isEmpty() ) {
            for ( Contact conRecord : [ SELECT Id, AccountId, Email FROM Contact WHERE Title = :CaseUtility.TITLE_CLERK AND Active__c = TRUE AND AccountId IN :acctIdToCaseMap.keySet() ORDER BY ACV_Updated__c DESC ] ) {
                if ( acctIdToCaseMap.get( conRecord.AccountId ) != null ) {
                    for ( Case caseRecord : acctIdToCaseMap.get( conRecord.AccountId ) ) {
                        caseRecord.Seller_Title_Clerk_Email__c = conRecord.Email;
                    }
                }
                // We order results by most recent first, remove the cases from the map once processed
                acctIdToCaseMap.remove( conRecord.AccountId );
            }
            if ( !acctIdToCaseMap.isEmpty() ) { // For anything left, set the values to null
                for ( Id acctId : acctIdToCaseMap.keySet() ) {
                    for ( Case caseRecord : acctIdToCaseMap.get( acctId ) ) {
                        caseRecord.Seller_Title_Clerk_Email__c = null;
                    }
                }
            }
        }

        return newLst;
    }
}