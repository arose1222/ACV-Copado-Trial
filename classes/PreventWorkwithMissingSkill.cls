public with sharing class PreventWorkwithMissingSkill extends TriggerInterface {
    @TestVisible private final static String INVALID_RESOURCE_CONFIG_ERROR = 'A Resource cannot be assigned to a Job without the required Skill. Please check their skills and open an R&I for assistance if needed';

    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {
        Map<Id, Id> srArIdMap = new Map<Id, Id>();
        for ( AssignedResource arRec : (List<AssignedResource>) newMap.values() ) {
            AssignedResource oldRec = (AssignedResource) oldMap.get( arRec.Id );
            if ( arRec.ServiceResourceId != oldRec.ServiceResourceId && arRec.ServiceResourceId != null ) {
                srArIdMap.put( arRec.ServiceResourceId, arRec.Id );
            }
        }

        if ( !srArIdMap.isEmpty() ) {
            checkResourceForSkill( srArIdMap, newMap );
        }
    }

    public override void afterInsert( Map<Id, SObject> newMap ) {
        Map<Id, Id> srArIdMap = new Map<Id, Id>();
        for ( AssignedResource arRec : (List<AssignedResource>) newMap.values() ) {
            srArIdMap.put( arRec.ServiceResourceId, arRec.Id );
        }

        if ( !srArIdMap.isEmpty() ) {
            checkResourceForSkill( srArIdMap, newMap );
        }
    }  

    public static void checkResourceForSkill( Map<Id, Id> resourceToARMap, Map<Id, SObject> newARmap ) {
        List<AssignedResource> queryResourceApptLst = [ SELECT Id, ServiceAppointmentId, ServiceAppointment.WorkTypeId, ServiceResourceId 
                                                        FROM AssignedResource WHERE Id IN :new Set<Id>( resourceToARMap.values() )
                                                        AND ServiceAppointment.WorkTypeId != null ];
        
        Set<Id> workTypeSet = new Set<Id>();
        for ( AssignedResource arRec : queryResourceApptLst ) {
            workTypeSet.add( arRec.ServiceAppointment.WorkTypeId );
        }

        // Work Type Id to all Required Skills
        Map<Id, Set<Id>> workTypeIdToSkillMap = FSLWorkProcessUtility.getSkillRequirementsByWorkTypeId( workTypeSet );

        // Resource Id to all currently 'active' Skills
        // Note: Skill Level implementation will complicate this and need adjustment in the future
        Map<Id, Set<Id>> resourceToSkillMap = new Map<Id, Set<Id>>();
        for ( ServiceResourceSkill srs : [ SELECT Id, SkillId, ServiceResourceId FROM ServiceResourceSkill 
                                            WHERE ServiceResourceId IN :resourceToARMap.keySet() AND ( EffectiveEndDate = null OR ( EffectiveEndDate != null AND EffectiveEndDate >= TODAY ) ) ] ) 
        {
            if ( resourceToSkillMap.get( srs.ServiceResourceId ) == null ) {
                resourceToSkillMap.put( srs.ServiceResourceId, new Set<Id>() );
            }
            resourceToSkillMap.get( srs.ServiceResourceId ).add( srs.SkillId );
        }

        for ( AssignedResource arDetailRec : queryResourceApptLst ) {
            Set<Id> workTypeSkillCheckSet = workTypeIdToSkillMap.get( arDetailRec.ServiceAppointment.WorkTypeId );
            Set<Id> resourceSkillSet = resourceToSkillMap.get( arDetailRec.ServiceResourceId );
            if ( workTypeSkillCheckSet != null && resourceSkillSet != null ) {
                workTypeSkillCheckSet.removeAll( resourceSkillSet );
                if ( !workTypeSkillCheckSet.isEmpty() ) {
                    newARmap.get( arDetailRec.Id ).addError( INVALID_RESOURCE_CONFIG_ERROR );
                }
            } else if ( workTypeSkillCheckSet != null && !workTypeSkillCheckSet.isEmpty() && resourceSkillSet == null ) {
                newARmap.get( arDetailRec.Id ).addError( INVALID_RESOURCE_CONFIG_ERROR );
            }
        }
    }
}