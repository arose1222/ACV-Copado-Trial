/**
 * @description Unit tests for TitleStatusTransitionTriggerHandler.
 * 
 * @author Manmeet Vaseer
 * @date 05/24/2021
 */
@isTest
public class TitleStatusTransitionTriggerHandlerTest {

    /**
 	 * @description Test updateTitleStatus method.
     * 
     * 
	*/
    @isTest
    static void testUpdateTitleStatus()	{
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Titles'];
        User newTitlesUser = TestUtility.createUser(p.Id);
        
        String acctUniqueName = 'Test TitleStatusTransitionTriggerHandlerTest';
        Account newAcct = TestUtility.createAccount(acctUniqueName);        
        Contact newContact = TestUtility.createContact(newAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Status = 'New';
        
        SObject[] newObjs = new SObject[] {newTitlesUser, newAcct, newContact, newVehicle, newAuction, newTitleCase};
        insert newObjs;

        System.runAs(newTitlesUser) {
            Case updatedCase = [SELECT Status, Update_Status__c FROM CASE WHERE Id = :newTitleCase.Id];
            
            /*
             * When a user changes the Update_Status__c field then Status field should be set 
             * automatically with the Update_Status__c value.
             */
            updatedCase.Update_Status__c = 'Received';
            update updatedCase;
            updatedCase = [SELECT Status, Update_Status__c FROM CASE WHERE Id = :newTitleCase.Id];
            System.assertEquals('Received', updatedCase.Status, 'Status should be Received.');
            System.assertEquals(null, updatedCase.Update_Status__c, 'Update_Status__c should be null.');            
        }
    }
    
    @isTest
    static void testUpdateTitleStatusException()	{
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Titles'];
        User newTitlesUser = TestUtility.createUser(p.Id);
        
        String acctUniqueName = 'Test TitleStatusTransitionTriggerHandlerTest';
        Account newAcct = TestUtility.createAccount(acctUniqueName);        
        Contact newContact = TestUtility.createContact(newAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Status = 'New';
        
        SObject[] newObjs = new SObject[] {newTitlesUser, newAcct, newContact, newVehicle, newAuction, newTitleCase};
        insert newObjs;

        /*
         * A user can not change the Title Status field directly.
         * Throw an error if a user try to change the Status field directly for Title Information record type.
         */
        newTitleCase.Status = 'Working';
        try {
            System.runAs(newTitlesUser) {
                update newTitleCase;
            }
            System.assert( false, 'This message indicates an error was not thrown when expected!' );
        } 
        catch(Exception e) {
            System.assert(e.getMessage().contains( 
                'You can not change the Status field value. Use Update Status field to change the Title Status' ), 
                          'The error message thrown was unexpected: ' + e.getMessage()
                         );
        }        
    }
    
}