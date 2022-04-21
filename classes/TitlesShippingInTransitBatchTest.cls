//@isTest
public class TitlesShippingInTransitBatchTest {
/*    
    public static string easyPostTrackerResponse = '{ "trackers": [ { "id": "trk_5fa556216e64499e9557dcdeec6acf84", "object": "Tracker", "mode": "test", "tracking_code": "794693306003", "status": "in_transit", "status_detail": "arrived_at_destination", "created_at": "2020-03-25T23:35:38Z", "updated_at": "2020-03-25T23:38:38Z", "signed_by": "John Tester", "weight": 17.6, "est_delivery_date": "2020-03-25T23:38:38Z", "shipment_id": "shp_1667eb589e524d1aa8875916a3e57c44", "carrier": "FedEx", "tracking_details": [ { "object": "TrackingDetail", "message": "Shipment information sent to FedEx", "description": null, "status": "pre_transit", "status_detail": "status_update", "datetime": "2020-02-26T14:02:38Z", "source": "FedEx", "carrier_code": null, "tracking_location": { "object": "TrackingLocation", "city": null, "state": null, "country": null, "zip": null } }, { "object": "TrackingDetail", "message": "Picked up", "description": null, "status": "in_transit", "status_detail": "arrived_at_facility", "datetime": "2020-02-26T14:26:38Z", "source": "FedEx", "carrier_code": null, "tracking_location": { "object": "TrackingLocation", "city": "NEW YORK", "state": "NY", "country": "US", "zip": "10014" } }, { "object": "TrackingDetail", "message": "Departed FedEx location", "description": null, "status": "in_transit", "status_detail": "departed_facility", "datetime": "2020-02-27T08:29:38Z", "source": "FedEx", "carrier_code": null, "tracking_location": { "object": "TrackingLocation", "city": "MEMPHIS", "state": "TN", "country": "US", "zip": "38118" } }, { "object": "TrackingDetail", "message": "At destination sort facility", "description": null, "status": "in_transit", "status_detail": "arrived_at_facility", "datetime": "2020-02-28T09:09:38Z", "source": "FedEx", "carrier_code": null, "tracking_location": { "object": "TrackingLocation", "city": "ATLANTA", "state": "GA", "country": "US", "zip": "30320" } }, { "object": "TrackingDetail", "message": "At local FedEx facility", "description": null, "status": "in_transit", "status_detail": "arrived_at_facility", "datetime": "2020-02-28T14:02:38Z", "source": "FedEx", "carrier_code": null, "tracking_location": { "object": "TrackingLocation", "city": "MARIETTA", "state": "GA", "country": "US", "zip": "30067" } }, { "object": "TrackingDetail", "message": "On FedEx vehicle for delivery", "description": null, "status": "out_for_delivery", "status_detail": "out_for_delivery", "datetime": "2020-02-29T07:48:38Z", "source": "FedEx", "carrier_code": null, "tracking_location": { "object": "TrackingLocation", "city": "MARIETTA", "state": "GA", "country": "US", "zip": "30067" } }, { "object": "TrackingDetail", "message": "Delivered", "description": null, "status": "delivered", "status_detail": "arrived_at_destination", "datetime": "2020-02-29T15:11:38Z", "source": "FedEx", "carrier_code": null, "tracking_location": { "object": "TrackingLocation", "city": "ATLANTA", "state": "GA", "country": "US", "zip": "30320" } } ], "carrier_detail": { "object": "CarrierDetail", "service": "FEDEX_GROUND", "container_type": "YOUR_PACKAGING", "est_delivery_date_local": "2877-09-28", "est_delivery_time_local": "23:38:38", "origin_location": "NEW YORK NY US", "origin_tracking_location": { "object": "TrackingLocation", "city": "NEW YORK", "state": "NY", "country": "US", "zip": "10014" }, "destination_location": "ATLANTA GA US", "destination_tracking_location": { "object": "TrackingLocation", "city": "ATLANTA", "state": "GA", "country": "US", "zip": "30320" }, "guaranteed_delivery_date": null, "alternate_identifier": null, "initial_delivery_attempt": "2020-02-29T15:11:38Z" }, "finalized": true, "is_return": false, "public_url": "https://track.easypost.com/djE6dHJrXzVmYTU1NjIxNmU2NDQ5OWU5NTU3ZGNkZWVjNmFjZjg0", "fees": [] } ], "has_more": false }';

    @TestSetup
    static void makeData(){
        TestUtility.createAccount();
        final Id TITLE_CASE_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Title_Information' ).getRecordTypeId();
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        // User usah = new User(
        //     LastName = 'gamer',
        //     Username = 'gamer@420.com',
        //     Email = 'gamer@420.com',
        //     TimeZoneSidKey = 'America/New_York',
        //     EmailEncodingKey = 'UTF-8',
        //     LanguageLocaleKey = 'en_US',
        //     LocaleSidKey = 'en_US',
        //     Alias = 'admSU3',
        //     ProfileId = profile.id
        //     );
        User usah = TestUtility.createUser();
        insert usah;
        Account actObj = TestUtility.createAccount();
        actObj.BillingStreet = '8369 Lower East Hill Rd';
        actObj.BillingCity = 'Colden';
        actObj.BillingState = 'NY';
        actObj.BillingCountry = 'US';
        actObj.BillingPostalCode = '14033';
        actObj.Name = 'test account';
        insert actObj;
        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;
        Vehicle__c vehicleObj = TestUtility.createVehicle();
        insert vehicleObj;
        Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
        auctionObj.Payment_Status__c = 'Pending';
        auctionObj.Payment_Method__c = 'ach';
    	insert auctionObj;
        Case caseObj =  TestUtility.createTitleCase(auctionObj, actObj, contactObj);
        caseObj.Seller_Dealership__c = actObj.id;
        caseObj.Easypost_Tracker__c = '794693306003';
        caseObj.Digital_Title__c = true;
        insert caseObj;
    }

    @isTest
    static void testTrackingUpdate(){
        TestingUtility.SingleRequestMock trackingCall = new TestingUtility.SingleRequestMock(200,'OK',easyPostTrackerResponse,null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:EasyPost/v2/trackers?tracking_code=794693306003', trackingCall);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Test.startTest();
            TitlesShippingInTransitBatch batch = new TitlesShippingInTransitBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();

        System.assert([select id from case where status = 'Sent'].size() > 0, 'Status Not Updated by Tracking');
    }*/
}