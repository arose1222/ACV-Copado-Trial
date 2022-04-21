/**
 * Test class for CaliforniaBadgeLogic
 * @author James Andre LaCour
 * @since Aug 10th, 2021
 */
@isTest
public  class CaliforniaBadgeLogicTest {
    /********************Test Data Setup*************************/
    /**
     * Creates Data needed for Test Methods
     * @return void
     */
    @TestSetup
    public static void makeData(){
        Account acct = TestUtility.createAccount('Test Dealership');
        acct.BillingState = 'CA';
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
        cse.Seller_Dealership__c = acct.Id;
        cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
        cse.ACV_Titles_External_ID__c = '12345';
        insert cse;
    }
    /********************Test Methods****************************/
    /**
     * Test the Californa Badge on the Case record
     * @return void
     */
    public static testMethod void caseSellerTest(){
        List<Case> caseList = [ SELECT Id FROM Case LIMIT 1 ];
        System.assertEquals( 1, caseList.size() );
        Test.startTest();
            Boolean eligilbeBadge = new CaliforniaBadgeLogic().checkLogic( 'California_Seller_Case', caseList[0].Id );
        Test.stopTest();
        System.assertEquals( true, eligilbeBadge );
    }
    /**
     * Test the California on the Auction record for Seller Dealership
     * @return void
     */
    public static testMethod void auctionSellerTest(){
        List<Auction__c> aucList = [ SELECT Id FROM Auction__c LIMIT 1 ];
        System.assertEquals( 1, aucList.size() );
        Test.startTest();
            Boolean eligilbeBadgeSeller = new CaliforniaBadgeLogic().checkLogic( 'California_Seller_Auction', aucList[0].Id );
        Test.stopTest();
        System.assertEquals( true, eligilbeBadgeSeller );
    }
}