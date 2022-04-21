public class AccountTerritoryProcesses {
    // Get rid of one day
    public static void insertRegionProcess(List<SObject> triggerNew){
        /*List<Account> accountList = (List<Account>)triggerNew;
        for(Account a : accountList){
            //logic to get the field and split it (Check for null before we try to split)
            if(a.Territory__c != null){
                // System.debug('territory not null');
                String region = a.Territory_Name__c.substringBetween('(',')');
                // System.debug(region);
                a.Sales_Region__c = region;
            }
        }*/
    }

    public static void updateRegionProcess(Map<Id,SObject> triggerNew, Map<Id,SObject> triggerOld){
        /*Map<Id,Account> accountMapNew = (Map<Id,Account>)triggerNew;
        Map<Id,Account> accountMapOld = (Map<Id,Account>)triggerOld;
        List<Account> accountsToUpdate = new List<Account>();
        //loop through and compare old to new territory to see if anything has changed
        for(Account a : accountMapNew.values()){
            // System.debug('enter loop');
            if( accountMapOld.get(a.Id).Territory_Name__c != a.Territory_Name__c && a.Territory_Name__c != null){
                // System.debug('new and old not same and territory not null');
                // System.debug(a.Territory__c);
                //if somthing has changed on the terrirtory run our logic to split
                String region = a.Territory_Name__c.substringBetween('(',')');
                // System.debug(region);
                a.Sales_Region__c = region;
            }
        }*/
    }
}