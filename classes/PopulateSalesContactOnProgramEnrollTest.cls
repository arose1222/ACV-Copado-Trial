/******************************************
*Author - Avinash Sharma(Saisystems) 
*Description - Test Class for PopulateSalesContactOnProgramEnrollments 
*Date - 5 APR 2021
*******************************************/
@isTest
public class PopulateSalesContactOnProgramEnrollTest {
    @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account acc=TestUtility.createAccount();
        acc.IST_Account_Owner__c =UserInfo.getUserId();
        insert acc;
        
        Contact con = TestUtility.createContact(acc);
        insert con;
        
        List<Program_Rule__c> progRuleList=new List<Program_Rule__c>();
        Program_Rule__c programRule = new Program_Rule__c();
        programRule.Active__c =true;
        programRule.Field_To_Compare_1__c='Account.Purchases_All_Time__c';
        programRule.Operator__c = '>';
        programRule.Field_To_Compare_2__c ='Account.All_Time_Sales_Gross__c';
        programRule.Field_Type__c= 'INTEGER';
        programRule.Eligibility__c=true;
        progRuleList.add(programRule);
        
         Program_Rule__c programRule1 = new Program_Rule__c();
        programRule1.Active__c =true;
        programRule1.Field_To_Compare_1__c='Account.Active__c';
        programRule1.Operator__c = '=';
        programRule1.Field_To_Compare_2__c ='true';
        programRule1.Is_RHS_Static_Value__c=true;
        programRule1.Field_Type__c= 'BOOLEAN';
        programRule1.Eligibility__c=true;
        progRuleList.add(programRule1);
        insert progRuleList;
        
        List<Program__c> programList = New List<Program__c>();
        Program__c prog = new Program__c();
        prog.Name ='Program';
        Prog.Active__c =true;
        Prog.Sales_Contact__c='IST_Account_Owner__c';
        prog.Program_Rule_Logic__c='1 AND 2';
        Prog.Status__c ='Eligible';
        programList.add(Prog);
        
        Program__c Prog_1 = new Program__c();
        Prog_1.Name ='Program';
        Prog_1.Active__c =true;
        Prog_1.Sales_Contact__c='IST_Account_Owner__c';
        Prog_1.Program_Rule_Logic__c='1 AND 2';
        Prog_1.Status__c ='Eligible';
        programList.add(Prog_1);
        insert programList;
        
        //Prog.Sales_Contact__c='OwnerId';
        //update prog;
        
        
        
        List<Rule_Assignment__c> ruleAssignList = New List<Rule_Assignment__c>();
        Rule_Assignment__c ruleAssign = new Rule_Assignment__c();
        ruleAssign.Order__c = 1;
        ruleAssign.Program__c = prog.Id;
        ruleAssign.Program_Rule__c = programRule.Id;
        ruleAssignList.add(ruleAssign);
        
        Rule_Assignment__c ruleAssign1 = new Rule_Assignment__c();
        ruleAssign1.Order__c = 2;
        ruleAssign1.Program__c = prog.Id;
        ruleAssign1.Program_Rule__c = programRule1.Id;
        ruleAssignList.add(ruleAssign1);
        insert ruleAssignList;
        
        List<Program_Enrollment__c> programEnrollList = new List<Program_Enrollment__c>();        
        Program_Enrollment__c progEnroll = new Program_Enrollment__c(Program__c =prog.Id, Account__c=acc.Id, Primary_Dealership_Contact__c=con.Id,Name ='Program enrollment', Status__c='Rejected', Approval_Status__c ='TM Rejected');
        programEnrollList.add(progEnroll);
        Program_Enrollment__c progEnroll1 = new Program_Enrollment__c(Program__c =Prog_1.Id, Account__c=acc.Id, Primary_Dealership_Contact__c=con.Id,Name ='Program enrollment1', Status__c='Rejected', Approval_Status__c ='TM Rejected');
        programEnrollList.add(progEnroll1);
        insert programEnrollList;
        System.assertNotEquals(null, acc.IST_Account_Owner__c);
        System.assertEquals(UserInfo.getUserId(), acc.IST_Account_Owner__c);
        
    }
    @isTest
    static void TestafterUpdate(){
    	List<Program__c> programlist = [SELECT Name, Id, Program__c.Sales_Contact__c,Program__c.Program_Rule_Logic__c from Program__c];
        List<Program_Enrollment__c> programEnrollmentList =[SELECT Id, Name from Program_Enrollment__c];
        List<sObject> programlists = new List<sObject>();
        for (Program__c pe : programlist){
            pe.Name = 'Program1';
            pe.Sales_Contact__c='IST_Account_Owner__c';
            programlists.add(pe);
        }
        update programlists;
        PopulateSalesContactOnProgramEnrollments populatesalescontactonproramenroll = new PopulateSalesContactOnProgramEnrollments();
        populatesalescontactonproramenroll.afterUpdate(programlist,programlists);
        PopulateSalesContactOnProgramEnrollments.populateProgramEligibilityCriteria(programlists);
        System.assertEquals(programlist, programlists);        
		System.assertNotEquals(null, programlist[0].Sales_Contact__c);
        System.assertNotEquals(null, programlist);
        System.assertNotEquals(null, programlists);
	
    }
}