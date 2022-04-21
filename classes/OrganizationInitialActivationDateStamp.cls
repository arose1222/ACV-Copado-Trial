public class OrganizationInitialActivationDateStamp extends TriggerInterface {
    //TODO: Pull out common parts of the Code to a method

   Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();


   public override void beforeInsert(List<sObject> objectList) {
    
    List<Account> newAccounts = (List<Account>) objectList;
    List<Account> updateList = new List<Account>();

    // List<Account> accLst = new List<Account>([Select id, Active__c, Dealership_Id__c, 
    // RecordTypeId, Initial_Activation_Date__c From Account Where id IN: newAccounts]);

        //trigger anytime an Account is Created and Active is set to true
        for(Account newAcc : newAccounts) {
            // if Active is set to true, account is standard, and initial activation date is null  
            if(newAcc.RecordTypeId == orgRecordTypeId && newAcc.Active__c == True && newAcc.Initial_Activation_Date__c == null) {
                newAcc.Initial_Activation_Date__c = Datetime.Now();
                // updateList.add(newAcc);
            }
        //     try{
        //         if(!updateList.isempty()){
        //            update updateList;
        //         }
        //     }
        //    catch(Exception e){
        //        IdentityHelper.makeApexLog(acvutility.currentLineNumber(), 
        //            'OrganizationInitialActivationDateStamp: Active Date stamp failure: '+e.getStackTraceString(), 
        //            SplunkHelper.LOGLEVEL.ERROR, 'OrganizationInitialActivationDateStamp', 
        //            e.getMessage(), 
        //            'Account');
        //            //TODO: Throw Fatal error after Splunk log
        //    }
        }
    }
    public override void beforeUpdate(List<Sobject> oldList, List<Sobject> newlist){

       List<Account> newAccLst = (List<Account>) newlist;
       List<Account> oldAccLst = (List<Account>) oldList;

    //    List<Account> newAccounts = new List<Account>([Select id, Active__c, Dealership_Id__c, 
    //    RecordTypeId, Initial_Activation_Date__c From Account Where id IN: newAccLst]);

       Map<Id, Account> oldAccountMap = new Map<Id, Account>(oldAccLst);

       List<Account> updateList = new List<Account>();

            for ( Account newAcc : newAccLst ) {
               if (newAcc.RecordTypeId == orgRecordTypeId && newAcc.Active__c == True
               && newAcc.Initial_Activation_Date__c == null && oldAccountMap.get(newAcc.Id).Active__c == False){
                newAcc.Initial_Activation_Date__c = Datetime.Now();
                // updateList.add(newAcc);
               }
                // try{
                //     if(!updateList.isempty()){
                //         update updateList;
                //     }
                // }
                // catch(Exception e){
                //     IdentityHelper.makeApexLog(acvutility.currentLineNumber(), 
                //         'OrganizationInitialActivationDateStamp: Active Date stamp failure: '+e.getStackTraceString(), 
                //         SplunkHelper.LOGLEVEL.ERROR, 'OrganizationInitialActivationDateStamp', 
                //         e.getMessage(), 
                //         'Account');
                //         //TODO: Throw Fatal error after Splunk log
                //     }
            }
    }
}