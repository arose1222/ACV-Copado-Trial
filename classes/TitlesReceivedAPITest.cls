@isTest
public class TitlesReceivedAPITest {
    
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

    @isTest
    public static void receiveTitle() {
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