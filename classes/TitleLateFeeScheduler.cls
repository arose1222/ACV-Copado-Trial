/**
 * @description Apex Scheduler class to schedule the batch process to update late fee on Account and create a new Assigned Fee record.
 * 				Requirements: https://acvauctions.atlassian.net/browse/TDO-22
 * 
 * @author Manmeet Vaseer
 * @date 08/02/2021
 * 
 */
global class TitleLateFeeScheduler extends SchedulingInterface{
    public override void executeScheduledLogic() {
        TitleLateFeeBatch acBatch = new TitleLateFeeBatch();
        Database.executebatch(acBatch);
    }       
}