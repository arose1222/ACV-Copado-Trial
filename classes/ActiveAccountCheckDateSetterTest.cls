@isTest
public class ActiveAccountCheckDateSetterTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    @isTest
    static void insertTest() {
        //create 3 accounts
        List<Account> accountList = new List<Account>();
        //one with Active__c == true and Dealer_Doc_Compliance__c != 'Out of Compliance'
        accountList.add(new Account(Name = 'Account1', legal_name__c = 'Account1', Active__c = true, Dealer_Doc_Compliance__c = 'Out of Compliance', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US', phone= '1234567890'));
        //one with Dealer_Doc_Compliance__c == 'Out of Compliance' (if it will allow it) and Active__c == false
        accountList.add(new Account(Name = 'Account3', legal_name__c = 'Account3', Active__c = false, Dealer_Doc_Compliance__c = 'Out of Compliance', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14215', BillingCountry='US', phone= '1234567890'));
        //insert accounts
        insert accountList;
        //query
        List<Account> accountCheck = [SELECT Id, Name, Set_Active_Account_Check_Date__c FROM Account ORDER BY Name ASC];
        //system.asserts
        System.assertEquals(System.Today().addDays(11), accountCheck[0].Set_Active_Account_Check_Date__c);
        System.assertEquals(null, accountCheck[1].Set_Active_Account_Check_Date__c);
    }

    @isTest
    static void updateTest() {
        //create 2 accounts
        List<Account> accountList = new List<Account>();
        //both need to have Active__c = false (so they don't trigger the insert code)
        accountList.add(new Account(Name = 'Account1', legal_name__c = 'Account1', Active__c = false, Dealer_Doc_Compliance__c = 'Out of Compliance', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14217', BillingCountry='US', phone= '1234567890'));
        accountList.add(new Account(Name = 'Account2', legal_name__c = 'Account2',Active__c = false, Dealer_Doc_Compliance__c = 'Out of Compliance', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14218', BillingCountry='US', phone= '1234567890'));
        //insert accounts
        insert accountList;
        //get accounts
        List<Account> accountsToUpdate = [SELECT Id, Active__c, Dealer_Doc_Compliance__c FROM Account ORDER BY Name ASC];
        //update them with Active__c == true
        accountsToUpdate[0].Active__c = true;
        accountsToUpdate[1].Active__c = true;
        //update accounts
        Contact c = TestUtility.createContact(accountsToUpdate[0]);
        insert c;
        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( accountsToUpdate[0], c );
        affList.add( aff );
        Affiliation__c aff1 = TestUtility.createAffiliation( accountsToUpdate[1], c );
        affList.add( aff1 );
        insert affList;

        update accountsToUpdate;
        //query
        List<Account> accountCheck = [SELECT Id, Name, Set_Active_Account_Check_Date__c FROM Account ORDER BY Name ASC];
        //system.asserts
        System.assertEquals(System.Today().addDays(11), accountCheck[0].Set_Active_Account_Check_Date__c);
        System.assertEquals(System.Today().addDays(11), accountCheck[1].Set_Active_Account_Check_Date__c);
    }
}