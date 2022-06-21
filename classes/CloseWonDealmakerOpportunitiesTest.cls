@isTest
public class CloseWonDealmakerOpportunitiesTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        List<Account> accountList = New List<Account>();
        accountList.add(new Account(Name='seller', IST_Account_Owner__c = UserInfo.getUserId()));
        accountList.add(new Account(Name='buyer', IST_Account_Owner__c = UserInfo.getUserId()));
        insert accountList;
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(FirstName='seller', LastName='seller', accountId=accountList[0].id));
        contactList.add(new Contact(FirstName='buyer', LastName='buyer', accountId=accountList[1].id));
        insert contactList;
        vehicle__c newCar = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
        insert newCar;
    }

    @IsTest
    static void testAutoCloseDealmaker() {
      
        List<Account> accountList = [select id from Account ORDER BY NAME];
        List<Contact> contactList = [select id from Contact ORDER BY NAME];
        vehicle__c car = [select id from vehicle__c limit 1];

        auction__c newAuction = new auction__c(status__c = 'active', end_time__c = System.Now(), Buyer_Dealership__c = accountList[0].id, 
                                Seller_Dealership__c = accountList[1].id, Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = car.id);
        
        insert newAuction;

        newAuction.status__c = 'counter_original_declined';
        update newAuction;

        newAuction.status__c = 'counter_accepted';
        update newAuction;

        Integer numOfOps = [Select Id from Opportunity].size();
        System.assert( numOfOps == 1, 'More or less than one Opportunity exists when there should only be 1, instead found '+ numOfOps);
    }
}