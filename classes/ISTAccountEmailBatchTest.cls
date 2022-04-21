@isTest
public class ISTAccountEmailBatchTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    @isTest
    static void batchTestIST() {
        //will i need a user? or can i fudge with like test@test.com for an email?
        //need some accounts - 4? one with multiple docs, two with one doc, one correct and one not, and one account with no docs
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Account1', Dealer_Type__c='1', phone='1234567890', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Account2', Dealer_Type__c='1', phone='1234567890', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account(Name = 'Account3', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Account3', Dealer_Type__c='1', phone='1234567890', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account(Name = 'Account4', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Account4', Dealer_Type__c='1', phone='1234567890', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        insert accountList;

        Contact c = TestUtility.createContact(accountList[0]);
        insert c;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( accountList[0], c );
        affList.add( aff );
        Affiliation__c aff1 = TestUtility.createAffiliation( accountList[1], c );
        affList.add( aff1 );
        Affiliation__c aff2 = TestUtility.createAffiliation( accountList[2], c );
        affList.add( aff2 );
        Affiliation__c aff3 = TestUtility.createAffiliation( accountList[3], c );
        affList.add( aff3 );
        insert affList;
        //make four dates - i'm literally only doing this so i have a way to order the docs at the end
        Date expDate7 = System.Today().addMonths(7);
        Date expDate6 = System.Today().addMonths(6);
        Date expDate5 = System.Today().addMonths(5);
        Date expDate4 = System.Today().addMonths(4);
        //4 docs
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        //need some docs for one of the accounts with the correct IST account email, one without
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '11111', Expiration_Date__c = expDate7, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '22222', Expiration_Date__c = expDate6, Compliant__c = true));
        //need a doc for an account that will be correct
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33333', Expiration_Date__c = expDate5, Compliant__c = true));
        //need a doc for an account that will be incorrect
        docList.add(new Dealer_Docs__c(Account__c = accountList[2].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '44444', Expiration_Date__c = expDate4, Compliant__c = true));
        insert docList;
        //will have to try and update the email field to the incorrect info after because it will auto-populate correctly
        for (Dealer_Docs__c d : docList) {
            if (d.License_Number__c == '11111' || d.Permit_Resale_Number__c == '44444') {
                d.IST_Account_Manager_Email__c = 'test@test.com'; //going to try this to see if i can get away with not creating a test user
            }
        }
        //update docs
        update docList;

        //run batch
        //start test
        Test.startTest();
        //run batch
            SchedulableContext sc = null;
            ISTAccountEmailBatch batch = new ISTAccountEmailBatch();
            Batch.execute(sc);
        //stop test
        Test.stopTest();

        //query
        List<Dealer_Docs__c> checkDocList = [SELECT Id, RecordTypeId, License_Number__c, Permit_Resale_Number__c, IST_Account_Manager_Email__c, TM_Email__c FROM Dealer_Docs__c ORDER BY Expiration_Date__c DESC];
        //system.asserts
        System.assertEquals(UserInfo.getUserEmail(), checkDocList[0].IST_Account_Manager_Email__c);
        System.assertEquals(UserInfo.getUserEmail(), checkDocList[1].IST_Account_Manager_Email__c);
        System.assertEquals(UserInfo.getUserEmail(), checkDocList[2].IST_Account_Manager_Email__c);
        System.assertEquals(UserInfo.getUserEmail(), checkDocList[3].IST_Account_Manager_Email__c);
    }

    @isTest
    static void batchTestTM() {
        //will i need a user? or can i fudge with like test@test.com for an email?
        //need some accounts - 4? one with multiple docs, two with one doc, one correct and one not, and one account with no docs
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Account1', Dealer_Type__c='1', phone='1234567890', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Account2', Dealer_Type__c='1', phone='1234567890', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account(Name = 'Account3', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Account3', Dealer_Type__c='1', phone='1234567890', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account(Name = 'Account4', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c='Account4', Dealer_Type__c='1', phone='1234567890', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        insert accountList;

        Contact c = TestUtility.createContact(accountList[0]);
        insert c;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( accountList[0], c );
        affList.add( aff );
        Affiliation__c aff1 = TestUtility.createAffiliation( accountList[1], c );
        affList.add( aff1 );
        Affiliation__c aff2 = TestUtility.createAffiliation( accountList[2], c );
        affList.add( aff2 );
        Affiliation__c aff3 = TestUtility.createAffiliation( accountList[3], c );
        affList.add( aff3 );
        insert affList;
        //make four dates - i'm literally only doing this so i have a way to order the docs at the end
        Date expDate7 = System.Today().addMonths(7);
        Date expDate6 = System.Today().addMonths(6);
        Date expDate5 = System.Today().addMonths(5);
        Date expDate4 = System.Today().addMonths(4);
        //4 docs
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        //need some docs for one of the accounts with the correct IST account email, one without
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '11111', Expiration_Date__c = expDate7, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '22222', Expiration_Date__c = expDate6, Compliant__c = true));
        //need a doc for an account that will be correct
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33333', Expiration_Date__c = expDate5, Compliant__c = true));
        //need a doc for an account that will be incorrect
        docList.add(new Dealer_Docs__c(Account__c = accountList[2].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '44444', Expiration_Date__c = expDate4, Compliant__c = true));
        insert docList;
        //will have to try and update the email field to the incorrect info after because it will auto-populate correctly
        for (Dealer_Docs__c d : docList) {
            if (d.License_Number__c == '11111' || d.Permit_Resale_Number__c == '44444') {
                d.TM_Email__c = 'test@test.com'; //going to try this to see if i can get away with not creating a test user
            }
        }
        //update docs
        update docList;

        //run batch
        //start test
        Test.startTest();
        //run batch
            SchedulableContext sc = null;
            ISTAccountEmailBatch batch = new ISTAccountEmailBatch();
            Batch.execute(sc);
        //stop test
        Test.stopTest();

        //query
        List<Dealer_Docs__c> checkDocList = [SELECT Id, RecordTypeId, License_Number__c, Permit_Resale_Number__c, IST_Account_Manager_Email__c, TM_Email__c FROM Dealer_Docs__c ORDER BY Expiration_Date__c DESC];
        //system.asserts
        System.assertEquals(UserInfo.getUserEmail(), checkDocList[0].TM_Email__c);
        System.assertEquals(UserInfo.getUserEmail(), checkDocList[1].TM_Email__c);
        System.assertEquals(UserInfo.getUserEmail(), checkDocList[2].TM_Email__c);
        System.assertEquals(UserInfo.getUserEmail(), checkDocList[3].TM_Email__c);
    }

    //@isTest
    static void bulkTest() {
        //create a date
        Date past = System.Today().addMonths(-5);
        //create some accounts
        List<Account> accountList = new List<Account>();
        for (Integer i = 0; i < 50; i ++) {
            accountList.add(new Account(Name = 'Account' + i, legal_Name__c='Account' + i, dealer_type__c='1',phone='1234567890',IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '1' + i, Active__c = true,BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='1421' + i, BillingCountry='US'));
        }
        //insert account
        insert accountList;
        //create 200 dealer docs
        List<Dealer_Docs__c> bulkDocs = new List<Dealer_Docs__c>();
        for (Integer i = 0; i < 50; i ++) {
            bulkDocs.add(new Dealer_Docs__c(Account__c = accountList[i].Id, Expiration_Date__c = past, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '11111'));
        }
        //insert docs
        insert bulkDocs;
        //update docs to have incorrect email data
        for (Dealer_Docs__c d : bulkDocs) {
            d.TM_Email__c = 'test@test.com';
            d.IST_Account_Manager_Email__c = 'test@test.com';
        }
        update bulkDocs;
        //run through batch
        //start test
        Test.startTest();
        //run batch
            SchedulableContext sc = null;
            ISTAccountEmailBatch batch = new ISTAccountEmailBatch();
            Batch.execute(sc);
        //stop test
        Test.stopTest();
        //test "pass" condition is: no errors thrown
    }

    // @isTest
    // static void errorCheck() {
    //     Account newAccount = new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId());
    //     insert newAccount;
    //     Date expDate = System.Today().addMonths(5);
    //     Dealer_Docs__c newDoc = new Dealer_Docs__c(Account__c = newAccount.Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = true);
    //     insert newDoc;
    //     //run through batch with an error
    //     //start test
    //     Test.startTest();
    //     //run batch
    //         SchedulableContext sc = null;
    //         ISTAccountEmailBatch ISTbatch = new ISTAccountEmailBatch();
    //         ISTbatch.errorList.add('error');
    //         ISTbatch.execute(sc);
    //     //stop test
    //     Test.stopTest();
    // }
}