@isTest
public class CaseTitlesProcessesTest {
    public final static String TEST_EMAIL1 = 'test@gmail.com.test';
    public final static String TEST_EMAIL2 = 'test@yahoo.com.test';
    static final String amFollowUp = 'AM Follow Up';

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Test.startTest();
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        List<Account> accountList = New List<Account>();
        accountList.add(new Account(Dealership_ID__c = '456', Name='seller',IST_Account_Owner__c =UserInfo.getUserId(),BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US', legal_Name__c='seller', dealer_type__c='1'));
        accountList.add(new Account(Dealership_ID__c = '123', Name='buyer',IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US', legal_Name__c='buyer', dealer_type__c='1'));
        insert accountList;
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(FirstName='seller', LastName='seller', accountId=accountList[0].id, Active__c = TRUE, ACV_Updated__c = Datetime.now().addMinutes(-5)));
        contactList.add(new Contact(FirstName='buyer', LastName='buyer', accountId=accountList[1].id, Active__c = TRUE, ACV_Updated__c = Datetime.now().addMinutes(-5)));
        insert contactList;
        vehicle__c newCar = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
        insert newCar;
        vehicle__c newCar1 = new vehicle__c(year__c='2010',make__c='test make', model__c='test model', vin__c = '1234567890102031');
        insert newCar1;
        auction__c newAuction = new auction__c(status__c = 'Active', end_time__c = System.Now(),Buyer_Dealership__c = accountList[0].id, 
        Seller_Dealership__c = accountList[1].id,Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = newCar.id);
        insert newAuction;

        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        Case newCase = new Case( accountId = accountList[0].id, RecordTypeId = arbRecordType, Vehicle__c = newCar.id, status= 'Awaiting Release', Buyer_s_Assurance_Exceptions__c = 'Goodwill', ACV_Titles_External_ID__c='456' ); //, Denial_status__C = 'Denial Pending'
        insert newCase;
        Case titleCase = TestUtility.createTitleCase(newAuction, accountList[0], contactList[0]);
        insert titleCase;

        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Related_Case_Object_Access'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = TestUtility.createUser(p.Id);
        insert u;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
        }
        Test.stopTest();
    }

    @isTest
    static void BuyerAddressStampTest(){
        List<Account> aList = [select id, Dealership_ID__c, BillingStreet from account where name = 'buyer'];
        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();

        if(aList.size() > 0){
            Account a = new Account(Dealership_ID__c = '123');
            Case c = new Case(account = a, recordTypeId = titlesRecordType, ACV_Titles_External_ID__c='123');
            upsert c;
            List<Case> cList = [select Default_Delivery_Address__c from case where id = :c.id];
            system.assertEquals(aList[0].BillingStreet, cList[0].Default_Delivery_Address__c);

            aList[0].BillingStreet = '222 Main St';
            update aList;
            cList[0].Default_Delivery_Address__c = null;
            update cList;
            cList = [select Default_Delivery_Address__c from case where id = :c.id];
            system.assertEquals(aList[0].BillingStreet, cList[0].Default_Delivery_Address__c);

        }
        System.Debug('CPU Time: ' + String.valueOf(Limits.getCpuTime()));

    }
    //Process : Title Data Update Automation DONE
    //criterias: update case owner, status = received, status = sent 
    @istest 
    static void updateCaseOwnerStatusWorking(){
        case newcase = new case();
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();

        newcase = [select status, recordtypeid, ownerid, Title_Received_Date__c, Title_Sent_date__C from case limit 1 ];
        newcase.status ='Working';
        newcase.recordtypeid = arbRecordtype ; 
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/New_York',
        UserName=uniqueUserName);
        System.debug('Current User: ' + UserInfo.getUserName());        
        System.runAs(u){
            update newcase;
            System.debug('Current User: ' + UserInfo.getUserName());
        }
        system.debug(newcase.ownerid);
        newcase = [select status, recordtypeid, ownerid, Title_Sent_date__C from case limit 1 ];
        System.assertequals(u.Id, newcase.ownerid);
        System.Debug('CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }

    @istest 
    static void updateCaseOwnerStatusRecieved(){
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        case newcase = new case();
        newcase = [select status, recordtypeid, Title_Received_Date__c from case where title_received_date__c = null limit 1 ];
        newcase.status = 'Received';
        newcase.recordtypeid = arbRecordtype ;
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/New_York',
        UserName=uniqueUserName);
        System.debug('Current User: ' + UserInfo.getUserName());
        System.runAs(u){
            update newcase;
        }
        newcase = [select status, recordtypeid, Title_Received_Date__c from case limit 1 ];
        System.assertequals(date.today(), newcase.title_received_date__C);
        System.Debug('CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }

    @istest 
    static void updateCaseOwnerStatusSent(){
        Case newCase = [SELECT Id, Status FROM Case WHERE RecordType.DeveloperName = 'Title_Information' LIMIT 1];
        newCase.update_status__c = 'Sent';
        Profile p = [SELECT Id FROM Profile WHERE Name='Titles'];
        User u = TestUtility.createUser(p.Id);
        insert u;
        System.runAs(u) {
            update newCase;
        }
        newcase = [SELECT Id, Status, Title_Sent_Date__c FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(Date.Today(), newCase.Title_Sent_Date__c);
        // System.Debug('CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }

    @isTest
    static void updateStatusOnAuctionTest(){
        List<Account> aList = [select id, BillingStreet from account where name = 'buyer'];
        List<Auction__c> auList = [select id from auction__c];
        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();

        if(aList.size() > 0 && auList.size() > 0){
            Case c = new Case(accountId = aList[0].id, recordTypeId = titlesRecordType, auction_number__c = auList[0].id, status = 'New', ACV_Titles_External_ID__c='555');
            insert c;
            c.status = 'Working';
            update c;
            auList = [select id, Title_Status_1__c from auction__c where id = :c.auction_number__c];
            system.assertEquals('New',auList[0].Title_Status_1__c);
        }
    }

    @isTest
    static void createTitleClerk() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        Contact testCon = [ SELECT Id FROM Contact WHERE AccountId = :testAcct.Id LIMIT 1 ];
        testCon.Email = TEST_EMAIL1;
        testCon.Title = CaseUtility.TITLE_CLERK;
        testCon.ACV_Updated__c = DateTime.now();
        update testCon;

        Test.startTest();
             final Id TITLE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

            Case testCase = new Case(
                AccountId = testAcct.Id, Seller_Dealership__c = testAcct.Id, recordTypeId = TITLE_RT_ID, ACV_Titles_External_ID__c='789'
            );
            insert testCase;            
        Test.stopTest();

        testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

        System.assertEquals( TEST_EMAIL1, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );
    }

    @isTest
    static void updateTitleClerk() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        Contact testCon = [ SELECT Id FROM Contact WHERE AccountId = :testAcct.Id LIMIT 1 ];
        testCon.Email = TEST_EMAIL1;
        testCon.Title = CaseUtility.TITLE_CLERK;
        testCon.ACV_Updated__c = DateTime.now();
        update testCon;

        final Id TITLE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        Case testCase = new Case(
            AccountId = testAcct.Id, Seller_Dealership__c = testAcct.Id, recordTypeId = TITLE_RT_ID, ACV_Titles_External_ID__c='666'
        );
        insert testCase;

        testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c = :testAcct.Id LIMIT 1 ];

        System.assertEquals( TEST_EMAIL1, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );

        Test.startTest();
            testCase.Seller_Dealership__c = null;
            update testCase;

            testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Id = :testCase.Id LIMIT 1 ];

            System.assertEquals( null, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );

            testCase.Seller_Dealership__c = testAcct.Id;
            update testCase;

            testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Id = :testCase.Id LIMIT 1 ];

            System.assertEquals( TEST_EMAIL1, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );

            Account testAcct2 = [ SELECT Id FROM Account WHERE Id != :testAcct.Id LIMIT 1 ];
            Contact testCon2 = [ SELECT Id FROM Contact WHERE AccountId = :testAcct2.Id LIMIT 1 ];
            testCon2.Email = TEST_EMAIL2;
            testCon2.Title = CaseUtility.TITLE_CLERK;
            testCon2.ACV_Updated__c = DateTime.now();
            update testCon2;

            testCase.Seller_Dealership__c = testAcct2.Id;
            update testCase;

            testCase = [ SELECT Id, Seller_Title_Clerk_Email__c FROM Case WHERE Id = :testCase.Id LIMIT 1 ];

            System.assertEquals( TEST_EMAIL2, testCase.Seller_Title_Clerk_Email__c, 'The Case\'s email doesn\'t match as expected' );
        Test.stopTest();
    }

