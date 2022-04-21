@isTest
public class DealerDocExpirationHandlerTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();
    public static final Id confirmationId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('License_Renewal_Confirmation').getRecordTypeId();

    //do i need @TestSetup?
    @isTest
    static void runTest() {
        //need a few dates - expiring today, expiring in two weeks, expiring in a while
        Date expToday = System.Today();
        //Date expTwoWeeks = System.Today().addDays(14);
        Date expLater = System.Today().addMonths(5);
        //need two accounts
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Doc_Compliance__c = 'Out of Compliance', legal_name__c='Account1', Dealer_Type__c='1'));
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Doc_Compliance__c = 'Out of Compliance', legal_name__c='Account3', Dealer_Type__c='1'));
        accountList.add(new Account(Name = 'Account3', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Doc_Compliance__c = 'Out of Compliance', legal_name__c='Account3', Dealer_Type__c='1'));
        //insert accounts
        insert accountList;
        //make a few doc records
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        //need one of each type that is expiring today
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, Expiration_Date__c = expToday, RecordTypeId = resaleId, Document_State__c = 'WA', Permit_Resale_Number__c = '22222'));
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, Expiration_Date__c = expToday, RecordTypeId = licenseId, Document_State__c = 'WA', License_Number__c = '33333'));
        //need one of each type that is expiring in two weeks
        //docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, Expiration_Date__c = expTwoWeeks, RecordTypeId = resaleId, Document_State__c = 'WA', Permit_Resale_Number__c = '22222'));
        //docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, Expiration_Date__c = expTwoWeeks, RecordTypeId = licenseId, Document_State__c = 'WA', License_Number__c = '33333'));
        //need one of one type that is expiring in a year
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, Expiration_Date__c = expLater, RecordTypeId = licenseId, Document_State__c = 'WA', License_Number__c = '33333'));
        //need one of each type that is expiring in two weeks
        //docList.add(new Dealer_Docs__c(Account__c = accountList[2].Id, Expiration_Date__c = expTwoWeeks, RecordTypeId = resaleId, Document_State__c = 'WA', Permit_Resale_Number__c = '22222'));
        //docList.add(new Dealer_Docs__c(Account__c = accountList[2].Id, Expiration_Date__c = expTwoWeeks, RecordTypeId = licenseId, Document_State__c = 'WA', License_Number__c = '33333'));
        //need one of the other type that is expiring in a year
        docList.add(new Dealer_Docs__c(Account__c = accountList[2].Id, Expiration_Date__c = expLater, RecordTypeId = resaleId, Document_State__c = 'WA', Permit_Resale_Number__c = '22222'));
        //insert docs
        insert docList;
        //start test
        Test.startTest();
        //run batch
            DealerDocExpirationHandler batch = new DealerDocExpirationHandler();
            Batch.executeScheduledLogic();
        //stop test
        Test.stopTest();
        //query docs
        List<Dealer_Docs__c> expTodayCheck = [SELECT Document_Expired__c, Compliant__c, Compliance_Issues__c, Review_Status__c, Reminder_Email_Sent__c FROM Dealer_Docs__c WHERE Account__r.Name = 'Account1'];
        //List<Dealer_Docs__c> expTwoWeeksCheck = [SELECT Document_Expired__c, Reminder_Email_Sent__c FROM Dealer_Docs__c WHERE Account__r.Name = 'Account2' AND RecordType.DeveloperName = 'Resale_Certificate'];
        //List<Dealer_Docs__c> expTwoWeeksCheck2 = [SELECT Document_Expired__c, Reminder_Email_Sent__c FROM Dealer_Docs__c WHERE Account__r.Name = 'Account3' AND RecordType.DeveloperName = 'Dealer_License'];
        //make sure that fields are changed appropriately for two docs expiring today
        System.assertEquals(true, expTodayCheck[0].Document_Expired__c);
        System.assertEquals(false, expTodayCheck[0].Compliant__c);
        System.assertEquals('Document expired', expTodayCheck[0].Compliance_Issues__c);
        System.assertEquals(null, expTodayCheck[0].Review_Status__c);
        System.assertEquals(true, expTodayCheck[1].Document_Expired__c);
        System.assertEquals(false, expTodayCheck[1].Compliant__c);
        System.assertEquals('Document expired', expTodayCheck[1].Compliance_Issues__c);
        System.assertEquals(null, expTodayCheck[1].Review_Status__c);
        System.assertNotEquals(true, expTodayCheck[0].Reminder_Email_Sent__c); //checking this wasn't changed when it should have been ignored
        System.assertNotEquals(true, expTodayCheck[1].Reminder_Email_Sent__c); //checking this wasn't changed when it should have been ignored
        //make sure email reminder feild is correct for doc with no same type doc for account
        //System.assertEquals(true, expTwoWeeksCheck[0].Reminder_Email_Sent__c);
        //System.assertNotEquals(true, expTwoWeeksCheck[0].Document_Expired__c); //checking this wasn't changed when it should have been ignored
        //make sure email reminder feild is correct for doc with no same type doc for account
        //System.assertEquals(true, expTwoWeeksCheck2[0].Reminder_Email_Sent__c);
        //System.assertNotEquals(true, expTwoWeeksCheck2[0].Document_Expired__c); //checking this wasn't changed when it should have been ignored
        //can i make sure the workflow sent the email? or will that not happen because this is in a test context?
    }

    @isTest
    static void bulkTest() {
        //create a date
        Date today = System.Today();
        //create an account
        Account newAccount = new Account(Name = 'Test Account', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Test Account', Dealer_Type__c='1');
        //insert account
        insert newAccount;
        //create 200 dealer docs
        List<Dealer_Docs__c> bulkDocs = new List<Dealer_Docs__c>();
        for (Integer i = 0; i < 200; i ++) {
            bulkDocs.add(new Dealer_Docs__c(Account__c = newAccount.Id, Expiration_Date__c = today, RecordTypeId = resaleId, Document_State__c = 'WA', Permit_Resale_Number__c = '22222'));
        }
        //insert docs
        insert bulkDocs;
        //run through batch
        //start test
        Test.startTest();
        //run batch
            DealerDocExpirationHandler batch = new DealerDocExpirationHandler();
            Batch.executeScheduledLogic();
        //stop test
        Test.stopTest();
        //test "pass" condition is: no errors thrown
    }

    @isTest
    static void errorCheck() {
        //populate errorList
        DealerDocExpirationHandler.errorList.add('error');
        //start test
        Test.startTest();
        //run batch
            DealerDocExpirationHandler batch = new DealerDocExpirationHandler();
            Batch.executeScheduledLogic();
        //stop test
        Test.stopTest();
    }

    @isTest
    static void confirmationDocsTest() {
        //need an account
        Account testAcct = new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Test', Dealer_Type__c='1');
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
        //conDocs.add(new Dealer_Docs__c(Account__c = testAcct.Id, Related_Dealer_License__c = licList[1].Id, RecordTypeId = confirmationId, Expiration_Date__c = twoWeeks, License_Number__c = '22222'));
        insert conDocs;
        //run batch
        Test.startTest();
            DealerDocExpirationHandler batch = new DealerDocExpirationHandler();
            Batch.executeScheduledLogic();
        Test.stopTest();

        List<Dealer_Docs__c> checkDocList = [SELECT Id, Document_Expired__c FROM Dealer_Docs__c WHERE RecordTypeId = :licenseId AND License_Number__c = '11111'];
        System.assertEquals(true, checkDocList[0].Document_Expired__c);

        List<Dealer_Docs__c> checkConDocList = [SELECT Id, Document_Expired__c, Reminder_Email_Sent__c FROM Dealer_Docs__c WHERE RecordTypeId = :confirmationId ORDER BY License_Number__c ASC];
        System.assertEquals(true, checkConDocList[0].Document_Expired__c);
        //System.assertEquals(true, checkConDocList[1].Reminder_Email_Sent__c);
    }
}