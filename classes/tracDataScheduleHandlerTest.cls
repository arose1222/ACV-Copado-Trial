/**
 * @description ${DESCRIPTION}
 * @name tracDataScheduleHandlerTest
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-09-05
 */

@IsTest
private class tracDataScheduleHandlerTest {
    @IsTest
    static void testBehavior() {
        Data_Schedule__c ds = new Data_Schedule__c();
        ds.Frequency__c = 'Monthly';
        ds.Day__c = '5';
        ds.Active__c = true;
        ds.Batch_Size__c = 50;
        insert ds;
    }

    @IsTest
    static void testUpdate() {
        insert new List<WorkType>{
                new WorkType(Name = tracConstants.WORKTYPE_DEALER_STANDARD_INSPECTION,EstimatedDuration = 60)
        };

        Data_Schedule__c ds = new Data_Schedule__c();
        ds.Frequency__c = 'Monthly';
        ds.Day__c = '5';
        ds.Active__c = true;
        ds.Batch_Size__c = 50;
        insert ds;

        ds.Active__c = true;
        ds.Run_Batch__c = true;
        update ds;

        Data_Schedule__c updatedDataSchedule = [SELECT Run_Batch__c FROM Data_Schedule__c WHERE Id = :ds.Id];
        System.assert(updatedDataSchedule.Run_Batch__c, 'Deprecated Flag was reset');
    }

    @IsTest
    static void testUndelete() {
        Data_Schedule__c ds = new Data_Schedule__c();
        ds.Frequency__c = tracConstants.DATA_FREQUENCY_DAILY;
        ds.Active__c = true;
        ds.Batch_Size__c = 50;
        insert ds;

        delete ds;

        undelete ds;
        Data_Schedule__c updatedDataSchedule = [SELECT Id, Active__c FROM Data_Schedule__c WHERE Id = :ds.Id];
        System.assert(!updatedDataSchedule.Active__c);
    }
}