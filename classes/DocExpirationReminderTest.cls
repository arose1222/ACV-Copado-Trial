@isTest
public class DocExpirationReminderTest {
  
    //get record type ids
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    @TestSetup
    static void makeData() {
        //need afew accounts - deleteTest()
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'AccountDelete1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave')); //this one will have a dealer license in a special state that gets deleted
        accountList.add(new Account(Name = 'AccountDelete2', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave')); //this one will have a license and resale that get deleted
        accountList.add(new Account(Name = 'AccountDelete3', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave')); //this will have two licenses and only one gets deleted
        accountList.add(new Account(Name = 'AccountDelete4', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave')); //this will have two licenses and two resale certs, one of each will get deleted

        //accounts for activeStatusInsertTest()
        //need some accounts - one inactive blacklisted, one inactive incomplete, one inactive null, one active (for control)
        accountList.add(new Account(Name = 'AccountASI1', IST_Account_Owner__c = UserInfo.getUserId(), Inactive_Sub_Status__c = '5', Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'AccountASI2', IST_Account_Owner__c = UserInfo.getUserId(), Inactive_Sub_Status__c = '1', Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'AccountASI3', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'AccountASI4', IST_Account_Owner__c = UserInfo.getUserId(), Active__c = true, Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));

        //accounts for activeStatusUpdateTest()
        //need some accounts - one inactive non-payment, one inactive dealer docs out of compliance, one inactive null, one active (for control)
        accountList.add(new Account(Name = 'AccountASU1', IST_Account_Owner__c = UserInfo.getUserId(), Inactive_Sub_Status__c = '7', Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'AccountASU2', IST_Account_Owner__c = UserInfo.getUserId(), Inactive_Sub_Status__c = '8', Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'AccountASU3', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'AccountASU4', IST_Account_Owner__c = UserInfo.getUserId(), Active__c = true, Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        insert accountList;

        Contact c = TestUtility.createContact(accountList[0]);
        insert c;

        //deleteTest()
        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( accountList[0], c );
        affList.add( aff );
        Affiliation__c aff1 = TestUtility.createAffiliation( accountList[1], c );
        affList.add( aff1 );
        Affiliation__c aff2 = TestUtility.createAffiliation( accountList[2], c );
        affList.add( aff2 );
        Affiliation__c aff3 = TestUtility.createAffiliation( accountList[3], c );
        affList.add( aff3 );
        
        //activeStatusInsert() 
        Affiliation__c aff4 = TestUtility.createAffiliation( accountList[4], c );
        affList.add( aff4 );
        Affiliation__c aff5 = TestUtility.createAffiliation( accountList[5], c );
        affList.add( aff5 );
        Affiliation__c aff6 = TestUtility.createAffiliation( accountList[6], c );
        affList.add( aff6 );
        Affiliation__c aff7 = TestUtility.createAffiliation( accountList[7], c );
        affList.add( aff7 );

        //activeStatusUpdate()
        Affiliation__c aff8 = TestUtility.createAffiliation( accountList[8], c );
        affList.add( aff8 );
        Affiliation__c aff9 = TestUtility.createAffiliation( accountList[9], c );
        affList.add( aff9 );
        Affiliation__c aff10 = TestUtility.createAffiliation( accountList[10], c );
        affList.add( aff10 );
        Affiliation__c aff11 = TestUtility.createAffiliation( accountList[11], c );
        affList.add( aff11 );
        insert affList;

        Date expDate = System.Today().addMonths(5);
        
        //deleteTest()
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '22222', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[2].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '44444', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[2].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '55555', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[3].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '66666', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[3].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '77777', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[3].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '88888', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[3].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '99999', Expiration_Date__c = expDate, Compliant__c = true));

        //docs for activeStatusInsertTest() - need four DE licenses to be inserted, one for each account
        docList.add(new Dealer_Docs__c(Account__c = accountList[4].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[5].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '22222', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[6].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[7].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '44444', Expiration_Date__c = expDate, Compliant__c = true));

        //docs for activeStatusUpdateTest() - need four DE licenses to be inserted, one for each account (all out of compliance to start)
        docList.add(new Dealer_Docs__c(Account__c = accountList[8].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = false));
        docList.add(new Dealer_Docs__c(Account__c = accountList[9].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '22222', Expiration_Date__c = expDate, Compliant__c = false));
        docList.add(new Dealer_Docs__c(Account__c = accountList[10].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = false));
        docList.add(new Dealer_Docs__c(Account__c = accountList[11].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '44444', Expiration_Date__c = expDate, Compliant__c = false));
        insert docList;
        
    }

    @isTest
    static void insertTest() { //this test checks basic functionality of inserting a document       
        Test.startTest();
        //create two accounts
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        insert accountList;

        Contact c = TestUtility.createContact(accountList[0]);
        insert c;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( accountList[0], c );
        affList.add( aff );
        Affiliation__c aff1 = TestUtility.createAffiliation( accountList[1], c );
        affList.add( aff1 );
        insert affList;
        //create expiration date
        Date expDate = System.Today().addMonths(5);
        Date testDate = System.Today().addMonths(5).addDays(-14);
        //create 3 dealer docs
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>(); //can i just do record type?
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'NY', Permit_Resale_Number__c = '22222', No_Expiration__c = true, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'NY', License_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33332', Expiration_Date__c = expDate, Compliant__c = true));
        //insert docs
        insert docList;

        Dealer_Docs__c failDoc1 = new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'NY', Permit_Resale_Number__c = '22222', No_Expiration__c = false, Expiration_Date__c = null);
        String failDoc1Str = '';
        try {
            insert failDoc1;
        } catch (Exception e) {
            failDoc1Str = e.getMessage();
        }
        Dealer_Docs__c failDoc2 = new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'VT', License_Number__c = '22222', No_Expiration__c = false, MTC__c = false);
        String failDoc2Str = '';
        try {
            insert failDoc2;
        } catch (Exception exce) {
            failDoc2Str = exce.getMessage();
        }
        Test.stopTest();
        //check if the two relevant fields are populated
        List<Dealer_Docs__c> resale = [SELECT IST_Account_Manager_Email__c FROM Dealer_Docs__c WHERE RecordType.DeveloperName = 'Resale_Certificate']; //Expiration_Reminder_Date__c
        List<Dealer_Docs__c> license = [SELECT IST_Account_Manager_Email__c FROM Dealer_Docs__c WHERE RecordType.DeveloperName = 'Dealer_License' ORDER BY License_Number__c DESC]; //Expiration_Reminder_Date__c
        List<Account> accountInfo = [SELECT Dealer_Doc_Compliance__c FROM Account WHERE Name = 'Account1' OR Name = 'Account2' ORDER BY Name ASC];

        String failCheck1 = 'Please mark the \'No Expiration\' field as true for this record.';
        String failCheck2 = 'Please mark the \'No Expiration\' field as true for this record.';

        //System.assertNotEquals(null, resale[0].IST_Account_Manager_Email__c); //no longer populated right away
        //System.assertEquals(null, resale[0].Expiration_Reminder_Date__c);
        //System.assertNotEquals(null, license[0].IST_Account_Manager_Email__c); //no longer populated right away
        //System.assertEquals(testDate, license[0].Expiration_Reminder_Date__c);
        //System.assertNotEquals(null, license[1].IST_Account_Manager_Email__c); //no longer populated right away
        //System.assertEquals(testDate, license[1].Expiration_Reminder_Date__c);
        System.assertEquals('Compliant', accountInfo[0].Dealer_Doc_Compliance__c);
        System.assertEquals('Compliant', accountInfo[1].Dealer_Doc_Compliance__c);
        //failed doc asserts
        System.assertEquals(failDoc1Str.contains('Please mark the \'No Expiration\' field as true for this record.'), failCheck1.contains('Please mark the \'No Expiration\' field as true for this record.'));
        System.assertEquals(failDoc2Str.contains('Please mark the \'No Expiration\' field as true for this record.'), failCheck2.contains('Please mark the \'No Expiration\' field as true for this record.'));
    }

    @isTest
    static void updateTest() { //this test checks basic functionality of updating a document
        Test.startTest();
        //create three accounts
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account3', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
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
        insert affList;
        //create expiration date
        Date expDate = System.Today().addMonths(5);
        Date testDate = System.Today().addMonths(5).addDays(-14);
        Date oldDate = System.Today().addMonths(-1);
        //create 3 dealer docs
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'NY', Permit_Resale_Number__c = '22222', No_Expiration__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'NY', License_Number__c = '33333', Expiration_Date__c = expDate));
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33332', Expiration_Date__c = expDate));
        docList.add(new Dealer_Docs__c(Account__c = accountList[2].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '55555', Expiration_Date__c = oldDate, Document_Expired__c = true));
        //insert docs
        insert docList;
        //get docs and update them to be compliant
        List<Dealer_Docs__c> updateDocs = [SELECT Compliant__c, License_Number__c, Expiration_Date__c FROM Dealer_Docs__c];
        for (Dealer_Docs__c d : updateDocs) {
            if (d.License_Number__c == '55555') {
                d.Compliant__c = true;
                d.Expiration_Date__c = expDate; //going to insert as a past date and then update to a new date and compliant to test document_expired checkbox
            }
            else {
                d.Compliant__c = true;
            }
        }
        //update docs
        update updateDocs;
        Test.stopTest();
        //query
        List<Account> checkAccounts = [SELECT Dealer_Doc_Compliance__c FROM Account WHERE Name = 'Account1' OR Name ='Account2' OR Name = 'Account3' ORDER BY Name ASC];
        List<Dealer_Docs__c> checkDocs = [SELECT Id, Document_Expired__c FROM Dealer_Docs__c WHERE License_Number__c = '55555' AND (Account__r.Name = 'Account1' OR Account__r.Name = 'Account2' OR Account__r.Name = 'Account3')];
        //system.asserts
        System.assertEquals('Compliant', checkAccounts[0].Dealer_Doc_Compliance__c);
        System.assertEquals('Compliant', checkAccounts[1].Dealer_Doc_Compliance__c);
        System.assertEquals(false, checkDocs[0].Document_Expired__c);
    }

    @isTest
    static void updateNegativeTest() {  //this test checks that propper errors are thrown when you try to update a doc to a failing condition
        Test.startTest();
        //create two accounts
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        insert accountList;

        Contact c = TestUtility.createContact(accountList[0]);
        insert c;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( accountList[0], c );
        affList.add( aff );
        Affiliation__c aff1 = TestUtility.createAffiliation( accountList[1], c );
        affList.add( aff1 );
        insert affList;
        //create expiration date
        Date expDate = System.Today().addMonths(5);
        Date testDate = System.Today().addMonths(5).addDays(-14);
        //create 3 dealer docs
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'NY', Permit_Resale_Number__c = '22222', No_Expiration__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'NY', License_Number__c = '33333', Expiration_Date__c = expDate));
        // DE is a state that only needs a dealer licence record to be valid 
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33332', Expiration_Date__c = expDate));
        //insert docs
        insert docList;
        //get docs and update them to be compliant
        List<Dealer_Docs__c> updateDocs = [SELECT Compliant__c, Review_Status__c FROM Dealer_Docs__c WHERE Account__r.Name = 'Account1' OR Account__r.Name = 'Account2'];
        for (Dealer_Docs__c d : updateDocs) {
            d.Compliant__c = true;
        }
        update updateDocs;
        for (Dealer_Docs__c d : updateDocs) {
            //System.debug('All docs? Should be x3 if yes');
            d.Compliant__c = false;
            d.Review_Status__c = 'Requires BDR';
        }
        //update docs
        update updateDocs;
        Test.stopTest();
        //query
        List<Account> checkAccounts = [SELECT Dealer_Doc_Compliance__c FROM Account WHERE Name = 'Account1' OR Name = 'Account2' ORDER BY Name ASC];
        //system.asserts
        System.assertEquals('Out Of Compliance', checkAccounts[0].Dealer_Doc_Compliance__c);
        System.assertEquals('Out Of Compliance', checkAccounts[1].Dealer_Doc_Compliance__c);
    }

    @isTest
    static void insertNegativeTest() {  //this test checks that propper errors are thrown when you try to insert a doc in a failing condition
        Test.startTest();
        //create two accounts
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        insert accountList;

        Contact c = TestUtility.createContact(accountList[0]);
        insert c;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( accountList[0], c );
        affList.add( aff );
        Affiliation__c aff1 = TestUtility.createAffiliation( accountList[1], c );
        affList.add( aff1 );
        insert affList;
        //create expiration date
        Date expDate = System.Today().addMonths(5);
        Date testDate = System.Today().addMonths(5).addDays(-14);
        //create 3 dealer docs
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'NY', Permit_Resale_Number__c = '22222', No_Expiration__c = true, Compliant__c = false));
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'NY', License_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = false));
        //DE is a state that only needs a Dealer License to pass this check
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33332', Expiration_Date__c = expDate, Compliant__c = false));
        //insert docs
        insert docList;

        Dealer_Docs__c failDoc1 = new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'NY', Permit_Resale_Number__c = '22222', No_Expiration__c = false, Expiration_Date__c = null);
        String failDoc1Str = '';
        try {
            insert failDoc1;
        } catch (Exception e) {
            failDoc1Str = e.getMessage();
        }
        Dealer_Docs__c failDoc2 = new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'VT', License_Number__c = '22222', No_Expiration__c = false, MTC__c = false);
        String failDoc2Str = '';
        try {
            insert failDoc2;
        } catch (Exception exce) {
            failDoc2Str = exce.getMessage();
        }
        Test.stopTest();
        //check if the two relevant fields are populated
        List<Dealer_Docs__c> resale = [SELECT IST_Account_Manager_Email__c FROM Dealer_Docs__c WHERE RecordType.DeveloperName = 'Resale_Certificate']; //Expiration_Reminder_Date__c
        List<Dealer_Docs__c> license = [SELECT IST_Account_Manager_Email__c FROM Dealer_Docs__c WHERE RecordType.DeveloperName = 'Dealer_License' ORDER BY License_Number__c DESC]; //Expiration_Reminder_Date__c
        List<Account> accountInfo = [SELECT Dealer_Doc_Compliance__c FROM Account WHERE Name = 'Account1' OR Name = 'Account2' ORDER BY Name ASC];

        String failCheck1 = 'Please mark the \'No Expiration\' field as true for this record.';
        String failCheck2 = 'Please mark the \'No Expiration\' field as true for this record.';

        //System.assertNotEquals(null, resale[0].IST_Account_Manager_Email__c); //no longer populated right away
        //System.assertEquals(null, resale[0].Expiration_Reminder_Date__c);
        //System.assertNotEquals(null, license[0].IST_Account_Manager_Email__c); //no longer populated right away
        //System.assertEquals(testDate, license[0].Expiration_Reminder_Date__c);
        //System.assertNotEquals(null, license[1].IST_Account_Manager_Email__c); //no longer populated right away
        //System.assertEquals(testDate, license[1].Expiration_Reminder_Date__c);
        System.assertEquals('Out Of Compliance', accountInfo[0].Dealer_Doc_Compliance__c);
        System.assertEquals('Out Of Compliance', accountInfo[1].Dealer_Doc_Compliance__c);
        //failed doc asserts
        System.assertEquals(failDoc1Str.contains('Please mark the \'No Expiration\' field as true for this record.'), failCheck1.contains('Please mark the \'No Expiration\' field as true for this record.'));
        System.assertEquals(failDoc2Str.contains('Please mark the \'No Expiration\' field as true for this record.'), failCheck2.contains('Please mark the \'No Expiration\' field as true for this record.'));
    }

    @isTest
    static void updateTestKeepComplianceOnDEResaleExpires() {  //this test checks that if an account with a license in a special state has a resale doc that expires, it will remain compliant
        Test.startTest();
        //create two accounts
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        insert accountList;
        Contact c = TestUtility.createContact(accountList[0]);
        insert c;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( accountList[0], c );
        affList.add( aff );
        insert affList;
        //create expiration date
        Date expDate = System.Today().addMonths(5);
        Date testDate = System.Today().addMonths(5).addDays(-14);
        //create 3 dealer docs
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        // DE is a state that only needs a dealer licence record to be valid 
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'DE', Permit_Resale_Number__c = '22222', No_Expiration__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33332', Expiration_Date__c = expDate));
        //insert docs
        insert docList;
        //get docs and update them to be compliant
        List<Dealer_Docs__c> updateDocs = [SELECT Compliant__c, RecordTypeId FROM Dealer_Docs__c WHERE Account__r.Name = 'Account1'];
        for (Dealer_Docs__c d : updateDocs) {
            d.Compliant__c = true;
        }
        update updateDocs;
        for (Dealer_Docs__c d : updateDocs) {
            if(d.RecordTypeId == resaleId){
                d.Compliant__c = false;
                d.review_status__c = 'Requires BDR';
            }
        }
        //update docs
            update updateDocs;
        Test.stopTest();
        //query
        List<Account> checkAccounts = [SELECT Dealer_Doc_Compliance__c FROM Account WHERE Name = 'Account1' ORDER BY Name ASC];
        //system.asserts
        System.assertEquals('Compliant', checkAccounts[0].Dealer_Doc_Compliance__c);
    }

    @isTest
    static void negativeValidationRuleTest() {  //this test checks that propper errors are thrown when you try to insert a doc in a failing condition (validation rule)
        //testing the validation rule fires when expected (expiration date is in past and compliant is checked)
        Test.startTest();
        //create two accounts
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        insert accountList;

        Contact c = TestUtility.createContact(accountList[0]);
        insert c;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( accountList[0], c );
        affList.add( aff );
        insert affList;
        //create expiration date
        Date expDate = System.Today().addMonths(-5);
        //create 3 dealer docs
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        // DE is a state that only needs a dealer licence record to be valid 
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33332', Expiration_Date__c = expDate, Compliant__c = true));
        //insert doc
        String failString = '';
        try {
            insert docList;
        } catch (Exception e) {
            failString = e.getMessage();
        }
        Test.stopTest();

        String failCheck = 'Cannot have an expiration date in the past if the document is compliant. Please enter the correct expiration date or do not mark this record as compliant.';
        System.assertEquals(failCheck.contains('Cannot have an expiration date in the past if the document is compliant. Please enter the correct expiration date or do not mark this record as compliant.'), failString.contains('Cannot have an expiration date in the past if the document is compliant. Please enter the correct expiration date or do not mark this record as compliant.'));
    }

    @isTest
    static void handlingMultipleDocsWhenOneExpires() {  //this test checks that if an account has two licenses or two certs, if one expires, but the other is still valid, the account will remain compliant
        //need to test for an account having two valid resale docs but one is currently expiring - should not effect account compliance
        //need to test for an account having two valid licenses but one is currently expiring - should not effect account compliance
        Test.startTest();
        //need two accounts
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        insert accountList;

        Contact c = TestUtility.createContact(accountList[0]);
        insert c;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( accountList[0], c );
        affList.add( aff );
        Affiliation__c aff1 = TestUtility.createAffiliation( accountList[1], c );
        affList.add( aff1 );
        insert affList;

        //expiration date
        Date expDate = System.Today().addMonths(5);
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        //first account needs two resale certs and a dealer license
        doclist.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = true));
        doclist.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '22222', Expiration_Date__c = expDate, Compliant__c = true));
        doclist.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = true));
        //second account needs two dealer licenses in a special state
        doclist.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '44444', Expiration_Date__c = expDate, Compliant__c = true));
        doclist.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '55555', Expiration_Date__c = expDate, Compliant__c = true));
        insert docList;

        //need to get and update the two expiring docs
        List<Dealer_Docs__c> updateList = [SELECT Id, Document_Expired__c, Compliant__c, Compliance_Issues__c, Review_Status__c FROM Dealer_Docs__c WHERE (Permit_Resale_Number__c = '22222' OR License_Number__c = '44444') AND (Account__r.Name = 'Account1' OR Account__r.Name = 'Account2')];
        for (Dealer_Docs__c d : updateList) {
            d.Document_Expired__c = true;
            d.Compliant__c = false;
            d.Compliance_Issues__c = 'Document expired';
            d.Review_Status__c = null;
        }
        update updateList;
        Test.stopTest();

        //query accounts
        List<Account> checkAccountList = [SELECT Id, Dealer_Doc_Compliance__c FROM Account WHERE Name = 'Account1' OR Name = 'Account2' ORDER BY Name ASC];
        System.assertEquals('Compliant', checkAccountList[0].Dealer_Doc_Compliance__c);
        System.assertEquals('Compliant', checkAccountList[1].Dealer_Doc_Compliance__c);
    }

    @isTest
    static void handlingMultipleDocsWhenInsertingANonCompliantOne() {  //this test checks that if an account has a valid license already, but a second one is inserted as not being compliant yet, it will only use the valid doc to calculate compliance (same with resale certs)
        //basically if an account already has a resale cert or license that is valid but expiring soon 
        //and someone inserts a new one as not-compliant (before they make it compliant later)
        //it shouldn't effect compliance
        Test.startTest();
        //need two accounts
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        insert accountList;


        Contact c = TestUtility.createContact(accountList[0]);
        insert c;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( accountList[0], c );
        affList.add( aff );
        Affiliation__c aff1 = TestUtility.createAffiliation( accountList[1], c );
        affList.add( aff1 );
        insert affList;
        //expiration date
        Date expDate = System.Today().addMonths(5);
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        //one with a valid resale cert and dealer license
        doclist.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = true));
        doclist.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '22222', Expiration_Date__c = expDate, Compliant__c = true));
        //one with only a valid license in a special state
        doclist.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = true));
        //insert docs
        insert docList;

        List<Dealer_Docs__c> docListTwo = new List<Dealer_Docs__c>();
        //then insert a non-compliant resale cert for the first account
        docListTwo.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '44444', Expiration_Date__c = expDate));
        //and insert a non-compliant license for the second account
        doclistTwo.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '55555', Expiration_Date__c = expDate));
        insert docListTwo;
        Test.stopTest();
        //query for account compliance
        List<Account> checkAccountList = [SELECT Id, Dealer_Doc_Compliance__c FROM Account WHERE Name = 'Account1' OR Name = 'Account2' ORDER BY Name ASC];
        System.assertEquals('Compliant', checkAccountList[0].Dealer_Doc_Compliance__c);
        System.assertEquals('Compliant', checkAccountList[1].Dealer_Doc_Compliance__c);
    }

    @isTest
    static void markResaleCompliantOnAccountForSpecialStatesInsert() { //this test checks that the function to replace Ashley's auto-checker for Compliant_Resale_Certificate__c on account is functioning on insert
        Test.startTest();
        //need an account
        Account newAccount = new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave');
        insert newAccount;
        Contact c = TestUtility.createContact(newAccount);
        insert c;
        Affiliation__c aff = TestUtility.createAffiliation( newAccount, c );
        insert aff;
        //need a date
        Date expDate = System.Today().addMonths(5);
        //need a dealer license
        Dealer_Docs__c newDoc = new Dealer_Docs__c(Account__c = newAccount.Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = true);
        insert newDoc;
        Test.stopTest();
        //query for Compliant Resale Certificate field on account
        Account checkAccount = [SELECT Id, Compliant_Resale_Certificate__c FROM Account WHERE Name = 'Test'];
        System.assertEquals(true, checkAccount.Compliant_Resale_Certificate__c);
    }

    @isTest
    static void markResaleCompliantOnAccountForSpecialStatesUpdate() { //this test checks that the function to replace Ashley's auto-checker for Compliant_Resale_Certificate__c on account is functioning on update
        Test.startTest();
        //need an account
        Account newAccount = new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave');
        insert newAccount;
        Contact c = TestUtility.createContact(newAccount);
        insert c;
        Affiliation__c aff = TestUtility.createAffiliation( newAccount, c );
        insert aff;
        //need a date
        Date expDate = System.Today().addMonths(5);
        //need a dealer license from a non-special state
        Dealer_Docs__c newDoc = new Dealer_Docs__c(Account__c = newAccount.Id, RecordTypeId = licenseId, Document_State__c = 'AZ', License_Number__c = '11111', Expiration_Date__c = null, No_Expiration__c = true, Compliant__c = true);
        insert newDoc;
        //update doc to correct state (DE)
        newDoc.Document_State__c = 'DE';
        newDoc.Expiration_Date__c = expDate;
        newDoc.No_Expiration__c = false;
        update newDoc;
        Test.stopTest();
        //query
        Account checkAccount = [SELECT Id, Compliant_Resale_Certificate__c FROM Account WHERE Name = 'Test'];
        System.assertEquals(true, checkAccount.Compliant_Resale_Certificate__c);
    }

    @isTest
    static void dontMarkResaleCompliantForNonSpecialStates() { //this test checks that the function to replace Ashley's auto-checker for Compliant_Resale_Certificate__c on account doesn't fire when conditions are not met
        //or non-dealer liences in a special state
        Test.startTest();
        //need three accounts
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account3', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
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
        insert affList;
        //date
        Date expDate = System.Today().addMonths(5);
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        //need a reslae cert for DE
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'DE', Permit_Resale_Number__c = '11111', No_Expiration__c = true, Compliant__c = false));
        //need a dealer license for FL or something
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '22222', Expiration_Date__c = expDate, Compliant__c = true));
        //need a non-compliant dealer license in a special state
        docList.add(new Dealer_Docs__c(Account__c = accountList[2].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = false));
        insert docList;
        Test.stopTest();
        //query
        List<Account> checkAccountList = [SELECT Id, Compliant_Resale_Certificate__c FROM Account WHERE Name = 'Account1' OR Name ='Account2' OR Name = 'Account3' ORDER BY Name ASC ];
        //system.asserts
        System.assertEquals(false, checkAccountList[0].Compliant_Resale_Certificate__c);
        System.assertEquals(false, checkAccountList[1].Compliant_Resale_Certificate__c);
        System.assertEquals(false, checkAccountList[2].Compliant_Resale_Certificate__c);
    }

    @isTest
    static void changingStateToSpecial() { //this test checks that when the Document_State__c is changed, the code re-checks compliance properly
        //need an account
        Test.startTest();
        Account newAccount = new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave');
        insert newAccount;

        Contact c = TestUtility.createContact(newAccount);
        insert c;
        Affiliation__c aff = TestUtility.createAffiliation( newAccount, c );
        insert aff;
        //need a date
        Date expDate = System.Today().addMonths(5);
        //need a license in AZ
        Dealer_Docs__c newDoc = new Dealer_Docs__c(Account__c = newAccount.Id, RecordTypeId = licenseId, Document_State__c = 'AZ', License_Number__c = '11111', Expiration_Date__c = null, No_Expiration__c = true,  Compliant__c = true);
        insert newDoc;
        //update to DE
        newDoc.Document_State__c = 'DE';
        newDoc.Expiration_Date__c = expDate;
        newDoc.No_Expiration__c = false;
        update newDoc;
        Test.stopTest();
        //query
        Account checkAccount = [SELECT Id, Dealer_Doc_Compliance__c FROM Account WHERE Name = 'Test'];
        //system.asserts
        System.assertEquals('Compliant', checkAccount.Dealer_Doc_Compliance__c);
    }

    @isTest
    static void changingStateToNormal() { //this test checks that when the Document_State__c is changed, the code re-checks compliance properly
        //need an account
        Test.startTest();
        Account newAccount = new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave');
        insert newAccount;

        Contact c = TestUtility.createContact(newAccount);
        insert c;
        Affiliation__c aff = TestUtility.createAffiliation( newAccount, c );
        insert aff;
        //need a date
        Date expDate = System.Today().addMonths(5);
        //need a license in DE
        Dealer_Docs__c newDoc = new Dealer_Docs__c(Account__c = newAccount.Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = true);
        insert newDoc;
        //update to AZ
        newDoc.Document_State__c = 'AZ';
        newDoc.Expiration_Date__c = null;
        newDoc.No_Expiration__c = true;
        update newDoc;
        Test.stopTest();
        //query
        Account checkAccount = [SELECT Id, Dealer_Doc_Compliance__c FROM Account WHERE Name = 'Test'];
        //system.asserts
        System.assertEquals('Out Of Compliance', checkAccount.Dealer_Doc_Compliance__c);
    }

    @isTest
    static void handlingChangingStatesWithMultipleDocs() { //this test checks that when the Document_State__c is changed and there are multiple compliant docs, the code re-checks compliance properly
        //need an account
        Test.startTest();
        Account newAccount = new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave');
        insert newAccount;

        Contact c = TestUtility.createContact(newAccount);
        insert c;
        Affiliation__c aff = TestUtility.createAffiliation( newAccount, c );
        insert aff;
        //expiration date
        Date expDate = System.Today().addMonths(5);
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        //need two licenses
        docList.add(new Dealer_Docs__c(Account__c = newAccount.Id, RecordTypeId = licenseId, Document_State__c = 'AZ', License_Number__c = '11111', Expiration_Date__c = null, No_Expiration__c = true, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = newAccount.Id, RecordTypeId = licenseId, Document_State__c = 'AZ', License_Number__c = '22222', Expiration_Date__c = null, No_Expiration__c = true, Compliant__c = true));
        insert docList;
        Dealer_Docs__c updateDoc = [SELECT Id, Document_State__c FROM Dealer_Docs__c WHERE License_Number__c = '11111' AND Account__r.Name = 'Test']; // OR Permit_Resale_Number__c = '55555'
        updateDoc.Document_State__c = 'DE';
        updateDoc.Expiration_Date__c = expDate;
        updateDoc.No_Expiration__c = false;
        update updateDoc;
        Test.stopTest();
        //query
        List<Account> checkAccounts = [SELECT Id, Dealer_Doc_Compliance__c FROM Account WHERE Name = 'Test' ORDER BY Name ASC];
        //system.asserts
        System.assertEquals('Compliant', checkAccounts[0].Dealer_Doc_Compliance__c);
    }

    @isTest
    static void changingTypeToLicense() { //this test checks that when the RecordType is changed, the code re-checks compliance properly
        //want to have an account where they had two resale certs in FL and one was changed to a license (should become compliant)
        //want to have an account that has a resale cert that is changed to a license in DE (should become compliant)
        //want to have an account that has a resale cert that is changed to a license in FL (will remain not compliant)

        Test.startTest();
        //need three accounts
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account3', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
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
        insert affList;
        //need a date
        Date expDate = System.Today().addMonths(5);
        //need 4 resale certs
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '22222', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = resaleId, Document_State__c = 'DE', Permit_Resale_Number__c = '33333', No_Expiration__c = true, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[2].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '44444', Expiration_Date__c = expDate, Compliant__c = true));
        //doclist.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordType = 'Resale Certificate', Document_State__c = 'FL', Permit_Resale_Number__c = '22222', Expiration_Date__c = expDate, Compliant__c = true));
        insert docList;
        //change 3 to licenses
        List<Dealer_Docs__c> updateDocs = [SELECT Id, RecordTypeId, Permit_Resale_Number__c, License_Number__c, Expiration_Date__c, No_Expiration__c FROM Dealer_Docs__c WHERE Permit_Resale_Number__c != '22222' AND (Account__r.Name = 'Account1' OR Account__r.Name = 'Account2' OR Account__r.name = 'Account3')];
        for (Dealer_Docs__c d : updateDocs) {
            if (d.Permit_Resale_Number__c == '33333') {
                d.No_Expiration__c = false;
                d.Expiration_Date__c = expDate;
            }
            d.RecordTypeId = licenseId;
            d.License_Number__c = d.Permit_Resale_Number__c;
            d.Permit_Resale_Number__c = null;
        }
        update updateDocs;
        Test.stopTest();
        //query
        List<Account> checkAccounts = [SELECT Id, Dealer_Doc_Compliance__c FROM Account WHERE Name = 'Account1' OR Name = 'Account2' OR Name = 'Account3' ORDER BY Name ASC];
        //system.asserts
        System.assertEquals('Compliant', checkAccounts[0].Dealer_Doc_Compliance__c);
        System.assertEquals('Compliant', checkAccounts[1].Dealer_Doc_Compliance__c);
        System.assertEquals('Out Of Compliance', checkAccounts[2].Dealer_Doc_Compliance__c);
    }

    @isTest
    static void changingTypeToResale() { //this test checks that when the RecordType is changed, the code re-checks compliance properly
        //want to have an account with two licenses in FL and one changes to a resale (should become compliant)
        //wnat to have an account that has a license in DE that is changed to FL (should become not compliant)
        //want to have an account that has a license in FL that is changed to a resale (should remain not compliant)

        Test.startTest();
        //need three accounts
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
        accountList.add(new Account(Name = 'Account3', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'));
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
        insert affList;
        //need a date
        Date expDate = System.Today().addMonths(5);
        //need 4 dealer licenses
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '22222', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[2].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '44444', Expiration_Date__c = expDate, Compliant__c = true));
        insert docList;
        //change 3 to resale certs
        List<Dealer_Docs__c> updateDocs = [SELECT Id, RecordTypeId, Permit_Resale_Number__c, License_Number__c, Expiration_Date__c, No_Expiration__c FROM Dealer_Docs__c WHERE (Account__r.Name = 'Account1' OR Account__r.Name = 'Account2' OR Account__r.Name = 'Account3') AND License_Number__c != '22222'];
        for (Dealer_Docs__c d : updateDocs) {
            if (d.License_Number__c == '33333') {
                d.Expiration_Date__c = null;
                d.No_Expiration__c = true;
            }
            d.RecordTypeId = resaleId;
            d.Permit_Resale_Number__c = d.License_Number__c;
            d.License_Number__c = null;
        }
        update updateDocs;
        Test.stopTest();
        //query
        List<Account> checkAccounts = [SELECT Id, Dealer_Doc_Compliance__c FROM Account WHERE Name = 'Account1' OR Name = 'Account2' OR Name = 'Account3' ORDER BY Name ASC];
        //system.asserts
        System.assertEquals('Compliant', checkAccounts[0].Dealer_Doc_Compliance__c);
        System.assertEquals('Out Of Compliance', checkAccounts[1].Dealer_Doc_Compliance__c);
        System.assertEquals('Out Of Compliance', checkAccounts[2].Dealer_Doc_Compliance__c);
    }

    @isTest
    static void handlingDocsInDifferentStatesOnInsert() { //this test deals with an issues in the accountStates map on insert on docs if docs in a different state already exist
        //need an account
        Test.startTest();

        Account testAccount = new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave');
        insert testAccount;
        Contact c = TestUtility.createContact(testAccount);
        insert c;
        Affiliation__c aff = TestUtility.createAffiliation( testAccount, c );
        insert aff;
        Date expDate = System.Today().addMonths(5);
        //with a valid dealer license in DE
        Dealer_Docs__c license = new Dealer_Docs__c(Account__c = testAccount.Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '11111', Expiration_Date__c = expDate, Compliant__c = true);
        insert license;
        //then insert a not-valid resale cert in like FL or something
        Dealer_Docs__c resale = new Dealer_Docs__c(Account__c = testAccount.Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '22222', Expiration_Date__c = expDate, Compliant__c = false);
        insert resale;
        Test.stopTest();
        //is the account still marked as compliant?
        Account checkAccount = [SELECT Id, Dealer_Doc_Compliance__c FROM Account Where Name = 'Test'];
      
        System.assertEquals('Compliant', checkAccount.Dealer_Doc_Compliance__c);
    }

    // @isTest
    // static void tmEmailTest() { //NO LONGER POPULATED RIGHHT AWAY
    //     //need an account with the owner set to the person running the test
    //     Account testAccount = new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = '2', legal_name__c = 'TEST', Phone = '5555555555', BillingStreet = '123 test ave'); //not declaring Owner = 'current runner of test' because i think that is the default
    //     insert testAccount;
    //     Contact c = TestUtility.createContact(testAccount);
    //     insert c;
    //     Affiliation__c aff = TestUtility.createAffiliation( testAccount, c );
    //     insert aff;

    //     Date expDate = System.Today().addMonths(5);
    //     //need a dealer doc (actually two, one of each type)
    //     List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
    //     docList.add(new Dealer_Docs__c(Account__c = testAccount.Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33333', Expiration_Date__c = expDate, Compliant__c = true));
    //     docList.add(new Dealer_Docs__c(Account__c = testAccount.Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '22222', Expiration_Date__c = expDate, Compliant__c = false));
    //     insert docList;
    //     //check that TM_Email__c matches the email of the person running the test
   
    //     List<Dealer_Docs__c> checkDocList = [SELECT Id, TM_Email__c FROM Dealer_Docs__c];
  
    //     System.assertEquals(UserInfo.getUserEmail(), checkDocList[0].TM_Email__c);
    //     System.assertEquals(UserInfo.getUserEmail(), checkDocList[1].TM_Email__c);
    // }

    /**
     * @see https://acvauctions.atlassian.net/browse/SI-580
     */
    @isTest
    static void deleteTest() {
        Test.startTest();

        String mockMetaDataString = '';
        mockMetaDataString += 
                    '{"DeveloperName": "OrganizationUniqueIdGenerationAfterInsert", '
                    + '"NamespacePrefix": "",'
                    + '"After_Insert__c": "true", '
                    + '"sObject__c": "Account", "Class_Name__c": "OrganizationUniqueIdGeneration"},'
                    + '{"DeveloperName": "DocExpirationReminderBeforeDelete", '
                    + '"NamespacePrefix": "",'
                    + '"Before_Delete__c": "true", '
                    + '"sObject__c": "Dealer_Docs__c", "Class_Name__c": "DocExpirationReminder"},';
        mockMetaDataString = '[' + mockMetaDataString.substringBeforeLast(',') + ']';
        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>) JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);

        Set<String> licensesToDelete = new Set<String>{'11111', '22222', '55555', '88888'};
        Set<String> resaleToDelete = new Set<String>{'33333', '99999'};

        List<Dealer_Docs__c> deleteList = new List<Dealer_Docs__c>();

        List<Dealer_Docs__c> docList = [ SELECT RecordTypeId, Permit_Resale_Number__c, License_Number__c FROM Dealer_Docs__c WHERE Account__r.Name = 'AccountDelete1' OR Account__r.Name = 'AccountDelete2' OR Account__r.Name = 'AccountDelete3' OR Account__r.Name = 'AccountDelete4' ORDER BY Account__r.Name ASC];

        for (Dealer_Docs__c d : docList) {
            if (d.RecordTypeId == licenseId && licensesToDelete.contains(d.License_Number__c)) {
                deleteList.add(d);
            }
            else if (d.RecordTypeId == resaleId && resaleToDelete.contains(d.Permit_Resale_Number__c)) {
                deleteList.add(d);
            }
        }
        
        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>) JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);
        delete deleteList;
        Test.stopTest();

        List<Account> checkAccountList = [SELECT Dealer_Doc_Compliance__c FROM Account WHERE Name = 'AccountDelete1' OR Name = 'AccountDelete2' OR Name = 'AccountDelete3' OR Name = 'AccountDelete4' ORDER BY Name ASC];
        System.assertEquals('Out Of Compliance', checkAccountList[0].Dealer_Doc_Compliance__c);
        System.assertEquals('Out Of Compliance', checkAccountList[1].Dealer_Doc_Compliance__c);
        System.assertEquals('Compliant', checkAccountList[2].Dealer_Doc_Compliance__c);
        System.assertEquals('Compliant', checkAccountList[3].Dealer_Doc_Compliance__c);
    }

    /** 
     * @see https://acvauctions.atlassian.net/browse/SI-581
     */
    @isTest
    static void activeStatusInsertTest() {

        String mockMetaDataString = '';
            mockMetaDataString += 
                        '{"DeveloperName": "OrganizationUniqueIdGenerationAfterInsert", '
                        + '"NamespacePrefix": "",'
                        + '"After_Insert__c": "true", '
                        + '"sObject__c": "Account", "Class_Name__c": "OrganizationUniqueIdGeneration"},'
                        + '{"DeveloperName": "DocExpirationReminderBeforeInsert", '
                        + '"NamespacePrefix": "",'
                        + '"Before_Insert__c": "true", '
                        + '"sObject__c": "Dealer_Docs__c", "Class_Name__c": "DocExpirationReminder"},';
            mockMetaDataString = '[' + mockMetaDataString.substringBeforeLast(',') + ']';
            TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>) JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);

        List<Account> accountList = new List<Account>();    
        //query for accounts
        accountList = [SELECT Active__c, Inactive_Sub_Status__c FROM Account WHERE Name = 'AccountASI1' OR Name = 'AccountASI2' OR Name = 'AccountASI3' OR Name = 'AccountASI4' ORDER BY Name ASC ];
        
        //system.asserts
        System.assertEquals(false, accountList[0].Active__c); //first account shouldn't change
        System.assertEquals('5', accountList[0].Inactive_Sub_Status__c);
        System.assertEquals(true, accountList[1].Active__c); //second account should become active
        System.assertEquals(null, accountList[1].Inactive_Sub_Status__c);
        System.assertEquals(true, accountList[2].Active__c); //third account should become active
        System.assertEquals(null, accountList[2].Inactive_Sub_Status__c);
        System.assertEquals(true, accountList[3].Active__c); //fourth account shouldn't change
        System.assertEquals(null, accountList[3].Inactive_Sub_Status__c);
    }

    /** 
     * @see https://acvauctions.atlassian.net/browse/SI-577
     */
    @isTest
    static void activeStatusUpdateTest() {
    Test.startTest();

    String mockMetaDataString = '';
            mockMetaDataString += 
                        '{"DeveloperName": "OrganizationUniqueIdGenerationAfterInsert", '
                        + '"NamespacePrefix": "",'
                        + '"After_Insert__c": "true", '
                        + '"sObject__c": "Account", "Class_Name__c": "OrganizationUniqueIdGeneration"},'
                        + '{"DeveloperName": "DocExpirationReminderBeforeUpdate", '
                        + '"NamespacePrefix": "",'
                        + '"Before_Update__c": "true", '
                        + '"sObject__c": "Dealer_Docs__c", "Class_Name__c": "DocExpirationReminder"},';
            mockMetaDataString = '[' + mockMetaDataString.substringBeforeLast(',') + ']';
            TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>) JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);

        //need a date in the future
        Date expDate = System.Today().addMonths(5);
        List<Account> accountList = new List<Account>();
        accountList = [SELECT Active__c, Inactive_Sub_Status__c FROM Account WHERE Name = 'AccountASU1' OR Name = 'AccountASU2' OR Name = 'AccountASU3' OR Name = 'AccountASU4' ORDER BY Name ASC];

        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList = [SELECT Account__c, Compliant__c FROM Dealer_Docs__c WHERE Account__c IN :accountList];

        for (Dealer_Docs__c d : docList) {
            d.Compliant__c = true;
        }
        
        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>) JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);
        update docList;

    Test.stopTest();

        //query for accounts
        accountList = [SELECT Active__c, Inactive_Sub_Status__c FROM Account WHERE Name = 'AccountASU1' OR Name = 'AccountASU2' OR Name = 'AccountASU3' OR Name = 'AccountASU4' ORDER BY Name ASC];

        //system.asserts
        System.assertEquals(false, accountList[0].Active__c); //first account shouldn't change
        System.assertEquals('7', accountList[0].Inactive_Sub_Status__c);
        System.assertEquals(true, accountList[1].Active__c); //second account should become active
        System.assertEquals(null, accountList[1].Inactive_Sub_Status__c);
        System.assertEquals(true, accountList[2].Active__c); //third account should become active
        System.assertEquals(null, accountList[2].Inactive_Sub_Status__c);
        System.assertEquals(true, accountList[3].Active__c); //fourth account shouldn't change
        System.assertEquals(null, accountList[3].Inactive_Sub_Status__c);
    }
}