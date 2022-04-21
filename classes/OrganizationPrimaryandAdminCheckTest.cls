@istest
public class OrganizationPrimaryandAdminCheckTest {
    @testSetup
    static void createTestData(){
        
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

        List<Account> accountList = new List<Account>();
        Account a = TestUtility.createAccount('Seller');
        Account a2 = TestUtility.createAccount('buyer');
        Account a3 = TestUtility.createAccount('Cars R Us');
        Account a4 = TestUtility.createTransportAcct();
        accountList.add(a);
        accountList.add(a2);
        accountList.add(a3);
        accountList.add(a4);

        insert accountList;

        List<Contact> contactList = new List<Contact>();
        Contact c2 = TestUtility.createContact(a);
        c2.LastName = 'Contact2';
        Contact c4 = TestUtility.createContact(a2);
        c4.LastName = 'Contact4';
        Contact c5 = TestUtility.createContact(a3);
        c5.LastName = 'Contact5';
        Contact c6 = TestUtility.createContact(a3);
        c6.LastName = 'Contact6';
        contactList.add(c2);
        contactList.add(c4);
        contactList.add(c5);
        contactList.add(c6);
        insert contactList;

        List<Affiliation__c> affList = new List<Affiliation__c>();
            
        Affiliation__c af2 = TestUtility.createAffiliation(a, c2);
        af2.Active__c=true;
        af2.primary_contact__c=false; 
        af2.type__c='Admin';
        Affiliation__c af4 = TestUtility.createAffiliation(a2, c4);
        af4.Active__c=true;
        af4.primary_contact__c=true; 
        af4.type__c='Admin';
        Affiliation__c af5 = TestUtility.createAffiliation(a3, c5);
        af5.Active__c=true;
        af5.primary_contact__c=false; 
        af5.type__c='Admin';
        Affiliation__c af6 = TestUtility.createAffiliation(a3, c6);
        af6.Active__c=true;
        af6.primary_contact__c=true; 
        af6.type__c='rep';

        affList.add(af2);
        affList.add(af4);
        affList.add(af5);
        affList.add(af6);


        insert affList;
        // Account a4 = TestUtility.createAccount('We buy anything');
        // insert a4;
        // Contact c7 = TestUtility.createContact(a4);
        // c7.LastName = 'Contact7';
        // insert c7;
        // Contact c8 = TestUtility.createContact(a4);
        // c8.LastName = 'Contact8';
        // insert c8;
        // Affiliation__c af7 = new Affiliation__c(Account__c=a4.id, Contact__c=c7.id, Active__c=true, Receive_Push__c = true, type__c='rep', primary_contact__c=false);
        // insert af7;
        // Affiliation__c af8 = new Affiliation__c(Account__c=a4.id, Contact__c=c7.id, Active__c=true, Receive_Push__c = true, type__c='admin', primary_contact__c=true);
        // insert af8;


    }
    public static testMethod void TestAccountActiveUpdateCheck(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //Check an error message will fire when attempting to Change the Account active flag without having a primary contact set
        Account acc = [Select id, active__c From Account Where Name='seller'];
        system.debug(acc);
        acc.Active__c=true;
        Boolean goterror = false;
        test.startTest();
            try{
                update acc;
            }catch(Exception exc){
                system.debug(acc);
                system.debug(exc);
                if(exc.getMessage().contains('Please ensure this Account has a Primary Contact and Admin ACV User before setting it to active')){
                    goterror = true;
                }        
            }
        test.stopTest();
        System.assert(goterror, 'ActiveAccountPrimaryAdminCheck class failed to prevent account activation without a primary contact');   
    }
    public static testMethod void TestTranspoAccountCheck(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //Check an error message will fire when attempting to Change the Account active flag without having a primary contact set
        Account accT = [Select id, active__c From Account Where Name='Test Transporter'];
        accT.Active__c=true;
        Boolean goterror = false;
        test.startTest();
            try{
                update accT;
            }catch(Exception exc){
                if(exc.getMessage().contains('Please ensure this Account has a Primary Contact and Admin ACV User before setting it to active')){
                    goterror = true;
                }        
            }
        test.stopTest();
        System.assert(goterror==false, 'ActiveAccountPrimaryAdminCheck ran for a Transporter account when it shouldnt have');   
    }
    @istest
    static void UpdateAffiliationPrimEventTest()  {
        //find an affiliation and update it to Prim contact, this should not fail
        Contact c = [Select id, active__c From Contact Where LastName='Contact2'];
        Affiliation__c Aff = new Affiliation__c();
        Aff = [SELECT ID, Id__c, Active__c, Primary_Contact__c FROM Affiliation__c Where Contact__c=:c.id];
        Aff.Primary_Contact__c=true;
        update Aff;
        System.debug(Aff);

        Account acc = [Select id, active__c From Account Where Name='seller'];
        system.debug(acc);
        acc.Active__c=true;
        Boolean goterror = false;
        test.startTest();
            try{
                update acc;
            }catch(Exception exc){
                system.debug(acc);
                system.debug(exc);
                if(exc.getMessage().contains('Please ensure this Account has a Primary Contact and Admin ACV User before setting it to active')){
                    goterror = true;
                }        
            }
        test.stopTest();
        System.assert(goterror==false, 'ActiveAccountPrimaryAdminCheck fired when it shoudlnt have');   


    }
    public static testMethod void TestAffiliationPrimarytoFalseUpdateCheck(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        //grab affiliation directly and remove primary Contact check, this should fail
        Contact c = [Select id, active__c From Contact Where LastName='Contact4'];
        Affiliation__c Aff = new Affiliation__c();
        Aff = [SELECT ID, Id__c, Active__c, Primary_Contact__c FROM Affiliation__c Where Contact__c=:c.id];
        Aff.Primary_Contact__c=false;
        System.debug(Aff);
        Boolean goterror = false;
        test.startTest();
            try{
                update Aff;
            }catch(Exception exc){
                system.debug(Aff);
                system.debug(exc);
                if(exc.getMessage().contains('Please ensure the associated Account to this Affiliation has an Active Primary Contact and Admin set before updated this Affiliation')){
                    goterror = true;
                }        
            }
        test.stopTest();
        System.assert(goterror, 'AffiliationPrimaryorAdminChangeCheck class failed to prevent affiliation update without a primary contact');   
    }
    public static testMethod void TestAffiliationPrimarytoFalseUpdateCheckWithDisableFunctionality(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        //grab affiliation directly and remove primary Contact check, this should fail
        Contact c = [Select id, active__c From Contact Where LastName='Contact4'];
        Affiliation__c Aff = new Affiliation__c();
        Aff = [SELECT ID, Id__c, Active__c, Primary_Contact__c FROM Affiliation__c Where Contact__c=:c.id];
        Aff.Primary_Contact__c=false;
        System.debug(Aff);
        Boolean goterror = false;
        test.startTest();
        AffiliationPrimaryorAdminChangeCheck.validationEnabled = false;
        update Aff;
        AffiliationPrimaryorAdminChangeCheck.validationEnabled = true;
        test.stopTest();
        System.assert([SELECT COUNT() FROM Affiliation__c Where Contact__c=:c.id AND Primary_Contact__c = FALSE] == 1, 'validationEnabled boolean succeeded in preventing AffiliationPrimaryorAdminChangeCheck class from triggering.');   
    }
    public static testMethod void TestAffiliationAdmintoRepUpdateCheck(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        //grab affiliation directly and remove admin role, this should fail
        Contact c = [Select id, active__c From Contact Where LastName='Contact5'];
        Affiliation__c Aff = new Affiliation__c();
        Aff = [SELECT ID, Id__c, Active__c, Primary_Contact__c, Type__c FROM Affiliation__c Where Contact__c=:c.id];
        Aff.Type__c='rep';
        System.debug(Aff);
        Boolean goterror = false;
        test.startTest();
            try{
                update Aff;
            }catch(Exception exc){
                system.debug(Aff);
                system.debug(exc);
                if(exc.getMessage().contains('Please ensure the associated Account to this Affiliation has an Active Primary Contact and Admin set before updated this Affiliation')){
                    goterror = true;
                }        
            }
        test.stopTest();
        System.assert(goterror, 'AffiliationPrimaryorAdminChangeCheck class failed to prevent affiliation update without a Admin contact');   
    }

