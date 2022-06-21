@isTest
public class TitleCheckForAuctionPaymentTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        TestUtility.createAccount();
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
        insert usah;
        Account actObj = TestUtility.createAccount();
        insert actObj;
        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;
        Vehicle__c vehicleObj = TestUtility.createVehicle();
        insert vehicleObj;
        Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
        auctionObj.Payment_Status__c = 'Pending';
        auctionObj.Payment_Method__c = 'ach';
    	insert auctionObj;
        Case caseObj =  TestUtility.createTitleCase(auctionObj, actObj, contactObj);
        caseObj.Hold_For_Payment__c = System.today().addDays(3);
        insert caseObj;
    }

    @isTest
    static void testMovingFromNotPaidToPaid(){
        List<Auction__c> auctionList = [select id, Payment_Status__c from Auction__c];
        auctionList[0].Payment_Status__c = 'paid';
        update auctionList;
        List<Case> caseList = [select id, Hold_For_Payment__c from case where Hold_For_Payment__c = null];
        system.assert(caseList.size() > 0, 'No cases returned when we should have gotten one');
    }

    @isTest
    static void testNoPaymentUpdate(){
        List<Auction__c> auctionList = [select id, Payment_Status__c from Auction__c];
        update auctionList;
        List<Case> caseList = [select id, Hold_For_Payment__c from case where Hold_For_Payment__c = null];
        system.assert(caseList.size() == 0, 'cases returned when we should have gotten none');
    }
}