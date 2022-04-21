public class OpsCaseHasOpenCase extends TriggerInterface{
    // These are the CI statuses that are considered open from the ops case perspective
    private static set<String> opsOpenStatusSet = new set<String>{'New','Working'};
    // These are the CI statuses that are considered open from the support case perspective
    private static set<String> supportOpenStatusSet = new set<String>{'New','Working','AM Follow Up'};
    
    /**
     * afterInsert description
     * This method is designed to run on the Related_Case object so we can listen for When related cases are generated
     */
    public override void afterInsert(List<SObject> newList){
        List<Customer_Inquiry__c> ciList = (List<Customer_Inquiry__c>) newList;
        Set<Id> caseIds = new Set<Id>();

        for(Customer_Inquiry__c ci :ciList){
            if (opsOpenStatusSet.contains(ci.Status__c)) { // for sc , created not closed
                if (ci.Ops_Case__c != null) {
                    caseIds.add(ci.Ops_Case__c);
                }
            }
            if (supportOpenStatusSet.contains(ci.Status__c)) {
                if (ci.Support_Case__c != null) {
                    caseIds.add(ci.Support_Case__c);
                }
            }
        }

        if(!caseIds.isEmpty()) {
            List<Case> allParentCases = [SELECT Id, Open_Customer_Inquiry__c FROM Case WHERE Id IN :caseIds AND Open_Customer_Inquiry__c = false];
            for(Case c : allParentCases) {
                c.Open_Customer_Inquiry__c = true;
            }
            update allParentCases;
        }
    }

    /**
     * afterUpdate description
     * This method will set Open_Customer_Inquiry__c on the parent ops case to true or false depending on the status of its children Inquiries
     * If one or more child CIs have a status of New or Working Open_Customer_Inquiry__c is true
     */
    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){
        Map<Id, Customer_Inquiry__c> oldCIMap = (Map<Id,Customer_Inquiry__c>) oldMap;
        Map<Id, Customer_Inquiry__c> newCIMap = (Map<Id, Customer_Inquiry__c>) newMap;
        Set<Id> opsCaseIds = new Set<Id>();
        Set<Id> supportCaseIds = new Set<Id>();
        for (Customer_Inquiry__c ci : newCIMap.values()) {
            if ((ci.Status__c == 'Closed' && oldCIMap.get(ci.Id).Status__c != 'Closed') || (ci.Status__c != 'Closed' && oldCIMap.get(ci.Id).Status__c == 'Closed')) {
                if (ci.Support_Case__c != null) {
                    supportCaseIds.add(ci.Support_Case__c);
                }
            }
            if(ci.Ops_Case__c != null && ((opsOpenStatusSet.contains(ci.Status__c) && !opsOpenStatusSet.contains(oldCIMap.get(ci.Id).Status__c) ) || ( opsOpenStatusSet.contains(oldCIMap.get(ci.Id).Status__c) && !opsOpenStatusSet.contains(ci.Status__c) ))) {
                opsCaseIds.add(ci.Ops_Case__c);   
            }
        }

        if(!opsCaseIds.isEmpty() || !supportCaseIds.isEmpty()) {
            Map<Id,Case> caseIdToCase = new Map<Id,Case>();
            Set<Id> casesToIgnore = new Set<Id>();

            for(Customer_Inquiry__c ci :[SELECT Id, Ops_Case__c, Ops_Case__r.Open_Customer_Inquiry__c, Support_Case__c, Support_Case__r.Open_Customer_Inquiry__c, Status__c FROM Customer_Inquiry__c WHERE Ops_Case__c IN :opsCaseIds OR Support_Case__c IN :supportCaseIds ORDER BY Status__c ASC]) {
                if (caseIdToCase.get(ci.Id)?.Open_Customer_Inquiry__c != true) {
                    if(opsCaseIds.contains(ci.Ops_Case__c)) {
                        if(opsOpenStatusSet.contains(ci.Status__c) && ci.Ops_Case__r.Open_Customer_Inquiry__c == true) {
                            casesToIgnore.add(ci.Ops_Case__c);
                        }
                        else if(!casesToIgnore.contains(ci.Ops_Case__c) && opsOpenStatusSet.contains(ci.Status__c) && ci.Ops_Case__r.Open_Customer_Inquiry__c == false) {
                            caseIdToCase.put(ci.Ops_Case__c, new Case(Id = ci.Ops_Case__c, Open_Customer_Inquiry__c = true));
                        } 
                        else if(!casesToIgnore.contains(ci.Ops_Case__c) && !opsOpenStatusSet.contains(ci.Status__c) && ci.Ops_Case__r.Open_Customer_Inquiry__c == true) {
                            caseIdToCase.put(ci.Ops_Case__c, new Case(Id = ci.Ops_Case__c, Open_Customer_Inquiry__c = false));
                        }
                    }
                    
                    if (supportCaseIds.contains(ci.Support_Case__c)) {
                        if(supportOpenStatusSet.contains(ci.Status__c) && ci.Support_Case__r.Open_Customer_Inquiry__c == true) {
                            casesToIgnore.add(ci.Support_Case__c);
                        }
                        else if(!casesToIgnore.contains(ci.Support_Case__c) && supportOpenStatusSet.contains(ci.Status__c) && ci.Support_Case__r.Open_Customer_Inquiry__c == false) {
                            caseIdToCase.put(ci.Support_Case__c, new Case(Id = ci.Support_Case__c, Open_Customer_Inquiry__c = true));
                        } 
                        else if(!casesToIgnore.contains(ci.Support_Case__c) && !supportOpenStatusSet.contains(ci.Status__c) && ci.Support_Case__r.Open_Customer_Inquiry__c == true) {
                            caseIdToCase.put(ci.Support_Case__c, new Case(Id = ci.Support_Case__c, Open_Customer_Inquiry__c = false));
                        }
                    }
                }
                
            }
            update caseIdToCase.values();
        }
    }
}