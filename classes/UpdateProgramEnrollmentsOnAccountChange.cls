public without sharing class UpdateProgramEnrollmentsOnAccountChange extends TriggerInterface {
    public override void afterUpdate(List<sObject> oldList, List<sObject> newList) {
        List<Account> accountListNew = (List<Account>)newList;
        List<Account> accountListOld = (List<Account>)oldList;
        Map<Id, Account> accountMapOld = new Map<Id, Account>(accountListOld);
        
        Schema.DescribeFieldResult salesContactFieldResult = CertifiedIndependentDealerUtility.getSobjectFieldResult('Program__c', 'Sales_Contact__c');
        String userLookupFieldNamesOnAccount = '';
        List<String> accountManagerFieldNames = new List<String>();
        if(salesContactFieldResult != null){
            System.debug('---pickListVal--'+salesContactFieldResult.getPicklistValues());
            for( Schema.PicklistEntry pickListVal : salesContactFieldResult.getPicklistValues()){
                accountManagerFieldNames.add(pickListVal.getValue());
                System.debug('---accountManagerFieldNames---'+accountManagerFieldNames);
                userLookupFieldNamesOnAccount += ', Account__r.'+pickListVal.getValue();
            }
        }
        Set<Id> accountsWithManagerChanged = new Set<Id>();
        for(Account accountNew : accountListNew){
            Account accountOld = accountMapOld.get(accountNew.Id);
            for(String accountManagerFieldName : accountManagerFieldNames){
                System.debug('---accountNew---'+accountNew.get(accountManagerFieldName));
                System.debug('---accountOld---'+accountOld.get(accountManagerFieldName));
                if(accountNew.get(accountManagerFieldName) <> accountOld.get(accountManagerFieldName)){
                    accountsWithManagerChanged.add(accountNew.Id);
                }
            }
        }
        if(!accountsWithManagerChanged.isEmpty()){
        	String programEnrollmentQuery = 'SELECT Id, Sales_Contact__c, Program__r.Sales_Contact__c, Account__c'+userLookupFieldNamesOnAccount+' FROM Program_Enrollment__c WHERE Account__c <> NULL AND Account__c =: accountsWithManagerChanged';
            List<Program_Enrollment__c> programEnrollmentList = Database.query(programEnrollmentQuery);
            List<Program_Enrollment__c> programEnrollmentToUpdateList = new List<Program_Enrollment__c>();
            for(Program_Enrollment__c peObj : programEnrollmentList){
                Account dealerRecord = (Account)peObj.getSObject('Account__r');
                Object salesContactObj = dealerRecord.get(''+peObj.Program__r.Sales_Contact__c);
                String salesContactId = salesContactObj <> NULL ? String.valueOf(salesContactObj) : null;
                if(peObj.Sales_Contact__c <> salesContactId){
                    peObj.Sales_Contact__c = salesContactId;
                    programEnrollmentToUpdateList.add(peObj);
                }
            }
            if(programEnrollmentToUpdateList.size() > 0){
                update programEnrollmentToUpdateList;
            }    
        }        
    }
}