@isTest
public class PredictedHighBidComponentTest {
    @TestSetup
    static void makeData(){
        List<Account> accountList = New List<Account>();
        accountList.add(new Account(Name='seller',IST_Account_Owner__c =UserInfo.getUserId()));
        accountList.add(new Account(Name='buyer',IST_Account_Owner__c = UserInfo.getUserId()));
        insert accountList;
        vehicle__c newCar = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
        insert newCar;
        auction__c newAuction = new auction__c(status__c = 'Active', end_time__c = System.Now(),Buyer_Dealership__c = accountList[0].id, 
        Seller_Dealership__c = accountList[1].id,Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = newCar.id, Name = '292599');
        insert newAuction;        
    }

    @isTest
    static void shouldGetPredictedPriceFromAuctionId(){
        Test.setMock(HttpCalloutMock.class, new PredictedHighBidMockCallout());
        Test.startTest();
        Decimal predictedHighBid = PredictedHighBidComponent.fetchPredictedHighBid('292599');
        System.assertEquals(283.0, predictedHighBid);
        Test.stopTest();
    }

    @isTest
    static void shouldReturnNegativeOneForMissingAuction(){
        Test.setMock(HttpCalloutMock.class, new PredictedHighBidMockCallout());
        Test.startTest();
        Decimal predictedHighBid = PredictedHighBidComponent.getPredictedHighBid('123456789');
        System.assertEquals(-1, predictedHighBid);
        Test.stopTest();
    }

    @isTest
    static void shouldReturnNegative500ForErrorResponseFromPredictionService(){
        Test.setMock(HttpCalloutMock.class, new PredictedHighBidMockErrorCallout(500));
        Test.startTest();
        Decimal predictedHighBid = PredictedHighBidComponent.fetchPredictedHighBid('123456789');
        System.assertEquals(-500, predictedHighBid);
        Test.stopTest();
    }

    @isTest
    static void shouldReturnNegative404For404ResponseFromPredictionService(){
        Test.setMock(HttpCalloutMock.class, new PredictedHighBidMockErrorCallout(404));
        Test.startTest();
        Decimal predictedHighBid = PredictedHighBidComponent.fetchPredictedHighBid('123456789');
        System.assertEquals(-404, predictedHighBid);
        Test.stopTest();
    }

    @isTest
    static void shouldGetPredictedPriceFromObjectId(){
        Test.setMock(HttpCalloutMock.class, new PredictedHighBidMockCallout());
        Test.startTest();
        list<auction__c> auctions = [select id from Auction__c];
        Decimal predictedHighBid = PredictedHighBidComponent.getPredictedHighBid(auctions[0].id);
        System.assertEquals(283.0, predictedHighBid);
        Test.stopTest();
    }
}