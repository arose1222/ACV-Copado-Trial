public without sharing class RecPriceUpdateActive extends TriggerInterface {
    public override void beforeUpdate(List<sObject> oldList, List<sObject> newList) {
        List<Recommended_Price__c> oldRecPrices = (List<Recommended_Price__c>)oldList;
        List<Recommended_Price__c> newRecPrices = (List<Recommended_Price__c>)newList;

        Map<Id, Recommended_Price__c> oldMap = new Map<Id, Recommended_Price__c>();

        for (Recommended_Price__c orp : oldRecPrices) {
            //creating a map
            oldMap.put(orp.Id, orp);
        }

        for (Recommended_Price__c nrp : newRecPrices) {
            if(nrp.Pricing_Status__c == 'Active' && oldMap.get(nrp.Id).Pricing_Status__c == 'Expired') {
                nrp.Recommended_Price_Active__c = true;
            } else if (nrp.Pricing_Status__c == 'Expired' && oldMap.get(nrp.Id).Pricing_Status__c == 'Active') {
                nrp.Recommended_Price_Active__c = false;
            }
        }
    }
}