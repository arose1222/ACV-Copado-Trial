global class RevolvingBatchSchedulable extends SchedulingInterface {

    // RevolvingBatchSchedulable revolvingBatchSchedule = new RevolvingBatchSchedulable ();
    // String CRON = '0 0 4 * * ?';
    // System.schedule('Revolving Appointment Batch', CRON, revolvingBatchSchedule);

    public override void executeScheduledLogic() {
        Data_Schedule__c dataSchedule = [SELECT Clean_Up_Batch_Size__c, Generation_Batch_Size__c FROM Data_Schedule__c WHERE Active__c = TRUE LIMIT 1];
        RevolvingCleanUpBatch batch = new RevolvingCleanUpBatch(true, dataSchedule.Generation_Batch_Size__c.intValue(), false);
        Id batchId = Database.executeBatch(batch, dataSchedule.Clean_Up_Batch_Size__c.intValue());
    }
}