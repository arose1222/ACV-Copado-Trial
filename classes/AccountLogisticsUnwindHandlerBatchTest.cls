@isTest
public class AccountLogisticsUnwindHandlerBatchTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        //need four dates
        Date firstDate = System.Today().addDays(-3);
        Date secondDate = System.Today().addDays(-2);
        Date thirdDate = System.Today().addDays(-1);
        Date fourthDate = System.Today();
        //need car
        Vehicle__c newCar = new Vehicle__c(Year__c='2009',Make__c='test make', Model__c='test model', VIN__c = '1234567890102030');
        insert newCar;
        Vehicle__c car = [SELECT Id FROM Vehicle__c LIMIT 1];
        //need to insert accounts with Date of First Purchase, Date of Last Purchase, and Date of Last Sale populated
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'test1', IST_Account_Owner__c = UserInfo.getUserId(), Date_of_First_Buy__c = firstDate, Flagged_for_Unwind_Batch__c = 'buyerFirst', legal_Name__c='test1', dealer_type__c='1'));
        accountList.add(new Account(Name = 'test2', IST_Account_Owner__c = UserInfo.getUserId(), Date_of_Last_Purchase__c = thirdDate, Flagged_for_Unwind_Batch__c = 'buyerLast', legal_Name__c='test2', dealer_type__c='1'));
        accountList.add(new Account(Name = 'test3', IST_Account_Owner__c = UserInfo.getUserId(), Date_of_Last_Sale__c = fourthDate, Flagged_for_Unwind_Batch__c = 'seller', legal_Name__c='test3', dealer_type__c='1'));
        accountList.add(new Account(Name = 'test4', IST_Account_Owner__c = UserInfo.getUserId(), Flagged_for_Unwind_Batch__c = 'error plz', legal_Name__c='test4', dealer_type__c='1'));
        insert accountList;
        //need to insert some active auctions
        List<Auction__c> auctionList = new List<Auction__c>();
        auctionList.add(new Auction__c(Status__c = 'Active', End_Time__c = firstDate, Buyer_Dealership__c = accountList[0].Id, Seller_Dealership__c = accountList[1].Id, Counted_for_Account_Logistics__c = true, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Active', End_Time__c = thirdDate, Buyer_Dealership__c = accountList[1].Id, Seller_Dealership__c = accountList[1].Id, Counted_for_Account_Logistics__c = true, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Active', End_Time__c = fourthDate, Seller_Dealership__c = accountList[2].Id, Counted_for_Account_Logistics__c = true, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Active', End_Time__c = fourthDate, Buyer_Dealership__c = accountList[3].Id, Seller_Dealership__c = accountList[1].Id, Counted_for_Account_Logistics__c = true, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Ended_Accepted', End_Time__c = secondDate, Buyer_Dealership__c = accountList[0].Id, Seller_Dealership__c = accountList[1].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Ended_Accepted', End_Time__c = secondDate, Buyer_Dealership__c = accountList[1].Id, Seller_Dealership__c = accountList[1].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Ended_Accepted', End_Time__c = thirdDate, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        insert auctionList;
    }

    // @isTest
    // static void scheduleBatch() {    
    //     delete [ SELECT Id FROM Account LIMIT 3 ]; // remove accounts to allow single batch instance to run
    //     Test.startTest();
    //         SchedulableAccountUnwindHandler schClass = new SchedulableAccountUnwindHandler();
    //         schClass.executeScheduledLogic();
    //     Test.stopTest();
    // }

    @isTest
    static void batchTest() {
        List<Auction__c> auctionList = [SELECT Id, Status__c FROM Auction__c WHERE Status__c = 'Active'];
        for (Auction__c a : auctionList) {
            a.Status__c = 'Ended_Unwound';
        }
        update auctionList;
        //startTest and stopTest containing the call for the batch
        Test.startTest();
			AccountUpdateLogisticsUnwindHandlerBatch auluhb = new AccountUpdateLogisticsUnwindHandlerBatch();
			Database.executeBatch(auluhb, 5);
            //if the batch size is set to 1 in test code and it's tying to update on more than one account it will fail
            //setting to 5 for testing purposes only
        Test.stopTest();
        //query the accounts
        List<Account> buyerAccount1 = [SELECT Id, Date_of_First_Buy__c FROM Account WHERE Name = 'test1'];
        List<Account> buyerAccount2 = [SELECT Id, Date_of_Last_Purchase__c FROM Account WHERE Name = 'test2'];
        List<Account> sellerAccount = [SELECT Id, Date_of_Last_Sale__c FROM Account WHERE Name = 'test3'];
        //make the two dates
        Date secondDate = System.Today().addDays(-2);
        Date thirdDate = System.Today().addDays(-1);
        //system asserts
        System.assertEquals(secondDate, buyerAccount1[0].Date_of_First_Buy__c);
        System.assertEquals(secondDate, buyerAccount2[0].Date_of_Last_Purchase__c);
        System.assertEquals(thirdDate, sellerAccount[0].Date_of_Last_Sale__c);
    }

    // @isTest
    // static void buyerLastTest() {
    //     //need some dates
    //     //date for first purchase:
    //     Date firstDate = System.Today().addDays(-2);
    //     //date for last purchase will have to be today() or match the date for the auction we enter in as unwound
    //     Date secondDate = System.Today();
    //     //need date for first accepted auction
    //     Date thirdDate = System.Today().addDays(-1);
        
    //     //need a car
    //     Vehicle__c newCar = new Vehicle__c(Year__c='2009',Make__c='test make', Model__c='test model', VIN__c = '1234567890102030');
    //     insert newCar;
    //     Vehicle__c car = [SELECT Id FROM Vehicle__c LIMIT 1];

    //     //need two accounts
    //     List<Account> accountList = new List<Account>();
    //     //one for buyer
    //     accountList.add(new Account(Name = 'test1', IST_Account_Owner__c = UserInfo.getUserId(), Date_of_First_Buy__c = firstDate, Date_of_Last_purchase__c = secondDate));
    //     //one for seller
    //     accountList.add(new Account(Name = 'seller', IST_Account_Owner__c = UserInfo.getUserId()));
    //     //insert accounts
    //     insert accountList;

    //     //need two auctions
    //     List<Auction__c> auctionList = new List<Auction__c>();
    //     //need an accepted auction that ended between the first and last purchase date
    //     auctionList.add(new Auction__c(Status__c = 'Ended_Accepted', End_Time__c = thirdDate, Buyer_Dealership__c = accountList[0].Id, Seller_Dealership__c = accountList[1].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
    //     //need an auction that starts as ended
    //     auctionList.add(new Auction__c(Status__c = 'Counter_Accepted', End_Time__c = secondDate, Buyer_Dealership__c = accountList[0].Id, Seller_Dealership__c = accountList[1].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
    //     //insert auctions
    //     insert auctionList;

    //     //update the second accepted auction to unwound
    //     List<Auction__c> auctions = [SELECT Id, Status__c FROM Auction__c WHERE Status__c = 'Counter_Accepted'];
    //     System.debug('Auctions to update to unwound: ' + auctions);
    //     for (Auction__c a : auctions) {
    //         a.Status__c = 'Ended_Unwound';
    //         System.debug(a.Status__c);
    //     }
    //     update auctions;

    //     Test.startTest();
    //         SchedulableAccountUnwindHandler schClass = new SchedulableAccountUnwindHandler();
    //         String schedule = '0 0 23 * * ?';
    //         System.schedule('Test Auction Unwind Check', schedule, schClass);
	// 		AccountUpdateLogisticsUnwindHandlerBatch auluhb = new AccountUpdateLogisticsUnwindHandlerBatch();
	// 		Database.executeBatch(auluhb, 5);
    //         //if the batch size is set to 1 in test code and it's tying to update on more than one account it will fail
    //         //setting to 5 for testing purposes only
    //     Test.stopTest();
        
    //     Account buyer = [SELECT Id, Date_of_Last_Purchase__c FROM Account WHERE Name = 'test1'];
    //     //check what the date of last purchase is at the end of all of this
    //     System.assertEquals(thirdDate, buyer.Date_of_Last_Purchase__c);
    // }
}