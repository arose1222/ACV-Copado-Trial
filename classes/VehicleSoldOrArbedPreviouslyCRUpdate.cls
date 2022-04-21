public class VehicleSoldOrArbedPreviouslyCRUpdate extends TriggerInterface {
    public override void afterUpdate(List<sObject> oldList, List<sObject> newList) {
        List<Condition_Report__c> newCRList = (List<Condition_Report__c>)newList;
        List<Condition_Report__c> oldCRList = (List<Condition_Report__c>)oldList;
        Map<Id, Condition_Report__c> oldCRMap = new Map<Id, Condition_Report__c>(oldCRList);
        Map<String, Case> arbCaseMap = new Map<String, Case>();
        Map<String, Auction__c> auctionsMap = new Map<String, Auction__c>();
        Set<String> vinSet = new Set<String>();
        for (Condition_Report__c c : newCRList) {
            if (c.Vin__c != oldCRMap.get(c.Id).Vin__c && c.Vin__c != null) { //(c.Vin__c != null && oldPreMap.get(c.Id).Vin__c == null) || (
                vinSet.add(c.Vin__c);
            }
        }

        List<Condition_Report_Prescreen__c> crpList = [SELECT Id, Previous_Auction_Run__c, Previously_Arbitrated__c, Vin__c, Status__c FROM Condition_Report_Prescreen__c WHERE Status__c != 'Closed' AND Condition_Report__c IN :oldCRMap.keySet()];

        if (!vinSet.isEmpty() && crpList != null && !crpList.isEmpty()) {
            auctionsMap = VehicleSoldOrArbedPreviously.queryAuctions(vinSet, auctionsMap);
            if (!auctionsMap.isEmpty()) { //if there are no auctions, no need to look for arbs, saves a query and a loop. also don't need to assess the checkboxes because they would be false
                arbCaseMap = VehicleSoldOrArbedPreviously.queryCases(vinSet, arbCaseMap);
                crpList = VehicleSoldOrArbedPreviously.assessCheckboxes(auctionsMap, arbCaseMap, crpList);
                update crpList;
            }
        }
    }
}