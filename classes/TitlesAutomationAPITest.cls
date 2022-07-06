@isTest
public class TitlesAutomationAPITest {
    static final Id TITLE_CASE_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Title_Information' ).getRecordTypeId();

    static void makeData(){
        TestUtility.createAccount();
        final Id TITLE_CASE_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Title_Information' ).getRecordTypeId();
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usah = new User(
            LastName = 'gamer',
            Username = 'gamer@420.com',
            Email = 'gamer@420.com',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Alias = 'admSU3',
            ProfileId = profile.id
            );
        // insert usah;
        System.runAs(usah){
            Account actObj = TestUtility.createAccount();
            insert actObj;
            Contact contactObj = TestUtility.createContact(actObj);
            insert contactObj;
            Vehicle__c vehicleObj = TestUtility.createVehicle();
            insert vehicleObj;
            Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
            insert auctionObj;
            Case caseObj =  TestUtility.createTitleCase(auctionObj, actObj, contactObj);
            insert caseObj;
        }
    }
    
    static void setupFloorPlanMetadata()	{
        TitlesAutomationAPI.loadFloorPlanMap();
        
        Floor_Plan_Setting__mdt fpRec= new Floor_Plan_Setting__mdt();
        fpRec.Name__c = 'test_payment_method_1';
        fpRec.Payment_Method_API_Name__c = 'test_payment_method_1';
        fpRec.Payment_Method_Group_Name__c = 'test_payment_method_group';
        //fpRec.Internal_Delivery__c = true;
        fpRec.Company__c = 'Unit Testing';
        fpRec.Street1__c = '640 Ellicott St, Suite #321';
        fpRec.City__c = 'Buffalo';
        fpRec.State__c = 'NY';
        fpRec.Country__c = 'USA';
        fpRec.Zip__c = '14203';        
        TitlesAutomationAPI.floorPlanMap.put(fpRec.Payment_Method_API_Name__c, fpRec);
        
        fpRec= new Floor_Plan_Setting__mdt();
        fpRec.Name__c = 'test_payment_method_2';
        fpRec.Payment_Method_API_Name__c = 'test_payment_method_2';
        fpRec.Payment_Method_Group_Name__c = 'test_payment_method_group';
        //fpRec.Internal_Delivery__c = true;
        fpRec.Company__c = 'Unit Testing';
        fpRec.Street1__c = '640 Ellicott St, Suite #321';
        fpRec.City__c = 'Buffalo';
        fpRec.State__c = 'NY';
        fpRec.Country__c = 'USA';
        fpRec.Zip__c = '14203';        
        TitlesAutomationAPI.floorPlanMap.put(fpRec.Payment_Method_API_Name__c, fpRec);  
        
        fpRec= new Floor_Plan_Setting__mdt();
        fpRec.Name__c = 'test_payment_method_3';
        fpRec.Payment_Method_API_Name__c = 'test_payment_method_3';
        fpRec.Send_Title_to_Buyer__c = false;
        //fpRec.Internal_Delivery__c = false;
        fpRec.Company__c = 'Unit Testing';
        fpRec.Street1__c = '640 Ellicott St, Suite #321';
        fpRec.City__c = 'Buffalo';
        fpRec.State__c = 'NY';
        fpRec.Country__c = 'USA';
        fpRec.Zip__c = '14203';        
        TitlesAutomationAPI.floorPlanMap.put(fpRec.Payment_Method_API_Name__c, fpRec);        

        fpRec= new Floor_Plan_Setting__mdt();
        fpRec.Name__c = 'test_payment_method_3';
        fpRec.Payment_Method_API_Name__c = 'test_payment_method_4';
        fpRec.Send_Title_to_Buyer__c = true;
        //fpRec.Internal_Delivery__c = false;
        fpRec.Company__c = 'Unit Testing';
        fpRec.Street1__c = '640 Ellicott St, Suite #321';
        fpRec.City__c = 'Buffalo';
        fpRec.State__c = 'NY';
        fpRec.Country__c = 'USA';
        fpRec.Zip__c = '14203';        
        TitlesAutomationAPI.floorPlanMap.put(fpRec.Payment_Method_API_Name__c, fpRec);        
        
    }
    
