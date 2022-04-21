public class OrganizationGuidGeneration extends TriggerInterface {
    //TODO: Use utility method for recordType checks

    Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

    public override void beforeInsert(List<sObject> objectList) {
    
        List<Account> newAccounts = (List<Account>) objectList;
        
            for ( Account newAcc : newAccounts ) {
                if (string.isBlank(newAcc.Organization_Guid__c) && newAcc.RecordTypeId == orgRecordTypeId && newAcc.Dealership_Id__c != null) {
                    newAcc.Organization_Guid__c = ACVUtility.NewGuid();
                }
            }
    }
    public override void beforeUpdate(List<Sobject> oldList, List<Sobject> newlist){

        List<Account> newAccList = (List<Account>)newlist;
        
            for ( Account newAcc : newAccList ) {
                if (string.isBlank(newAcc.Organization_Guid__c) && newAcc.RecordTypeId == orgRecordTypeId && newAcc.Dealership_Id__c != null) {
                    newAcc.Organization_Guid__c = ACVUtility.NewGuid();
                }
            }
    }
}