@isTest
public class DateStampCaseStatusChangeTest {
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
    static void setReceived() {
        Auction__c testAuctRec = [ SELECT Id, buyer_dealership__c, buyer_contact__c FROM Auction__c LIMIT 1 ];
        Case titleCaseRec = TestUtility.createTitleCase( testAuctRec, new Account( Id = testAuctRec.buyer_dealership__c ), new Contact( Id = testAuctRec.buyer_contact__c ) );

        User testUser = TestUtility.createUser();
        insert testUser;

        titleCaseRec.Status = 'New';
        insert titleCaseRec;
        Test.setCreatedDate( titleCaseRec.Id, Datetime.now().addDays( -7 ) );

        Test.startTest();

        System.runAs( testUser ) {
            titleCaseRec.Status = 'Received';
            update titleCaseRec;
        }

        Test.stopTest();

        titleCaseRec = [ SELECT Id, Status_Last_Updated__c, Title_Clerked_Date__c FROM Case WHERE Id = :titleCaseRec.Id LIMIT 1 ];
        System.assertEquals( Date.today(), titleCaseRec.Status_Last_Updated__c, 'The Status Last Updated Field was not correctly set' );
    }
    
    @isTest
    static void setWorking() {
        Auction__c testAuctRec = [ SELECT Id, buyer_dealership__c, buyer_contact__c FROM Auction__c LIMIT 1 ];
        Case titleCaseRec = TestUtility.createTitleCase( testAuctRec, new Account( Id = testAuctRec.buyer_dealership__c ), new Contact( Id = testAuctRec.buyer_contact__c ) );

        User testUser = TestUtility.createUser();
        insert testUser;

        titleCaseRec.Status = 'New';
        insert titleCaseRec;
        Test.setCreatedDate( titleCaseRec.Id, Datetime.now().addDays( -7 ) );

        Test.startTest();

        System.runAs( testUser ) {
            titleCaseRec.Status = 'Working';
            update titleCaseRec;
        }

        Test.stopTest();

        titleCaseRec = [ SELECT Id, Status_Last_Updated__c, Title_Clerked_Date__c FROM Case WHERE Id = :titleCaseRec.Id LIMIT 1 ];
        System.assertEquals( Date.today(), titleCaseRec.Status_Last_Updated__c, 'The Status Last Updated Field was not correctly set' );
        System.assertEquals( Date.today(), titleCaseRec.Title_Clerked_Date__c, 'The Title Clerk Date was not correctly set' );
    }

    @isTest
    static void setProblem() {
        Auction__c testAuctRec = [ SELECT Id, buyer_dealership__c, buyer_contact__c FROM Auction__c LIMIT 1 ];
        Case titleCaseRec = TestUtility.createTitleCase( testAuctRec, new Account( Id = testAuctRec.buyer_dealership__c ), new Contact( Id = testAuctRec.buyer_contact__c ) );

        User testUser = TestUtility.createSystemAdministratorUser();
        insert testUser;

        titleCaseRec.Status = 'New';
        insert titleCaseRec;
        Test.setCreatedDate( titleCaseRec.Id, Datetime.now().addDays( -7 ) );

        Test.startTest();

        System.runAs( testUser ) {
            titleCaseRec.Status = 'Problem';
            titleCaseRec.Title_Problem_Subset__c = 'O';
            titleCaseRec.Incorrect_Vehicle_Information_on_Title__c = TRUE;
            update titleCaseRec;
        }

        Test.stopTest();

        titleCaseRec = [ SELECT Id, Status_Last_Updated__c, Was_Problem__c FROM Case WHERE Id = :titleCaseRec.Id LIMIT 1 ];
        System.assertEquals( Date.today(), titleCaseRec.Status_Last_Updated__c, 'The Status Last Updated Field was not correctly set' );
        System.assertEquals( TRUE, titleCaseRec.Was_Problem__c, 'The Was Problem Checkbox was not correctly set' );
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
            insert titleCaseRec;
            Test.setCreatedDate( titleCaseRec.Id, Datetime.now().addDays( -7 ) );

            Test.startTest();

                titleCaseRec.Status = '48 Hour Notice';
                update titleCaseRec;

            Test.stopTest();
        }

