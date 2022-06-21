@isTest
public class AccountSalesInfoTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
      List<Auction__c> newAuctions = new List<Auction__c>();
      List<Account> AccountList = new List<Account>();
      accountList.add(new Account(Name='seller',IST_Account_Owner__c =UserInfo.getUserId(),legal_Name__c='seller', dealer_type__c='1'));
      accountList.add(new Account(Name='buyer',IST_Account_Owner__c = UserInfo.getUserId(),legal_Name__c='buyer', dealer_type__c='1'));
      vehicle__c newCar = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
      insert newCar;
      insert accountList;
      
      vehicle__c car = [select id from vehicle__c limit 1];
        
      for(Integer i=0;i<100;i++){
          auction__c newAuction = new auction__c(status__c = 'Counter_Accepted', end_time__c = System.Now(),Buyer_Dealership__c = accountList[1].id, 
                                                   Seller_Dealership__c = accountList[0].id,Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = car.id);
          newAuctions.add(newAuction);   
      }
   
      insert newAuctions;    
    }

    @IsTest
    public static void testBatch(){
      
      test.startTest();
      id batchJob = Database.executeBatch(new AccountSalesPurchasesBatch(),200);
      test.stopTest();
      List<account> buyerAccount = [select id, Name, Last_90_Days_Sold__C, Last_90_Days_bought__C from Account where Name = 'buyer'];
      List<account> sellerAccount = [select id, Name, Last_90_Days_Sold__C, Last_90_Days_bought__C from Account where Name = 'seller'];
      //Integer numOfAuc = [SELECT ID FROM Auction__c].size();
      

      //System.assertEquals(numOfAuc,200);
      System.assertEquals(sellerAccount[0].Last_90_days_sold__c, 100);
      System.assertEquals(buyerAccount[0].Last_90_days_bought__c, 100);
     
    }

    @IsTest
    public static void testBatchSchedule(){
      test.startTest();
        AutoCloseDealmakerOpportunitiesScheduler batch = new AutoCloseDealmakerOpportunitiesScheduler();
        batch.executeScheduledLogic();
      test.stopTest();
      
      
    }
}