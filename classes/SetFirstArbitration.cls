public class SetFirstArbitration extends TriggerInterface {

    public override void beforeInsert(List<sObject> objectList) {
        // For an arbitration case that is the first arb associated with a dealer account set First_Arbitration__c to true on that case
        List<Case> newCases = (List<Case>) objectList;
        Map<Id,Case> accountIdToCase = new Map<Id,Case>();
        for(Case c : newCases){
            if(ACVUtility.recordTypeCheck('Arbitration_Claim','Case',c.RecordTypeId) && c.AccountId != null){
                accountIdToCase.put(c.AccountId,c);
            }
        }
        if(accountIdToCase.size() > 0){
            Id arbRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
            List<Case> existingArbCases = [SELECT Id, AccountId FROM Case WHERE AccountId = :accountIdToCase.keySet() AND RecordTypeId = :arbRecordTypeID];
            Set<Id> accountIdsWithPriorArbs = new Set<Id>();
            // existingArbCases does not include current trigger.new cases as we are before insert
            for(Case cs : existingArbCases){
                accountIdsWithPriorArbs.add(cs.AccountId);
            }
            // if the newly created arb case does not have any existing sibling arbs, then set first arb to true
            for(Case newArb : accountIdToCase.values()){
                if(!accountIdsWithPriorArbs.contains(newArb.AccountId)){
                    newArb.First_Arbitration__c = true;
                }
            }
        }
    }
}