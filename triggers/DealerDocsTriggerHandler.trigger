trigger DealerDocsTriggerHandler on Dealer_Docs__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    (new TriggerFrameWork()).handle();
}