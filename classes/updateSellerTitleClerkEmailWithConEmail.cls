public class updateSellerTitleClerkEmailWithConEmail extends TriggerInterface{
   
   //This method is used to update the title clerk contact on the case record.
    public static String TITLE_VALUE = 'Title Clerk';
    public static Id conDealershipRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealership_Contact').getRecordTypeId();
    public static Id titleRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();


    public override void afterInsert(Map<Id, SObject> newMap){
        Map<Id,Contact> conIdToConRec = (Map<Id,Contact>)newMap;
        Map<Id,String> accIdToConEmail = new Map<Id,String>();
        for(Contact conRec :conIdToConRec.values()){
            if(conRec.Title_Picklist__c == TITLE_VALUE 
               && conRec.RecordTypeId == conDealershipRecTypeId
               && conRec.Email != NULL
               && conRec.AccountId != NULL){
                   accIdToConEmail.put(conRec.AccountId, conRec.Email);
               }
        }
        if(!accIdToConEmail.isEmpty()){
            updateTitleClerkEmailOnTitleCase(accIdToConEmail);
        }
    }
    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        Map<Id,Contact> conIdToConRec = (Map<Id,Contact>)newMap;
        Map<Id,Contact> conIdToOldConRec = (Map<Id,Contact>)oldMap;
        Map<Id,String> accIdToConEmail = new Map<Id,String>();
       // Id conDealershipRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealership_Contact').getRecordTypeId();
        for(Contact conRec :conIdToConRec.values()){
            if(conRec.Title_Picklist__c != conIdToOldConRec.get(conRec.Id).Title_Picklist__c 
               && conRec.Title_Picklist__c == TITLE_VALUE 
               && conRec.RecordTypeId == conDealershipRecTypeId
               && conRec.Email != NULL
               && conRec.AccountId != NULL)
            {
                accIdToConEmail.put(conRec.AccountId, conRec.Email);
            }
        }
        if(!accIdToConEmail.isEmpty()){
            updateTitleClerkEmailOnTitleCase(accIdToConEmail);
        }
    }    
    public static void updateTitleClerkEmailOnTitleCase(Map<Id,String> accIdToConEmail){
        List<Case> cases = new List<Case>();
        for(Case caseRec : [Select Id,Seller_Title_Clerk_Email__c,Seller_Dealership__c,IsClosed 
                            FROM Case 
                            WHERE Seller_Dealership__c IN :accIdToConEmail.keySet() 
                            AND RecordTypeId =: titleRecordTypeId AND IsClosed = FALSE AND Seller_Title_Clerk_Email__c = NULL ]){
           
                if(accIdToConEmail.containsKey(caseRec.Seller_Dealership__c)){
                    caseRec.Seller_Title_Clerk_Email__c = accIdToConEmail.get(caseRec.Seller_Dealership__c);
                    cases.add(caseRec);
                }
            
        }
        if(!cases.isEmpty()){
            update cases;
        }
    }
}