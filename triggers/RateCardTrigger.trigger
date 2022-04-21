/**
 * The Trigger for Rate Card
 * @author James Andre LaCour
 * @since April 29th, 2021
 */
trigger RateCardTrigger on Rate_Card__c ( before insert, before update, after insert, after update, before delete, after delete, after undelete ) {
    (new TriggerFrameWork()).handle();
}