@isTest
public class TitlesReceivedAPITest {
    
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
        insert usah;
        Account actObj = TestUtility.createAccount();
        insert actObj;
        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;
        Vehicle__c vehicleObj = TestUtility.createVehicle();
        insert vehicleObj;
        Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
    	insert auctionObj;
        Case caseObj =  TestUtility.createTitleCase(auctionObj, actObj, contactObj);
        caseObj.Status = 'New';
        insert caseObj;
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

        // Assume Approval Process for Unwind is Pending.
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        //newTitleCase.ClosedDate = System.now();
        newTitleCase.Auction_Number_Searchable__c = acctUniqueName;
        insert newTitleCase;
        
        // Assume Approval Process for Unwind is Pending and the Status is set to Awaiting Approval.
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
        
        TitlesReceivedAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null, 'New York');
        
        List<Case> casesWithTrackingCode = [SELECT Status, Title_State__c FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals('Received', casesWithTrackingCode[0].Status);
        System.assertEquals('New York', casesWithTrackingCode[0].Title_State__c);
        
        Id excepRecId = Schema.SObjectType.Exception__c.getRecordTypeInfosByDeveloperName().get( 'Titles' ).getRecordTypeId();
        List<Exception__c> exceptions = [SELECT RecordTypeId, Status__c, Exceptions_Found__c, Related_Case__c, Related_Auction__c FROM Exception__c];
        System.assertEquals(1, exceptions.size());        
        System.assertEquals(excepRecId, exceptions[0].RecordTypeId,'Unwind Case Type is found so create an Exception rec with Titles record type.');        
        System.assertEquals('Open', exceptions[0].Status__c,'Unwind Case Type is found so create an Exception rec with Titles record type.');        
        //System.assertEquals('Potential pending/approved unwind for this auction', exceptions[0].Exceptions_Found__c);        
        System.assertEquals(newTitleCase.Id, exceptions[0].Related_Case__c);        
        System.assertEquals(newAuction.Id, exceptions[0].Related_Auction__c);                                
    }
    
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
        
        TitlesReceivedAPI.validateParams(acctUniqueName, 'gamer@420.com', Datetime.now(), null, null, 'New York');
        
        List<Case> casesWithTrackingCode = [SELECT Status, Title_State__c FROM Case WHERE Id = :newTitleCase.Id];
        System.assertEquals(1, casesWithTrackingCode.size());        
        System.assertEquals('Closed Unwound', casesWithTrackingCode[0].Status);
        System.assertEquals('New York', casesWithTrackingCode[0].Title_State__c);
        
        Id excepRecId = Schema.SObjectType.Exception__c.getRecordTypeInfosByDeveloperName().get( 'Titles' ).getRecordTypeId();
        List<Exception__c> exceptions = [SELECT RecordTypeId, Status__c, Exceptions_Found__c, Related_Case__c, Related_Auction__c FROM Exception__c];
        System.assertEquals(1, exceptions.size());        
        System.assertEquals(excepRecId, exceptions[0].RecordTypeId,'Unwind Case Type is found so create an Exception rec with Titles record type.');        
        System.assertEquals('Open', exceptions[0].Status__c,'Unwind Case Type is found so create an Exception rec with Titles record type.');        
        //System.assertEquals('Potential pending/approved unwind for this auction', exceptions[0].Exceptions_Found__c);        
        System.assertEquals(newTitleCase.Id, exceptions[0].Related_Case__c);        
        System.assertEquals(newAuction.Id, exceptions[0].Related_Auction__c);                                
    }

    @isTest
    public static void receiveTitle() {
        makeData();
        
        Case titleCase = [SELECT Auction_Number_Searchable__c FROM Case LIMIT 1];
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;

        TitlesReceivedAPI.validateParams(titleCase.Auction_Number_Searchable__c,'gamer@420.com',Datetime.now(), null, null, 'New York');

        System.assertEquals('Received', [SELECT Status FROM Case LIMIT 1].Status);
        System.assertEquals('New York', [SELECT Title_State__c FROM Case LIMIT 1].Title_State__c);
    }

    @isTest 
    public static void alreadyReceived() {
        makeData();
        
        Auction__c auc = [ SELECT payment_status__c FROM Auction__C LIMIT 1 ];
        Case titleCase = [SELECT Auction_Number_Searchable__c FROM Case LIMIT 1];
        titleCase.status = 'Received';
        update titleCase;
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;

        TitlesReceivedAPI.validateParams(titleCase.Auction_Number_Searchable__c,'gamer@420.com',Datetime.now(), null, null, 'New York');

        System.assertEquals(1, [SELECT Id FROM Exception__c].size());
    }
}