public class BudgetTrigger extends TriggerInterface {
    
    public override void beforeInsert(List<SObject> newList) {
        List<Budget__c> newBudgetList = (List<Budget__c>) newList;
        for(Budget__c b : newBudgetList){
            b.Current_Balance__c = b.Starting_Balance__c;
        }
    }

    public override void afterUpdate(List<SObject> oldMap, List<SObject> newMap) {
        Map<Id,Budget__c> oldBudgetMap = new Map<Id,Budget__c>((List<Budget__c>) oldMap);
        Map<Id,Budget__c> newBudgetMap = new Map<Id,Budget__c>((List<Budget__c>) newMap);
        List<Id> budgetIdList = new List<Id>();
        List<Budget__c> budgetToUpdate = new List<Budget__c>();
    
        for(Budget__c b : newBudgetMap.values()){
            if(oldBudgetMap.get(b.Id).Adjusted_Budget_Balance__c == null && b.Adjusted_Budget_Balance__c != null){
                budgetIdList.add(b.Id);
            }
        }
        if(budgetIdList.size()>0){
            for(Budget__c b: [SELECT Id, Adjusted_Budget_Balance__c, Starting_Balance__c, Current_Balance__c FROM Budget__c WHERE Id IN :budgetIdList]){
                //null pointer on difference
                Integer difference = Integer.valueOf(b.Adjusted_Budget_Balance__c) - Integer.valueOf(b.Starting_Balance__c);
                b.Current_Balance__c = b.Current_Balance__c + difference;
                budgetToUpdate.add(b);
            }
        }
        if(budgetToUpdate.size()>0){
            update budgetToUpdate;
        }  
    }
}