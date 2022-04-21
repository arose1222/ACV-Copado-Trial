@isTest
public class AccountTriggerHandlerTest {
    
    @isTest
    static void changePrimaryContact() {
        Account a = new Account(
            Name = 'Testerson Dealership'
        );
        insert a;

        Contact c = new Contact(
            LastName = 'Smith',
            FirstName = 'John',
            AccountId = a.Id
        );
        insert c;

        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Auction__c au = TestUtility.createAuction( a, c, v );
        insert au;
        Case titleCase = TestUtility.createTitleCase( au, a, c );
        titleCase.Seller_Dealership__c = a.Id;
        insert titleCase;

        Test.startTest();

            a.Primary_Contact__c = c.Id;
            update a;

        Test.stopTest();

        titleCase = [ SELECT Id, Seller_Contact__c FROM Case WHERE Id = :titleCase.Id LIMIT 1 ];
        system.assertEquals( titleCase.Seller_Contact__c, c.Id, 'The Case was expected to have the Seller Contact filled in, but it is not' );
    }
}