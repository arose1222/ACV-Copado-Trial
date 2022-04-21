public class GroupAffiliationUniqueIdGeneration extends TriggerInterface {

    public override void beforeInsert(List<sObject> objectList) {
    
        List<Group_Affiliation__c> newGrpAff = (List<Group_Affiliation__c>) objectList;

            for ( Group_Affiliation__c newGaf : newGrpAff ) {
                //Upon Creation of GroupAffiliation Record, if unique id is blank then populate it with the unique GroupId_AccountId combination
                if (string.isBlank(newGaf.Unique_Affiliation__c )) {
                        newGaf.Unique_Affiliation__c = newGaf.Group__c + '_' + newGaf.Account__c;
                }

            }
    }
    public override void beforeUpdate(Map<Id, Sobject> oldMap, Map<Id, Sobject> newMap){

        Map<Id, Group_Affiliation__c> newGrpAffMap = (Map<Id, Group_Affiliation__c>)newMap;
        Map<Id, Group_Affiliation__c> oldGrpAffMap = (Map<Id, Group_Affiliation__c>)oldMap;
        
            for ( Group_Affiliation__c newGaf : newGrpAffMap.values() ) {
                //Upon update of GroupAffiliation Record, if unique id is blank OR the Account record has been changed 
                //then "attempt" to populate it with the unique GroupId_AccountId combination
                //This will trigger validation rule 'Cant_Change_Account_Group_Combination'
                if (string.isBlank(newGaf.Unique_Affiliation__c ) || 
                    oldGrpAffMap.get(newGaf.id).Account__c != newGaf.Account__c) {
                        newGaf.Unique_Affiliation__c = newGaf.Group__c + '_' + newGaf.Account__c;
                }
            }
    }
}