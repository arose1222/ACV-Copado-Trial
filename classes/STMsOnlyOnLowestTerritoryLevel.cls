public class STMsOnlyOnLowestTerritoryLevel extends TriggerInterface {
    @TestVisible private static final String DONT_ALLOW_STM_ABOVE_LOWEST_LEVEL = 'You cannot have create a Service Territory Member outside of the lowest level of Service Territories in the system';

    // public override void beforeUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap ) {
    //     Map<Id, Set<Id>> stmCheckMap = new Map<Id, Set<Id>>();
    //     for ( ServiceTerritoryMember stm : (List<ServiceTerritoryMember>) newMap.values() ) {
    //         ServiceTerritoryMember oldSTM = (ServiceTerritoryMember) oldMap.get( stm.Id );
    //         if ( stm.ServiceTerritoryId != oldSTM.ServiceTerritoryId && stm.ServiceTerritoryId != null ) {
    //             if ( stmCheckMap.get( stm.ServiceTerritoryId ) == null ) {
    //                 stmCheckMap.put( stm.ServiceTerritoryId, new Set<Id>() );
    //             }
    //             stmCheckMap.get( stm.ServiceTerritoryId ).add( stm.Id );
    //         } 
    //     }
    //     if ( !stmCheckMap.isEmpty() ) {            
    //         checkForPrimarySTM( stmCheckMap, newMap );
    //     }
    // }

    public override void afterInsert( Map<Id, SObject> newMap ) {
        Map<Id, Set<Id>> stmCheckMap = new Map<Id, Set<Id>>();
        for ( ServiceTerritoryMember stm : (List<ServiceTerritoryMember>) newMap.values() ) {
            if ( stm.ServiceTerritoryId != null ) {
                if ( stmCheckMap.get( stm.ServiceTerritoryId ) == null ) {
                    stmCheckMap.put( stm.ServiceTerritoryId, new Set<Id>() );
                }
                stmCheckMap.get( stm.ServiceTerritoryId ).add( stm.Id );
            } 
        }
        
        if ( !stmCheckMap.isEmpty() ) {
            checkForPrimarySTM( stmCheckMap, newMap );
        }
    }

    public static void checkForPrimarySTM( Map<Id, Set<Id>> serviceTerritoryIdMap, Map<Id, SObject> objectMapForErrors ) {
        final Integer LOWEST_LEVEL = FSLWorkProcessUtility.LOWEST_TERRITORY_LEVEL;
        if ( LOWEST_LEVEL != null && LOWEST_LEVEL != 0 ) {
            for ( ServiceTerritory stCheckRec : [ SELECT Id FROM ServiceTerritory 
                                                    WHERE Id IN :serviceTerritoryIdMap.keySet()
                                                    AND FSL__TerritoryLevel__c = :LOWEST_LEVEL ] ) {
                serviceTerritoryIdMap.remove( stCheckRec.Id ); // If found, no error needed
            }

            if ( !serviceTerritoryIdMap.isEmpty() ) {
                for ( Id stId : serviceTerritoryIdMap.keyset() ) {
                    for ( Id stmId : serviceTerritoryIdMap.get( stId ) ) {
                        objectMapForErrors.get( stmId ).addError( DONT_ALLOW_STM_ABOVE_LOWEST_LEVEL );
                    }
                }
            }
        }
    }
}