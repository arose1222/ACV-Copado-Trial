public class AccountMergeDependentRecordError extends TriggerInterface {


    Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

    public override void beforeDelete(Map<Id,SObject> incomingMap) {

        Map<Id, Account> mergeAccMap = (Map<Id, Account>)incomingMap;
        Map<Id, Account> accCheckMap = new Map<Id, Account>([Select Id, RecordTypeId, (Select Id From Auctions__r), (Select Id From BuyerAuctions__r), (Select Id From Cases), (Select Id From Cases1__r) 
        From Account Where Id In :mergeAccMap.keyset()]);
        
        for (Account a : accCheckMap.values()) {
            if (a.RecordTypeId == orgRecordTypeId && AccountMergeDependentRecordCheck.AccountMergeDependentRecordCheck(a)) {
                mergeAccMap.get(a.id).adderror('This Account has an Auction or Case record associated with it and cannot be merged.');
            }
        }
    }
}