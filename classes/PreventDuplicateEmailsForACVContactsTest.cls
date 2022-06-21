@isTest
public class PreventDuplicateEmailsForACVContactsTest {
    static string contactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact(a);
        c.Email = 'Bill@testEmail.com';
        c.recordTypeId = contactRT;
        insert c;
        Contact c1 = TestUtility.createContact(a);
        c1.Email = 'Bill@testEmail2.com';
        c1.recordTypeId = contactRT;
        insert c1;
    }

    @isTest
    static void insertNewContactTest(){
        //Having to do this to get around duplicate contact rules
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Account a = TestUtility.createAccount();
        Database.insert(a,dml);
        Contact c = TestUtility.createContact(a);
        c.Email = 'Bill@testEmail.com';
        c.recordTypeId = contactRT;
        Boolean errorThrown = false;
        Test.startTest();
        database.SaveResult sr = Database.insert(c,dml);
        
        if(!sr.isSuccess()){
            errorThrown = true;
        }

        Test.stopTest();
        System.assert(errorThrown, 'Error was not thrown');
    }

    @isTest
    static void updatePreventDupeEmail(){
        Contact c = [SELECT Id, Email FROM Contact WHERE Email = 'Bill@testEmail2.com' limit 1];
        c.Email = 'Bill@testEmail.com';
        Boolean errorThrown = false;
        Test.startTest();
        try{
            update c;
        }
        catch(Exception e){
            errorThrown = true;
        }
        Test.stopTest();
        System.assert(errorThrown, 'Error was not thrown');
    }

    @isTest
    static void createGoodContact(){
        Account a = TestUtility.createAccount('Bill\'s Account');
        insert a;
        Contact c = TestUtility.createContact(a);
        c.Email = 'Bill@Bill.com';
        Boolean errorThrown = true;
        Test.startTest();
        try{
            insert c;
        }
        catch(Exception e){
            errorThrown = false;
        }
        Test.stopTest();
        System.assert(errorThrown, 'Error was thrown');
        System.assert([SELECT Count() FROM Contact WHERE Email = 'Bill@Bill.com'] == 1, 'contact count doesn\'t match');
    }

    @isTest
    static void updateGoodEmail(){
        Contact c = [SELECT Id, Email FROM Contact WHERE Email = 'Bill@testEmail2.com' limit 1];
        c.Email = 'Bill@Bill.com';
        Boolean errorThrown = true;
        Test.startTest();
        try{
            update c;
        }
        catch(Exception e){
            errorThrown = false;
        }
        Test.stopTest();
        System.assert(errorThrown, 'Error was thrown');
        System.assert([SELECT Count() FROM Contact WHERE Email = 'Bill@Bill.com'] == 1, 'contact count doesn\'t match');
    }
}