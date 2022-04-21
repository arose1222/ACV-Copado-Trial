@isTest
private class EasyPostQueueableJob_Test {
	
	@TestSetup static void createData(){
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
			Case caseObj = TestUtility.createTitleCase(auctionObj, actObj, contactObj);
			insert caseObj;

        Test.stopTest();
    }

	@isTest static void testPostCalloutCreateShipment(){
        Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"status": "ok", "user_id": 123, "session_token": "TOKEN", "rates":[{"id":"rate_5348271f012147858d42753ecd4e100f","object":"Rate","created_at":"2019-01-04T12:28:08Z","updated_at":"2019-01-04T12:28:08Z","mode":"test","service":"STANDARD_OVERNIGHT","carrier":"FedEx","rate":"17.80","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"17.80","list_currency":"USD","delivery_days":4,"delivery_date":"2019-01-08T16:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":4,"shipment_id":"shp_51b7afaea3014559b3483d7676ccc767","carrier_account_id":"ca_45lusCky"},{"id":"rate_7f3e659a20d44cfeaf5b4a1b72ee1c2b","object":"Rate","created_at":"2019-01-04T12:28:08Z","updated_at":"2019-01-04T12:28:08Z","mode":"test","service":"FEDEX_EXPRESS_SAVER","carrier":"FedEx","rate":"7.65","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"7.65","list_currency":"USD","delivery_days":5,"delivery_date":"2019-01-09T16:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":5,"shipment_id":"shp_51b7afaea3014559b3483d7676ccc767","carrier_account_id":"ca_45lusCky"}],"id":"shp_51b7afaea3014559b3483d7676ccc767","object":"Shipment"}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders)); 
        List<Case> lTitleCases = [SELECT id, Easypost_Parcel_Predefined_Package__c, Easypost_Parcel_Weight__c,
                          Default_Delivery_City__c,  Default_Delivery_Country__c, Buyer_Name__c, ContactPhone, Default_Delivery_State__c,
                         Default_Delivery_Address__c, Default_Delivery_Address_Line2__c, Default_Delivery_Postal_Code__c, EasyPost_Shipping_Service__c
                         FROM Case LIMIT 1];
		System.debug('case:'+lTitleCases); 
		List<Id> lTitleCaseIds = new List<Id>();
		for(Case caseObj :lTitleCases){
			lTitleCaseIds.add(caseObj.Id);
		}

        Test.startTest();
			if(lTitleCaseIds.size() >0){
				EasyPost_ShipmentController epsc = new EasyPost_ShipmentController();
				EasyPost_ShipmentController.CreateEasyPostShipment(lTitleCaseIds);
			}
            //System.enqueueJob(New EasyPostQueueableJob('Create Shipment', lTitleCases, null));       
        Test.stopTest();
    }

    @isTest static void testPostCalloutCreateShipment_Cheapest(){
        Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"status": "ok", "user_id": 123, "session_token": "TOKEN", "rates":[{"id":"rate_5348271f012147858d42753ecd4e100f","object":"Rate","created_at":"2019-01-04T12:28:08Z","updated_at":"2019-01-04T12:28:08Z","mode":"test","service":"STANDARD_OVERNIGHT","carrier":"FedEx","rate":"17.80","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"17.80","list_currency":"USD","delivery_days":4,"delivery_date":"2019-01-08T16:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":4,"shipment_id":"shp_51b7afaea3014559b3483d7676ccc767","carrier_account_id":"ca_45lusCky"},{"id":"rate_7f3e659a20d44cfeaf5b4a1b72ee1c2b","object":"Rate","created_at":"2019-01-04T12:28:08Z","updated_at":"2019-01-04T12:28:08Z","mode":"test","service":"FEDEX_EXPRESS_SAVER","carrier":"FedEx","rate":"7.65","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"7.65","list_currency":"USD","delivery_days":5,"delivery_date":"2019-01-09T16:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":5,"shipment_id":"shp_51b7afaea3014559b3483d7676ccc767","carrier_account_id":"ca_45lusCky"}],"id":"shp_51b7afaea3014559b3483d7676ccc767","object":"Shipment"}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders)); 
        List<Case> lTitleCases = [SELECT id, Easypost_Parcel_Predefined_Package__c, Easypost_Parcel_Weight__c,
                          Default_Delivery_City__c,  Default_Delivery_Country__c, Buyer_Name__c, ContactPhone, Default_Delivery_State__c,
                         Default_Delivery_Address__c, Default_Delivery_Address_Line2__c, Default_Delivery_Postal_Code__c, EasyPost_Shipping_Service__c
                         FROM Case LIMIT 1];
		System.debug('case:'+lTitleCases); 
		List<Id> lTitleCaseIds = new List<Id>();
		for(Case caseObj :lTitleCases){
            caseObj.EasyPost_Shipping_Service__c = 'CHEAPEST';
			lTitleCaseIds.add(caseObj.Id);
		}
        update lTitleCases;

        Test.startTest();
			if(lTitleCaseIds.size() >0){
				EasyPost_ShipmentController epsc = new EasyPost_ShipmentController();
				EasyPost_ShipmentController.CreateEasyPostShipment(lTitleCaseIds);
			}
            //System.enqueueJob(New EasyPostQueueableJob('Create Shipment', lTitleCases, null));       
        Test.stopTest();
    }

	@isTest static void testPostCalloutCreateShipmentUnwind(){
        Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"status": "ok", "user_id": 123, "session_token": "TOKEN", "rates":[{"id":"rate_5348271f012147858d42753ecd4e100f","object":"Rate","created_at":"2019-01-04T12:28:08Z","updated_at":"2019-01-04T12:28:08Z","mode":"test","service":"STANDARD_OVERNIGHT","carrier":"FedEx","rate":"17.80","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"17.80","list_currency":"USD","delivery_days":4,"delivery_date":"2019-01-08T16:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":4,"shipment_id":"shp_51b7afaea3014559b3483d7676ccc767","carrier_account_id":"ca_45lusCky"},{"id":"rate_7f3e659a20d44cfeaf5b4a1b72ee1c2b","object":"Rate","created_at":"2019-01-04T12:28:08Z","updated_at":"2019-01-04T12:28:08Z","mode":"test","service":"FEDEX_EXPRESS_SAVER","carrier":"FedEx","rate":"7.65","currency":"USD","retail_rate":null,"retail_currency":null,"list_rate":"7.65","list_currency":"USD","delivery_days":5,"delivery_date":"2019-01-09T16:30:00Z","delivery_date_guaranteed":true,"est_delivery_days":5,"shipment_id":"shp_51b7afaea3014559b3483d7676ccc767","carrier_account_id":"ca_45lusCky"}],"id":"shp_51b7afaea3014559b3483d7676ccc767","object":"Shipment"}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders)); 
        List<Case> lTitleCases = [SELECT Id, Easypost_Parcel_Predefined_Package__c, Easypost_Parcel_Weight__c,
                          Default_Pickup_City__c,  Default_Pickup_Country__c, Buyer_Name__c, ContactPhone, Default_Pickup_State__c,
                         Pickup_Address__c, Pick_Up_Address_Line_2__c, Default_Pickup_Postal_Code__c, EasyPost_Shipping_Service__c
                         FROM Case LIMIT 1];
		System.debug('case:'+lTitleCases); 
        List<Id> lTitleCaseIds = new List<Id>();
        for(Case caseObj :lTitleCases){
            lTitleCaseIds.add(caseObj.Id);
        }

        Test.startTest();
            if(lTitleCaseIds.size() >0){
                EasyPost_Unwind_ShipmentController epusc = new EasyPost_Unwind_ShipmentController();
                EasyPost_Unwind_ShipmentController.CreateEasyPostShipment_Unwind(lTitleCaseIds);
            }
            //System.enqueueJob(New EasyPostQueueableJob('Create Shipment Unwind', lTitleCases, null));       
        Test.stopTest();
    }

	@isTest static void testPostCalloutBuyShipment(){
        Map<String, String> responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"status": "ok", "user_id": 123, "session_token": "TOKEN", "id":"shp_51b7afaea3014559b3483d7676ccc767","object":"Shipment","tracking_code": "794652521650","postage_label":{"object":"PostageLabel","id":"pl_1288eae3c22143a1b708b84a566b0cdf","label_url":"https://easypost-files.s3-us-west-2.amazonaws.com/files/postage_label/20190104/f2478a1f0a774e8393872233b19f1551.png"},"tracker":{"id":"trk_fdeeaff90c7d4b8186c72146f2adc495","object":"Tracker","tracking_code":"794652521650","public_url":"https://track.easypost.com/djE6dHJrX2ZkZWVhZmY5MGM3ZDRiODE4NmM3MjE0NmYyYWRjNDk1"}}';
        Integer code = 200;
        String status = 'OK';
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(code,status,body,responseHeaders)); 
        List<Case> lTitleCases = [SELECT id, Easypost_Parcel_Predefined_Package__c, Easypost_Parcel_Weight__c,
                          Default_Delivery_City__c,  Default_Delivery_Country__c, Buyer_Name__c, ContactPhone, Default_Delivery_State__c,
                         Default_Delivery_Address__c, Default_Delivery_Address_Line2__c, Default_Delivery_Postal_Code__c, EasyPost_Shipping_Service__c
                         FROM Case LIMIT 1];
		System.debug('case:'+lTitleCases); 

        Test.startTest();
			Map<String,object> buyShipmentValues = new Map<String, object>();
			buyShipmentValues.put('rate_id','rate_7f3e659a20d44cfeaf5b4a1b72ee1c2b');
			buyShipmentValues.put('shipment_id','shp_51b7afaea3014559b3483d7676ccc767');
			System.enqueueJob(new EasyPostQueueableJob('Buy Shipment', lTitleCases, buyShipmentValues));     
        Test.stopTest();
    }    
	
}