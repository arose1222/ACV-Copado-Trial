@isTest
public class DealerDocComplianceTest {
    
    public static boolean BatchTestFlag = FALSE;
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        insert u1;

        Account a = new Account(); 
        a.Name = 'Smith Dealerships';
        a.Phone = '1234567890';
        a.IST_Account_Owner__c = u1.Id;
        a.legal_Name__c = 'Smith Dealerships';
        a.Dealer_Type__c = '1';
        a.Dealership_Id__c = '1234';
        a.BillingStreet='158 main st'; 
        a.BillingState='NY';
        a.BillingCity='Buffalo';
        a.BillingPostalCode='14214' ;
        a.BillingCountry='US';
        insert a;
        Contact c = TestUtility.createContact(a);
        insert c;
        Affiliation__c aff = TestUtility.createAffiliation( a, c );
        insert aff;
    }

    @isTest
    static void makeResaleDoc() {
        Account testAcct = [ SELECT Id FROM Account Where Name = 'Smith Dealerships' ];

        Dealer_Docs__c resaleDoc = new Dealer_Docs__c();
        resaleDoc.Account__c = testAcct.Id;
        resaleDoc.RecordTypeId = resaleId;
        resaleDoc.Document_State__c = 'AL';
        resaleDoc.No_Expiration__c = TRUE;
        resaleDoc.Permit_Resale_Number__c = '1';

        Test.startTest();

            resaleDoc.Review_Status__c = 'Complete';
            resaleDoc.Compliant__c = TRUE;
            insert resaleDoc;

        Test.stopTest();

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( testAcct.Compliant_Resale_Certificate__c );
    }

    @isTest
    static void makeDealerDoc() {
        Account testAcct = [ SELECT Id FROM Account Where Name = 'Smith Dealerships' ];

        Dealer_Docs__c dealerDoc = new Dealer_Docs__c();
        dealerDoc.Account__c = testAcct.Id;
        dealerDoc.RecordTypeId = licenseId;
        dealerDoc.Document_State__c = 'AL';
        dealerDoc.License_Number__c = '1';
        dealerDoc.Expiration_Date__c = Date.today().addDays( 30 );

        Test.startTest();

            dealerDoc.Review_Status__c = 'Complete';
            dealerDoc.Compliant__c = TRUE;
            insert dealerDoc;

        Test.stopTest();

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( testAcct.Compliant_Dealer_License__c );
    }

    @isTest
    static void updateResaleDoc() {
        Account testAcct = [ SELECT Id FROM Account Where Name = 'Smith Dealerships' ];

        Dealer_Docs__c resaleDoc = new Dealer_Docs__c();
        resaleDoc.Account__c = testAcct.Id;
        resaleDoc.RecordTypeId = resaleId;
        resaleDoc.Document_State__c = 'AL';
        resaleDoc.No_Expiration__c = TRUE;
        resaleDoc.Permit_Resale_Number__c = '1';
        resaleDoc.Review_Status__c = 'Ready for Review';

        insert resaleDoc;

        Test.startTest();

            resaleDoc.Review_Status__c = 'Complete';
            resaleDoc.Compliant__c = TRUE;
            update resaleDoc;

        Test.stopTest();

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( testAcct.Compliant_Resale_Certificate__c );
    }

    @isTest
    static void updateDealerDoc() {
        Account testAcct = [ SELECT Id FROM Account Where Name = 'Smith Dealerships' ];

        Dealer_Docs__c dealerDoc = new Dealer_Docs__c();
        dealerDoc.Account__c = testAcct.Id;
        dealerDoc.RecordTypeId = licenseId;
        dealerDoc.Document_State__c = 'AL';
        dealerDoc.License_Number__c = '1';
        dealerDoc.Expiration_Date__c = Date.today().addDays( 30 );
        dealerDoc.Review_Status__c = 'Ready for Review';

        insert dealerDoc;

        Test.startTest();

            dealerDoc.Review_Status__c = 'Complete';
            dealerDoc.Compliant__c = TRUE;
            update dealerDoc;

        Test.stopTest();

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( testAcct.Compliant_Dealer_License__c );
    }

    @isTest
    static void makeBadResaleDoc() {
        Account testAcct = [ SELECT Id FROM Account Where Name = 'Smith Dealerships' ];

        Dealer_Docs__c resaleDoc = new Dealer_Docs__c();
        resaleDoc.Account__c = testAcct.Id;
        resaleDoc.RecordTypeId = resaleId;
        resaleDoc.Document_State__c = 'AL';
        resaleDoc.No_Expiration__c = TRUE;
        resaleDoc.Permit_Resale_Number__c = '1';

        Test.startTest();

            resaleDoc.Review_Status__c = 'Ready for Review';
            resaleDoc.Compliant__c = FALSE;
            insert resaleDoc;

        Test.stopTest();

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( !testAcct.Compliant_Resale_Certificate__c );
    }

    @isTest
    static void makeBadDealerDoc() {
        Account testAcct = [ SELECT Id FROM Account Where Name = 'Smith Dealerships' ];

        Dealer_Docs__c dealerDoc = new Dealer_Docs__c();
        dealerDoc.Account__c = testAcct.Id;
        dealerDoc.RecordTypeId = licenseId;
        dealerDoc.Document_State__c = 'AL';
        dealerDoc.License_Number__c = '1';
        dealerDoc.Expiration_Date__c = Date.today().addDays( 30 );

        Test.startTest();

            dealerDoc.Review_Status__c = 'Ready for Review';
            dealerDoc.Compliant__c = FALSE;
            insert dealerDoc;

        Test.stopTest();

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( !testAcct.Compliant_Dealer_License__c );
    }

    @isTest
    static void updateBadResaleDoc() {
        Account testAcct = [ SELECT Id FROM Account Where Name = 'Smith Dealerships' ];

        Dealer_Docs__c resaleDoc = new Dealer_Docs__c();
        resaleDoc.Account__c = testAcct.Id;
        resaleDoc.RecordTypeId = resaleId;
        resaleDoc.Document_State__c = 'AL';
        resaleDoc.No_Expiration__c = TRUE;
        resaleDoc.Permit_Resale_Number__c = '1';
        resaleDoc.Review_Status__c = 'Ready for Review';

        insert resaleDoc;

        resaleDoc.Review_Status__c = 'Complete';
        resaleDoc.Compliant__c = TRUE;
        update resaleDoc;

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( testAcct.Compliant_Resale_Certificate__c );

        Test.startTest();

            resaleDoc.Review_Status__c = 'Ready for Review';
            resaleDoc.Compliant__c = FALSE;
            update resaleDoc;

        Test.stopTest();

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( !testAcct.Compliant_Resale_Certificate__c );
    }

    @isTest
    static void updateBadDealerDoc() {
        Account testAcct = [ SELECT Id FROM Account Where Name = 'Smith Dealerships' ];

        Dealer_Docs__c dealerDoc = new Dealer_Docs__c();
        dealerDoc.Account__c = testAcct.Id;
        dealerDoc.RecordTypeId = licenseId;
        dealerDoc.Document_State__c = 'AL';
        dealerDoc.License_Number__c = '1';
        dealerDoc.Expiration_Date__c = Date.today().addDays( 30 );
        dealerDoc.Review_Status__c = 'Ready for Review';

        insert dealerDoc;

        dealerDoc.Review_Status__c = 'Complete';
        dealerDoc.Compliant__c = TRUE;
        update dealerDoc;

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( testAcct.Compliant_Dealer_License__c );

        Test.startTest();

            dealerDoc.Review_Status__c = 'Ready for Review';
            dealerDoc.Compliant__c = FALSE;
            update dealerDoc;

        Test.stopTest();

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( !testAcct.Compliant_Dealer_License__c );
    }

     @isTest
    static void deleteResaleDoc() {
        Account testAcct = [ SELECT Id FROM Account Where Name = 'Smith Dealerships' ];

        Dealer_Docs__c resaleDoc = new Dealer_Docs__c();
        resaleDoc.Account__c = testAcct.Id;
        resaleDoc.RecordTypeId = resaleId;
        resaleDoc.Document_State__c = 'AL';
        resaleDoc.No_Expiration__c = TRUE;
        resaleDoc.Permit_Resale_Number__c = '1';
        resaleDoc.Review_Status__c = 'Complete';
        resaleDoc.Compliant__c = TRUE;
        insert resaleDoc;

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( testAcct.Compliant_Resale_Certificate__c );

        Test.startTest();

            delete resaleDoc;

        Test.stopTest();

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( !testAcct.Compliant_Resale_Certificate__c );
    }

    @isTest
    static void deleteDealerDoc() {
        Account testAcct = [ SELECT Id FROM Account Where Name = 'Smith Dealerships' ];

        Dealer_Docs__c dealerDoc = new Dealer_Docs__c();
        dealerDoc.Account__c = testAcct.Id;
        dealerDoc.RecordTypeId = licenseId;
        dealerDoc.Document_State__c = 'AL';
        dealerDoc.License_Number__c = '1';
        dealerDoc.Expiration_Date__c = Date.today().addDays( 30 );

        dealerDoc.Review_Status__c = 'Complete';
        dealerDoc.Compliant__c = TRUE;
        insert dealerDoc;

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( testAcct.Compliant_Dealer_License__c );

        Test.startTest();

            delete dealerDoc;

        Test.stopTest();

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( !testAcct.Compliant_Dealer_License__c );
    }

    @isTest
    static void runBatch() {
        Account testAcct = [ SELECT Id FROM Account Where Name = 'Smith Dealerships' ];

        List<Dealer_Docs__c> dealLst = new List<Dealer_Docs__c>();
        for ( Integer index = 0; index < 10; index++ ) {
            Dealer_Docs__c dealerDoc = new Dealer_Docs__c();
            dealerDoc.Account__c = testAcct.Id;
            dealerDoc.RecordTypeId = licenseId;
            dealerDoc.Document_State__c = 'AL';
            dealerDoc.License_Number__c = '1';
            dealerDoc.Expiration_Date__c = Date.today().addDays( 30 );
            dealerDoc.Review_Status__c = 'Complete';
            dealerDoc.Compliant__c = TRUE;
            dealLst.add( dealerDoc );
        }

        for ( Integer index = 0; index < 10; index++ ) {
            Dealer_Docs__c dealerDoc = new Dealer_Docs__c();
            dealerDoc.Account__c = testAcct.Id;
            dealerDoc.RecordTypeId = resaleId;
            dealerDoc.Document_State__c = 'AL';
            dealerDoc.Permit_Resale_Number__c = '1';
            dealerDoc.No_Expiration__c = TRUE;
            dealerDoc.Review_Status__c = 'Complete';
            dealerDoc.Compliant__c = TRUE;
            dealLst.add( dealerDoc );
        }

        insert dealLst;

        Test.startTest();
            Database.executeBatch( new DealerDocComplianceBatch(), 200 );
        Test.stopTest();

        testAcct = [ SELECT Id, Compliant_Resale_Certificate__c, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        system.assert( testAcct.Compliant_Dealer_License__c );
        system.assert( testAcct.Compliant_Resale_Certificate__c );
    }
    
    @isTest
    static void runErrorBatch() {
        Account testAcct = [ SELECT Id FROM Account Where Name = 'Smith Dealerships' ];

        List<Dealer_Docs__c> dealLst = new List<Dealer_Docs__c>();
        for ( Integer index = 0; index < 10; index++ ) {
            Dealer_Docs__c dealerDoc = new Dealer_Docs__c();
            dealerDoc.Account__c = testAcct.Id;
            dealerDoc.RecordTypeId = licenseId;
            dealerDoc.Document_State__c = 'AL';
            dealerDoc.License_Number__c = '1';
            dealerDoc.Expiration_Date__c = Date.today().addDays( 30 );
            dealerDoc.Review_Status__c = 'Complete';
            dealerDoc.Compliant__c = TRUE;
            dealLst.add( dealerDoc );
        }

        for ( Integer index = 0; index < 10; index++ ) {
            Dealer_Docs__c dealerDoc = new Dealer_Docs__c();
            dealerDoc.Account__c = testAcct.Id;
            dealerDoc.RecordTypeId = resaleId;
            dealerDoc.Document_State__c = 'AL';
            dealerDoc.Permit_Resale_Number__c = '1';
            dealerDoc.No_Expiration__c = TRUE;
            dealerDoc.Review_Status__c = 'Complete';
            dealerDoc.Compliant__c = TRUE;
            dealLst.add( dealerDoc );
        }

        insert dealLst;

        testAcct.Compliant_Dealer_License__c = false;
        testAcct.Compliant_Resale_Certificate__c = false;
        update testAcct;

        Test.startTest();
            DealerDocComplianceBatch batch = new DealerDocComplianceBatch();
            DealerDocComplianceTest.BatchTestFlag = TRUE;
            Database.executeBatch( batch, 200 );
        Test.stopTest();

        System.assertEquals( 1, DealerDocComplianceBatch.errorLst.size(), 'The number of errors reported in the batch was unexpected' );
    }

    @isTest
    static void deletingCompliantDoc() { //if one doc is compliant and then deleted (no other docs), make sure checkbox is false
        Account testAcct = [SELECT Id FROM Account LIMIT 1];
        Date expDate = System.Today().addMonths(5);
        Dealer_Docs__c testDoc = new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = true);
        insert testDoc;
        
        testAcct = [ SELECT Id, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        System.assert(testAcct.Compliant_Dealer_License__c);

        Test.startTest();
            delete testDoc;
        Test.stopTest();

        testAcct = [ SELECT Id, Compliant_Dealer_License__c FROM Account LIMIT 1 ];
        System.assert(!testAcct.Compliant_Dealer_License__c);
    }

    @isTest
    static void deleteCompliantWithOthersPresent() { //deleting a compliant doc with other compliant docs in the system should leave box checked
        Account testAcct = [SELECT Id FROM Account LIMIT 1];
        Date expDate = System.Today().addMonths(5);
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '22222', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '44444', Expiration_Date__c = expDate, Compliant__c = true));
        insert docList;

        List<Dealer_Docs__c> delList = [SELECT Id FROM Dealer_Docs__c WHERE Permit_Resale_Number__c = '33333' OR License_Number__c = '44444'];

        testAcct = [SELECT Id, Compliant_Dealer_License__c, Compliant_Resale_Certificate__c FROM Account LIMIT 1];
        System.assert(testAcct.Compliant_Dealer_License__c);
        System.assert(testAcct.Compliant_Resale_Certificate__c);

        Test.startTest();
            delete delList;
        Test.stopTest();

        testAcct = [SELECT Id, Compliant_Dealer_License__c, Compliant_Resale_Certificate__c FROM Account LIMIT 1];
        System.assert(testAcct.Compliant_Dealer_License__c);
        System.assert(testAcct.Compliant_Resale_Certificate__c);
    }

    @isTest
    static void deleteCompliantWithNonPresent() { //deleting a compliant doc with other, non-compliant, docs shoudl uncheck the box
        Account testAcct = [SELECT Id FROM Account LIMIT 1];
        Date expDate = System.Today().addMonths(5);
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = false));
        insert docList;

        testAcct = [SELECT Id, Compliant_Resale_Certificate__c FROM Account LIMIT 1];
        System.assert(testAcct.Compliant_Resale_Certificate__c);

        Test.startTest();
            delete docList[0];
        Test.stopTest();

        testAcct = [SELECT Id, Compliant_Resale_Certificate__c FROM Account LIMIT 1];
        System.assert(!testAcct.Compliant_Resale_Certificate__c);
    }

    @isTest
    static void dontUncheckResaleForSpecialStates() {
        Account testAcct = [SELECT Id FROM Account LIMIT 1];
        Date expDate = System.Today().addMonths(5);
        Dealer_Docs__c newDoc = new Dealer_Docs__c(Account__c = testAcct.Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_NUmber__c = '11111', Expiration_Date__c = expDate, Compliant__c = true);
        insert newDoc;

        testAcct = [SELECT Id, Compliant_Dealer_License__c, Compliant_Resale_Certificate__c FROM Account LIMIT 1];
        System.assert(testAcct.Compliant_Dealer_License__c);
        System.assert(testAcct.Compliant_Resale_Certificate__c);

        Test.startTest();
            Database.executeBatch( new DealerDocComplianceBatch(), 200 );
        Test.stopTest();

        testAcct = [SELECT Id, Compliant_Dealer_License__c, Compliant_Resale_Certificate__c FROM Account LIMIT 1];
        System.assert(testAcct.Compliant_Dealer_License__c); //make sure they haven't changed
        System.assert(testAcct.Compliant_Resale_Certificate__c); //make sure they haven't changed
    }
}