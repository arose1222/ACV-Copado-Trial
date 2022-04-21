@isTest
public class AuctionLightsConcatenationUpdateTest {
    @isTest
    static void runInsertTest() {
        //a seller account
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'seller', IST_Account_Owner__c = UserInfo.getUserId()));
        insert accountList;
        //a car
        Vehicle__c newCar = new Vehicle__c(Year__c = '2009', Make__c = 'test make', Model__c = 'test model', VIN__c = '1234567890102030');
        insert newCar;
        Vehicle__c car = [SELECT Id FROM Vehicle__c LIMIT 1];

        List<Auction__c> auctionList = new List<Auction__c>();
        //auction where all lights are true
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = true, Yellow_Light__c = true, Blue_Light__c = true, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        //auction where green and yellow are true
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = true, Yellow_Light__c = true, Blue_Light__c = false, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 499, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        //auction where green and blue are true
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = true, Yellow_Light__c = false, Blue_Light__c = true, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 498, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        //auction where yellow and blue are true
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = false, Yellow_Light__c = true, Blue_Light__c = true, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 497, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        //auction where only green is true
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = true, Yellow_Light__c = false, Blue_Light__c = false, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 496, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        //auction where only yellow is true
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = false, Yellow_Light__c = true, Blue_Light__c = false, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 495, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        //auction where only blue is true
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = false, Yellow_Light__c = false, Blue_Light__c = true, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 494, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        //auction where all lights are false
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = false, Yellow_Light__c = false, Blue_Light__c = false, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 493, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        insert auctionList;

        //query
        List<Auction__c> auctions = [SELECT Id, Auction_Lights_Concatenation__c FROM Auction__c ORDER BY Floor_Price__c DESC];
        //system asserts
        System.assertEquals('gyb', auctions[0].Auction_Lights_Concatenation__c);
        System.assertEquals('gy', auctions[1].Auction_Lights_Concatenation__c);
        System.assertEquals('gb', auctions[2].Auction_Lights_Concatenation__c);
        System.assertEquals('yrb', auctions[3].Auction_Lights_Concatenation__c);
        System.assertEquals('g', auctions[4].Auction_Lights_Concatenation__c);
        System.assertEquals('yr', auctions[5].Auction_Lights_Concatenation__c);
        System.assertEquals('rb', auctions[6].Auction_Lights_Concatenation__c);
        System.assertEquals('r', auctions[7].Auction_Lights_Concatenation__c);
    }

    @isTest
    static void runUpdateTest() {
        //a seller account
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'seller', IST_Account_Owner__c = UserInfo.getUserId()));
        insert accountList;
        //a car
        Vehicle__c newCar = new Vehicle__c(Year__c = '2009', Make__c = 'test make', Model__c = 'test model', VIN__c = '1234567890102030');
        insert newCar;
        Vehicle__c car = [SELECT Id FROM Vehicle__c LIMIT 1];

        //insert auctions where all lights default to false
        List<Auction__c> auctionList = new List<Auction__c>();
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = false, Yellow_Light__c = false, Blue_Light__c = false, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = false, Yellow_Light__c = false, Blue_Light__c = false, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 499, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = false, Yellow_Light__c = false, Blue_Light__c = false, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 498, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = false, Yellow_Light__c = false, Blue_Light__c = false, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 497, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = false, Yellow_Light__c = false, Blue_Light__c = false, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 496, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = false, Yellow_Light__c = false, Blue_Light__c = false, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 495, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = false, Yellow_Light__c = false, Blue_Light__c = false, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 494, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        auctionList.add(new Auction__c(Status__c = 'Active', Green_Light__c = false, Yellow_Light__c = false, Blue_Light__c = false, Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 493, Winning_Bid_Price__c = 500, Vehicle_Id__c = car.Id));
        insert auctionList;

        //update them to have all different configurations
        //auction where all lights are true
        auctionList[0].Green_Light__c = true;
        auctionList[0].Yellow_Light__c = true;
        auctionList[0].Blue_Light__c = true;
        //auction where green and yellow are true
        auctionList[1].Green_Light__c = true;
        auctionList[1].Yellow_Light__c = true;
        //auction where green and blue are true
        auctionList[2].Green_Light__c = true;
        auctionList[2].Blue_Light__c = true;
        //auction where yellow and blue are true
        auctionList[3].Yellow_Light__c = true;
        auctionList[3].Blue_Light__c = true;
        //auction where only green is true
        auctionList[4].Green_Light__c = true;
        //auction where only yellow is true
        auctionList[5].Yellow_Light__c = true;
        //auction where only blue is true
        auctionList[6].Blue_Light__c = true;
        //auction where all lights are false - no need to change the last aution, it's already going to be false
        update auctionList;

        //query
        List<Auction__c> auctions = [SELECT Id, Auction_Lights_Concatenation__c FROM Auction__c ORDER BY Floor_Price__c DESC];
        //system asserts
        System.assertEquals('gyb', auctions[0].Auction_Lights_Concatenation__c);
        System.assertEquals('gy', auctions[1].Auction_Lights_Concatenation__c);
        System.assertEquals('gb', auctions[2].Auction_Lights_Concatenation__c);
        System.assertEquals('yrb', auctions[3].Auction_Lights_Concatenation__c);
        System.assertEquals('g', auctions[4].Auction_Lights_Concatenation__c);
        System.assertEquals('yr', auctions[5].Auction_Lights_Concatenation__c);
        System.assertEquals('rb', auctions[6].Auction_Lights_Concatenation__c);
        System.assertEquals('r', auctions[7].Auction_Lights_Concatenation__c);
    }
}