trigger AuctionTrigger on Auction__c ( before update, before insert, after insert, after update, after delete ) {
    (new TriggerFrameWork()).handle();
}