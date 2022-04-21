public class GroupAffiliationAccountChangeError extends TriggerInterface{
    
    public override void beforeUpdate(Map<Id, Sobject> oldMap, Map<Id, Sobject> newMap){

        Map<Id, Group_Affiliation__c> newGrpAffMap = (Map<Id, Group_Affiliation__c>)newMap;
        Map<Id, Group_Affiliation__c> oldGrpAffMap = (Map<Id, Group_Affiliation__c>)oldMap;
        
            for ( Group_Affiliation__c newGaf : newGrpAffMap.values() ) {
                //Upon update of GroupAffiliation Record, if unique id is blank OR the Account record has been changed 
                //then "attempt" to populate it with the unique GroupId_AccountId combination
                //This will trigger an error if the Account field is already populated and attempting to change
                if (!string.isBlank(newGaf.Unique_Affiliation__c )  
                    && oldGrpAffMap.get(newGaf.id).Account__c != null 
                    && oldGrpAffMap.get(newGaf.id).Account__c != newGaf.Account__c) {
                        newGaf.adderror('Cannot change Group Affiliation account after creation');
                }
            }
    }
}