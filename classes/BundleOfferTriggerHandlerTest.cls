/**
 * Test class for BundleOfferTriggerHandler
 * @author Pankaj Kumar
 * @group Vehicle Intelligence 
 */
@isTest
public class BundleOfferTriggerHandlerTest {
    
    public final static String TEST_EMAIL1 = 'test@gmail.com.test';
    public final static String TEST_EMAIL2 = 'test@yahoo.com.test';
    
    @testSetup static void makeData() {
		List<Account> accInsertList = new List<Account>();
        
        Account acc1 = TestUtility.createAccount();
        accInsertList.add(acc1);
        
        Account acc2 = TestUtility.createAccount();
        accInsertList.add(acc2);
        
        insert accInsertList;
        
        List<Contact> conInsertList = new List<Contact>();
        
        Contact contact1 = TestUtility.createContact(accInsertList[0]);
        contact1.Email = TEST_EMAIL1;
        conInsertList.add(contact1);
        
		Contact contact2 = TestUtility.createContact(accInsertList[1]);
        contact2.Email = TEST_EMAIL2;
        conInsertList.add(contact2);
        
        insert conInsertList;

        acc1.Primary_Contact__c = conInsertList[0].Id;
        update acc1;
        
        acc2.Primary_Contact__c = conInsertList[1].Id;
        update acc2;
    }
    
    @isTest
    static void triggerTest() {
        List<Account> accList = [ SELECT Id FROM Account LIMIT 2 ];
        
        Test.startTest();
        	Bundled_Offer__c bundledOffer = TestUtility.createBundleOffer(accList[0].Id);
        	insert bundledOffer;
        
        	bundledOffer.Dealer__c = accList[1].Id;
        	update bundledOffer;
        Test.stopTest();
        
        bundledOffer = [SELECT Seller_Email_Address__c FROM Bundled_Offer__c WHERE Id = :bundledOffer.Id LIMIT 1];
        System.assertEquals( bundledOffer.Seller_Email_Address__c, TEST_EMAIL2, 'Seller Email Address on Bundled Offer should be equal to email of Primary Contact.' );
    }
}