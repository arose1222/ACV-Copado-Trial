public class FastPassExperianAccountTrigger extends TriggerInterface {
   
     public override void beforeInsert(List<SObject> newList){	
        List<Account> newAccountList = (List<Account>)newList;
        for (Account acc : newAccountList) {
            system.debug('Account '+acc.Name );
            if (acc.FastPass_Approval__c == 'In Progress') {
                ExperianCalloutService.makeCallout((String)acc.id);
            }
        }
    }
    public override void beforeUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){

        Map<Id, Account> newMap = (Map<Id, Account>)incomingNewMap;
        Map<Id, Account> oldMap = (Map<Id, Account>)incomingOldMap;
        
        for (Account acc : newMap.values()) {
            if (acc.FastPass_Approval__c == 'In Progress' && oldMap.get(acc.Id).FastPass_Approval__c !='In Progress') {
   				ExperianCalloutService.makeCallout((String)acc.id);
            }
        }
    }
}