/**
 * The Test class for RateCardDeletionValidation
 * @author James Andre LaCour
 * @since April 30th, 2021
 */
@isTest
public class RateCardDeletionValidationTest{
    /**
     * Makes Test data per Test Method
     */
    @TestSetup
    public static void makeData(){
        Rate_Card__c rc = TestUtility.createRateCard();
        rc.Approval_Status__c = 'Draft';
        insert rc;
    }
    /**
     * Test that deleting a Rate card with an eligible status works
     */
    public static testMethod void eligibleStatusTest(){
        RateCardDeletionValidation.ELIGIBLE_DELETION_STATUSES = new Set<String>{'Draft'};
        List<Rate_Card__c> rcs = [ SELECT Id FROM Rate_Card__c LIMIT 1 ];
        System.assertEquals(1, rcs.size() );
        Test.startTest();
            try{
                delete rcs;
            }catch(Exception ex){
                System.assert( false, 'Deletion should be successful' );
            }
        Test.stopTest();
    }
    /**
     *  Test that deleting a Rate card without an eligible status fails 
     */
    public static testMethod void ineligibleStatusTest(){
        RateCardDeletionValidation.ELIGIBLE_DELETION_STATUSES = new Set<String>{'Not a valid Status'};
        List<Rate_Card__c> rcs = [ SELECT Id FROM Rate_Card__c LIMIT 1 ];
        System.assertEquals(1, rcs.size() );
        Test.startTest();
            try{
                delete rcs;
                System.assert( false, 'Should have thrown an error' );
            }catch(Exception ex){
                System.assert( ex.getMessage().contains(RateCardDeletionValidation.CANT_DELETE_ERROR_MESSAGE) );
            }
        Test.stopTest();
    }
}