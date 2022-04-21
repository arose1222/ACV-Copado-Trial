@isTest
public class DealerDocInsertTimeStampForAcctTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    @TestSetup
    static void makeData() {
        List<Account> acctList = new List<account>();
        DateTime testDate = System.Today().addDays(-5);
        acctList.add(new Account(Name = 'Test 1', IST_Account_Owner__c = UserInfo.getUserId()));
        acctList.add(new Account(Name = 'Test 2', IST_Account_Owner__c = UserInfo.getUserId(), Required_Docs_Uploaded__c = testDate));
        insert acctList;
    }
    
    @isTest
    static void licenseInSpecialStateTest() {
        //need an account
        Account testAcct = [SELECT Id FROM Account WHERE Name = 'Test 1'];
        //expDate
        Date expDate = System.Today().addMonths(5);
        //need a license in a special state
        Dealer_Docs__c testDoc = new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '11111', Expiration_Date__c = expDate);
        insert testDoc;

        testAcct = [SELECT Id, Required_Docs_Uploaded__c FROM Account WHERE Name = 'Test 1'];
        System.assertNotEquals(null, testAcct.Required_Docs_Uploaded__c, 'Field did not populate correctly (License in special state)');
    }

    @isTest
    static void licenseWithResaleInSystem() {
        //need an account
        Account testAcct = [SELECT Id FROM Account WHERE Name = 'Test 1'];
        //expDate
        Date expDate = System.Today().addMonths(5);
        //insert resale doc
        Dealer_Docs__c resale = new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = resaleId, Document_State__c = 'LA', Permit_Resale_Number__c = '11111', Expiration_Date__c = expDate);
        insert resale;
        //start test and insert license
        Dealer_Docs__c license = new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'LA', License_Number__c = '22222', Expiration_Date__c = expDate);
        Test.startTest();
            insert license;
        //stop test
        Test.stopTest();
        //system.assert
        testAcct = [SELECT Id, Required_Docs_Uploaded__c FROM Account WHERE Name = 'Test 1'];
        System.assertNotEquals(null, testAcct.Required_Docs_Uploaded__c, 'Field did not populate correctly (License not in special state)');
    }

    @isTest
    static void resaleWithLicenseInSystem() {
        //need an account
        Account testAcct = [SELECT Id FROM Account WHERE Name = 'Test 1'];
        //expDate
        Date expDate = System.Today().addMonths(5);
        //insert license
        Dealer_Docs__c license = new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'LA', License_Number__c = '22222', Expiration_Date__c = expDate);
        insert license;
        //start test and insert resale
        Dealer_Docs__c resale = new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = resaleId, Document_State__c = 'LA', Permit_Resale_Number__c = '11111', Expiration_Date__c = expDate);
        Test.startTest();
            insert resale;
        //stop test
        Test.stopTest();
        //system.assert
        testAcct = [SELECT Id, Required_Docs_Uploaded__c FROM Account WHERE Name = 'Test 1'];
        System.assertNotEquals(null, testAcct.Required_Docs_Uploaded__c, 'Field did not populate correctly (Resale not in special state)');
    }

    @isTest
    static void onlyLicense() {
        //need an account
        Account testAcct = [SELECT Id FROM Account WHERE Name = 'Test 1'];
        //expDate
        Date expDate = System.Today().addMonths(5);
        //insert license not in a special state
        Dealer_Docs__c license = new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'LA', License_Number__c = '22222', Expiration_Date__c = expDate);
        insert license;
        //should not populate the field
        testAcct = [SELECT Id, Required_Docs_Uploaded__c FROM Account WHERE Name = 'Test 1'];
        //system.assert
        System.assertEquals(null, testAcct.Required_Docs_Uploaded__c, 'Field populated with only one doc (License)');
    }

    @isTest
    static void onlyResale() {
        //need an account
        Account testAcct = [SELECT Id FROM Account WHERE Name = 'Test 1'];
        //expDate
        Date expDate = System.Today().addMonths(5);
        //insert resale doc
        Dealer_Docs__c resale = new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = resaleId, Document_State__c = 'LA', Permit_Resale_Number__c = '11111', Expiration_Date__c = expDate);
        insert resale;
        //should not populate a field
        testAcct = [SELECT Id, Required_Docs_Uploaded__c FROM Account WHERE Name = 'Test 1'];
        //system.assert
        System.assertEquals(null, testAcct.Required_Docs_Uploaded__c, 'Field populated with only one doc (Resale)');
    }

    @isTest
    static void dateFieldPopulated() {
        //need an account
        Account testAcct = [SELECT Id FROM Account WHERE Name = 'Test 2'];
        //expDate
        Date expDate = System.Today().addMonths(5);
        DateTime checkTime = System.Now().addHours(-2); //two hours earlier
        //insert license in special state
        Dealer_Docs__c testDoc = new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '11111', Expiration_Date__c = expDate);
        insert testDoc;
        //should not update the date field
        testAcct = [SELECT Id, Required_Docs_Uploaded__c FROM Account WHERE Name = 'Test 2'];
        //system.assert
        System.assert(testAcct.Required_Docs_Uploaded__c < checkTime, 'Overwrote old uploaded date with new uploaded date.'); //make sure the date has not been updated to the new createdDate
    }
}