    public static testMethod void TestAffiliationAdmintoRepWPrimaryUpdateCheck(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        //grab affiliation directly and remove admin role but keep primary, this should not fail
        Contact c = [Select id, active__c From Contact Where LastName='Contact6'];
        Affiliation__c Aff = new Affiliation__c();
        Aff = [SELECT ID, Id__c, Active__c, Primary_Contact__c, Type__c FROM Affiliation__c Where Contact__c=:c.id];
        Aff.Type__c='admin';
        update Aff;
        system.debug(Aff);

        Aff.Type__c='rep';

        Boolean goterror = false;
        test.startTest();
            try{
                update Aff;
            }catch(Exception exc){
                system.debug(Aff);
                system.debug(exc);
                if(exc.getMessage().contains('Please ensure the associated Account to this Affiliation has an Active Primary Contact and Admin set before updated this Affiliation')){
                    goterror = true;
                }        
            }
        test.stopTest();
        System.assert(goterror==false, 'AffiliationPrimaryorAdminChangeCheck class failed to allow primary affiliation update with a rep contact');   
    }
    public static testMethod void TestAffiliationRemoveAdminandPrimUpdateCheck(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        test.startTest();
        //grab affiliation directly and remove primary Contact check AND admin role, this should fail
        Contact c = [Select id, active__c From Contact Where LastName='Contact5'];
        Affiliation__c Aff = new Affiliation__c();
        Aff = [SELECT ID, Id__c, Active__c, Primary_Contact__c, Type__c FROM Affiliation__c Where Contact__c=:c.id];
        Aff.primary_contact__c=true;
        update Aff;
        system.debug(Aff);

        Aff.Type__c='rep';
        Aff.primary_contact__c=false;

        Boolean goterror = false;
            try{
                update Aff;
            }catch(Exception exc){
                system.debug(Aff);
                system.debug(exc);
                if(exc.getMessage().contains('Please ensure the associated Account to this Affiliation has an Active Primary Contact and Admin set before updated this Affiliation')){
                    goterror = true;
                }        
            }
        test.stopTest();
        System.assert(goterror, 'AffiliationPrimaryorAdminChangeCheck class failed to stop a primary contact and admin form being removed');   
    }
    public static testMethod void TestAffiliationPrimDeleteCheck(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        test.startTest();
        //grab affiliation directly and remove primary Contact check AND admin role, this should fail
        Contact c = [Select id, active__c From Contact Where LastName='Contact6'];
        Affiliation__c Aff = new Affiliation__c();
        Aff = [SELECT ID, Id__c, Active__c, Primary_Contact__c, Type__c FROM Affiliation__c Where Contact__c=:c.id];

        Boolean goterror = false;
            try{
                delete Aff;
            }catch(Exception exc){
                system.debug(Aff);
                system.debug(exc);
                if(exc.getMessage().contains('Please ensure the associated Account to this Affiliation has an Active Primary Contact and Admin set before updated this Affiliation')){
                    goterror = true;
                }        
            }
        test.stopTest();
        System.assert(goterror, 'AffiliationPrimaryorAdminChangeCheck class failed to stop a primary contact from being removed');   
    }
}