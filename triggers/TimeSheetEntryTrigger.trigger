trigger TimeSheetEntryTrigger on TimesheetEntry ( before insert, after insert, before update, after update, before delete, after delete  ) {
    (new TriggerFrameWork()).handle();
}