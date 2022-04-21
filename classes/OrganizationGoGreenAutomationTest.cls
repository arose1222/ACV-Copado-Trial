@istest
public class OrganizationGoGreenAutomationTest {
    @TestSetup
    static void makeData(){

        Account a1 = TestUtility.createAccount('Insert Account check');
        a1.Dealership_Id__c = '1';
        a1.Active__c = true;
        insert a1;

        Account a3 = TestUtility.createAccount('Insert fail');
        a3.Dealership_Id__c = '123';
        a3.Active__c = true;
        a3.BillingState = 'WI';
        insert a3;

        Account a2 = TestUtility.createAccount('Update Account check');
        a2.Dealership_Id__c = '12';
        a2.Active__c = false;
        insert a2;

        Contact c = TestUtility.createContact(a2);
        insert c;
        Affiliation__c aff = TestUtility.createAffiliation( a2, c );
        insert aff;


    }
    @istest
    static void InsertAccountActiveDateCheckTest()  {
        //Update Active flag
        Account newOrg = new Account();
        newOrg = [SELECT ID, Dealership_ID__c, Active__c,Initial_Activation_Date__c, Go_Green_Seller__c FROM Account Where Dealership_ID__c = '1'];
        System.debug(newOrg);
        
        System.assert(newOrg.Initial_Activation_Date__c != null, 'Inserting Active account does not populate the Initial Activation Date field');     
        System.assert(newOrg.Go_Green_Seller__c = true, 'Inserting Active account does not flip the go green field');
    }
    @istest
    static void InsertAccountActiveGreenFailureTest()  {
        //Update Active flag
        Account newOrg = new Account();
        newOrg = [SELECT ID, Dealership_ID__c, Active__c,Initial_Activation_Date__c, Go_Green_Seller__c FROM Account Where Dealership_ID__c = '123'];
        System.debug(newOrg.Go_Green_Seller__c);
        
        System.assert(newOrg.Initial_Activation_Date__c != null, 'Inserting Active account does not populate the Initial Activation Date field');
        System.assert(newOrg.Go_Green_Seller__c == false, 'Inserting Active account flips the go green field when it shouldnt');
    }
    @istest
    static void UpdateAccountActiveDateCheckTest()  {
        //Update Active flag
        Account newOrg = new Account();
        newOrg = [SELECT ID, Dealership_ID__c, Active__c,Initial_Activation_Date__c, Go_Green_Seller__c FROM Account Where Dealership_ID__c = '12'];
        System.debug(newOrg);
        newOrg.Active__c = true;
        Test.startTest();
        update newOrg;
        
        Account newOrg2 = new Account();
        newOrg2 = [SELECT ID, Dealership_ID__c, Active__c,Initial_Activation_Date__c, Go_Green_Seller__c FROM Account Where Dealership_ID__c = '12'];
        System.debug(newOrg2);

        System.assert(newOrg2.Initial_Activation_Date__c != null, 'Updating Active account does not populate the Initial Activation Date field');
        System.assert(newOrg2.Go_Green_Seller__c = true, 'Updating Active account does not flip the go green field');
        Test.stopTest();
    }
    @istest
    static void UpdateAccountActiveGreenFailureAfterActiveFlipTest()  {
        //Flip active flag back to false, then back to true and make sure go green doesn't flip back to true as well since this is not an initial activation
        Test.startTest();
        Account a4 = TestUtility.createAccount('flip failure');
        a4.Dealership_Id__c = '1234';
        a4.Active__c = true;
        insert a4;

        Contact c1 = TestUtility.createContact(a4);
        insert c1;
        Affiliation__c aff1 = TestUtility.createAffiliation( a4, c1 );
        insert aff1;


        Account newOrg = new Account();
        newOrg = [SELECT ID, Dealership_ID__c, Active__c,Initial_Activation_Date__c, Go_Green_Seller__c FROM Account Where Dealership_ID__c = '1234'];
        newOrg.Active__c = false;
        newOrg.Go_Green_Seller__c = false;
        newOrg.Inactive_Sub_Status__c = '1';	
        update newOrg;
        Account newOrg3 = new Account();
        newOrg3 = [SELECT ID, Dealership_ID__c, Active__c,Initial_Activation_Date__c, Go_Green_Seller__c FROM Account Where Dealership_ID__c = '1234'];
        System.debug(newOrg3);
        System.debug(newOrg3.Go_Green_Seller__c);
        System.assert(newOrg3.Initial_Activation_Date__c != null, 'Updating Active account does not populate the Initial Activation Date field');
        System.assert(newOrg3.Go_Green_Seller__c == false, 'Updating Active account flips the go green field when it shouldnt');

        Account newOrg2 = new Account();
        newOrg2 = [SELECT ID, Dealership_ID__c, Active__c,Initial_Activation_Date__c, Go_Green_Seller__c FROM Account Where Dealership_ID__c = '1234'];
        newOrg2.Active__c = true;
        update newOrg2;

        Account newOrg4 = new Account();
        newOrg4 = [SELECT ID, Dealership_ID__c, Active__c,Initial_Activation_Date__c, Go_Green_Seller__c FROM Account Where Dealership_ID__c = '1234'];
        System.assert(newOrg4.Go_Green_Seller__c == false, 'Updating Active account flips the go green field when it shouldnt');
        Test.stopTest();

    }
}