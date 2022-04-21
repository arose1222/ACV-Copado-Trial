/**
 * Test Class for WisconsinBadgeLogic
 * @author James Andre LaCour
 * @since Aug 12th, 2021
 */
@isTest
public class WisconsinBadgeLogicTest {
    /********************Test Data Setup*************************/
    /**
     * Creates Data needed for Test Methods
     * @return void
     */
    @TestSetup
    public static void makeData(){
        Account acct = TestUtility.createAccount('Test Dealership');
        acct.BillingState = 'WI';
        insert acct;
        Contact con = TestUtility.createContact(acct);
        insert con;
        Vehicle__c veh = TestUtility.createVehicle();
        insert veh;
        Auction__c auc = TestUtility.createAuction(acct, con, veh);
        auc.Buyer_Dealership__c = acct.Id;
        auc.Seller_Dealership__c = acct.Id;
        insert auc;
        Case cse = TestUtility.createCase(auc, veh, acct, con);
        cse.Type = 'Titles';
        cse.AccountId = acct.Id;
        cse.Seller_Dealership__c = acct.Id;
        cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
        cse.ACV_Titles_External_ID__c = '12345';
        insert cse;
    }
    /********************Test Methods****************************/
    /**
     * Test the WI badge on the Account record
     * @return void
     */
    public static testMethod void accountTest(){
        List<Account> acctList = [ SELECT Id FROM Account LIMIT 1 ];
        System.assertEquals( 1, acctList.size() );
        Test.startTest();
            Boolean eligilbeBadge = new WisconsinBadgeLogic().checkLogic( 'Wisconsin_Account', acctList[0].Id );
        Test.stopTest();
        System.assertEquals( true, eligilbeBadge );
    }
    /**
     * Test the WI Badge on the case record
     * @return void
     */
    public static testMethod void caseTest(){
        List<Case> caseList = [ SELECT Id FROM Case LIMIT 1 ];
        System.assertEquals( 1, caseList.size() );
        Test.startTest();
            Boolean eligilbeBadge = new WisconsinBadgeLogic().checkLogic( 'Wisconsin_Case', caseList[0].Id );
        Test.stopTest();
        System.assertEquals( true, eligilbeBadge );
    }
    /**
     * Test the WI badge on the Auction record for Seller and Buyer Dealership
     * @return void
     */
    public static testMethod void auctionTest(){
        List<Auction__c> aucList = [ SELECT Id FROM Auction__c LIMIT 1 ];
        System.assertEquals( 1, aucList.size() );
        Test.startTest();
            Boolean eligilbeBadgeSeller = new WisconsinBadgeLogic().checkLogic( 'Wisconsin_Auction_Seller', aucList[0].Id );
            Boolean eligilbeBadgeBuyer = new WisconsinBadgeLogic().checkLogic( 'Wisconsin_Auction_Buyer', aucList[0].Id );
        Test.stopTest();
        System.assertEquals( true, eligilbeBadgeSeller );
        System.assertEquals( true, eligilbeBadgeBuyer );
    }
}