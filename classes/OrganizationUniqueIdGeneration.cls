public class OrganizationUniqueIdGeneration extends TriggerInterface {
    //TODO: Pull out common parts of the Code to a method
    Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
   Salesforce_Setting__mdt auto_inc_jump = Salesforce_Setting__mdt.getInstance('uat_orgs_unique_id_jump');
   //Salesforce_Setting__mdt auto_inc_jump;
   String environmentName = ACVUtility.getEnvironmentName();

   public override void afterInsert(List<sObject> objectList) {
   
       List<Account> newAccounts = (List<Account>) objectList;
       Map<id, String> idMap = new Map<id, String>();
       List<Account> updateList = new List<Account>();
       /* commented as part of IO-1646 - refactoring code, querying is not needed
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
           }*/
           for ( Account newAcc : newAccounts ) {
                if (string.isBlank(newAcc.Dealership_id__c) && newAcc.RecordTypeId == orgRecordTypeId && environmentName == 'UAT') {
                    //newAcc.Dealership_id__c = String.valueOf(Integer.valueOf(idMap.get(newAcc.id)) + Integer.valueOf(auto_inc_jump.Value__c));
                    String dealershipId = String.valueOf(Integer.valueOf(newAcc.Organization_Auto_Inc_Id__c) + Integer.valueOf(auto_inc_jump.Value__c));
                    updateList.add(new Account(Id = newAcc.Id, Dealership_id__c = dealershipId));
                }
                if (string.isBlank(newAcc.Dealership_id__c) && newAcc.RecordTypeId == orgRecordTypeId && environmentName != 'UAT') {
                    updateList.add(new Account(Id = newAcc.Id, Dealership_id__c = newAcc.Organization_Auto_Inc_Id__c));
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
       /* commented as part of IO-1646 - refactoring code, querying is not needed
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
           }*/
            for( Account newAcc : newAccounts ) {
                if (string.isBlank(newAcc.Dealership_id__c) && newAcc.RecordTypeId == orgRecordTypeId &&  environmentName == 'UAT') {
                    //newAcc.Dealership_id__c = String.valueOf(Integer.valueOf(idMap.get(newAcc.id)) + Integer.valueOf(auto_inc_jump.Value__c));
                    String dealershipId = String.valueOf(Integer.valueOf(newAcc.Organization_Auto_Inc_Id__c) + Integer.valueOf(auto_inc_jump.Value__c));
                    updateList.add(new Account(Id = newAcc.Id, Dealership_id__c = dealershipId));
                }
                if (string.isBlank(newAcc.Dealership_id__c) && newAcc.RecordTypeId == orgRecordTypeId && environmentName != 'UAT') {
                    updateList.add(new Account(Id = newAcc.Id, Dealership_id__c = newAcc.Organization_Auto_Inc_Id__c));
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