        titleCaseRec = [ SELECT Id, Status_Last_Updated__c, Title_Clerked_Date__c FROM Case WHERE Id = :titleCaseRec.Id LIMIT 1 ];
        System.assertEquals( Date.today(), titleCaseRec.Status_Last_Updated__c, 'The Status Last Updated Field was not correctly set' );
    }

    @isTest
    static void setReturnToSeller() {
        Auction__c testAuctRec = [ SELECT Id, buyer_dealership__c, buyer_contact__c FROM Auction__c LIMIT 1 ];
        Case titleCaseRec = TestUtility.createTitleCase( testAuctRec, new Account( Id = testAuctRec.buyer_dealership__c ), new Contact( Id = testAuctRec.buyer_contact__c ) );

        User testUser = TestUtility.createSystemAdministratorUser();
        insert testUser;

        titleCaseRec.Status = 'New';
        insert titleCaseRec;
        Test.setCreatedDate( titleCaseRec.Id, Datetime.now().addDays( -7 ) );

        Test.startTest();

        System.runAs( testUser ) {
            titleCaseRec.Status = 'Return to Seller';
            update titleCaseRec;
        }

        Test.stopTest();

        titleCaseRec = [ SELECT Id, Status_Last_Updated__c, Title_Clerked_Date__c FROM Case WHERE Id = :titleCaseRec.Id LIMIT 1 ];
        System.assertEquals( Date.today(), titleCaseRec.Status_Last_Updated__c, 'The Status Last Updated Field was not correctly set' );
    }

    @isTest
    static void setSent() {
        Auction__c testAuctRec = [ SELECT Id, buyer_dealership__c, buyer_contact__c FROM Auction__c LIMIT 1 ];
        Case titleCaseRec = TestUtility.createTitleCase( testAuctRec, new Account( Id = testAuctRec.buyer_dealership__c ), new Contact( Id = testAuctRec.buyer_contact__c ) );

        //Profile userProfile = [ SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User testUser = TestUtility.createSystemAdministratorUser();
        

        titleCaseRec.Status = 'New';
        insert titleCaseRec;
        Test.setCreatedDate( titleCaseRec.Id, Datetime.now().addDays( -7 ) );

        Test.startTest();

        System.runAs( testUser ) {
            titleCaseRec.Status = 'Sent';
            update titleCaseRec;
        }

        Test.stopTest();

        titleCaseRec = [ SELECT Id, Status_Last_Updated__c, Title_Clerked_Date__c FROM Case WHERE Id = :titleCaseRec.Id LIMIT 1 ];
        System.assertEquals( Date.today(), titleCaseRec.Status_Last_Updated__c, 'The Status Last Updated Field was not correctly set' );
    }

    @isTest
    static void setTitleAtACVUnwound() {
        Auction__c testAuctRec = [ SELECT Id, buyer_dealership__c, buyer_contact__c FROM Auction__c LIMIT 1 ];
        Case titleCaseRec = TestUtility.createTitleCase( testAuctRec, new Account( Id = testAuctRec.buyer_dealership__c ), new Contact( Id = testAuctRec.buyer_contact__c ) );

        User testUser = TestUtility.createUser();
        insert testUser;

        titleCaseRec.Status = 'New';
        insert titleCaseRec;
        Test.setCreatedDate( titleCaseRec.Id, Datetime.now().addDays( -7 ) );

        Test.startTest();

        System.runAs( testUser ) {
            titleCaseRec.Status = 'Title at ACV Unwound';
            update titleCaseRec;
        }

        Test.stopTest();

        titleCaseRec = [ SELECT Id, Status_Last_Updated__c, Title_Clerked_Date__c FROM Case WHERE Id = :titleCaseRec.Id LIMIT 1 ];
        System.assertEquals( Date.today(), titleCaseRec.Status_Last_Updated__c, 'The Status Last Updated Field was not correctly set' );
    }

    @isTest
    static void setClosedUnwound() {
        Auction__c testAuctRec = [ SELECT Id, buyer_dealership__c, buyer_contact__c FROM Auction__c LIMIT 1 ];
        Case titleCaseRec = TestUtility.createTitleCase( testAuctRec, new Account( Id = testAuctRec.buyer_dealership__c ), new Contact( Id = testAuctRec.buyer_contact__c ) );

        // Profile userProfile = [ SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User testUser = TestUtility.createSystemAdministratorUser();
        

        titleCaseRec.Status = 'New';
        insert titleCaseRec;
        Test.setCreatedDate( titleCaseRec.Id, Datetime.now().addDays( -7 ) );

        System.runAs( testUser ) {
            Group queueGroup = new Group(
                Type = 'Queue', Name = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Title Resolution Queue Name' LIMIT 1 ].Value__c
            );
            insert queueGroup;
            insert new QueuesObject(
                QueueId = queueGroup.Id, sObjectType = 'Case'
            );
        }

        Test.startTest();

        System.runAs( testUser ) {
            titleCaseRec.Status = 'Closed Unwound';
            update titleCaseRec;
        }

        Test.stopTest();

        titleCaseRec = [ SELECT Id, Status_Last_Updated__c, Title_Clerked_Date__c FROM Case WHERE Id = :titleCaseRec.Id LIMIT 1 ];
        System.assertEquals( Date.today(), titleCaseRec.Status_Last_Updated__c, 'The Status Last Updated Field was not correctly set' );
    }
}