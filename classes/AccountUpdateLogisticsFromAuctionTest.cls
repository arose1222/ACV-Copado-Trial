/**
 * @description Test class for AccountUpdateLogisticsFromAuction to ensure that Account details get updated correctly depending on Auction outcomes
 * @author Kendall Priebe
 * @since 3/28/2022
 * @group Sales
 */
@isTest
public class AccountUpdateLogisticsFromAuctionTest {
    //removed insert, upsert, and recursion tests because those are no longer issues my code will deal with
    //renamed the update test to methods Test because it makes sure all of the methods are working
    //added a bulk auctions test that makes sure the code can handle a large amount of auctions
    //added a batch test to test how the method is called from the batch
    
    public static DateTime FIRST_DATE = DateTime.newInstance(System.Today().Year(), System.Today().Month(), 15, 10, 0, 0);
    public static Date SECOND_DATE = FIRST_DATE.date().addDays(3);
    public static DateTime THIRD_DATE = FIRST_DATE.addDays(4);
    public static Date FOURTH_DATE = FIRST_DATE.date().addMonths(-1);
    public static Date FIFTH_DATE = FIRST_DATE.date().addMonths(-2);
    public static Date SIXTH_DATE = FIRST_DATE.date().addDays(-2);

    @TestSetup
    static void makeData(){
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        List<Auction__c> auctionList = new List<Auction__c>();
        List<Account> accountList = new List<Account>();
        Vehicle__c newCar = new Vehicle__c(Year__c = '2009', Make__c = 'test make', Model__c = 'test model', VIN__c = '1234567890102030');
        insert newCar;
        // Vehicle__c car = [SELECT Id FROM Vehicle__c LIMIT 1];

        //updateLastSaleDate check
        //need a seller
        Account lastSaleSeller = new Account(Name = 'lastSaleSeller', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'lastSaleSeller', dealer_type__c='1');
        accountList.add(lastSaleSeller); //accountList[0]
        //need a buyer for one of the auctions
        Account lastSaleBuyer = new Account(Name = 'lastSaleBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'lastSaleBuyer', dealer_type__c='1');
        accountList.add(lastSaleBuyer); //accountList [1]

        //insertFirstPurchaseDate check
        //need a seller - this can be a general seller for a lot of the other tests
        Account generalSeller = new Account(Name = 'generalSeller', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'generalSeller', dealer_type__c='1');
        accountList.add(generalSeller); //accountList[2]
        //need a buyer with a null Date_of_First_Buy__c
        Account firstPurchaseBuyer1 = new Account(Name = 'firstPurchaseBuyer1', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'firstPurchaseBuyer1', dealer_type__c='1');
        accountList.add(firstPurchaseBuyer1); //accountList[3]
        //need a buyer with a populated Date_of_First_Buy__c
        Account firstPurchaseBuyer2 = new Account(Name = 'firstPurchaseBuyer2', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'firstPurchaseBuyer2', dealer_type__c='1', Date_of_First_Buy__c = FIRST_DATE.date());
        accountList.add(firstPurchaseBuyer2); //accountList[4]

        //updateLastPurchaseDate check
        //use the general seller above
        //need a buyer with a null Date_of_Last_Purchase__c
        Account lastPurchaseBuyer1 = new Account(Name = 'lastPurchaseBuyer1', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'lastPurchaseBuyer1', dealer_type__c='1');
        accountList.add(lastPurchaseBuyer1); //accountList[5]
        //need a buyer with a populated Date_of_Last_Purchase__c
        Account lastPurchaseBuyer2 = new Account(Name= 'lastPurchaseBuyer2', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'lastPurchaseBuyer2', dealer_type__c='1', Date_of_Last_Purchase__c = FIRST_DATE.date());
        accountList.add(lastPurchaseBuyer2); //accountList[6]

        //updateAllTimePurchases and updateNetSales check
        //need a seller with Wholesale_Units_Sold__c = 0 - this should default to zero so no need to declare it here
        Account wholesaleSeller1 = new Account(Name = 'wholesaleSeller1', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'wholesaleSeller1', dealer_type__c='1');
        accountList.add(wholesaleSeller1); //accountList[7]
        //need a seller with Wholesale_Units_Sold__c = something greater than 0, say 3
        Account wholesaleSeller2 = new Account(Name = 'wholesaleSeller2', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'wholesaleSeller2', dealer_type__c='1', Wholesale_Units_Sold__c = 3, All_Time_Sales_Gross__c = 5);
        accountList.add(wholesaleSeller2); //accountList[8]
        //need a buyer with Purchases_All_Time__c = 0 - this should default to zero so no need to declare it here
        Account allTimeBuyer1 = new Account(Name = 'allTimeBuyer1', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'allTimeBuyer1', dealer_type__c='1');
        accountList.add(allTimeBuyer1); //accountList[9]
        //need a buyer with Purchases_All_Time__c = something greater than 0, say 5
        Account allTimeBuyer2 = new Account(Name = 'allTimeBuyer2', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'allTimeBuyer2', dealer_type__c='1', Purchases_All_Time__c = 5);
        accountList.add(allTimeBuyer2); //accountList[10]

        //updateMTDPurchased check
        //use the general seller above
        //need a buyer with MTD_Purchases__c = 3 (not going to check 0 for this one because if it works for the above, it should work here)
        Account mtdBuyer = new Account(Name = 'mtdBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'mtdBuyer', dealer_type__c='1', MTD_Purchases__c = 3);
        accountList.add(mtdBuyer); //accountList[11]

        //rollbackAllTimePurchases and rollbackNetSales check
        //need a seller with Wholesale_Units_Sold__c = 5 (not going to check 0 for this one because if it works for the above, it should work here)
        Account rNetSales = new Account(Name = 'rNetSales', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'rNetSales', dealer_type__c='1', Wholesale_Units_Sold__c = 5, All_Time_Sales_Gross__c = 7);
        accountList.add(rNetSales); //accountList[12]
        //need a buyer with Purchases_All_Time__c = 7 (not going to check 0 for this one because if it works for the above, it should work here)
        Account rAllTimeBuyer = new Account(Name = 'rAllTimeBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'rAllTimeBuyer', dealer_type__c='1', Purchases_All_Time__c = 7);
        accountList.add(rAllTimeBuyer); //accountList[13]

        //rollbackMTDAndLastMonthPurchased check
        //use the general seller above
        //need a buyer with MTD_Purchased__c = 4 and Purchase_Last_Month__c = 7
        Account rMTDandLastBuyer = new Account(Name = 'rMTDandLastBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'rMTDandLastBuyer', dealer_type__c='1', MTD_Purchases__c = 4, Purchase_Last_Month__c = 7);
        accountList.add(rMTDandLastBuyer); //accountList[14]

        //insertFirstSaleDate check
        //need a seller with a null Date_of_First_Sale__c
        Account firstSaleSeller1 = new Account(Name = 'firstSaleSeller1', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'firstSaleSeller1', dealer_type__c='1');
        accountList.add(firstSaleSeller1); //accountList[15]
        //need a seller with a populated Date_of_First_Sale__c
        Account firstSaleSeller2 = new Account(Name = 'firstSaleSeller2', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'firstSaleSeller2', dealer_type__c='1', Date_of_First_Sale__c = FIRST_DATE.date());
        accountList.add(firstSaleSeller2); //accountList[16]
        //need a buyer
        Account firstSaleBuyer = new Account(Name = 'firstSaleBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'firstSaleBuyer', dealer_type__c='1');
        accountList.add(firstSaleBuyer); //accountList [17]

        //check that batch is only picking up auctions that have both a buyer and a seller
        //need a seller
        Account onlyOneAccount = new Account(Name = 'onlyOneAccount', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'onlyOneAccount', dealer_type__c='1');
        accountList.add(onlyOneAccount); //accountList[18]

        //updateMTDSold check
        //need a seller with MTD_Sales__c = 3 (not going to check 0 for this one because if it works for the above, it should work here)
        Account mtdSoldSeller = new Account(Name = 'mtdSoldSeller', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'mtdSoldSeller', dealer_type__c='1', MTD_Sales__c = 3);
        accountList.add(mtdSoldSeller); //accountList[19]
        //need a buyer
        Account mtdSoldBuyer = new Account(Name = 'mtdSoldBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'mtdSoldBuyer', dealer_type__c='1');
        accountList.add(mtdSoldBuyer); //accountList[20]

        //rollbackMTDSold check
        //need a seller with MTD_Sales__c = 4
        Account rMTDSoldSeller = new Account(Name = 'rMTDSoldSeller', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'rMTDSoldSeller', dealer_type__c='1', MTD_Sales__c = 4);
        accountList.add(rMTDSoldSeller); //accountList[21]
        //need a buyer
        Account rMTDSoldBuyer = new Account(Name = 'rMTDSoldBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'rMTDSoldBuyer', dealer_type__c='1');
        accountList.add(rMTDSoldBuyer); //accountList[22]

        insert accountList;

        //-------------------------------------------------------------------------------------------------------------------------------------------------------------

        //updateLastSaleDate check
        //need two auctions, with different dates
        Auction__c lastSaleAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = SIXTH_DATE, Buyer_Dealership__c = accountList[1].Id, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(lastSaleAuction1);
        Auction__c lastSaleAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[1].Id, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(lastSaleAuction2);
        //should set the Date_of_Last_Sale__c date for the seller account as FIRST_DATE

        //insertFirstPurchaseDate check
        //need an auction to make sure the first purchase date is set
        Auction__c firstPurchaseAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[3].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(firstPurchaseAuction1);
        //also need an auction with end time of SECOND_DATE and a buyer of firstPurchaseBuyer2 to make sure it doesn't change
        Auction__c firstPurchaseAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = SECOND_DATE, Buyer_Dealership__c = accountList[4].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(firstPurchaseAuction2);
        //should set the Date_of_First_Buy__c for buyer1 as FIRST_DATE
        //and should not change the Date_of_First_Buy__c for buyer2 from FIRST_DATE

        //updateLastPurchaseDate check
        //need two auctions for buyer1 with end_time's of FIRST_DATE and SECOND_DATE
        Auction__c lastPurchaseAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = SIXTH_DATE, Buyer_Dealership__c = accountList[5].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(lastPurchaseAuction1);
        Auction__c lastPurchaseAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[5].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(lastPurchaseAuction2);
        //need two auctions for buyer2 with end_times's of SECOND_DATE and THIRD_DATE
        Auction__c lastPurchaseAuction3 = new Auction__c(Status__c = 'Active', End_Time__c = SECOND_DATE, Buyer_Dealership__c = accountList[6].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(lastPurchaseAuction3);
        Auction__c lastPurchaseAuction4 = new Auction__c(Status__c = 'Active', End_Time__c = THIRD_DATE, Buyer_Dealership__c = accountList[6].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(lastPurchaseAuction4);
        //buyer1 should end up with a Date_of_Last_Purchase__c of FIRST_DATE
        //and buyer2 should end up with a Date_of_Last_Purchase__c of THIRD_DATE

        //updateAllTimePurchases and updateNetSales check
        //need a few auctions for each - going to do multiple for buyer1 and a single for buyer2
        for(Integer i=0;i<3;i++){
            Auction__c allTimeAuction = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[9].Id, Seller_Dealership__c = accountList[7].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
            auctionList.add(allTimeAuction);
        }
        Auction__c allTimeAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[10].Id, Seller_Dealership__c = accountList[8].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(allTimeAuction2);
        //buyer1 should have a Purchases_All_Time__c count of 3
        //and buyer2 should have a Purchases_All_Time__c count of 6
        //seller1 should have a Wholesale_Units_Sold__c count of 3
        //seller2 should have a Wholesale_Units_Sold__c count of 4

        //updateMTDPurchased check
        //need two auctions, one from the current month and one from the previous month
        Auction__c mtdAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[11].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(mtdAuction1);
        Auction__c mtdAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FOURTH_DATE, Buyer_Dealership__c = accountList[11].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(mtdAuction2);
        //MTD_Purchases__c for buyer should be 4 because it will count the auction from this month but not the one from last month

        //rollbackAllTimePurchases and rollbackNetSales check
        //need some unwound auctions
        for(Integer i=0;i<4;i++){
            Auction__c rAllTimeAuction = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[13].Id, Seller_Dealership__c = accountList[12].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
            auctionList.add(rAllTimeAuction);
        }
        //Purchases_All_Time__c for buyer should be 3
        //Wholesale_Units_Sold__c for seller should be 1

        //rollbackMTDAndLastMonthPurchased check
        //need three unwound auctions - one from this month, one from last month, and one from two months ago
        Auction__c rMTDandLastAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[14].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(rMTDandLastAuction1);
        Auction__c rMTDandLastAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FOURTH_DATE, Buyer_Dealership__c = accountList[14].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(rMTDandLastAuction2);
        Auction__c rMTDandLastAuction3 = new Auction__c(Status__c = 'Active', End_Time__c = FIFTH_DATE, Buyer_Dealership__c = accountList[14].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(rMTDandLastAuction3);
        //MTD_Purchased__c should be 3
        //and Purchase_Last_Month__c should be 6

        //insertFirstSaleDate check
        //need an auction to make sure the first sale date is set
        Auction__c firstSaleAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[17].Id, Seller_Dealership__c = accountList[15].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(firstSaleAuction1);
        //also need an auction with end time of SECOND_DATE and a seller of firstSaleSeller2 to make sure it doesn't change
        Auction__c firstSaleAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = SECOND_DATE, Buyer_Dealership__c = accountList[17].Id, Seller_Dealership__c = accountList[16].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(firstSaleAuction2);
        //should set the Date_of_First_Sale__c for seller1 as FIRST_DATE
        //and should not change the Date_of_First_Sale__c for seller2 from FIRST_DATE

        //check that batch is only picking up auctions that have both a buyer and a seller
        //need an auction with only the seller, no buyer
        Auction__c onlyOneAccountAuc = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Seller_Dealership__c = accountList[18].Id, Floor_Price__c = 8888, Winning_Bid_Price__c = 9999, Vehicle_Id__c = newCar.Id);
        auctionList.add(onlyOneAccountAuc);
        //should not be included in the batch and should have Counted_for_Account_Logistics__c == false;

        //updateMTDSold check
        //need two auctions, one from the current month and one from the previous month
        Auction__c mtdSoldAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[20].Id, Seller_Dealership__c = accountList[19].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(mtdSoldAuction1);
        Auction__c mtdSoldAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FOURTH_DATE, Buyer_Dealership__c = accountList[20].Id, Seller_Dealership__c = accountList[19].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(mtdSoldAuction2);
        //MTD_Sales__c for seller should be 4 because it will count the auction from this month but not the one from last month

        //rollbackMTDSold check
        //need two unwound auctions - one from this month and one from last month
        Auction__c rMTDSoldAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[22].Id, Seller_Dealership__c = accountList[21].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(rMTDSoldAuction1);
        Auction__c rMTDSoldAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FOURTH_DATE, Buyer_Dealership__c = accountList[22].Id, Seller_Dealership__c = accountList[21].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = newCar.Id);
        auctionList.add(rMTDSoldAuction2);
        //MTD_Purchased__c should be 3 because it will decrease by 1 for this month but not for the one from last month

        insert auctionList;

        List<Account> checkBuyer = [SELECT Id FROM Account WHERE Name = 'rAllTimeBuyer' OR Name = 'rMTDandLastBuyer' OR Name = 'rMTDSoldBuyer'];
        List<Auction__c> updatedAuctions = [SELECT Id, Status__c, End_Time__c, Counted_for_Account_Logistics__c, Buyer_Dealership__c, Seller_Dealership__c FROM Auction__c];
        for (Auction__c auc : updatedAuctions) {
            if (auc.Buyer_Dealership__c == checkBuyer[0].Id || auc.Buyer_Dealership__c == checkBuyer[1].Id || auc.Buyer_Dealership__c == checkBuyer[2].Id) {
                auc.Status__c = 'Ended_Unwound';
                auc.Counted_for_Account_Logistics__c = true;
                // System.debug(auc.Status__c);
            }
            else {
                auc.Status__c = 'Ended_Accepted';
                // System.debug(auc.Status__c);
            }
        }
        update updatedAuctions; //having this here won't case issues, will it?
    }


    /**
     * @see https://acvauctions.atlassian.net/jira/software/projects/SI/boards/299?selectedIssue=SI-532
     */
    static void methodsTest() {
        List<Auction__c> auctionList = new List<Auction__c>();
        List<Account> accountList = new List<Account>();
        Vehicle__c newCar = new Vehicle__c(Year__c = '2009', Make__c = 'test make', Model__c = 'test model', VIN__c = '1234567890102030');
        insert newCar;
        Vehicle__c car = [SELECT Id FROM Vehicle__c LIMIT 1];
        Integer Month = System.Today().Month();
        Integer Year = System.Today().Year();
        DateTime FIRST_DATE = DateTime.newInstance(Year, Month, 15, 10, 0, 0);
        Date SECOND_DATE = FIRST_DATE.date().addDays(3);
        DateTime THIRD_DATE = FIRST_DATE.addDays(4);
        Date FOURTH_DATE = FIRST_DATE.date().addMonths(-1);
        Date FIFTH_DATE = FIRST_DATE.date().addMonths(-2);
        Date SIXTH_DATE = FIRST_DATE.date().addDays(-2);

        //updateLastSaleDate check
        //need a seller
        Account lastSaleSeller = new Account(Name = 'lastSaleSeller', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'lastSaleSeller', dealer_type__c='1');
        accountList.add(lastSaleSeller); //accountList[0]
        //need a buyer for one of the auctions
        Account lastSaleBuyer = new Account(Name = 'lastSaleBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'lastSaleBuyer', dealer_type__c='1');
        accountList.add(lastSaleBuyer); //accountList [1]

        //insertFirstPurchaseDate check
        //need a seller - this can be a general seller for a lot of the other tests
        Account generalSeller = new Account(Name = 'generalSeller', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'generalSeller', dealer_type__c='1');
        accountList.add(generalSeller); //accountList[2]
        //need a buyer with a null Date_of_First_Buy__c
        Account firstPurchaseBuyer1 = new Account(Name = 'firstPurchaseBuyer1', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'firstPurchaseBuyer1', dealer_type__c='1');
        accountList.add(firstPurchaseBuyer1); //accountList[3]
        //need a buyer with a populated Date_of_First_Buy__c
        Account firstPurchaseBuyer2 = new Account(Name = 'firstPurchaseBuyer2', IST_Account_Owner__c = UserInfo.getUserId(), Date_of_First_Buy__c = FIRST_DATE.date(), legal_name__c = 'firstPurchaseBuyer2', dealer_type__c='1');
        accountList.add(firstPurchaseBuyer2); //accountList[4]

        //updateLastPurchaseDate check
        //use the general seller above
        //need a buyer with a null Date_of_Last_Purchase__c
        Account lastPurchaseBuyer1 = new Account(Name = 'lastPurchaseBuyer1', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'lastPurchaseBuyer1', dealer_type__c='1');
        accountList.add(lastPurchaseBuyer1); //accountList[5]
        //need a buyer with a populated Date_of_Last_Purchase__c
        Account lastPurchaseBuyer2 = new Account(Name= 'lastPurchaseBuyer2', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'lastPurchaseBuyer2', dealer_type__c='1', Date_of_Last_Purchase__c = FIRST_DATE.date());
        accountList.add(lastPurchaseBuyer2); //accountList[6]

        //updateAllTimePurchases and updateNetSales check
        //need a seller with Wholesale_Units_Sold__c = 0 - this should default to zero so no need to declare it here
        Account wholesaleSeller1 = new Account(Name = 'wholesaleSeller1', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'wholesaleSeller1', dealer_type__c='1');
        accountList.add(wholesaleSeller1); //accountList[7]
        //need a seller with Wholesale_Units_Sold__c = something greater than 0, say 3
        Account wholesaleSeller2 = new Account(Name = 'wholesaleSeller2', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'wholesaleSeller2', dealer_type__c='1', Wholesale_Units_Sold__c = 3, All_Time_Sales_Gross__c = 5);
        accountList.add(wholesaleSeller2); //accountList[8]
        //need a buyer with Purchases_All_Time__c = 0 - this should default to zero so no need to declare it here
        Account allTimeBuyer1 = new Account(Name = 'allTimeBuyer1', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'allTimeBuyer1', dealer_type__c='1');
        accountList.add(allTimeBuyer1); //accountList[9]
        //need a buyer with Purchases_All_Time__c = something greater than 0, say 5
        Account allTimeBuyer2 = new Account(Name = 'allTimeBuyer2', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'allTimeBuyer2', dealer_type__c='1', Purchases_All_Time__c = 5);
        accountList.add(allTimeBuyer2); //accountList[10]

        //updateMTDPurchased check
        //use the general seller above
        //need a buyer with MTD_Purchases__c = 3 (not going to check 0 for this one because if it works for the above, it should work here)
        Account mtdBuyer = new Account(Name = 'mtdBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'mtdBuyer', dealer_type__c='1', MTD_Purchases__c = 3);
        accountList.add(mtdBuyer); //accountList[11]

        //rollbackAllTimePurchases and rollbackNetSales check
        //need a seller with Wholesale_Units_Sold__c = 5 (not going to check 0 for this one because if it works for the above, it should work here)
        Account rNetSales = new Account(Name = 'rNetSales', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'rNetSales', dealer_type__c='1', Wholesale_Units_Sold__c = 5, All_Time_Sales_Gross__c = 7);
        accountList.add(rNetSales); //accountList[12]
        //need a buyer with Purchases_All_Time__c = 7 (not going to check 0 for this one because if it works for the above, it should work here)
        Account rAllTimeBuyer = new Account(Name = 'rAllTimeBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'rAllTimeBuyer', dealer_type__c='1', Purchases_All_Time__c = 7);
        accountList.add(rAllTimeBuyer); //accountList[13]

        //rollbackMTDAndLastMonthPurchased check
        //use the general seller above
        //need a buyer with MTD_Purchased__c = 4 and Purchase_Last_Month__c = 7
        Account rMTDandLastBuyer = new Account(Name = 'rMTDandLastBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'rMTDandLastBuyer', dealer_type__c='1', MTD_Purchases__c = 4, Purchase_Last_Month__c = 7);
        accountList.add(rMTDandLastBuyer); //accountList[14]

        //insertFirstSaleDate check
        //need a seller with a null Date_of_First_Sale__c
        Account firstSaleSeller1 = new Account(Name = 'firstSaleSeller1', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'firstSaleSeller1', dealer_type__c='1');
        accountList.add(firstSaleSeller1); //accountList[15]
        //need a seller with a populated Date_of_First_Sale__c
        Account firstSaleSeller2 = new Account(Name = 'firstSaleSeller2', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'firstSaleSeller2', dealer_type__c='1', Date_of_First_Sale__c = FIRST_DATE.date());
        accountList.add(firstSaleSeller2); //accountList[16]
        //need a buyer
        Account firstSaleBuyer = new Account(Name = 'firstSaleBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'firstSaleBuyer', dealer_type__c='1');
        accountList.add(firstSaleBuyer); //accountList[17]

        //updateMTDSold check
        //need a seller with MTD_Sales__c = 3 (not going to check 0 for this one because if it works for the above, it should work here)
        Account mtdSoldSeller = new Account(Name = 'mtdSoldSeller', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'mtdSoldSeller', dealer_type__c='1', MTD_Sales__c = 3);
        accountList.add(mtdSoldSeller); //accountList[18]
        //need a buyer
        Account mtdSoldBuyer = new Account(Name = 'mtdSoldBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'mtdSoldBuyer', dealer_type__c='1');
        accountList.add(mtdSoldBuyer); //accountList[19]

        //rollbackMTDSold check
        //need a seller with MTD_Sales__c = 4
        Account rMTDSoldSeller = new Account(Name = 'rMTDSoldSeller', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'rMTDSoldSeller', dealer_type__c='1', MTD_Sales__c = 4);
        accountList.add(rMTDSoldSeller); //accountList[20]
        //need a buyer
        Account rMTDSoldBuyer = new Account(Name = 'rMTDSoldBuyer', IST_Account_Owner__c = UserInfo.getUserId(), legal_name__c = 'rMTDSoldBuyer', dealer_type__c='1');
        accountList.add(rMTDSoldBuyer); //accountList[21]

        insert accountList;

        //-------------------------------------------------------------------------------------------------------------------------------------------------------------

        //updateLastSaleDate check
        //need two auctions, with different dates
        Auction__c lastSaleAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = SIXTH_DATE, Buyer_Dealership__c = accountList[1].Id, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(lastSaleAuction1);
        Auction__c lastSaleAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[1].Id, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(lastSaleAuction2);
        //should set the Date_of_Last_Sale__c date for the seller account as FIRST_DATE

        //insertFirstPurchaseDate check
        //need an auction to make sure the first purchase date is set
        Auction__c firstPurchaseAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[3].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(firstPurchaseAuction1);
        //also need an auction with end time of SECOND_DATE and a buyer of firstPurchaseBuyer2 to make sure it doesn't change
        Auction__c firstPurchaseAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = SECOND_DATE, Buyer_Dealership__c = accountList[4].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(firstPurchaseAuction2);
        //should set the Date_of_First_Buy__c for buyer1 as FIRST_DATE
        //and should not change the Date_of_First_Buy__c for buyer2 from FIRST_DATE

        //updateLastPurchaseDate check
        //need two auctions for buyer1 with end_time's of FIRST_DATE and SECOND_DATE
        Auction__c lastPurchaseAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = SIXTH_DATE, Buyer_Dealership__c = accountList[5].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(lastPurchaseAuction1);
        Auction__c lastPurchaseAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[5].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(lastPurchaseAuction2);
        //need two auctions for buyer2 with end_times's of SECOND_DATE and THIRD_DATE
        Auction__c lastPurchaseAuction3 = new Auction__c(Status__c = 'Active', End_Time__c = SECOND_DATE, Buyer_Dealership__c = accountList[6].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(lastPurchaseAuction3);
        Auction__c lastPurchaseAuction4 = new Auction__c(Status__c = 'Active', End_Time__c = THIRD_DATE, Buyer_Dealership__c = accountList[6].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(lastPurchaseAuction4);
        //buyer1 should end up with a Date_of_Last_Purchase__c of FIRST_DATE
        //and buyer2 should end up with a Date_of_Last_Purchase__c of THIRD_DATE

        //updateAllTimePurchases and updateNetSales check
        //need a few auctions for each - going to do multiple for buyer1 and a single for buyer2
        for(Integer i=0;i<3;i++){
            Auction__c allTimeAuction = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[9].Id, Seller_Dealership__c = accountList[7].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
            auctionList.add(allTimeAuction);
        }
        Auction__c allTimeAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[10].Id, Seller_Dealership__c = accountList[8].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(allTimeAuction2);
        //buyer1 should have a Purchases_All_Time__c count of 3
        //and buyer2 should have a Purchases_All_Time__c count of 6
        //seller1 should have a Wholesale_Units_Sold__c count of 3
        //seller2 should have a Wholesale_Units_Sold__c count of 4

        //updateMTDPurchased check
        //need two auctions, one from the current month and one from the previous month
        Auction__c mtdAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[11].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(mtdAuction1);
        Auction__c mtdAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FOURTH_DATE, Buyer_Dealership__c = accountList[11].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(mtdAuction2);
        //MTD_Purchases__c for buyer should be 4 because it will count the auction from this month but not the one from last month

        //rollbackAllTimePurchases and rollbackNetSales check
        //need some unwound auctions
        for(Integer i=0;i<4;i++){
            Auction__c rAllTimeAuction = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[13].Id, Seller_Dealership__c = accountList[12].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
            auctionList.add(rAllTimeAuction);
        }
        //Purchases_All_Time__c for buyer should be 3
        //Wholesale_Units_Sold__c for seller should be 1

        //rollbackMTDAndLastMonthPurchased check
        //need three unwound auctions - one from this month, one from last month, and one from two months ago
        Auction__c rMTDandLastAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[14].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(rMTDandLastAuction1);
        Auction__c rMTDandLastAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FOURTH_DATE, Buyer_Dealership__c = accountList[14].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(rMTDandLastAuction2);
        Auction__c rMTDandLastAuction3 = new Auction__c(Status__c = 'Active', End_Time__c = FIFTH_DATE, Buyer_Dealership__c = accountList[14].Id, Seller_Dealership__c = accountList[2].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(rMTDandLastAuction3);
        //MTD_Purchased__c should be 3
        //and Purchase_Last_Month__c should be 6

        //insertFirstSaleDate check
        //need an auction to make sure the first sale date is set
        Auction__c firstSaleAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[17].Id, Seller_Dealership__c = accountList[15].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(firstSaleAuction1);
        //also need an auction with end time of SECOND_DATE and a seller of firstSaleSeller2 to make sure it doesn't change
        Auction__c firstSaleAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = SECOND_DATE, Buyer_Dealership__c = accountList[17].Id, Seller_Dealership__c = accountList[16].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(firstSaleAuction2);
        //should set the Date_of_First_Sale__c for seller1 as FIRST_DATE
        //and should not change the Date_of_First_Sale__c for seller2 from FIRST_DATE

        //updateMTDSold check
        //need two auctions, one from the current month and one from the previous month
        Auction__c mtdSoldAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[19].Id, Seller_Dealership__c = accountList[18].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(mtdSoldAuction1);
        Auction__c mtdSoldAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FOURTH_DATE, Buyer_Dealership__c = accountList[19].Id, Seller_Dealership__c = accountList[18].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(mtdSoldAuction2);
        //MTD_Sales__c for seller should be 4 because it will count the auction from this month but not the one from last month

        //rollbackMTDSold check
        //need two unwound auctions - one from this month and one from last month
        Auction__c rMTDSoldAuction1 = new Auction__c(Status__c = 'Active', End_Time__c = FIRST_DATE, Buyer_Dealership__c = accountList[21].Id, Seller_Dealership__c = accountList[20].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(rMTDSoldAuction1);
        Auction__c rMTDSoldAuction2 = new Auction__c(Status__c = 'Active', End_Time__c = FOURTH_DATE, Buyer_Dealership__c = accountList[21].Id, Seller_Dealership__c = accountList[20].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id);
        auctionList.add(rMTDSoldAuction2);
        //MTD_Purchased__c should be 3 because it will decrease by 1 for this month but not for the one from last month

        insert auctionList;


        List<Account> checkBuyer = [SELECT Id FROM Account WHERE Name = 'rAllTimeBuyer' OR Name = 'rMTDandLastBuyer' OR Name = 'rMTDSoldBuyer'];
        List<Auction__c> updatedAuctions = [SELECT Id, Status__c, End_Time__c, Counted_for_Account_Logistics__c, Buyer_Dealership__c, Seller_Dealership__c FROM Auction__c];
        for (Auction__c auc : updatedAuctions) {
            if (auc.Buyer_Dealership__c == checkBuyer[0].Id || auc.Buyer_Dealership__c == checkBuyer[1].Id || auc.Buyer_Dealership__c == checkBuyer[2].Id) {
                auc.Status__c = 'Ended_Unwound';
                auc.Counted_for_Account_Logistics__c = true;
                // System.debug(auc.Status__c);
            }
            else {
                auc.Status__c = 'Ended_Accepted';
                // System.debug(auc.Status__c);
            }
        }
        Test.startTest();
            update updatedAuctions;
            AccountUpdateLogisticsFromAuction.run(updatedAuctions);
        Test.stopTest();

        List<Account> lastSaleSellerCheck = [SELECT Id, Date_of_Last_Sale__c FROM Account WHERE Name = 'lastSaleSeller'];
        List<Account> firstPurchaseBuyer1Check = [SELECT Id, Date_of_First_Buy__c FROM Account WHERE Name = 'firstPurchaseBuyer1'];
        List<Account> firstPurchaseBuyer2Check = [SELECT Id, Date_of_First_Buy__c FROM Account WHERE Name = 'firstPurchaseBuyer2'];
        List<Account> lastPurchaseBuyer1Check = [SELECT Id, Date_of_Last_Purchase__c FROM Account WHERE Name = 'lastPurchaseBuyer1'];
        List<Account> lastPurchaseBuyer2Check = [SELECT Id, Date_of_Last_Purchase__c FROM Account WHERE Name = 'lastPurchaseBuyer2'];
        List<Account> wholesaleSeller1Check = [SELECT Id, Wholesale_Units_Sold__c, All_Time_Sales_Gross__c FROM Account WHERE Name = 'wholesaleSeller1']; //new
        List<Account> wholesaleSeller2Check = [SELECT Id, Wholesale_Units_Sold__c, All_Time_Sales_Gross__c FROM Account WHERE Name = 'wholesaleSeller2']; //new
        List<Account> allTimeBuyer1Check = [SELECT Id, Purchases_All_Time__c FROM Account WHERE Name = 'allTimeBuyer1'];
        List<Account> allTimeBuyer2Check = [SELECT Id, Purchases_All_Time__c FROM Account WHERE Name = 'allTimeBuyer2'];
        List<Account> mtdBuyerCheck = [SELECT Id, MTD_Purchases__c FROM Account WHERE Name = 'mtdBuyer'];
        List<Account> rNetSalesCheck = [SELECT Id, Wholesale_Units_Sold__c, All_Time_Sales_Gross__c FROM Account WHERE Name = 'rNetSales']; //new
        List<Account> rAllTimeBuyerCheck = [SELECT Id, Purchases_All_Time__c FROM Account WHERE Name = 'rAllTimeBuyer'];
        List<Account> rMTDandLastBuyerCheck = [SELECT Id, MTD_Purchases__c, Purchase_Last_Month__c FROM Account WHERE Name = 'rMTDandLastBuyer'];
        List<Account> firstSaleSeller1Check = [SELECT Id, Date_of_First_Sale__c FROM Account WHERE Name = 'firstSaleSeller1'];
        List<Account> firstSaleSeller2Check = [SELECT Id, Date_of_First_Sale__c FROM Account WHERE Name = 'firstSaleSeller2'];
        List<Account> mtdSoldSellerCheck = [SELECT Id, MTD_Sales__c FROM Account WHERE Name = 'mtdSoldSeller'];
        List<Account> rMTDSoldSellerCheck = [SELECT Id, MTD_Sales__c FROM Account WHERE Name = 'rMTDSoldSeller'];

        // System.debug('Last Sold: ' + lastSaleSellerCheck[0].Date_of_Last_Sale__c);
        // System.debug('Date of First Buy 1: ' + firstPurchaseBuyer1Check[0].Date_of_First_Buy__c);
        // System.debug('Date of First Buy 2: ' + firstPurchaseBuyer2Check[0].Date_of_First_Buy__c);
        // System.debug('Date of Last Purchase 1: ' + lastPurchaseBuyer1Check[0].Date_of_Last_Purchase__c);
        // System.debug('Date of Last Purchase 2: ' + lastPurchaseBuyer2Check[0].Date_of_Last_Purchase__c);
        // System.debug('Wholesale Units Sold: ' + wholesaleSeller1Check[0].Wholesale_Units_Sold__c); //new
        // System.debug('Gross Units Sold: ' + wholesaleSeller1Check[0].All_Time_Sales_Gross__c);
        // System.debug('Wholesale Units Sold: ' + wholesaleSeller2Check[0].Wholesale_Units_Sold__c); //new
        // System.debug('Gross Units Sold: ' + wholesaleSeller2Check[0].All_Time_Sales_Gross__c);
        // System.debug('All Time Purchases: ' + allTimeBuyer1Check[0].Purchases_All_Time__c);
        // System.debug('All Time Purchases: ' + allTimeBuyer2Check[0].Purchases_All_Time__c);
        // System.debug('MTD Purchases: ' + mtdBuyerCheck[0].MTD_Purchases__c);
        // System.debug('Rollback Wholesale Units Sold: ' + rNetSalesCheck[0].Wholesale_Units_Sold__c); //new
        // System.debug('Rollback Gross Units Sold: ' + wholesaleSeller1Check[0].All_Time_Sales_Gross__c);
        // System.debug('Rollback All Time Purchases: ' + rAllTimeBuyerCheck[0].Purchases_All_Time__c);
        // System.debug('Rollback MTD Purchases: ' + rMTDandLastBuyerCheck[0].MTD_Purchases__c);
        // System.debug('Rollback Last Month Purchases: ' + rMTDandLastBuyerCheck[0].Purchase_Last_Month__c);
        // System.debug('Date of First Sale 1: ' + firstSaleSeller1Check[0].Date_of_First_Sale__c);
        // System.debug('Date of First Sale 2: ' + firstSaleSeller2Check[0].Date_of_First_Sale__c);

        System.assertEquals(FIRST_DATE.date(), lastSaleSellerCheck[0].Date_of_Last_Sale__c);
        System.assertEquals(FIRST_DATE.date(), firstPurchaseBuyer1Check[0].Date_of_First_Buy__c);
        System.assertEquals(FIRST_DATE.date(), firstPurchaseBuyer2Check[0].Date_of_First_Buy__c);
        System.assertEquals(FIRST_DATE.date(), lastPurchaseBuyer1Check[0].Date_of_Last_Purchase__c);
        System.assertEquals(THIRD_DATE.date(), lastPurchaseBuyer2Check[0].Date_of_Last_Purchase__c);
        System.assertEquals(3, wholesaleSeller1Check[0].Wholesale_Units_Sold__c); //new
        System.assertEquals(3, wholesaleSeller1Check[0].All_Time_Sales_Gross__c);
        System.assertEquals(4, wholesaleSeller2Check[0].Wholesale_Units_Sold__c); //new
        System.assertEquals(6, wholesaleSeller2Check[0].All_Time_Sales_Gross__c);
        System.assertEquals(3, allTimeBuyer1Check[0].Purchases_All_Time__c);
        System.assertEquals(6, allTimeBuyer2Check[0].Purchases_All_Time__c);
        System.assertEquals(4, mtdBuyerCheck[0].MTD_Purchases__c);
        System.assertEquals(1, rNetSalesCheck[0].Wholesale_Units_Sold__c); //new
        System.assertEquals(7, rNetSalesCheck[0].All_Time_Sales_Gross__c);
        System.assertEquals(3, rAllTimeBuyerCheck[0].Purchases_All_Time__c);
        System.assertEquals(3, rMTDandLastBuyerCheck[0].MTD_Purchases__c);
        System.assertEquals(6, rMTDandLastBuyerCheck[0].Purchase_Last_Month__c);
        System.assertEquals(FIRST_DATE.date(), firstSaleSeller1Check[0].Date_of_First_Sale__c);
        System.assertEquals(FIRST_DATE.date(), firstSaleSeller2Check[0].Date_of_First_Sale__c);
        System.assertEquals(4, mtdSoldSellerCheck[0].MTD_Sales__c);
        System.assertEquals(3, rMTDSoldSellerCheck[0].MTD_Sales__c);
    }

    /**
     * @see https://acvauctions.atlassian.net/jira/software/projects/SI/boards/299?selectedIssue=SI-523
     */
    static void bulkAuctionsTest() {
        //need to make a bunch of auctions and run them through my class to make sure it can handle a large volume
        List<Auction__c> auctionList = new List<Auction__c>();
        List<Account> accountList = new List<Account>();
        Vehicle__c newCar = new Vehicle__c(Year__c = '2009', Make__c = 'test make', Model__c = 'test model', VIN__c = '1234567890102030');
        insert newCar;
        Vehicle__c car = [SELECT Id FROM Vehicle__c LIMIT 1];
        Date newDate = System.Today();

        for (Integer i = 0; i < 50; i ++) {
            accountList.add(new Account(Name = 'test', IST_Account_Owner__c = UserInfo.getUserId()));
        }
        insert accountList;

        for (Integer i = 0; i < 35; i ++){
            auctionList.add(new Auction__c(Status__c = 'Ended_Accepted', End_Time__c = newDate, Buyer_Dealership__c = accountList[i].Id, Seller_Dealership__c = accountList[(i + 1)].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        }
        
        for (Integer i = 0; i < 15; i ++) {
            auctionList.add(new Auction__c(Status__c = 'Ended_Unwound', End_Time__c = newDate, Buyer_Dealership__c = accountList[(i + 32)].Id, Seller_Dealership__c = accountList[(i + 33)].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        }
        insert auctionList;

        Test.startTest();
            AccountUpdateLogisticsFromAuction.run(auctionList);
        Test.stopTest();

        //what am i testing here? that there are no CPU timeouts? how long it takes?
    }

    /**
     * @see https://acvauctions.atlassian.net/jira/software/projects/SI/boards/299?selectedIssue=SI-529
     */
    @isTest
    static void batchTest() {
        Test.startTest();
            TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

            SchedulableContext sc = null;
            AccountLogisticsMainBatch batch = new AccountLogisticsMainBatch();
            Batch.execute(sc);
        Test.stopTest();

        List<Account> accountCheck = [SELECT Id, Name, Date_of_Last_Sale__c, Date_of_First_Buy__c, Date_of_Last_Purchase__c, Wholesale_Units_Sold__c, All_Time_Sales_Gross__c, Purchases_All_Time__c, MTD_Purchases__c, Purchase_Last_Month__c, Date_of_First_Sale__c, MTD_Sales__c FROM Account];
        List<Auction__c> onlyOneAccountAucCheck = [SELECT Id, Counted_for_Account_Logistics__c FROM Auction__c WHERE Floor_Price__c = 8888];

        for(Account acc : accountCheck) {
            switch on acc.Name {
                when 'lastSaleSeller' {
                    System.assertEquals(FIRST_DATE.date(), acc.Date_of_Last_Sale__c);
                }
                when 'firstPurchaseBuyer1' {
                    System.assertEquals(FIRST_DATE.date(), acc.Date_of_First_Buy__c);
                }
                when 'firstPurchaseBuyer2' {
                    System.assertEquals(FIRST_DATE.date(), acc.Date_of_First_Buy__c);
                }
                when 'lastPurchaseBuyer1' {
                    System.assertEquals(FIRST_DATE.date(), acc.Date_of_Last_Purchase__c);
                }
                when 'lastPurchaseBuyer2' {
                    System.assertEquals(THIRD_DATE.date(), acc.Date_of_Last_Purchase__c);
                }
                when 'wholesaleSeller1' {
                    System.assertEquals(3, acc.Wholesale_Units_Sold__c);
                    System.assertEquals(3, acc.All_Time_Sales_Gross__c);
                }
                when 'wholesaleSeller2' {
                    System.assertEquals(4, acc.Wholesale_Units_Sold__c); //new
                    System.assertEquals(6, acc.All_Time_Sales_Gross__c);
                }
                when 'allTimeBuyer1' {
                    System.assertEquals(3, acc.Purchases_All_Time__c);
                }
                when 'allTimeBuyer2' {
                    System.assertEquals(6, acc.Purchases_All_Time__c);
                }
                when 'mtdBuyer' {
                    System.assertEquals(4, acc.MTD_Purchases__c);
                }
                when 'rNetSales' {
                    System.assertEquals(1, acc.Wholesale_Units_Sold__c); //new
                    System.assertEquals(7, acc.All_Time_Sales_Gross__c);
                }
                when 'rAllTimeBuyer' {
                    System.assertEquals(3, acc.Purchases_All_Time__c);
                }
                when 'rMTDandLastBuyer' {
                    System.assertEquals(3, acc.MTD_Purchases__c);
                    System.assertEquals(6, acc.Purchase_Last_Month__c);
                }
                when 'firstSaleSeller1' {
                    System.assertEquals(FIRST_DATE.date(), acc.Date_of_First_Sale__c);
                }
                when 'firstSaleSeller2' {
                    System.assertEquals(FIRST_DATE.date(), acc.Date_of_First_Sale__c);
                }
                when 'mtdSoldSeller' {
                    System.assertEquals(4, acc.MTD_Sales__c);
                }
                when 'rMTDSoldSeller' {
                    System.assertEquals(3, acc.MTD_Sales__c);
                }
            }
        }
        System.assertEquals(false, onlyOneAccountAucCheck[0].Counted_for_Account_Logistics__c);
    }
}