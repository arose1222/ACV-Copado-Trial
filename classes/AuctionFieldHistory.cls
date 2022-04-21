public class AuctionFieldHistory extends TriggerInterface {
    
    public override void afterInsert(List<SObject> newList) {
        FieldHistoryProcess.create( newList , null );
    }

    public override void afterUpdate(List<SObject> newList, List<SObject> oldList) {
        Map<Id, Auction__c> oldMap = new Map<Id, Auction__c>((List<Auction__c>)oldList);
        FieldHistoryProcess.create( newList, oldMap );
    }
}