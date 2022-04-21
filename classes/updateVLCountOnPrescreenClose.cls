public class updateVLCountOnPrescreenClose extends TriggerInterface{

    public static boolean alreadyRan = false;   
    
    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        if(alreadyRan){return;}
        Map<Id,Condition_Report_Prescreen__c> newPrescreenMap = (Map<Id,Condition_Report_Prescreen__c>)newMap;
        Map<Id,Condition_Report_Prescreen__c> oldPrescreenMap = (Map<Id,Condition_Report_Prescreen__c>)oldMap;
        Map<Id,Contact> contactUpdate = new Map<Id,Contact>();
        List<Id> closedPrescreenList = new List<Id>();

        for(Condition_Report_Prescreen__c crp :newPrescreenMap.values()){
            if(crp.Closed_Date__c != null && crp.Closed_Date__c != oldPrescreenMap.get(crp.id).Closed_Date__c){
                closedPrescreenList.add(crp.Id);
            }
        }
        for(Condition_Report_Prescreen__c crp :[Select id, CR_Review_Timeout__c, VCI__r.Successful_Virtual_Lift_Prescreens__c, VCI__c, (Select Id From CR_Questions__r where Question_Type__c = 'Virtual Lift Image Issue (Image Removed)') ,(Select ID from Prescreen_Reasons__r where name like '%Virtual Lift%') from Condition_Report_Prescreen__c where id in :closedPrescreenList]){
            if(crp.Prescreen_Reasons__r.size() > 0 && (crp.VCI__r.Successful_Virtual_Lift_Prescreens__c < 10 || crp.VCI__r.Successful_Virtual_Lift_Prescreens__c == null)&& crp.CR_Questions__r.size() == 0 && !crp.CR_Review_Timeout__c){
                if(contactUpdate.get(crp.VCI__c) != null){
                    contactUpdate.get(crp.VCI__c).Successful_Virtual_Lift_Prescreens__c = contactUpdate.get(crp.VCI__c).Successful_Virtual_Lift_Prescreens__c+1;
                }
                else{
                   contactUpdate.put(crp.VCI__c, New Contact(Id = crp.VCI__c, Successful_Virtual_Lift_Prescreens__c = crp.VCI__r.Successful_Virtual_Lift_Prescreens__c != null ? crp.VCI__r.Successful_Virtual_Lift_Prescreens__c+1 : 1));
                }
                
            }
        }
        if(contactUpdate.size() > 0){
            alreadyRan = true;
            update contactUpdate.values();
        }
        
    }
}