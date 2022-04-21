public class AffiliationUniqueIdGeneration extends TriggerInterface {
    //TODO: Pull out common parts of the Code to a method
    //TODO: IF statement that DealerId and UserId are populated before attempting to fill in affiliationId

    public override void beforeInsert(List<sObject> objectList) {
    
        List<Affiliation__c> newAff = (List<Affiliation__c>) objectList;
        List<Id> accIdList = new List<Id>();
        List<Id> conIdList = new List<Id>();

        for(Affiliation__c a : newAff){
            accIdList.add(a.Account__c);
            conIdList.add(a.Contact__c);
        }    
        Map<id,Account> accMap = new Map<Id, Account>([Select id, Dealership_Id__c, RecordType.DeveloperName From Account Where id IN: accIdList]);
        Map<id,Contact> conMap = new Map<Id, Contact>([Select id, id__c, RecordType.DeveloperName From Contact Where id IN: conIdList]);
        
            for ( Affiliation__c Aff : newAff ) {
                //Upon Creation of Affiliation Record, if unique id is blank then populate it with the unique OrgId_UserId combination
                if (string.isBlank(Aff?.id__c )) {
                    Aff.id__c = IdentityHelper.createAffiliationId(accMap.get(Aff.Account__c)?.Dealership_Id__c, conMap.get(Aff.Contact__c)?.id__c);
                        //Aff.id__c = 'OrganizationId:' + accMap.get(Aff.Account__c)?.Dealership_Id__c + '_' + 'UserId:' + conMap.get(Aff.Contact__c)?.id__c;
                }

            }
    }
    public override void beforeUpdate(Map<Id, Sobject> oldMap, Map<Id, Sobject> newMap){

        Map<Id, Affiliation__c> newAffMap = (Map<Id, Affiliation__c>)newMap;
        Map<Id, Affiliation__c> oldAffMap = (Map<Id, Affiliation__c>)oldMap;

        List<Id> accIdList = new List<Id>();
        List<Id> conIdList = new List<Id>();

        Map<id,Affiliation__c> affMap = new Map<Id, Affiliation__c>([Select id, id__c, Account__c, Account__r.Dealership_Id__c, 
        Contact__c, Contact__r.id__c From Affiliation__c Where id IN: newAffMap.keyset()]);
         
            for ( Affiliation__c newaf : newAffMap.values() ) {
                //Upon update of Affiliation Record, if unique id is blank OR the Account record has been changed 
                //then "attempt" to populate it with the unique AccountId_UserId combination
                //This will trigger validation rule 'Cant_Change_Account_Combination'
                if (string.isBlank(newaf.id__c ) || 
                oldAffMap.get(newaf.id).Account__c != newaf.Account__c) {
                    newaf.id__c = IdentityHelper.createAffiliationId(affMap.get(newaf.id)?.Account__r?.Dealership_ID__c, affMap.get(newaf.id)?.Contact__r?.id__c);
                    //newaf.id__c = 'OrganizationId:' + affMap.get(newaf.id)?.Account__r?.Dealership_ID__c + '_' + 'UserId:' + affMap.get(newaf.id)?.Contact__r?.id__c;
                }
            }
    }
}