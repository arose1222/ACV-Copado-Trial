/**
 * @description https://acvauctions.atlassian.net/browse/TDO-292
 * 
 * @author Manmeet Vaseer
 * @date 09/01/2021
 * 
 */
@isTest
public class SetTitleClerkEmailTest {
	@isTest
    static void testSellerContactEmail()	{
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Titles'];
        User newTitlesUser = TestUtility.createUser(p.Id);
        
        String acctUniqueName = 'Test TitleStatusTransitionTriggerHandlerTest';
        Account newAcct = TestUtility.createAccount(acctUniqueName);
        SObject[] newObjs = new SObject[] {newTitlesUser, newAcct};
        insert newObjs;
        
        Contact newContact = TestUtility.createContact(newAcct);
        newContact.Active__c = true;
        newContact.Email = 'seller@dealership.com';
        newContact.Title = 'Title Clerk';

        Contact newPrimaryContact = TestUtility.createContact(newAcct);
        newPrimaryContact.Active__c = true;
        newPrimaryContact.Email = 'primary@dealership.com';

        newObjs = new SObject[] {newContact, newPrimaryContact};
        insert newObjs;
        
        newAcct.Primary_Contact__c = newPrimaryContact.Id;
        update newAcct;

        // newContact.Title can not be set during insert so we have to do another update to set the Title field.
        newContact.Title = 'Title Clerk';
		update newContact;
        
        Contact aContact = [SELECT Title FROM Contact WHERE Id = :newContact.Id];
        System.assertEquals(newContact.Title, aContact.Title, 'Contact Title should be populated.');
        
        Vehicle__c newVehicle = TestUtility.createVehicle();
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
        
        newObjs = new SObject[] {newVehicle, newAuction};
        insert newObjs;

		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Seller_Dealership__c = newAcct.Id;
        newTitleCase.Status = 'New';
        
        newObjs = new SObject[] {newTitleCase};
        insert newObjs;

        Case updatedCase = [SELECT Seller_Title_Clerk_Email__c, Seller_Contact_Email__c FROM CASE WHERE Id = :newTitleCase.Id];
        System.assertEquals(newContact.Email, updatedCase.Seller_Title_Clerk_Email__c, 'Seller_Title_Clerk_Email__c should be populated by the trigger.');
        //System.assertEquals(newPrimaryContact.Email, updatedCase.Seller_Contact_Email__c, 'Seller_Contact_Email__c should be populated by the trigger.');
    }

}