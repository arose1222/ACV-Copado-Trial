/**
 * Controller ACVAuctionsSiteController for public site page
 * Update the Bundle offer status
 * @author Pankaj Kumar
 * @group Vehicle Intelligence 
 */
public without sharing class ACVAuctionsSiteController {
    /**
     * @description Update the status on Bundle Offer record
     * 
     * @param bundleOfferId Bundle Offer Record Id
     * @return void
     * 
     */
    @AuraEnabled
    public static Boolean updateBundleOfferStatus(String bundleOfferId){
        try {
            
            for(Bundled_Offer__c bO : [SELECT Id FROM Bundled_Offer__c WHERE Id = :bundleOfferId AND Bundle_Status__c = 'Active' LIMIT 1]) {
                return false;
            }

            Bundled_Offer__c bundledOffer = new Bundled_Offer__c();
            bundledOffer.Id = bundleOfferId;
            bundledOffer.Bundle_Status__c = 'Active';
            bundledOffer.Offer_Accepted__c = true;
            bundledOffer.Offer_Accepted_Date__c = System.now();
            update bundledOffer;
            
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}