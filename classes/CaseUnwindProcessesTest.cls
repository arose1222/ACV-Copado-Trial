@isTest
public class CaseUnwindProcessesTest {
@TestSetup
    static void makeData(){
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        List<Account> accountList = New List<Account>();
        accountList.add(new Account( IST_Account_Owner__c =UserInfo.getUserId(), Name='seller', Buyer_s_assurance_exceptions__c = 'Goodwill')); 
        accountList.add(new Account( IST_Account_Owner__c =UserInfo.getUserId(), Name='buyer')); // IST_Account_Owner__c
        accountList.add(new Account(Dealership_ID__c = '456', Name='seller',legal_Name__c='seller', dealer_type__c='1',IST_Account_Owner__c =UserInfo.getUserId(),BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account(Dealership_ID__c = '123', Name='buyer',legal_Name__c='buyer', dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        insert accountList;
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(FirstName='seller', LastName='seller', accountId=accountList[0].id));
        contactList.add(new Contact(FirstName='buyer', LastName='buyer', accountId=accountList[1].id));
        insert contactList;
        vehicle__c newCar = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
        insert newCar;
        List<Auction__c> lAuctions = new List<Auction__C>();
        for(Integer i = 0;i<1;i++){
            auction__c newAuction = new auction__c(  status__c = 'Active', end_time__c = System.Now(),Buyer_Dealership__c = accountList[0].id, 
            Seller_Dealership__c = accountList[1].id,  Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = newCar.id);
            lAuctions.add(newAuction);
        }
        insert lAuctions;

        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        Case newCase = new Case( accountId = accountList[0].id, RecordTypeId = arbRecordType, Vehicle__c = newCar.id, status= 'Awaiting Release', Buyer_s_Assurance_Exceptions__c = 'Goodwill' ); //, Denial_status__C = 'Denial Pending'
        insert newCase;
        
    }

    //Process: Unwind Status change DONE
    @istest 
    static void unwindStatusChange(){
        Test.startTest();

        auction__c newauction = new auction__C();
        newauction = [select status__C from auction__C limit 1 ];
        system.debug(newauction.status__C);
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();

        case newcase = new case(status = 'Unwound', recordtypeid = arbRecordtype ); 
        newcase.auction_number__c = newauction.id;
        insert newcase;
        
        newauction = [select id, status__C from auction__C limit 1];
        system.debug(newauction.status__C);

        system.assertEquals('ended_unwound', newauction.status__C);
        System.Debug('CPU Time: ' + String.valueOf(Limits.getCpuTime()));
        Test.stopTest();
    }
    
    
    @isTest
    static void unwindProcessStampAddressOnCase(){
        Test.startTest();
        Id unwindRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();
        Auction__c newAuction = [SELECT id, buyer_dealership__c,seller_dealership__c FROM auction__C limit 1];
        Account buyerAccount = [SELECT id FROM Account WHERE BillingStreet = '123 main st' Limit 1];
        Account sellerAccount = [SELECT id FROM Account WHERE BillingStreet = '158 main st' Limit 1];
        newAuction.seller_dealership__c = sellerAccount.Id;
        newAuction.buyer_dealership__c = buyerAccount.Id;
        update newAuction;

        Case newCase = new Case(Vehicle_Location__c = 'Buyer', Auction_Number__c = newAuction.Id, RecordTypeId = unwindRecordType);
        insert newCase;
        
        buyerAccount = [SELECT BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Sales_Territory__c FROM Account WHERE Id= :newAuction.buyer_dealership__c LIMIT 1];
        newCase = [SELECT Vehicle_Location__c, Pickup_Address__c,Default_Pickup_City__c,Default_Pickup_Postal_Code__c,Default_Pickup_State__c, Default_Pickup_Country__c,Vehicle_Location_Territory__c FROM Case WHERE Id = :newCase.Id LIMIT 1];

        System.assertNotEquals(null, buyerAccount.BillingStreet);
        System.assertNotEquals(null, newCase.Pickup_Address__c);
        System.assertEquals(buyerAccount.BillingStreet, newCase.Pickup_Address__c);
        System.assertEquals(buyerAccount.BillingCity, newCase.Default_Pickup_City__c);
        System.assertEquals(buyerAccount.BillingPostalCode, newCase.Default_Pickup_Postal_Code__c); 
        System.assertEquals(buyerAccount.BillingState, newCase.Default_Pickup_State__c);
        System.assertEquals(buyerAccount.BillingCountry, newCase.Default_Pickup_Country__c);

        newCase.Vehicle_Location__c = 'Seller';
        CaseUnwindProcesses.beforeUpdateToggle();
        update newCase;

        sellerAccount = [SELECT BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Sales_Territory__c FROM Account WHERE Id= :newAuction.seller_dealership__c LIMIT 1];
        newCase = [SELECT Vehicle_Location__c, Auction_Number__c, Pickup_Address__c,Default_Pickup_City__c,Default_Pickup_Postal_Code__c,Default_Pickup_State__c, Default_Pickup_Country__c,Vehicle_Location_Territory__c FROM Case WHERE Id = :newCase.Id LIMIT 1];

        System.assertNotEquals(null, sellerAccount.BillingStreet);
        System.assertNotEquals(null, newCase.Pickup_Address__c);
        System.assertEquals(sellerAccount.BillingStreet, newCase.Pickup_Address__c);
        System.assertEquals(sellerAccount.BillingCity, newCase.Default_Pickup_City__c);
        System.assertEquals(sellerAccount.BillingPostalCode, newCase.Default_Pickup_Postal_Code__c); 
        System.assertEquals(sellerAccount.BillingState, newCase.Default_Pickup_State__c);
        System.assertEquals(sellerAccount.BillingCountry, newCase.Default_Pickup_Country__c);

        // newCase.Vehicle_Location__c = 'Other';
        // CaseUnwindProcesses.beforeUpdateToggle();
        // update newCase;

        // newCase = [SELECT Auction_Number__c, Pickup_Address__c,Default_Pickup_City__c,Default_Pickup_Postal_Code__c,Default_Pickup_State__c, Default_Pickup_Country__c,Vehicle_Location_Territory__c FROM Case WHERE Id = :newCase.Id LIMIT 1];

        // System.assertEquals(null, newCase.Pickup_Address__c);
        // System.assertEquals(null, newCase.Pickup_Address__c);
        // System.assertEquals(null, newCase.Default_Pickup_City__c);
        // System.assertEquals(null, newCase.Default_Pickup_Postal_Code__c); 
        // System.assertEquals(null, newCase.Default_Pickup_State__c);
        // System.assertEquals(null, newCase.Default_Pickup_Country__c);        
        System.Debug('CPU Time: ' + String.valueOf(Limits.getCpuTime()));
        Test.stopTest();
    }

    @isTest
    static void unwindRequestisRejected(){
        Test.startTest();
        Auction__c auc = [SELECT Id FROM Auction__c LIMIT 1];
        Case newCase = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId(), Status = 'New', Auction_Number__c = auc.Id);
        insert newCase;
        Case titleCase = new Case(RecordTypeId = Schema.SOBjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId(), Auction_Number__c = auc.Id, Status = 'New', ACV_Titles_External_ID__c='123');
        insert titleCase;
        titleCase.status = 'Working';
        update titleCase;
        System.assertEquals('New', [SELECT Id,Title_Status_1__c FROM Auction__c WHERE Id = :auc.Id].Title_Status_1__c);
        newCase.Status = 'Closed (Not Approved)';
        CaseUnwindProcesses.beforeUpdateToggle(false);
        update newCase;

        System.assertEquals('New', [SELECT Status FROM Case WHERE RecordTypeId = :Schema.SOBjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId()].Status);
        Test.stopTest();
    }
}