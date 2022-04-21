/**
 * This class handles the logic of PReventing Rate Cards from being deleted based on the status
 * @author James Andre LaCour
 * @since April 29th, 2021
 */
public without sharing class RateCardDeletionValidation extends TriggerInterface{
    /**
     * Error Message shown if we are preventing deletion. Controlled by Custom Label Rate_Card_Cant_Delete_Error_Message
     */
    @TestVisible private static final String CANT_DELETE_ERROR_MESSAGE = System.Label.Rate_Card_Cant_Delete_Error_Message;
    /**
     * A set of the Eligible Deletion Statuses controlled by the Salesforce Setting - Rate_Card_Eligible_Deletion_Status
     */
    @TestVisible private static Set<String> ELIGIBLE_DELETION_STATUSES = new Set<String>( ACVUtility.getSalesforceSettings(new Set<String>{'Rate_Card_Eligible_Deletion_Status'}).get('Rate_Card_Eligible_Deletion_Status').Value__c.split(';') );
    /**
     * Runs Before Delete logic for Rate Card
     * @param oldMap 
     */
    public override void beforeDelete( Map<Id, SObject> oldMap ){
        preventDeletionBasedOnStatus(oldMap);
    }
    /**
     * Based on ELIGIBLE_DELETION_STATUSES, determines if the rate card can be deleted
     * @param oldMap 
     */
    public void preventDeletionBasedOnStatus( Map<Id, SObject> oldMap ){
        if( ELIGIBLE_DELETION_STATUSES.isEmpty() ) return;
        for( Rate_Card__c rc : (List<Rate_Card__c>)oldMap.values() ){
            if( !ELIGIBLE_DELETION_STATUSES.contains(rc.Approval_Status__c) ){
                rc.addError(CANT_DELETE_ERROR_MESSAGE);
            }
        }
    }
}