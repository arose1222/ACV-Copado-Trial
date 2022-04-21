@isTest
public class AssignedCaseToQueueTest {
    
    @TestSetup
    static void makeData(){
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
    static void setQueueOwnership() {
        Auction__c testAuctRec = [ SELECT Id, buyer_dealership__c, buyer_contact__c FROM Auction__c LIMIT 1 ];
        Case titleCaseRec = TestUtility.createTitleCase( testAuctRec, new Account( Id = testAuctRec.buyer_dealership__c ), new Contact( Id = testAuctRec.buyer_contact__c ) );

        titleCaseRec.Status = 'New';
        insert titleCaseRec;

        
        User testUser = TestUtility.createSystemAdministratorUser();
        

        Group queueGroup;

        system.runAs( testUser ) {
            queueGroup = new Group(
                Type = 'Queue', Name = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Title Resolution Queue Name' LIMIT 1 ].Value__c
            );
            insert queueGroup;
            insert new QueuesObject(
                QueueId = queueGroup.Id, sObjectType = 'Case'
            );
        }

        Test.startTest();

            titleCaseRec.OwnerId = queueGroup.Id;
            update titleCaseRec;

        Test.stopTest();

        titleCaseRec = [ SELECT Id, Date_Time_Assigned_to_Queue__c FROM Case WHERE Id = :titleCaseRec.Id LIMIT 1 ];
        System.assertEquals( Datetime.now().day(), titleCaseRec.Date_Time_Assigned_to_Queue__c.day(), 'The Status Last Updated Field was not correctly set' );
    }
}