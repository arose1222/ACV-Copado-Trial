public class PreventCannotCompleteWorkEarly extends TriggerInterface {

    @TestVisible private static final String CANNOT_COMPLETE_ERROR = 'You cannot put a Service Appointment in the status of \'Cannot Complete\' when it has not been scheduled yet. Please use the \'Canceled\' Status instead.';

    public override void beforeUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {
        Set<Id> saIdSet = new Set<Id>();
        for ( ServiceAppointment sa : (List<ServiceAppointment>) newMap.values() ) {
            ServiceAppointment oldSA = (ServiceAppointment) oldMap.get( sa.Id );
            if ( sa.Status != oldSA.Status && sa.Status == 'Cannot Complete' ) {
                saIdSet.add( sa.Id );
            }
        }

        if ( !saIdSet.isEmpty() ) {
            for ( AssignedResource ar : [ SELECT Id, ServiceAppointmentId FROM AssignedResource WHERE ServiceAppointmentId IN :saIdSet ] ) {
                saIdSet.remove( ar.ServiceAppointmentId );
            }

            for ( Id saId : saIdSet ) {
                newMap.get( saId ).addError( CANNOT_COMPLETE_ERROR );
            }
        }
    }
}