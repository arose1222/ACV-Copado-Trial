/**
 * @description ${DESCRIPTION}
 * @name tracDataScheduleTrigger
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-09-05
 */

trigger tracDataScheduleTrigger on Data_Schedule__c (before insert, before update, before delete, after insert, after update, after delete, after undelete ) {
    (new TriggerFrameWork()).handle();
    // if(Trigger.isInsert) {
    //     if(Trigger.isBefore) {
    //         tracDataScheduleHandler.handleValidateInsert(Trigger.new);
    //         tracDataScheduleHandler.handleBeforeInsert(Trigger.new);
    //     }
    // } else if(Trigger.isUpdate) {
    //     if(Trigger.isBefore) {
    //         tracDataScheduleHandler.handleBeforeUpdate(Trigger.new,Trigger.oldMap);
    //     } else if(Trigger.isAfter) {
    //         tracDataScheduleHandler.handleAfterUpdate(Trigger.new,Trigger.oldMap);
    //     }
    // } else if(Trigger.isUndelete) {
    //     if(Trigger.isAfter) {
    //         tracDataScheduleHandler.handleAfterUndelete(Trigger.new);
    //     }
    // }
}