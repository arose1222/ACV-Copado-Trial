public class StampOriginalDueDate extends TriggerInterface {

    public override void beforeInsert( List<SObject> newList ) {
        for ( ServiceAppointment saRec: (List<ServiceAppointment>) newList ) {
            saRec.Original_Due_Date__c = saRec.DueDate;
        }
    }
}