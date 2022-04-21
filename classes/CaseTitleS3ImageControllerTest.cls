/**
 * @description A controller used by LWC to fetch S3 Title Image History from the Field History object.
 * 
 * @author Manmeet Vaseer
 * @date 06/03/2021
 * 
 *
 */
@isTest
public class CaseTitleS3ImageControllerTest {

    @isTest
    static void testGetS3ImageLocationHistory()	{
        /*
         * Setup Data
         */
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Titles'];
        User newTitlesUser = TestUtility.createUser(p.Id);
        
        String acctUniqueName = 'Test CaseTitleS3ImageControllerTest';
        Account newAcct = TestUtility.createAccount(acctUniqueName);        
        Contact newContact = TestUtility.createContact(newAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Status = 'New';
        newTitleCase.Image_Location__c = 's3 image 1';
        
        SObject[] newObjs = new SObject[] {newTitlesUser, newAcct, newContact, newVehicle, newAuction, newTitleCase};
        insert newObjs;
        
        /*
         * There should be only one record in the Field History object, which we just inserted.
         */
        List<String> s3ImageHist = CaseTitleS3ImageController.getS3ImageLocationHistory(newTitleCase.Id, false);
        System.assertEquals(1, s3ImageHist.size(), 'There should be only one record in the field history.');
        
        CaseTitleS3ImageController.Payload pl = (CaseTitleS3ImageController.Payload) System.JSON.deserialize(s3ImageHist[0], CaseTitleS3ImageController.Payload.class);        
        System.assertEquals('s3 image 1', pl.s3URL, 'Payload is (s3URL): ' + s3ImageHist[0]);
        System.assertEquals('On New status', pl.description, 'Payload is: (description)' + s3ImageHist[0]);                
        
        RecordCaseFieldHistory.reset();
        System.runAs(newTitlesUser) {
            /*
             * The following should create 2 more records in the Field History. One for 'Received' and another for 'Working' Status field.
             */
            Case theCase = [SELECT Status, Update_Status__c, Image_Location__c FROM Case WHERE Id = :newTitleCase.Id];
            theCase.Update_Status__c = 'Received';
            update theCase;
            
            TitleStatusTransitionTriggerHandler.reset();
            
            theCase = [SELECT Status, Update_Status__c, Image_Location__c FROM Case WHERE Id = :newTitleCase.Id];
            theCase.Update_Status__c = 'Working';
            update theCase;
            
            TitleStatusTransitionTriggerHandler.reset();
        }

        /*
         * This should still only return one record from Field History object as we have not yet updated the Image_Location__c field.
         * And, getS3ImageLocationHistory() only returns records related to Image_Location__c from the Field History object.
         */
        s3ImageHist = CaseTitleS3ImageController.getS3ImageLocationHistory(newTitleCase.Id, false);
        System.assertEquals(1, s3ImageHist.size(), 'There should still be only one record in the field history.');

        RecordCaseFieldHistory.reset();
        System.runAs(newTitlesUser) {
            /*
             * Updated the Status along with Image Location fields.
             * This whould create 2 records in the Field History. One for 'Sent' Status field and another for Image_Location__c field.
             */
            Case theCase = [SELECT Status, Update_Status__c, Image_Location__c FROM Case WHERE Id = :newTitleCase.Id];
            theCase.Update_Status__c = 'Sent';
        	theCase.Image_Location__c = 's3 image 2';
            update theCase;
        }
        
        s3ImageHist = CaseTitleS3ImageController.getS3ImageLocationHistory(newTitleCase.Id, false);
        System.assertEquals(2, s3ImageHist.size(), 'There should 2 records in the field history.');
        
        pl = (CaseTitleS3ImageController.Payload) System.JSON.deserialize(s3ImageHist[0], CaseTitleS3ImageController.Payload.class);        
        System.assertEquals('s3 image 2', pl.s3URL, 'Payload is (s3URL): ' + s3ImageHist[0]);
        System.assertEquals('On Sent status', pl.description, 'Payload is: (description)' + s3ImageHist[0]);
        
        pl = (CaseTitleS3ImageController.Payload) System.JSON.deserialize(s3ImageHist[1], CaseTitleS3ImageController.Payload.class);        
        System.assertEquals('s3 image 1', pl.s3URL, 'Payload is (s3URL): ' + s3ImageHist[1]);
        System.assertEquals('On New status', pl.description, 'Payload is: (description)' + s3ImageHist[1]);        
    }
    
    @isTest
    static void testNoS3ImageLocationHistoryForQC()	{
        /*
         * Setup Data
         */
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Titles'];
        User newTitlesUser = TestUtility.createUser(p.Id);
        
        String acctUniqueName = 'Test CaseTitleS3ImageControllerTest';
        Account newAcct = TestUtility.createAccount(acctUniqueName);        
        Contact newContact = TestUtility.createContact(newAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Status = 'New';
        newTitleCase.Image_Location__c = 's3 image 1';
        
        SObject[] newObjs = new SObject[] {newTitlesUser, newAcct, newContact, newVehicle, newAuction, newTitleCase};
        insert newObjs;
        
        /*
         * There should be only one record in the Field History object, which we just inserted.
         */
        List<String> s3ImageHist = CaseTitleS3ImageController.getS3ImageLocationHistory(newTitleCase.Id, false);
        System.assertEquals(1, s3ImageHist.size(), 'There should be only one record in the field history.');
        
        CaseTitleS3ImageController.Payload pl = (CaseTitleS3ImageController.Payload) System.JSON.deserialize(s3ImageHist[0], CaseTitleS3ImageController.Payload.class);        
        System.assertEquals('s3 image 1', pl.s3URL, 'Payload is (s3URL): ' + s3ImageHist[0]);
        System.assertEquals('On New status', pl.description, 'Payload is: (description)' + s3ImageHist[0]);                
        
        RecordCaseFieldHistory.reset();
        System.runAs(newTitlesUser) {
            /*
             * The following should create 2 more records in the Field History. One for 'Received' and another for 'Working' Status field.
             */
            Case theCase = [SELECT Status, Update_Status__c, Image_Location__c FROM Case WHERE Id = :newTitleCase.Id];
            theCase.Update_Status__c = 'Received';
            update theCase;
            
            TitleStatusTransitionTriggerHandler.reset();
            
            theCase = [SELECT Status, Update_Status__c, Image_Location__c FROM Case WHERE Id = :newTitleCase.Id];
            theCase.Update_Status__c = 'Working';
            update theCase;
            
            TitleStatusTransitionTriggerHandler.reset();
        }

        /*
         * This should not return any record from Field History object as we don't want to display field history on LWC configured on QC object.
         */
        s3ImageHist = CaseTitleS3ImageController.getS3ImageLocationHistory(newTitleCase.Id, true);
        System.assertEquals(0, s3ImageHist.size(), 'There should no field history record fetched for the LWC on QC object.');
    }
    
}