public class AffiliationAccountChangeError extends TriggerInterface{
    //TODO: Change to Validation Rule
    
    public override void beforeUpdate(Map<Id, Sobject> oldMap, Map<Id, Sobject> newMap){

        Map<Id, Affiliation__c> newAffMap = (Map<Id, Affiliation__c>)newMap;
        Map<Id, Affiliation__c> oldAffMap = (Map<Id, Affiliation__c>)oldMap;
        
            for ( Affiliation__c newaf : newAffMap.values() ) {
                //Upon update of Affiliation Record, if unique id is blank OR the Account record has been changed 
                //then "attempt" to populate it with the unique AccountId_UserId combination
                //This will trigger an error if the Account field is already populated and attempting to change
                if (!string.isBlank(newaf.id__c ) && 
                    oldAffMap.get(newaf.id).Account__c != newaf.Account__c) {
                        newaf.adderror('Cannot change Affiliation account after creation');
                }
            }
    }
}