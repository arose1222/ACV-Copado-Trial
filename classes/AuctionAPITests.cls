@isTest
public class AuctionAPITests {


    @TestSetup
    static void makeData(){
        Vehicle__c vech = TestUtility.createVehicle();
        insert vech;
        Account acct = TestUtility.createAccount();
        insert acct;
        Contact con = TestUtility.createContact( acct );
        insert con;
        Auction__c auct = TestUtility.createAuction( acct, con, vech );
        insert auct;
        Case titleCase = TestUtility.createTitleCase( auct, acct, con );
        //titleCase.ACV_Titles_External_ID__c = '123456789';
        insert titleCase;        
    }
    
    @isTest
    static void successfulReturn(){
        Test.startTest();
        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
        List<String> imageSet = new List<String>();
        imageSet.add('odometer');
        imageSet.add('vin_plate');
        imageSet.add('vin_sticker');
        Test.setMock(HttpCalloutMock.class, new MockCalloutGoodCall());
        List<String> returnList = AuctionAPI.getSAPUrl(recordId, imageSet);
        Decimal expected = 3;
        Decimal actual = returnList.size();
        Test.stopTest();
        System.assertEquals(expected, actual);
    }

    @isTest 
    static void testSuccessfulInsert(){
        Test.startTest();
        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
        List<String> imageSet = new List<String>();
        imageSet.add('odometer');
        imageSet.add('vin_plate');
        imageSet.add('vin_sticker');
        Test.setMock(HttpCalloutMock.class, new MockCalloutGoodCall());
        AuctionAPI.getSAPUrl(recordId, imageSet);
        Boolean actual = [SELECT Repair_Order_Attached__c FROM Case WHERE Id=:recordId].Repair_Order_Attached__c;
        Boolean expected = true;
        Test.stopTest();
        System.assertEquals(expected, actual);
    }

    /* This test the creation of an AuctionKillRequest method
     * which uses the Salesforce Gateway named Crednetial
     * @return void
    */
    public static testMethod void createAuctionKillRequestTest(){
        List<Integer> auctionIds = new List<Integer>{1234, 4567};
        Integer acvUserId = 1111;
        String userEmail = 'testEmail@testEmail.test.invalid';
        String notes = 'test notes';
        HttpRequest reqTest = AuctionKillAPI.createAuctionKillRequest(auctionIds, acvUserId, userEmail, notes);

        System.assertEquals('POST', reqTest.getMethod(), 'This should be a POST method');
        System.assertEquals('application/json', reqTest.getHeader('Content-Type'), 'This should be a JSON Content-Type');
        System.assert(reqTest.getHeader('Authorization') != null, 'Authorization should be populated');
        System.assert(reqTest.getEndpoint().endsWith(AuctionKillAPI.AUCTION_KILL_ENDPOINT_SUFFIX), 'Endpoint is not correct');
        System.assertEquals('{"user_id":1111,"notes":"test notes","authorized_by":"testEmail@testEmail.test.invalid","auction_ids":[1234,4567]}', reqTest.getBody());
    }


