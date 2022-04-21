/******************************************
*Author - Avinash Sharma(Saisystems) 
*Description - Test Class for DealerProgramApplicationController 
*Date - 05 APR 2021
*******************************************/
@isTest
public class DealerProgramApplicationControllerTest {
   @TestSetup
    static void makeData(){
        Account acc=TestUtility.createAccount();
        insert acc;
        
        Contact con =TestUtility.createContact(acc); 
        insert con;
        Program__c prog = new Program__c(Name='Program1', Active__c =true, Sales_Contact__c='IST_Account_Owner__c');
        insert prog;
        //Program_Rule__c progrule = new Program_Rule__c(Name ='program rule1', Active__c =true, Criteria__c='This is criteria',Field_Type__c='Date');
        //insert progrule;
        
        Program_Rule__c progrule = new Program_Rule__c();
        progrule.Name ='program rule1';
        progrule.Active__c =true;
        progrule.Field_To_Compare_1__c='field1';
        progrule.Field_To_Compare_2__c ='field2';
        progrule.Field_Type__c= 'DATE';
        progrule.Operator__c = '!=';
        insert progrule;
        
        Rule_Assignment__c ruleassign = new Rule_Assignment__c(Program__c=prog.Id, Program_Rule__c= progrule.Id);
        insert ruleassign;
        
        Program_Enrollment__c programEnroll = new Program_Enrollment__c();
        programEnroll.Account__c = acc.Id;
       // programEnroll.No_Of_Days_Since_Invitation_Sent__c =0;
        programEnroll.Name='Test Program Enroll';
        programEnroll.Program__c=prog.Id;
        programEnroll.Invitation_Sent_Date__c=System.today()-15;
        programEnroll.Primary_Dealership_Contact__c = con.Id;
        programEnroll.IST_Sales_Rep_Email__c = con.Email;
        programEnroll.Sales_Contact__c =  UserInfo.getUserId();
        programEnroll.Has_Customer_Applied__c = true;
        insert programEnroll;
        System.debug('program enrollment'+programEnroll);
        
        ContentVersion cv = new ContentVersion();
        cv.Title ='Test Document';
        cv.PathOnClient='TestDocument.pdf';
        cv.VersionData=Blob.valueof('Test Content');
        cv.IsMajorVersion= true;
        insert cv;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
		cdl.LinkedEntityId = acc.Id;
		cdl.ContentDocumentId = conDocId;
		cdl.shareType = 'V';
		Insert cdl;
	}
    
    @isTest
	static void testgetProgramAndContactDetails() {
    	ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Account ac =[SELECT Id, Name FROM Account LIMIT 1];
        List<Contact> co =[SELECT Id, LastName FROM Contact LIMIT 1];
        List<Program__c> pr =[SELECT Id, Name FROM Program__c LIMIT 1];
        List<Program_Enrollment__c> programEnrollList=[Select Id, Name, No_Of_Days_Since_Invitation_Sent__c, Primary_Dealership_Contact__c,
                                                       Primary_Dealership_Contact__r.Email from Program_Enrollment__c LIMIT 1];
        DealerProgramApplicationController.updateEnrolmentRecord(programEnrollList[0].Id);
        
        List<ContentVersion> contentversionList = DealerProgramApplicationController.getContentDetails(ac.Id);
        
        DealerProgramApplicationController.submitApplication(programEnrollList[0].Id);
        
        DealerProgramApplicationController.ProgramAndContactDetails prandcondetail = DealerProgramApplicationController.getProgramAndContactDetails(pr[0].Id, ac.Id, co[0].Id, programEnrollList[0].Id);
        
        System.assertNotEquals(null, cv.Id);
        System.assertNotEquals(null, prandcondetail);
        system.assertNotEquals(NULL, prandcondetail.programRecord);
        system.assertNotEquals(NULL, prandcondetail.contactRecord);
        system.assertNotEquals(NULL, prandcondetail.ProgramRuleAssignmentAndAcceptanceList);
        system.assertNotEquals(NULL, prandcondetail.contentVersionList);
        System.assertNotEquals(null, contentversionList);
        
    }
    

}