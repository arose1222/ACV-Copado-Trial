/**
 * Test class for CaptialEliteDealerBadgeLogic
 * @author Naveen Varshney
 * @since Oct 26th, 2021
 */
@isTest
public  class CaptialEliteDealerBadgeLogicTest {
    /********************Test Data Setup*************************/
    /**
     * Creates Data needed for Test Methods
     * @return void
     */
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        List<Account> accList = new List<Account>();
        Account acct = TestUtility.createAccount('Test Dealer Type');
        acct.Capital_Dealer_Type__c = 'Capital Orange Elite';
        accList.add(acct);
        
        // account with no capital dealer type
        Account acct1 = TestUtility.createAccount('Dealer Type 2');
        accList.add(acct1);
        insert accList;
    }
    /********************Test Methods****************************/
    /**
     * Test the CaptialEliteDealerBadge on the Account record
     * @return void
     */
    public static testMethod void accountCapitalDealerTest(){
        List<Account> accList = [ SELECT Id FROM Account];
        System.assertEquals( 2, accList.size() );
        Test.startTest();
        CaptialEliteDealerBadgeLogic capBadgeLogic = new CaptialEliteDealerBadgeLogic();
        Boolean eligilbeBadge = capBadgeLogic.checkLogic( 'Capital_Orange_Elite_Dealers_Account', accList[0].Id );
        Boolean eligilbeBadgeFalse = capBadgeLogic.checkLogic( 'Capital_Orange_Elite_Dealers_Account', accList[1].Id );
        Test.stopTest();
        System.assertEquals( true, eligilbeBadge );
        System.assertEquals( false, eligilbeBadgeFalse );
    }
}