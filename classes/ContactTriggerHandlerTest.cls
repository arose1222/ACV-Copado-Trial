@isTest
public class ContactTriggerHandlerTest {

    public final static String TEST_EMAIL1 = 'test@gmail.com.test';
    public final static String TEST_EMAIL2 = 'test@yahoo.com.test';

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        List<Account> accountList = New List<Account>();
        //accountList.add(new Account(Dealership_ID__c = '456', Name='seller',legal_Name__c='seller', dealer_type__c='1',IST_Account_Owner__c =UserInfo.getUserId(),BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        Account a = TestUtility.createAccount();
        a.Dealership_ID__c = '456';
        a.IST_Account_Owner__c = UserInfo.getUserId();
        accountList.add(a);
        insert accountList;

        final Id TITLE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
        Case newCase = new Case( 
            accountId = accountList[0].id, RecordTypeId = TITLE_RT_ID, status= 'New', ACV_Titles_External_ID__c = '123',
            Seller_Dealership__c = accountList[0].Id
        );
        insert newCase;
    }

    @isTest
    static void newTitleContact() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        test.StartTest();
            // Contact conRecord = new Contact(
            //     FirstName = 'seller', LastName = 'seller', accountId = testAcct.id, Email = TEST_EMAIL1,
            //     Title_Picklist__c = 'Title Clerk', Active__c = TRUE, ACV_Updated__c = DateTime.now()
            // );
            Contact conRecord = TestUtility.createContact(testAcct);
            conRecord.Email = TEST_EMAIL1;
            conRecord.Title_Picklist__c = 'Title Clerk';
            conRecord.ACV_Updated__c = System.now().addMinutes(-5);
            conRecord.Active__c = true;
            SalesforceGatewayUserCreateLogic.disableGatewayLogic();
            insert conRecord;
        test.StopTest();

        Case testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

        System.assertEquals( TEST_EMAIL1, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );
    }

    @isTest
    static void updateTitleContact() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];

        List<Contact> conLst = new List<Contact>();
        Contact conRecord = new Contact(
            FirstName = 'seller', LastName = 'seller', accountId = testAcct.id, Email = TEST_EMAIL1,
            Title_Picklist__c = 'Principal', Active__c = TRUE, ACV_Updated__c = DateTime.now()
        );
        conLst.add( conRecord );
        Contact conRecord2 = new Contact(
            FirstName = 'seller2', LastName = 'seller', accountId = testAcct.id, Email = TEST_EMAIL2,
            Title_Picklist__c = 'Title Clerk', Active__c = TRUE, ACV_Updated__c = DateTime.now().AddMinutes(-5)
        );
        conLst.add( conRecord2 );
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert conLst;

        test.StartTest();
            conRecord.Title_Picklist__c = 'Title Clerk';
            update conRecord;

            Case testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

            System.assertEquals( TEST_EMAIL1, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );

            conRecord.Title_Picklist__c = 'Principal';
            update conRecord;

        test.StopTest();

        testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

        System.assertEquals( TEST_EMAIL2, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );
    }

    @isTest
    static void updateAccountContact() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];

        List<Contact> conLst = new List<Contact>();
        Contact conRecord = new Contact(
            FirstName = 'seller', LastName = 'seller', accountId = testAcct.id, Email = TEST_EMAIL1,
            Title_Picklist__c = 'Title Clerk', Active__c = TRUE, ACV_Updated__c = DateTime.now()
        );
        conLst.add( conRecord );
        Contact conRecord2 = new Contact(
            FirstName = 'seller2', LastName = 'seller', accountId = testAcct.id, Email = TEST_EMAIL2,
            Title_Picklist__c = 'Title Clerk', Active__c = TRUE, ACV_Updated__c = DateTime.now().addMinutes(-5)
        );
        conLst.add( conRecord2 );
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert conLst;

        Account testAcct2 = new Account(Dealership_ID__c = '123', Name='buyer',legal_Name__c='buyer', dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert testAcct2;

        test.StartTest();
            Case testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

            System.assertEquals( TEST_EMAIL1, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );

            conRecord2.AccountId = testAcct2.Id;
            update conRecord2;

        test.StopTest();

        testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

        System.assertEquals( TEST_EMAIL1, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );
    }

    @isTest
    static void updateEmailContact() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];

        Contact conRecord = new Contact(
            FirstName = 'seller', LastName = 'seller', accountId = testAcct.id, Email = TEST_EMAIL1,
            Title_Picklist__c = 'Title Clerk', Active__c = TRUE, ACV_Updated__c = DateTime.now()
        );
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert conRecord;

        Case testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

        System.assertEquals( TEST_EMAIL1, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );

        test.StartTest();
            conRecord.Email = TEST_EMAIL2;
            update conRecord;
        test.StopTest();

        testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

        System.assertEquals( TEST_EMAIL2, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );
    }

    @isTest
    static void noContact() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        Contact conRecord = new Contact(
            FirstName = 'seller', LastName = 'seller', accountId = testAcct.id, Email = TEST_EMAIL1,
            Title_Picklist__c = 'Title Clerk', Active__c = TRUE, ACV_Updated__c = DateTime.now()
        );
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert conRecord;

        Case testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

        System.assertEquals( TEST_EMAIL1, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );

        test.StartTest();
            conRecord.Title_Picklist__c = 'Principal';
            update conRecord;
        test.StopTest();

        testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

        System.assertEquals( null, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );
    }

    @isTest
    static void deleteContact() {

        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Can_Modify_All_Contacts'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = TestUtility.createUser(p.Id);
        insert u;
        
        TestUtility.addContactDeletePermission(u.Id);
        
        System.RunAs(u)
        {
            Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
            insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
            Contact conRecord = TestUtility.createContact(testAcct);
            conRecord.Email = TEST_EMAIL1;
            conRecord.Title_Picklist__c = 'Title Clerk';
            conRecord.Active__c = true;
            conRecord.ACV_Updated__c = Datetime.now().addMinutes(-5);
            //new Contact(
            //     FirstName = 'seller', LastName = 'seller', accountId = testAcct.id, Email = TEST_EMAIL1,
            //     Title_Picklist__c = 'Title Clerk', Active__c = TRUE, ACV_Updated__c = DateTime.now().addMinutes(-5)
            // );
            SalesforceGatewayUserCreateLogic.disableGatewayLogic();
            insert conRecord;
            system.debug([SELECT Id, Title FROM Contact Where ID = :conRecord.Id]);
            System.debug(conRecord);
            System.debug([SELECT Count() FROM Contact WHERE Title_Picklist__c = 'Title Clerk']);
            system.assert([SELECT Count() FROM Contact WHERE Title_Picklist__c = 'Title Clerk'] == 1, 'Not found');
            Case testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

            System.assertEquals( TEST_EMAIL1, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );

            test.StartTest();
                delete conRecord;
            test.StopTest();

            testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

            System.assertEquals( null, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );
        }
    }

    @isTest     static void unDeleteContact() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];

        Contact conRecord = new Contact(
            FirstName = 'seller', LastName = 'seller', accountId = testAcct.id, Email = TEST_EMAIL1,
            Title_Picklist__c = 'Title Clerk', Active__c = TRUE, ACV_Updated__c = DateTime.now()
        );
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert conRecord;

        Case testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

        System.assertEquals( TEST_EMAIL1, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );

        delete conRecord;

        testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

        System.assertEquals( null, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );

        test.StartTest();
            undelete conRecord;
        test.StopTest();

        testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

        System.assertEquals( TEST_EMAIL1, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );
    }
}