trigger ServiceTerritoryMemberTrigger on ServiceTerritoryMember (before insert, before update, before delete, after insert,after update, after delete, after undelete) {
    system.debug('stm trigger');
    (new TriggerFrameWork()).handle();
}