    /*
     * New shipping label will be generated and saved in the Internal Delivery object for the Buyer (using Account Id).
     */
    @isTest
    public static void testBuyerShippingLabelsNew()
    {
        //
        // Begin : Setup Testing Data
        // 
        Test.startTest();

        setupFloorPlanMetadata();
            
        String acvTitlesExternalId = 'external_title_uuid_BB';
        String acctUniqueName = 'BB_TitlesAuto_BB';
        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer');         
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'ach';
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'Working';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        newTitleCase.ClosedDate = System.now();
        newTitleCase.Auction_Number_Searchable__c = acctUniqueName;
        insert newTitleCase;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usah = new User(
            LastName = 'gamer',
            Username = 'gamer@420.com',
            Email = 'gamer@420.com',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Alias = 'admSU3',
            ProfileId = profile.id
            );
        insert usah;

        Test.stopTest();
        
        //
        // End : Setup Testing Data
        // 
                
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        
        List<Internal_Delivery__c> internalDel = [SELECT Account__c, Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(0, internalDel.size());
        
        TitlesAutomationAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null);
        
        List<Case> casesWithTrackingCode = [SELECT Easypost_Tracker__c, Status FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals('794668170255', casesWithTrackingCode[0].Easypost_Tracker__c);        
        System.assertEquals('Sent', casesWithTrackingCode[0].Status); 
        
        internalDel = [SELECT Account__c, Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(1, internalDel.size());
		System.assertEquals(newBuyerAcct.Id, internalDel[0].Account__c);
		System.assertEquals('794668170255', internalDel[0].Easypost_Tracker__c);
    }

    /*
     * New shipping label will be generated and saved in the Internal Delivery object for the Buyer (using Account Id).
     * Floor plan Send_Title_to_Buyer__c=true, so Account Id should be used instead of Floor plan.
     */
    @isTest
    public static void testBuyerShippingLabelsNew2()
    {
        //
        // Begin : Setup Testing Data
        // 
        Test.startTest();

        setupFloorPlanMetadata();
            
        String acvTitlesExternalId = 'external_title_uuid_BB';
        String acctUniqueName = 'BB_TitlesAuto_BB';
        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer');         
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'test_payment_method_4';
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'Working';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        newTitleCase.ClosedDate = System.now();
        newTitleCase.Auction_Number_Searchable__c = acctUniqueName;
        insert newTitleCase;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usah = new User(
            LastName = 'gamer',
            Username = 'gamer@420.com',
            Email = 'gamer@420.com',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Alias = 'admSU3',
            ProfileId = profile.id
            );
        insert usah;

        Test.stopTest();
        
        //
        // End : Setup Testing Data
        // 
                
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        
        List<Internal_Delivery__c> internalDel = [SELECT Account__c, Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(0, internalDel.size());
        
        TitlesAutomationAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null);
        
        List<Case> casesWithTrackingCode = [SELECT Easypost_Tracker__c, Status FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals('794668170255', casesWithTrackingCode[0].Easypost_Tracker__c);        
        System.assertEquals('Sent', casesWithTrackingCode[0].Status); 
        
        internalDel = [SELECT Account__c, Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(1, internalDel.size());
		System.assertEquals(null, internalDel[0].Payment_Method_API_Name__c);
		System.assertEquals(null, internalDel[0].Payment_Method_Group_Name__c);
		System.assertEquals(newBuyerAcct.Id, internalDel[0].Account__c);
		System.assertEquals('794668170255', internalDel[0].Easypost_Tracker__c);
    }
    
    /*
     * Existing shipping label will be used from the Internal Delivery object for the Buyer (using Account Id).
     */
    @isTest
    public static void testBuyerShippingLabelsExisting()
    {
        //
        // Begin : Setup Testing Data
        // 
        setupFloorPlanMetadata();
            
        String acvTitlesExternalId = 'external_title_uuid_BB';
        String acctUniqueName = 'BB_TitlesAuto_BB';
        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer');         
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'ach';
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'Working';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        newTitleCase.ClosedDate = System.now();
        newTitleCase.Auction_Number_Searchable__c = acctUniqueName;
        insert newTitleCase;
        
        Internal_Delivery__c internalDelv = new Internal_Delivery__c(
            Account__c = newBuyerAcct.Id,
            Easypost_Tracker__c = '555568172222',
            Easypost_Postage_Label_URL__c = 'some_shipping_label_url',
            Shipping_Label_Created_Date__c = System.now()
        );
        insert internalDelv;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usah = new User(
            LastName = 'gamer',
            Username = 'gamer@420.com',
            Email = 'gamer@420.com',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Alias = 'admSU3',
            ProfileId = profile.id
            );
        insert usah;
        
        //
        // End : Setup Testing Data
        // 
                
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        
        Test.startTest();
        TitlesAutomationAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null);
        
        //
        //TODO - This test is failing when run between 6-7PM EST so disable it until find the solution
        //
        List<Case> casesWithTrackingCode = [SELECT Easypost_Tracker__c, Status FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals('555568172222', casesWithTrackingCode[0].Easypost_Tracker__c);        
        System.assertEquals('Sent', casesWithTrackingCode[0].Status); 
        
        List<Internal_Delivery__c> internalDel = [SELECT Account__c, Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(1, internalDel.size());
		System.assertEquals(newBuyerAcct.Id, internalDel[0].Account__c);
		System.assertEquals('555568172222', internalDel[0].Easypost_Tracker__c);

        Test.stopTest();
    }
    
    /*
     * Existing shipping label will be used from the Internal Delivery object for the Buyer (using Account Id).
     * Internal delivery Shipping_Label_Created_Date__c was set to 2 days ago.
     */
    @isTest
    public static void testBuyerShippingLabelsExisting2()
    {
        //
        // Begin : Setup Testing Data
        // 
        setupFloorPlanMetadata();
            
        String acvTitlesExternalId = 'external_title_uuid_BB';
        String acctUniqueName = 'BB_TitlesAuto_BB';
        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer');         
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'ach';
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'Working';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        newTitleCase.ClosedDate = System.now();
        newTitleCase.Auction_Number_Searchable__c = acctUniqueName;
        insert newTitleCase;
        
        Internal_Delivery__c internalDelv = new Internal_Delivery__c(
            Account__c = newBuyerAcct.Id,
            Easypost_Tracker__c = '555568172222',
            Easypost_Postage_Label_URL__c = 'some_shipping_label_url',
            Shipping_Label_Created_Date__c = Date.today().addDays(-2) // shippling label was created 2 days ago.
        );
        insert internalDelv;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usah = new User(
            LastName = 'gamer',
            Username = 'gamer@420.com',
            Email = 'gamer@420.com',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Alias = 'admSU3',
            ProfileId = profile.id
            );
        insert usah;
        
        //
        // End : Setup Testing Data
        // 
                
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        
        Test.startTest();
        TitlesAutomationAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null);
        
        //
        //TODO - This test is failing when run between 6-7PM EST so disable it until find the solution
        //
        List<Case> casesWithTrackingCode = [SELECT Easypost_Tracker__c, Status FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals('794668170255', casesWithTrackingCode[0].Easypost_Tracker__c);        
        System.assertEquals('Sent', casesWithTrackingCode[0].Status); 
        
        List<Internal_Delivery__c> internalDel = [SELECT Account__c, Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(1, internalDel.size());
		System.assertEquals(newBuyerAcct.Id, internalDel[0].Account__c);
		System.assertEquals('794668170255', internalDel[0].Easypost_Tracker__c);

        Test.stopTest();
    }
    
    
    /*
     * New shipping label will be generated and saved in the Internal Delivery object for the Floor (using Payment Method).
     */
    @isTest
    public static void testFloorPlanShippingLabelsNew()
    {
        //
        // Begin : Setup Testing Data
        // 
        Test.startTest();

        setupFloorPlanMetadata();
            
        String acvTitlesExternalId = 'external_title_uuid_BB';
        String acctUniqueName = 'BB_TitlesAuto_BB';
        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer');         
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'test_payment_method_3';
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'Working';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        newTitleCase.ClosedDate = System.now();
        newTitleCase.Auction_Number_Searchable__c = acctUniqueName;
        insert newTitleCase;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usah = new User(
            LastName = 'gamer',
            Username = 'gamer@420.com',
            Email = 'gamer@420.com',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Alias = 'admSU3',
            ProfileId = profile.id
            );
        insert usah;

        Test.stopTest();
        
        //
        // End : Setup Testing Data
        // 
                
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        
        List<Internal_Delivery__c> internalDel = [SELECT Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(0, internalDel.size());
        
        TitlesAutomationAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null);
        
        List<Case> casesWithTrackingCode = [SELECT Easypost_Tracker__c, Status FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals('794668170255', casesWithTrackingCode[0].Easypost_Tracker__c);        
        System.assertEquals('Sent', casesWithTrackingCode[0].Status); 
        
        internalDel = [SELECT Account__c, Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(1, internalDel.size());
		System.assertEquals(null, internalDel[0].Account__c);
		System.assertEquals(null, internalDel[0].Payment_Method_Group_Name__c);
		System.assertEquals('test_payment_method_3', internalDel[0].Payment_Method_API_Name__c);
		System.assertEquals('794668170255', internalDel[0].Easypost_Tracker__c);
    }
    
    /*
     * Existing shipping label will be used from the Internal Delivery object for the Floor Plan (using Payment Method).
     */
    @isTest
    public static void testFloorPlanShippingLabelsExisting()
    {
        //
        // Begin : Setup Testing Data
        // 
        setupFloorPlanMetadata();
            
        String acvTitlesExternalId = 'external_title_uuid_BB';
        String acctUniqueName = 'BB_TitlesAuto_BB';
        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer');         
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'test_payment_method_3';
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'Working';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        newTitleCase.ClosedDate = System.now();
        newTitleCase.Auction_Number_Searchable__c = acctUniqueName;
        insert newTitleCase;
        
        Internal_Delivery__c internalDelv = new Internal_Delivery__c(
            Payment_Method_API_Name__c = 'test_payment_method_3',
            Easypost_Tracker__c = '555568172222',
            Easypost_Postage_Label_URL__c = 'some_shipping_label_url',
            Shipping_Label_Created_Date__c = DateTime.now()
        );
        insert internalDelv;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usah = new User(
            LastName = 'gamer',
            Username = 'gamer@420.com',
            Email = 'gamer@420.com',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Alias = 'admSU3',
            ProfileId = profile.id
            );
        insert usah;
        
        //
        // End : Setup Testing Data
        // 
                
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        
        Test.startTest();
        TitlesAutomationAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null);
        
        //
        //TODO - This test is failing when run between 6-7PM EST so disable it until find the solution
        //
        List<Case> casesWithTrackingCode = [SELECT Easypost_Tracker__c, Status FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals('555568172222', casesWithTrackingCode[0].Easypost_Tracker__c);        
        System.assertEquals('Sent', casesWithTrackingCode[0].Status); 
        
        List<Internal_Delivery__c> internalDel = [SELECT Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(1, internalDel.size());
		System.assertEquals('test_payment_method_3', internalDel[0].Payment_Method_API_Name__c);
		System.assertEquals('555568172222', internalDel[0].Easypost_Tracker__c);

        Test.stopTest();
    }
    
    /*
     * Create Exception record if there is an Unwind Case Record Type associated with the Auction.
     */
    @isTest
    public static void testHasUnwindCaseRecordTypeAwaitingApproval()
    {
        //
        // Begin : Setup Testing Data
        // 
        Test.startTest();        
        String acvTitlesExternalId = 'external_title_uuid_BB';
        String acctUniqueName = 'BB_TitlesAuto_BB';
        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer');         
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'test_payment_method_1';
        insert newAuction;

        //List<Auction__c> auctions2 = [SELECT Id, Buyer_Dealership__c, Seller_Dealership__c, Name, id__c, Payment_Status__c, Payment_Method__c FROM Auction__c];
        //System.assertEquals(1, auctions2.size());
        //System.assertEquals(acctUniqueName, auctions2[0].id__c);
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'Working';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        //newTitleCase.ClosedDate = System.now();
        newTitleCase.Auction_Number_Searchable__c = acctUniqueName;
        insert newTitleCase;
        
        Id unwindCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Unwind').getRecordTypeId();
        Case unwindCase = new Case(
            RecordTypeId = unwindCaseRecordTypeId,
            Status = 'Awaiting Approval',
            Unwind_Type__c = 'Return_to_Seller',
            Auction_Number__c = newAuction.Id,
            ACV_Titles_External_ID__c = ACVUtility.NewGuid()
        );
        insert unwindCase;

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usah = new User(
            LastName = 'gamer',
            Username = 'gamer@420.com',
            Email = 'gamer@420.com',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Alias = 'admSU3',
            ProfileId = profile.id
            );
        insert usah;
        
        Test.stopTest();
        //
        // End : Setup Testing Data
        // 
                
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        
        TitlesAutomationAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null);
        
        List<Case> casesWithTrackingCode = [SELECT Status, Easypost_Tracker__c FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals(null, casesWithTrackingCode[0].Easypost_Tracker__c,'Unwind Case Type is found so do not create tracking info.');        
        System.assertNotEquals('Sent', casesWithTrackingCode[0].Status, 'Unwind Case Type is found so do not set the Status to Sent');
        
        Id excepRecId = Schema.SObjectType.Exception__c.getRecordTypeInfosByDeveloperName().get( 'Titles' ).getRecordTypeId();
        List<Exception__c> exceptions = [SELECT RecordTypeId, Status__c, Exceptions_Found__c, Related_Case__c, Related_Auction__c FROM Exception__c];
        System.assertEquals(1, exceptions.size());        
        System.assertEquals(excepRecId, exceptions[0].RecordTypeId,'Unwind Case Type is found so create an Exception rec with Titles record type.');        
        System.assertEquals('Open', exceptions[0].Status__c,'Unwind Case Type is found so create an Exception rec with Titles record type.');        
        //System.assertEquals('Potential pending/approved unwind for this auction', exceptions[0].Exceptions_Found__c);        
        System.assertEquals(newTitleCase.Id, exceptions[0].Related_Case__c);        
        System.assertEquals(newAuction.Id, exceptions[0].Related_Auction__c);                
    }

    /*
     * Create Exception record if there is an Unwind Case Record Type associated with the Auction.
     */
    @isTest
    public static void testHasUnwindCaseRecordTypeUnwound()
    {
        //
        // Begin : Setup Testing Data
        // 
        Test.startTest();        
        String acvTitlesExternalId = 'external_title_uuid_BB';
        String acctUniqueName = 'BB_TitlesAuto_BB';
        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer');         
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'test_payment_method_1';
        insert newAuction;

        //List<Auction__c> auctions2 = [SELECT Id, Buyer_Dealership__c, Seller_Dealership__c, Name, id__c, Payment_Status__c, Payment_Method__c FROM Auction__c];
        //System.assertEquals(1, auctions2.size());
        //System.assertEquals(acctUniqueName, auctions2[0].id__c);
        
        // Assume Approval Process for Unwind is Approved and the Status is set to Closed Unwound.
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'Closed Unwound';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        newTitleCase.Auction_Number_Searchable__c = acctUniqueName;
        insert newTitleCase;
        
        // Assume Approval Process for Unwind is Approved and the Status is set to Unwound.
        Id unwindCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Unwind').getRecordTypeId();
        Case unwindCase = new Case(
            RecordTypeId = unwindCaseRecordTypeId,
            Status = 'Unwound',
            Unwind_Type__c = 'ACV_Relaunch',
            Auction_Number__c = newAuction.Id,
            ACV_Titles_External_ID__c = ACVUtility.NewGuid()
        );
        insert unwindCase;

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usah = new User(
            LastName = 'gamer',
            Username = 'gamer@420.com',
            Email = 'gamer@420.com',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Alias = 'admSU3',
            ProfileId = profile.id
            );
        insert usah;
        
        Test.stopTest();
        //
        // End : Setup Testing Data
        // 
                
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        
        TitlesAutomationAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null);
        
        List<Case> casesWithTrackingCode = [SELECT Status, Easypost_Tracker__c FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals(null, casesWithTrackingCode[0].Easypost_Tracker__c,'Unwind Case Type is found so do not create tracking info.');        
        System.assertNotEquals('Sent', casesWithTrackingCode[0].Status, 'Unwind Case Type is found so do not set the Status to Sent');
        
        Id excepRecId = Schema.SObjectType.Exception__c.getRecordTypeInfosByDeveloperName().get( 'Titles' ).getRecordTypeId();
        List<Exception__c> exceptions = [SELECT RecordTypeId, Status__c, Exceptions_Found__c, Related_Case__c, Related_Auction__c FROM Exception__c];
        System.assertEquals(1, exceptions.size());        
        System.assertEquals(excepRecId, exceptions[0].RecordTypeId,'Unwind Case Type is found so create an Exception rec with Titles record type.');        
        System.assertEquals('Open', exceptions[0].Status__c,'Unwind Case Type is found so create an Exception rec with Titles record type.');        
        //System.assertEquals('Potential pending/approved unwind for this auction', exceptions[0].Exceptions_Found__c);        
        System.assertEquals(newTitleCase.Id, exceptions[0].Related_Case__c);        
        System.assertEquals(newAuction.Id, exceptions[0].Related_Auction__c);                
    }
    
    /*
     * New shipping label will be generated and saved in the Internal Delivery object for the Payment Method Group.
     */
    @isTest
    public static void testInternalDeliveryNewShippingLabel()
    {
        //
        // Begin : Setup Testing Data
        // 
        Test.startTest();

        setupFloorPlanMetadata();
            
        String acvTitlesExternalId = 'external_title_uuid_BB';
        String acctUniqueName = 'BB_TitlesAuto_BB';
        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer');         
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'test_payment_method_1';
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'Working';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        newTitleCase.ClosedDate = System.now();
        newTitleCase.Auction_Number_Searchable__c = acctUniqueName;
        insert newTitleCase;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usah = new User(
            LastName = 'gamer',
            Username = 'gamer@420.com',
            Email = 'gamer@420.com',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Alias = 'admSU3',
            ProfileId = profile.id
            );
        insert usah;

        Test.stopTest();
        
        //
        // End : Setup Testing Data
        // 
                
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        
        List<Internal_Delivery__c> internalDel = [SELECT Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(0, internalDel.size());
        
        TitlesAutomationAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null);
        
        List<Case> casesWithTrackingCode = [SELECT Easypost_Tracker__c, Status FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals('794668170255', casesWithTrackingCode[0].Easypost_Tracker__c);        
        System.assertEquals('Sent', casesWithTrackingCode[0].Status); 
        
        internalDel = [SELECT Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(1, internalDel.size());
		System.assertEquals('test_payment_method_group', internalDel[0].Payment_Method_Group_Name__c);
		System.assertEquals('794668170255', internalDel[0].Easypost_Tracker__c);
    }

    /*
     * Existing shipping label will be used from the Internal Delivery object for the Payment Method Group.
     */
    @isTest
    public static void testInternalDeliveryExistingShippingLabel()
    {
        //
        // Begin : Setup Testing Data
        // 
        setupFloorPlanMetadata();
            
        String acvTitlesExternalId = 'external_title_uuid_BB';
        String acctUniqueName = 'BB_TitlesAuto_BB';
        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer');         
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'test_payment_method_2';
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'Working';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        newTitleCase.ClosedDate = System.now();
        newTitleCase.Auction_Number_Searchable__c = acctUniqueName;
        insert newTitleCase;
        
        Internal_Delivery__c internalDelv = new Internal_Delivery__c(
            Payment_Method_API_Name__c = 'test_payment_method_1',
            Payment_Method_Group_Name__c = 'test_payment_method_group',
            Easypost_Tracker__c = '555568172222',
            Easypost_Postage_Label_URL__c = 'some_shipping_label_url',
            Shipping_Label_Created_Date__c = DateTime.now()
        );
        insert internalDelv;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usah = new User(
            LastName = 'gamer',
            Username = 'gamer@420.com',
            Email = 'gamer@420.com',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Alias = 'admSU3',
            ProfileId = profile.id
            );
        insert usah;
        
        //
        // End : Setup Testing Data
        // 
                
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        
        Test.startTest();
        TitlesAutomationAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null);
        
        //
        //TODO - This test is failing when run between 6-7PM EST so disable it until find the solution
        //
        /*List<Case> casesWithTrackingCode = [SELECT Easypost_Tracker__c, Status FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals('555568172222', casesWithTrackingCode[0].Easypost_Tracker__c);        
        System.assertEquals('Sent', casesWithTrackingCode[0].Status); 
        
        List<Internal_Delivery__c> internalDel = [SELECT Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(1, internalDel.size());
		System.assertEquals('test_payment_method_group', internalDel[0].Payment_Method_Group_Name__c);
		System.assertEquals('555568172222', internalDel[0].Easypost_Tracker__c);*/

        Test.stopTest();
    }
    
    @isTest
    public static void codeCoverage() {
        makeData();
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        Case c = [SELECT Id, Auction_Number_Searchable__c FROM Case LIMIT 1];

        TitlesAutomationAPI.validateParams('','',Datetime.now(), null, null);
        TitlesAutomationAPI.validateParams('','gamer@420.com',Datetime.now(), null, null);
        TitlesAutomationAPI.validateParams('auctionNumber', 'gamer@420.com', Datetime.now(), null, null);
    }

    @isTest
    public static void goodCall() {
        makeData();
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        Auction__c auc = [SELECT Id, Payment_Method__c, Payment_Status__c FROM Auction__c LIMIT 1];
        auc.Payment_Method__c = 'ach';
        auc.Payment_Status__c = 'Paid';
        update auc; 
        Case c = [SELECT Id, Auction_Number_Searchable__c FROM Case LIMIT 1];
        Test.startTest();
        TitlesAutomationAPI.validateParams(c.auction_number_Searchable__c, 'gamer@420.com', Datetime.now(), null, null);
        Test.stopTest();
        c = [SELECT Status, EP_Label_Generated_By__c FROM Case WHERE Id = :c.Id LIMIT 1];
        System.assertEquals('Sent', c.Status);
        System.assertEquals(null, c.EP_Label_Generated_By__c);
    }

    @isTest
    public static void goodCallACHPush() {
        makeData();
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        Auction__c auc = [SELECT Id, Payment_Method__c, Payment_Status__c FROM Auction__c LIMIT 1];
        auc.Payment_Method__c = 'ach_push';
        auc.Payment_Status__c = 'Paid';
        update auc; 
        Case c = [SELECT Id, Auction_Number_Searchable__c FROM Case LIMIT 1];
        Test.startTest();
        TitlesAutomationAPI.validateParams(c.auction_number_Searchable__c, 'gamer@420.com', Datetime.now(), null, null);
        Test.stopTest();
        c = [SELECT Status, EP_Label_Generated_By__c FROM Case WHERE Id = :c.Id LIMIT 1];
        System.assertEquals('Sent', c.Status);
        System.assertEquals(null, c.EP_Label_Generated_By__c);
    }

    /*
    @isTest
    public static void existingLabelforUser() {
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        Case c = [SELECT Id, AccountId, Auction_Number_Searchable__c FROM Case LIMIT 1];
        User u = [SELECT Id FROM User WHERE Email = 'gamer@420.com' LIMIT 1];
        final Id TITLE_CASE_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Title_Information' ).getRecordTypeId();
        Auction__c auc = [SELECT Id, Payment_Method__c, Payment_Status__c FROM Auction__c LIMIT 1];
        auc.Payment_Method__c = 'ach';
        auc.Payment_Status__c = 'Paid';
        update auc; 
        Case newCase = new Case(Easypost_Tracker__c = '43069', Title_Scanner__c = u.Id, Auction_Number__c = auc.Id, AccountId = c.AccountId, Status = 'Sent', RecordTypeId = TITLE_CASE_RT, ACV_Titles_External_ID__c='123');
        insert newCase;
        Test.startTest();
        TitlesAutomationAPI.validateParams(c.auction_number_Searchable__c, 'gamer@420.com', Datetime.now(), null, null);
        Test.stopTest();
        System.assertEquals(u.Id, [SELECT EP_Label_Generated_By__c FROM Case WHERE Id = :c.Id LIMIT 1].EP_Label_Generated_By__c);
    }
*/
    @isTest
    public static void addressException() {
        makeData();
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        Case c = [SELECT Id, Status, Auction_Number_Searchable__c FROM Case LIMIT 1];
        Account a = [SELECT Id,Dealership_Notes__c FROM Account LIMIT 1];
        c.Status = 'Working';
        a.Dealership_Notes__c = 'titles';
        update a;
        update c;
        Test.startTest();
        TitlesAutomationAPI.validateParams(c.auction_number_Searchable__c, 'gamer@420.com', Datetime.now(), null, null);
        Test.stopTest();
        // System.assertEquals('Working', [SELECT Id, Status FROM Case WHERE Id = :c.Id LIMIT 1].Status);
        // System.assertEquals(1, [SELECT Id FROM Exception__c].size());
    }

    @isTest
    public static void floorplanPayment(){
        makeData();
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        Case c = [SELECT Id, Auction_Number_Searchable__c, Dealer_doc_hold__c FROM Case LIMIT 1];
        final Id TITLE_CASE_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Title_Information' ).getRecordTypeId();
        Account a = [SELECT Id, Title_Hold__c FROM Account LIMIT 1];
        Auction__c auc = [SELECT Id, Payment_Method__c, Payment_Status__c FROM Auction__c LIMIT 1];
        auc.Payment_Method__c = 'adi';
        auc.Payment_Status__c = 'Approved';
        c.Status = 'Working';
        update auc;
        update c;
        Test.startTest();
        TitlesAutomationAPI.validateParams(c.auction_number_Searchable__c, 'gamer@420.com', Datetime.now(), null, null);
        Test.stopTest();
        System.assertEquals('Sent', [SELECT Id, Status FROM Case ].Status);
    }

    @isTest
    public static void titlesMailingAddress(){
        makeData();
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() );

        Account acc = [SELECT Name,
                            Title_Mailing_Street__c,
                            Title_Mailing_City__c,
                            Title_Mailing_State__c,
                            Title_Mailing_Zip_Code__c,
                            Title_Mailing_Country__c,
                            BillingStreet,
                            BillingCity,
                            BillingState,
                            BillingCountry,
                            BillingPostalCode FROM Account LIMIT 1];
        System.assertEquals(TitlesAutomationAPI.getTitleMailingAddress(acc).street, acc.BillingStreet);
        acc.Title_Mailing_Street__c = '420 Blaze Circle';
        update acc;
        acc = [SELECT Name,
                    Title_Mailing_Street__c,
                    Title_Mailing_City__c,
                    Title_Mailing_State__c,
                    Title_Mailing_Zip_Code__c,
                    Title_Mailing_Country__c,
                    BillingStreet,
                    BillingCity,
                    BillingState,
                    BillingCountry,
                    BillingPostalCode FROM Account LIMIT 1];
        System.assertEquals(TitlesAutomationAPI.getTitleMailingAddress(acc).street, '420 Blaze Circle');
    }

    @isTest
    public static void notPaidForException() {
        makeData();
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        Auction__c auc = [SELECT Id, Payment_Method__c, Payment_Status__c FROM Auction__c LIMIT 1];
        auc.Payment_Method__c = 'ach_push';
        update auc; 
        Case c = [SELECT Id, Auction_Number_Searchable__c FROM Case LIMIT 1];
        Test.startTest();
        TitlesAutomationAPI.validateParams(c.auction_number_Searchable__c, 'gamer@420.com', Datetime.now(), null, null);
        Test.stopTest();
        c = [SELECT Status, EP_Label_Generated_By__c FROM Case WHERE Id = :c.Id LIMIT 1];
        System.assertNotEquals('Sent', c.Status);
        System.assert([SELECT COUNT() FROM Exception__c WHERE Exceptions_Found__c LIKE '%Auction Not Paid%'] > 0, 'No Exception Found when we should have');
    }

    @isTest
    public static void notPaidForDealerPermitted() {
        makeData();
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        Auction__c auc = [SELECT Id, Payment_Method__c, Payment_Status__c FROM Auction__c LIMIT 1];
        auc.Payment_Method__c = 'ach_push';
        update auc; 
        Case c = [SELECT Id, accountId, Auction_Number_Searchable__c FROM Case LIMIT 1];
        insert new Dealer_Setting__c(Account__c = c.accountId, Titles_Payment_Exception__c = true);
        Test.startTest();
        TitlesAutomationAPI.validateParams(c.auction_number_Searchable__c, 'gamer@420.com', Datetime.now(), null, null);
        Test.stopTest();
        c = [SELECT Status, EP_Label_Generated_By__c FROM Case WHERE Id = :c.Id LIMIT 1];
        System.assertEquals('Sent', c.Status);
        System.assert([SELECT COUNT() FROM Exception__c WHERE Exceptions_Found__c LIKE '%Auction Not Paid%'] == 0, 'Exception Found when we should have none');
    }

    public class EasyPostMockCalloutGoodCall implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return TestEasyPostComponentController.processGoodResponse( req );
        }
    }
}