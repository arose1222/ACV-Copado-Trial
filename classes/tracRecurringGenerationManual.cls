/**
 * @description class to allow admins to invoke the batch via the active Data_Schedule__c record
 * @name tracRecurringGenerationManual
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-09-28
 */

public with sharing class tracRecurringGenerationManual {
    public static Boolean overrideDataSchedule = false;

    public static void runBatch(Integer batchSize) {
        overrideDataSchedule = true;

        tracRecurringGenerationBatch batch = new tracRecurringGenerationBatch();
        Database.executeBatch(batch, batchSize);
    }
}