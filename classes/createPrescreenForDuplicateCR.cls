public class createPrescreenForDuplicateCR extends ClassInterface{
    
    public override List<SObject> handle(List<SObject> objList){
        return (List<SObject>)getCRsThatHaveSiblings((List<Condition_Report__c>)objList);
    }

    public List<Condition_Report__c> getCRsThatHaveSiblings(List<Condition_Report__c> crList){
        Map<Id, Condition_Report__c> vinIdtoCrMap = new Map<Id,Condition_Report__c>();
        List<Condition_Report__c> returnList = new List<Condition_Report__c>();
        List<Id> crIdList = new List<Id>();
        for(Condition_Report__c cr :crList){
                vinIdtoCrMap.put(cr.vehicle__c,cr);
                crIdList.add(cr.id);
        }
        if(vinIdtoCrMap.keySet().size() > 0){
            Map<Id,Condition_Report__c> crMap = new Map<Id,Condition_Report__c>(crList);
            //Filter Sub Query on CR Prescreen to not look at CR Ids in the CR List that we get passed
            for(vehicle__c v :[select id, (Select Id from Condition_Reports__r where Floor_Price__c > 0 AND createddate != TODAY AND ID NOT IN :crMap.keySet()), (select id from Condition_Report_Prescreen__r where Condition_Report__c IN :crIdList) from Vehicle__c where ID in :vinIdtoCrMap.keySet()]){
                if(v.Condition_Reports__r.size() > 0 && v.Condition_Report_Prescreen__r.size() == 0){
                    returnList.add(vinIdtoCrMap.get(v.id));
                }
            }
        }
        return returnList;
    }
}