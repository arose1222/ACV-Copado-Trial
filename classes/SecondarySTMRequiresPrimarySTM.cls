public class SecondarySTMRequiresPrimarySTM extends TriggerInterface {
    @TestVisible private static final String SECONDARY_STM = 'S';
    private static final String PRIMARY_STM = 'P';
    @TestVisible private static final String DONT_ALLOW_SECONDARY_WITHOUT_PRIMARY = 'You cannot have a Secondary Service Territory Member without a Primary Service Territory Member';

    public override void beforeUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap ) {
        Map<Id, Set<Id>> secondarySTMCheckMap = new Map<Id, Set<Id>>();
        for ( ServiceTerritoryMember stm : (List<ServiceTerritoryMember>) newMap.values() ) {
            ServiceTerritoryMember oldSTM = (ServiceTerritoryMember) oldMap.get( stm.Id );
            if ( stm.TerritoryType != oldSTM.TerritoryType && stm.TerritoryType == SECONDARY_STM ) {
                if ( secondarySTMCheckMap.get( stm.ServiceResourceId ) == null ) {
                    secondarySTMCheckMap.put( stm.ServiceResourceId, new Set<Id>() );
                }
                secondarySTMCheckMap.get( stm.ServiceResourceId ).add( stm.Id );
            } 
        }

        if ( !secondarySTMCheckMap.isEmpty() ) {            
            checkForPrimarySTM( secondarySTMCheckMap, newMap );
        }
    }

    public override void afterInsert( Map<Id, SObject> newMap ) {
        Map<Id, Set<Id>> secondarySTMCheckMap = new Map<Id, Set<Id>>();
        for ( ServiceTerritoryMember stm : (List<ServiceTerritoryMember>) newMap.values() ) {
            if ( stm.TerritoryType == SECONDARY_STM ) {
                if ( secondarySTMCheckMap.get( stm.ServiceResourceId ) == null ) {
                    secondarySTMCheckMap.put( stm.ServiceResourceId, new Set<Id>() );
                }
                secondarySTMCheckMap.get( stm.ServiceResourceId ).add( stm.Id );
            } 
        }
        
        if ( !secondarySTMCheckMap.isEmpty() ) {
            checkForPrimarySTM( secondarySTMCheckMap, newMap );
        }
    }

    public static void checkForPrimarySTM( Map<Id, Set<Id>> serviceResourceIdMap, Map<Id, SObject> objectMapForErrors ) {
        for ( ServiceTerritoryMember primarySTM : [ SELECT ServiceResourceId FROM ServiceTerritoryMember 
                                                WHERE EffectiveStartDate <= :DateTime.now() 
                                                AND ( EffectiveEndDate > :DateTime.now() OR EffectiveEndDate = null ) 
                                                AND TerritoryType = :PRIMARY_STM
                                                AND ServiceResourceId IN :serviceResourceIdMap.keyset()
                                                AND Id NOT IN :objectMapForErrors.keySet() ] ) {
            serviceResourceIdMap.remove( primarySTM.ServiceResourceId ); // If found, no error needed
        }

        if ( !serviceResourceIdMap.isEmpty() ) {
            for ( Id serviceResourceId : serviceResourceIdMap.keyset() ) {
                for ( Id secondarySTMId : serviceResourceIdMap.get( serviceResourceId ) ) {
                    objectMapForErrors.get( secondarySTMId ).addError( DONT_ALLOW_SECONDARY_WITHOUT_PRIMARY );
                }
            }
        }
    }
}