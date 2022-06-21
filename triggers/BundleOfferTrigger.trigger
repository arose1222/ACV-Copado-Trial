/**
 * Trigger BundleOfferTrigger on Bundled_Offer__c Object
 * Fire the DML events
 * @author Pankaj Kumar
 * @group Vehicle Intelligence 
 */
trigger BundleOfferTrigger on Bundled_Offer__c (before insert, before update) {    
    (new TriggerFrameWork()).handle();
}