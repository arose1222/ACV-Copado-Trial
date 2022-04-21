/**
 * @description https://acvauctions.atlassian.net/browse/TDO-292
 * 
 * @author Manmeet Vaseer
 * @date 09/03/2021
 * 
 */
@isTest
public class SetTitleContactEmailTest {
	@isTest
    static void testSellerContactEmailInsert()	{
        Test.startTest();
        String acctUniqueName = 'Test TitleStatusTransitionTriggerHandlerTest';
        Account newAcct = TestUtility.createAccount(acctUniqueName);
        SObject[] newObjs = new SObject[] {newAcct};
        insert newObjs;
        
        Contact newContact = TestUtility.createContact(newAcct);
        newContact.Active__c = true;
        newContact.Email = 'seller@dealership.com';

        Contact newPrimaryContact = TestUtility.createContact(newAcct);
        newPrimaryContact.Active__c = true;
        newPrimaryContact.Email = 'primary@dealership.com';

        newObjs = new SObject[] {newContact, newPrimaryContact};
        insert newObjs;
        
        Affiliation__c newAffiliation1 = new Affiliation__c(Account__c=newAcct.Id, Contact__c=newContact.Id, Primary_Contact__c=false);
        Affiliation__c newAffiliation2 = new Affiliation__c(Account__c=newAcct.Id, Contact__c=newPrimaryContact.Id, Primary_Contact__c=true);
        newObjs = new SObject[] {newAffiliation1, newAffiliation2};
        insert newObjs;
                
        Vehicle__c newVehicle = TestUtility.createVehicle();
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
        
        newObjs = new SObject[] {newVehicle, newAuction};
        insert newObjs;

		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Seller_Dealership__c = newAcct.Id;
        newTitleCase.Status = 'New';
        
        newObjs = new SObject[] {newTitleCase};
        insert newObjs;
        Test.stopTest();

        Case updatedCase = [SELECT Seller_Title_Clerk_Email__c, Seller_Contact_Email__c FROM CASE WHERE Id = :newTitleCase.Id];
        System.assertEquals(newPrimaryContact.Email, updatedCase.Seller_Contact_Email__c, 'Seller_Contact_Email__c should be populated by the trigger.');
    }

	@isTest
    static void testSellerContactEmailUpdate()	{
        Test.startTest();
        String acctUniqueName = 'Test TitleStatusTransitionTriggerHandlerTest';
        Account newAcct = TestUtility.createAccount(acctUniqueName);
        SObject[] newObjs = new SObject[] {newAcct};
        insert newObjs;
        
        Contact newContact = TestUtility.createContact(newAcct);
        newContact.Active__c = true;
        newContact.Email = 'seller@dealership.com';

        Contact newPrimaryContact = TestUtility.createContact(newAcct);
        newPrimaryContact.Active__c = true;
        newPrimaryContact.Email = 'primary@dealership.com';

        newObjs = new SObject[] {newContact, newPrimaryContact};
        insert newObjs;
        
        Affiliation__c newAffiliation1 = new Affiliation__c(Account__c=newAcct.Id, Contact__c=newContact.Id, Primary_Contact__c=false);
        Affiliation__c newAffiliation2 = new Affiliation__c(Account__c=newAcct.Id, Contact__c=newPrimaryContact.Id, Primary_Contact__c=true);
        newObjs = new SObject[] {newAffiliation1, newAffiliation2};
        insert newObjs;
                
        Vehicle__c newVehicle = TestUtility.createVehicle();
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
        
        newObjs = new SObject[] {newVehicle, newAuction};
        insert newObjs;

		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Seller_Dealership__c = newAcct.Id;
        newTitleCase.Status = 'New';
        
        newObjs = new SObject[] {newTitleCase};
        insert newObjs;
        Test.stopTest();

        Case updatedCase = [SELECT Seller_Title_Clerk_Email__c, Seller_Contact_Email__c FROM CASE WHERE Id = :newTitleCase.Id];
        System.assertEquals(newPrimaryContact.Email, updatedCase.Seller_Contact_Email__c, 'Seller_Contact_Email__c should be populated by the trigger.');
        
        // Now Update the primary contact
        newPrimaryContact.Email = 'primary2@dealership.com';
        update newPrimaryContact;
        update newTitleCase; // to invoke trigger

        updatedCase = [SELECT Seller_Title_Clerk_Email__c, Seller_Contact_Email__c FROM CASE WHERE Id = :newTitleCase.Id];
        System.assertEquals(newPrimaryContact.Email, updatedCase.Seller_Contact_Email__c, 'Seller_Contact_Email__c should be updated by the trigger.');

        // Now remove the primary contact from the Account/Affiliation
        newAffiliation1.Primary_Contact__c = true;
        newAffiliation2.Primary_Contact__c = false;
        newObjs = new SObject[] {newAffiliation1, newAffiliation2, newTitleCase};
        update newObjs;

        updatedCase = [SELECT Seller_Title_Clerk_Email__c, Seller_Contact_Email__c FROM CASE WHERE Id = :newTitleCase.Id];
        System.assertEquals(newContact.Email, updatedCase.Seller_Contact_Email__c, 'Seller_Contact_Email__c should be updated by the trigger.');        
  }    
}