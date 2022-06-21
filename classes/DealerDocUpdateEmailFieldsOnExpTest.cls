@isTest
public class DealerDocUpdateEmailFieldsOnExpTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        //need three accounts
        List<Account> acctList = new List<Account>();
        acctList.add(TestUtility.createAccount('Test 1'));
        acctList.add(TestUtility.createAccount('Test 2'));
        acctList.add(TestUtility.createAccount('Test 3'));
        insert acctList;
        //need contacts
        List<Contact> contList = new List<Contact>();
        contList.add(TestUtility.createContact(acctList[0]));
        contList.add(TestUtility.createContact(acctList[1]));
        contList.add(TestUtility.createContact(acctList[2]));
        insert contList;
        //and affiliations
        List<Affiliation__c> affList = new List<Affiliation__c>();
        affList.add(TestUtility.createAffiliation(acctList[0], contList[0]));
        affList.add(TestUtility.createAffiliation(acctList[1], contList[1]));
        affList.add(TestUtility.createAffiliation(acctList[2], contList[2]));
        insert affList;
        //and users
        List<User> userList = new List<User>();
        userList.add(TestUtility.createUser());
        userList.add(TestUtility.createUser());
        userList[1].LastName = 'uniqueTestName';
        insert userList;
        //primary contact is already handled, set the TM and IST rep
        acctList[0].Owner = userList[0];
        acctList[0].IST_Account_Owner__c = userList[0].Id;
        acctList[1].Owner = userList[0];
        acctList[1].IST_Account_Owner__c = userList[0].Id;
        acctList[2].Owner = userList[0];
        acctList[2].IST_Account_Owner__c = userList[0].Id;
        update acctList;
        //need at least one doc for each account
        Date future = System.Today().addMonths(5);
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(Account__c = acctList[0].Id, RecordTypeId = licenseId, Document_State__c = 'NY', Expiration_Date__c = future, No_Expiration__c = false, License_Number__c = '11111'));
        docList.add(new Dealer_Docs__c(Account__c = acctList[1].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Expiration_Date__c = future, No_Expiration__c = false, Permit_Resale_Number__c = '22222'));
        docList.add(new Dealer_Docs__c(Account__c = acctList[2].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Expiration_Date__c = future, No_Expiration__c = false, Permit_Resale_Number__c = '33333'));
        insert docList;
    }

    //test if the review decision is changed it will re-query for IST and TM
    @isTest
    static void testReviewDecisionChange() {
        //query for the account
        Account a = [SELECT Id, IST_Account_Owner__c, IST_Account_Owner__r.Email, OwnerId, Owner.Email, Primary_Contact__c, Primary_Contact__r.Email FROM Account WHERE Name = 'Test 1'];
        //query for the user
        User u = [SELECT Id FROM User WHERE LastName = 'uniqueTestName'];
        //create new contact
        Contact c = TestUtility.createContact(a);
        insert c;
        Affiliation__c aff = TestUtility.createAffiliation(a, c); //this will set the new contact as the new primary? or will i have to adjust the account Primary_Contact__c field manually?
        insert aff;
        //change the TM, IST, PC
        a.Owner = u;
        a.IST_Account_Owner__c = u.Id;
        update a;
        //re-query the account
        a = [SELECT Id, IST_Account_Owner__r.Email, Owner.Email, Primary_Contact__r.Email FROM Account WHERE Name = 'Test 1'];
        //query for the doc
        Dealer_Docs__c d = [SELECT Id, IST_Account_Manager_Email__c, TM_Email__c, Primary_Contact_Email__c FROM Dealer_Docs__c WHERE Account__c = :a.Id];
        //initial system asserts to check that the email fields no longer match
        System.assertNotEquals(a.Owner.Email, d.TM_Email__c);
        System.assertNotEquals(a.IST_Account_Owner__r.Email, d.IST_Account_Manager_Email__c);
        System.assertNotEquals(a.Primary_Contact__r.Email, d.Primary_Contact_Email__c);
        //edit the review status field to 'Requires BDR'
        Test.startTest();
            d.Review_Status__c = 'Requires BDR';
            update d;
        Test.stopTest();
        //re-query the doc
        d = [SELECT Id, IST_Account_Manager_Email__c, TM_Email__c, Primary_Contact_Email__c FROM Dealer_Docs__c WHERE Account__c = :a.Id];
        //system asserts to check that only the TM and IST emails fields match and the PC ones does not
        System.assertEquals(a.Owner.Email, d.TM_Email__c);
        System.assertEquals(a.IST_Account_Owner__r.Email, d.IST_Account_Manager_Email__c);
        System.assertNotEquals(a.Primary_Contact__r.Email, d.Primary_Contact_Email__c);
    }

    //test if one (or more in other tests) of the email checkboxes is checked, IST, TM, and PC are re-queried for
    @isTest
    static void testExpirationCheckboxChange() {
        //query for the account
        Account a = [SELECT Id, IST_Account_Owner__c, IST_Account_Owner__r.Email, OwnerId, Owner.Email, Primary_Contact__c, Primary_Contact__r.Email FROM Account WHERE Name = 'Test 2'];
        //query for the user
        User u = [SELECT Id FROM User WHERE LastName = 'uniqueTestName'];
        //create new contact
        Contact c = TestUtility.createContact(a);
        insert c;
        Affiliation__c aff = TestUtility.createAffiliation(a, c); //this will set the new contact as the new primary? or will i have to adjust the account Primary_Contact__c field manually?
        insert aff;
        //change the TM, IST, PC
        a.Owner = u;
        a.IST_Account_Owner__c = u.Id;
        update a;
        //re-query the account
        a = [SELECT Id, IST_Account_Owner__r.Email, Owner.Email, Primary_Contact__r.Email FROM Account WHERE Name = 'Test 2'];
        //query for the doc
        Dealer_Docs__c d = [SELECT Id, IST_Account_Manager_Email__c, TM_Email__c, Primary_Contact_Email__c FROM Dealer_Docs__c WHERE Account__c = :a.Id];
        //initial system asserts to check that the email fields no longer match
        System.assertNotEquals(a.Owner.Email, d.TM_Email__c);
        System.assertNotEquals(a.IST_Account_Owner__r.Email, d.IST_Account_Manager_Email__c);
        System.assertNotEquals(a.Primary_Contact__r.Email, d.Primary_Contact_Email__c);
        //edit one of the three email checkboxes to true
        Test.startTest();
            d.Reminder_Email_Sent__c = true;
            update d;
            //re-query the doc
            d = [SELECT Id, IST_Account_Manager_Email__c, TM_Email__c, Primary_Contact_Email__c FROM Dealer_Docs__c WHERE Account__c = :a.Id];
            //system asserts to check that all of the emails fields match
            System.assertEquals(a.Owner.Email, d.TM_Email__c);
            System.assertEquals(a.IST_Account_Owner__r.Email, d.IST_Account_Manager_Email__c);
            System.assertEquals(a.Primary_Contact__r.Email, d.Primary_Contact_Email__c);

            d.TM_Email__c = null;
            d.IST_Account_Manager_Email__c = null;
            d.Primary_Contact_Email__c = null;
            d.Thirty_Day_Reminder_Email_Sent__c = true;
            update d;
            //re-query the doc
            d = [SELECT Id, IST_Account_Manager_Email__c, TM_Email__c, Primary_Contact_Email__c FROM Dealer_Docs__c WHERE Account__c = :a.Id];
            //system asserts to check that all of the emails fields match
            System.assertEquals(a.Owner.Email, d.TM_Email__c);
            System.assertEquals(a.IST_Account_Owner__r.Email, d.IST_Account_Manager_Email__c);
            System.assertEquals(a.Primary_Contact__r.Email, d.Primary_Contact_Email__c);


            d.TM_Email__c = null;
            d.IST_Account_Manager_Email__c = null;
            d.Primary_Contact_Email__c = null;
            d.Forty_Five_Day_Reminder_Email_Sent__c = true;
            update d;
            //re-query the doc
            d = [SELECT Id, IST_Account_Manager_Email__c, TM_Email__c, Primary_Contact_Email__c FROM Dealer_Docs__c WHERE Account__c = :a.Id];
            //system asserts to check that all of the emails fields match
            System.assertEquals(a.Owner.Email, d.TM_Email__c);
            System.assertEquals(a.IST_Account_Owner__r.Email, d.IST_Account_Manager_Email__c);
            System.assertEquals(a.Primary_Contact__r.Email, d.Primary_Contact_Email__c);
        Test.stopTest();
    }

    //test if something else changes, it won't re-query anything
    @isTest
    static void testOtherFieldChange() {
        //query for the account
        Account a = [SELECT Id, IST_Account_Owner__c, IST_Account_Owner__r.Email, OwnerId, Owner.Email, Primary_Contact__c, Primary_Contact__r.Email FROM Account WHERE Name = 'Test 3'];
        //query for the user
        User u = [SELECT Id FROM User WHERE LastName = 'uniqueTestName'];
        //create new contact
        Contact c = TestUtility.createContact(a);
        insert c;
        Affiliation__c aff = TestUtility.createAffiliation(a, c); //this will set the new contact as the new primary? or will i have to adjust the account Primary_Contact__c field manually?
        insert aff;
        //change the TM, IST, PC
        a.Owner = u;
        a.IST_Account_Owner__c = u.Id;
        update a;
        //re-query the account
        a = [SELECT Id, IST_Account_Owner__r.Email, Owner.Email, Primary_Contact__r.Email FROM Account WHERE Name = 'Test 3'];
        //query for the doc
        Dealer_Docs__c d = [SELECT Id, IST_Account_Manager_Email__c, TM_Email__c, Primary_Contact_Email__c FROM Dealer_Docs__c WHERE Account__c = :a.Id];
        //initial system asserts to check that the email fields no longer match
        System.assertNotEquals(a.Owner.Email, d.TM_Email__c);
        System.assertNotEquals(a.IST_Account_Owner__r.Email, d.IST_Account_Manager_Email__c);
        System.assertNotEquals(a.Primary_Contact__r.Email, d.Primary_Contact_Email__c);
        //edit a random field on the doc that sould no trigger the re-query
        Test.startTest();
            d.Document_Notes__c = 'test note';
            update d;
        Test.stopTest();
        //re-query the doc
        d = [SELECT Id, IST_Account_Manager_Email__c, TM_Email__c, Primary_Contact_Email__c FROM Dealer_Docs__c WHERE Account__c = :a.Id];
        //system asserts that none of the email fields match still
        System.assertNotEquals(a.Owner.Email, d.TM_Email__c);
        System.assertNotEquals(a.IST_Account_Owner__r.Email, d.IST_Account_Manager_Email__c);
        System.assertNotEquals(a.Primary_Contact__r.Email, d.Primary_Contact_Email__c);
    }
}