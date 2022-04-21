@istest
public with sharing class AccountMergeDependentRecordErrorTest {
    @testSetup
    static void createTestData(){

        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();


        List<Account> accountList = new List<Account>();
        Account a = TestUtility.createAccount('Auction');
        Account a2 = TestUtility.createAccount('Both');
        Account a3 = TestUtility.createAccount('Case');
        Account a4 = TestUtility.createAccount('Neither');
        Account a5 = TestUtility.createAccount('Parent');
        accountList.add(a);
        accountList.add(a2);
        accountList.add(a3);
        accountList.add(a4);
        accountList.add(a5);

        insert accountList;

        List<Contact> contactList = new List<Contact>();
        Contact c = TestUtility.createDealerContact(a);
        c.LastName = 'Contact';
        Contact c2 = TestUtility.createDealerContact(a2);
        c2.LastName = 'Contact2';
        Contact c3 = TestUtility.createDealerContact(a3);
        c3.LastName = 'Contact3';
        Contact c4 = TestUtility.createDealerContact(a4);
        c4.LastName = 'Contact4';
        contactList.add(c);
        contactList.add(c2);
        contactList.add(c3);
        contactList.add(c4);

        insert contactList;

        List<Vehicle__c> vehicleList = new List<Vehicle__c>();
        Vehicle__c v = TestUtility.createVehicle();
        Vehicle__c v2 = TestUtility.createVehicle();
        vehicleList.add(v);
        vehicleList.add(v2);
        
        insert vehicleList;

        List<Auction__c> auctionList = new List<Auction__c>();
        Auction__c auction = TestUtility.createAuctionWithUniqueId(a, c, v);
        Auction__c auction2 = TestUtility.createAuctionWithUniqueId(a2, c2, v2);
        auctionList.add(auction);
        auctionList.add(auction2);
        insert auctionList;

        List<Case> caseList = new List<Case>();
        Case case1 = TestUtility.createTitleCase(auction2, a2, c2);
        Case case2 = TestUtility.createTitleCase(auction, a3, c3);
        caseList.add(case1);
        caseList.add(case2);
        insert caseList;

    }
    public static testMethod void TestAuction(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //Check an error message will fire when attempting to Change the Account active flag without having a primary contact set
        Account acc = [Select id From Account Where Name = 'Auction'];
        Account parent = [Select id From Account Where Name = 'Parent'];
        Boolean goterror = false;
        test.startTest();
            try{
                merge parent acc;
            }catch(Exception exc){
                if(exc.getMessage().contains('This Account has an Auction or Case record associated with it and cannot be merged.')){
                    goterror = true;
                }        
            }
        test.stopTest();
        System.assert(goterror, 'AccountMergeDependentRecordError class failed to prevent account merge with an Auction record.');   
    }
    public static testMethod void TestCase(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //Check an error message will fire when attempting to Change the Account active flag without having a primary contact set
        Account acc = [Select id From Account Where Name = 'Case'];
        Account parent = [Select id From Account Where Name = 'Parent'];
        Boolean goterror = false;
        test.startTest();
            try{
                merge parent acc;
            }catch(Exception exc){
                System.debug('exception message:' + exc.getMessage());
                if(exc.getMessage().contains('This Account has an Auction or Case record associated with it and cannot be merged.') 
                || exc.getMessage().contains('Your attempt to delete TestNameContact Contact3 could not be completed because it is associated with the following cases')){
                    goterror = true;
                }        
            }
        test.stopTest();
        System.assert(goterror, 'AccountMergeDependentRecordError class failed to prevent account merge with a Case record.');   
    }
    public static testMethod void TestBoth(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //Check an error message will fire when attempting to Change the Account active flag without having a primary contact set
        Account acc = [Select id From Account Where Name = 'Both'];
        Account parent = [Select id From Account Where Name = 'Parent'];
        Boolean goterror = false;
        test.startTest();
            try{
                merge parent acc;
            }catch(Exception exc){
                System.debug('exception message:' + exc.getMessage());
                if(exc.getMessage().contains('This Account has an Auction or Case record associated with it and cannot be merged.')
                || exc.getMessage().contains('Your attempt to delete TestNameContact Contact2 could not be completed because it is associated with the following cases.')){
                    
                    goterror = true;
                }        
            }
        test.stopTest();
        System.assert(goterror, 'AccountMergeDependentRecordError class failed to prevent account merge with an Auction and Case record.');   
    }
    public static testMethod void TestNeither(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //Check an error message will fire when attempting to Change the Account active flag without having a primary contact set
        Account acc = [Select id From Account Where Name = 'Neither'];
        Account parent = [Select id From Account Where Name = 'Parent'];
        Boolean noerror = true;
        test.startTest();
            try{
                merge parent acc;
            }catch(Exception exc){
                if(exc.getMessage().contains('This Account has an Auction or Case record associated with it and cannot be merged.')){
                    noerror = false;
                }        
            }
        test.stopTest();
        System.assert(noerror, 'AccountMergeDependentRecordError class succeeded in not preventing Account merge without an Auction or Case record.');   
    }
}