public class VciPrescreenCheck extends ClassInterface{
    


    public override Map<String, PrescreenServiceHelper.InspectionWrapper> handle(Map<String, PrescreenServiceHelper.InspectionWrapper> wrapperMap, CR_Review_Trigger__mdt crt){
        Set<String> vciIdSet = new Set<String>();
        //throw and catch for any missing data in this method
        for(PrescreenServiceHelper.InspectionWrapper wrapper : wrapperMap.values()){
            vciIdSet.add(wrapper.idef.inspectorIdentityId);
        }
    
        //throw the list of contacts into a set of ids
        Set<String> crReviewIds = new Set<String>();

        for(Contact c : [SELECT Id, Identity_Id__c FROM Contact WHERE Identity_Id__c in : vciIdSet AND CR_Review__c = true]){
            crReviewIds.add(c?.Identity_Id__c);
        }
        crReviewIds.remove(null);
        
        //if the vci on an inspection is in the list of prescreen vcis, add that reason
        for(PrescreenServiceHelper.InspectionWrapper wrapper : wrapperMap.values()){
            if(crReviewIds.contains(wrapper.idef.inspectorIdentityId)){
                wrapper.prescreenReasons.add(crt.Prescreen_Reason__c);
                wrapper.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper(crt.Prescreen_Reason__c, crt.Is_Aux_Reason__c));
            }
        }

        return wrapperMap;
    }
}