@isTest
public class TitlesAPITest {
    public static String blockedStateAPIResponse = '{"api_version": 2,"data": ["CA","NY","NJ","CT","PA","DE","KY"]}';
    public static String loginV2APIResponse = '{"jwtToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2ZjNlOWJkMS05ZTQzLTQyN2UtOTk2Yy1hMzdhMWZlMDQ0MmMiLCJqdGkiOiIxZjJmNjNkZC0zMmU5LTQzNTEtYjk2Yy0yYTdmZmRlMzE1MWUiLCJhcHBfcm9sZSI6InRvb2xfdXNlciIsIm9yZ2FuaXphdGlvbl9hZG1pbiI6IiIsImV4cCI6MTU4NTA3NDk5NCwiaXNzIjoiQUNWLlNlY3VyaXR5LkJlYXJlciIsImF1ZCI6IkFDVi5TZWN1cml0eS5CZWFyZXIifQ.LdNpqSLn_Sk4t6ew6reYClPmNVjOoGOlX65sdNVAW3o","refreshToken": "32e251e1-9817-478f-9c1a-f0b17aaca0a6","api_version": 2,"data": {"user_id": 34233,"email": "bsutton@acvauctions.com","active": true,"role": "user","session_token": "d5b8a098-5c92-4ee1-bf8a-956359745373","source": "app","registration_state": 4,"dealer_id": 4308,"dealer_type": "Franchise","dealer_active": true,"dealerships": [{"active": true,"address": "For Pick up location please call 1-800-553-4070 option 1, then option 2","dealership_type": 1,"id": 4308,"legal_name": "ACV Auctions","location": {"city": "Buffalo","region": "NY"},"member_type": "rep","name": "ACV Auctions","zip_code": "14203"}],"sorting_prefs": {"buying_ended": "all","selling_ended": "all"}}}';
    
    @IsTest
    static void testClosedStateTrue(){
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK',loginV2APIResponse,null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK',blockedStateAPIResponse,null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:ACVAuth2',loginResp);
        multiCall.put('callout:ACVAuctionData/v2/auctions/launch_blocked_regions?user_id=34233&session_token=d5b8a098-5c92-4ee1-bf8a-956359745373',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Boolean result = false;
        Test.startTest();
            result = TitlesAPI.isInBlockedRegion('NY');
        Test.stopTest();
        System.assert(result, 'False returned when is should be true');
    }

    @IsTest
    static void testClosedStateFalse(){
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK',loginV2APIResponse,null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK',blockedStateAPIResponse,null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:ACVAuth2',loginResp);
        multiCall.put('callout:ACVAuctionData/v2/auctions/launch_blocked_regions?user_id=34233&session_token=d5b8a098-5c92-4ee1-bf8a-956359745373',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Boolean result = false;
        Test.startTest();
            result = TitlesAPI.isInBlockedRegion('FL');
        Test.stopTest();
        System.assert(!result, 'True returned when is should be false');
    }

    @isTest
    static void testGetAllStates(){
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK',loginV2APIResponse,null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK',blockedStateAPIResponse,null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:ACVAuth2',loginResp);
        multiCall.put('callout:ACVAuctionData/v2/auctions/launch_blocked_regions?user_id=34233&session_token=d5b8a098-5c92-4ee1-bf8a-956359745373',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        List<String> result = new List<String>();
        Test.startTest();
            result = TitlesAPI.getAllBlockedRegions();
        Test.stopTest();
        System.assert(result.size() == 7, '7 should have been returned, something else was');
    }
}