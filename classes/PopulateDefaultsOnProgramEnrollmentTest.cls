/******************************************
*Author - Avinash Sharma(Saisystems) 
*Description - Test Class for PopulateDefaultsOnProgramEnrollment 
*Date - 28th Jan 2021
*******************************************/
@isTest
public class PopulateDefaultsOnProgramEnrollmentTest {
    @TestSetup
    static void makeData(){
        
        Account acc=TestUtility.createAccount();
        acc.IST_Account_Owner__c =UserInfo.getUserId();
        insert acc;
        
        Contact con = TestUtility.createContact(acc);
        insert con;
        acc.Primary_Contact__c=con.Id;
        update acc;
        
         List<Program__c> programList = New List<Program__c>();
        Program__c prog = new Program__c();
        prog.Name ='Program';
        Prog.Active__c =true;
        Prog.Sales_Contact__c='IST_Account_Owner__c';
        prog.Program_Rule_Logic__c='1 AND 2';
        Prog.Status__c ='Eligible';
        programList.add(Prog);
        
        Program__c Prog_1 = new Program__c();
        Prog_1.Name ='Program 1';
        Prog_1.Active__c =true;
        Prog_1.Sales_Contact__c='IST_Account_Owner__c';
        Prog_1.Program_Rule_Logic__c='1 AND 2';
        Prog_1.Status__c ='Eligible';
        programList.add(Prog_1);
        
        Program__c Prog_2 = new Program__c();
        Prog_2.Name ='Program 1';
        Prog_2.Active__c =true;
        Prog_2.Sales_Contact__c='IST_Account_Owner__c';
        Prog_2.Program_Rule_Logic__c='1 AND 2';
        Prog_2.Status__c ='Eligible';
        programList.add(Prog_2);
        insert programList;
        
        List<Program_Enrollment__c> programEnrollList = new List<Program_Enrollment__c>();
        Program_Enrollment__c progEnroll = new Program_Enrollment__c(Program__c =prog.Id, Account__c=acc.Id, Primary_Dealership_Contact__c=con.Id,Name ='Program enrollment', Status__c='Eligible', Approval_Status__c ='TM Rejected');
        programEnrollList.add(progEnroll);
        Program_Enrollment__c progEnroll1 = new Program_Enrollment__c(Program__c =Prog_1.Id, Account__c=acc.Id, Primary_Dealership_Contact__c=con.Id,Name ='Program enrollment1_1', Approval_Status__c ='RSD Rejected', Status__c='Eligible', IST_Sales_Rep_Email__c='abc@abc.com',Territory_Manager__c=UserInfo.getUserId(),Regional_Sales_Director__c=UserInfo.getUserId());
        programEnrollList.add(progEnroll1);
        Program_Enrollment__c progEnroll2 = new Program_Enrollment__c(Program__c =Prog_2.Id, Account__c=acc.Id, Primary_Dealership_Contact__c=null,Name ='Program enrollment1_2', Approval_Status__c ='TM Rejected', Status__c='Eligible');
        programEnrollList.add(progEnroll2);
        insert programEnrollList;
        programEnrollList[0].Name='Program Enrollment1';
        upsert programEnrollList;
                
        
    }
    @isTest
    static void TestbeforeInsert(){
        List<sObject> aclist =[Select Id, Name, Account.IST_Account_Owner__c, Account.OwnerId from Account];
        List<sObject> programlist = [SELECT Name, Id, Program__c.Sales_Contact__c from Program__c]; 
        List<Program_Enrollment__c> ProgramEnrollList =[Select Id, Name, Program_Enrollment__c.Account__c,Program_Enrollment__c.Primary_Dealership_Contact__c,Program_Enrollment__c.IST_Sales_Rep_Email__c,Program_Enrollment__c.Sales_Contact__c,Program_Enrollment__c.Program__c,Program_Enrollment__c.Status__c, Program_Enrollment__c.Approval_Status__c,Program_Enrollment__c.Territory_Manager__c,Program_Enrollment__c.Regional_Sales_Director__c  from Program_Enrollment__c];
        system.debug('ProgramEnrollList'+ProgramEnrollList);
        List<sObject> ProgramEnrollLists = new List<sObject>();
        for (Program_Enrollment__c pe : ProgramEnrollList){
            pe.Status__c = 'Rejected';
            pe.Approval_Status__c ='RSD Approved';
            //pe.Approval_Status__c ='TM Rejected';
            ProgramEnrollLists.add(pe);
        }
        update ProgramEnrollLists;
        
        List<Program_Enrollment__c> ProgramEnrollList1 =[Select Id, Name, Program_Enrollment__c.Account__c,Program_Enrollment__c.Primary_Dealership_Contact__c,Program_Enrollment__c.IST_Sales_Rep_Email__c,Program_Enrollment__c.Sales_Contact__c,Program_Enrollment__c.Program__c,Program_Enrollment__c.Status__c, Program_Enrollment__c.Approval_Status__c  from Program_Enrollment__c];
        List<sObject> ProgramEnrollLists1 = new List<sObject>();
        for (Program_Enrollment__c pe : ProgramEnrollList1){
            pe.Status__c = 'Rejected';
            //pe.Approval_Status__c ='RSD Approved';
            pe.Approval_Status__c ='TM Rejected';
            ProgramEnrollLists1.add(pe);
        }
        update ProgramEnrollLists1;
        
        
        PopulateDefaultsOnProgramEnrollment populatedefaultsonProgramenroll = new PopulateDefaultsOnProgramEnrollment();
        populatedefaultsonProgramenroll.beforeInsert(ProgramEnrollList);
        populatedefaultsonProgramenroll.afterUpdate(ProgramEnrollList, ProgramEnrollLists);
    	populatedefaultsonProgramenroll.beforeUpdate(ProgramEnrollList, ProgramEnrollLists);
        
        System.assertEquals(3, ProgramEnrollLists.size());
        System.assertEquals(ProgramEnrollList, ProgramEnrollLists);
        System.assertNotEquals(null, ProgramEnrollList[0].Approval_Status__c);
        System.assertNotEquals(null, ProgramEnrollList[0].Status__c);
        System.assertEquals('Rejected', ProgramEnrollList1[0].Status__c);
        System.assertEquals('RSD Approved', ProgramEnrollList[0].Approval_Status__c);
        System.assertEquals('TM Rejected', ProgramEnrollList1[0].Approval_Status__c);
    
    }

}