/**
 * Created by zdeng on 9/24/2019.
 */

trigger trac_ServiceAppointmentTrigger on ServiceAppointment (before insert, before update, before delete, after insert,after update, after delete, after undelete) {
    (new TriggerFrameWork()).handle();    
}