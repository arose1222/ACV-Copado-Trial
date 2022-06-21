@isTest
public class DealerDocExpirationReminderHandlerTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();
    public static final Id confirmationId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('License_Renewal_Confirmation').getRecordTypeId();

    @TestSetup
    static void makeData(){
        List<Account> acctList = new List<Account>();
        //need an account with two docs - one expiring a year in the future, one that doesn't expire
        acctList.add(new Account(Name = 'Test 1', phone='1234567890',IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Test 1', Dealer_Type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        //need an account with two docs - one that shouldn't get picked up by the batch and one expiring in 30 days
        acctList.add(new Account(Name = 'Test 2', phone='1234567890',IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Test 2', Dealer_Type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        //need an account with three docs - all expiring on one of the reminder days
        acctList.add(new Account(Name = 'Test 3', phone='1234567890',IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Test 3', Dealer_Type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        //insert
        insert acctList;

        Contact c = TestUtility.createContact(acctList[0]);
        insert c;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( acctList[0], c );
        affList.add( aff );
        Affiliation__c aff1 = TestUtility.createAffiliation( acctList[1], c );
        affList.add( aff1 );
        Affiliation__c aff2 = TestUtility.createAffiliation( acctList[2], c );
        affList.add( aff2 );
        insert affList;

        //dates
        Date future = System.today().addMonths(12);
        Date days45 = System.today().addDays(45);
        Date days30 = System.today().addDays(30);
        Date days14 = System.today().addDays(14);

        //seven docs
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(Account__c = acctList[0].Id, RecordTypeId = licenseId, Document_State__c = 'AZ', No_Expiration__c = true, License_Number__c = '11111', Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = acctList[0].Id, RecordTypeId = resaleId, Document_State__c = 'AZ', Expiration_Date__c = future, Permit_Resale_Number__c = '22222', Compliant__c = true));

        docList.add(new Dealer_Docs__c(Account__c = acctList[1].Id, RecordTypeId = licenseId, Document_State__c = 'NY', Expiration_Date__c = days30, License_Number__c = '33333', Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = acctList[1].Id, RecordTypeId = resaleId, Document_State__c = 'NY', No_Expiration__c = true, Permit_Resale_Number__c = '44444', Compliant__c = true));

        docList.add(new Dealer_Docs__c(Account__c = acctList[2].Id, RecordTypeId = licenseId, Document_State__c = 'FL', Expiration_Date__c = days14, License_Number__c = '55555', Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = acctList[2].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Expiration_Date__c = days30, Permit_Resale_Number__c = '66666', Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = acctList[2].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Expiration_Date__c = days45, Permit_Resale_Number__c = '77777', Compliant__c = true));
        //insert
        insert docList;
    }

    @isTest
    static void batchTest() {
        //run batch
        Test.startTest();
            DealerDocExpirationReminderHandler batch = new DealerDocExpirationReminderHandler();
            Batch.executeScheduledLogic();
        Test.stopTest();

        List<Dealer_Docs__c> docList = [SELECT Id, Reminder_Email_Sent__c, Thirty_Day_Reminder_Email_Sent__c, Forty_Five_Day_Reminder_Email_Sent__c FROM Dealer_Docs__c]; //theoretically this should return them in the same order i created them
        //for account 1 - make sure that all three checkbox fields are false
        //first doc
        System.assertEquals(false, docList[0].Reminder_Email_Sent__c);
        System.assertEquals(false, docList[0].Thirty_Day_Reminder_Email_Sent__c);
        System.assertEquals(false, docList[0].Forty_Five_Day_Reminder_Email_Sent__c);
        //second doc
        System.assertEquals(false, docList[1].Reminder_Email_Sent__c);
        System.assertEquals(false, docList[1].Thirty_Day_Reminder_Email_Sent__c);
        System.assertEquals(false, docList[1].Forty_Five_Day_Reminder_Email_Sent__c);
        //for account 2 - make sure that ONLY the 30 day checkbox field is true (for the appropriate doc)
        //first doc
        System.assertEquals(false, docList[2].Reminder_Email_Sent__c);
        System.assertEquals(true, docList[2].Thirty_Day_Reminder_Email_Sent__c);
        System.assertEquals(false, docList[2].Forty_Five_Day_Reminder_Email_Sent__c);
        //second doc
        System.assertEquals(false, docList[3].Reminder_Email_Sent__c);
        System.assertEquals(false, docList[3].Thirty_Day_Reminder_Email_Sent__c);
        System.assertEquals(false, docList[3].Forty_Five_Day_Reminder_Email_Sent__c);
        //for account 3 - make sure that all checkbox fields are true (in respective documents)
        //first doc
        System.assertEquals(true, docList[4].Reminder_Email_Sent__c);
        System.assertEquals(false, docList[4].Thirty_Day_Reminder_Email_Sent__c);
        System.assertEquals(false, docList[4].Forty_Five_Day_Reminder_Email_Sent__c);
        //second doc
        System.assertEquals(false, docList[5].Reminder_Email_Sent__c);
        System.assertEquals(true, docList[5].Thirty_Day_Reminder_Email_Sent__c);
        System.assertEquals(false, docList[5].Forty_Five_Day_Reminder_Email_Sent__c);
        //third doc
        System.assertEquals(false, docList[6].Reminder_Email_Sent__c);
        System.assertEquals(false, docList[6].Thirty_Day_Reminder_Email_Sent__c);
        System.assertEquals(true, docList[6].Forty_Five_Day_Reminder_Email_Sent__c);
    }

    @isTest
    static void bulkTest() {
        Date days30 = System.Today().addDays(30);
        Account newAccount = new Account(Name = 'Test Account', phone='1234567890',IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Test Account', Dealer_Type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert newAccount;

        Test.startTest();
            Contact c = TestUtility.createContact(newAccount);
            insert c;
            Affiliation__c aff = TestUtility.createAffiliation( newAccount, c );
            insert aff;

            //create 200 dealer docs
            List<Dealer_Docs__c> bulkDocs = new List<Dealer_Docs__c>();
            for (Integer i = 0; i < 193; i ++) { //have to account for the seven docs in the make data
                bulkDocs.add(new Dealer_Docs__c(Account__c = newAccount.Id, Expiration_Date__c = days30, RecordTypeId = resaleId, Document_State__c = 'WA', Permit_Resale_Number__c = '11111'));
            }
            insert bulkDocs;

            //run batch
            DealerDocExpirationReminderHandler batch = new DealerDocExpirationReminderHandler();
            Batch.executeScheduledLogic();
            //stop test
        Test.stopTest();
        //test "pass" condition is: no cpu errors thrown
    }

    @isTest
    static void errorCheck() {
        //populate errorList
        DealerDocExpirationReminderHandler.errorList.add('error');
        //start test
        Test.startTest();
        //run batch
            DealerDocExpirationReminderHandler batch = new DealerDocExpirationReminderHandler();
            Batch.executeScheduledLogic();
        //stop test
        Test.stopTest();
    }
}