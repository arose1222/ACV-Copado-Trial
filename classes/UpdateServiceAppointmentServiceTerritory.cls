public class UpdateServiceAppointmentServiceTerritory extends TriggerInterface {
    
    public override void beforeUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap ) {
        Set<FSLWorkProcessUtility.WorkGeoDataStruct> processIdSet = new Set<FSLWorkProcessUtility.WorkGeoDataStruct>();

        for ( ServiceAppointment saRec: (List<ServiceAppointment>) newMap.values() ) {
            ServiceAppointment oldSaRec = (ServiceAppointment) oldMap.get( saRec.Id );   
            if ( ( oldSaRec.longitude != saRec.longitude ||
                oldSaRec.latitude != saRec.latitude ) &&
                saRec.latitude != null && saRec.longitude != null ) {
                    processIdSet.add( new FSLWorkProcessUtility.WorkGeoDataStruct( saRec.Id, saRec.longitude, saRec.latitude ) );
            }
        }

        if ( !processIdSet?.isEmpty() ) {
            Map<Id, Id> returnMap = FSLWorkProcessUtility.getServiceTerritories( processIdSet );
            for ( Id saId : returnMap.keySet() ) {
                if ( returnMap.get( saId ) != null ) {
                    ServiceAppointment saRec = (ServiceAppointment) newMap.get( saId );         
                    saRec.ServiceTerritoryId = returnMap.get( saId );
                }
            }
        }
    }
}