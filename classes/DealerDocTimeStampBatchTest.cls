@isTest
public class DealerDocTimeStampBatchTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    public static DateTime utcToEST(DateTime utcCreatedDate) {
        Integer Day = utcCreatedDate.Day();
        Integer Month = utcCreatedDate.Month();
        Integer Year = utcCreatedDate.Year();
        Integer Hour = utcCreatedDate.Hour(); //so this is showing up as the EST hour, but the value in the field at the end is UTC still
        Integer estHour = Hour - 5; //i don't know how this works, but it works
        Integer Minute = utcCreatedDate.Minute();
        Integer Second = utcCreatedDate.Second();
        DateTime correctedDateTime = DateTime.newInstance(Year, Month, Day, estHour, Minute, Second); //so when it creates the new instance, it makes it UTC. fun.
        //System.debug(correctedDateTime);
        return correctedDateTime;
    }

    @TestSetup
    static void makeData(){
        Account newAcct = new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Test', Dealer_Type__c='1');
        insert newAcct;
    }

    @isTest
    static void licenseInSpecialState() { //making sure the date of the license is stamped correctly and code isn't looking for a resale cert
        Account testAcct = [SELECT Id FROM Account];
        Date expDate = System.Today().addMonths(5);
        Dealer_Docs__c testDoc = (new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '11111', Expiration_Date__c = expDate));
        insert testDoc;

        //run batch
        Test.startTest();
            SchedulableContext sc = null;
            DealerDocTimeStampBatch batch = new DealerDocTimeStampBatch();
            Batch.execute(sc);
        Test.stopTest();

        testAcct = [SELECT Id, Required_Docs_Uploaded__c FROM Account];
        System.assertNotEquals(null, testAcct.Required_Docs_Uploaded__c);
    }

    @isTest
    static void licenseAndResaleNotSpecial() { //making sure the code takes the date of the more recent doc
        Account testAcct = [SELECT Id FROM Account];
        Date expDate = System.Today().addMonths(5);
        DateTime createdDate = System.Now().addHours(-3);
        Dealer_Docs__c testDoc1 = (new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '11111', Expiration_Date__c = expDate));
        insert testDoc1;
        Test.setCreatedDate(testDoc1.Id, createdDate); //can i do this?
        Dealer_Docs__c testDoc2 = (new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '22222', Expiration_Date__c = expDate));
        insert testDoc2; //doing two inserts so the created dates will be slightly different

        //run batch
        Test.startTest();
            SchedulableContext sc = null;
            DealerDocTimeStampBatch batch = new DealerDocTimeStampBatch();
            Batch.execute(sc);
        Test.stopTest();

        testAcct = [SELECT Id, Required_Docs_Uploaded__c FROM Account];
        testDoc1 = [SELECT Id, CreatedDate FROM Dealer_Docs__c WHERE RecordType.DeveloperName = 'Dealer_License'];
        System.assertNotEquals(null, testAcct.Required_Docs_Uploaded__c);
        System.assertEquals(true, (testAcct.Required_Docs_Uploaded__c > utcToEst(testDoc1.CreatedDate)));
    }

    @isTest
    static void onlyAResale() { //making sure the code doesn't stamp a date because the other doc is missing
        Account testAcct = [SELECT Id FROM Account];
        Date expDate = System.Today().addMonths(5);
        Dealer_Docs__c testDoc = (new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '22222', Expiration_Date__c = expDate));
        insert testDoc;

        //run batch
        Test.startTest();
            SchedulableContext sc = null;
            DealerDocTimeStampBatch batch = new DealerDocTimeStampBatch();
            Batch.execute(sc);
        Test.stopTest();

        testAcct = [SELECT Id, Required_Docs_Uploaded__c FROM Account];
        System.assertEquals(null, testAcct.Required_Docs_Uploaded__c);
    }

    @isTest
    static void multiplesOfBothDocs() { //making sure the code takes the date of the first doc of its kind, but the second of the two required (that makes no sense)
        Account testAcct = [SELECT Id FROM Account];
        Date expDate = System.Today().addMonths(5);
        DateTime createdDate1 = System.Now().addHours(-6);
        DateTime createdDate2 = System.Now().addHours(-4);
        DateTime createdDate3 = System.Now().addHours(-2);
        Dealer_Docs__c testDoc1 = (new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '11111', Expiration_Date__c = expDate));
        insert testDoc1;
        Test.setCreatedDate(testDoc1.Id, createdDate1);
        Dealer_Docs__c testDoc2 = (new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '22222', Expiration_Date__c = expDate));
        insert testDoc2;
        Test.setCreatedDate(testDoc2.Id, createdDate2);
        Dealer_Docs__c testDoc3 = (new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '33333', Expiration_Date__c = expDate));
        insert testDoc3;
        Test.setCreatedDate(testDoc3.Id, createdDate3);
        Dealer_Docs__c testDoc4 = (new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '44444', Expiration_Date__c = expDate));
        insert testDoc4; // doing four inserts so the created dates are all different

        //run batch
        Test.startTest();
            SchedulableContext sc = null;
            DealerDocTimeStampBatch batch = new DealerDocTimeStampBatch();
            Batch.execute(sc);
        Test.stopTest();

        testAcct = [SELECT Id, Required_Docs_Uploaded__c FROM Account];
        testDoc1 = [SELECT Id, CreatedDate FROM Dealer_Docs__c WHERE RecordType.DeveloperName = 'Dealer_License' AND License_Number__c = '11111'];
        testDoc3 = [SELECT Id, CreatedDate FROM Dealer_Docs__c WHERE RecordType.DeveloperName = 'Dealer_License' AND License_Number__c = '33333'];
        System.assertNotEquals(null, testAcct.Required_Docs_Uploaded__c);
        System.assertEquals(true, (testAcct.Required_Docs_Uploaded__c > utcToEST(testDoc1.CreatedDate))); //greater than the created date of the first doc
        System.assertEquals(true, (testAcct.Required_Docs_Uploaded__c < utcToEST(testDoc3.CreatedDate))); //less than the created date of the third doc
    }
}