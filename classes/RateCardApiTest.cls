/**
 * Test Class for RateCardApi class
 * @author James Andre LaCour
 * @since May 6th, 2021
 */
@isTest
public class RateCardApiTest {
    /**
     * Creates Test Data
     */
    @TestSetup
    static void makeData(){
        User u = TestUtility.createUser();
        u.LastName = 'RateCardTestLastName';
        u.Id__c = '9999';
        insert u;
        System.runAs(u){
            Rate_Card__c rc = TestUtility.createRateCard();
            insert rc;
            Rate_Card_Fee__c rcf = TestUtility.createRateCardFee(rc, 1, 100);
            insert rcf;
        }
    }
    /**
     * Test the creation of the HTTPRequest helper class
     */
    public static testMethod void  createHttpRequestPublishRateCardTest(){
        List<Rate_Card__c> rcList = [ SELECT Id, Display_Name__c, Fee_Type__c, CreatedById, CreatedBy.Id__c, (SELECT Id, Price_Min__c, Fee_Charged__c FROM Rate_Card_Fees__r) FROM Rate_Card__c LIMIT 1 ];
        System.assertEquals(1, rcList.size());
        String testAcvId = '1234';
        Test.startTest();
            HttpRequest req = RateCardApi.createHttpRequestPublishRateCard(rcList[0], testAcvId);
        Test.stopTest();
        System.assert( req.getEndpoint().endsWith(RateCardApi.PUBLISH_RATE_CARD_ENDPOINT_SUFFIX) );
        System.assertEquals( 'POST', req.getMethod() );
        System.assertEquals( 'application/json', req.getHeader('Content-Type') );
    }
    /**
     * Test the Creation of the PublishRateCard json data structure 
     */
    public static testMethod void  createPublishRateCardTest(){
        List<User> u = [ SELECT Id, Id__c FROM User WHERE LastName = 'RateCardTestLastName' LIMIT 1 ];
        System.assertEquals( 1, u.size() );
        String acvId = '1234';
        List<Rate_Card__c> rcList = [ SELECT Id, Display_Name__c, Fee_Type__c, CreatedById, CreatedBy.Id__c, (SELECT Id, Price_Min__c, Fee_Charged__c FROM Rate_Card_Fees__r) FROM Rate_Card__c LIMIT 1 ];
        System.assertEquals(1, rcList.size());
        Test.startTest();
            RateCardApi.PublishRateCard prc = null;
            System.runAs(u[0]){
                prc = RateCardApi.createPublishRateCard(rcList[0], acvId);
            }
        Test.stopTest();
        System.assertEquals( rcList[0].Display_Name__c, prc.name );
        System.assertEquals( true, prc.shared );
        System.assertEquals( rcList[0].Fee_Type__c, prc.feeType );
        System.assertEquals( 1, prc.pricePoints.size() );
        System.assertEquals( rcList[0].Rate_Card_Fees__r[0].Price_Min__c, prc.pricePoints[0].minimumPrice.amount );
        System.assertEquals( rcList[0].Rate_Card_Fees__r[0].Fee_Charged__c, prc.pricePoints[0].rate.amount );
        System.assertEquals( Integer.valueOf(u[0].Id__c), prc.createdBy );
        System.assertEquals( Integer.valueOf(acvId), prc.approvedBy );

    }
}