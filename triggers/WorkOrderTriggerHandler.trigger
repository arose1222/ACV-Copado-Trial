trigger WorkOrderTriggerHandler on WorkOrder (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    (new TriggerFrameWork()).handle();
}