public class UpdateWorkOrderServiceTerritory extends TriggerInterface {
    
    public override void beforeUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap ) {
        Set<FSLWorkProcessUtility.WorkGeoDataStruct> processIdSet = new Set<FSLWorkProcessUtility.WorkGeoDataStruct>();

        for ( WorkOrder woRec: (List<WorkOrder>) newMap.values() ) {
            WorkOrder oldWoRec = (WorkOrder) oldMap.get( woRec.Id );   
            if ( ( oldWoRec.longitude != woRec.longitude ||
                oldWoRec.latitude != woRec.latitude) &&
                woRec.latitude != null && woRec.longitude != null ) {
                    processIdSet.add( new FSLWorkProcessUtility.WorkGeoDataStruct( woRec.Id, woRec.longitude, woRec.latitude ) );
            }
        }

        if ( !processIdSet?.isEmpty() ) {
            Map<Id, Id> returnMap = FSLWorkProcessUtility.getServiceTerritories( processIdSet );
            for ( Id woId : returnMap.keySet() ) {
                if ( returnMap.get( woId ) != null ) {
                    WorkOrder woRec = (WorkOrder) newMap.get( woId );         
                    woRec.ServiceTerritoryId = returnMap.get( woId );
                }
            }
        }
    }
}