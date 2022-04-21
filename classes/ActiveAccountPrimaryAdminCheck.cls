public class ActiveAccountPrimaryAdminCheck extends TriggerInterface {

    Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

    public override void beforeUpdate(Map<Id, Sobject> oldMap, Map<Id, Sobject> newMap){

        Map<Id, Account> newAccMap = (Map<Id, Account>)newMap;
        Map<Id, Account> oldccMap = (Map<Id, Account>)oldMap;
        
        for (Account a : newAccMap.values()) {
            if (a.Active__c == TRUE && oldccMap.get(a.id).Active__c == FALSE && a.RecordTypeId == orgRecordTypeId) {
                Boolean AdminPrimExist = OrganizationPrimaryandAdminCheck.OrganizationPrimaryandAdminCheck(a.id);
                if(AdminPrimExist == FALSE){
                    a.adderror('Please ensure this Account has a Primary Contact and Admin ACV User before setting it to active');
                }
            }
        }
    }
}