    private class MockCalloutGoodCall implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return AuctionAPITests.processGoodResponse( req );
        }
    }

    public static HTTPResponse processGoodResponse( HTTPRequest req ) {

        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application-json');
        String body = '';
        if(req.getMethod() == 'GET'){
            System.debug('method1: ' + req.getMethod());
            body = '{    "api_version": 2,    "data": {        "id": 1070336,               "images": [           {                "image_key": "odometer",                "url": "https://s3.amazonaws.com/static-prod.acvauctions.com/vehicle_photos/9526aef518f54fb78fa9521835084c5b.jpg",                "thumbnail": "https://static-prod-vehicles-acvauctions.imgix.net/9526aef518f54fb78fa9521835084c5b.jpg?h=300&w=300",                "acv_thumbnail": "https://cdn.staging.acvauctions.com/vehicle_photos/300x300/9526aef518f54fb78fa9521835084c5b.jpg",                "acv_medium": "https://cdn.staging.acvauctions.com/vehicle_photos/600x600/9526aef518f54fb78fa9521835084c5b.jpg",                "acv_large": "https://cdn.staging.acvauctions.com/vehicle_photos/1000x1000/9526aef518f54fb78fa9521835084c5b.jpg",                "updated": null            },            {                "image_key": "vin_sticker",                "url": "https://s3.amazonaws.com/static-prod.acvauctions.com/vehicle_photos/1479669b2bd44b3f966cb8fe1de22513.jpg",                "thumbnail": "https://static-prod-vehicles-acvauctions.imgix.net/1479669b2bd44b3f966cb8fe1de22513.jpg?h=300&w=300",                "acv_thumbnail": "https://cdn.staging.acvauctions.com/vehicle_photos/300x300/1479669b2bd44b3f966cb8fe1de22513.jpg",                "acv_medium": "https://cdn.staging.acvauctions.com/vehicle_photos/600x600/1479669b2bd44b3f966cb8fe1de22513.jpg",                "acv_large": "https://cdn.staging.acvauctions.com/vehicle_photos/1000x1000/1479669b2bd44b3f966cb8fe1de22513.jpg",                "updated": null            },            {                "image_key": "vin_plate",                "url": "https://s3.amazonaws.com/static-prod.acvauctions.com/vehicle_photos/00c9436ff54e451bafaf21c1347a000d.jpg",                "thumbnail": "https://static-prod-vehicles-acvauctions.imgix.net/00c9436ff54e451bafaf21c1347a000d.jpg?h=300&w=300",                "acv_thumbnail": "https://cdn.staging.acvauctions.com/vehicle_photos/300x300/00c9436ff54e451bafaf21c1347a000d.jpg",                "acv_medium": "https://cdn.staging.acvauctions.com/vehicle_photos/600x600/00c9436ff54e451bafaf21c1347a000d.jpg",                "acv_large": "https://cdn.staging.acvauctions.com/vehicle_photos/1000x1000/00c9436ff54e451bafaf21c1347a000d.jpg",                "updated": null            }        ],        "condition_report": {            "sections": [                {                    "id": "317",                    "sort_order": "8",                    "title": "Title & History",                    "answered_affirmative": 0,                    "subsections": [                        {                            "id": "317",                            "sort_order": "1",                            "title": "",                            "section_id": "317",                            "answered_affirmative": 0,                            "questions": [                                {                                    "id": 78,                                    "title": "Title Absent (30 Days)",                                    "question_text": null,                                    "example": "",                                    "yellow_light": "0",                                    "sort_order": "1",                                    "subsection_id": "317",                                    "carfax_announcement": null,                                    "seller_disclosure": "",                                    "yes_no": 0                                },                                {                                    "id": "382",                                    "title": "Branded Title",                                    "question_text": null,                                    "example": "",                                    "yellow_light": "1",                                    "sort_order": "2",                                    "subsection_id": "317",                                    "carfax_announcement": null,                                    "seller_disclosure": "",                                    "yes_no": 0                                },                                {                                    "id": 79,                                    "title": "True Mileage Unknown",                                    "question_text": null,                                    "example": "",                                    "yellow_light": "1",                                    "sort_order": "3",                                    "subsection_id": "317",                                    "carfax_announcement": null,                                    "seller_disclosure": "",                                    "yes_no": 0                                },                                {                                    "id": "384",                                    "title": "Front Line Vehicle",                                    "question_text": null,                                    "example": "",                                    "yellow_light": "0",                                    "sort_order": "4",                                    "subsection_id": "317",                                    "carfax_announcement": null,                                    "seller_disclosure": "",                                    "yes_no": 0                                },                                {                                    "id": "385",                                    "title": "Off Lease Vehicle",                                    "question_text": null,                                    "example": "",                                    "yellow_light": "0",                                    "sort_order": "5",                                    "subsection_id": "317",                                    "carfax_announcement": null,                                    "seller_disclosure": "",                                    "yes_no": 0                                },                                {                                    "id": "386",                                    "title": "Repair Order Attached",                                    "question_text": null,                                    "example": "",                                    "yellow_light": "0",                                    "sort_order": "6",                                    "subsection_id": "317",                                    "carfax_announcement": null,                                    "seller_disclosure": "",                                    "yes_no": 1                                },                                {                                    "id": "387",                                    "title": "Repossession",                                    "question_text": null,                                    "example": "",                                    "yellow_light": "1",                                    "sort_order": "7",                                    "subsection_id": "317",                                    "carfax_announcement": null,                                    "seller_disclosure": "",                                    "yes_no": 0                                },                                {                                    "id": "390",                                    "title": "Mobility",                                    "question_text": null,                                    "example": "",                                    "yellow_light": "0",                                    "sort_order": "8",                                    "subsection_id": "317",                                    "carfax_announcement": null,                                    "seller_disclosure": "",                                    "yes_no": 0                                }                            ]                        }                    ]                }            ]        }    }}';
        }
        if(req.getMethod() == 'POST'){
            System.debug('method2: ' + req.getMethod());
            body = '{"jwtToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkM2Q5MGQxZi1iNTU3LTQ5ZTItYmYwNC00YzQxZDM1OGRlZmQiLCJqdGkiOiJmZjdhZDFhNC0xMjk5LTQyY2EtYmVkNS00NWNlZmE5ZmExZGQiLCJhcHBfcm9sZSI6InRvb2xfdXNlciIsIm9yZ2FuaXphdGlvbl9hZG1pbiI6IiIsImV4cCI6MTU4MDg0OTMwMCwiaXNzIjoiQUNWLlNlY3VyaXR5LkJlYXJlciIsImF1ZCI6IkFDVi5TZWN1cml0eS5CZWFyZXIifQ.VO-MYDAScg6VRvKqFw1I49PYTVI9SxP2HhbUG1-_Bbg","refreshToken":"9fcf4b7e-788e-4c06-ad10-e09b680af388","api_version":2,"data":{"user_id":28523,"email":"SF-DevAlerts@acvauctions.com","active":true,"role":"user","session_token":"7b6d8e40-b98e-425f-827e-6e96c1ddf3fe","source":"web","registration_state":4,"dealer_id":4308,"dealer_type":"Franchise","dealer_active":true,"dealerships":[{"active":true,"address":"","dealership_type":1,"id":4308,"legal_name":"Stone, Edwards and Smith","location":{"city":"Buffalo","region":"NY"},"member_type":"rep","name":"Stone, Edwards and Smith","zip_code":"14203"}],"sorting_prefs":{"buying_ended":"all","selling_ended":"all"}}}';
        }
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}