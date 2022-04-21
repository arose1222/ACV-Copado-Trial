public class CreateWorkTypeSkillRequirement extends TriggerInterface {
    public override void afterInsert( List<SObject> newList ) {
		Set<Id> workTypeIdSet = new Set<Id>();
        Map<Id, Id> woToWorkTypeMap = new Map<Id, Id>();
        for ( WorkOrder wo : (List<WorkOrder>) newList ) {
            if ( wo.Promotional_Work_Type__c != null ) {
                workTypeIdSet.add( wo.Promotional_Work_Type__c );
                woToWorkTypeMap.put( wo.Id, wo.Promotional_Work_Type__c );
            }
        }
        
        if ( !workTypeIdSet.isEmpty() ) {
			Map<Id, Set<Id>> workTypeToSkillMap = FSLWorkProcessUtility.getSkillRequirementsByWorkTypeId( workTypeIdSet );
            List<SkillRequirement> newSkillReqLst = new List<SkillRequirement>();
            for ( Id woId : woToWorkTypeMap.keyset() ) {
                Id workTypeId = woToWorkTypeMap.get( woId );
                for ( Id skillId : workTypeToSkillMap.get( workTypeId ) ) {
                    newSkillReqLst.add( new SkilLRequirement(
                    	RelatedRecordId = woId,
                        SkillId = skillId
                    ) );
                }
            }

            if ( !newSkillReqLst.isEmpty() ) { insert newSkillReqLst; }
        }
    }
}