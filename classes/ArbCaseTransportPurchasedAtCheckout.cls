public class ArbCaseTransportPurchasedAtCheckout extends TriggerInterface {
    public override void beforeUpdate(List<sObject> oldList, List<sObject> newList) {
        Map<Id, Case> oldMap = new Map<Id, Case>((List<Case>)oldList);
        List<Case> caseList = (List<Case>)newList; //don't really care about the old values since they will all be blank
        Map<Id, Case> arbMap = new Map<Id, Case>();
        Set<Id> aucIdSet = new Set<Id>();

        for (Case c : caseList) {
            if (!String.isBlank(c.Auction_Number__c) && (c.Auction_Number__c != oldMap.get(c.Id).Auction_Number__c) && ACVUtility.recordTypeCheck('Arbitration_Claim', 'Case', c.RecordTypeId) && !c.ACV_Transport_Purchased_at_Checkout__c) {
                arbMap.put(c.Auction_Number__c, c);
            }
        }

        //query - Transportation Case SF Consumer Name
        List<Salesforce_Setting__mdt> settingList = [SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Transportation Case SF Consumer Name' LIMIT 2];

        if (settingList.size() == 2) {
            for (Case t : [SELECT Id, CreatedBy.Name, Auction_Number__c FROM Case WHERE Auction_Number__c IN :arbMap.keySet() AND RecordType.DeveloperName = 'Transportation']) {
                if (t.CreatedBy.Name == settingList[0].Value__c || t.CreatedBy.Name == settingList[1].Value__c) {
                    arbMap.get(t.Auction_Number__c).ACV_Transport_Purchased_at_Checkout__c = true;
                }
            }//no update call as this is a before trigger
        }
    }
}