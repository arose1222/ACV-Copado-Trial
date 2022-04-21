public class RemoveVLFromPrescreenController {
    
    @AuraEnabled
    public static Boolean removeVLFromVin(String PerscreenId){
        List<Condition_Report_Prescreen__c> crp = [select id, VIN__c, Status__c,CR_Update_by_pre_Screener__c from Condition_Report_Prescreen__c where id = :PerscreenId];
        if(crp.size() > 0){
            VirtualLiftAPIHelper api = new VirtualLiftAPIHelper();
            Boolean apiResult = api.deactivateVLImagesByVin(crp[0].VIN__c);
            if(apiResult){
                crp[0].CR_Update_by_pre_Screener__c = 'Yes';
                insert new CR_Question__c(Condition_Report_Prescreen__c = crp[0].id, Question_Type__c = 'Virtual Lift Image Issue (Image Removed)');
                update crp;
                return true;
            }
            else{
                return false;
            }
        }
        else{
            return false;
        }
    }
}