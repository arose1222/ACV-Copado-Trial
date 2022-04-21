global class OfferSlotObject implements Comparable {
    public Decimal grade;
    public DateTime startTime;
    public DateTime endTime;

    global OfferSlotObject( Decimal grade, DateTime start, DateTime finish ) {
        this.grade = grade;
        this.startTime = start;
        this.endTime = finish;
    }

    public Integer compareTo( Object compareTo ) {
        OfferSlotObject compareToSlot = (OfferSlotObject) compareTo;
        if ( grade == compareToSlot.grade ) { return 0; }
        if ( grade > compareToSlot.grade ) { return -1; }
        return 1;
    }
}