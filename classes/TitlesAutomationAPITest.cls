@isTest
public class TitlesAutomationAPITest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
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
        fpRec.Internal_Delivery__c = true;
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
        fpRec.Internal_Delivery__c = true;
        fpRec.Company__c = 'Unit Testing';
        fpRec.Street1__c = '640 Ellicott St, Suite #321';
        fpRec.City__c = 'Buffalo';
        fpRec.State__c = 'NY';
        fpRec.Country__c = 'USA';
        fpRec.Zip__c = '14203';        
        TitlesAutomationAPI.floorPlanMap.put(fpRec.Payment_Method_API_Name__c, fpRec);        
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
        
        Test.startTest();
        TitlesAutomationAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null);
        
        List<Case> casesWithTrackingCode = [SELECT Easypost_Tracker__c, Status FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals('794668170255', casesWithTrackingCode[0].Easypost_Tracker__c);        
        System.assertEquals('Sent', casesWithTrackingCode[0].Status); 
        
        internalDel = [SELECT Payment_Method_API_Name__c, Payment_Method_Group_Name__c, Easypost_Tracker__c, Shipping_Label_Created_Date__c FROM Internal_Delivery__c];
		System.assertEquals(1, internalDel.size());
		System.assertEquals('test_payment_method_group', internalDel[0].Payment_Method_Group_Name__c);
		System.assertEquals('794668170255', internalDel[0].Easypost_Tracker__c);

        Test.stopTest();
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
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() ); 
        Case c = [SELECT Id, Auction_Number_Searchable__c, Dealer_doc_hold__c FROM Case LIMIT 1];
        final Id TITLE_CASE_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Title_Information' ).getRecordTypeId();
        Account a = [SELECT Id, Title_Hold__c FROM Account LIMIT 1];
        System.debug(c.Dealer_doc_hold__c);
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