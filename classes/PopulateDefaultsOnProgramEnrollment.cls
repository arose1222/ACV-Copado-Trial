public without sharing class PopulateDefaultsOnProgramEnrollment extends TriggerInterface {
	
    public override void beforeInsert(List<sObject> newList) {
        populateDefaultsOnEnrollmentRecord(newList);
    }
    public override void beforeUpdate(List<sObject> oldList, List<sObject> newList) {
        populateDefaultsOnEnrollmentRecord(newList);
    }
    
    public override void afterUpdate(List<sObject> oldList, List<sObject> newList) {
        List<Program_Enrollment__c> programEnrollmentListNew = (List<Program_Enrollment__c>)newList;
        List<Program_Enrollment__c> programEnrollmentListOld = (List<Program_Enrollment__c>)oldList;
        Map<Id, Program_Enrollment__c> programEnrollmentMapOld = new Map<Id, Program_Enrollment__c>(programEnrollmentListOld);
        List<Task> tasksToInsert = new List<Task>();
        for(Program_Enrollment__c programEnrollmentNew : programEnrollmentListNew){
            Program_Enrollment__c programEnrollmentOld = programEnrollmentMapOld.get(programEnrollmentNew.Id);
            if(String.isNotBlank(programEnrollmentNew.Sales_Contact__c) && programEnrollmentOld.Status__c <> programEnrollmentNew.Status__c && programEnrollmentNew.Status__c == 'Rejected'){
                Task taskToInsert = new Task();
                taskToInsert.OwnerId = programEnrollmentNew.Sales_Contact__c;
                taskToInsert.Subject = 'Dealer Rejected from Program';
                taskToInsert.WhatId = programEnrollmentNew.Id;
                taskToInsert.ActivityDate = System.today().addDays(1);
                tasksToInsert.add(taskToInsert);
            }
            if(String.isNotBlank(programEnrollmentNew.Territory_Manager__c) && programEnrollmentOld.Approval_Status__c <> programEnrollmentNew.Approval_Status__c){
                Task taskToInsert = new Task();
                switch on programEnrollmentNew.Approval_Status__c {
                    when 'TM Rejected','RSD Rejected' {
                        taskToInsert.Subject = 'Program Enrollment Rejected';
                        taskToInsert.Description = 'Notify dealer that the enrollment application is rejected.';
                    }
                    when 'RSD Approved' {
                        taskToInsert.Subject = 'Program Enrollment Approved';
                        taskToInsert.Description = 'Notify dealer that the enrollment application is approved.';
                    }
                }
                if(String.isNotBlank(taskToInsert.Subject)){
                    taskToInsert.OwnerId = programEnrollmentNew.Territory_Manager__c;
                    taskToInsert.WhatId = programEnrollmentNew.Id;
                    taskToInsert.ActivityDate = System.today().addDays(1);
                    tasksToInsert.add(taskToInsert);
                }
            }
        }
        insert tasksToInsert;
    }

    private static void populateDefaultsOnEnrollmentRecord(List<sObject> newList){
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();
        List<Program_Enrollment__c> programEnrollmentList = (List<Program_Enrollment__c>)newList;
        for(Program_Enrollment__c peObj : programEnrollmentList) {
            if(String.isNotBlank(peObj.Account__c) && (String.isBlank(peObj.Sales_Contact__c) || String.isBlank(peObj.Territory_Manager__c) || String.isBlank(peObj.Regional_Sales_Director__c) || String.isBlank(peObj.Primary_Dealership_Contact__c) || String.isBlank(peObj.IST_Sales_Rep_Email__c))) {
                accountIdSet.add(peObj.Account__c);
            }
            if(String.isBlank(peObj.Sales_Contact__c)) {
                programIdSet.add(peObj.Program__c);
            }
        }

        String userLookupFieldNamesOnAccount = CertifiedIndependentDealerUtility.getSalesContactUserLookupFields('');
        
        String accountQuery = 'SELECT Id, Primary_Contact__c, IST_Account_Owner__r.Email, Owner.ManagerId'+String.escapeSingleQuotes(userLookupFieldNamesOnAccount)+' FROM Account WHERE Id =: accountIdSet';
        List<Account> accountList = Database.query(accountQuery);
        Map<Id, Account> accountMap = new Map<Id, Account>(accountList);
        Map<Id, Program__c> programMap = new Map<Id, Program__c>([SELECT Id, Sales_Contact__c FROM Program__c WHERE Id =: programIdSet]);
        for(Program_Enrollment__c peObj : programEnrollmentList) {
            if(String.isNotBlank(peObj.Account__c) && accountMap.containsKey(peObj.Account__c)){
                Account accountObj = accountMap.get(peObj.Account__c);
                if(String.isBlank(peObj.Territory_Manager__c) || peObj.Territory_Manager__c <> accountObj.OwnerId){
                    peObj.Territory_Manager__c = accountObj.OwnerId;
                }
                if(String.isBlank(peObj.Regional_Sales_Director__c) || peObj.Regional_Sales_Director__c <> accountObj.Owner.ManagerId){
                    peObj.Regional_Sales_Director__c = accountObj.Owner.ManagerId;
                }
                if(String.isNotBlank(accountObj.IST_Account_Owner__c) && peObj.IST_Sales_Rep_Email__c <> accountObj.IST_Account_Owner__r.Email){
                    peObj.IST_Sales_Rep_Email__c = accountObj.IST_Account_Owner__r.Email;
                }
                if(String.isBlank(peObj.Primary_Dealership_Contact__c) || peObj.Primary_Dealership_Contact__c <> accountObj.Primary_Contact__c) {
                    peObj.Primary_Dealership_Contact__c = accountObj.Primary_Contact__c;
                }
                if(String.isBlank(peObj.Sales_Contact__c) && programMap.containsKey(peObj.Program__c)) {
                    String salesContactField = programMap.get(peObj.Program__c).Sales_Contact__c;
                    if(String.isNotBlank(salesContactField)){
                        peObj.Sales_Contact__c = String.valueOf(accountObj.get(salesContactField));
                    }
                }
            }
        }
    }
}