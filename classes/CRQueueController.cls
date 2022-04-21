public class CRQueueController {
    /**
     * getPrescreens Only meant to get the Prescreens where the owner is the 'CR Queue'
     * @return   return List<Condition_Report_Prescreen__c>
     */
    @AuraEnabled(cacheable = false)
    public static List<Condition_Report_Prescreen__c> getPrescreens(){
        return [Select Id, Name, Vehicle__r.VIN__c, Vehicle__c, Vehicle__r.Year__c,Link_To_CR__c, Age_in_Minutes__c, VIN__c, vci__r.Name, (Select Id, Name from Prescreen_Reasons__r) from Condition_Report_Prescreen__c where Status__c = 'New'];
    }

    
    /**
     * getCRReasons get all review trigger metadata records and get the prescreen reasons from them
     * @return   retruns a set of picklists to ensure we have single of each value
     */
    @AuraEnabled
    public static String getCRReasons(){
        Set<LWCUtility.picklist> reasonList = new Set<LWCUtility.picklist>();
        Set<String> reasonStringSet = new Set<String>();
        //List<CR_Review_Trigger__mdt> ruleList = [select id, Prescreen_Reason__c from CR_Review_Trigger__mdt];
        for(CR_Review_Trigger__mdt rule :[select id, Prescreen_Reason__c from CR_Review_Trigger__mdt where Active__c = True]){
            if(!String.isBlank(rule.Prescreen_Reason__c)){
                reasonStringSet.add(rule.Prescreen_Reason__c);
            }
        }
        for(String s :reasonStringSet){
            reasonList.add(new LWCUtility.picklist(s,s));
        }

        return JSON.serialize(reasonList);
        //return new List<LWCUtility.picklist>(reasonList);
    }
}