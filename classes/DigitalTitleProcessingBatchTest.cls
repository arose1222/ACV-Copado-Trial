//@isTest
public class DigitalTitleProcessingBatchTest {
/*
    public static String blockedStateAPIResponse = '{"api_version": 2,"data": ["CA","NY","NJ","CT","PA","DE","KY"]}';
    public static String loginV2APIResponse = '{"jwtToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2ZjNlOWJkMS05ZTQzLTQyN2UtOTk2Yy1hMzdhMWZlMDQ0MmMiLCJqdGkiOiIxZjJmNjNkZC0zMmU5LTQzNTEtYjk2Yy0yYTdmZmRlMzE1MWUiLCJhcHBfcm9sZSI6InRvb2xfdXNlciIsIm9yZ2FuaXphdGlvbl9hZG1pbiI6IiIsImV4cCI6MTU4NTA3NDk5NCwiaXNzIjoiQUNWLlNlY3VyaXR5LkJlYXJlciIsImF1ZCI6IkFDVi5TZWN1cml0eS5CZWFyZXIifQ.LdNpqSLn_Sk4t6ew6reYClPmNVjOoGOlX65sdNVAW3o","refreshToken": "32e251e1-9817-478f-9c1a-f0b17aaca0a6","api_version": 2,"data": {"user_id": 34233,"email": "bsutton@acvauctions.com","active": true,"role": "user","session_token": "d5b8a098-5c92-4ee1-bf8a-956359745373","source": "app","registration_state": 4,"dealer_id": 4308,"dealer_type": "Franchise","dealer_active": true,"dealerships": [{"active": true,"address": "For Pick up location please call 1-800-553-4070 option 1, then option 2","dealership_type": 1,"id": 4308,"legal_name": "ACV Auctions","location": {"city": "Buffalo","region": "NY"},"member_type": "rep","name": "ACV Auctions","zip_code": "14203"}],"sorting_prefs": {"buying_ended": "all","selling_ended": "all"}}}';
    public static String easyPostShipmentResponse = '{"created_at":"2019-03-25T15:43:24Z","is_return":false,"messages":[],"mode":"test","options":{"currency":"USD","payment":{"type":"SENDER"},"label_date":null,"date_advance":0},"reference":null,"status":"unknown","tracking_code":null,"updated_at":"2019-03-25T15:43:24Z","batch_id":null,"batch_status":null,"batch_message":null,"customs_info":null,"from_address":{"id":"adr_986e63f1c43c444bbb084d5899877f9e","object":"Address","created_at":"2019-03-25T15:43:24Z","updated_at":"2019-03-25T15:43:24Z","name":null,"company":"ACV Auctions, Inc","street1":"640 Ellicott St","street2":"Suite 321","city":"Buffalo","state":"NY","zip":"14203","country":"US","phone":"8005534070","email":null,"mode":"test","carrier_facility":null,"residential":null,"federal_tax_id":null,"state_tax_id":null,"verifications":{}},"insurance":null,"order_id":null,"parcel":{"id":"prcl_e811c9bb2a194df881d756907306d176","object":"Parcel","created_at":"2019-03-25T15:43:24Z","updated_at":"2019-03-25T15:43:24Z","length":null,"width":null,"height":null,"predefined_package":"FedExEnvelope","weight":10,"mode":"test"},"postage_label":null,"rates":[{"id":"rate_53ce5ae98d584a9d949b971e9b8f1d8b","object":"Rate","created_at":"2019-03-25T15:43:25Z","updated_at":"2019-03-25T15:43:25Z","mode":"test","service":"FIRST_OVERNIGHT","carrier":"FedEx","rate":"80.20","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"80.20","list_currency":"USD","delivery_days":1,"delivery_date":"2019-03-26T08:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":1,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"},{"id":"rate_cfd041158d484b439eb8bf5286900f9e","object":"Rate","created_at":"2019-03-25T15:43:25Z","updated_at":"2019-03-25T15:43:25Z","mode":"test","service":"FIRST_OVERNIGHT","carrier":"FedEx","rate":"40.20","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"40.20","list_currency":"USD","delivery_days":1,"delivery_date":"2019-03-26T10:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":1,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"},{"id":"rate_5557544d6854415c9d220cccafb3a403","object":"Rate","created_at":"2019-03-25T15:43:25Z","updated_at":"2019-03-25T15:43:25Z","mode":"test","service":"STANDARD_OVERNIGHT","carrier":"FedEx","rate":"27.35","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"27.35","list_currency":"USD","delivery_days":1,"delivery_date":"2019-03-26T15:00:00Z","delivery_date_guaranteed":true,"est_delivery_days":1,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"},{"id":"rate_62d8d91fec984f0b9d598a6dcf41c77f","object":"Rate","created_at":"2019-03-25T15:43:25Z","updated_at":"2019-03-25T15:43:25Z","mode":"test","service":"FEDEX_2_DAY_AM","carrier":"FedEx","rate":"26.10","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"26.10","list_currency":"USD","delivery_days":2,"delivery_date":"2019-03-27T10:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":2,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"},{"id":"rate_84aadd84162046cbb45377f9ed77de00","object":"Rate","created_at":"2019-03-25T15:43:25Z","updated_at":"2019-03-25T15:43:25Z","mode":"test","service":"FEDEX_2_DAY","carrier":"FedEx","rate":"20.50","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"20.50","list_currency":"USD","delivery_days":2,"delivery_date":"2019-03-27T16:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":2,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"},{"id":"rate_0e392ad219154576b919ee18efb90f2c","object":"Rate","created_at":"2019-03-25T15:43:25Z","updated_at":"2019-03-25T15:43:25Z","mode":"test","service":"FEDEX_EXPRESS_SAVER","carrier":"FedEx","rate":"8.65","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"8.65","list_currency":"USD","delivery_days":3,"delivery_date":"2019-03-28T16:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":3,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"}],"refund_status":null,"scan_form":null,"selected_rate":null,"tracker":null,"to_address":{"id":"adr_276f233fcc2147de8a6e9661dc2f1f1a","object":"Address","created_at":"2019-03-25T15:43:24Z","updated_at":"2019-03-25T15:43:24Z","name":"K & S Auto Brokers, Inc.","company":null,"street1":"2875 Cherry Road","street2":"","city":"Rock Hill","state":"SC","zip":"29730","country":"US","phone":"8038100424","email":null,"mode":"test","carrier_facility":null,"residential":null,"federal_tax_id":null,"state_tax_id":null,"verifications":{}},"usps_zone":4,"return_address":{"id":"adr_986e63f1c43c444bbb084d5899877f9e","object":"Address","created_at":"2019-03-25T15:43:24Z","updated_at":"2019-03-25T15:43:24Z","name":null,"company":"ACV Auctions, Inc","street1":"640 Ellicott St","street2":"Suite 321","city":"Buffalo","state":"NY","zip":"14203","country":"US","phone":"8005534070","email":null,"mode":"test","carrier_facility":null,"residential":null,"federal_tax_id":null,"state_tax_id":null,"verifications":{}},"buyer_address":{"id":"adr_276f233fcc2147de8a6e9661dc2f1f1a","object":"Address","created_at":"2019-03-25T15:43:24Z","updated_at":"2019-03-25T15:43:24Z","name":"K & S Auto Brokers, Inc.","company":null,"street1":"2875 Cherry Road","street2":"","city":"Rock Hill","state":"SC","zip":"29730","country":"US","phone":"8038100424","email":null,"mode":"test","carrier_facility":null,"residential":null,"federal_tax_id":null,"state_tax_id":null,"verifications":{}},"forms":[],"fees":[],"id":"shp_e60d045467db4fdc8589221cc666a362","object":"Shipment"}';
    public static String easyPostBuyResponse = '{"created_at":"2019-03-25T15:43:24Z","is_return":false,"messages":[],"mode":"test","options":{"currency":"USD","payment":{"type":"SENDER"},"label_date":null,"date_advance":0},"reference":null,"status":"unknown","tracking_code":"794668170255","updated_at":"2019-03-25T15:45:12Z","batch_id":null,"batch_status":null,"batch_message":null,"customs_info":null,"from_address":{"id":"adr_986e63f1c43c444bbb084d5899877f9e","object":"Address","created_at":"2019-03-25T15:43:24Z","updated_at":"2019-03-25T15:43:24Z","name":null,"company":"ACV Auctions, Inc","street1":"640 Ellicott St","street2":"Suite 321","city":"Buffalo","state":"NY","zip":"14203","country":"US","phone":"8005534070","email":null,"mode":"test","carrier_facility":null,"residential":null,"federal_tax_id":null,"state_tax_id":null,"verifications":{}},"insurance":null,"order_id":null,"parcel":{"id":"prcl_e811c9bb2a194df881d756907306d176","object":"Parcel","created_at":"2019-03-25T15:43:24Z","updated_at":"2019-03-25T15:43:24Z","length":null,"width":null,"height":null,"predefined_package":"FedExEnvelope","weight":10,"mode":"test"},"postage_label":{"object":"PostageLabel","id":"pl_d49b7f74b0aa4713adc5a593172d42dd","created_at":"2019-03-25T15:45:11Z","updated_at":"2019-03-25T15:45:12Z","date_advance":0,"integrated_form":"none","label_date":"2019-03-25T15:45:11Z","label_resolution":200,"label_size":"PAPER_4X6","label_type":"default","label_file_type":"image/png","label_url":"https://easypost-files.s3-us-west-2.amazonaws.com/files/postage_label/20190325/26c61759a83d41d1a1b9e9cee616ce47.png","label_pdf_url":null,"label_zpl_url":null,"label_epl2_url":null,"label_file":null},"rates":[{"id":"rate_53ce5ae98d584a9d949b971e9b8f1d8b","object":"Rate","created_at":"2019-03-25T15:43:25Z","updated_at":"2019-03-25T15:43:25Z","mode":"test","service":"FIRST_OVERNIGHT","carrier":"FedEx","rate":"80.20","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"80.20","list_currency":"USD","delivery_days":1,"delivery_date":"2019-03-26T08:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":1,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"},{"id":"rate_cfd041158d484b439eb8bf5286900f9e","object":"Rate","created_at":"2019-03-25T15:43:25Z","updated_at":"2019-03-25T15:43:25Z","mode":"test","service":"FIRST_OVERNIGHT","carrier":"FedEx","rate":"40.20","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"40.20","list_currency":"USD","delivery_days":1,"delivery_date":"2019-03-26T10:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":1,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"},{"id":"rate_5557544d6854415c9d220cccafb3a403","object":"Rate","created_at":"2019-03-25T15:43:25Z","updated_at":"2019-03-25T15:43:25Z","mode":"test","service":"STANDARD_OVERNIGHT","carrier":"FedEx","rate":"27.35","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"27.35","list_currency":"USD","delivery_days":1,"delivery_date":"2019-03-26T15:00:00Z","delivery_date_guaranteed":true,"est_delivery_days":1,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"},{"id":"rate_62d8d91fec984f0b9d598a6dcf41c77f","object":"Rate","created_at":"2019-03-25T15:43:25Z","updated_at":"2019-03-25T15:43:25Z","mode":"test","service":"FEDEX_2_DAY_AM","carrier":"FedEx","rate":"26.10","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"26.10","list_currency":"USD","delivery_days":2,"delivery_date":"2019-03-27T10:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":2,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"},{"id":"rate_84aadd84162046cbb45377f9ed77de00","object":"Rate","created_at":"2019-03-25T15:43:25Z","updated_at":"2019-03-25T15:43:25Z","mode":"test","service":"FEDEX_2_DAY","carrier":"FedEx","rate":"20.50","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"20.50","list_currency":"USD","delivery_days":2,"delivery_date":"2019-03-27T16:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":2,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"},{"id":"rate_0e392ad219154576b919ee18efb90f2c","object":"Rate","created_at":"2019-03-25T15:43:25Z","updated_at":"2019-03-25T15:43:25Z","mode":"test","service":"FEDEX_EXPRESS_SAVER","carrier":"FedEx","rate":"8.65","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"8.65","list_currency":"USD","delivery_days":3,"delivery_date":"2019-03-28T16:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":3,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"}],"refund_status":null,"scan_form":null,"selected_rate":{"id":"rate_53ce5ae98d584a9d949b971e9b8f1d8b","object":"Rate","created_at":"2019-03-25T15:45:11Z","updated_at":"2019-03-25T15:45:11Z","mode":"test","service":"FIRST_OVERNIGHT","carrier":"FedEx","rate":"80.20","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"80.20","list_currency":"USD","delivery_days":1,"delivery_date":"2019-03-26T08:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":1,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier_account_id":"ca_45lusCky"},"tracker":{"id":"trk_7aabd49b684a49049c49f16279702853","object":"Tracker","mode":"test","tracking_code":"794668170255","status":"unknown","status_detail":"unknown","created_at":"2019-03-25T15:45:12Z","updated_at":"2019-03-25T15:45:12Z","signed_by":null,"weight":null,"est_delivery_date":null,"shipment_id":"shp_e60d045467db4fdc8589221cc666a362","carrier":"FedEx","tracking_details":[],"fees":[],"carrier_detail":null,"public_url":"https://track.easypost.com/djE6dHJrXzdhYWJkNDliNjg0YTQ5MDQ5YzQ5ZjE2Mjc5NzAyODUz"},"to_address":{"id":"adr_276f233fcc2147de8a6e9661dc2f1f1a","object":"Address","created_at":"2019-03-25T15:43:24Z","updated_at":"2019-03-25T15:43:24Z","name":"K & S Auto Brokers, Inc.","company":null,"street1":"2875 Cherry Road","street2":"","city":"Rock Hill","state":"SC","zip":"29730","country":"US","phone":"8038100424","email":null,"mode":"test","carrier_facility":null,"residential":null,"federal_tax_id":null,"state_tax_id":null,"verifications":{}},"usps_zone":4,"return_address":{"id":"adr_986e63f1c43c444bbb084d5899877f9e","object":"Address","created_at":"2019-03-25T15:43:24Z","updated_at":"2019-03-25T15:43:24Z","name":null,"company":"ACV Auctions, Inc","street1":"640 Ellicott St","street2":"Suite 321","city":"Buffalo","state":"NY","zip":"14203","country":"US","phone":"8005534070","email":null,"mode":"test","carrier_facility":null,"residential":null,"federal_tax_id":null,"state_tax_id":null,"verifications":{}},"buyer_address":{"id":"adr_276f233fcc2147de8a6e9661dc2f1f1a","object":"Address","created_at":"2019-03-25T15:43:24Z","updated_at":"2019-03-25T15:43:24Z","name":"K & S Auto Brokers, Inc.","company":null,"street1":"2875 Cherry Road","street2":"","city":"Rock Hill","state":"SC","zip":"29730","country":"US","phone":"8038100424","email":null,"mode":"test","carrier_facility":null,"residential":null,"federal_tax_id":null,"state_tax_id":null,"verifications":{}},"forms":[],"fees":[{"object":"Fee","type":"LabelFee","amount":"0.01000","charged":true,"refunded":false}],"id":"shp_e60d045467db4fdc8589221cc666a362","object":"Shipment"}';

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

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

        System.runAs(usah){
            Account actObj = TestUtility.createAccount('test account');
            actObj.legal_name__c = 'test account';
            actObj.Dealer_Type__c = '1';
            actObj.Title_Mailing_Street__c = '8368 Lower East Hill Rd';
            actObj.Title_Mailing_City__c = 'Colden';
            actObj.Title_Mailing_State__c = 'NY';
            actObj.Title_Mailing_Country__c = 'US';
            actObj.Title_Mailing_Zip_Code__c = '14033';
            insert actObj;
            Contact contactObj = TestUtility.createContact(actObj);
            insert contactObj;
            Vehicle__c vehicleObj = TestUtility.createVehicle();
            insert vehicleObj;
            Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
            auctionObj.Payment_Status__c = 'Approved';
            auctionObj.Payment_Method__c = 'ach';
            insert auctionObj;
            Case caseObj =  TestUtility.createTitleCase(auctionObj, actObj, contactObj);
            caseObj.Seller_Dealership__c = actObj.id;
            caseObj.Status = 'Received';
            caseObj.Title_Sent_Digitally__c = 'Yes';
            caseObj.Digital_Title__c = true;
            insert caseObj;
        }
    }

    @isTest
    static void basicBatchRun() {
        Test.setMock(HttpCalloutMock.class, mock());
        Test.startTest();
            DigitalTitleProcessingBatch batch = new DigitalTitleProcessingBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();
        System.assert([select id from case where Easypost_Tracker__c != null].size() > 0, 'No Tracking Numbers Found');
    }

    @isTest
    static void nonBlockedStateSellerTitleMailingFieldsPopulated() {
        Account buyerAcc = [Select id from Account limit 1];
        Account actObj = TestUtility.createAccount('test account');
        actObj.Title_Mailing_Street__c = '8368 Lower East Hill Rd';
        actObj.Title_Mailing_City__c = 'Colden';
        actObj.Title_Mailing_State__c = 'NY';
        actObj.Title_Mailing_Country__c = 'US';
        actObj.Title_Mailing_Zip_Code__c = '14033';
        actObj.BillingStreet = '420 Blaze Court';
        actObj.BillingCity = 'Gamer';
        actObj.BillingState = 'FL';
        actObj.BillingCountry = 'US';
        actObj.BillingPostalCode = '42069';
        insert actObj;

        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;

        Vehicle__c vehicleObj = TestUtility.createVehicle();
        insert vehicleObj;

        Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
        auctionObj.id__c = '0123456';
        auctionObj.Payment_Status__c = 'Approved';
        auctionObj.Payment_Method__c = 'ach';
      insert auctionObj;
        Case caseObj =  TestUtility.createTitleCase(auctionObj, buyerAcc, contactObj);
        caseObj.Seller_Dealership__c = actObj.id;
        caseObj.Status = 'Received';
        caseObj.Digital_Title__c = true;
        insert caseObj;
        Test.setMock(HttpCalloutMock.class, mock());
        Test.startTest();
            DigitalTitleProcessingBatch batch = new DigitalTitleProcessingBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();
        System.assert([Select Id from Case Where Easypost_Tracker__c != null AND Auction_Number__r.id__c = '0123456'].size() > 0, 'No Tracking Number Found');
    }

    @isTest
    static void nonBlockedState() {
        Account buyerAcc = [Select id from Account limit 1];
        Account actObj = TestUtility.createAccount();
        actObj.BillingStreet = '420 Blaze Court';
        actObj.BillingCity = 'Gamer';
        actObj.BillingState = 'FL';
        actObj.BillingCountry = 'US';
        actObj.BillingPostalCode = '42069';
        actObj.Name = 'test account';
        insert actObj;

        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;

        Vehicle__c vehicleObj = TestUtility.createVehicle();
        insert vehicleObj;

        Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
        auctionObj.id__c = '0123456';
        auctionObj.Payment_Status__c = 'Approved';
        auctionObj.Payment_Method__c = 'ach';
      insert auctionObj;
        Case caseObj =  TestUtility.createTitleCase(auctionObj, buyerAcc, contactObj);
        caseObj.Seller_Dealership__c = actObj.id;
        caseObj.Status = 'Received';
        caseObj.Digital_Title__c = true;
        insert caseObj;
        Test.setMock(HttpCalloutMock.class, mock());
        Test.startTest();
            DigitalTitleProcessingBatch batch = new DigitalTitleProcessingBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();
        System.assert([Select Id from Case Where Easypost_Tracker__c != null AND Auction_Number__r.id__c = '0123456'].size() > 0, 'No Tracking Number Found');
    }

    @isTest
    static void nonBlockedStateNewTitlesAddress() {
        Account actObj = TestUtility.createAccount();
        actObj.BillingStreet = '420 Blaze Court';
        actObj.BillingCity = 'Gamer';
        actObj.BillingState = 'FL';
        actObj.BillingCountry = 'US';
        actObj.BillingPostalCode = '42069';
        actObj.Name = 'test account';
        insert actObj;

        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;

        Vehicle__c vehicleObj = TestUtility.createVehicle();
        insert vehicleObj;

        Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
        auctionObj.id__c = '0123456';
        auctionObj.Payment_Status__c = 'Approved';
        auctionObj.Payment_Method__c = 'ach';
      insert auctionObj;
        Case caseObj =  TestUtility.createTitleCase(auctionObj, actObj, contactObj);
        caseObj.Seller_Dealership__c = actObj.id;
        caseObj.Status = 'Received';
        caseObj.Digital_Title__c = true;
        insert caseObj;
        Test.setMock(HttpCalloutMock.class, mock());
        Test.startTest();
            DigitalTitleProcessingBatch batch = new DigitalTitleProcessingBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();
        System.assert([Select Id from Case Where Easypost_Tracker__c != null AND Auction_Number__r.id__c = '0123456'].size() > 0, 'No Tracking Number Found');
    }

    @isTest
    static void floorPlan() {
        Account buyerAcc = [Select id from Account limit 1];
        Account actObj = TestUtility.createAccount();
        actObj.BillingStreet = '420 Blaze Court';
        actObj.BillingCity = 'Gamer';
        actObj.BillingState = 'FL';
        actObj.BillingCountry = 'US';
        actObj.BillingPostalCode = '42069';
        actObj.Name = 'test account';
        insert actObj;

        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;

        Vehicle__c vehicleObj = TestUtility.createVehicle();
        insert vehicleObj;

        Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
        auctionObj.id__c = '1234567';
        auctionObj.Payment_Status__c = 'Approved';
        auctionObj.Payment_Method__c = 'nextgear';
      insert auctionObj;
        Case caseObj =  TestUtility.createTitleCase(auctionObj, buyerAcc, contactObj);
        caseObj.Seller_Dealership__c = actObj.id;
        caseObj.Status = 'Received';
        caseObj.Digital_Title__c = true;
        insert caseObj;
        Test.setMock(HttpCalloutMock.class, mock());
        Test.startTest();
            DigitalTitleProcessingBatch batch = new DigitalTitleProcessingBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();
        System.assert([Select Id from Case Where Easypost_Tracker__c != null AND Auction_Number__r.id__c = '1234567'].size() > 0, 'No Tracking Number Found');
    }

    @isTest
    static void invalidFloorPlan() {
        Account actObj = TestUtility.createAccount();
        actObj.BillingStreet = '420 Blaze Court';
        actObj.BillingCity = 'Gamer';
        actObj.BillingState = 'FL';
        actObj.BillingCountry = 'US';
        actObj.BillingPostalCode = '42069';
        actObj.Name = 'test account';
        insert actObj;

        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;

        Vehicle__c vehicleObj = TestUtility.createVehicle();
        insert vehicleObj;

        Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
        auctionObj.id__c = '12345678';
        auctionObj.Payment_Status__c = 'Approved';
        auctionObj.Payment_Method__c = 'badplan';
      insert auctionObj;
        Case caseObj =  TestUtility.createTitleCase(auctionObj, actObj, contactObj);
        caseObj.Seller_Dealership__c = actObj.id;
        caseObj.Status = 'Received';
        caseObj.Digital_Title__c = true;
        insert caseObj;
        Test.setMock(HttpCalloutMock.class, mock());
        Test.startTest();
            DigitalTitleProcessingBatch batch = new DigitalTitleProcessingBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();
        System.assert([Select Id from Case Where Digital_Title_Problem__c = true AND Auction_Number__r.id__c = '12345678'].size() > 0, 'No Tracking Number Found');
    }

    @isTest
    static void notPaidFor() {
        Account buyerAcc = [Select id from Account limit 1];
        Account actObj = TestUtility.createAccount();
        actObj.BillingStreet = '420 Blaze Court';
        actObj.BillingCity = 'Gamer';
        actObj.BillingState = 'FL';
        actObj.BillingCountry = 'US';
        actObj.BillingPostalCode = '42069';
        actObj.Name = 'test account';
        insert actObj;

        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;

        Vehicle__c vehicleObj = TestUtility.createVehicle();
        insert vehicleObj;

        Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
        auctionObj.id__c = '12345679';
        auctionObj.Payment_Status__c = 'Pending';
        auctionObj.Payment_Method__c = 'ach';
      insert auctionObj;
        Case caseObj =  TestUtility.createTitleCase(auctionObj, buyerAcc, contactObj);
        caseObj.Seller_Dealership__c = actObj.id;
        caseObj.Status = 'Received';
        caseObj.Digital_Title__c = true;
        insert caseObj;
        Test.setMock(HttpCalloutMock.class, mock());
        Test.startTest();
            DigitalTitleProcessingBatch batch = new DigitalTitleProcessingBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();
        System.assert([Select Id from Case Where Digital_Title_Problem__c = true AND Auction_Number__r.id__c = '12345679'].size() > 0, 'No Tracking Number Found');
    }

    public static HttpCalloutMock mock(){
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK',loginV2APIResponse,null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK',blockedStateAPIResponse,null);
        TestingUtility.SingleRequestMock shipRes = new TestingUtility.SingleRequestMock(200,'OK',easyPostShipmentResponse,null);
        TestingUtility.SingleRequestMock buyRes = new TestingUtility.SingleRequestMock(200,'OK',easyPostBuyResponse,null);
        TestingUtility.SingleRequestMock splunkRes = new TestingUtility.SingleRequestMock(200,'OK','{ success }',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:ACVAuth2',loginResp);
        multiCall.put('callout:ACVAuctionData/v2/auctions/launch_blocked_regions?user_id=34233&session_token=d5b8a098-5c92-4ee1-bf8a-956359745373',uactiveRes);
        multiCall.put('callout:EasyPost/v2/shipments',shipRes);
        multiCall.put('callout:EasyPost/v2/shipments/shp_e60d045467db4fdc8589221cc666a362/buy', buyRes);
        multiCall.put('callout:Splunk/services/collector/event',splunkRes);
        return new TestingUtility.MultiRequestMock(multiCall);
    }
*/
}