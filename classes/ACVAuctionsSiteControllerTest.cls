/**
 * Test class for ACVAuctionsSiteController
 * @author Pankaj Kumar
 * @group Vehicle Intelligence 
 */
@isTest
public class ACVAuctionsSiteControllerTest {
    @testSetup static void makeData() {
        Account acc = TestUtility.createAccount();
        insert acc;
        
        Bundled_Offer__c bundleOffer = TestUtility.createBundleOffer(acc.Id);
        insert bundleOffer;
    }
    
    @isTest static void updateBundleOfferStatusTest() {
        Bundled_Offer__c bundleOffer = [SELECT Id FROM Bundled_Offer__c LIMIT 1];
        
        Test.startTest();
            Boolean result1 = ACVAuctionsSiteController.updateBundleOfferStatus(bundleOffer.Id);
            System.assertEquals(result1, true, 'Bundled Offer is not updated.');
            
            Boolean result2 = ACVAuctionsSiteController.updateBundleOfferStatus(bundleOffer.Id);
            System.assertEquals(result2, false, 'Bundled Offer is updated.');
        Test.stopTest();
    }
}