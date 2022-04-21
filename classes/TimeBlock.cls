public class TimeBlock implements Comparable {
    public Id timesheetEntryId;
    public DateTime startTime;
    public DateTime endTime;

    public TimeBlock( TimeSheetEntry providedTSE ) {
        this.timesheetEntryId = providedTSE.Id;
        this.startTime = providedTSE.StartTime;
        this.endTime = providedTSE.EndTime;
    }

    public Integer compareTo( Object compareTo ) {
        TimeBlock compareToBlock = (TimeBlock) compareTo;
        if ( this.startTime == compareToBlock.startTime && this.endTime == compareToBlock.endTime) { return 0; }
        if ( this.startTime > compareToBlock.startTime ) { return 1; }
        return -1;
    }
}