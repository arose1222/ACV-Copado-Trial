@isTest
public class EngineAudioComponentTest {

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

    @isTest
    static void testGettingData(){
        Test.setMock(HttpCalloutMock.class, new EngineAudioPlayerMockCallout());
        list<Case> caseList = [select id from case];
        Test.startTest();
        EngineAudioPlayerComponent.getAudioLink(caseList[0].id);
        Test.stopTest();
    }
}