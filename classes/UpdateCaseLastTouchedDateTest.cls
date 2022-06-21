@isTest
public class UpdateCaseLastTouchedDateTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        List<Account> accountList = New List<Account>();
        accountList.add( TestUtility.createAccount( '456' ) );
        accountList.add( TestUtility.createAccount( '123' ) );
        insert accountList;
        List<Contact> contactList = new List<Contact>();
        contactList.add( TestUtility.createContact( accountList[0] ) );
        contactList.add( TestUtility.createContact( accountList[1] ) );
        insert contactList;
        Vehicle__c newCar = TestUtility.createVehicle();
        newCar.vin__c = '1234567890102030';
        insert newCar;
        vehicle__c newCar1 = TestUtility.createVehicle();
        newCar.vin__c = '1234567890102031';
        insert newCar1;

        Auction__c newAuction = TestUtility.createAuction( accountList[0], contactList[0], newCar );
        newAuction.Status__c = 'Active'; 
        newAuction.end_time__c = System.Now();
        newAuction.Seller_Dealership__c = accountList[1].id;
        newAuction.Floor_Price__c = 500;
        newAuction.Winning_Bid_Price__c = 450;
        insert newAuction;
    }

    @isTest
    static void set48HourNotice() {
        Auction__c testAuctRec = [ SELECT Id, buyer_dealership__c, buyer_contact__c FROM Auction__c LIMIT 1 ];
        Case titleCaseRec = TestUtility.createTitleCase( testAuctRec, new Account( Id = testAuctRec.buyer_dealership__c ), new Contact( Id = testAuctRec.buyer_contact__c ) );

        UserRole titleManagerRole = [ SELECT Id FROM UserRole WHERE DeveloperName = 'Titles_Manager' LIMIT 1];

        User testUser = TestUtility.createUser();
        testUser.UserRoleId = titleManagerRole.Id;
        insert testUser;

        System.runAs( testUser ) {
            titleCaseRec.Status = 'New';
            titleCaseRec.Send_to_ACV__c = FALSE;
            insert titleCaseRec;
            Test.setCreatedDate( titleCaseRec.Id, Datetime.now().addDays( -7 ) );

            // need to turn flag back off
            titleCaseRec.Send_to_ACV__c = FALSE;
            update titleCaseRec;

            Test.startTest();

                titleCaseRec.Status = '48 Hour Notice';
                update titleCaseRec;

            Test.stopTest();
        }

        titleCaseRec = [ SELECT Id, Last_Touched__c FROM Case WHERE Id = :titleCaseRec.Id LIMIT 1 ];
        System.assert( titleCaseRec.Last_Touched__c != null, 'The Last Touched field is not filled in' );
        System.assertEquals( Date.today().day(), titleCaseRec.Last_Touched__c.day(), 'The Last Touched field was not correctly set' );
    }

}