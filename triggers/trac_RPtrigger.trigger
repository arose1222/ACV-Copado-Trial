/**
 * Created by zdeng on 9/23/2019.
 */

trigger trac_RPtrigger on ResourcePreference (before insert, before update, before delete, after insert,after update, after delete, after undelete) {
    (new TriggerFrameWork()).handle();
}