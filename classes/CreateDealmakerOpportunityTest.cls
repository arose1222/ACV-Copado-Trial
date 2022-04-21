@isTest
public class CreateDealmakerOpportunityTest {

    @TestSetup
    public static void makeData() {
        // Create 2 users:   testuser1 (Seller) and testuser2 (Buyer)
        String uniqueUserName1 = 'testuser1' + DateTime.now().getTime() + '@testorg.com';
        String uniqueUserName2 = 'testuser2' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Inside Sales - Managers'];
        List<User> newUsers = new List<User>();
        newUsers.add(new User(UserName = uniqueUserName1, LastName = 'test1', Alias = 'test1', Email = 'testuser1@testorg.com', ProfileId = p.Id, CommunityNickname = 'tEsT1', 
                              EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/New_York'));
        newUsers.add(new User(UserName = uniqueUserName2, LastName = 'test2', Alias = 'test2', Email = 'testuser2@testorg.com', ProfileId = p.Id, CommunityNickname = 'tEsT2', 
                            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/New_York'));
        insert newUsers;

        // Create 4 Accounts:   2 Sellers and 2 Buyers
        List<Account> accountList = New List<Account>();
        accountList.add(new Account(Name = '1Seller ZERO Dealership', IST_Account_Owner__c = newUsers[0].Id));
        accountList.add(new Account(Name = '2Seller ONE Dealership',  IST_Account_Owner__c = newUsers[0].Id));
        accountList.add(new Account(Name = '3Buyer TWO Dealership',   IST_Account_Owner__c = newUsers[1].Id));
        accountList.add(new Account(Name = '4Buyer THREE Dealership', IST_Account_Owner__c = newUsers[1].Id));
        insert accountList;

        // Create 2 vehicles
        List<Vehicle__c> vehicleList = New List<Vehicle__c>();
        vehicleList.add (new vehicle__c(year__c = '2011', make__c = 'test make1', model__c = 'test model1', vin__c = '1111111234567890'));
        vehicleList.add (new vehicle__c(year__c = '2012', make__c = 'test make2', model__c = 'test model2', vin__c = '2222221234567890'));
        insert vehicleList;
    }

    @isTest
    public static void testOpptyDoesNotExists() {
        /* * * * * * *  TEST <--> Opportunity does NOT already exist, so Insert NEW Opportunity  * * * * * * */
        List<User> userList = [SELECT id, Email FROM user WHERE Email LIKE '%@testorg.com%' ORDER BY LastName];
        List<Account> accountList = [select id from Account ORDER BY NAME ASC];
        List<Vehicle__c> vehicleList = [select id from Vehicle__c ORDER BY vin__c ASC];

        // New Auction created
        auction__c newAuction = new auction__c(id__c = '1234567', status__c = 'Active', end_time__c = System.Now(), Seller_Dealership__c = accountList[0].id, 
                                               Buyer_Dealership__c = accountList[2].id, Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = vehicleList[0].id);
        insert newAuction;

        // NO Opportunity should be created
        Integer numOfOps1 = [Select Id from Opportunity].size();
        System.assert(numOfOps1 == 0, 'More or less than one Opportunity exists when there should only be 0, instead found ' + numOfOps1);

        // Auction status changed to a "Failed" status
        newAuction.status__c = 'ended_declined';
        update newAuction;

        // New Oppty should be inserted since an Oppty does NOT exist for this auction
        Integer numOfOps2 = [Select Id from Opportunity].size();
        System.assert( numOfOps2 == 1, 'More or less than 1 Opportunity exists when there should only be 1, instead found ' + numOfOps2);

        // Oppty should be an Open Oppty for this auction
        Integer numOfOps3 = [Select Id from Opportunity where isClosed = FALSE].size();
        System.assert( numOfOps3 == 1, 'More or less than 1 OPEN Opportunity exists when there should only be 1 Open, instead found ' + numOfOps3);

        Opportunity checkOppty = [SELECT Id, OwnerId, Seller_IST__c, Buyer_IST__c, Auction_ID__c, isClosed FROM Opportunity];
        System.assert(checkOppty.OwnerId       == userList[0].Id, 'Opportunity OwnerID should be the Seller = ' + userList[0].Id + ', instead found ' + checkOppty.OwnerId);
        System.assert(checkOppty.Seller_IST__c == userList[0].Id, 'Opportunity Seller_IST should be the Seller = ' + userList[0].Id + ', instead found ' + checkOppty.Seller_IST__c);
        System.assert(checkOppty.Buyer_IST__c  == userList[1].Id, 'Opportunity Buyer_IST should be the Buyer = ' + userList[1].Id + ', instead found ' + checkOppty.Buyer_IST__c);
        System.assert(checkOppty.Auction_ID__c == '1234567',      'Auction_ID_c should be populated with 1234567, instead found ' + checkOppty.Auction_ID__c);
        System.assert(checkOppty.isClosed      == FALSE,          'Opportunity should be Open, instead found ' + checkOppty.isClosed);
    }

    @isTest
    public static void testOpportunitiesDoNotExist() {
        /* * * * * * *  TEST <--> MULTIPLE - Opportunities do NOT already exist, so Insert NEW Opportunities  * * * * * * */
        List<Account> accountList = [select id from Account ORDER BY NAME ASC];
        List<Vehicle__c> vehicleList = [select id from Vehicle__c ORDER BY vin__c ASC];

        // New Auction # 1234567 created
        auction__c newAuction1 = new auction__c(id__c = '1234567', status__c = 'active', end_time__c = System.Now(), Seller_Dealership__c = accountList[0].id, 
                                                Buyer_Dealership__c = accountList[2].id, Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = vehicleList[0].id);
        insert newAuction1;

        // NO Opportunity should be created for Auction # 1234567
        Integer numOfOps1 = [Select Id from Opportunity].size();
        System.assert(numOfOps1 == 0, 'More or less than one Opportunity exists when there should only be 0, instead found ' + numOfOps1);

        // Auction # 1234567 status changed to a "Failed" status
        newAuction1.status__c = 'ended_declined';
        update newAuction1;

        // New Oppty should be inserted since an Oppty does NOT exist for this auction # 1234567
        Integer numOfOps2 = [Select Id from Opportunity].size();
        System.assert(numOfOps2 == 1, 'More or less than one Opportunity exists when there should only be 1, instead found ' + numOfOps2);

        // Oppty should be an Open Oppty for this auction # 1234567
        Integer numOfOps3 = [Select Id from Opportunity where isClosed = FALSE].size();
        System.assert( numOfOps3 == 1, 'More or less than 1 OPEN Opportunity exists when there should only be 1 Open, instead found ' + numOfOps3);

        Opportunity checkOppty1 = [SELECT Id, OwnerId, Seller_IST__c, Buyer_IST__c, Auction_ID__c, isClosed FROM Opportunity];
        System.assert(checkOppty1.Auction_ID__c == '1234567', 'Auction_ID_c should be populated with 1234567, instead found ' + checkOppty1.Auction_ID__c);
        System.assert(checkOppty1.isClosed      == FALSE,     'Opportunity should be Open, instead found ' + checkOppty1.isClosed);

        // New Auction # 8901234 created
        auction__c newAuction8  = new auction__c(id__c = '8901234', status__c = 'active', end_time__c = System.Now(), Seller_Dealership__c = accountList[0].id, 
                                                Buyer_Dealership__c = accountList[2].id, Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = vehicleList[1].id);        
        insert newAuction8;

        // NO Opportunity should be created for Auction # 8901234, but Oppty does already exist for Auction # 1234567
        Integer numOfOps4 = [Select Id from Opportunity].size();
        System.assert(numOfOps4 == 1, 'More or less than one Opportunity exists when there should only be 1, instead found ' + numOfOps4);

        Opportunity checkOppty2 = [SELECT Id, OwnerId, Seller_IST__c, Buyer_IST__c, Auction_ID__c, isClosed FROM Opportunity];
        System.assert(checkOppty2.Auction_ID__c == '1234567', 'Auction_ID_c should be populated with 1234567, instead found ' + checkOppty2.Auction_ID__c);
        System.assert(checkOppty2.isClosed      == FALSE,     'Opportunity should be Open, instead found ' + checkOppty2.isClosed);

        // Auction # 8901234 status changed to a "Failed" status
        newAuction8.status__c = 'ended_declined';
        update newAuction8;

        // New Oppty should be inserted since an Oppty does NOT exist for this auction # 8901234, now there should be 2 Opptys
        Integer numOfOps5 = [Select Id from Opportunity].size();
        System.assert( numOfOps5 == 2, 'More or less than 2 Opportunities exists when there should only be 2, instead found ' + numOfOps5);

        // Should be 2 Open Opptys now, Auction # 1234567 and auction # 8901234
        Integer numOfOps6 = [Select Id from Opportunity where isClosed = FALSE].size();
        System.assert( numOfOps6 == 2, 'More or less than 2 OPEN Opportunities exists when there should only be 2 Open, instead found ' + numOfOps6);

        Opportunity checkOppty3 = [SELECT Id, OwnerId, Seller_IST__c, Buyer_IST__c, Auction_ID__c, isClosed FROM Opportunity WHERE Auction_ID__c = '8901234'];
        System.assert(checkOppty3.Auction_ID__c == '8901234', 'Auction_ID_c should be populated with 8901234, instead found ' + checkOppty3.Auction_ID__c);
        System.assert(checkOppty3.isClosed      == FALSE,     'Opportunity should be Open, instead found ' + checkOppty3.isClosed);
    }

    @isTest
    public static void testClosedOpptyExists() {
        /* * * * * * *  TEST <--> Closed Opportunity exists, so Insert NEW Opportunity  * * * * * * */
        List<User> userList = [SELECT id, Email FROM user WHERE Email LIKE '%@testorg.com%' ORDER BY LastName];
        List<Account> accountList = [select id from Account ORDER BY NAME ASC];
        List<Vehicle__c> vehicleList = [select id from Vehicle__c ORDER BY vin__c ASC];

        // New Auction # 1234567 created
        auction__c newAuction = new auction__c(id__c = '1234567', status__c = 'Active', end_time__c = System.Now(), Seller_Dealership__c = accountList[0].id, 
                                               Buyer_Dealership__c = accountList[2].id, Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = vehicleList[0].id);
        insert newAuction;

        // NO Opportunity should be created
        Integer numOfOps1 = [Select Id from Opportunity].size();
        System.assert(numOfOps1 == 0, 'More or less than one Opportunity exists when there should only be 0, instead found ' + numOfOps1);

        // Auction # 1234567 status changed to a "Failed" status
        newAuction.status__c = 'ended_declined';
        update newAuction;

        // New Oppty should be inserted since an Oppty does NOT exist for this auction # 1234567
        Integer numOfOps2 = [Select Id from Opportunity].size();
        System.assert( numOfOps2 == 1, 'More or less than 1 Opportunity exists when there should only be 1, instead found ' + numOfOps2);

        // Open Oppty should exist for this auction # 1234567
        Integer numOfOps3 = [Select Id from Opportunity where isClosed = FALSE].size();
        System.assert( numOfOps3 == 1, 'More or less than 1 OPEN Opportunity exists when there should only be 1 Open, instead found ' + numOfOps3);

        Opportunity checkOppty1 = [SELECT Id, OwnerId, Seller_IST__c, Buyer_IST__c, Auction_ID__c, isClosed FROM Opportunity];
        System.assert(checkOppty1.OwnerId       == userList[0].Id, 'Opportunity OwnerID should be the Seller = ' + userList[0].Id + ', instead found ' + checkOppty1.OwnerId);
        System.assert(checkOppty1.Seller_IST__c == userList[0].Id, 'Opportunity Seller_IST should be the Seller = ' + userList[0].Id + ', instead found ' + checkOppty1.Seller_IST__c);
        System.assert(checkOppty1.Buyer_IST__c  == userList[1].Id, 'Opportunity Buyer_IST should be the Buyer = ' + userList[1].Id + ', instead found ' + checkOppty1.Buyer_IST__c);
        System.assert(checkOppty1.Auction_ID__c == '1234567',      'Auction_ID_c should be populated with 1234567, instead found ' + checkOppty1.Auction_ID__c);
        System.assert(checkOppty1.isClosed      == FALSE,          'Opportunity should be Open, instead found ' + checkOppty1.isClosed);

        // Close this Oppty for auction # 1234567, this should result in isClosed = TRUE and blank Auction_ID__c
        checkOppty1.StageName = 'Closed Lost';
        update checkOppty1;

        Opportunity checkOppty2 = [SELECT Id, OwnerId, Seller_IST__c, Buyer_IST__c, Auction_ID__c, isClosed FROM Opportunity];
        System.assert(checkOppty2.OwnerId       == userList[0].Id, 'Opportunity OwnerID should be the Seller = ' + userList[0].Id + ', instead found ' + checkOppty2.OwnerId);
        System.assert(checkOppty2.Seller_IST__c == userList[0].Id, 'Opportunity Seller_IST should be the Seller = ' + userList[0].Id + ', instead found ' + checkOppty2.Seller_IST__c);
        System.assert(checkOppty2.Buyer_IST__c  == userList[1].Id, 'Opportunity Buyer_IST should be the Buyer = ' + userList[1].Id + ', instead found ' + checkOppty2.Buyer_IST__c);
        System.assert(checkOppty2.Auction_ID__c == null,           'Auction_ID_c should be BLANK, instead found ' + checkOppty2.Auction_ID__c);
        System.assert(checkOppty2.isClosed      == TRUE,           'Opportunity should be Open, instead found ' + checkOppty2.isClosed);

        // Auction # 1234567 status changed AGAIN to a "Failed" status
        newAuction.status__c = 'counter_original_declined';
        update newAuction;

        // New Oppty should be inserted since ONLY a CLOSED Oppty exists for this auction # 1234567
        Integer numOfOps4 = [Select Id from Opportunity].size();
        System.assert( numOfOps4 == 2, 'More or less than 2 Opportunity exists when there should only be 2, instead found ' + numOfOps4);

        // Only 1 Open Oppty exists for this auction # 1234567
        Integer numOfOps5 = [Select Id from Opportunity where isClosed = TRUE].size();
        System.assert( numOfOps5 == 1, 'More or less than 1 CLOSED Opportunity exists when there should only be 1 CLOSED, instead found ' + numOfOps5);

        Opportunity checkOppty3 = [SELECT Id, OwnerId, Seller_IST__c, Buyer_IST__c, Auction_ID__c, isClosed FROM Opportunity WHERE isClosed = FALSE];
        System.assert(checkOppty3.OwnerId       == userList[0].Id, 'Opportunity OwnerID should be the Seller = ' + userList[0].Id + ', instead found ' + checkOppty3.OwnerId);
        System.assert(checkOppty3.Seller_IST__c == userList[0].Id, 'Opportunity Seller_IST should be the Seller = ' + userList[0].Id + ', instead found ' + checkOppty3.Seller_IST__c);
        System.assert(checkOppty3.Buyer_IST__c  == userList[1].Id, 'Opportunity Buyer_IST should be the Buyer = ' + userList[1].Id + ', instead found ' + checkOppty3.Buyer_IST__c);
        System.assert(checkOppty3.Auction_ID__c == '1234567',      'Auction_ID_c should be populated with 1234567, instead found ' + checkOppty3.Auction_ID__c);
        System.assert(checkOppty3.isClosed      == FALSE,          'Opportunity should be Open, instead found ' + checkOppty3.isClosed);
    }

    @isTest
    public static void testOpenOpptyExists() {
        /* * * * * * *  TEST <--> Open Opportunity already exists, so Update Opportunity  * * * * * * */
        List<Account> accountList = [select id from Account ORDER BY NAME ASC];
        List<Vehicle__c> vehicleList = [select id from Vehicle__c ORDER BY vin__c ASC];

        // New Auction # 1234567 created
        auction__c newAuction = new auction__c(id__c = '1234567', status__c = 'Active', end_time__c = System.Now(), Seller_Dealership__c = accountList[0].id, 
                                               Buyer_Dealership__c = accountList[2].id, Floor_Price__c = 500, Winning_Bid_Price__c = 400, vehicle_id__c = vehicleList[0].id);        
        insert newAuction;

        // NO Opportunity should be created
        Integer numOfOps1 = [Select Id from Opportunity].size();
        System.assert(numOfOps1 == 0, 'More or less than one Opportunity exists when there should only be 0, instead found ' + numOfOps1);

        // Auction # 1234567 status changed to a "Failed" status
        newAuction.status__c = 'ended_declined';
        update newAuction;

        // New Oppty should be inserted since an Oppty does NOT exist for this auction # 1234567
        Integer numOfOps2 = [Select Id from Opportunity].size();
        System.assert( numOfOps2 == 1, 'More or less than one Opportunity exists when there should only be 1, instead found ' + numOfOps2);

        // Open Oppty exists for Auction #1234567, Status__c should = 'ended_declined'
        Opportunity checkOppty1 = [SELECT Id, OwnerId, Seller_IST__c, Buyer_IST__c, Auction_ID__c, isClosed, Auction__r.Status__c, Auction__r.Floor_Price__c, Auction__r.Winning_Bid_Price__c FROM Opportunity];
        System.assert(checkOppty1.auction_ID__c                   == '1234567',        'Auction_ID_c should be 1234567, instead found ' + checkOppty1.auction_ID__c);
        System.assert(checkOppty1.isClosed                        == FALSE,            'Opportunity should be Open, instead found ' + checkOppty1.isClosed);    
        System.assert(checkOppty1.auction__r.status__c            == 'ended_declined', 'Auction status__c should be ended_declined, instead found ' + checkOppty1.auction__r.status__c);
        System.assert(checkOppty1.auction__r.Floor_Price__c       == 500,              'Floor_Price__c should be 500, instead found ' + checkOppty1.auction__r.Floor_Price__c);
        System.assert(checkOppty1.auction__r.Winning_Bid_Price__c == 400,              'Winning_Bid_Price__c should be 400, instead found ' + checkOppty1.auction__r.Winning_Bid_Price__c);
        
        // Auction # 1234567 status changed AGAIN to a "Failed" status
        Test.startTest();
            newAuction.status__c            = 'counter_original_declined';
            newAuction.Floor_Price__c       = 555;
            newAuction.Winning_Bid_Price__c = 444;
            newAuction.Seller_Dealership__c = accountList[1].id;
            newAuction.Buyer_Dealership__c  = accountList[3].id;
            newAuction.end_time__c          = System.Now();

            update newAuction;

            // Open Oppty EXISTS for Auction # 1234567, so Oppty is UPDATED.  Status__c should now = 'counter_original_declined'
            Integer numOfOps3 = [Select Id from Opportunity].size();
            System.assert( numOfOps3 == 1, 'More or less than one Opportunity exists when there should only be 1, instead found ' + numOfOps3);

            Opportunity checkOppty2 = [SELECT Id, OwnerId, Seller_IST__c, Buyer_IST__c, Auction_ID__c, isClosed, Auction__r.Status__c, Auction__r.Floor_Price__c, Auction__r.Winning_Bid_Price__c FROM Opportunity];
            System.assert(checkOppty2.auction_ID__c                   == '1234567',                   'Auction_ID_c should be 1234567, instead found ' + checkOppty2.auction_ID__c);
            System.assert(checkOppty2.isClosed                        == FALSE,                       'Opportunity should be Open, instead found ' + checkOppty2.isClosed);    
            System.assert(checkOppty2.auction__r.status__c            == 'counter_original_declined', 'Auction status__c should be counter_original_declined, instead found ' + checkOppty2.auction__r.status__c);
            System.assert(checkOppty2.auction__r.Floor_Price__c       == 555,                         'Floor_Price__c should be 555, instead found ' + checkOppty2.auction__r.Floor_Price__c);
            System.assert(checkOppty2.auction__r.Winning_Bid_Price__c == 444,                          'Winning_Bid_Price__c should be 444, instead found ' + checkOppty2.auction__r.Winning_Bid_Price__c);
        Test.stopTest();

        // New Oppty should NOT be inserted But UPDATED since an Open Oppty DOES exist for this auction # 1234567
        Integer numOfOps4 = [Select Id from Opportunity].size();
        System.assert(numOfOps4 == 1, 'More or less than one Opportunity exists when there should only be 1, instead found ' + numOfOps4);
    }

    @isTest
    public static void testAuctionInsertWithBlankBuyer() {
        List<Account> accountList = [select id from Account ORDER BY NAME DESC];
        List<Vehicle__c> vehicleList = [select id from Vehicle__c ORDER BY vin__c ASC];

        // New Auction created
        auction__c newAuction = new auction__c(id__c = '1234567', status__c = 'Active', end_time__c = System.Now(), Seller_Dealership__c = accountList[0].id, 
                                               Buyer_Dealership__c = null, Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = vehicleList[0].id);
        insert newAuction;

        newAuction.status__c = 'ended_declined';
        update newAuction;

        Integer numOfOps = [Select Id from Opportunity].size();
        System.assert( numOfOps == 1, 'More or less than one Opportunity exists when there should only be 1, instead found ' + numOfOps);
    }

    @isTest
    public static void testAuctionInsertWithBlankSeller() {
        List<Account> accountList = [select id from Account ORDER BY NAME DESC];
        List<Vehicle__c> vehicleList = [select id from Vehicle__c ORDER BY vin__c ASC];

        // New Auction created
        auction__c newAuction = new auction__c(id__c = '1234567', status__c = 'Active', end_time__c = System.Now(), Seller_Dealership__c = null, 
                                               Buyer_Dealership__c = accountList[2].id, Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = vehicleList[0].id);
        insert newAuction;

        newAuction.status__c = 'ended_declined';
        update newAuction;

        Integer numOfOps = [Select Id from Opportunity].size();
        System.assert( numOfOps == 0, 'No Opportunities should exist with a BLANK Seller, instead found ' + numOfOps);
    }

    @isTest
    public static void testAuctionInsertWithBlankSellerANDBlankBuyer() {
        List<Account> accountList = [select id from Account ORDER BY NAME DESC];
        List<Vehicle__c> vehicleList = [select id from Vehicle__c ORDER BY vin__c ASC];

        // New Auction created
        auction__c newAuction = new auction__c(id__c = '1234567', status__c = 'Active', end_time__c = System.Now(), Seller_Dealership__c = null, 
                                               Buyer_Dealership__c = null, Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = vehicleList[0].id);
        insert newAuction;

        newAuction.status__c = 'ended_declined';
        update newAuction;

        Integer numOfOps = [Select Id from Opportunity].size();
        System.assert( numOfOps == 0, 'No Opportunities should exist with a BLANK Seller & BLANK Buyer, instead found ' + numOfOps);
    }
}