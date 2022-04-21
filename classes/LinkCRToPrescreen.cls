public class LinkCRToPrescreen extends TriggerInterface{
    
    public override void afterInsert(Map<Id, SObject> newMap){
        Map<Id, Condition_Report__c> tempCrMap = (Map<Id, Condition_Report__c>)newMap;
        Map<String, Condition_Report__c> newCrMap = new Map<String, Condition_Report__c>();

        for(Condition_Report__c cr :tempCrMap.values()){
            if(!String.isBlank(cr.Inspection_Guid__c)){
                newCrMap.put(cr.Inspection_Guid__c, cr);
            }
        }

        List<Condition_Report_Prescreen__c> prescreenUpdateList = new List<Condition_Report_Prescreen__c>();

        for(Condition_Report_Prescreen__c crp :[SELECT ID, Vehicle__c, Condition_Report__c,Inspection_Id__c FROM Condition_Report_Prescreen__c WHERE Inspection_Id__c IN :newCrMap.keySet()]){
            if(newCrMap.get(crp.Inspection_Id__c) != null){
                if(!String.isBlank(newCrMap.get(crp.Inspection_Id__c).Vehicle__c)){
                    crp.Vehicle__c = newCrMap.get(crp.Inspection_Id__c).Vehicle__c;
                }
                
                crp.Condition_Report__c = newCrMap.get(crp.Inspection_Id__c).Id;
                prescreenUpdateList.add(crp);
            }
        }

        if(prescreenUpdateList.size() > 0){
            update prescreenUpdateList;
        }
    }
}