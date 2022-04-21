/**
 * Created by zdeng on 9/25/2019.
 */

global with sharing class tracRecurringGenerationSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        Data_Schedule__c schedule = [
                SELECT Batch_Size__c
                FROM Data_Schedule__c
                WHERE Active__c = TRUE
                LIMIT 1];
        tracRecurringGenerationBatch batch = new tracRecurringGenerationBatch();
        Id batchId = Database.executeBatch(batch,Integer.valueOf(schedule.Batch_Size__c));
    }
}