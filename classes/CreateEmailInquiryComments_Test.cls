@isTest
public class CreateEmailInquiryComments_Test {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account actObj = TestUtility.createAccount();
        insert actObj;
        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;
        Vehicle__c vehicleObj = TestUtility.createVehicle();
        insert vehicleObj;
        Auction__c auctionObj = TestUtility.createAuction(actObj, contactObj, vehicleObj);
        auctionObj.Payment_Status__c = 'Pending';
        insert auctionObj;

        List<Case> caseList = new List<Case>();
        caseList.add(TestUtility.createTitleCase(auctionObj, actObj, contactObj));
        caseList.add(TestUtility.createCase(auctionObj,vehicleObj,actObj,contactObj));
        caseList.add(TestUtility.createSupportCase(actObj));
        insert caseList;

        List<Customer_Inquiry__c> inquiryList = new List<Customer_Inquiry__c>();
        Customer_Inquiry__c titleCI = TestUtility.createCustomerInquiry(caseList[2],actObj);
        titleCI.Ops_Case__c = caseList[0].id;
        inquiryList.add(titleCI);
        Customer_Inquiry__c arbCI = TestUtility.createCustomerInquiry(caseList[2],actObj);
        arbCI.Ops_Case__c = caseList[1].id;
        inquiryList.add(arbCI);
        insert inquiryList;

    } 
    
    @isTest
    public static void emailBodyWithExistingValue(){
        Case cs = [SELECT Id FROM Case WHERE Subject = 'Title Testing' LIMIT 1];
        EmailMessage testEmailMsg = new EmailMessage(ToAddress = 'Test@test.com',ParentId = cs.Id,status = '3',TextBody = 'Testbody  --------------- Original Message --------------- Text'); 
        insert testEmailMsg;
       
        Test.startTest();
        update testEmailMsg;
        Test.stopTest();  

        Inquiry_Comment__c ic = [select id,Inquiry_Notes__c,Ops_Case__c from Inquiry_Comment__c where Ops_Case__c =:cs.Id];
        System.assertEquals(ic.Inquiry_Notes__c, 'Testbody', 'Inquiry comment record created with the notes that was added new excludes existing note');
    }

    @isTest
    public static void emailBodyWithoutExistingValue(){
        Case cse = [SELECT Id,RecordTypeId FROM Case WHERE Subject = 'Title Testing' LIMIT 1];
        EmailMessage testEmailMsg = new EmailMessage(ToAddress = 'Test@test.com',ParentId = cse.Id,status = '3',TextBody = 'Testbody');
        insert testEmailMsg;
        
        Test.startTest();
        update testEmailMsg;
        Test.stopTest();
        
        Inquiry_Comment__c icRec = [select id,Inquiry_Notes__c,Ops_Case__c from Inquiry_Comment__c where Ops_Case__c =:cse.Id];
        System.assertEquals(icRec.Inquiry_Notes__c, 'Testbody', 'Inquiry comment record created with the newly added text');
        System.assertEquals(icRec.Ops_Case__c,cse.id);        
    }

    @isTest
    public static void emailCreatedDoesNotCreateCommentOnClosedInquiry(){
        Case cse = [SELECT Id,RecordTypeId FROM Case WHERE Subject = 'Title Testing' LIMIT 1];
        List<Customer_Inquiry__c> ciList = [SELECT Id, Status__c FROM Customer_Inquiry__c];
        for (Customer_Inquiry__c ci : ciList) {
            ci.Status__c = 'Closed';
        }
        update ciList;

        EmailMessage testEmailMsg = new EmailMessage(ToAddress = 'Test@test.com',ParentId = cse.Id,status = '3',TextBody = 'Testbody');
        insert testEmailMsg;
        
        Test.startTest();
        update testEmailMsg;
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Count() FROM Inquiry_Comment__c], 'Inquiry comments should only be logged on open Customer Inquries');     
    }
    
    @isTest
    public static void testForArbCase(){
        Case cse = [SELECT Id,RecordTypeId FROM Case WHERE Subject = 'Testing' LIMIT 1];
        EmailMessage testEmailMsg = new EmailMessage(
            ToAddress = 'Test@test.com',
            ParentId = cse.Id,
            status = '3',
            TextBody = 'Testbody'
        );
        insert testEmailMsg;

        Test.startTest();
        update testEmailMsg;
        Test.stopTest();

        List<Inquiry_Comment__c> icRecs = [select id,Inquiry_Notes__c,Ops_Case__c from Inquiry_Comment__c where Ops_Case__c =:cse.Id];
        System.assertEquals(icRecs.size(),0,'Inquiry comment record will not get created for arb case');        
    }
    
    @isTest
    public static void testMultipleEmails(){
        List<EmailMessage> emailMsgs = new List<EmailMessage>();

        for (Case c : [SELECT Id FROM Case]) {
            emailMsgs.add(new EmailMessage(ToAddress = 'Test@test.com', ParentId = c.Id, Status = '3', TextBody = 'Testbody'));
        }
        insert emailMsgs;

        Test.startTest();
        update emailMsgs;
        Test.stopTest();

        List<Inquiry_Comment__c> icRec = [SELECT Id FROM Inquiry_Comment__c];
        System.assertEquals(icRec.size(),1,'Inquiry comment record will be created for only one case of title information record type');        
    }
}