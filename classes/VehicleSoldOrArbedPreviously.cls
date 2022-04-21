public class VehicleSoldOrArbedPreviously extends TriggerInterface {
    public override void beforeInsert(List<sObject> newList) {
        List<Condition_Report_Prescreen__c> newPreList = (List<Condition_Report_Prescreen__c>)newList;
        Map<String, Case> arbCaseMap = new Map<String, Case>();
        Map<String, Auction__c> auctionsMap = new Map<String, Auction__c>();
        Set<String> vinSet = new Set<String>();
        for (Condition_Report_Prescreen__c c : newPreList) {
            if (c.Vin__c != null) {
                vinSet.add(c.Vin__c);
            }
        }

        if (!vinSet.isEmpty()) {
            auctionsMap = queryAuctions(vinSet, auctionsMap);
            if (!auctionsMap.isEmpty()) { //if there are no auctions, no need to look for arbs, saves a query and a loop. also don't need to assess the checkboxes because they would be false
                arbCaseMap = queryCases(vinSet, arbCaseMap);
                assessCheckboxes(auctionsMap, arbCaseMap, newPreList);
            }
        }
    }

    public static Map<String, Auction__c> queryAuctions(Set<String> vinSet, Map<String, Auction__c> auctionsMap) {
        List<Auction__c> auctions = [SELECT Id, Vehicle_Id__r.Vin__c FROM Auction__c WHERE Vehicle_Id__r.Vin__c IN :vinSet];
        if (!auctions.isEmpty()) {
            for (Auction__c a : auctions) {
                if (auctionsMap.get(a.Vehicle_Id__r.Vin__c) == null) {
                    auctionsMap.put(a.Vehicle_Id__r.Vin__c, a);
                } //if the vin is already mapped to an auction, i don't need to do anything else
            }
        }
        return auctionsMap;
    }

    public static Map<String, Case> queryCases(Set<String> vinSet, Map<String, Case> arbCaseMap) {
        List<Case> arbCases = [SELECT Id, Vehicle__r.Vin__c FROM Case WHERE RecordType.DeveloperName = 'Arbitration_Claim' AND Vehicle__r.Vin__c IN :vinSet];
        if (!arbCases.isEmpty()) {
            for (Case c : arbCases) {
                if (arbCaseMap.get(c.Vehicle__r.Vin__c) == null) {
                    arbCaseMap.put(c.Vehicle__r.Vin__c, c);
                } //if the vin is already mapped to a case, i don't need to do anything else
            }
        }
        return arbCaseMap;
    }

    public static List<Condition_Report_Prescreen__c> assessCheckboxes(Map<String, Auction__c> auctionsMap, Map<String, Case> arbCaseMap, List<Condition_Report_Prescreen__c> crpList) {
        List<Condition_Report_Prescreen__c> returnList = new List<Condition_Report_Prescreen__c>();
        if ((auctionsMap != null && arbCaseMap != null) && (!auctionsMap.isEmpty() || !arbCaseMap.isEmpty())) {
            for (Condition_Report_Prescreen__c p : crpList) {
                Boolean crChanged = false;
                if (p.Status__c != 'Closed') {
                    if (auctionsMap.get(p.Vin__c) != null && auctionsMap.get(p.Vin__c).Vehicle_Id__r.Vin__c != null) {
                        p.Previous_Auction_Run__c = true;
                        crChanged = true;
                    }
                    if (arbCaseMap.get(p.Vin__c) != null && arbCaseMap.get(p.Vin__c).Vehicle__r.Vin__c != null) {
                        p.Previously_Arbitrated__c = true;
                        crChanged = true;
                    }
                    if(crChanged){
                        returnList.add(p);
                    }
                }
            }
        }
        return returnList;
    }
}