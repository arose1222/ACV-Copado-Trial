/**
 * This is Handler class for BundleOfferTrigger 
 * holds the logic for automated process
 * @author Pankaj Kumar
 * @group Vehicle Intelligence 
 */

public class BundleOfferTriggerHandler extends TriggerInterface {
    public override void beforeInsert(List<SObject> newList) {
        doBeforeInsert((List<Bundled_Offer__c>) newList);
	}
	public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        doBeforeUpdate((List<Bundled_Offer__c>) newMap.values(), (Map<Id, Bundled_Offer__c>) oldMap);
	}
    
    /**
     * @description BEFORE INSERT LOGIC
     * 
     * @param newList List of inserted Bundled_Offer__c
     * @return void
     * 
     */
    public static void doBeforeInsert(List<Bundled_Offer__c> newList){
        List<Bundled_Offer__c> dealerBundleOfferList = new List<Bundled_Offer__c>();
        Set<Id> dealerIds = new Set<Id>();
        
        // traversing newList to store bundleOffer where dealer is NOT NULL
        for(Bundled_Offer__c bundledOffer : newList) {
            if(bundledOffer.Dealer__c != null) {
                dealerBundleOfferList.add(bundledOffer);
                dealerIds.add(bundledOffer.Dealer__c );
            }
        }
        
        if(!dealerBundleOfferList.isEmpty()){
            populateSenderEmailAddress(newList, dealerIds);
        }
    }
    
    /**
     * @description BEFORE UPDATE LOGIC
     * 
     * @param newList List of updated Bundled_Offer__c
     * @param oldMap Map of Bundled offer Id to Bundled Offer record, storing old version of Bundled Offer record
     * @return void
     * 
     */
    public static void doBeforeUpdate(List<Bundled_Offer__c> newList, Map<Id, Bundled_Offer__c> oldMap){
        List<Bundled_Offer__c> dealerBundleOfferList = new List<Bundled_Offer__c>();
        Set<Id> dealerIds = new Set<Id>();
        
        // traversing newList to store bundleOffer where dealer is NOT NULL
        for(Bundled_Offer__c bundledOffer : newList) {
            if(bundledOffer.Dealer__c != null &&  bundledOffer.Dealer__c != oldMap.get(bundledOffer.Id).Dealer__c) {
                dealerBundleOfferList.add(bundledOffer);
                dealerIds.add(bundledOffer.Dealer__c );
            }
        }
        
        if(!dealerBundleOfferList.isEmpty()){
            populateSenderEmailAddress(newList, dealerIds);
        }
    }
    
    /**
     * @description Sets the Seller Email Address field on Bundled offer to Dealer's Primary Contact's Email
     * 
     * @param dealerBundleOfferList List of Bundled offer
     * @param dealerIds Set of dealer Ids
     * @return void
     * 
     */
    public static void populateSenderEmailAddress(List<Bundled_Offer__c> dealerBundleOfferList,  Set<Id> dealerIds ) {
        Map<Id, String> dealerEmailMap = new Map<Id, String>();
        for(Account acc : [SELECT Id, Primary_Contact__r.Email
                           FROM Account 
                           WHERE Id IN :dealerIds 
                           AND Primary_Contact__r.Email != null]) 
        {
            dealerEmailMap.put(acc.Id, acc.Primary_Contact__r.Email);
        }
        
        for(Bundled_Offer__c bundledOffer : dealerBundleOfferList){
            if(dealerEmailMap.containsKey(bundledOffer.Dealer__c)){
                bundledOffer.Seller_Email_Address__c = dealerEmailMap.get(bundledOffer.Dealer__c);
            }
        }
    }
}