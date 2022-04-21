public class PreventASISkillsWithoutId extends TriggerInterface {
    private static final Map<Id, Set<Id>> CHECK_ASI_SKILL_MAP = FSLWorkProcessUtility.getSkillRequirementsBySkillId( FSLWorkProcessUtility.getWorkTypeIdByGroupName( new Set<String>{ 'asi' } ) );
    @TestVisible private static final String ASI_SKILL_WITHOUT_ID_ERROR = 'You cannot add this skill to a Service Resource if they don\'t have an ASI Id on their Service Resource record';
    
    public override void afterInsert(Map<Id, SObject> newMap ) {
        List<SObject> newLst = newMap.values();

        Map<Id, Set<Id>> serviceResourceIdMap = new Map<Id, Set<Id>>();
        for ( ServiceResourceSkill srs : (List<ServiceResourceSkill>) newLst ) {
            if ( CHECK_ASI_SKILL_MAP != null && CHECK_ASI_SKILL_MAP.get( srs.SkillId ) != null && !CHECK_ASI_SKILL_MAP.get( srs.SkillId ).isEmpty() ) { 
                // This is an ASI Skill and it is tied as a requirement to a WorkType
                if ( serviceResourceIdMap.get( srs.ServiceResourceId ) == null ) {
                    serviceResourceIdMap.put( srs.ServiceResourceId, new Set<Id>() );
                }
                serviceResourceIdMap.get( srs.ServiceResourceId ).add( srs.Id );
            }
        }

        if ( !serviceResourceIdMap.isEmpty() ) {
            for ( ServiceResource sr : [ SELECT Id FROM ServiceResource WHERE Id IN :serviceResourceIdMap.keySet() AND ASI_Resource_Id__c = null ] ) {
                for ( Id skillResourceId : serviceResourceIdMap.get( sr.Id ) ) {
                    newMap.get( skillResourceId ).addError( ASI_SKILL_WITHOUT_ID_ERROR );
                }
            }
        }
    }
}