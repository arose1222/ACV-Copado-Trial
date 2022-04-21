public class PreventSTMWithoutOperatingHours extends TriggerInterface {
    @TestVisible private static final String DONT_ALLOW_EMPTY_HOURS = 'You cannot have a Service Territory Member without Operating Hours assigned';

    public override void beforeUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap ) {
        for ( ServiceTerritoryMember stm : (List<ServiceTerritoryMember>) newMap.values() ) {
            ServiceTerritoryMember oldSTM = (ServiceTerritoryMember) oldMap.get( stm.Id );
            if ( stm.OperatingHoursId != oldSTM.OperatingHoursId && stm.OperatingHoursId == null ) {
                stm.addError( DONT_ALLOW_EMPTY_HOURS );
            } 
        }
    }

    public override void beforeInsert( List<SObject> newLst ) {
        for ( ServiceTerritoryMember stm : (List<ServiceTerritoryMember>) newLst ) {
            if ( stm.OperatingHoursId == null ) {
                stm.addError( DONT_ALLOW_EMPTY_HOURS );
            } 
        }
    }
}