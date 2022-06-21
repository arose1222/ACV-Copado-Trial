@isTest
public class TitlesAutomationAPITest {
    @TestSetup
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