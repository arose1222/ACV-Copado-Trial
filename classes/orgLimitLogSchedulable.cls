global class orgLimitLogSchedulable extends SchedulingInterface implements Database.AllowsCallouts{
    public override void executeScheduledLogic() {
        LimitLog.logOrgLimits();
    }
}