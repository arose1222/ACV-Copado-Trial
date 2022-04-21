@istest
public class OrganizationInitialActivationTest {
    @TestSetup
    static void makeData(){

        Account a1 = TestUtility.createAccount('Insert Account check');
        a1.Dealership_Id__c = '1';
        a1.Active__c = true;
        insert a1;

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
        Test.stopTest();
    }
}