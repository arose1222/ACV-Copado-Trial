public with sharing class PrescreenReasonProcesses {
    
    public static void assignPrescreenToQueue(Map<Id,Prescreen_Reason__c> newPrescreenReasonsMap){

        Set<Id> prescreenIds  = new Set<Id>();
        Set<String> reasons  = new Set<String>();

        Map<Id,List<Prescreen_Reason__c>>  prescreenMap = new Map<Id,List<Prescreen_Reason__c>>();
        
        for(Prescreen_Reason__c pr : newPrescreenReasonsMap.values()){ prescreenIds.add(pr.Condition_Report_Prescreen__c); }

        List<Condition_Report_Prescreen__c> existingPrescreens = [SELECT Id, OwnerId, Aux_Prescreen_Status__c, Status__c, (select Id, Name from Prescreen_Reasons__r) FROM  Condition_Report_Prescreen__c WHERE Id IN: prescreenIds AND (Status__c = 'New' OR Aux_Prescreen_Status__c = 'Reviewed - No Issues')];

        for(Condition_Report_Prescreen__c prescreen : existingPrescreens){
            for(Prescreen_Reason__c reason : prescreen.Prescreen_Reasons__r){
                reasons.add(reason.Name);
            }
        }

        List<CR_Review_Trigger__mdt> reviewTriggerMetadatas = [SELECT Id, Assigned_Queue__r.Priority__c, Assigned_Queue__r.DeveloperName, Prescreen_Reason__c
                                                                FROM CR_Review_Trigger__mdt
                                                                WHERE Prescreen_Reason__c IN: reasons
                                                                AND Active__c = true];

        Set<String> queueNames = new Set<String>();

        for(CR_Review_Trigger__mdt rtm : reviewTriggerMetadatas){
            if(CR_Review_Trigger__mdt.Assigned_Queue__c != null){ queueNames.add(rtm.Assigned_Queue__r.DeveloperName); }
        }

        List<Group> queues = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN: queueNames];

        Map<String,Id> queuesMap = new Map<String,Id>();
        
        for(Group queue : queues){ queuesMap.put(queue.DeveloperName,queue.Id); }

        List<Condition_Report_Prescreen__c> prescreenToUpdate = new List<Condition_Report_Prescreen__c>();
        
        for(Condition_Report_Prescreen__c prescreen : existingPrescreens){

            String lowestPriorityQueue;
            Decimal lowestPriority;

            //FOR EVERY REASON ON THAT EACH PRESCREEN
            for(Prescreen_Reason__c pr : prescreen.Prescreen_Reasons__r){

                for(CR_Review_Trigger__mdt rtm : reviewTriggerMetadatas){

                    if(rtm.Prescreen_Reason__c == pr.Name){

                        //VALUES NOT INITIALIZED

                        if(lowestPriorityQueue == null && lowestPriority == null){
                            lowestPriorityQueue = rtm.Assigned_Queue__r.DeveloperName;
                            lowestPriority = rtm.Assigned_Queue__r.Priority__c;
                        }

                        else{//VALUES INITIALIZED

                            if(lowestPriority > rtm.Assigned_Queue__r.Priority__c){
                                lowestPriorityQueue = rtm.Assigned_Queue__r.DeveloperName;
                                lowestPriority = rtm.Assigned_Queue__r.Priority__c;
                            }

                        }

                    }

                }

            }

            if(lowestPriorityQueue != null && queuesMap.containsKey(lowestPriorityQueue) && prescreen.OwnerId != queuesMap.get(lowestPriorityQueue) ){
                //Logic to handel if the prescreen was closed but we need to re open for Arb Guard or AMP
                if(lowestPriorityQueue == 'Specialized_Prescreen' && prescreen.Aux_Prescreen_Status__c == 'Reviewed - No Issues'){ 
                    system.debug('NEW LOG');
                    system.debug('SETTING THE USER AND STATUS');
                    prescreenToUpdate.add(new Condition_Report_Prescreen__c(Id = prescreen.Id, OwnerId = queuesMap.get(lowestPriorityQueue), Status__c = 'New'));
                }
                else{
                    prescreenToUpdate.add(new Condition_Report_Prescreen__c(Id = prescreen.Id, OwnerId = queuesMap.get(lowestPriorityQueue)));
                }
            }
            
        }

        if(!prescreenToUpdate.isEmpty()){ update prescreenToUpdate; }
       
    }

}