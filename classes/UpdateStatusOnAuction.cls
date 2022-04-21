public class UpdateStatusOnAuction extends TriggerInterface {
    public override void beforeUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        processCases( oldMap, newMap );
    }

    public static List<Auction__c> processCases( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        Map<Id, Case> oldCaseMap =  (Map<Id, Case>) oldMap;

        List<Case> titleCaseLst = new List<Case>();
        for ( Case caseRec : (List<Case>) newMap.values() ) {
            if ( ACVUtility.recordTypeCheck( CaseUtility.TITLES_RECORDTYPE_DEV_NAME, 'Case', caseRec.RecordTypeId )
            && ( caseRec.Auction_Number__c != null && caseRec.Status != oldCaseMap.get( caseRec.Id ).Status ) ) {
                titleCaseLst.add( new Case( 
                    Auction_Number__c = caseRec.Auction_Number__c, 
                    Status = oldCaseMap.get( caseRec.Id ).Status
                ) );
            }
        }

        return updateAuctions( titleCaseLst );
    }

    private static List<Auction__c> updateAuctions( List<Case> caseLst ) {
        List<Auction__c> auctionUpdateList = new List<Auction__c>();

        for ( Case c : caseLst ) {
            auctionUpdateList.add( new Auction__c(
                id = c.Auction_Number__c, Title_Status_1__c = c.status
            ) );
        }

        if ( !auctionUpdateList.isEmpty() ) {
            update auctionUpdateList;
            return auctionUpdateList;
        }
        return null;
    }
}