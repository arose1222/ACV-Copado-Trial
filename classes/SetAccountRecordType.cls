public class SetAccountRecordType extends TriggerInterface {
    
    String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

    public override void beforeInsert(List<sObject> objectList) {
    
        List<Account> newAccounts = (List<Account>) objectList;
        
            for ( Account newAcc : newAccounts ) {
                if (LeadConversion.isConverting) {
                    newAcc.RecordTypeId = accRTId;
                    newAcc.Active__c= false;
                    newAcc.Creation_Source__c= 'Registration';
                    newAcc.Lead_Convert_Status__c= 'Converting';
                }
            }
    }
    
}