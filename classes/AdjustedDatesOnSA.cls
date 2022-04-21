/**
 * Logic to clear out Arrival & Scheduled Windows if the Earliest Start Time is adjusted or certain statuses are hit
 *
 * @group FSL
 */
public class AdjustedDatesOnSA extends TriggerInterface {
    
    /**
     * If an Earliest Start Time is adjusted, check to see if it disrupts existing Arrival Windows or Scheduled Start Time, if so, clear those values out.
     * Always clear the values of records in the Incomplete or Canceled Status Categories
     * @param oldMap Trigger old map context of Service Appointment Records
     * @param newMap Trigger new map context of Service Appointment Records
     */
    /*public override void beforeUpdate ( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        for ( ServiceAppointment sa : (List<ServiceAppointment>) newMap.values() ) {
            ServiceAppointment oldSA = (ServiceAppointment) oldMap.get( sa.Id );

            Boolean changeStartWindow = sa.EarliestStartTime != oldSA.EarliestStartTime;

            if ( changeStartWindow && sa.SchedStartTime == oldSA.SchedStartTime ) { // If we're already changing the Schedule Start, don't disrupt that process
                sa.SchedStartTime = null;
                sa.SchedEndTime = null;
            }

            if ( ( changeStartWindow && ( sa.ArrivalWindowStartTime == oldSA.ArrivalWindowStartTime ) )  
                || sa.StatusCategory == FSLWorkProcessUtility.SA_INCOMPELTE_CATEGORY ||  sa.StatusCategory == FSLWorkProcessUtility.SA_CANCEL_CATEGORY ) {
                    sa.ArrivalWindowStartTime = null;
                    sa.ArrivalWindowEndTime = null;
            }
        }
    }*/
}