/**
 * @description Unit tests for DataUpdateAutomation.
 * 
 * @author Manmeet Vaseer
 * @date 06/28/2021
 */
@isTest
public class DataUpdateAutomationTest {

    @isTest
    public static void testTitleDatesWithTitleProfile(){
        Test.startTest();
        
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Titles'];
        User newTitlesUser = TestUtility.createUser(p.Id);
        
        String acctUniqueName = 'Test DataUpdateAutomationTestTest';
        Account newAcct = TestUtility.createAccount(acctUniqueName);        
        Contact newContact = TestUtility.createContact(newAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Status = 'New';
        
        SObject[] newObjs = new SObject[] {newTitlesUser, newAcct, newContact, newVehicle, newAuction, newTitleCase};
        insert newObjs;
        
        /*Customer_Inquiry__c newCI = TestUtility.createCustomerInquiry(newTitleCase, newAcct);
        newCI.Ops_Case__c = newTitleCase.Id;
        insert newCI;*/

        System.runAs(newTitlesUser) {
            Case updatedCase = [SELECT Status, Update_Status__c, Title_Received_Date__c, Title_Sent_Date__c  FROM CASE WHERE Id = :newTitleCase.Id];
            System.assertEquals(null, updatedCase.Title_Received_Date__c, 'Title_Received_Date__c should be null.');            
            System.assertEquals(null, updatedCase.Title_Sent_Date__c, 'Title_Sent_Date__c should be null.');                        
            
            /*
             * When a user changes the Update_Status__c field then Status field should be set 
             * automatically with the Update_Status__c value.
             */
            updatedCase.Update_Status__c = 'Received';
            update updatedCase;
            updatedCase = [SELECT Status, Update_Status__c, Title_Received_Date__c, Title_Sent_Date__c FROM CASE WHERE Id = :newTitleCase.Id];
            System.assertEquals('Received', updatedCase.Status, 'Status should be Received.');
            System.assertEquals(null, updatedCase.Update_Status__c, 'Update_Status__c should be null.');            
            System.assertNotEquals(null, updatedCase.Title_Received_Date__c, 'Title_Received_Date__c should not be null.');                        
            System.assertEquals(null, updatedCase.Title_Sent_Date__c, 'Title_Sent_Date__c should be null.');                                    
            TitleStatusTransitionTriggerHandler.reset();
            
            updatedCase.Update_Status__c = 'Working';
            update updatedCase;
            updatedCase = [SELECT Status, Update_Status__c, Title_Received_Date__c, Title_Sent_Date__c, OwnerId FROM CASE WHERE Id = :newTitleCase.Id];
            System.assertEquals('Working', updatedCase.Status, 'Status should be Working.');
            System.assertEquals(UserInfo.getUserId(), updatedCase.OwnerId, 'Incorrect Owner Id.');
            TitleStatusTransitionTriggerHandler.reset();            
            
            /*Customer_Inquiry__c updatedCI = [SELECT Id, Call_Type__c, Status__c FROM Customer_Inquiry__c WHERE Id = :newCI.Id];
            updatedCI.Call_Bucket__c = 'Titles';
            updatedCI.Call_Type__c = 'Buyer Title Status';
            updatedCI.Status__c = 'Working';
			update updatedCI;*/

            updatedCase.Update_Status__c = 'Sent';
            update updatedCase;
            updatedCase = [SELECT Status, Update_Status__c, Title_Received_Date__c, Title_Sent_Date__c FROM CASE WHERE Id = :newTitleCase.Id];
            System.assertEquals('Sent', updatedCase.Status, 'Status should be Sent.');
            System.assertEquals(null, updatedCase.Update_Status__c, 'Update_Status__c should be null.');            
            System.assertNotEquals(null, updatedCase.Title_Received_Date__c, 'Title_Received_Date__c should not be null.');                        
            System.assertNotEquals(null, updatedCase.Title_Sent_Date__c, 'Title_Sent_Date__c should not be null.');                                    
            TitleStatusTransitionTriggerHandler.reset();            
            
            //updatedCI = [SELECT Id, Call_Type__c, Status__c FROM Customer_Inquiry__c WHERE Id = :newCI.Id];
            //System.assertEquals('AM Follow Up', updatedCI.Status__c, 'There should be one Customer Inquiry record.');            
        }
        
        Test.stopTest();        
    }
    
    @isTest
    public static void testTitleDates()	{
        Test.startTest();
        
        String acctUniqueName = 'Test DataUpdateAutomationTestTest';
        Account newAcct = TestUtility.createAccount(acctUniqueName);        
        Contact newContact = TestUtility.createContact(newAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Status = 'New';
        
        SObject[] newObjs = new SObject[] {newAcct, newContact, newVehicle, newAuction, newTitleCase};
        insert newObjs;
        
        Case updatedCase = [SELECT Status, Update_Status__c, Title_Received_Date__c, Title_Sent_Date__c  FROM CASE WHERE Id = :newTitleCase.Id];
        System.assertEquals(null, updatedCase.Title_Received_Date__c, 'Title_Received_Date__c should be null.');            
        System.assertEquals(null, updatedCase.Title_Sent_Date__c, 'Title_Sent_Date__c should be null.');                        
        
        updatedCase.Status = 'Received';
        update updatedCase;
        updatedCase = [SELECT Status, Update_Status__c, Title_Received_Date__c, Title_Sent_Date__c FROM CASE WHERE Id = :newTitleCase.Id];
        System.assertEquals('Received', updatedCase.Status, 'Status should be Received.');
        System.assertEquals(null, updatedCase.Update_Status__c, 'Update_Status__c should be null.');            
        System.assertNotEquals(null, updatedCase.Title_Received_Date__c, 'Title_Received_Date__c should not be null.');                        
        System.assertEquals(null, updatedCase.Title_Sent_Date__c, 'Title_Sent_Date__c should be null.');                                    
        TitleStatusTransitionTriggerHandler.reset();
        
        updatedCase.Status = 'Working';
        update updatedCase;
        updatedCase = [SELECT Status, Update_Status__c, Title_Received_Date__c, Title_Sent_Date__c, OwnerId FROM CASE WHERE Id = :newTitleCase.Id];
        System.assertEquals('Working', updatedCase.Status, 'Status should be Working.');
        System.assertEquals(UserInfo.getUserId(), updatedCase.OwnerId, 'Incorrect Owner Id.');
        TitleStatusTransitionTriggerHandler.reset();            
        
        updatedCase.Status = 'Sent';
        update updatedCase;
        updatedCase = [SELECT Status, Update_Status__c, Title_Received_Date__c, Title_Sent_Date__c FROM CASE WHERE Id = :newTitleCase.Id];
        System.assertEquals('Sent', updatedCase.Status, 'Status should be Sent.');
        System.assertEquals(null, updatedCase.Update_Status__c, 'Update_Status__c should be null.');            
        System.assertNotEquals(null, updatedCase.Title_Received_Date__c, 'Title_Received_Date__c should not be null.');                        
        System.assertNotEquals(null, updatedCase.Title_Sent_Date__c, 'Title_Sent_Date__c should not be null.');                                    
        TitleStatusTransitionTriggerHandler.reset();            
        
        Test.stopTest();        
    }
    
}