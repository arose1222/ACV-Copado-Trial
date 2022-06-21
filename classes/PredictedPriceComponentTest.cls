@isTest
public class PredictedPriceComponentTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
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
        Decimal predictedPrice = PredictedPriceComponent.fetchPredictedHighBid('292599');
        System.assertEquals(283.0, predictedPrice);
        Test.stopTest();
    }

    @isTest
    static void shouldReturnNegativeOneForMissingAuction(){
        Test.setMock(HttpCalloutMock.class, new PredictedHighBidMockCallout());
        Test.startTest();
        Decimal predictedPrice = PredictedPriceComponent.getPredictedHighBid('123456789');
        System.assertEquals(-1, predictedPrice);
        Test.stopTest();
    }

    @isTest
    static void shouldReturnNegative500ForErrorResponseFromPredictionService(){
        Test.setMock(HttpCalloutMock.class, new PredictedHighBidMockErrorCallout(500));
        Test.startTest();
        Decimal predictedPrice = PredictedPriceComponent.fetchPredictedHighBid('123456789');
        System.assertEquals(-500, predictedPrice);
        Test.stopTest();
    }

    @isTest
    static void shouldReturnNegative404For404ResponseFromPredictionService(){
        Test.setMock(HttpCalloutMock.class, new PredictedHighBidMockErrorCallout(404));
        Test.startTest();
        Decimal predictedPrice = PredictedPriceComponent.fetchPredictedHighBid('123456789');
        System.assertEquals(-404, predictedPrice);
        Test.stopTest();
    }

    @isTest
    static void shouldGetPredictedPriceFromObjectId(){
        Test.setMock(HttpCalloutMock.class, new PredictedHighBidMockCallout());
        Test.startTest();
        list<auction__c> auctions = [select id from Auction__c];
        Decimal predictedPrice = PredictedPriceComponent.getPredictedHighBid(auctions[0].id);
        System.assertEquals(283.0, predictedPrice);
        Test.stopTest();
    }

    @isTest
    static void shouldGetPredictedCeilingFloorPriceFromObjectId(){
        String predictionResponse = '{"floorPrice": 1000, "ceilingPrice": 1500}';
        Test.setMock(HttpCalloutMock.class, new PredictedFloorCeilingMockCallout(200, predictionResponse));
        Test.startTest();
        list<auction__c> auctions = [select id from Auction__c];
        String actualResponse = PredictedPriceComponent.getPredictedCeilingAndFloorPrice(auctions[0].id);        
        System.assertEquals(actualResponse, predictionResponse);
        Test.stopTest();
    }

    @isTest
    static void shouldReturnNullFor404ResponseFromPredictionServiceForFloorCeilingPrice(){
        Test.setMock(HttpCalloutMock.class, new PredictedFloorCeilingMockCallout(404, ''));
        Test.startTest();
        String response = PredictedPriceComponent.fetchPredictedCeilingAndFloorPrice('123456789');
        System.assertEquals(null, response);
        Test.stopTest();
    }
}