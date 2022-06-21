@istest
public class AcvIntegrationQueueableJobTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Test.startTest();
            Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
            String body = '{"status":"ok"}';
            Integer code = 200;
            String status = 'OK';
            Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders));

            Account actObj = TestUtility.createAccount();
            insert actObj;
            Contact contactObj = TestUtility.createContact(actObj);
            insert contactObj;
            Vehicle__c vehicleObj = TestUtility.createVehicle();
            Insert vehicleObj;
            Auction__c auctionObj = TestUtility.createAuction(actObj, contactObj, vehicleObj);
            insert auctionObj;
        Test.stopTest();
    }
    
    @isTest static void testPostCalloutCreateArb(){
        Auction__c auctionObj = [SELECT id, id__c, floor_price__c, Name, notes__c, vehicle_id__c FROM Auction__c LIMIT 1];
        Vehicle__c vehicleObj = [SELECT id,basic_color__c,class_name__c,drivetrain__c,fuel_type__c,model__c,msrp__c,Name FROM Vehicle__c LIMIT 1];
        Account actObj = [SELECT id,Name FROM Account LIMIT 1];
        Contact contactObj = [SELECT id,firstName,LastName,Email,AccountId FROM Contact LIMIT 1]; 
        Case CaseObj = TestUtility.createCase(auctionObj,vehicleObj,actObj,contactObj);
        insert CaseObj;

        Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"status":"ok"}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders)); 
        
        Test.startTest();
            Case co = [SELECT id,createdbyid,IsClosed FROM Case LIMIT 1];
            System.enqueueJob(New AcvIntegrationQueueableJob('Create Arb',New List<Case>{co},null));
        Test.stopTest();    
    }

    @isTest static void testPostCalloutCreateComplaint(){
        Auction__c auctionObj = [SELECT id, id__c, floor_price__c, Name, notes__c, vehicle_id__c FROM Auction__c LIMIT 1];
        Vehicle__c vehicleObj = [SELECT id,basic_color__c,class_name__c,drivetrain__c,fuel_type__c,model__c,msrp__c,Name FROM Vehicle__c LIMIT 1];
        Account actObj = [SELECT id,Name FROM Account LIMIT 1];
        Contact contactObj = [SELECT id,firstName,LastName,Email,AccountId FROM Contact LIMIT 1]; 
        Case CaseObj = TestUtility.createCase(auctionObj,vehicleObj,actObj,contactObj);
        insert CaseObj;
        Complaint__c complaintObj = TestUtility.createComplaint(CaseObj);
        insert complaintObj;

        Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"status": "ok", "user_id": 123, "session_token": "TOKEN", "api_version": 2, "data": {"arbitration_id": 97, "avoidable": true, "complaint_type": 1, "SF_Claim_Parent_Type": "Driveability", "sf_claim_type": "Brakes Inop", "created_by": "hadmi", "description": "Airbag Light Update Test 22222", "id": 153, "insurance": false, "valid": true}}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders)); 
        
        Test.startTest();
            Complaint__c co = [SELECT id,complaint_type__c,valid__c,description__c,CreatedById,claim_type__c,Claim_Parent_Type__c,avoidable__c, insurance__c,Auction_Number_Complaint__c FROM Complaint__c LIMIT 1];
            System.enqueueJob(New AcvIntegrationQueueableJob('Create Complaint',New List<Complaint__c>{co},null));
        Test.stopTest();  
    }
    @isTest static void testPostCalloutAdjustment(){
        Auction__c auctionObj = [SELECT id, id__c, floor_price__c, Name, notes__c, vehicle_id__c FROM Auction__c LIMIT 1];
        Vehicle__c vehicleObj = [SELECT id,basic_color__c,class_name__c,drivetrain__c,fuel_type__c,model__c,msrp__c,Name FROM Vehicle__c LIMIT 1];
        Account actObj = [SELECT id,Name FROM Account LIMIT 1];
        Contact contactObj = [SELECT id,firstName,LastName,Email,AccountId FROM Contact LIMIT 1]; 
        Case CaseObj = TestUtility.createCase(auctionObj,vehicleObj,actObj,contactObj);
        insert CaseObj;
        Complaint__c complaintObj = TestUtility.createComplaint(CaseObj);
        insert complaintObj;

        Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"status": "ok", "user_id": 123, "session_token": "TOKEN", "data": { "id": 123}}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders)); 
        
        Test.startTest();
            Resolution__c res = New Resolution__c(Case__c = CaseObj.Id,Amount__c=1000,Resolution__c='ACV Issue Check',Goodwill__c=True,
                                                LastModifiedDate=System.now());
            System.enqueueJob(New AcvIntegrationQueueableJob('Update Adjustment',New List<Resolution__c>{res},null));
        Test.stopTest();  
    }

    @isTest static void testPostCalloutTitle(){
        //Create test title record to pass into queued job call
        Auction__c auctionObj = [SELECT id, id__c, floor_price__c, Name, notes__c, vehicle_id__c FROM Auction__c LIMIT 1];
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case caseObj = new Case(
            Status = 'Received',
            Auction_Number__c = auctionObj.Id,
            Subject = 'Title Testing',
            RecordTypeId = caseRecordTypeId,
            ACV_Titles_External_ID__c = '123456789'
        );
        insert caseObj;

        Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"status": "ok", "user_id": 123, "session_token": "TOKEN", "api_version": 2,"data": {"errors": [{"attempted_update": {"auction_id": 3002,"title_state": "rts"},"error": {"message": "No title was found for auction ID 3002","name": "NoTitleFoundException"}}],"successes": [{"auction_id": '+auctionObj.id__c+',"title_state": "received"},{"auction_id": 3003,"title_state": "received"}]}}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders)); 
        
        Test.startTest();
            List<Case> lTitles = [SELECT id, status, ACV_Titles_External_ID__c, Auction_Number_Case__c, Title_Received_Date__c, Title_Sent_Date__c, Easypost_Tracker__c
                        FROM Case
                        WHERE ID = :caseObj.Id];
            System.debug('title cases:'+lTitles);
            System.enqueueJob(New AcvIntegrationQueueableJob('Update Title',lTitles,null));
        Test.stopTest();
    }

    @isTest static void testPostCalloutTitleBatch(){
        //Create test title record to pass into queued job call
        Auction__c auctionObj = [SELECT id, id__c, floor_price__c, Name, notes__c, vehicle_id__c FROM Auction__c LIMIT 1];
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case caseObj = new Case(
            Status = 'Received',
            Auction_Number__c = auctionObj.Id,
            Subject = 'Title Testing',
            RecordTypeId = caseRecordTypeId,
            Send_To_ACV__c = true,
            ACV_Titles_External_ID__c = '123456789'
        );
        insert caseObj;

        Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"status": "ok", "user_id": 123, "session_token": "TOKEN", "api_version": 2,"data": {"errors": [{"attempted_update": {"auction_id": 3002,"title_state": "rts"},"error": {"message": "No title was found for auction ID 3002","name": "NoTitleFoundException"}}],"successes": [{"auction_id": '+auctionObj.id__c+',"title_state": "received"},{"auction_id": 3003,"title_state": "received"}]}}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders)); 
        
        Test.startTest();
            BatchTitleOutbound batchClass = new BatchTitleOutbound();
            database.executebatch(batchClass,200);
        Test.stopTest();
    }

    @isTest static void testPostCalloutPricing(){
        //Create test recommended price record to pass into queued job call
        Auction__c auctionObj = [SELECT id, id__c, floor_price__c, Name, notes__c, vehicle_id__c FROM Auction__c LIMIT 1];
        Vehicle__c vehicleObj = [SELECT id,basic_color__c,class_name__c,drivetrain__c,fuel_type__c,model__c,msrp__c,Name FROM Vehicle__c LIMIT 1];
        Recommended_Price__c recomPriceObj = TestUtility.createRecommended_Price(auctionObj,vehicleObj);
        insert recomPriceObj;

        Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"status": "ok", "user_id": 123, "session_token": "TOKEN", "api_version": 2,"data": {"'+recomPriceObj.Id+'": 4,"a5dd84d9ff4b4bbe920f86bd40f052f4": null,"e6e3b028819044fca896a3dd2a6c4136": 5}}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders)); 
        
        Test.startTest();
            List<Recommended_Price__c> lRPs = [SELECT Id, Saved_Auction_Id__c,Price_Ceiling__c , condition_rating__c,Pricing_Status__c, 
                                    External_Notes_to_Seller__c, Price_Floor__c, CreatedDate, LastModifiedDate                                   
                                    FROM Recommended_Price__c WHERE Id = :recomPriceObj.Id];
            System.enqueueJob(New AcvIntegrationQueueableJob('Create Pricing',lRPs,null));
        Test.stopTest();
    }

        @isTest static void testPostCalloutPricingBatch(){
        //Create test recommended price record to pass into queued job call
        Auction__c auctionObj = [SELECT id, id__c, floor_price__c, Name, notes__c, vehicle_id__c FROM Auction__c LIMIT 1];
        Vehicle__c vehicleObj = [SELECT id,basic_color__c,class_name__c,drivetrain__c,fuel_type__c,model__c,msrp__c,Name FROM Vehicle__c LIMIT 1];
        Recommended_Price__c recomPriceObj = TestUtility.createRecommended_Price(auctionObj,vehicleObj);
        insert recomPriceObj;

        Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"status": "ok", "user_id": 123, "session_token": "TOKEN", "api_version": 2,"data": {"'+recomPriceObj.Id+'": 4,"a5dd84d9ff4b4bbe920f86bd40f052f4": null,"e6e3b028819044fca896a3dd2a6c4136": 5}}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders)); 
        
        Test.startTest();
            BatchRecommendPriceOutbound batchClass = new BatchRecommendPriceOutbound();
            database.executebatch(batchClass,200);
        Test.stopTest();
    }

    @isTest static void testPostCalloutLogout(){
        Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"status": "ok", "user_id": 123, "session_token": "TOKEN"}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders)); 
        
        Test.startTest();
            Map<String,object> mAuthValues = new Map<String,object>();
            mAuthValues.put('session_token','"TOKEN"');
            mAuthValues.put('user_id', '123');
            System.enqueueJob(New AcvIntegrationQueueableJob('Logout',null,mAuthValues));        
        Test.stopTest();
    }  

    @isTest static void testPostCalloutUnwindAuction(){
        Auction__c auctionObj = [SELECT id, id__c, status__c, saved_auction_id__c, floor_price__c, Name, notes__c, vehicle_id__c FROM Auction__c LIMIT 1];

        auctionObj.id__c = '12344';
        auctionObj.saved_auction_id__c = '23455';
        auctionObj.status__c = 'Ended Unwound';
        upsert auctionObj;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();
        Case unwCase = new Case(
            Status = 'Unwound',
            Auction_Number__c = auctionObj.Id,
            Subject = 'Unwind Testing',
            RecordTypeId = caseRecordTypeId,
            Send_To_ACV__c = true,
            Unwind_Type__c = 'ACV_Relaunch'
        );
        insert unwCase;

        Map<String, String> responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        String body = '{"api_version": 2, "data": { "errors": [{"attempted_update": 34566, "error_message": "Cannot unwind an auction which is not in an accepted state." }], "successes": [{"auction_id":'+auctionObj.id__c+'}]}}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code, status, body, responseHeaders));

        Test.startTest();
            List<Case> lCases = [select id, Auction_Number_Case__c, Unwind_Type__c from Case where ID =:unwCase.Id];
            System.enqueueJob(New AcvIntegrationQueueableJob('Unwind Auction', lCases, null));
        Test.stopTest();
    }

    @isTest static void testPostCalloutSavedAuctionDelete(){
        Auction__c auctionObj = [SELECT id, id__c, status__c, saved_auction_id__c, floor_price__c, Name, notes__c, vehicle_id__c FROM Auction__c LIMIT 1];

        auctionObj.id__c = '12344';
        auctionObj.saved_auction_id__c = '23455';
        auctionObj.status__c = 'Ended Unwound';
        upsert auctionObj;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();
        Case unwCase = new Case(
            Status = 'Unwound',
            Auction_Number__c = auctionObj.Id,
            Subject = 'Unwind Testing',
            RecordTypeId = caseRecordTypeId,
            Send_To_ACV__c = true,
            Unwind_Type__c = 'ACV_Relaunch'
        );
        insert unwCase;

        Map<String, String> responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        String body = '{}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code, status, body, responseHeaders));

        Test.startTest();
            List<Case> lCases = [select id, Auction_Number_Case__c, Saved_Auction_ID__c, Unwind_Type__c from Case where ID =:unwCase.Id];
            System.enqueueJob(New AcvIntegrationQueueableJob('Update Saved Auction Delete', lCases, null));
        Test.stopTest();
    }

    @isTest static void testPostCalloutSavedAuctionDealer(){
        Auction__c auctionObj = [SELECT id, id__c, status__c, saved_auction_id__c, floor_price__c, Name, notes__c, vehicle_id__c FROM Auction__c LIMIT 1];

        auctionObj.id__c = '12344';
        auctionObj.saved_auction_id__c = '23455';
        auctionObj.status__c = 'Ended Unwound';
        upsert auctionObj;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();
        Case unwCase = new Case(
            Status = 'Unwound',
            Auction_Number__c = auctionObj.Id,
            Subject = 'Unwind Testing',
            RecordTypeId = caseRecordTypeId,
            Send_To_ACV__c = true
        );
        insert unwCase;

        Map<String, String> responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        String body = '{"api_version": 2, "data": { "errors": [{"attempted_update": {"dealer_id": 73, "saved_auction_id": 234567}, "exception": {"message": "SavedAuction matching query does not exist.", "name": "DoesNotExist"}}] , "successes": [{"update":{"dealer_id": 73, "saved_auction_id": '+auctionObj.Saved_Auction_Id__c+'}}]}}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code, status, body, responseHeaders));

        Test.startTest();
            List<Case> lCases = [select id, Auction_Number_Case__c, Saved_Auction_ID__c, Unwind_Type__c from Case where ID =:unwCase.Id];
            System.enqueueJob(New AcvIntegrationQueueableJob('Update Saved Auction Dealer', lCases, null));
        Test.stopTest();
    }

    @isTest static void testPostCalloutUpdateTransportationRequest(){
        Auction__c auctionObj = [SELECT id, id__c, status__c, saved_auction_id__c, floor_price__c, Name, notes__c, vehicle_id__c FROM Auction__c LIMIT 1];

        auctionObj.id__c = '12344';
        auctionObj.saved_auction_id__c = '23455';
        upsert auctionObj;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        Case transCase = new Case(
            Status = 'Posted',
            Auction_Number__c = auctionObj.Id,
            Subject = 'Trans Testing',
            RecordTypeId = caseRecordTypeId,
            Buyer_Price__c = 500,
            Send_To_ACV__c = true,
            Date_Last_Posted__c = Date.today(),
            ACV_Transportation_Request_Id__c = '123456',
            Posted_Price__c = 150

        );
        insert transCase;

        Map<String, String> responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        String body = '{"api_version": 2, "data": { "errors": [{"attempted_update": {"id": 73456, "status": "in_transit"}, "error_message": "A transportation request with the specified ID could not be found."}], "successes": [{"update":{"date_posted":"11/1/2019 00:00:00", "status": "posted", "id": '+transCase.ACV_Transportation_Request_Id__c+', "price_paid": 500}}, {"update":{"date_posted":"11/1/2019 00:00:00", "status": "posted", "id": 55632, "price_paid": 500}}]}}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code, status, body, responseHeaders));

        Test.startTest();
            List<Case> lCases = [select id, Send_to_ACV__c, Posted_Price__c, Buyer_Price__c, Status, ACV_Transportation_Request_Id__c, 
                                    Transporter_Name__c, Date_Delivered_Actual__c, Date_Last_Posted__c, Vehicle_Abandoned__c,
                                    Expected_Delivery__c, Date_Picked_Up__c, Description, Auction_Number_Case__c, Date_First_Posted_Portal__c from Case where ID =:transCase.Id];
            System.enqueueJob(New AcvIntegrationQueueableJob('Update Transportation Request', lCases, null));
            
        Test.stopTest();
        
        Case updatedCase = [select id, Send_To_ACV__c from case where id =:transCase.id];
        System.assertEquals(false, updatedCase.Send_To_ACV__c);
    }

    @isTest static void testPostCalloutUpdateTransportationRequestNoAuctionTest(){
        Account buyer = TestUtility.createAccount();
        buyer.Name = 'new test account';
        buyer.Dealership_ID__c = '123';
        insert buyer;
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        Case transCase = new Case(
            Status = 'Posted',
            Seller_Dealership__c = buyer.id,
            AccountId = buyer.id,
            Subject = 'Trans Testing',
            RecordTypeId = caseRecordTypeId,
            Buyer_Price__c = 500,
            Send_To_ACV__c = true,
            Date_Last_Posted__c = Date.today(),
            Posted_Price__c = 150

        );
        insert transCase;

        Map<String, String> responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        String body = '{"api_version":2,"data":{"successes":[{"update":{"pickup_address_postal_code":"60074","seller_dealership_name":"CHEVROLET OF PALATINE ibt 4276-6389","pickup_address_region":"IL","vehicle_model":"","vehicle_make":"","pickup_address_address_line_one":"151 E. LAKE COOK RD","auction_id":0,"pickup_address_name":"CHEVROLET OF PALATINE ibt 4276-6389","seller_dealership_id":123,"delivery_address_name":"CHEVROLET OF PALATINE ibt 4276-6389","buyer_dealership_id":123,"pickup_address_country":"US","delivery_address_city":"Palatine","delivery_address_country":"US","pickup_address_city":"Palatine","price_pre_promotion":1250.0,"delivery_address_address_line_one":"151 E. LAKE COOK RD","delivery_address_postal_code":"60074","buyer_dealership_name":"CHEVROLET OF PALATINE ibt 4276-6389","price_charged_to_customer":1250.0,"vehicle_class_name":"","vehicle_year":0,"delivery_address_region":"IL","vehicle_is_oversize":false,"vehicle_vin":"","transportation_request_id":225520}}],"errors":[]}}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code, status, body, responseHeaders));

        Test.startTest();
        
            List<Case> lCases = [SELECT id, status, Auction_Number_Case__c, Buyer_External_Id__c, Buyer_Name__c, Default_Delivery_Address__c, Default_Delivery_City__c, Default_Delivery_Country__c, Delivery_Address_Name__c,Default_Delivery_Postal_Code__c, Default_Delivery_State__c, Pickup_Address__c, Default_Pickup_City__c, Default_Pickup_Country__c, Pickup_Address_Name__c, Default_Pickup_Postal_Code__c,Default_Pickup_State__c, Posted_Price__c, Buyer_Price__c, Seller_External_Id__c, Seller_Name__c, Vehicle_Class_Name__c, Vehicle_Is_Oversize__c, Vehicle_Make__c, Vehicle_Model__c, Vehicle_VIN__c, Vehicle_Year__c, Vehicle_External_Id__c, Price_Pre_Promotion__c FROM Case WHERE RecordTypeId = :caseRecordTypeId AND Send_To_ACV__c = true];
            System.enqueueJob(New AcvIntegrationQueueableJob('Create Transportation Request', lCases, null));
        Test.stopTest();

        System.assert( [select id from case where ACV_Transportation_Request_Id__c = '225520'].size() == 1, 'Not enough transport ids created');
    }
}