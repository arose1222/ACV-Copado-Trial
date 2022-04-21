public class CaseCRReviewProcesses {
    private static boolean beforeInsertProcessed = false;
    private static boolean afterInsertProcessed = false;
    private static boolean beforeUpdateProcessed = false;
    private static boolean afterUpdateProcessed = false;

    // public static void beforeInsert(List<Case> newCaseList){
    //     if(beforeInsertProcessed == false){
    //         List<Case> filteredList = filter(newCaseList);

    //         if(filteredList.size() > 0){
    //             beforeInsertProcessed = true;
    //         }
    //     } else{
    //         System.debug('Recursion on Before Insert on CR Review Cases blocked. Use CaseCRReviewProcesses.beforeInsertToggle() to step in.');
    //     }        
    // }

    // public static void afterInsert(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
    //     if(afterInsertProcessed == false){
    //         afterInsertProcessed = true;
    //     } else{
    //         System.debug('Recursion on After Insert on CR Review Cases blocked. Use CaseCRReviewProcesses.afterInsertToggle() to step in.');
    //     }
    // }

    public static void beforeUpdate(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
        if(beforeUpdateProcessed == false){
            Map<Id,Case> filteredMap = filter((Map<Id,Case>) newCaseMap);
            if(filteredMap.size() > 0){
                beforeUpdateProcessed = true;
                dateTimeStamp(filteredMap, (Map<Id,Case>)oldcasemap);
                System.debug('Before Update processes for CR Review Cases executed');
            }
        } else{
            System.debug('Recursion on Before Update on CR Review Cases blocked. Use CaseCRReviewProcesses.beforeUpdateToggle() to step in.');
        }
    }

    // public static void afterUpdate(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
    //     if(afterUpdateProcessed == false){
    //         Map<Id,Case> filteredMap = filter((Map<Id,Case>) newCaseMap);
    //         if(filteredMap.size() > 0){
    //             afterUpdateProcessed = true;
    //             System.debug('After Update processes for CR Review Cases executed');
    //         }
    //     } else{
    //         System.debug('Recursion on Before Update on CR Review blocked. Use CaseCRReviewProcesses.afterUpdateToggle() to step in.');
    //     }
    // }
    /**
     * dateTimeStamp 
     * process name: Date/Time Stamp on Case Reviews
     *   GIVEN A CR Review
     *   AND Status is 'Under Review'
     *   WHEN Status is changed 
     *   THEN update 'Date_Time_Case_Status_Under_Review__c' with current time
     * 
     *   Repeat for 'Reviewed' and 'Denial Pending'
     *
     *
     * @param  newCaseMap - new values, key is id of case and value is Case object with that id 
     * @param  oldcasemap - old values, key is id of case and value is Case object with that id 
     */
    public static void dateTimeStamp( Map<Id, Case> newCaseMap, Map<Id, Case> oldcasemap){
        for(Id caseId :newCaseMap.keySet()){ 
            if( newCaseMap.get(caseID).status != null && newCaseMap.get(caseID).Status != oldCaseMap.get(caseID).status){
                if((newCaseMap.get(caseId).Date_Time_Case_Status_Under_Review__c == null) && newcaseMap.get(caseID).Status== 'Under Review' ){
                    newCaseMap.get(caseId).Date_Time_Case_Status_Under_Review__c =  datetime.valueOf(system.NOW());  
                }
                if((newCaseMap.get(caseId).Date_Time_Case_Status_Reviewed__c == null) && newcaseMap.get(caseID).Status== 'Reviewed' ){  
                    newCaseMap.get(caseId).Date_Time_Case_Status_Reviewed__c = datetime.valueOf(system.NOW());  
                }
                if((newCaseMap.get(caseId).Date_Time_Case_Denial_Enters_Pending__c == null) && newcaseMap.get(caseID).Status== 'Denial Pending' ){
                    newCaseMap.get(caseId).Date_Time_Case_Denial_Enters_Pending__c = datetime.valueOf(system.NOW());  
                }
            }
        }
    }

    public static Map<Id,Case> filter(Map<Id,Case> newCaseMap){
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CR Review').getRecordTypeId();
        Map<Id,Case> filteredMap = new Map<Id,Case>();

        for(Case c : newCaseMap.values()){
            if(c.RecordTypeId == arbRecordType){
                filteredMap.put(c.Id,c);
            }
        }

        return filteredMap;
    }

    public static List<Case> filter(List<Case> newCaseList){
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CR Review').getRecordTypeId();
        List<Case> filteredList = new List<Case>();

        for(Case c : newCaseList){
            if(c.RecordTypeId == arbRecordType){
                filteredList.add(c);
            }
        }

        return filteredList;
    }
    public static void beforeInsertToggle(){
        beforeInsertProcessed = !beforeInsertProcessed;
    }
    public static void beforeInsertToggle(Boolean foo){
        beforeInsertProcessed = foo;
    }

    public static void afterInsertToggle(){
        afterInsertProcessed = !afterInsertProcessed;
    }
    public static void afterInsertToggle(Boolean foo){
        afterInsertProcessed = foo;
    }

    public static void beforeUpdateToggle(){
        beforeUpdateProcessed = !beforeUpdateProcessed;
    }
    public static void beforeUpdateToggle(Boolean foo){
        beforeInsertProcessed = foo;
    }

    public static void afterUpdateToggle(){
        afterUpdateProcessed = !afterUpdateProcessed;
    }
    public static void afterUpdateToggle(Boolean foo){
        afterUpdateProcessed = foo;
    }
}