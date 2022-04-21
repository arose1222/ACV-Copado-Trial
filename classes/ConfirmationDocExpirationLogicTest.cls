@isTest
public class ConfirmationDocExpirationLogicTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id confirmationId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('License_Renewal_Confirmation').getRecordTypeId();
    @isTest
    static void docExpToday() {
        //need an account
        Account testAcct = TestUtility.createAccount('Test'); //new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId());
        testAcct.IST_Account_Owner__c = UserInfo.getUserId();
        insert testAcct;
        //need a date
        Date today = System.Today();
        //need a license
        Dealer_Docs__c licDoc = new Dealer_Docs__c(Account__c = testAcct.Id, Expiration_Date__c = null, No_Expiration__c = true, RecordTypeId = licenseId, Document_State__c = 'AZ', License_Number__c = '11111', Compliant__c = true, Review_Status__c = 'Complete');
        insert licDoc;
        //need a confirmation doc exp today
        Dealer_Docs__c conDoc = new Dealer_Docs__c(Account__c = testAcct.Id, Related_Dealer_License__c = licDoc.Id, RecordTypeId = confirmationId, Expiration_Date__c = today, License_Number__c = '11111');
        insert conDoc;
        //run DealerDocExpirationHandler
        Test.startTest();
            DealerDocExpirationHandler batch = new DealerDocExpirationHandler();
            Batch.executeScheduledLogic();
        Test.stopTest();
        //system.asserts
        Dealer_Docs__c checkLicDoc = [SELECT Id, Document_Expired__c FROM Dealer_Docs__c WHERE RecordTypeId = :licenseId];
        System.assertEquals(true, checkLicDoc.Document_Expired__c);

        Dealer_Docs__c checkConDoc = [SELECT Id, Document_Expired__c FROM Dealer_Docs__c WHERE RecordTypeId = :confirmationId];
        System.assertEquals(true, checkConDoc.Document_Expired__c);
    }

    @isTest
    static void docExpTwoWeeks() {
        //need an account
        Account testAcct = TestUtility.createAccount('Test'); //new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId());
        testAcct.IST_Account_Owner__c = UserInfo.getUserId();
        insert testAcct;
        //need a date
        Date twoWeeks = System.Today().addDays(14);
        //need a license
        Dealer_Docs__c licDoc = new Dealer_Docs__c(Account__c = testAcct.Id, Expiration_Date__c = null, No_Expiration__c = true, RecordTypeId = licenseId, Document_State__c = 'AZ', License_Number__c = '11111', Compliant__c = true, Review_Status__c = 'Complete');
        insert licDoc;
        //need a confirmation doc exp two weeks
        Dealer_Docs__c conDoc = new Dealer_Docs__c(Account__c = testAcct.Id, Related_Dealer_License__c = licDoc.Id, RecordTypeId = confirmationId, Expiration_Date__c = twoWeeks, License_Number__c = '11111');
        insert conDoc;
        //run DealerDocExpirationHandler
        Test.startTest();
            DealerDocExpirationHandler batch = new DealerDocExpirationHandler();
            Batch.executeScheduledLogic();
        Test.stopTest();
        //system.asserts
        Dealer_Docs__c checkLicDoc = [SELECT Id, Document_Expired__c FROM Dealer_Docs__c WHERE RecordTypeId = :licenseId];
        System.assertEquals(false, checkLicDoc.Document_Expired__c); //not expired yet

        Dealer_Docs__c checkConDoc = [SELECT Id, Document_Expired__c FROM Dealer_Docs__c WHERE RecordTypeId = :confirmationId]; //Reminder_Email_Sent__c
        System.assertEquals(false, checkConDoc.Document_Expired__c); //not expired yet
        //System.assertEquals(true, checkConDoc.Reminder_Email_Sent__c);
    }

    @isTest
    static void twoDocsSameLicense() {
        //need an account
        Account testAcct = TestUtility.createAccount('Test'); //new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId());
        testAcct.IST_Account_Owner__c = UserInfo.getUserId();
        insert testAcct;
        //need two dates - today and future
        Date today = System.Today();
        Date future = System.Today().addMonths(5);
        //need a license
        Dealer_Docs__c licDoc = new Dealer_Docs__c(Account__c = testAcct.Id, Expiration_Date__c = null, No_Expiration__c = true, RecordTypeId = licenseId, Document_State__c = 'AZ', License_Number__c = '11111', Compliant__c = true, Review_Status__c = 'Complete');
        insert licDoc;
        //need two confirmation docs - one exp today and one in the future
        List<Dealer_Docs__c> conDocs = new List<Dealer_Docs__c>();
        conDocs.add(new Dealer_Docs__c(Account__c = testAcct.Id, Related_Dealer_License__c = licDoc.Id, RecordTypeId = confirmationId, Expiration_Date__c = today, License_Number__c = '11111'));
        conDocs.add(new Dealer_Docs__c(Account__c = testAcct.Id, Related_Dealer_License__c = licDoc.Id, RecordTypeId = confirmationId, Expiration_Date__c = future, License_Number__c = '11111'));
        insert conDocs;
        //run DealerDocExpirationHandler
        Test.startTest();
            DealerDocExpirationHandler batch = new DealerDocExpirationHandler();
            Batch.executeScheduledLogic();
        Test.stopTest();
        //system.asserts
        Dealer_Docs__c checkLicDoc = [SELECT Id, Document_Expired__c FROM Dealer_Docs__c WHERE RecordTypeId = :licenseId];
        System.assertEquals(false, checkLicDoc.Document_Expired__c); //not expired with new doc

        List<Dealer_Docs__c> checkConDocs = [SELECT Id, Document_Expired__c FROM Dealer_Docs__c WHERE RecordTypeId = :confirmationId];
        System.assertEquals(true, checkConDocs[0].Document_Expired__c);
        System.assertEquals(false, checkConDocs[1].Document_Expired__c);
    }

    @isTest
    static void twoDocsDifferentLicenses() {
        //need an account
        Account testAcct = TestUtility.createAccount('Test'); //new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId());
        testAcct.IST_Account_Owner__c = UserInfo.getUserId();
        insert testAcct;
        //need two dates: today and two weeks
        Date today = System.Today();
        Date twoWeeks = System.Today().addDays(14);
        //need two licenses
        List<Dealer_Docs__c> licList = new List<Dealer_Docs__c>();
        licList.add(new Dealer_Docs__c(Account__c = testAcct.Id, Expiration_Date__c = null, No_Expiration__c = true, RecordTypeId = licenseId, Document_State__c = 'AZ', License_Number__c = '11111', Compliant__c = true, Review_Status__c = 'Complete'));
        licList.add(new Dealer_Docs__c(Account__c = testAcct.Id, Expiration_Date__c = null, No_Expiration__c = true, RecordTypeId = licenseId, Document_State__c = 'AZ', License_Number__c = '22222', Compliant__c = true, Review_Status__c = 'Complete'));
        insert licList;
        //need two confirmation docs - one expiring today and one in two weeks
        List<Dealer_Docs__c> conDocs = new List<Dealer_Docs__c>();
        conDocs.add(new Dealer_Docs__c(Account__c = testAcct.Id, Related_Dealer_License__c = licList[0].Id, RecordTypeId = confirmationId, Expiration_Date__c = today, License_Number__c = '11111'));
        conDocs.add(new Dealer_Docs__c(Account__c = testAcct.Id, Related_Dealer_License__c = licList[1].Id, RecordTypeId = confirmationId, Expiration_Date__c = twoWeeks, License_Number__c = '22222'));
        insert conDocs;
        //run batch
        Test.startTest();
            DealerDocExpirationHandler batch = new DealerDocExpirationHandler();
            Batch.executeScheduledLogic();
        Test.stopTest();

        List<Dealer_Docs__c> checkDocList = [SELECT Id, Document_Expired__c FROM Dealer_Docs__c WHERE RecordTypeId = :licenseId AND License_Number__c = '11111'];
        System.assertEquals(true, checkDocList[0].Document_Expired__c);

        List<Dealer_Docs__c> checkConDocList = [SELECT Id, Document_Expired__c FROM Dealer_Docs__c WHERE RecordTypeId = :confirmationId ORDER BY License_Number__c ASC]; //Reminder_Email_Sent__c
        System.assertEquals(true, checkConDocList[0].Document_Expired__c);
        //System.assertEquals(true, checkConDocList[1].Reminder_Email_Sent__c);
    }
}