    @isTest
    static void setTitleScanner() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        Case testCase = new Case(
            AccountId = testAcct.Id, Seller_Dealership__c = testAcct.Id, recordTypeId = TITLE_RT_ID, Status = 'New', ACV_Titles_External_ID__c='999'
        );
        insert testCase; 

        Test.startTest();
                       
            testCase.status = 'Sent';
            update testCase;

        Test.stopTest();

        testCase = [ SELECT Id, Status, Title_Scanner__c FROM Case WHERE Id = :testCase.Id LIMIT 1 ];

        System.assertEquals( UserInfo.getUserId(), testCase.Title_Scanner__c, 'The Case\'s Title Scanner field isn\'t filled out as expected' );
    }

    @isTest
    static void updateCustomerInquiryFromTitle(){
        Case titleCase = [SELECT Id, Status, AccountId FROM Case WHERE RecordType.DeveloperName = 'Title_Information' LIMIT 1];
        titleCase.update_status__c = 'Sent';
        Account a = [SELECT Id FROM Account WHERE Id = :titleCase.AccountId LIMIT 1];
        Case supCase = TestUtility.createSupportCase(a);
        insert supCase;
        Customer_Inquiry__c ci = new Customer_Inquiry__c();
        ci.Ops_Case__c = titleCase.Id;
        ci.Support_Case__c = supCase.Id;
        ci.Call_Bucket__c = 'Titles';
        ci.Call_Type__c = 'Buyer Title Status';
        ci.Status__c = 'New';
        insert ci;
        Profile p = [SELECT Id FROM Profile WHERE Name='Titles'];
        User u = TestUtility.createUser(p.Id);
        insert u;
        System.runAs(u) {
            Test.startTest();
                update titleCase;
            Test.stopTest();
        }
        ci = [SELECT Id, Status__c FROM Customer_Inquiry__c WHERE Ops_Case__c = :titleCase.Id];
        System.assertEquals(amFollowUp, ci.Status__c);
    }

    @isTest
    static void updateCustomerInquiryFromTitleBuyerReportedProblem(){
        Case titleCase = [SELECT Id, Status, AccountId FROM Case WHERE RecordType.DeveloperName = 'Title_Information' LIMIT 1];
        titleCase.update_status__c = 'Sent';
        Account a = [SELECT Id FROM Account WHERE Id = :titleCase.AccountId LIMIT 1];
        Case supCase = TestUtility.createSupportCase(a);
        insert supCase;
        Customer_Inquiry__c ci = new Customer_Inquiry__c();
        ci.Ops_Case__c = titleCase.Id;
        ci.Support_Case__c = supCase.Id;
        ci.Call_Bucket__c = 'Titles';
        ci.Call_Type__c = 'Buyer Reported Problem';
        ci.Status__c = 'New';
        insert ci;
        Profile p = [SELECT Id FROM Profile WHERE Name='Titles'];
        User u = TestUtility.createUser(p.Id);
        insert u;
        System.runAs(u) {
            Test.startTest();
                update titleCase;
            Test.stopTest();
        }
        ci = [SELECT Id, Status__c FROM Customer_Inquiry__c WHERE Ops_Case__c = :titleCase.Id];
        System.assertEquals(amFollowUp, ci.Status__c);
    }

    @isTest
    static void updateNullCallTypeCustomerInquiry(){
        Case titleCase = [SELECT Id, Status, AccountId FROM Case WHERE RecordType.DeveloperName = 'Title_Information' LIMIT 1];
        titleCase.update_status__c = 'Sent';
        Account a = [SELECT Id FROM Account WHERE Id = :titleCase.AccountId LIMIT 1];
        Case supCase = TestUtility.createSupportCase(a);
        insert supCase;
        Customer_Inquiry__c ci = new Customer_Inquiry__c();
        ci.Ops_Case__c = titleCase.Id;
        ci.Support_Case__c = supCase.Id;
        ci.Call_Bucket__c = 'Titles';
        ci.Status__c = 'New';
        insert ci;
        Profile p = [SELECT Id FROM Profile WHERE Name='Titles'];
        User u = TestUtility.createUser(p.Id);
        insert u;
        System.runAs(u) {
            Test.startTest();
                update titleCase;
            Test.stopTest();
        }
        ci = [SELECT Id, Status__c FROM Customer_Inquiry__c WHERE Ops_Case__c = :titleCase.Id];
        System.assertEquals(amFollowUp, ci.Status__c);
    }
}