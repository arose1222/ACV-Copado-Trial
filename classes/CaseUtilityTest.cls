@isTest
public class CaseUtilityTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        List<Account> accountList = New List<Account>();
        accountList.add(new Account(Name='seller',IST_Account_Owner__c =UserInfo.getUserId()));
        accountList.add(new Account(Name='buyer',IST_Account_Owner__c = UserInfo.getUserId()));
        insert accountList;
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(FirstName='seller', LastName='seller', accountId=accountList[0].id));
        contactList.add(new Contact(FirstName='buyer', LastName='buyer', accountId=accountList[1].id));
        insert contactList;
        vehicle__c newCar = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
        insert newCar;
        vehicle__c newCar1 = new vehicle__c(year__c='2010',make__c='test make', model__c='test model', vin__c = '1234567890102031');
        insert newCar1;
        auction__c newAuction = new auction__c(status__c = 'Active', end_time__c = System.Now(),Buyer_Dealership__c = accountList[0].id, 
        Seller_Dealership__c = accountList[1].id,Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = newCar.id);
        insert newAuction;
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Case newCase = new Case(accountId = accountList[0].id,RecordTypeId = arbRecordType, Vehicle__c = newCar.id);
        insert newCase;
    }

    @IsTest
    static void testNewArbWithAuction(){
      List<Account> accountList = [select id from account where name = 'buyer'];
      List<Auction__c> auctionList = [select id from Auction__c];
      Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
      Case newCase = new Case(Auction_Number__c = auctionList[0].id,RecordTypeId = arbRecordType);
      insert newCase;
    }

    @IsTest
    static void testNewArbWithOutAuction(){
      List<Account> accountList = [select id from account where name = 'buyer'];
      List<Auction__c> auctionList = [select id from Auction__c];
      Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
      Case newCase = new Case(accountId = accountList[0].id, RecordTypeId = arbRecordType);
      insert newCase;
    }

    @IsTest
    static void testArbUpdateVehicle(){
      List<Account> accountList = [select id from account where name = 'buyer'];
      List<Case> caseList = [select id, vehicle__c from case];
      List<vehicle__c> carList = [select id from vehicle__c where vin__c = '1234567890102031'];
      caseList[0].vehicle__c = carList[0].id;
      update caseList;
    }
    
    @IsTest
    static void testToggle(){
      CaseUtility.toggleAlreadyProcessed();
    }
}