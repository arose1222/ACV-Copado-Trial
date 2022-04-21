/**
 * @description 
 * 
 * 
 * @author Manmeet Vaseer
 * @date 03/17/2022
 * 
 * @history
 * 		03/17/2022 Manmeet Vaseer - Initial Revision.
 * 
 */ 
trigger TitleReviewTrigger on Title_Review__c (after insert,after update,before insert,before update, before delete, after delete, after undelete) {
    (new TriggerFrameWork()).handle();
}