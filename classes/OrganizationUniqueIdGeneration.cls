public class OrganizationUniqueIdGeneration extends TriggerInterface {
     //TODO: Pull out common parts of the Code to a method

    Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

    public override void afterInsert(List<sObject> objectList) {
    
        List<Account> newAccounts = (List<Account>) objectList;
        Map<id, String> idMap = new Map<id, String>();
        List<Account> updateList = new List<Account>();
        for(Account newAccs : newAccounts){
            idMap.put(newAccs.id, newAccs.Organization_Auto_Inc_Id__c);
        }
        List<Account> accLst = new List<Account>([Select id, Organization_Auto_Inc_Id__c, Dealership_Id__c, 
        RecordTypeId From Account Where id IN: newAccounts]);

            for ( Account newAcc : accLst ) {
                if (string.isBlank(newAcc.Dealership_id__c) && newAcc.RecordTypeId == orgRecordTypeId) {
                    newAcc.Dealership_id__c = idMap.get(newAcc.id);
                    updateList.add(newAcc);
                }
            }
            try{
                if(!updateList.isempty()){
                    update updateList;
                }
            }
            catch(Exception e){
                IdentityHelper.makeApexLog(acvutility.currentLineNumber(), 
                    'OrganizationUniqueIdGeneration: Get Account Id failure: '+e.getStackTraceString(), 
                    SplunkHelper.LOGLEVEL.ERROR, 'OrganizationUniqueIdGeneration', 
                    e.getMessage(), 
                    'Account');
                    //TODO: Throw Fatal error after Splunk log
            }
    }
    public override void afterUpdate(List<Sobject> oldList, List<Sobject> newlist){
    
        List<Account> newAccounts = (List<Account>) newlist;
        Map<id, String> idMap = new Map<id, String>();
        List<Account> updateList = new List<Account>();
        for(Account newAccs : newAccounts){
            idMap.put(newAccs.id, newAccs.Organization_Auto_Inc_Id__c);
        }
        List<Account> accLst = new List<Account>([Select id, Organization_Auto_Inc_Id__c, Dealership_Id__c, 
        RecordTypeId From Account Where id IN: newAccounts]);

            for ( Account newAcc : accLst ) {
                if (string.isBlank(newAcc.Dealership_id__c) && newAcc.RecordTypeId == orgRecordTypeId) {
                    newAcc.Dealership_id__c = idMap.get(newAcc.id);
                    updateList.add(newAcc);
                }
            }
            try{
                if(!updateList.isempty()){
                    update updateList;
                }
            }
            catch(Exception e){
                IdentityHelper.makeApexLog(acvutility.currentLineNumber(), 
                    'OrganizationUniqueIdGeneration: Get Account Id failure: '+e.getStackTraceString(), 
                    SplunkHelper.LOGLEVEL.ERROR, 'OrganizationUniqueIdGeneration', 
                    e.getMessage(), 
                    'Account');
            }
    }
}