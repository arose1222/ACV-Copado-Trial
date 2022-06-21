/******************************************
*Author - Avinash Sharma(Saisystems) 
*Description - Test Class for UpdateProgramEnrollmentsOnAccountChange 
*Date - 28th Jan 2021
*******************************************/
@isTest
public class UpdateProgramEnrollmentsOnAccountTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        User p = TestUtility.createUser();
        User u = TestUtility.createUser(p.Id);
        
        List<Account> accountsList = new List<Account>(); 
        List<Account> accountsNewList = new List<Account>(); 
        
        Account acc = TestUtility.createAccount();
        acc.Rating='Prospect';
        acc.IST_Account_Owner__c =u.Id;
        accountsList.add(acc);
       
        insert accountsList;
        
		Contact con = TestUtility.createContact(acc);
        insert con;
        
        List<Program__c> programsList = new List<Program__c>();
        Program__c prog = new Program__c();
        prog.Name ='Program';
        Prog.Active__c =true;
        prog.Sales_Contact__c='IST_Account_Owner__c';
        Prog.Status__c ='Eligible';
        programsList.add(Prog);
        
        Program__c progOwnerId = new Program__c();
        progOwnerId.Name ='Program 1';
        progOwnerId.Active__c =true;
        progOwnerId.Sales_Contact__c='OwnerId';
        progOwnerId.Status__c ='Eligible';
        programsList.add(progOwnerId);
        insert programsList;
        
        List<Program_Enrollment__c> programEnList = new List<Program_Enrollment__c>();
        /*for(Integer i=1; i<=5; i++){
            Program_Enrollment__c progEnroll = new Program_Enrollment__c(Program__c =progOwnerId.Id, Account__c=acc.Id, Primary_Dealership_Contact__c=con.Id,Name ='Program enrollment'+i, Status__c='Rejected', Approval_Status__c ='TM Rejected');
            programEnList.add(progEnroll);
        }*/
        
        Program_Enrollment__c pe1=new Program_Enrollment__c();
        pe1.Program__c=prog.Id;
        pe1.Account__c=acc.Id;
		pe1.Primary_Dealership_Contact__c=con.Id;
		pe1.Name='ProgEnrol 1'; 
        pe1.Status__c='Rejected';
        pe1.Approval_Status__c ='TM Rejected';
        programEnList.add(pe1);
        
         Program_Enrollment__c pe2=new Program_Enrollment__c();
        pe2.Program__c=progOwnerId.Id;
        pe2.Account__c=acc.Id;
		pe2.Primary_Dealership_Contact__c=con.Id;
		pe2.Name='ProgEnrol 2'; 
        pe2.Status__c='Rejected';
        pe2.Approval_Status__c ='TM Rejected';
        programEnList.add(pe2);
        insert programEnList;
        acc.IST_Account_Owner__c = userinfo.getUserId();
        update acc;
        accountsNewList.add(acc);
        UpdateProgramEnrollmentsOnAccountChange updateprogramenrollmentsaccountchange = new UpdateProgramEnrollmentsOnAccountChange();
        updateprogramenrollmentsaccountchange.afterUpdate(accountsList, accountsNewList);
        System.assertEquals(userinfo.getUserId(), acc.IST_Account_Owner__c);
        System.assertNotEquals(null, acc.IST_Account_Owner__c);
    }
    @isTest
    static void TestafterUpdate(){
        List<Account> aclist =[Select Id, Name, Account.IST_Account_Owner__c, Account.OwnerId from Account];
        List<Program_Enrollment__c> prenrolllist = [Select ID, Name,Program__c,Account__c,Primary_Dealership_Contact__c,Status__c, Approval_Status__c,Program__r.Sales_Contact__c,Sales_Contact__c  From Program_Enrollment__c];
        List<sObject> aclists = new List<sObject>();
        for (Account ac : aclist){
            //ac.Name='Ajay';
            ac.Rating='Mild';
            ac.of_Locations__c=5;
           // ac.Manager_Id__c=u.Id;
            aclists.add(ac);
        }
        upsert aclists; 
        
        UpdateProgramEnrollmentsOnAccountChange updateprogramenrollmentsaccountchange = new UpdateProgramEnrollmentsOnAccountChange();
        //updateprogramenrollmentsaccountchange.afterUpdate(aclist, aclists);
        System.assertEquals(1, aclist.size());
        System.assertEquals(aclist,aclists);
        System.assertEquals(2, prenrolllist.size());
        
        //System.assertNotEquals(null,prenrolllist[0].Primary_Dealership_Contact__c );
        System.assertNotEquals(null, prenrolllist[0].Program__r.Sales_Contact__c);
    }

}