global class AutoCloseDealmakerOpportunitiesScheduler extends SchedulingInterface{
    public override void executeScheduledLogic() {
        AutoCloseDealmakerOpportunitiesBatch acdob = new AutoCloseDealmakerOpportunitiesBatch();
        //hard coded scope size of 200, this shouldn't be a problem since we are doing single field updates based on the close date of the opportunity
        database.executeBatch(acdob,200);
    }
}