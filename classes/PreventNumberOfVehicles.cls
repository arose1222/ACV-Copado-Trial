public class PreventNumberOfVehicles extends TriggerInterface {

    @TestVisible private static final String DOES_NOT_RESPECT_VEHICLE_COUNT_ERR = 'This Type of Work does not respect the Number of Vehicles field, please remove the value from the Number of Vehicles field';

    public override void beforeInsert( List<SObject> newLst ) {
        for ( WorkOrder woCheck : (List<WorkOrder>) newLst ) {
            if ( woCheck.Inspection_Number_of_Vehicles__c != null && woCheck.Inspection_Number_of_Vehicles__c != 0 && !FSLWorkProcessUtility.workTypeIdMap.get( woCheck.WorkTypeId ).Respects_Number_of_Vehicles__c ) {
                woCheck.addError( DOES_NOT_RESPECT_VEHICLE_COUNT_ERR );
            }
        }
    }
}