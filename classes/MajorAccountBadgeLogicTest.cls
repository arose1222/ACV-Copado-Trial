/**
 * Test Class for the MajorAccountBadgeLogic
 * @author James Andre LaCour
 */
@isTest
public class MajorAccountBadgeLogicTest {
    /********************Test Data Setup*************************/
    /**
     * Creates Data needed for Test Methods
     * @return void
     */
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account acct = TestUtility.createAccount('Test Dealership');
        insert acct;
        Contact con = TestUtility.createContact(acct);
        insert con;
        Vehicle__c veh = TestUtility.createVehicle();
        insert veh;
        Group__c grp = TestUtility.createGroup('Major Group');
        grp.Top_150_Rank__c = 0;
        grp.Major_Account__c = true;
        insert grp;
        List<Group_Affiliation__c> grpAffilList = TestUtility.createGroupAffiliation( grp, new List<Account>{acct} );
        for( Group_Affiliation__c grpAffil : grpAffilList ){
            grpAffil.Active__c = true;
        }
        insert grpAffilList;
        Affiliation__c conAffil = new Affiliation__c(Active__c = true);
        conAffil.Contact__c = con.Id;
        conAffil.Account__c = acct.Id;
        insert conAffil;
        Auction__c auc = TestUtility.createAuction(acct, con, veh);
        auc.Buyer_Dealership__c = acct.Id;
        auc.Seller_Dealership__c = acct.Id;
        insert auc;
        Case cse = TestUtility.createCase(auc, veh, acct, con);
        insert cse;
    }
    /********************Test Methods****************************/
    /**
     * Test the Major Account Checkbox on the Account record
     * @return void
     */
    public static testMethod void MajorAccountAccountTest(){
        List<Account> acctList = [ SELECT Id FROM Account LIMIT 1 ];
        System.assertEquals( 1, acctList.size() );
        Test.startTest();
            Boolean eligilbeBadge = new MajorAccountBadgeLogic().checkLogic( 'Major_Account_Checkmark_Account', acctList[0].Id );
        Test.stopTest();
        System.assertEquals( true, eligilbeBadge );
    }
    /**
     * Test the Major Account checkbox on the Auction record for Seller and Buyer Dealership
     * @return void
     */
    public static testMethod void MajorAccountAuctionTest(){
        List<Auction__c> aucList = [ SELECT Id FROM Auction__c LIMIT 1 ];
        System.assertEquals( 1, aucList.size() );
        Test.startTest();
            Boolean eligilbeBadgeSeller = new MajorAccountBadgeLogic().checkLogic( 'Major_Account_Checkmark_Seller_Auction', aucList[0].Id );
            Boolean eligilbeBadgeBuyer = new MajorAccountBadgeLogic().checkLogic( 'Major_Account_Checkmark_Buyer_Auction', aucList[0].Id );
        Test.stopTest();
        System.assertEquals( true, eligilbeBadgeSeller );
        System.assertEquals( true, eligilbeBadgeBuyer );
    }
    /**
     * Test the Major Account checkbox on the Case record
     * @return void
     */
    public static testMethod void MajorAccountCaseTest(){
        List<Case> caseList = [ SELECT Id FROM Case LIMIT 1 ];
        System.assertEquals( 1, caseList.size() );
        Test.startTest();
            Boolean eligilbeBadge = new MajorAccountBadgeLogic().checkLogic( 'Major_Account_Checkmark_Case', caseList[0].Id );
        Test.stopTest();
        System.assertEquals( true, eligilbeBadge );
    }
    /**
     * Test the Major Account Checkbox on the Contact record 
     * @return void
     */
    public static testMethod void MajorAccountContactTest(){
        List<Contact> conList = [ SELECT Id FROM Contact LIMIT 1 ];
        System.assertEquals( 1, conList.size() );
        Test.startTest();
            Boolean eligilbeBadge = new MajorAccountBadgeLogic().checkLogic( 'Major_Account_Checkmark_Contact', conList[0].Id );
        Test.stopTest();
        System.assertEquals( true, eligilbeBadge );
    }
}