/******************************************************************************* 
@description Base trigger for email message object
@author Huron Consulting Group
*******************************************************************************/
trigger EmailMessageTrigger on EmailMessage (before insert, before update, after update, after insert, before delete, after delete) {
    (new TriggerFrameWork()).handle();
}