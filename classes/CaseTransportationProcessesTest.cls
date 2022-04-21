@isTest
public class CaseTransportationProcessesTest {
    @TestSetup
    static void makeData(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        String uniqueUserName = 'Adminuser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        // User u = new User(Alias = 'admint', Email='adminuser@testorg.com',
        // EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        // LocaleSidKey='en_US', TimeZoneSidKey='America/New_York', ProfileId = p.Id,
        //  UserName=uniqueUserName);
        User u = TestUtility.createSystemAdministratorUser();
        u.email = 'adminuser@testorg.com';

        System.runAs(u) {
            insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
            Transportation_Address__c tAddress1 = new Transportation_Address__c(City__c = 'Browntown', Country__c='US', Name = 'Schmucky Thakloun Automotive', State__c = 'Wisconsin', Street__c = '420 Blaze Circle', Postal_Code__c = '53522', Notes__c = 'Are you down to clown?',id__c = '420');
            insert tAddress1;
            Id transpRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Transporters').getRecordTypeId();
            List<Account> accountList = New List<Account>();
            accountList.add(new Account(Dealership_ID__c = '456', Name='seller',legal_Name__c='seller', dealer_type__c='1',IST_Account_Owner__c =UserInfo.getUserId(),BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US', Dealership_Notes__c='Where is this coming from?', Pickup_notes__c='Here I am'));
            accountList.add(new Account(Dealership_ID__c = '123', Name='buyer',legal_Name__c='buyer', dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US', Dealership_Notes__c='Where is this coming from?', Pickup_notes__c='Here I am'));
            accountList.add(new Account(Name = 'transporter 1', Email__c = 't1@email.com', Phone = '5552227777', No_DOT__c = true, RecordTypeId = transpRTId));
            accountList.add(new Account(Name = 'transporter 2', Email__c = 't2@email.com', Phone = '5552228888', No_DOT__c = true, RecordTypeId = transpRTId));
            insert accountList;
            List<Contact> contactList = new List<Contact>();
            contactList.add(new Contact(FirstName='seller', LastName='seller', accountId=accountList[0].id, email='test@email.com'));
            contactList.add(new Contact(FirstName='buyer', LastName='buyer', accountId=accountList[1].id, email='test@email.com'));
            insert contactList;
            vehicle__c newCar = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
            insert newCar;
            vehicle__c newCar1 = new vehicle__c(year__c='2010',make__c='test make', model__c='test model', vin__c = '1234567890102031');
            insert newCar1;
            auction__c newAuction = new auction__c(status__c = 'Active', end_time__c = System.Now(),Buyer_Dealership__c = accountList[0].id, 
            Seller_Dealership__c = accountList[1].id,Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = newCar.id);
            insert newAuction;
        }
    }

    @isTest
    static void setPostedPriceTest(){
        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Transportation').getRecordTypeId();
        Account a = new Account(Dealership_ID__c = '123');
        Case c = new Case(account = a, recordTypeId = titlesRecordType);
        List<Transport_Pricing__mdt> pricingList = [select Percent_Adjustment__c from Transport_Pricing__mdt where MasterLabel = 'First Posted Price'];
        Double price = 100.00;
        c.Buyer_Price__c = price;
        c.Price_Pre_Promotion__c = null;
        insert c;
        List<Case> caseResult = [select id, Posted_Price__c, Price_Pre_Promotion__c from case where id = :c.id];
        system.assertEquals(85.00, caseResult[0].Posted_Price__c);
        system.assertEquals(100, caseResult[0].Price_Pre_Promotion__c);
        c.Posted_Price__c = null;
        c.Buyer_Price__c = null;
        CaseTransportationProcesses.beforeUpdateToggle();
        update c;

        price = 200.00;
        c.Buyer_Price__c = price-100.00;
        c.Price_Pre_Promotion__c = price;
        CaseTransportationProcesses.beforeUpdateToggle();
        update c;
        caseResult = [select id, Posted_Price__c from case where id = :c.id];
        system.assertEquals(170.00, caseResult[0].Posted_Price__c);
        System.Debug('CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }

    @isTest
    static void transporterTest(){
        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Transportation').getRecordTypeId();
        List<Account> aList = [select id, Dealership_ID__c, BillingStreet from account where name = 'buyer'];
        List<Account> bList = [select id, Dealership_ID__c, BillingStreet from account where name = 'seller'];
        List<Account> cList = [select id, Email__c, Name, Phone from account where email__c = 't1@email.com'];
        List<Account> dList = [select id, Email__c, Name, Phone from account where email__c = 't2@email.com'];
        Case c = new Case(accountid = aList[0].id, seller_dealership__c = bList[0].id, recordTypeId = titlesRecordType, Transporter_Account__c = cList[0].id);
        insert c;

        c.Transporter_Account__c = dList[0].id;
        CaseTransportationProcesses.beforeUpdateToggle();
        update c;

        List<Case> caseResult = [Select id, Transporter_Email__c from case where id = :c.id];
        system.assertEquals(caseResult[0].Transporter_Email__c, dList[0].Email__c);
        System.Debug('CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }

    @isTest
    static void addressStampTest(){
        List<Account> aList = [select id, Dealership_ID__c, BillingStreet from account where name = 'buyer'];
        List<Account> bList = [select id, Dealership_ID__c, BillingStreet from account where name = 'seller'];
        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Transportation').getRecordTypeId();
        Case parentCase = new Case(AccountId = aList[0].id, Vehicle_Location__c = 'Other');
        insert parentCase;

        if(aList.size() > 0){
            Account a = new Account(Dealership_ID__c = '123');
            Account b = new Account(Dealership_ID__c = '456');
            Case c = new Case(account = a, seller_dealership__r = b, recordTypeId = titlesRecordType, ParentId = parentCase.id);
            upsert c;
            List<Case> cList = [select Default_Delivery_Address__c, Pickup_Address__c from case where id = :c.id];
            system.assertEquals(aList[0].BillingStreet, cList[0].Default_Delivery_Address__c);
            system.assertEquals(bList[0].BillingStreet, cList[0].Pickup_Address__c);

            aList[0].BillingStreet = '222 Main St';
            CaseTransportationProcesses.beforeUpdateToggle();
            update aList;
            cList[0].Default_Delivery_Address__c = null;
            update cList;
            cList = [select Default_Delivery_Address__c from case where id = :c.id];
            system.assertEquals(aList[0].BillingStreet, cList[0].Default_Delivery_Address__c);
        }
        System.Debug('CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }
    //Process: Update Unwind Transportation Status - DONE 
    @istest 
    static void updateUnwindTransportationStatus(){
    
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Transportation').getRecordTypeId();
        Auction__c newAuction = [SELECT Id FROM Auction__c Limit 1];
        case childcase = new case(auction_number__c = newAuction.Id,status = 'Unwind Transportation Requested', recordtypeid = arbRecordtype ); // parentid= parentcase.id 
        case parentcase = new case(auction_number__c = newAuction.Id);
        
        insert parentcase;
        childcase.parentid = parentcase.id;
        insert childcase;

        parentcase = [select unwind_transportation_requested__C from case where id = :parentcase.id limit 1];
        //childcase = [select status, recordtypeid, parentid from case limit 1];
        system.assertequals(true, parentcase.unwind_transportation_requested__C);
        System.Debug('CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }

    @isTest
    static void releaseAvailableStatusChange(){
        Auction__c auc = [SELECT Id, Release_Available__c FROM Auction__c LIMIT 1];
        Case newCase = new Case(Auction_Number__c = auc.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Transportation').getRecordTypeId());
        insert newCase; 
        System.assertEquals('Awaiting Release', [SELECT Status FROM Case WHERE Auction_Number__c = :auc.Id LIMIT 1].Status);

        auc.Release_Available__c = true;
        update auc; 

        System.assertEquals('Ready-to-Post', [SELECT Id, Status FROM Case WHERE Id = :newCase.Id LIMIT 1].Status);
    }

    @isTest
    static void lockdownFinalizedTransportationCase(){
        Auction__c auc = [SELECT Id, Release_Available__c FROM Auction__c LIMIT 1];
        Case newCase = new Case(Auction_Number__c = auc.Id, Status = 'Awaiting Release', RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Transportation').getRecordTypeId());
        insert newCase; 
        System.assertEquals('Awaiting Release', [SELECT Status FROM Case WHERE Auction_Number__c = :auc.Id LIMIT 1].Status);
        
        List<Account> cList = [select id, Email__c, Name, Phone from account where email__c = 't1@email.com'];

        newCase.Status = 'Finalized';
        newCase.date_delivered_actual__c = date.today();
        newCase.posted_price__c = 10;
        newCase.transporter_account__c = cList[0].Id;
        update newCase;

        Profile p = [ SELECT Id FROM Profile WHERE Name= 'Standard User' LIMIT 1 ]; 
        User u = new User(
            Alias = 'standt', Email='standarduser@acv.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@acv.com'
        );
        insert u;

        CaseTransportationProcesses.beforeUpdateToggle( FALSE );

        Test.startTest(); 
            System.runas( u ) {
                newCase.date_transporter_paid__c = date.today();
                update newCase;
                // If an error is thrown, this is an issue

                CaseTransportationProcesses.beforeUpdateToggle( FALSE );

                newCase.Description = 'This is a late description I\'m trying to enter after the case is locked down.';
                try {
                    update newCase;
                    system.assert( false, 'This message indicates an error was not thrown when expected!' );
                } catch(exception e) {
                    system.assert( 
                        e.getMessage().contains( 'Transportation is Finalized. Please contact a System Administrator if you require changes to this case' ), 
                        'The error message thrown was unexpected: ' + e.getMessage()
                    );
                }
            }

        Test.stopTest();
    }

    @isTest
    static void lockdownFinalizedTransportationCase_StatusChange(){
        Auction__c auc = [SELECT Id, Release_Available__c FROM Auction__c LIMIT 1];
        Case newCase = new Case(Auction_Number__c = auc.Id, Status = 'Awaiting Release', RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Transportation').getRecordTypeId());
        insert newCase; 
        System.assertEquals('Awaiting Release', [SELECT Status FROM Case WHERE Auction_Number__c = :auc.Id LIMIT 1].Status);
        
        List<Account> cList = [select id, Email__c, Name, Phone from account where email__c = 't1@email.com'];

        newCase.Status = 'Finalized';
        newCase.date_delivered_actual__c = date.today();
        newCase.posted_price__c = 10;
        newCase.transporter_account__c = cList[0].Id;
        update newCase;

        Profile p = [ SELECT Id FROM Profile WHERE Name= 'Standard User' LIMIT 1 ]; 
        User u = new User(
            Alias = 'standt', Email='standarduser@acv.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@acv.com'
        );
        insert u;

        CaseTransportationProcesses.beforeUpdateToggle( FALSE );

        Test.startTest(); 
            System.runas( u ) {
                newCase.Status = 'Awaiting Release';
                newCase.Description = null;
                try {
                    update newCase;
                    system.assert( false, 'This message indicates an error was not thrown when expected!' );
                } catch ( exception e ) {
                    system.assert( 
                        e.getMessage().contains( 'Transportation is Finalized. Please contact a System Administrator if you require changes to this case' ), 
                        'The error message thrown was unexpected: ' + e.getMessage()
                    );
                }
            }

        Test.stopTest();
    }
    
    @isTest 
    static void useAlternatePickupAddress() {
        List<Account> aList = [select id, Dealership_ID__c, BillingStreet from account where name = 'buyer'];
        List<Account> bList = [select id, Dealership_ID__c, BillingStreet from account where name = 'seller'];
        List<Transportation_Address__c> tAddress = [SELECT id__c, Street__c, Notes__c FROM Transportation_Address__c];
        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Transportation').getRecordTypeId();
        Case parentCase = new Case(AccountId = aList[0].id, Vehicle_Location__c = 'Other');
        insert parentCase;

        if(aList.size() > 0){
            Account a = new Account(Dealership_ID__c = '123');
            Account b = new Account(Dealership_ID__c = '456');
            Case c = new Case(account = a, seller_dealership__r = b, recordTypeId = titlesRecordType, Pickup_Address_Lookup__c = tAddress[0].id, ParentId = parentCase.id);
            insert c;
            List<Case> cList = [select Default_Delivery_Address__c, Pickup_Address__c,Seller_Pick_up_Notes__c from case where id = :c.id];
            System.assertEquals(tAddress[0].Street__c, cList[0].Pickup_Address__c);
            System.assertEquals(tAddress[0].Notes__c, cList[0].Seller_Pick_up_Notes__c);
        }
    }

    @isTest
    static void useAlternateDeliveryAddress() {
        List<Account> aList = [select id, Dealership_ID__c, BillingStreet from account where name = 'buyer'];
        List<Account> bList = [select id, Dealership_ID__c, BillingStreet from account where name = 'seller'];
        List<Transportation_Address__c> tAddress = [SELECT id__c, Street__c, Notes__c FROM Transportation_Address__c];
        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Transportation').getRecordTypeId();
        Case parentCase = new Case(AccountId = aList[0].id, Vehicle_Location__c = 'Other');
        insert parentCase;

        if(aList.size() > 0){
            Account a = new Account(Dealership_ID__c = '123');
            Account b = new Account(Dealership_ID__c = '456');
            Case c = new Case(account = a, seller_dealership__r = b, recordTypeId = titlesRecordType, Delivery_Address_Lookup__c = tAddress[0].id, ParentId = parentCase.id);
            insert c;
            List<Case> cList = [select Default_Delivery_Address__c, Pickup_Address__c, Buyer_Pickup_Notes__c from case where id = :c.id];
            System.assertEquals(tAddress[0].Street__c, cList[0].Default_Delivery_Address__c);
            System.assertEquals(tAddress[0].Notes__c, cList[0].Buyer_Pickup_Notes__c);
        }

    }
    @isTest
    static void testToggles(){
        Boolean foo = false;
        CaseTransportationProcesses.beforeInsertToggle();
        CaseTransportationProcesses.beforeInsertToggle(foo);
        CaseTransportationProcesses.afterInsertToggle();
        CaseTransportationProcesses.afterInsertToggle(foo);
        CaseTransportationProcesses.beforeUpdateToggle();
        CaseTransportationProcesses.beforeUpdateToggle(foo);
        CaseTransportationProcesses.afterUpdateToggle();
        CaseTransportationProcesses.afterUpdateToggle(foo);
    }

}